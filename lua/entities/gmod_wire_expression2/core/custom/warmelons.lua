
MelonE2 = {}

function MelonE2.CanCommand(self,ent)
	local myteam = self.player:GetMTeam().name
	local enteam = ent.MelonTeam.name
	if not ent.MelonOrders then return false end
	if self.player:IsAdmin() then return true end
	if myteam == enteam then return true end
	return false 
end

function MelonE2.E2Team(self)
	return self.player:GetMTeam()
end

e2function number entity:wmismelon()
	if not IsValid(this) then return 0 end
	if not this.IsMelon then return 0 end
	if not this.IsMelon == true then return 0 end
	return 1
end

e2function number entity:wmhasmelonteam()
	if not IsValid(this) then return 0 end
	if not this.MelonTeam then return 0 end
	if this.MelonTeam then return 1 end
	return 0
end

e2function string entity:wmgetteamname()
	if not IsValid(this) then return "" end
	if not this.MelonTeam then return "" end
	if this.MelonTeam then return this.MelonTeam.name or "" end
	return ""
end

-- 0 hostile 1 friendly 2 nuetral
e2function number entity:wmisfriendly()
	if not IsValid(this) then return 2 end
	if not this.MelonTeam then return 2 end
	local R = MelonE2.E2Team(self):GetRelations(this.MelonTeam)
	if R == "Allied" then
		return 1
	elseif R == "Hostile" then
		return 0
	end
	return 2
end

e2function number entity:wmisbarracks()
	if not IsValid(this) then return 0 end
	if not this.IsBarracks then return 0 end
	if not this.IsBarracks == true then return 0 end
	return 1
end

e2function string entity:wmgettype()
	if not IsValid(this) then return "" end
	if not this.InitData then return "" end
	return self.InitData.N or ""
end

e2function number entity:wmisminable()
	if not IsValid(this) then return 0 end
	if not this.IsMinable then return 0 end
	if not this.IsMinable == true then return 0 end
	return 1
end

e2function number entity:wmcantakeorders()
	if not IsValid(this) then return 0 end
	if not this.MelonOrders then return 0 end
	if not this.MelonOrders == true then return 0 end
	return 1
end

e2function void entity:wmclearorders()
	if not IsValid(this) then return end
	if not this.MelonOrders then return end
	if MelonE2.CanCommand(self,this) then
		this:ClearOrders()
	end
end

e2function void entity:wmsettarget(entity ent)
	if not IsValid(this) then return end
	if not this.IsMelon then return end
	if MelonE2.CanCommand(self,this) then
		this.Target=ent
	end
end

e2function void entity:wmgivemoveorder(vector vec)
	if not IsValid(this) then return end
	if not this.MelonOrders then return end
	if MelonE2.CanCommand(self,this) then
		local TrueVector = Vector(vec[1],vec[2],vec[3])
		this:AddOrder({T="Goto",V=TrueVector})
	end
end

e2function number entity:wmhasorder()
	if not IsValid(this) then return 0 end
	if not this.MelonOrders then return 0 end
	if MelonE2.CanCommand(self,this) then
		if this:GetOrders()[1] then
			return 1
		end
	end
	return 0
end

e2function number entity:wmgethealth()
	if not IsValid(this) then return 0 end
	return Singularity.GetHealth( this )
end

e2function vector entity:wmgetorder()
	local Vec = {0,0,0}
	if not IsValid(this) then return Vec end
	if not this.MelonOrders then return Vec end
	if MelonE2.CanCommand(self,this) then
		local V = this:GetOrders()[1] or Vector(0,0,0)
		return {V.x,V.y,V.z}
	end
	return Vec
end

e2function void entity:wmaddtobuildqueue(string str)
	if not IsValid(this) then return end
	if not this.MelonOrders then return end
	if MelonE2.CanCommand(self,this) then
		this:AddToQueue(str)
	end
end

e2function array entity:wmgetbuildqueue()
	if not IsValid(this) then return {} end
	if not this.MelonOrders then return {} end
	if not this.IsBarracks then return {} end
	if MelonE2.CanCommand(self,this) then
		local Array = {}
		for k,v in pairs( this.BuildQueue ) do
			Array[#Array + 1] = v
		end
		return Array
	end
	return {}
end

e2function void entity:wmclearbuildqueue()
	if not IsValid(this) then return end
	if not this.MelonOrders then return end
	if not this.IsBarracks then return end
	if MelonE2.CanCommand(self,this) then
		this:ClearQueue()
	end
end

e2function array wmgetmelontypes()
	local Types = {}
	for k, v in pairs(Singularity.Entities.Modules["Melons"]) do
		Array[#Array + 1] = v
	end
	return Types
end

e2function number wmgetresource(res)
	local myteam = self.player:GetMTeam().name
	local Team = Singularity.Teams.Teams[myteam]
	if not Team then return 0 end
	return Team:GetResource(res)
end

