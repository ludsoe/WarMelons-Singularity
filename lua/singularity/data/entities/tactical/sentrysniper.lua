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
	self.SyncData.HealthRaw = {H=Singularity.GetHealth( self ),M=Singularity.GetMaxHealth( self )}
	self.SyncData.Health = self.SyncData.HealthRaw.H.."/"..self.SyncData.HealthRaw.M
	self:ScanEnemys()
		
	if IsValid(self.Target) then
		self:Attack(self.Target)
	end	
end

Data.HelpType = "Structures"

Data.HelpInfo = [[The Sniper Sentry is a defensive unit
specialised towards dealing high damage
over long ranges. As such its great for
taking out strong units before they come
into range of your base.
]]

Singularity.Entities.MakeModule(Data)
