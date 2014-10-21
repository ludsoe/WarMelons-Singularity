local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Type="Strategic",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.Name = "Resource Depot"
Data.MyModel = "models/props_lab/teleplatform.mdl"
Data.MaxHealth = 2000

Data.Setup = function(self,Data,MyData)
	self.IsStorageDepo = true
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	
	if not self.MelonTeam then return end
	local Resources = self.MelonTeam:GetResources()
	local Txt="["
	for k,v in pairs(Resources) do
		Txt=Txt..k..": "..v..", "
	end
	self.SyncData["Inventory:"]=Txt.."]"
end

Singularity.Entities.MakeModule(Data)