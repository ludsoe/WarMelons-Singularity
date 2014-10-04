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
	Damage=5,
	AttackRate=0.2,
	TrainTime=6
}

Data.Name = "Medic Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 300

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()
	self:ScanInjured()
	
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	
	if IsValid(self.Target) then
		self:Heal(self.Target)
	end	
end

Singularity.Entities.MakeModule(Data)