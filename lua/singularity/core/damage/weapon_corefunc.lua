
local Singularity = Singularity --SPEED
Singularity.WeaponFunc = Singularity.WeaponFunc or {}
local WF = Singularity.WeaponFunc

function WF.BlastDamage(Data)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[	--Example of the Data table
	Data = { 
		Pos 					=		Vector(0,0,0),	--Required--		--Position of the Explosion, World vector
		ShrapDamage	=		50,					--Optional--		--Amount of Damage dealt by each Shrapnel that hits, if 0 or nil then other Shap vars are not required
		ShrapCount		=		20,											--Number of Shrapnel, 0 to not use Shrapnel
		ShrapDir			=		Vector(1,1,0),							--Direction of the Shrapnel, Direction vector, Example: Missile:GetForward()
		ShrapCone		=		45,											--Cone Angle the Shrapnel is randomly fired into, 0-180, 0 for all to be released directly forward, 180 to be released in a sphere
		ShrapRadius		=		200,											--How far the Shrapnel travels
		ShockDamage	=		200,					--Optional--		--Amount of Shockwave Damage, if 0 or nil then other Shock vars are not required
		ShockRadius		=		500,											--How far the Shockwave travels in a sphere
		Ignore				=		Entity,				--Optional--		--Entity that Shrapnel and Shockwaves ignore, Example: A missile entity so that Shrapnel doesn't hit it before it's removed
		Inflictor				=		Entity,				--Required--		--The weapon or player that is dealing the damage
		Owner				=		Player				--Required--		--The player that owns the weapon, or the Player if the Inflictor is a player
	}
]]--
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if type(Data.ShrapDamage) == "number" then
		--print("ShrapDamage was a number")
		if Data.ShrapDamage > 0 then
			--print("ShrapDamage is > 0")
			for i=1, Data.ShrapCount do
				local cone = Angle(math.random(-Data.ShrapCone,Data.ShrapCone),math.random(-Data.ShrapCone,Data.ShrapCone),0)
				local tr = {}
				tr.start = Data.Pos
				--[[print("Data.Pos="..type(Data.Pos))
				print("cone="..type(cone))
				print("Data.ShrapDir="..type(Data.ShrapDir))
				print("Rotate="..type(Data.ShrapDir:Rotate(cone)))
				print("Data.ShrapRadius="..type(Data.ShrapRadius))]]--
				Data.ShrapDir:Rotate(cone)
				tr.endpos = Data.Pos + Data.ShrapDir * Data.ShrapRadius
				if IsValid(Data.Ignore) then tr.filter = Data.Ignore end
				local trace = util.TraceLine( tr )
				local Hit = trace.Hit
				local HitWorld = trace.HitWorld
				--local HitPos = trace.HitPos
				local HitEnt = trace.Entity
				
				if Hit and not HitWorld and IsValid(HitEnt) then
					if Singularity.CheckValid(HitEnt) and not Singularity.IsImmune(HitEnt) then
						--LDE:DamageShields(HitEnt,Data.ShrapDamage,false)
						Singularity.DealDamage(HitEnt,trace.HitPos,Data.ShrapDamage,Data.Inflictor,Data.Inflictor)
					end
				end
			end
		end
	else
		--print("ShrapDamage wasn't a number")
	end
	if type(Data.ShockDamage) == "number" then
		--print("ShockDamage was a number")
		if Data.ShockDamage > 0 then
			--print("ShockDamage is > 0")
			local found = ents.FindInSphere(Data.Pos, Data.ShockRadius)
			local targets = {}
			for k, v in pairs(found) do
				local tr = {}
				tr.start = Data.Pos
				tr.endpos = v:GetPos()
				if v:IsPlayer() then tr.endpos = tr.endpos + Vector(0,0,30) end
				local skip = false
				if IsValid(Data.Ignore) then
					tr.filter = Data.Ignore
					if v == Data.Ignore then skip = true end
				end
				if not skip then
					local trace = util.TraceLine( tr )
					local Hit = trace.Hit
					local HitWorld = trace.HitWorld
					--local HitPos = trace.HitPos
					local HitEnt = trace.Entity
				
					if (Hit and not HitWorld and IsValid(HitEnt)) or not Hit then
						--LDE:DamageShields(HitEnt,Data.ShockDamage,false)
						if not Hit then	--We didn't hit anything because the prop isn't parented correctly or is oddly shaped, so attempt damage anyway
							if Singularity.CheckValid(v) and not Singularity.IsImmune(v) then
								targets[v:EntIndex()]={P=trace.HitPos,E=v}
							end
						else		--We hit something!  Save the target for damaging
							if Singularity.CheckValid(HitEnt) and not Singularity.IsImmune(HitEnt) then
								targets[v:EntIndex()]={P=trace.HitPos,E=HitEnt}
							end
						end
					end
				end
			end
			
			local count = table.Count(targets)
			local damage = math.floor((Data.ShockDamage / count) * (1+(0.1*(count-1))))	--10% Damage increase for each entity caught in the blast beyond the first
			for k, v in pairs(targets) do
				--LDE:DamageShields(v,damage,false)
				Singularity.DealDamage(v.E,v.P,damage,Data.Inflictor,Data.Inflictor)
				print("Dealing damage")
			end
		end
	else
		--print("ShockDamage wasn't a number")
	end
