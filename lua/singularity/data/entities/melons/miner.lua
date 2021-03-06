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
	
	self.IsMiner = true
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()
	
	self.SyncData.HealthRaw = {H=Singularity.GetHealth( self ),M=Singularity.GetMaxHealth( self )}
	self.SyncData.Health = self.SyncData.HealthRaw.H.."/"..self.SyncData.HealthRaw.M
	
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

Data.ClientSetup = function(self)
	self.SyncData["Inventory:"] = "[]"
end

Data.WorldTip2 = function(self,Info)
	table.insert(Info,{Type="Label",Value="Inventory: "..self.SyncData["Inventory:"]})
end

--Tell garrys crappy duplicator to not copy the inventory.
Data.OnEntityCopyFinish = function(self,Data)
	Data.Inventory = {}
end

Data.HelpType = "Melons"

Data.HelpInfo = [[Mining melons are a utility type
melon capable of mining and hauling resources to
depots. They have no offensive capability.
]]

Singularity.Entities.MakeModule(Data)