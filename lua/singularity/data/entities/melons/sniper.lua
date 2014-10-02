local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=250,
	Force=400,
	Range=800,
	Damage=10,
	AttackRate=3,
	TrainTime=25
}

Data.Name = "Sniper Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 100

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()
	self:ScanEnemys()
	
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	
	if IsValid(self.Enemy) then
		self:Attack(self.Enemy)
	end	
end

Singularity.Entities.MakeModule(Data)