AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:BSSetup(Data,ply)
	self:ClearOrders()
	
	local Team = self.MelonTeam or ply:GetMTeam()

	if not Team:CanMakeMelon() then
		self:Remove()
		return false
	end
	
	self.MelonTeam:RegisterMelon(self)
	
	self.OrderFuncs["Goto"]=function(self,Pos)
		local angle1 = Pos - self:GetPos()
		if self:GetPos():Distance(Pos)>50 then
			self:GetPhysicsObject():SetDamping(2, 0)
			if self:GetVelocity():Length() < self.DNA.Speed then
				local Force = self.DNA.Force
				if not self:MoveTrace(angle1) then Force = -Force end
				self:GetPhysicsObject():ApplyForceCenter(Normalize(angle1)*Force)
			end
		else
			return true
		end
		return false
	end
end

function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function ENT:MoveTrace(Target)
	local Parent = self:GetParent()
	if not Parent or not IsValid(Parent) then
		local Start = self:GetPos()
		local tr = util.TraceLine({start = Start,endpos = Target+Start,filter = self} )
		if tr.Hit and not tr.HitWorld then
			return tr.HitPos:Distance(Start)>50
		else
			return true
		end
	end
end