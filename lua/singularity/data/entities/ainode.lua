local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Type="Resources",
	Class="swm_base",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.Setup = function(self,Data,MyData)
	self.NodeData = {}
end

Data.OnUse = function(self,name,activator,caller)
	local MyData = Singularity.AI.Nodes[tostring(Singularity.AI.GetSector(self:GetPos()))][tostring(self:GetPos())]

	for k, v in pairs(MyData.C) do
		self:DrawAttack(self:GetPos(),v.P)
	end
end

Data.Name = "AI Node"
Data.MyModel = "models/Combine_Helicopter/helicopter_bomb01.mdl"

Data.ThinkSpeed = 0
Data.Think = function(self)
	
end

Data.HelpType = "Hidden"

Singularity.Entities.MakeModule(Data)
