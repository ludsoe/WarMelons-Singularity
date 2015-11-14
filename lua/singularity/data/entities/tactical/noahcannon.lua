local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Type="Tactical",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}

local OnHit = function(tr,data)
	if not data.Ignore or not IsValid(data.Ignore) then
		local effectdata = EffectData()
			effectdata:SetOrigin(tr.HitPos)
			effectdata:SetStart(tr.HitPos)
		util.Effect( "explosion", effectdata )
		return 
	end --The cannon doesnt exist anymore
	local ent = ents.Create( "swm_ent" )
	
	ent:SetModel( "models/props_combine/headcrabcannister01a.mdl" )
	ent:SetPos( tr.HitPos )
	ent:SetAngles(tr.Normal:Angle())
		
	ent:Spawn() ent:Activate()
	if tr.Entity and not tr.HitWorld then
		local E = tr.Entity
		ent:SetParent(E)
	else
		ent:GetPhysicsObject():EnableMotion(false)
	end
	
	local Team = data.Ignore.MelonTeam
	
	Singularity.GivePlyProp(Singularity.GetPropOwner(data.Ignore),ent)
	ent:Compile(Singularity.Entities.Modules["Hidden"]["Canister"].M,nil,Team)
	ent.StoredMelons = data.Melons
	
	Team:RegisterProp(ent)
end

local ReloadTime = 5 --60
Data.Setup = function(self,Data,MyData)
	self.NoahCannon = true
	self.MelonLoadable = true
	
	self.StoredMelons = {}
	self.WirePos = Vector(0,0,0)
	self.NextFire = CurTime()
	
	self.CanFire = function()
		return self.NextFire < CurTime() and table.Count(self.StoredMelons)>0
	end
	
	self.CanEnter = function(Melon)
		return table.Count(self.StoredMelons) < 60
	end
	
	self.OnMEnter = function(Data)
		table.insert(self.StoredMelons,Data)
	end
	
	self.FireCannon = function(self,Dat)
		local Rnd = function() return math.random(-40,40) end
		local Vec = Dat.V+Vector(Rnd(),Rnd(),Rnd())
		if self:CanFire() then
			self.NextFire = CurTime()+ReloadTime
			
			local Batch,Rem = {},{}
			for n, v in pairs( self.StoredMelons ) do
				if table.Count(Batch)<20 then
					table.insert(Batch,v)
					self.StoredMelons[n]=nil
				else
					break
				end
			end

			local MyData = {
				ShootPos = self:LocalToWorld(Vector(0,0,80)),
				Direction = self:GetUp(),
				ProjSpeed = 40,
				HomingPos = Vec,
				HomingSpeed = 20,
				Spread=5,
				Count=1,
				Model="models/props_combine/headcrabcannister01a.mdl",
				Ignore = self,
				
				Melons=Batch,
				MelonTeam=self.MelonTeam,
				OnHit=OnHit,
				
				TrailTexture="trails/smoke.vmt",
				TrailStartW=30,
				TrailLifeTime=1,
				TrailColor=Color(255,255,255)
			}
			
			Singularity.WeaponFunc.FireProjectile(MyData)
			self:EmitSound("npc/env_headcrabcanister/launch.wav")
			return true
		end
		return false
	end
	
	self.OrderFuncs["Fire"]=function(self,Pos)
		return self:FireCannon(Pos)
	end
end

Data.Name = "Noah Cannon"
Data.MyModel = "models/props_combine/combinethumper002.mdl"
Data.MaxHealth = 2000

local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
Data.Wire.In = {ID={"AddToQueue","ClearQueue","Vector"},T={N,N,V}}
Data.Wire.Out = {ID={"Canister Ready","Loaded Melons"}}

Data.Wire.Func = function(self,iname,value)
	if iname == "AddToQueue" then
		if value > 0 and self.WirePos~=Vector(0,0,0) then
			self:AddOrder({T="Fire",V=self.WirePos})
		end
	elseif iname == "ClearQueue" then
		self:ClearOrders()
	elseif iname == "Vector" then
		self.WirePos = value
	end
end	
		
Data.ThinkSpeed = 0
Data.Think = function(self)
	self:RunOrders()

	self.SyncData.HealthRaw = {H=Singularity.GetHealth( self ),M=Singularity.GetMaxHealth( self )}
	self.SyncData.Health = self.SyncData.HealthRaw.H.."/"..self.SyncData.HealthRaw.M
	self.SyncData["Loaded Melons"] = table.Count(self.StoredMelons)
	self.SyncData["Canister Ready"] = self:CanFire()
	
	local Ready = 0
	if self:CanFire() then Ready = 1 end
	WireLib.TriggerOutput( self, "Canister Ready", Ready )
	WireLib.TriggerOutput( self, "Loaded Melons", table.Count(self.StoredMelons) )
end

Data.WorldTip2 = function(self,Info)
	table.insert(Info,{Type="Label",Value="Loaded Melons: "..tostring(self.SyncData["Loaded Melons"])})
	table.insert(Info,{Type="Label",Value="Weapon Ready: "..tostring(self.SyncData["Canister Ready"])})
	return true
end

Data.HelpType = "Structures"

Data.HelpInfo = [[The Noah Cannon is a strategic super weapon
capable of firing entire army's of melons across 
long distances. 

Just order the melons or a barracks onto the 
cannon and they will load into it. Then select
and order the cannon to fire it.
]]

Singularity.Entities.MakeModule(Data)
