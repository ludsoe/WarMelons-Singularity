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
	Range=600,
	Damage=80,
	AttackRate=0.4
}

Data.Name = "Basic Sentry"
Data.MyModel = "models/Roller.mdl"
Data.MaxHealth = 1000

Data.ThinkSpeed = 0
Data.Think = function(self)
	self.SyncData.HealthRaw = {H=Singularity.GetHealth( self ),M=Singularity.GetMaxHealth( self )}
	self.SyncData.Health = self.SyncData.HealthRaw.H.."/"..self.SyncData.HealthRaw.M
	self:ScanEnemys()
		
	if IsValid(self.Target) then
		self:Attack(self.Target)
	end	
end

Data.HelpType = "Structures"

Data.HelpInfo = [[The Basic Sentry is a defensive unit
thats highly effective at taking out swarms
of melons with its rapid fire high damage attacks.
]]

Singularity.Entities.MakeModule(Data)
