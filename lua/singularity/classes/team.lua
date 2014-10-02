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
	Persist = false
}

function Team:Setup(name,color)
	self.name = name
	self.color = color
	
	self:SyncData()
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

function Team:CanMakeMelon() return true end
function Team:CanMakeBuilding() return true end

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













