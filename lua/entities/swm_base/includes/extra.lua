function ENT:TeamBaseWelds()
	local Ents = constraint.GetAllConstrainedEntities_B( self )
	
	for n, ent in pairs( Ents ) do
		if not ent.IsMelon then
			ent.MelonTeam = self.MelonTeam
			ent:SetColor(self:GetColor())
		end
	end
end

function ENT:LineOfSight(Vec,Ent,Team,Filter,X)
	if (X or 0) > 5 then return false else X=(X or 0)+1 end

	local tr = util.TraceLine({start = self:GetPos(),endpos = Vec,filter = table.Merge({self},Filter or {})} )
	local Hit,HitEnt = tr.Hit,tr.Entity

	self.LastTrace = tr.HitPos
	
	if not Hit then
		return true
	else
		if Ent==HitEnt then
			return true
		else
			if not HitEnt.MelonTeam then return end
			if HitEnt.MelonTeam == self.MelonTeam then
				local Filter = Filter or {}
				table.insert(Filter,HitEnt)
				return self:LineOfSight(Vec,Ent,Team,Filter,X)
			else
				if HitEnt.MelonTeam and not Team then
					self.Target = HitEnt
				end
				return false
			end
		end
	end
	
	return false
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
	if not Singularity.Settings["MelonsDoDamage"] then self.Target = nil return end
	local Distance = self:GetPos():Distance(Ent:GetPos())
	if self:LineOfSight(EPos,Ent) and Distance<self.DNA.Range then
		if self.Times.Attack < CurTime() then
			Singularity.DealDamage(Ent,EPos,self.DNA.Damage,self,self)
			self.Times.Attack=CurTime()+self.DNA.AttackRate
			self:DrawAttack(self:GetPos(),self.LastTrace)
		end
	else
		if Distance>self.DNA.Range*2 then
			self.Target = nil
		end
	end
end

function ENT:ScanEnemys()
	if not Singularity.Settings["MelonsDoDamage"] then return end
	if self.Times.Scan < CurTime() then
		local entz = ents.FindInSphere(self:GetPos(),self.DNA.Range*2)
		for k, v in pairs(entz) do
			if v.MelonTeam and not v:IsPlayer() then
				if self.MelonTeam:CanAttack(v) then
					if self:LineOfSight(v:GetPos(),v) then
						self.Target = v
						break
					end
				end
			end
		end
		self.Times.Scan=CurTime()+0.2
	end
end

function IsDamaged(self)
	return Singularity.GetHealth( self ) < Singularity.GetMaxHealth( self ) 	
end

function ENT:Heal(Ent)
	local EPos = Ent:GetPos()
	if not Ent or not IsValid(Ent) then return end
	if not Singularity.Settings["MelonsDoDamage"] then self.Target = nil return end
	local Distance = self:GetPos():Distance(Ent:GetPos())
	if self:LineOfSight(EPos,Ent,true) and Distance<self.DNA.Range and IsDamaged(Ent) then
		if self.Times.Attack < CurTime() then
			Singularity.RepairHealth(Ent,self.DNA.Damage)
			self.Times.Attack=CurTime()+self.DNA.AttackRate
			self:DrawAttack(self:GetPos(),self.LastTrace)
		end
	else
		if Distance>self.DNA.Range*2 then
			self.Target = nil
		end
	end
end

function ENT:ScanInjured()
	if not Singularity.Settings["MelonsDoDamage"] then return end
	if self.Times.Scan < CurTime() then
		local entz = ents.FindInSphere(self:GetPos(),self.DNA.Range*4)
		for k, v in pairs(entz) do
			if v.MelonTeam and not v:IsPlayer() then
				if self.MelonTeam:CanHeal(v) and IsDamaged(v) then
					if self:LineOfSight(v:GetPos(),v,true) then
						self.Target = v
						break
					end
				end
			end
		end
		self.Times.Scan=CurTime()+0.2
	end
end
