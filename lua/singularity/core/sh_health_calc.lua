local Singularity = Singularity --MAH SPEED

function GetVolume(ent)

	local min = ent:OBBMins()
	local max = ent:OBBMaxs()
	local dif = max - min
	local volume = dif.x * dif.y * dif.z
	
	return volume
	
end

function Singularity.CalcHealth( ent )
	if not Singularity.CheckValid( ent ) then return 0 end
	ent.Singularity = ent.Singularity or {}
	
	local volume = GetVolume(ent)	
	local health = math.Round(((volume)^(0.515)))
	if not ent.Singularity.Health then 
		ent.Singularity.Health=health 
	end
	
	ent.Singularity.MaxHealth = ent.Singularity.MaxHealthOver or health
	return health
end

function Singularity.SetHealth( ent,health )
	if ent.InfHealth then return end

	ent.Singularity.Health = health
end

-- Returns the health of the entity without setting it
function Singularity.GetHealth( ent )
	if ent.InfHealth then return 99999999 end
	if not Singularity.CheckValid( ent ) then return 0 end
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return 0 end
	local Max = Singularity.GetMaxHealth(ent)
	
	if ent.Singularity and ent.Singularity.Health then
		if (ent.Singularity.Health > Max) then
			ent.Singularity.Health = Max
			return Max
		end
		return ent.Singularity.Health
	else
		return Max
	end
	return 0
end

-- Returns the maximum health of the entity without setting it
function Singularity.GetMaxHealth( ent )
	local Calc = ent.Singularity.MaxHealthOver or Singularity.CalcHealth(ent)
	if ent.Singularity and ent.Singularity.MaxHealth then 
		if Calc == ent.Singularity.MaxHealth then
			return ent.Singularity.MaxHealth 
		end
	end
	
	return Calc
end

function Singularity.SetMaxHealth( ent,number )
	ent.Singularity.MaxHealthOver = number
end
