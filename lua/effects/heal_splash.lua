function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local Ent	 	= data:GetEntity()
	if not Ent or not IsValid(Ent) then return end 	
	
	local emitter = ParticleEmitter( Pos )
	local clr=VectorRand() * 255
	for I=1, 3 do
		local pos = VectorRand() * 10
		local smoke = emitter:Add( "effects/bluespark", Pos + pos )
			smoke:SetVelocity( Vector(0,0,20) * math.Rand(1,5) )
			smoke:SetAirResistance( 50 )
			smoke:SetDieTime( math.Rand(1.8,2) )
			smoke:SetStartAlpha( 255 )
			smoke:SetEndAlpha( 25 )
			local clr = math.Rand(20,100)
			smoke:SetColor( Ent:GetColor() )
			smoke:SetStartSize( 8 )
			smoke:SetEndSize( 0 )
	end
	emitter:Finish()
end

function EFFECT:Think() return false end
function EFFECT:Render() end