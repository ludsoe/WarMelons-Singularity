local Data = {
	Type="Strategic",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=150,
	Force=4,
	TrainTime=10
}

Data.Name = "Hover Engine"
Data.MyModel = "models/combine_helicopter/helicopter_bomb01.mdl"
Data.MaxHealth = 1200
Data.Weight = 1000

Data.ResourceCost = {}
Data.ResourceCost["Melonium"]=400


Data.Wire.Func = function(self,iname,value)
	if iname == "Hover Altitude" then
		self.HoverAlt = value
	end
end

Data.Wire.In = {ID={"Hover Altitude"}}

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
	
	self.IgnoreTrace = true
	self.MovementOrderable = true
	
	self.HoverAlt = self:GetPos().z
	
	self.OrderFuncs["Goto"]=function(self,Dat)
		return self:ManageMovement(Dat.V)
	end
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()
	
	self:HoverAtAlt()
	
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
end

Data.HelpType = "Structures"

Data.HelpInfo = [[Hover engines are structures
with the ability to generate force
and are capable of moving contraptions.

But Are Also capable of generating lift
and are generally used when making aircraft.
]]

Singularity.Entities.MakeModule(Data)