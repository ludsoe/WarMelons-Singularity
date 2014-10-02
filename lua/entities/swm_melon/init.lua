AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:BSSetup(Data,ply)
	self:ClearOrders()
	
	self.MelonTeam:RegisterMelon(self)
end

function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function ENT:LineOfSight(Vec,Ent,Team,Filter,X)
	local tr = util.TraceLine({start = self:GetPos(),endpos = Vec,filter = table.Merge({self},Filter or {})} )
	local Hit,HitEnt = tr.Hit,tr.Entity
	
	if (X or 0) > 5 then return else X=(X or 0)+1 end
	
	if not Hit then
		return true
	else
		if HitEnt.MelonTeam == self.MelonTeam then
			local Filter = Filter or {}
			table.insert(Filter,HitEnt)
			return self:LineOfSight(Vec,Ent,Team,Filter,X)
		else
			if IsValid(Ent) and IsValid(HitEnt) then
				if not Ent==HitEnt and Ent.MelonTeam == HitEnt.MelonTeam then
					self.Enemy = HitEnt
					return false
				else
					return true
				end
			else
				return false
			end
		end
	end
end

function ENT:DrawAttack(S,E)
	local effectdata = EffectData()
		effectdata:SetOrigin(S+Vector(0,0,5))
		effectdata:SetStart(E+Vector(0,0,0))
		effectdata:SetEntity(self)
	util.Effect( "attack_beam", effectdata )
end

function ENT:Attack(Ent)
	local EPos = Ent:GetPos()
	if not Ent or not IsValid(Ent) then return end
	local Distance = self:GetPos():Distance(Ent:GetPos())
	if self:LineOfSight(EPos,Ent) and Distance<self.DNA.Range then
		if self.Times.Attack < CurTime() then
			Singularity.DealDamage(Ent,EPos,self.DNA.Damage,self,self)
			self.Times.Attack=CurTime()+self.DNA.AttackRate
			self:DrawAttack(self:GetPos(),Ent:GetPos())
		end
	else
		if Distance>self.DNA.Range*2 then
			self.Enemy = nil
		end
	end
end

function ENT:ScanEnemys()
	if self.Times.Scan < CurTime() then
		local entz = ents.FindInSphere(self:GetPos(),self.DNA.Range*2)
		for k, v in pairs(entz) do
			if v.MelonTeam and not v:IsPlayer() then
				if v.MelonTeam~=self.MelonTeam then
					if self:LineOfSight(v:GetPos(),v) then
						self.Enemy = v
						break
					end
				end
			end
		end
		self.Times.Scan=CurTime()+0.2
	end
end

local MoveRange = 50
function ENT:ManageMovement(Pos)
	local angle1 = Pos - self:GetPos()
	if self:GetPos():Distance(Pos)>MoveRange then
		self:GetPhysicsObject():SetDamping(2, 0)
		if self:GetVelocity():Length() < self.DNA.Speed then
			self:GetPhysicsObject():ApplyForceCenter(Normalize(angle1) * self.DNA.Force)
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
		if self.Enemy and IsValid(self.Enemy) then
			self:ManageMovement(self.Enemy:GetPos()+(Normalize(self:GetPos()-self.Enemy:GetPos())*(self.DNA.Range/2)))
		else
			self.Enemy = nil
		end
	end
end