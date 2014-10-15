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
	self.Times.Regen = CurTime()

	if self.MetalOver then
		self:SetAngles(self.MetalOver.Angles)
		self:SetModel(self.MetalOver.Mod)
		self.Resources["Metal"]=self.MetalOver.Metal
		self.MaxMetal = self.MetalOver.Metal
	else
		self:SetAngles(self:LocalToWorldAngles(Angle(0,math.random(-180,180),0)))
		self:SetModel(table.Random(MyData.ScrapModels))
		local Metal = math.Round(math.random(5000,6000))
		self.Resources["Metal"] = Metal
		self.MaxMetal = Metal
	end
end

Data.Name = "Scrap Metal"
Data.MyModel = "models/props_vehicles/car004a.mdl"

Data.ThinkSpeed = 0
Data.Think = function(self)
	local RegenRate = 20
	if self.Times.Regen < CurTime() then
		self.Times.Regen = CurTime()+0.5
		if self.Resources["Metal"]+RegenRate < self.MaxMetal then
			self.Resources["Metal"] = self.Resources["Metal"]+RegenRate
		else
			self.Resources["Metal"] = self.MaxMetal
		end
	end
end

Singularity.Entities.MakeModule(Data)
