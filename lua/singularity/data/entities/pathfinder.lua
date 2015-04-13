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
	self.Goal = ents.Create( "prop_physics" )
			
	self.Goal:SetModel( self:GetModel() )
	self.Goal:SetPos( self:LocalToWorld(Vector(0,0,100)))
	self.Goal:SetAngles( self:GetAngles() )

	self.Goal:Spawn() self.Goal:Activate()
	
	self.Path = {}
end

Data.OnUse = function(self,name,activator,caller)
	--print("MySector: "..tostring(Singularity.AI.GetSector(self:GetPos())))
	self.Path = Singularity.PathFinder.FindPath(self:GetPos(),self.Goal:GetPos())
	--PrintTable(self.Path)
end

Data.Name = "PathFinder"
Data.MyModel = "models/Combine_Helicopter/helicopter_bomb01.mdl"

Data.ThinkSpeed = 0.5
Data.Think = function(self)
	for x, n in pairs(self.Path) do
		self:DrawAttack(self.Path[x-1] or self:GetPos(),n)
	end
end

Data.HelpType = "Hidden"

Singularity.Entities.MakeModule(Data)
