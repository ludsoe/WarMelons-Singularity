local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Teams = Singularity.Teams

local Team = {
	name = "Error",
	color = Color(255,255,255,255),
	Members = {},
	Melons = {Units={},Buildings={}},
	Settings = {CanJoin = true, AttackMode = 1},
	Diplomacy = {},
	Persist = false
}

Team.DefaultSettings = Team.Settings

function Team:Setup(name,color)
	self.name = name
	self.color = color
	
	self:StartCheckTimer()
	self:SyncData()
	
	for k, v in pairs(Teams.Teams) do
		self:MakeNeutral(v)
	end
end

function Team:SetMaxMelons(Max)
	self.MaxMelons = Max
end

function Team:LockTeam()
	self.Settings.CanJoin = true
end

function Team:MakePersist()
	self.Persist = true
end

function Team:CleanupMelons()
	for k, v in pairs(self.Melons.Units) do
		local Ent = v.E
		if Ent and IsValid(Ent) then
			Ent:Remove()
		end
	end
end

function Team:CleanupStructures()
	for k, v in pairs(self.Melons.Buildings) do
		local Ent = v.E
		if Ent and IsValid(Ent) then
			Ent:Remove()
		end
	end	
end

function Team:Reset()
	self:CleanupMelons()
	self:CleanupStructures()
	
	self.Settings = table.Copy(self.DefaultSettings)
end

function Team:TeamDestroy()
	
	if self.Persist then self:Reset() return end

	self:CleanupMelons()
	self:CleanupStructures()
	
	--Add Player booting.
	
	Singularity.Debug("Deleting Team: "..self.name,2,"MTeams")
	
	NDat.AddDataAll({
		Name="TeamDelete",
		Val=1,
		Dat={{N="N",T="S",V=self.name}}
	})
		
	Teams.Teams[self.name]=nil
	Utl:SetupThinkHook(self.name.."MelonCheckHook",0,1,function() end)
end

function Team:AddMember(Ply)
	local OldTeam = Ply:GetMTeam()

	if OldTeam then
		if OldTeam.name == self.name then return end
		OldTeam:RemoveMember(Ply)
	end
	
	for k, v in pairs(self.Members) do
		v.E:SendColorChat("WMG",self.color,Ply:Nick().." Is now in you're Team.")
	end
	
	Singularity.Debug("Player: "..Ply:Nick().." is now in "..self.name,2,"MTeams")
	if table.Count(self.Members) <= 0 then
		self:SetLeader(Ply)
	else
		Ply:SendColorChat("WMG",self.color,"You are now in Team: "..self.name)
	end
	
	self.Members[Ply:Nick()]={ID=Ply:EntIndex(),E=Ply}
	Ply.MelonTeam=self.name
	Ply:ClearSelectedMelons()
	
	self:SyncMember(Ply)
	self:SyncData()
end

function Team:RemoveMember(Ply)	
	self.Members[Ply:Nick()]=nil

	if table.Count(self.Members) <= 0 then
		self:TeamDestroy()
		return
	end
		
	for k, v in pairs(self.Members) do
		v.E:SendColorChat("WMG",self.color,Ply:Nick().." has left you're Team.")
	end
	
	if self.Leader.E == Ply then
		self:GetNewLeader()
	end
	
	self:SyncData()
end

function Team:GetLeader() return self.Leader.E end
function Team:SetLeader(Ply) 
	self.Leader = {ID=Ply:EntIndex(),E=Ply}
	Ply:SendColorChat("WMG",self.color,"You are now the Leader of Team: "..self.name)

	Singularity.Debug("Player: "..Ply:Nick().." is leader of "..self.name,2,"MTeams")
	
	self:SyncData()
end

function Team:GetNewLeader() 
	for k, v in pairs(self.Members) do
		if v.E and IsValid(v.E) then
			self:SetLeader(v.E)
			return
		end	
	end
end

function Team:RegisterMelon(Ent)
	self.Melons.Units[Ent:EntIndex()]={E=Ent,Id=Ent:EntIndex()}
end

function Team:RegisterStructure(Ent)
	self.Melons.Buildings[Ent:EntIndex()]={E=Ent,Id=Ent:EntIndex()}
