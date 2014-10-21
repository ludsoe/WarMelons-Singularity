local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=400,
	Force=1,
	Range=400,
	Damage=10,
	AttackRate=0.5,
	TrainTime=8,
	Capacity=150
}

Data.Name = "Mining Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 300
Data.Weight = 300

Data.ResourceCost = {}
Data.ResourceCost["Melonium"]=200

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
	self.MaxInventory = self.DNA.Capacity
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()

	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	
	local Txt,Total = "[ ",0
	for k,v in pairs(self.Inventory) do
		if v == 0 then
			self.Inventory[k]=nil
		else
			Txt=Txt..k..": "..v..", "
			Total=Total+v
		end
	end self.SyncData["Inventory:"]=Txt.."]"
	
	if Total<self.MaxInventory then
		if self.Target and IsValid(self.Target) and self.Target.IsMinable then
			local Mined = self:Mine(self.Target)
			
			for k,v in pairs(Mined or {}) do
				local Stored = self.Inventory[k] or 0
				self.Inventory[k]= Stored+v
			end
		else
			self:ScanMinables()	
		end
	else
		if self.Target and IsValid(self.Target) and not self.Target.IsMinable then
			self:ManageMovement(self.Target:LocalToWorld(Vector(0,0,30)),self.Target)
			if self:GetPos():Distance(self.Target:GetPos())<200 then
				self:DropOffResources(self.Target)
			end
		else
			self:ScanDropOff() 
		end
	end
end

Singularity.Entities.MakeModule(Data)