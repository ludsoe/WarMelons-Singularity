local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=150,
	Force=5000,
	TrainTime=10
}

Data.Name = "Lift Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 400

Data.Wire.Func = function(self,iname,value)
	if iname == "Hover Altitude" then
		self.HoverAlt = value
	end
end

Data.Wire.In = {ID={"Hover Altitude"}}

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
	
	self.IgnoreTrace = true
	
	self.HoverAlt = self:GetPos().z
	
	self:GetPhysicsObject():SetMass(200)
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()
	
	self:HoverAtAlt()
	
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
end

Singularity.Entities.MakeModule(Data)