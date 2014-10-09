local Data = {
	Type="Melons",
	Class="swm_melon",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.MelonDNA={
	Speed=400,
	Force=600,
	Range=400,
	Damage=5,
	AttackRate=2,
	TrainTime=8
}

Data.Name = "Mining Melon"
Data.MyModel = "models/props_junk/watermelon01.mdl"
Data.MaxHealth = 300

Data.Setup = function(self,Data,MyData)
	self:SetMaterial("models/debug/debugwhite")
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()

	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	
	if self.Target and IsValid(self.Target) then
		local Mined = self:Mine(self.Target)
		
		for k,v in pairs(Mined or {}) do
			local Stored = self.Inventory[k] or 0
			self.Inventory[k]= Stored+v
		end
	else
		self:ScanMinables()	
	end
	
	local Txt = "[ "
	
	local X = false
	for k,v in pairs(self.Inventory) do
		if v == 0 then
			self.Inventory[k]=nil
		else
			Txt=Txt..k..": "..v.." "
			X = true
		end
	end
	
	Txt=Txt.."]"
	self.SyncData["Inventory"]=Txt
end

Singularity.Entities.MakeModule(Data)