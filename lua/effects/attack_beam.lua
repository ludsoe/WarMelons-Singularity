/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )
	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Ent	 	= data:GetEntity()
	self.Col		= self.Ent:GetColor()
	
	if not self.Ent:IsValid() then return false end
	
	self.Dir 		= self.EndPos - self.StartPos
	self.LocalStartPos   = self.Ent:WorldToLocal(self.StartPos)
	self.LocalEndPos = self.Ent:WorldToLocal(self.EndPos)
	
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
	
	self.DieTime = CurTime() + 0.1
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )

	if(not self or not self.DieTime)then return false end
	if ( CurTime() > self.DieTime ) then
		return false 
	end
	
	return true

end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )
	local Pos = self.StartPos
	local EPos = self.EndPos
	
	render.SetMaterial( Material("trails/laser") )
	render.DrawBeam( Pos, EPos, 60, 4, 40,self.Col)		
	--render.DrawLine(Pos,EPos,Color(255,255,255,255),false)
	
end
