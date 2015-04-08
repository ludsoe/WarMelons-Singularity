local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local NukeSound = Sound( "ambient/explosions/explode_6.wav" )

local Data = {
	Type="Tactical",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}

function NuclearEffect(Pos)
	local effectdata = EffectData()
	effectdata:SetMagnitude( 0.2 )
	effectdata:SetOrigin( Pos )
					
	util.Effect( "nuke_explosion", effectdata )
	sound.Play( NukeSound, Pos, 180, math.random( 90, 120 ))
end

local OnHit = function(tr,data)
	NuclearEffect(tr.HitPos)
	
	local NewData = { 
		Pos 					=		tr.HitPos,							--Required--		--Position of the Explosion, World vector
		ShockDamage	=		3000,					--Optional--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		500,												--How far the Shockwave travels in a sphere
		Inflictor				=		data.Ignore,							--Required--		--The weapon or player that is dealing the damage
		Owner				=		data.Ignore					--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
	Singularity.WeaponFunc.BlastDamage(NewData)
end

local ReloadTime = 20
Data.Setup = function(self,Data,MyData)
	self.SuperWeapon = true
	
	self.WirePos = Vector(0,0,0)
	self.NextFire = CurTime()
	
	self.FireCost = {}
	self.FireCost["Melonium"]=2000
	self.FireCost["Metal"]=1000
	
	self.CanFire = function()
		for k,v in pairs(self.FireCost) do
			if not self.MelonTeam:CanUseResource(k,v) then
				return false
			end
		end
		
		return self.NextFire < CurTime()
	end
	
	self.FireCannon = function(self,Dat)
		local Vec = Dat.V
		if self:CanFire() then
		
			if self.FireCost then
				for k,v in pairs(self.FireCost) do
					self.MelonTeam:UseResource(k,v)
				end
			end
			
			self.NextFire = CurTime()+ReloadTime

			local MyData = {
				ShootPos = self:LocalToWorld(Vector(0,0,80)),
				Direction = self:GetUp(),
				ProjSpeed = 40,
				HomingPos = Vec,
				HomingSpeed = 20,
				Spread=5,
				Count=1,
				Model="models/props_trainstation/trashcan_indoor001a.mdl",
				Ignore = self,
				
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

Data.Name = "Big Boy Launcher"
Data.MyModel = "models/props_c17/fountain_01.mdl"
Data.MaxHealth = 2000

local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
Data.Wire.In = {ID={"AddToQueue","ClearQueue","Vector"},T={N,N,V}}
Data.Wire.Out = {ID={"Weapon Ready"}}

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

	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	self.SyncData["Weapon Ready"] = self:CanFire()
	
	local Ready = 0
	if self:CanFire() then Ready = 1 end
	WireLib.TriggerOutput( self, "Weapon Ready", Ready )
end

Data.HelpType = "Structures"

Data.HelpInfo = [[The Big Boy is a heavy artillery
weapon. And is designed to take out heavily armoured
bases or contraptions.
]]

Singularity.Entities.MakeModule(Data)
