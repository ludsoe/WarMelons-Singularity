local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Type="Tactical",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Range=500,
	Damage=10,
	AttackRate=0.2
}

Data.Name = "Medic Sentry"
Data.MyModel = "models/Roller.mdl"
Data.MaxHealth = 1000

Data.ThinkSpeed = 0
Data.Think = function(self)
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	self:ScanInjured()
		
	if IsValid(self.Target) then
		self:Heal(self.Target)
	end	
end

Singularity.Entities.MakeModule(Data)
