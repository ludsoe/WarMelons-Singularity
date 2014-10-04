
MelonE2 = {}

function MelonE2.CanCommand(self,ent)
	local myteam = self.player:GetMTeam().name
	local enteam = ent.MelonTeam
	if not ent.MelonOrders then return false end
	if ply:IsAdmin() then return true end
	if myteam == enteam then return true end
	return false 
end

e2function number entity:ismelon()
	if not IsValid(this) then return 0 end
	if not this.IsMelon then return 0 end
	if not this.IsMelon == true then return 0 end
	return 1
end

e2function number entity:cantakemelonorders()
	if not IsValid(this) then return 0 end
	if not this.MelonOrders then return 0 end
	if not this.MelonOrders == true then return 0 end
	return 1
end

e2function void entity:clearmelonorders()
	if not IsValid(this) then return end
	if not this.MelonOrders then return end
	if MelonE2.CanCommand(self,this) then
		this:ClearOrders()
	end
end

e2function void entity:givemelonmoveorder(vector vec)
	if not IsValid(this) then return end
	if not this.MelonOrders then return end
	if MelonE2.CanCommand(self,this) then
		this:AddOrder({T="Goto",V=vec})
	end
end

e2function table entity:getmelonorders()
	if not IsValid(this) then return {} end
	if not this.MelonOrders then return {} end
	if MelonE2.CanCommand(self,this) then
		return this:GetOrders()
	end
	return {}
end