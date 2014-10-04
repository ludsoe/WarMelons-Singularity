AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:BSSetup(Data,ply)
	self:ClearOrders()
	
	local Team = self.MelonTeam or ply:GetMTeam()
	
	if Singularity.Settings["EnforceBuildingCap"] then
		if not Team:CanMakeBuilding() then
			self:Remove()
			return false
		end
	end
	
	self.MelonTeam:RegisterStructure(self)
end
