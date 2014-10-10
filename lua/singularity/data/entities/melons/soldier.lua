local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=400,
	Force=600,
	Range=200,
	Damage=50,
	AttackRate=1,
	TrainTime=4
}

Data.Name = "Soldier Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 300

Data.ResourceCost = {}
Data.ResourceCost["Melonium"]=80

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