AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:BSSetup(Data,ply,MyData)
	self:ClearOrders()
	
	local Team = self.MelonTeam or ply:GetMTeam()
	
	if MyData.IgnoreBuildMax then return end
	
	if Singularity.Settings["EnforceBuildingCap"] then
		if not Team:CanMakeBuilding() then
			self:Remove()
			return false
		end
	end
	
	Team:RegisterStructure(self)
end

function ENT:BSRemove()
	if self.MelonTeam then
		self.MelonTeam:DeRegisterStructure(self)
	end
end