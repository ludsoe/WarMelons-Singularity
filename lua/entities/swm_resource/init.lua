AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function WMRPhysgunPickup(ply,ent)
	if ent.IsResource or ent.NoPhysicsPickup then
		return false
	end
end
hook.Add("PhysgunPickup","WMRPhysgunPickup",WMRPhysgunPickup)

function ENT:BSSetup(Data,ply)
	self:CPPISetOwnerless(true)
end

function ENT:CreateGlow(color,distance,brightness)
	if not self.Glow or not IsValid(self.Glow) then
		local light = ents.Create( "light_dynamic" )
		if not light or not light:IsValid() then return end
		
		light:SetPos( self:GetPos() )
		light:SetParent(self)
		
		light:SetKeyValue("style", 0)
		light:SetKeyValue("_light", ("%d %d %d 255"):format( color[1], color[2], color[3] ))
		light:SetKeyValue("distance",distance)
		light:SetKeyValue("brightness",brightness)
		
		light.toggle = 1
		
		light:Spawn()
		
		self.Glow = light
	else
		self.Glow:SetKeyValue("_light", ("%d %d %d 255"):format( color[1], color[2], color[3] ))
		self.Glow:SetKeyValue("distance",distance)
		self.Glow:SetKeyValue("brightness",brightness)
	end
end

include("includes/spawning.lua")