end

function Team:CheckMelons()
	for k, v in pairs(self.Melons.Units) do
		local Ent = v.E
		if not Ent or not IsValid(Ent) then
			self.Melons.Units[k] = nil
		end
	end
	
	for k, v in pairs(self.Melons.Buildings) do
		local Ent = v.E
		if not Ent or not IsValid(Ent) then
			self.Melons.Buildings[k] = nil
		end
	end	
	
	self:SyncData()
end

function Team:StartCheckTimer()
	Utl:SetupThinkHook(self.name.."MelonCheckHook",10,0,function() self:CheckMelons() end)
end

function Team:CanMakeMelon(Barracks)
	local Count = table.Count(self.Melons.Units)
	if not self.Persist then
		return Count < Singularity.Settings["PlayerTeamMelonCap"]
	else
		return Count < Singularity.Settings["PersistTeamMelonCap"]
	end
	return true
end

function Team:CanMakeBuilding()
	local Count = table.Count(self.Melons.Buildings)
	if not self.Persist then
		return Count < Singularity.Settings["PlayerTeamBuildingCap"]
	else
		return Count < Singularity.Settings["PersistTeamBuildingCap"]
	end
	return true
end

function Team:CanPlayerJoin(Ply)
	if Utl:CheckAdmin( Ply ) then return true end
	if not self.Settings.CanJoin then return false end
	return true
end

function Team:DiplomacyCheck(Team,Over)
	self.Diplomacy[Team.name] = self.Diplomacy[Team.name] or "Neutral"
	if not Over then Team:DiplomacyCheck(self,true) end
end

function Team:CanAttack(Ent)
	if not Ent.MelonTeam then return end
	return not Ent.MelonTeam:GetRelations(self) == "Hostile"
end

function Team:CanHeal(Ent)
	if not Ent.MelonTeam then return end
	return not Ent.MelonTeam:GetRelations(self) == "Allied"
end

function Team:GetRelations(Team)
	self:DiplomacyCheck(Team)
	return self.Diplomacy[Team.name]
end

function Team:SetRelations(Team,Rel)
	self.Diplomacy[Team.name]=Rel
end

function Team:MakeAlly(Team,Over) 
	self:DiplomacyCheck(Team)
	
	if self:GetRelations(Team)=="Pending" then return end
	
	self:SetRelations(Team,"Pending")
	
	if Team:GetRelations(self)=="Pending" then
		self:SetRelations(Team,"Allied")
		
		Team:MsgMembers("You're now allied with Team: "..Team.name)
		
		if Over then return end
		Team:MakeAlly(self,true)
	else
		Team:MsgMembers("Team: "..self.name.." wants to become allied with you!")
		self:MsgMembers("Alliance Request with Team: "..Team.name.." is pending!")
	end
	
	self:SyncData()
end

function Team:MakeEnemy(Team,Over) 
	self:DiplomacyCheck(Team)
	
	self:SetRelations(Team,"Hostile")
	
	if Team:GetRelations(self)=="Allied" then
		Team:MakeEnemy(self)
	end
	
	self:MsgMembers("You're now Hostile towards Team: "..Team.name)

	self:SyncData()
end

function Team:MakeNeutral(Team,Over)
	self:DiplomacyCheck(Team)

	self:SetRelations(Team,"Neutral")
	
	if Team:GetRelations(self)=="Allied" then
		Team:MakeNeutral(self)
	end
	
	self:MsgMembers("You're now Neutral towards Team: "..Team.name)
	
	self:SyncData()
end

function Team:MsgMembers(Text)
	for k, v in pairs(self.Members) do
		if v.E and IsValid(v.E) then
			v.E:SendColorChat("WMG",self.color,""..Text)
		end
	end
end

function Team:SyncMember(Ply)
	NDat.AddData({
		Name="TeamMemberJoin",
		Val=1,
		Dat={{N="N",T="S",V=self.name}}
	},Ply)
end

function Team:SyncData()
	NDat.AddDataAll({
		Name="TeamSyncMsg",
		Val=1,
		Dat={{N="N",T="S",V=self.name},{N="T",T="T",V=self}}
	})
end

Singularity.Teams.Class = Team













