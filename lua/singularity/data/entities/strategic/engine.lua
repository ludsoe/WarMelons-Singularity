local Data = {
	Type="Strategic",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=150,
	Force=3,
	TrainTime=10
}

Data.Name = "Power Engine"
Data.MyModel = "models/combine_helicopter/helicopter_bomb01.mdl"
Data.MaxHealth = 1200
Data.Weight = 1200

Data.ResourceCost = {}
Data.ResourceCost["Melonium"]=300

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
	
	self.IgnoreTrace = true
	self.MovementOrderable = true
	
	self.OrderFuncs["Goto"]=function(self,Dat)
		return self:ManageMovement(Dat.V)
	end
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()

	self.SyncData.HealthRaw = {H=Singularity.GetHealth( self ),M=Singularity.GetMaxHealth( self )}
	self.SyncData.Health = self.SyncData.HealthRaw.H.."/"..self.SyncData.HealthRaw.M
end

Data.HelpType = "Structures"

Data.HelpInfo = [[Power engines are structures
with the ability to generate force
and are capable of moving contraptions.
]]

Singularity.Entities.MakeModule(Data)