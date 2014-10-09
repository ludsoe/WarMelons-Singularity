function ENT:ZoneCheck(Pos,Size)  
    local XB, YB, ZB = Size * 0.8, Size * 0.8, Size * 0.8
    local Results = {}
    local Clear = true
    for k,e in pairs(ents.FindInSphere(Pos,Size)) do
		if(e.IsResource)then
			local EP = e:GetPos()
					   
			local EPL = WorldToLocal( EP, Angle(0,0,0), Pos, Angle(0,0,0))
			local X,Y,Z = EPL.x, EPL.y, EPL.z
					   
			if X <= XB and X >= -XB and Y <= YB and Y >= -YB and Z <= ZB and Z >= -ZB then
				Clear = false
				break
			end
		end
    end
    return Clear
end

function ENT:LeapTrace(Height,Pos)
	local n = math.Rand(0,360)
	local d = math.Rand(10,200)
	local SPos = self:LocalToWorld(Vector(0,0,80))
	if Pos then SPos = Pos end
	local trace = {}
	trace.start = SPos
	trace.endpos = SPos + (self:GetUp() * -math.Rand(-50,100)) + (self:GetRight() * (math.cos(n) * d)) + (self:GetForward() * (math.sin(n) * d))
	trace.filter = self.Seedlings

	local Tr = util.TraceLine( trace )
	return Tr
end

function ENT:LeapGrowth(O)
	local tr,tre = self:LeapTrace()
	local SpreadDist = 50--70
	if tr.Hit and tr.HitWorld then
		if not self:ZoneCheck(tr.HitPos,SpreadDist) then
			return false
		else
			return true,tr
		end
	else
		return false 
	end
end

function ENT:SpawnSelf(Pos,Ang)
	local Data = self.InitData
	local ent = ents.Create( Data.E )
	
	ent:SetModel( Data.M )
	ent:SetPos( Pos )
	ent:SetAngles( Ang )
	
	ent:Spawn() ent:Activate()
	ent:GetPhysicsObject():EnableMotion(false)
	ent:GetPhysicsObject():Sleep()
	
	ent.SourceParent = self
	
	ent:Compile(Data)
	
	return ent
end
