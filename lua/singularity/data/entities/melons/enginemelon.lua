local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=150,
	Force=10000,
	TrainTime=10
}

Data.Name = "Engine Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 120

Data.ResourceCost = {}
Data.ResourceCost["Melonium"]=300

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
	
	self.IgnoreTrace = true
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()

	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
end

Singularity.Entities.MakeModule(Data)