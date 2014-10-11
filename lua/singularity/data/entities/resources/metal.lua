local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Type="Resources",
	Class="swm_resource",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.ScrapModels = {
	"models/props_vehicles/car004a.mdl",
	"models/props_vehicles/car001a_hatchback.mdl",
	"models/props_vehicles/car001b_hatchback.mdl",
	"models/props_vehicles/car002a.mdl",
	"models/props_vehicles/car002b.mdl",
	"models/props_vehicles/car003a.mdl",
	"models/props_vehicles/car003b.mdl",
	"models/props_vehicles/car004b.mdl",
	"models/props_vehicles/car005a.mdl",
	"models/props_vehicles/car005b.mdl"
}

Data.Setup = function(self,Data,MyData)
	self.IsMinable = true

	if self.MetalOver then
		self:SetAngles(self.MetalOver.Angles)
		self:SetModel(self.MetalOver.Mod)
		self.Resources["Metal"]=self.Metal
	else
		self:SetAngles(self:LocalToWorldAngles(Angle(0,math.random(-180,180),0)))
		self:SetModel(table.Random(MyData.ScrapModels))
		self.Resources["Metal"]=math.Round(math.random(5000,6000))
	end
end

Data.Name = "Scrap Metal"
Data.MyModel = "models/props_vehicles/car004a.mdl"

Data.ThinkSpeed = 0
Data.Think = function(self)

end

Singularity.Entities.MakeModule(Data)
