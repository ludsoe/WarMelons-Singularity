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
	
	Team:RegisterMelon(self)
	
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
