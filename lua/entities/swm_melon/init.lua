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
	
	self.OrderFuncs["Enter"]=function(self,Dat)
		local Ent = Dat.E
		if not Ent or not IsValid(Ent) then return true end
		if self:GetPos():Distance(Ent:GetPos())<100 then
			if Ent.CanEnter and not Ent:CanEnter(self) then return end
			table.insert(Ent.StoredMelons,self.InitData.N)
			self:Remove()
			return true
		else
			self:ManageMovement(Ent:GetPos())
		end
		return false
	end
	
	self.OrderFuncs["Goto"]=function(self,Dat)
		return self:ManageMovement(Dat.V)
	end
end

function ENT:BSRemove()
	if self.MelonTeam then
		self.MelonTeam:DeRegisterMelon(self)
	end
end

local function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function ENT:MoveTrace(Target)
	local Parent = self:GetParent()
	if self.IgnoreTrace then return false end
	if not Parent or not IsValid(Parent) then
		local Start = self:GetPos()
		local tr = util.TraceLine({start = Start,endpos = Target+Start,filter = self} )
		if tr.HitWorld then return false end
		if tr.Hit then
			return tr.HitPos:Distance(Start)<50
		else
			return false
		end
	end
	return true
end

function ENT:ManageMovement(Pos)
	local angle1 = Pos - self:GetPos()
	if self:GetPos():Distance(Pos)>50 then
		self:GetPhysicsObject():SetDamping(2, 0)
		if self:GetVelocity():Length() < self.DNA.Speed then
			if not self:MoveTrace(angle1) then 
				self:GetPhysicsObject():ApplyForceCenter(Normalize(angle1)*self.DNA.Force)
			end
		end
	else
		return true
	end
	return false
end
