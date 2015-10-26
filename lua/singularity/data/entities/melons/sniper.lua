local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=150,
	Force=0.8,
	Range=800,
	Damage=100,
	AttackRate=5,
	TrainTime=10
}

Data.Name = "Sniper Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 100
Data.Weight = 300

Data.ResourceCost = {}
Data.ResourceCost["Melonium"]=150

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
		self:Attack(self.Target)
	end	
end

Singularity.Entities.MakeModule(Data)