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
	
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	
	if IsValid(self.Target) then
		self:Attack(self.Target)
	end	
end

Singularity.Entities.MakeModule(Data)