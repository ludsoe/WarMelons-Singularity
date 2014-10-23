local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

local function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function ENT:MoveTrace(Target,Ent)
	local Parent = self:GetParent()
	if self.IgnoreTrace then return false end
	if not Parent or not IsValid(Parent) then
		local Start = self:GetPos()
		local tr = util.TraceLine({start = Start,endpos = Target+Start,filter = {self,Ent}} )
		if tr.HitWorld then return false end
		if tr.Hit then
			return tr.HitPos:Distance(Start)<50
		else
			return false
		end
	end
	return true
end

function ENT:ManageMovement(Pos,Ent)
	local angle1 = Pos - self:GetPos()
	if self:GetPos():Distance(Pos)>20 then
		local PO = self:GetPhysicsObject()
		PO:SetDamping(2, 0)
		if self:GetVelocity():Length() < self.DNA.Speed then
			if not self:MoveTrace(angle1,Ent) then 
				PO:ApplyForceCenter((Normalize(angle1)*PO:GetMass())*(self.DNA.Force*60))
			end
		end
	else
		return true
	end
	return false
end

function ENT:HoverAtAlt()
	local MyPos,Pos = self:GetPos(),self:GetPos()
	Pos.z = self.HoverAlt
	local angle1 = Pos - MyPos
	
	local Dis = math.Clamp((MyPos:Distance(Pos)),0,200)
	local Phys = self:GetPhysicsObject()
	local Mass = Phys:GetMass()
	
	if Dis > 0 then
		local F = (Normalize(angle1)*(self.DNA.Force*Mass)*Dis)
		Phys:ApplyForceCenter(F)
	end
	if self:GetVelocity():Length() > 5 then
		Phys:ApplyForceCenter(-(self:GetVelocity()*Vector(0,0,0.4))*Mass)
	end
end