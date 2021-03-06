local Data = {
	Type="Resources",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.Name = "HeadQuarters"
Data.MyModel = "models/props_junk/TrashDumpster01a.mdl"
Data.MaxHealth = 3000

Data.Setup = function(self,Data,MyData)
	self.MelonTeam = Singularity.Teams.UnOwned
	self.SyncData.Team=self.MelonTeam.name
	self.SyncData["Can Capture"] = true
	self.IsCapturable = true
	self.DMGDontKill = true
	
	self.DeathFunc = function(self)
		self.MelonTeam = Singularity.Teams.UnOwned
		self.SyncData.Team=self.MelonTeam.name
		self.SyncData["Can Capture"] = true
		self.IsCapturable = true
		
		Singularity.SetHealth( self,MyData.MaxHealth )
		
		--Alert owner that they lost their HQ
	end
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self.SyncData.HealthRaw = {H=Singularity.GetHealth( self ),M=Singularity.GetMaxHealth( self )}
	self.SyncData.Health = self.SyncData.HealthRaw.H.."/"..self.SyncData.HealthRaw.M
end

Data.OnUse = function(self,name,activator,caller)
	if self.IsCapturable then
		self.MelonTeam = activator:GetMTeam()
		self.SyncData.Team=self.MelonTeam.name
		self.SyncData["Can Capture"] = false
		self.IsCapturable = false
	end
end

Data.HelpType = "Structures"

Data.HelpInfo = [[Headquarters are a special type of
structure that aren't destroyable through the means
of combat. They are captured and held by teams.
]]

Singularity.Entities.MakeModule(Data)