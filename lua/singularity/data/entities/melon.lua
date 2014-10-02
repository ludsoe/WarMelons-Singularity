local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=300,
	Force=400,
	Range=160,
	Damage=20,
	AttackRate=1
}

Data.Name = "Basic Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 40

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