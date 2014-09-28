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
	
	if #self.Members <= 0 then
		self:Destroy()
	end
end

function Team:GetLeader() return self.Leader end
function Team:SetLeader(Player) self.Leader = Player end
function Team:GetNewLeader() end

function Team:CanMakeMelon() return true end
function Team:CanMakeBuilding() return true end

function Team:MakeAlly() end
function Team:MakeEnemy() end

Singularity.Teams.Class = Team