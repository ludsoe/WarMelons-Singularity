ENT.Type = "anim"
ENT.Base = "swm_base"
ENT.PrintName = "WarMelon"
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.IsMelon = true
--ENT.DNA = {}
--ENT.Orders = {}
--ENT.SyncedOrders = {}

local function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

/*
function ShouldEntitiesCollide( ent1, ent2 )
	if ent1:IsWorld() or ent2:IsWorld() then return true end --World check
	if ent1 == ent2 then return false end --No self collisions!
	if ent1.IsMelon and ent2.IsMelon then
		local PV1,PV2 = ent1:GetVelocity(),ent2:GetVelocity()
		
		local PingForce = 4000
		
		local PO1,PO2 = ent1:GetPhysicsObject(),ent2:GetPhysicsObject()
		
		if PO1 and IsValid(PO1) then
			PO1:ApplyForceCenter(Normalize(ent1:GetPos()-ent2:GetPos())*PingForce)
		end
		
		if PO2 and IsValid(PO2) then
			PO2:ApplyForceCenter(Normalize(ent2:GetPos()-ent1:GetPos())*PingForce)
		end
		
		--ent1:SetVelocity(-PV1*2+PV2*0.5)
		--ent2:SetVelocity(-PV2*2+PV1*0.5)
		return false
	else
		return true
	end
end
hook.Add( "ShouldCollide", "MelonCollisionFix", ShouldEntitiesCollide )
*/