end


----------------------------------------------------------------------------------------------
--Projectile Handling------------------------------------------------------------------------
local Multiplier = 2								--How often we run, was 6 previously, 11 should run about 6 times a second
local ProjectileSkip = 1							--So we only run every 6 ticks
WF.Projectiles = WF.Projectiles or {}	--Where our projectiles are stored
local RemoveProj = {}							--Table of keys so we can cleanup our main table in a separate loop

--Projectile Function-----
function WF.FireProjectile(MyData)
	--[[EXAMPLE Data Table
		Data = {
			ShootPos 			=		Vector(0,0,0),								--Required--		--Position to start the Projectile, World Pos
			Direction			=		Vector(1,1,0),								--Required--		--Direction the weapon is pointing, World Direction not local
			ProjSpeed			=		150,												--Required--		--How fast the Projectile Travels
			HomingPos		=		Vector(0,0,0),								--Optional--		--Anything other than Vector(0,0,0) will make the bullet home on that World position
			HomingSpeed	=		10,												--Optional--		--Controls homing turn speed, 0 to 100
			Spread				=		5,													--Required--		--How much spread the weapon has, 0 to 100
			Drop					=		1,													--Optional--		--How much drop the bullet has when inside a planet --Disabled Temporarily--
			Count				=		1,													--Optional--		--How many projectiles to fire, default is 1
		
			Model				=		"models/Items/AR2_Grenade.mdl",	--Required--		--What model to use for the Projectile
			Ignore				=		Entity,											--Optional--		--Entity that the Projectile can't hit, useful for guns
		
			MuzzleFlash		=		1,													--Optional--		--The size of the muzzle flash, defaults to 1
			
			--Trail defaults to standard Machinegun Bullet if these options aren't used
			TrailColor			=		Color(255,255,150),						--Optional--		--Color of the bullet trail
			TrailStartW		=		10,												--Optional--		--How wide the trail starts as
			TrailEndW			=		0,													--Optional--		--How wide the trail ends as
			TrailLifeTime		=		0.4,												--Optional--		--How long the trail lasts
			TrailRes			=		1,													--Optional--		--You probably won't need this, affects trail texture resolution, default should be fine
			TrailTexture		=		"trails/laser.vmt"							--Optional--		--Texture to use for the trail
		
		And any other vars you're passing along for the OnHit function
		}
	]]--
	
	local Data = table.Copy(MyData)
	local MyReturn = {}
	MyReturn.Multi=false
	
	if type(Data.ShootPos) ~= "Vector" or type(Data.Direction) ~= "Vector" or type(Data.ProjSpeed) ~= "number" or type(Data.Spread) ~= "number" then
		print(type(Data.ShootPos)..type(Data.Direction)..type(Data.ProjSpeed)..type(Data.Spread))
		return MyReturn
	end
	if type(Data.Model) ~= "string" then
		print(type(Data.Model))
		return MyReturn
	end
	
	Data.Count = Data.Count or 1
	Data.Drop = Data.Drop or 0
	Data.Drag = Data.Drag or 0
	Data.HomingPos = Data.HomingPos or Vector(0,0,0)
	Data.HomingSpeed = Data.HomingSpeed or 0
	Data.MuzzleFlash = Data.MuzzleFlash or 1
	Data.TrailColor = Data.TrailColor or Color(255,255,150)
	Data.TrailStartW = Data.TrailStartW or 10
	Data.TrailEndW = Data.TrailEndW or 0
	Data.TrailLifeTime = Data.TrailLifeTime or 0.4
	Data.TrailRes = Data.TrailRes or 1/(Data.TrailStartW+Data.TrailEndW)*0.5
	Data.TrailTexture = Data.TrailTexture or "trails/laser.vmt"
	Data.HomeDelay = Data.HomeDelay or 0.2
	Data.OnHit = Data.OnHit or function() end
	
	for I=1, Data.Count do

		local BulletData = {}
		BulletData.Pos = Data.ShootPos
		if Data.Spread < 0 then Data.Spread = 0 elseif Data.Spread > 100 then Data.Spread = 100 end
		local spread = (Data.Spread / 100)*90
		local cone = Angle(math.Rand(-spread,spread),math.Rand(-spread,spread),math.Rand(-spread,spread))
		local dir = Vector(Data.Direction.X,Data.Direction.Y,Data.Direction.Z)

		dir:Rotate(cone)
		dir:Normalize()
		BulletData.Dir = dir*Data.ProjSpeed*Multiplier
		if IsValid(Data.Ignore) then BulletData.Ignore = Data.Ignore end
		--print(Data.ProjSpeed)
	
		BulletData.Projectile = ents.Create("je_bulletent")
		BulletData.Birth = CurTime()
		--BulletData.Projectile:SetRenderMode( RENDERMODE_GLOW )
		BulletData.Projectile:SetPos( BulletData.Pos )
		local angle = BulletData.Dir:Angle()
		BulletData.Projectile:SetAngles( angle )
		BulletData.Projectile:SetModel( Data.Model )
		local ID = BulletData.Projectile:EntIndex()
	
		local trail = util.SpriteTrail( BulletData.Projectile, 0,  Data.TrailColor, false, Data.TrailStartW, Data.TrailEndW, Data.TrailLifeTime, Data.TrailRes, Data.TrailTexture )
		--util.SpriteTrail( Entity entity, Integer AttachmentID, Color color, Boolean additive, Float Start Width, Float End Width, Float LifeTime, Float TextureRes, String Texture )

		BulletData.SkipMult = Multiplier
		BulletData.Skip = Multiplier
		BulletData.Drag = Data.Drag
		BulletData.Drop = Data.Drop
		BulletData.Data = Data
		--table.insert(LDE.Projectiles,BulletData)
		WF.Projectiles[ID] = BulletData
		
		if I == 1 and Data.Count == 1 then
			MyReturn = WF.Projectiles[ID]
		else
			MyReturn.Multi=true
			MyReturn.Bullets = MyReturn.Bullets or {}
			MyReturn.Bullets[I]=WF.Projectiles[ID]
		end
	
	end
	
	--Muzzle Flash :D
	local effectdata = EffectData()
	effectdata:SetOrigin( Data.ShootPos )
	local angle = Data.Direction:Angle()
	effectdata:SetAngles( angle )
	effectdata:SetScale( Data.MuzzleFlash )
	util.Effect( "MuzzleEffect", effectdata, true, true )
	
	return MyReturn
	--print("Projectile Created")
