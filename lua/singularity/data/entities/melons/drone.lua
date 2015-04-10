local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=800,
	Force=1.5,
	Range=200,
	Damage=40,
	AttackRate=1.5,
	TrainTime=5
}

Data.Name = "Drone Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 120
Data.Weight = 300

Data.ResourceCost = {}
Data.ResourceCost["Melonium"]=120

Data.Wire.Func = function(self,iname,value)
	if iname == "Hover Altitude" then
		self.HoverAltWire = value
	end
end

Data.Wire.In = {ID={"Hover Altitude"}}

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
	
	self.HoverAlt = self:GetPos().z
	self.HoverAltWire = 0
	
	self.OrderFuncs["Goto"]=function(self,Dat)
		self.HoverAlt = Dat.V.z
		return self:ManageMovement(Dat.V)
	end	
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()
	self:ScanEnemys()
	
	self:HoverAtAlt()
	
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	
	if IsValid(self.Target) then
		self:Attack(self.Target)
	end	
end

Singularity.Entities.MakeModule(Data)