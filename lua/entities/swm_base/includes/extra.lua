local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan 

local function IsDamaged(self)
	return Singularity.GetHealth( self ) < Singularity.GetMaxHealth( self ) 	
end

local function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function ENT:TeamBaseWelds()
	local Ents = constraint.GetAllConstrainedEntities_B( self )
	
	for n, ent in pairs( Ents ) do
		if not ent.IsMelon then
			ent.MelonTeam = self.MelonTeam
			ent:SetColor(self.MelonTeam.color)
		end
	end
end

function ENT:LineOfSight(Vec,Ent,Team,Filter,X)
	if (X or 0) > 5 then return false else X=(X or 0)+1 end

	local MyPos = self.DNA.AttackPosition or self:GetPos()
	
	local tr = util.TraceLine({start = MyPos,endpos = Vec,filter = table.Merge({self},Filter or {})} )
	local Hit,HitEnt = tr.Hit,tr.Entity

	self.LastTrace = tr.HitPos
	
	if not Hit then
		return true
	else
		if Ent==HitEnt then
			return true
		else
			if not HitEnt.MelonTeam then return end
			local MyTeam = self.MelonTeam
			if MyTeam:CanHeal(HitEnt) then
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
	NDat.AddDataAll({
		Name="SingNetWorkEffect",
		Val=1,
		Dat={{N="N",T="S",V="attack_beam"},{N="Entity",T="E",V=self},{N="Origin",T="V",V=S+Vector(0,0,5)},{N="Start",T="V",V=E+Vector(0,0,0)}}
	})
end

function ENT:DrawHeal(S,E)
	self:DrawAttack(S,E)

	NDat.AddDataAll({
		Name="SingNetWorkEffect",
		Val=1,
		Dat={{N="N",T="S",V="heal_splash"},{N="Entity",T="E",V=self},{N="Start",T="V",V=E+Vector(0,0,5)}}
	})	
end

function ENT:CanAttack(Ent)
	local EPos = Ent:GetPos()
	local MyPos = self.DNA.AttackPosition or self:GetPos()
	local Distance = MyPos:Distance(EPos)
	local CanAttack = self.MelonTeam:CanAttack(Ent)
	if self:LineOfSight(EPos,Ent) and Distance<self.DNA.Range and CanAttack then
		return true
	end
	return false
end

function ENT:Attack(Ent)
	local EPos = Ent:GetPos()
	if not Ent or not IsValid(Ent) then return end
	if not Singularity.Settings["MelonsDoDamage"] then self.Target = nil return end
	local MyPos = self.DNA.AttackPosition or self:GetPos()
	local Distance = MyPos:Distance(EPos)
	local CanAttack = self.MelonTeam:CanAttack(Ent)
	local LOS = self:LineOfSight(EPos,Ent,true)
	if self:LineOfSight(EPos,Ent) and Distance<self.DNA.Range and CanAttack then
		if self.Times.Attack < CurTime() then
			Singularity.DealDamage(Ent,EPos,self.DNA.Damage,self,self)
			self.Times.Attack=CurTime()+self.DNA.AttackRate
			self:DrawAttack(MyPos,self.LastTrace)
			Ent.MelonTeam:MakeEnemy(self.MelonTeam) 
		end
	else
		if Distance>self.DNA.Range*2 or not CanAttack or not LOS then
			self.Target = nil
		end
	end
end

function ENT:Heal(Ent)
	local EPos = Ent:GetPos()
	if not Ent or not IsValid(Ent) then return end
	if not Singularity.Settings["MelonsDoDamage"] then self.Target = nil return end
	local MyPos = self.DNA.AttackPosition or self:GetPos()
	local Distance = MyPos:Distance(EPos)
	local CanHeal = self.MelonTeam:CanHeal(Ent)
	local IsDamaged = IsDamaged(Ent)
	local LOS = self:LineOfSight(EPos,Ent,true)
	if LOS and Distance<self.DNA.Range and IsDamaged and CanHeal and self:WaterLevel() < 2 then
		if self.Times.Attack < CurTime() then
			Singularity.RepairHealth(Ent,self.DNA.Damage)
			self.Times.Attack=CurTime()+self.DNA.AttackRate
			self:DrawHeal(MyPos,self.LastTrace)
		end
	else
		if Distance>self.DNA.Range*2 or not CanHeal or not IsDamaged or not LOS then
			self.Target = nil
		end
	end
end

