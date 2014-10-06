local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Type="Hidden",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}


local function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

Data.Setup = function(self,Data,MyData)
	self.StoredMelons = {}

	self.FinishTraining = function(self,Train)
		
		local tr = util.TraceLine({start = self:GetPos(),endpos = self:LocalToWorld(Vector(0,0,20)),filter = self} )

		if not tr.Hit and self.MelonTeam:CanMakeMelon(true) then
			local Data = Train.E
			local ent = ents.Create( Data.Class )
			
			ent:SetModel( Data.MyModel )
			ent:SetPos( self:LocalToWorld(Vector(-60,0,0)))
			ent:SetAngles( self:GetAngles() )
			
			ent:Spawn() ent:Activate()
			ent:GetPhysicsObject():Wake()
			
			ent.BarracksTrained = true
			
			ent:Compile(Train.M,nil,self.MelonTeam)
			
			Singularity.GivePlyProp(Singularity.GetPropOwner(self),ent)
			
			local angle1 = ent:GetPos() - self:GetPos()
			ent:GetPhysicsObject():ApplyForceCenter(Normalize(angle1)*2000)
			
			return true
		else
			return false
		end
	end
end

Data.Name = "Canister"
Data.MyModel = "models/props_combine/headcrabcannister01a.mdl"
Data.MaxHealth = 1000

Data.ThinkSpeed = 0
Data.Think = function(self)
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	
	if not self.StoredMelons then self:Remove() end
	
	if table.Count(self.StoredMelons)>0 then
		local Name = self.StoredMelons[1]
		local Unit = Singularity.Entities.Modules["Melons"][Name]
		if Unit then
			if self:FinishTraining(Unit) then
				table.remove(self.StoredMelons,1)
			end
		else
			table.remove(self.StoredMelons,1)
		end
	else
		self:Remove()
	end	
end

Singularity.Entities.MakeModule(Data)