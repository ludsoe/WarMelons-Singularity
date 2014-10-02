local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Teams = Singularity.Teams

local Team = {
	name = "Error",
	color = Color(255,255,255,255),
	Members = {},
	Melons = {Units={},Buildings={}},
	Diplomacy = {},
	Persist = false,
	PlayerOwned = false,
	MaxMelons = 40
}

function Team:Setup(name,color)
	self.name = name
	self.color = color
	
	self:StartCheckTimer()
	self:SyncData()
end

function Team:SetMaxMelons(Max)
	self.MaxMelons = Max
end

function Team:LockTeam()
	self.PlayerOwned = true
end

function Team:MakePersist()
	self.Persist = true
end

function Team:TeamDestroy()
	if self.Persist then return end
	Singularity.Debug("Deleting Team: "..self.name,2,"MTeams")
	
	--Add Melon Destruction
	--Add Player booting.

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
	
	if self.Leader == Ply then
		self:GetNewLeader()
	end
	
	self:SyncData()
end

function Team:GetLeader() return self.Leader end
function Team:SetLeader(Ply) 
	self.Leader = {ID=Ply:EntIndex(),E=Ply}
	Ply:SendColorChat("WMG",self.color,"You are now the Leader of Team: "..self.name)

	Singularity.Debug("Player: "..Ply:Nick().." is leader of "..self.name,2,"MTeams")
	
	self:SyncData()
end

function Team:GetNewLeader() 
	for k, v in pairs(self.Members) do
		self:SetLeader(v)
		return
	end
end

function Team:RegisterMelon(Ent)
	self.Melons.Units[Ent:EntIndex()]={E=Ent,Id=Ent:EntIndex()}
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
	if table.Count(self.Melons.Units) >= self.MaxMelons then
		return false
	end
	return true
end

function Team:CanMakeBuilding() 
	return true
end

function Team:CanPlayerJoin(Ply)
	if self.PlayerOwned then
		return false
	end
	return true
end

function Team:MakeAlly() end
function Team:MakeEnemy() end

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













