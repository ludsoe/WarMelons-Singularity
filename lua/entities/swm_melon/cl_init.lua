include('shared.lua')

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan 

Utl:HookNet("MelonsSyncOrders","",function(D)
	if D.E and IsValid(D.E) then
		D.E.Orders = table.Merge(D.E.Orders or {},D.T)
	end
end)

Utl:HookNet("MelonsSyncOrderComplete","",function(D)
	if D.E and IsValid(D.E) then
		table.remove(D.E.Orders,1)
	end
end)

Utl:HookNet("MelonsClearOrders","",function(D)
	if D.E and IsValid(D.E) then
		D.E.Orders={}
	end
end)

function ENT:AmISelected()
	local Melon = GetSelectedMelons()[self:EntIndex()]
	if Melon and Melon.SyncData then
		
		if Melon.SyncData.Team == LocalPlayer():GetMTeam().name then
			return true
		else
			GetSelectedMelons()[self:EntIndex()]=nil
		end
	end
	return false
end

function ENT:DrawOrder(S,E)
	local effectdata = EffectData()
		effectdata:SetOrigin(S+Vector(0,0,5))
		effectdata:SetStart(E+Vector(0,0,5))
		effectdata:SetEntity(self)
	util.Effect( "order_display", effectdata )
end

function ENT:BSThink()	
	if self:AmISelected() then
		local RendPos = self:GetPos()
		for k, v in pairs(self.Orders) do
			self:DrawOrder(RendPos,v.V)
			RendPos=v.V
		end
	end
end
















