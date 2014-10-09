AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function WMRPhysgunPickup(ply,ent)
	if ent.IsResource or ent.NoPhysicsPickup then
		return false
	end
end
hook.Add("PhysgunPickup","WMRPhysgunPickup",WMRPhysgunPickup)

function ENT:BSThink()
	if self.IsMinable then
		local Total = 0
		for k,v in pairs(self.Resources) do
			self.SyncData[k]=v
			Total=Total+v
		end
		if Total <= 0 then Singularity.KillEnt(self) return end
	end
end

function ENT:BSSetup(Data,ply)
	self:CPPISetOwnerless(true)
	self.Resources = {}
	self.IsMinable = false
end

function ENT:BSRemove()
	if self.Glow and IsValid(self.Glow) then
		self.Glow:Remove()
	end
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

function ENT:Mine(Amt)
	if not self.IsMinable then return end
	local Mined = {}
	for k,v in pairs(self.Resources) do
		if v >= Amt then
			Mined[k]=Amt 
			self.Resources[k]=v-Amt 
			Amt=0
		else
			Mined[k]=v 
			Amt=Amt-v 
			self.Resources[k]=0
		end
		if Amt <= 0 then break end
	end
	return Mined
end

include("includes/spawning.lua")
