local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=600,
	Force=1.2,
	Range=80,
	Damage=500,
	AttackRate=1,
	TrainTime=2
}

Data.Name = "Explosive Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 100
Data.Weight = 300

Data.ResourceCost = {}
Data.ResourceCost["Melonium"]=60

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()
	self:ScanEnemys()
	
	self.SyncData.HealthRaw = {H=Singularity.GetHealth( self ),M=Singularity.GetMaxHealth( self )}
	self.SyncData.Health = self.SyncData.HealthRaw.H.."/"..self.SyncData.HealthRaw.M
	
	if IsValid(self.Target) then
		if self:CanAttack(self.Target) then
		--self:Attack(self.Target)
			local Pos = self:GetPos()
			Singularity.WeaponFunc.BlastDamage(
			{
				Pos = Pos,
				ShockDamage	= self.DNA.Damage,
				ShockRadius	= self.DNA.Range,
				Ignore = self,
				Inflictor = self
			}
			)
			Singularity.KillEnt(self)
			local effectdata = EffectData()
				effectdata:SetOrigin(Pos)
				effectdata:SetStart(Pos)
			util.Effect( "explosion", effectdata )
		end
	end	
end

Singularity.Entities.MakeModule(Data)