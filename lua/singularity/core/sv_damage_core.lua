local Singularity = Singularity --MAH SPEED

function Singularity.DealDamage(ent,position,amount,attacker,inflictor)
	if not ent or not ent:IsValid() then return end
	if not amount or amount==0 then print("Damage is nil") return end
	if ent.NoDamage or Singularity.IsImmune( ent ) then return end
	amount=math.floor(math.abs(amount))

	if ent.OnDamage then
		ent:OnDamage(ent,position,amount,attacker,inflictor)
	else
		Singularity.DamageHealth(ent,amount)
	end
end

local function random(Table)
	local R = table.Count(Table)
	local I = 1
	for id, chl in pairs( Table ) do
		if I==R then
			return chl
		end
		I=I+1
	end
end

local function RealDamage(ent,amount)
	local Health = Singularity.GetHealth( ent )
	if Health > amount then
		Singularity.SetHealth( ent,Health-amount )
	else
		--print("Prop is dead now!")
		Singularity.KillEnt(ent)
	end
end

function Singularity.DamageHealth(ent,amount,over)
	--Makesure its a valid run.
	if not Singularity.CheckValid( ent ) then print("Error ent is not valid!") return end

	local Children = ent:GetChildren()
	if table.Count(Children)>1 and not over then
		Singularity.DamageHealth(random(Children),amount,true)--Redirect the damage to some random child prop.
		RealDamage(ent,(amount*0.01))--Take a small amount of the damage to ourselfs.
	else
		RealDamage(ent,amount)--We got no children :( Take all the damage!
	end
end

function Singularity.RepairHealth(ent,amount)
	if not Singularity.CheckValid( ent ) then print("Error ent is not valid!") return end
	local Health,Max = Singularity.GetHealth( ent ),Singularity.GetMaxHealth( ent )
	if Health+amount < Max then
		Singularity.SetHealth( ent,Health+amount )
	else
		Singularity.SetHealth( ent,Max )
	end
end

--####	Kill A Destroyed Entity  ####--
function Singularity.KillEnt(ent,Over)
	if not ent or not ent:IsValid() or ent:IsPlayer() then
		if ent:IsPlayer() and ent:Alive() then ent:Kill() end
		return
	end
	
	if ent.Killed then return end  --Prevents a entity from being killed multiple times.
	ent.Killed = true
	
	local Children = ent:GetChildren()
	for id, chl in pairs( Children ) do
		Singularity.BreakOff(chl)
	end
	
	if ent.OnKilled then
		ent:OnKilled()
	end
	local effectdata = EffectData()
		effectdata:SetOrigin(ent:GetPos())
		effectdata:SetStart(ent:GetPos())
		util.Effect( "prop_death", effectdata )
		
	local Snd = "vehicles/v8/vehicle_impact_heavy" .. tostring( math.random( 1, 4 ) ) .. ".wav"
	
	if math.random(1,6)>3 then
		Snd = "vehicles/v8/vehicle_impact_medium" .. tostring( math.random( 1, 4 ) ) .. ".wav"
	end
	
	ent:EmitSound( Sound(Snd) )
	ent:Remove()
end

function Singularity.BreakOff(ent,mult)
	if not ent or not IsValid(ent) then
		return
	end
	
	if ent.Broke then return end --PLOX no loops
	ent.Broke = true
	
	if ent.OnBreakOff then
		ent:OnBreakOff()
	end
	
	ent:EmitSound( Sound( "weapons/stunstick/spark" .. tostring( math.random( 1, 3 ) ) .. ".wav" ) )
	
	if math.random(1,9)==3 then
		ent:Ignite(1000,100)--So only a fraction of the props burn.
	end
	ent:SetParent(nil) --Break the dead part off from the ship.
	constraint.RemoveAll( ent )
	ent:SetSolid( SOLID_VPHYSICS )
	ent:SetCollisionGroup(COLLISION_GROUP_PROJECTILE) 
	ent:DrawShadow( false )
	ent:Fire("enablemotion","",0)

	local delay = math.random(300, 800) / 100
	timer.Create("Kill "..ent:EntIndex(),delay+10,1,function() Singularity.KillEnt(ent,Over) end) --Kill the ent after some time has passed.
	local physobj = ent:GetPhysicsObject()
	if physobj:IsValid() then
		physobj:Wake()
		physobj:EnableMotion(true)
		local mass = physobj:GetMass()
		
		local rand = function() return math.random(-1,1) end
		Force = Vector(rand(),rand(),rand())

		physobj:ApplyForceCenter((Force*mass)*(mult or 10))				
	end
	
	local Children = ent:GetChildren()
	for id, chl in pairs( Children ) do
		Singularity.BreakOff(chl)
	end
end

function Singularity.IsImmune( entity )
	--[[local GV,Class = Singularity.GV,entity:GetClass()
	for id, cls in pairs( GV.ImmuneClasses ) do
		if Class == cls then
			return true
		end
	end]]
	return false
end

function Singularity.CheckValid( entity )
	if (not entity or not entity:IsValid()) then return false end
	if (entity:IsWorld()) then return false end
	if (not entity:GetPhysicsObject():IsValid()) then return false end
	if (not entity:GetPhysicsObject():GetVolume()) then return false end
	if (not entity:GetPhysicsObject():GetMass()) then return false end
	return true
end
