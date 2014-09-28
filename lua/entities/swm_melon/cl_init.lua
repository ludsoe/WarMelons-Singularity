include('shared.lua')

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan 

Utl:HookNet("MelonsSyncOrders","",function(D)
	D.E.Orders = table.Merge(D.E.Orders or {},D.T) 
end)

Utl:HookNet("MelonsSyncOrderComplete","",function(D)
	table.remove(D.E.Orders,1)
end)

Utl:HookNet("MelonsClearOrders","",function(D)
	D.E.Orders={}
end)

function ENT:AmISelected()
	if GetSelectedMelons()[self:EntIndex()] then
		return true
	else
		return false
	end
end

function ENT:DrawOrder(S,E)
	local effectdata = EffectData()
		effectdata:SetOrigin(S+Vector(0,0,5))
		effectdata:SetStart(E+Vector(0,0,5))
		effectdata:SetEntity(self)
	util.Effect( "order_display", effectdata )
end

function ENT:BSThink()	
	if self:AmISelected then
		local RendPos = self:GetPos()
		for k, v in pairs(self.Orders) do
			self:DrawOrder(RendPos,v.V)
			RendPos=v.V
		end
	end
end
















