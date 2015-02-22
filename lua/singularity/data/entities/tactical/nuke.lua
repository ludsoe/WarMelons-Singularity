local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Type="Tactical",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}

function NuclearEffect(Pos)
	local effectdata = EffectData()
	effectdata:SetMagnitude( 1 )
	effectdata:SetOrigin( Pos )
	effectdata:SetScale( 23000 )
					
	util.Effect( "nuke_explosion", effectdata )
				
	local ShakeIt = ents.Create( "env_shake" )
	ShakeIt:SetName("Shaker")
	ShakeIt:SetKeyValue("amplitude", "200" )
	ShakeIt:SetKeyValue("radius", "200" )
	ShakeIt:SetKeyValue("duration", "5" )
	ShakeIt:SetKeyValue("frequency", "255" )
	ShakeIt:SetPos( Pos )
	ShakeIt:Fire("StartShake", "", 0);
	ShakeIt:Spawn()
	ShakeIt:Activate()

	ShakeIt:Fire("kill", "", 6)
end

local OnHit = function(tr,data)
	NuclearEffect(tr.HitPos)
	PrintTable(data)
	data.Ignored:EmitSound("ambient/explosions/explode_6.wav")
	local NewData = { 
		Pos 					=		tr.HitPos,							--Required--		--Position of the Explosion, World vector
		ShockDamage	=		2000,					--Optional--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		500,												--How far the Shockwave travels in a sphere
		Ignore			=		data.Weapon,									--Optional--		--Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		data.Weapon,							--Required--		--The weapon or player that is dealing the damage
		Owner				=		data.Weapon					--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
	Singularity.WeaponFunc.BlastDamage(NewData)
end

local ReloadTime = 20 --60
Data.Setup = function(self,Data,MyData)
	self.SuperWeapon = true
	
	self.WirePos = Vector(0,0,0)
	self.NextFire = CurTime()
	
	self.CanFire = function()
		return self.NextFire < CurTime()
	end
	
	self.FireCannon = function(self,Dat)
		local Vec = Dat.V
		if self:CanFire() then
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
				Weapon = self,
				
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

Data.HelpInfo = [[
TODO
]]

Singularity.Entities.MakeModule(Data)
