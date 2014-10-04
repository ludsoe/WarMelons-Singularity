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
	Range=400,
	Damage=100,
	AttackRate=0.5
}

Data.Name = "Basic Sentry"
Data.MyModel = "models/Roller.mdl"
Data.MaxHealth = 500

Data.ThinkSpeed = 0
Data.Think = function(self)
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	self:ScanEnemys()
		
	if IsValid(self.Target) then
		self:Attack(self.Target)
	end	
end

Singularity.Entities.MakeModule(Data)
