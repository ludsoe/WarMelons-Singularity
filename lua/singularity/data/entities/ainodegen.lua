local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.
local AI = Singularity.AI

local Data = {
	Type="Resources",
	Class="swm_base",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.Setup = function(self,Data,MyData)
	table.insert(AI.NodeFilter,self)
end

Data.OnUse = function(self,name,activator,caller)
	if self.Generated then return end
	
	local tr = AI.DoTrace(self:GetPos(),self:GetPos()+Vector(0,0,-10000))
	if tr.Hit then
		local Pos = tr.HitPos+Vector(0,0,20)
		AI.GenerateNavNodes(Pos)
	else
		return
	end
	
	self.Generated = true 
end

Data.Name = "AI Node Generator"
Data.MyModel = "models/props_combine/breenglobe.mdl"

Data.ThinkSpeed = 0
Data.Think = function(self)

end

Data.HelpType = "Hidden"

Singularity.Entities.MakeModule(Data)
