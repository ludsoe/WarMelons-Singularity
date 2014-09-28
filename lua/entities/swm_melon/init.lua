AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function ENT:LineOfSight(Vec,Ent)
	local tr = util.TraceLine({start = self:GetPos(),endpos = Vec,filter = self} )
	local Hit,HitEnt = tr.Hit,tr.Entity
	
	if not Hit then
		return true
	else
		if IsValid(Ent) and IsValid(HitEnt) and Ent==HitEnt then
			return true
		else
			return false
		end
	end
end

function ENT:Attack(Ent)
	local EPos = Ent:GetPos()
	if not Ent or not IsValid(Ent) then return end
	if self:LineOfSight(EPos,Ent) then
		if self.Times.Attack < CurTime() then
			Singularity.DealDamage(Ent,EPos,self.DNA.Damage,self,self)
			self.Times.Attack=CurTime()+self.DNA.AttackRate
		end
	end
end

function ENT:ScanEnemys()
	if self.Times.Scan < CurTime() then
		local entz = ents.FindInSphere(self:GetPos(),self.DNA.Range)
		for k, v in pairs(entz) do
			if v.MelonTeam and not v:IsPlayer() then
				if v.MelonTeam~=self.MelonTeam then
					if self:LineOfSight(v:GetPos(),v) then
						self.Enemy = v
					end
				end
			end
		end
		self.Times.Scan=CurTime()+self.DNA.AttackRate
	end
end

local MoveRange = 50
function ENT:ManageMovement()
	if self.TargetVec ~= nil && self.TargetVec[1] ~= nil then
		local angle1 = self.TargetVec[1] - self:GetPos()
		if self:GetPos():Distance(self.TargetVec[1])>MoveRange then
			self:GetPhysicsObject():SetDamping(2, 0)
			local blah = math.abs(angle1.x - angle1.y)
			if (self:GetVelocity():Length() < self.DNA.Speed or self.Grav == false ) and (blah >= 20 or angle1.z < self:GetPos().z) then
				self:GetPhysicsObject():ApplyForceCenter(Normalize(angle1) * self.DNA.Force)
			end
		else
			table.remove(self.TargetVec,1)
		end
	end
end

function ENT:WanderAI()

end