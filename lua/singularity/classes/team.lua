local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Teams = Singularity.Teams

local Team = {
	name = "Error",
	color = Color(255,255,255,255),
	Members = {},
	Melons = {Units={},Buildings={},Props={}},
	Settings = {CanJoin = true, AttackMode = 1,
	Persist = false, Hidden = false, AIMode = false},
	Resources = {Melonium=400,Metal=400},
	Diplomacy = {},
	AIData = {}
}

--Default Table Data.
Team.DefaultSettings = table.Copy(Team.Settings)
Team.DefaultResources = table.Copy(Team.Resources)

function Team:Update()
	if self:GetAIMode() then -- Ai is enabled for this team, call the run cycle function in the ai class.
		self.AIData:RunCycle()
	end
end

function Team:GetAIMode()
	return self.Settings.AIMode
end

function Team:ChangeSetting(Set,Val,Over)
	print("Changing Setting: "..tostring(Set).." to "..tostring(Val))
	if self.Settings[Set] == nil then 
		return 
	end
	
	self.Settings[Set] = Val
	
	if Over then
		self.DefaultSettings[Set] = Val
	end
	
	self:SyncData()
end

function Team:SetDefaultDiplomacy()
	for k, v in pairs(Teams.Teams) do
		if v:IsHidden() or self:IsHidden() then
			v:MakeNeutral(self)
			self:MakeNeutral(v)
		else
			v:MakeEnemy(self)
			self:MakeEnemy(v)
		end
	end
	self:SetRelations(self,"Allied")
end

function Team:Setup(name,color)
	self.name = name
	self.color = color
	
	self.AIData = table.Copy(Singularity.Teams.AIClass) -- Copy us a clean team ai class.
	self.AIData.MyTeam = self --Identify with the ai class 
	
	self:StartCheckTimer()
	self:SyncData()
	
	self:SetDefaultDiplomacy()
end

function Team:LockTeam(Bool)
	self.Settings.CanJoin = Bool or true
end

function Team:IsHidden()
	return self.Settings.Hidden
end

function Team:IsPersist()
	return self.Settings.Persist
end

function Team:LoopMels(tab,func)
	for k, v in pairs(self.Melons[tab]) do
		local Ent = v.E
		if Ent and IsValid(Ent) then
			func(k,Ent)
		else
			self.Melons[tab][k]=nil
		end
	end
end

function Team:SetColor(color)
	self.color = color
	self:SyncData()
	
	self:LoopMels("Units",function(k,Ent)
		Ent:SetColor(self.color)
	end)
	self:LoopMels("Buildings",function(k,Ent)
		Ent:SetColor(self.color)
	end)
	self:LoopMels("Props",function(k,Ent)
		Ent:SetColor(self.color)
	end)
end

function Team:CleanupMelons()
	self:LoopMels("Units",function(k,Ent)
		Ent:Remove()
		self.Melons.Units[k]=nil
	end)
end

function Team:CleanupStructures()
	self:LoopMels("Buildings",function(k,Ent)
		Ent:Remove()
		self.Melons.Buildings[k]=nil
	end)
end

function Team:CleanupProps()
	self:LoopMels("Props",function(k,Ent)
		Ent:Remove()
		self.Melons.Props[k]=nil
	end)
end

function Team:Reset()
	self:CleanupMelons()
	self:CleanupStructures()
	self:CleanupProps()
	
	self.Settings = table.Copy(self.DefaultSettings)
	self.Resources = table.Copy(self.DefaultResources)

	self:SetDefaultDiplomacy()
end

function Team:TeamDestroy()
	
	if game.SinglePlayer and game.SinglePlayer() then return end
	
	if self:GetAIMode() then return end --Dont reset if we have a ai in control.
	
	if self:IsPersist() then self:Reset() return end

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

function Team:CheckMembers()
	if table.Count(self.Members) <= 0 then
		self:SyncData()
		self:TeamDestroy()
		return true
	end
	return false
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

	if self.Leader and self.Leader.E == Ply then
		self:GetNewLeader()
	end
	
	if self:CheckMembers() then return end
		
	for k, v in pairs(self.Members) do
		v.E:SendColorChat("WMG",self.color,Ply:Nick().." has left you're Team.")
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
	self.Leader = nil
	self:SyncData()	
end

