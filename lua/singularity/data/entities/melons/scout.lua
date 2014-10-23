local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=800,
	Force=1.5,
	Range=150,
	Damage=25,
	AttackRate=0.5,
	TrainTime=2
}

Data.Name = "Swarm Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 80
Data.Weight = 300

Data.ResourceCost = {}
Data.ResourceCost["Melonium"]=20

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