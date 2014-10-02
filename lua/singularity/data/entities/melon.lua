local Data = {
	Type="Test",
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
	AttackRate=1,
	MaxHealth=70
}

Data.Name = "Test Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"

Data.Setup = function(self,Data,MyData)
	self.MelonTeam = self.Ply:GetMTeam()
	self:SetColor(self.MelonTeam.color)
	self.SyncData.Team=self.MelonTeam.name
	
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