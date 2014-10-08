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
	Range=900,
	Damage=200,
	AttackRate=1
}

Data.Name = "Sniper Sentry"
Data.MyModel = "models/Roller.mdl"
Data.MaxHealth = 1000

Data.ThinkSpeed = 0
Data.Think = function(self)
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	self:ScanEnemys()
		
	if IsValid(self.Target) then
		self:Attack(self.Target)
	end	
end

Singularity.Entities.MakeModule(Data)
