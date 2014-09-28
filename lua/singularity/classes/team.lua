local Utl = Singularity.Utl --Makes it easier to read the code.

local Team = {
	name = "Error",
	color = Color(255,255,255,255),
	Members = {},
	Melons = {Units={},Buildings={}},
	Diplomacy = {}
}

function Team:Setup(name,color)
	self.name = name
	self.color = color
end

function Team:Destroy()
	
end

function Team:AddMember(Player)
	local OldTeam = Player:GetMTeam()
	if OldTeam~= nil then
		OldTeam:RemoveMember(Player)
	end
	
	if #self.Members <= 0 then
		self:SetLeader(Player)
	end
	
	self.Members[Player:Nick()]=Player
	Player.MelonTeam=self.name
end

function Team:RemoveMember(Player)
	self.Members[Player:Nick()]=nil
	
	if table.Count(self.Members) <= 0 then
		self:Destroy()
		return
	end
	
	if self.Leader == Player then
		self:GetNewLeader()
	end
end

function Team:GetLeader() return self.Leader end
function Team:SetLeader(Player) 
	self.Leader = Player
	Player:SendColorChat("WMG",self.color,"You are now the Leader of Team: "..self.name)
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

Singularity.Teams.Class = Team