function Team:AddResource(Res,Amt) self.Resources[Res]=self.Resources[Res]+Amt end
function Team:UseResource(Res,Amt) self.Resources[Res]=self.Resources[Res]-Amt end
function Team:CanUseResource(Res,Amt) return self.Resources[Res] >= Amt end
function Team:GetResources() return self.Resources end
function Team:GetResource(Res) return self.Resources[Res] or 0 end

function Team:RegisterMelon(Ent) self.Melons.Units[Ent:EntIndex()]={E=Ent,Id=Ent:EntIndex()} end
function Team:RegisterStructure(Ent) self.Melons.Buildings[Ent:EntIndex()]={E=Ent,Id=Ent:EntIndex()} end
function Team:RegisterProp(Ent) self.Melons.Props[Ent:EntIndex()]={E=Ent,Id=Ent:EntIndex()} end

function Team:DeRegisterProp(Ent) self.Melons.Props[Ent:EntIndex()]=nil end
function Team:DeRegisterStructure(Ent) self.Melons.Buildings[Ent:EntIndex()]=nil end
function Team:DeRegisterMelon(Ent) self.Melons.Units[Ent:EntIndex()]=nil end

function Team:CheckMelons()
	self:LoopMels("Units",function(k,Ent) end)	
	self:LoopMels("Buildings",function(k,Ent) end)	
	self:LoopMels("Props",function(k,Ent) end)
	
	self:SyncData()
end

function Team:StartCheckTimer()
	Utl:SetupThinkHook(self.name.."MelonCheckHook",5,0,function() self:CheckMelons() end)
	Utl:SetupThinkHook(self.name.."UpdateTick",1,0,function() self:Update() end)
end

function Team:CanMakeMelon(Barracks)
	local Count = table.Count(self.Melons.Units)
	if not self.Persist then
		return Count < tonumber(Singularity.Settings["PlayerTeamMelonCap"])
	else
		return Count < tonumber(Singularity.Settings["PersistTeamMelonCap"])
	end
	return true
end

function Team:CanMakeBuilding()
	local Count = table.Count(self.Melons.Buildings)
	if not self.Persist then
		return Count < tonumber(Singularity.Settings["PlayerTeamBuildingCap"])
	else
		return Count < tonumber(Singularity.Settings["PersistTeamBuildingCap"])
	end
	return true
end

function Team:CanPlayerJoin(Ply)
	if Utl:CheckAdmin( Ply ) then return true end
	if not self.Settings.CanJoin then return false end
	return true
end

function Team:DiplomacyCheck(Team,Over)
	if type(Team)=="string" then Team = Teams.Teams[Team] end
	self.Diplomacy[Team.name] = self.Diplomacy[Team.name] or "Neutral"
	if not Over then Team:DiplomacyCheck(self,true) end
end

function Team:CanAttack(Ent)
	if not Ent.MelonTeam or Ent:IsPlayer() then return false end
	if self:GetRelations(Ent.MelonTeam) == "Hostile" then
		return true
	end
	return false 
end

function Team:CanHeal(Ent)
	if not Ent.MelonTeam or Ent:IsPlayer() then return false end
	if self:GetRelations(Ent.MelonTeam) == "Allied" then
		return true
	end
	return false
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
	
	local Relations = self:GetRelations(Team)
	if Relations == "Allied" then return end
	
	if Team:GetRelations(self)=="Pending" then
		self:SetRelations(Team,"Allied")
		Team:SetRelations(self,"Allied")
		
		Team:MsgMembers("You're now allied with Team: "..self.name)
		self:MsgMembers("You're now allied with Team: "..Team.name)
	else
		if Relations == "Pending" then return end
		self:SetRelations(Team,"Pending")

		Team:MsgMembers("Team: "..self.name.." wants to become allied with you!")
		self:MsgMembers("Alliance Request with Team: "..Team.name.." is pending!")
	end
	
	self:SyncData()
end

function Team:MakeEnemy(Team,Over) 
	self:DiplomacyCheck(Team)
	
	if self:GetRelations(Team)=="Hostile" then return end
	if self:IsHidden() or Team:IsHidden() then return end --Hidden teams cant become hostile.
	
	self:SetRelations(Team,"Hostile")
	
	if Team:GetRelations(self)=="Allied" then
		Team:MakeEnemy(self)
	end
	
	self:MsgMembers("You're now Hostile towards Team: "..Team.name)

	self:SyncData()
end

function Team:MakeNeutral(Team,Over)
	self:DiplomacyCheck(Team)
	
	if self:GetRelations(Team)=="Neutral" then return end

	self:SetRelations(Team,"Neutral")
	Team:MakeNeutral(self)
	
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













