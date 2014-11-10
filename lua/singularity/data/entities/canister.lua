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
	self:EmitSound("npc/env_headcrabcanister/explosion.wav")
	
	self.FinishTraining = function(self,Train)
		
		local tr = util.TraceLine({start = self:LocalToWorld(Vector(-5,0,0)),endpos = self:LocalToWorld(Vector(-20,0,0)),filter = self} )

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
		
		return false
	end
	
end

Data.Name = "Canister"
Data.MyModel = "models/props_combine/headcrabcannister01a.mdl"
Data.MaxHealth = 3000
Data.IgnoreBuildMax = true

Data.MelonDNA={
	Range=400,
	Damage=200,
	AttackRate=0.2,
	AttackPosition=Vector(-60,0,0)
}

Data.ThinkSpeed = 0
Data.Think = function(self)
	self:ScanEnemys()
		
	if IsValid(self.Target) then
		self:Attack(self.Target)
	end	
	
	if not self.StoredMelons then self:Remove() return end
	if table.Count(self.StoredMelons)>0 and self.MelonTeam:CanMakeMelon(true) then
		if (self.MelonSpawn or 0) > CurTime() then return end
		local Name = self.StoredMelons[1]
		local Unit = Singularity.Entities.Modules["Melons"][Name]
		if Unit then
			if self:FinishTraining(Unit) then
				self:EmitSound("npc/dog/dog_pneumatic2.wav")
				table.remove(self.StoredMelons,1)
				self.MelonSpawn = CurTime()+0.5
			end
		else
			table.remove(self.StoredMelons,1)
		end
	elseif table.Count(self.StoredMelons)<=0 then
		Singularity.DealDamage(self,self:GetPos(),10,self,self)
	end
	
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )	
	self.SyncData["Loaded Melons"] = table.Count(self.StoredMelons)
end

Data.HelpType = "Hidden"

Singularity.Entities.MakeModule(Data)
