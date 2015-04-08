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
			if Ent.CanEnter and not Ent:CanEnter(self) then return false end
			table.insert(Ent.StoredMelons,self.InitData.N)
			--Ent:OnMEnter(self.InitData.N)
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
	
	self:PrecacheGibs()
	
	self.DeathFunc = function(self)
		self:GibBreakClient(self:GetVelocity())
	end
	
	self.GeeCheck = 0
	
--	self:SetCustomCollisionCheck(true)
end

function ENT:BSThink()
	if self.GeeCheck < CurTime() then
		self.GeeCheck = CurTime()+0.2
		
		local Max = 400 --Apparntly 1G is 143, But more testing required.
		
		self.OldSpeed = self.OldSpeed or 0
		local CurSpeed = self:GetVelocity():Length()
		local GForces = CurSpeed - self.OldSpeed
		
		if GForces > Max or GForces < -Max then
			 Singularity.KillEnt(self)
		else
			self.OldSpeed = CurSpeed
		end
	end
end

function ENT:BSRemove()
	if self.MelonTeam then
		self.MelonTeam:DeRegisterMelon(self)
	end
end

/*
function ENT:PhysicsCollide(data,physobj)
	if data.HitEntity:GetClass() == "swm_melon" then
		--self:SetVelocity(-data.OurOldVelocity*2+data.TheirOldVelocity*0.5)
		return false
	end
end*/

