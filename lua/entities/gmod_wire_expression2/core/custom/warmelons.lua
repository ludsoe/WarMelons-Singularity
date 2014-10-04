
EnvExpTest = {}

function EnvExpTest.AdminAction(self)
	local ply = self.player
	return ply:IsAdmin()
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
	this:ClearOrders()
	return
end

e2function void entity:givemelonmoveorder(vector vec)
	if not IsValid(this) then return end
	if not this.MelonOrders then return end
	this:AddOrder({T="Goto",V=vec})
	return
end

e2function array entity:getmelonorders()
	if not IsValid(this) then return end
	if not this.MelonOrders then return end
	
	return this:GetOrders()
end