include('shared.lua')

function ENT:BSThink()	
	self:DrawOrders()
end

function ENT:GetStatusInfo(Info)
	local V,M = self.SyncData.Health or "0/0"
	self.SyncData.HealthRaw = self.SyncData.HealthRaw or {}
	table.insert(Info,{Type="Percentage",Text="Health: "..V,Value=(self.SyncData.HealthRaw.H or 0)/(self.SyncData.HealthRaw.M or 1)})
	
	--table.insert(Info,{Type="Label",Value="Target: "..(self.SyncData["MyTarget"] or "None")})
	return true 
end
