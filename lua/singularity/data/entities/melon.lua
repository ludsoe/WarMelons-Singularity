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
	Range=300,
	Damage=20,
	AttackRate=1
}

Data.Name = "Test Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"

Data.Setup = function(self,Data,MyData)
	self.MelonTeam = self.Ply:GetMTeam()
	self:SetColor(self.MelonTeam.color)
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:ManageMovement()
	self:ScanEnemys()
	
	if IsValid(self.Enemy) then
		self:Attack(self.Enemy)
	end
end

Singularity.Entities.MakeModule(Data)