function ENT:Mine(Ent)
	local EPos = Ent:LocalToWorld(Vector(0,0,5))
	if not Ent or not IsValid(Ent) then return end
	local MyPos = self.DNA.AttackPosition or self:GetPos()
	local Distance = MyPos:Distance(EPos)
	local LOS = self:LineOfSight(EPos,Ent)
	if LOS and Distance<self.DNA.Range then
		if self.Times.Attack < CurTime() then
			self.Times.Attack=CurTime()+self.DNA.AttackRate
			self:DrawAttack(MyPos,self.LastTrace)
			return Ent:Mine(self.DNA.Damage)
		end
	else
		if Distance>self.DNA.Range*2 or not LOS then
			self.Target = nil
		end
	end
end

function ENT:ScanEnemysV2(Range)
	if not Singularity.Settings["MelonsDoDamage"] then return end
	local entz = ents.FindInSphere(self:GetPos(),Range)
	local C = Range*2
	for k, v in pairs(entz) do
		if v.MelonTeam and not v:IsPlayer() then
			if not v.MelonTeam:IsHidden() and self.MelonTeam:CanAttack(v) then
				if self:LineOfSight(v:GetPos(),v) then
					local Dist = v:GetPos():Distance(self:GetPos())
					if Dist<C then
						C=Dist
						Closest = v
					end
				end
			end
		end
	end
	return Closest
end

function ENT:ScanEnemys()
	if not Singularity.Settings["MelonsDoDamage"] then return end
	if self.Times.Scan < CurTime() then
		local entz = ents.FindInSphere(self:GetPos(),self.DNA.Range*2)
		local C = 9999
		for k, v in pairs(entz) do
			if v.MelonTeam and not v:IsPlayer() then
				if not v.MelonTeam:IsHidden() and self.MelonTeam:CanAttack(v) then
					if self:LineOfSight(v:GetPos(),v) then
						local Dist = v:GetPos():Distance(self:GetPos())
						if Dist<C then
							C=Dist
							Closest = v
						end
					end
				end
			end
		end
		self.Target = Closest
		self.Times.Scan=CurTime()+0.2
	end
end

function ENT:ScanInjured()
	if not Singularity.Settings["MelonsDoDamage"] then return end
	if self.Times.Scan < CurTime() then
		local entz = ents.FindInSphere(self:GetPos(),self.DNA.Range*4)
		local C = 9999
		for k, v in pairs(entz) do
			if v.MelonTeam and not v:IsPlayer() then
				if self.MelonTeam:CanHeal(v) and IsDamaged(v) then
					if self:LineOfSight(v:GetPos(),v,true) then
					local Dist = v:GetPos():Distance(self:GetPos())
						if Dist<C then
							C=Dist
							Closest = v
						end
					end
				end
			end
		end
		self.Target = Closest
		self.Times.Scan=CurTime()+0.2
	end
end

function ENT:ScanMinables()
	if self.Times.Scan < CurTime() then
		local entz = ents.FindInSphere(self:GetPos(),self.DNA.Range*4)
		local C = 9999
		for k, v in pairs(entz) do
			if v.IsResource and v.IsMinable then
				if self:LineOfSight(v:LocalToWorld(Vector(0,0,5)),v) then
					local Dist = v:GetPos():Distance(self:GetPos())
					if Dist<C then
						C=Dist
						Closest = v
					end
				end
			end
		end
		self.Target = Closest
		self.Times.Scan=CurTime()+0.2
	end
end

function ENT:ScanDropOff()
	if self.Times.Scan < CurTime() then
		local entz = ents.FindInSphere(self:GetPos(),self.DNA.Range*4)
		local C = 9999
		for k, v in pairs(entz) do
			if self.MelonTeam:CanHeal(v) and v.IsStorageDepo then
				if self:LineOfSight(v:LocalToWorld(Vector(0,0,5)),v) then
					local Dist = v:GetPos():Distance(self:GetPos())
					if Dist<C then
						C=Dist
						Closest = v
					end
				end
			end
		end
		self.Target = Closest
		self.Times.Scan=CurTime()+0.2
	end
end

function ENT:DropOffResources(Ent)
	for k,v in pairs(self.Inventory) do
		self.MelonTeam:AddResource(k,v)
	end
	self.Inventory={}
	
	self:DrawAttack(self:GetPos(),Ent:GetPos())

	Ent:EmitSound("items/battery_pickup.wav")
end
