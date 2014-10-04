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

local MoveRange = 50
function ENT:ManageMovement(Pos)
	local angle1 = Pos - self:GetPos()
	if self:GetPos():Distance(Pos)>MoveRange then
		self:GetPhysicsObject():SetDamping(2, 0)
		if self:GetVelocity():Length() < self.DNA.Speed then
			if self:MoveTrace(angle1) then
				self:GetPhysicsObject():ApplyForceCenter(Normalize(angle1) * self.DNA.Force)
			end
		end
	else
		return true
	end
	return false
end

function ENT:RunOrders()
	if table.Count(self.Orders)>0 then
		for k, v in pairs(self.Orders) do
			local Completed = false
			if v.T == "Goto" then
				Completed = self:ManageMovement(v.V)
			end
			
			if Completed then
				self:RemoveOrder(k)
			else
				break
			end
		end
	else
		if self.Target and IsValid(self.Target) then
			self:ManageMovement(self.Target:GetPos()+(Normalize(self:GetPos()-self.Target:GetPos())*(self.DNA.Range/2)))
		else
			self.Target = nil
		end
	end
end

