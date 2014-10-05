
MelonE2 = {}

function MelonE2.CanCommand(self,ent)
	local myteam = self.player:GetMTeam().name
	local enteam = ent.MelonTeam
	if not ent.MelonOrders then return false end
	if ply:IsAdmin() then return true end
	if myteam == enteam then return true end
	return false 
end

e2function number entity:wmismelon()
	if not IsValid(this) then return 0 end
	if not this.IsMelon then return 0 end
	if not this.IsMelon == true then return 0 end
	return 1
end

e2function number entity:wmisbarracks()
	if not IsValid(this) then return 0 end
	if not this.IsBarracks then return 0 end
	if not this.IsBarracks == true then return 0 end
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
		--this:AddOrder({T="Goto",V=vec})
	end
end

e2function array entity:wmgetorders()
	if not IsValid(this) then return {} end
	if not this.MelonOrders then return {} end
	if MelonE2.CanCommand(self,this) then
		local Array = {}
		for k,v in pairs( this:GetOrders() ) do
			Array[#Array + 1] = v
		end
		return Array
	end
	return {}
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

e2function array entity:wmgetmelontypes()
	local Types = {}
	for k, v in pairs(Singularity.Entities.Modules["Melons"]) do
		Array[#Array + 1] = v
	end
	return Types
end