end


local function ProjectileThink()
	--We have something to cleanup, nil the tables
	local Cleanup = table.Count(RemoveProj)
	if Cleanup > 0 then																											
		for I, V in pairs(RemoveProj) do
			if IsValid(WF.Projectiles[I].Projectile) then
				WF.Projectiles[I].Projectile:Remove()
			end
			WF.Projectiles[I] = nil
			RemoveProj[I] = nil
		end
	end
	
	--First, see if we have any Projectiles to iterate
	local Count = table.Count(WF.Projectiles)
	if Count > 0 then
		--We have Projectiles, lets  move dem
		for I, V in pairs(WF.Projectiles) do
			if type(WF.Projectiles[I]) == "table" then
				local BulletData=WF.Projectiles[I]																			--Local table for speed boost
				
				if BulletData.Skip < BulletData.SkipMult then		--Skip this run
					BulletData.Skip = BulletData.Skip + 1
				else																	--Now we can calculate the projectile
					BulletData.Skip = 1
					
					--Homing
					if type(BulletData.Data.HomingPos) == "Vector" and type(BulletData.Data.HomingSpeed) == "number" then
						if BulletData.Data.HomingPos ~= Vector(0,0,0) and BulletData.Birth+BulletData.Data.HomeDelay < CurTime() then
							local speed = math.Clamp(BulletData.Data.HomingSpeed,0,100)*0.01
							local length = BulletData.Dir:Length()
							local aim = BulletData.Data.HomingPos - BulletData.Pos
							aim:Normalize()
							aim=aim*length
							BulletData.Dir = BulletData.Dir*(1-speed) + aim*speed
							BulletData.Dir:Normalize()
							BulletData.Dir = BulletData.Dir*length
						end
					end
					
					--Add Support for spacebuild maps!
					if type(BulletData.Drop) == "number" then BulletData.Dir=BulletData.Dir+Vector(0,0,-BulletData.Drop) end	--Add Drop to the next movement if applicable, will need Env checking
					if type(BulletData.Drag) == "number" then BulletData.Dir=BulletData.Dir-(BulletData.Dir*BulletData.Drag) end
				
					local tr = {}																											--Create a short trace along the flight path checking for hit and hitdata
						tr.start = BulletData.Pos
						tr.endpos = BulletData.Pos + BulletData.Dir
						if IsValid(BulletData.Ignore) then tr.filter = BulletData.Ignore end
					local Trace = util.TraceLine( tr )
					local Hit = Trace.Hit
					local HitWorld = Trace.HitWorld
					local HitPos = Trace.HitPos
					local HitEnt = Trace.Entity

					if not Hit and IsValid(BulletData.Projectile) then																										--Didn't hit anything, move the Projectile up
						BulletData.Pos=BulletData.Pos+BulletData.Dir

						WF.Projectiles[I] = BulletData
					else --Hit something, execute the attached function,move Projectile, mark for cleanup
						
						BulletData.Pos = HitPos
						local OnHit = BulletData.Data.OnHit
						local Succ,Error = pcall(OnHit,Trace,BulletData.Data)
						
						if not Succ then
							print("Error: "..Error)
						end
						
						WF.Projectiles[I] = BulletData
						RemoveProj[I] = 1

					end
				
					--Move the fake Projectile up
					if IsValid(BulletData.Projectile) then
						local angle = BulletData.Dir:Angle()
						BulletData.Projectile:SetPos(BulletData.Pos)
						BulletData.Projectile:SetAngles(angle)
					else
						RemoveProj[I] = 1
					end
				end
			end
		end
	end
end
hook.Add("Tick", "ProjectileThink", ProjectileThink)

