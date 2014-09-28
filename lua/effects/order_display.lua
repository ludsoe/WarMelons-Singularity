/*---------------------------------------------------------
   Init( data table )
---------------------------------------------------------*/
function EFFECT:Init( data )
	self.StartPos 	= data:GetStart()	
	self.EndPos 	= data:GetOrigin()
	self.Col		= data:GetEntity():GetColor()
	
	self.Entity:SetRenderBoundsWS( self.StartPos, self.EndPos )
end

/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render( )

	render.SetMaterial( Material("trails/laser") )
	render.DrawBeam( self.StartPos, self.EndPos, 20, 1, 10,self.Col)		
	--render.DrawLine(Pos,EPos,Color(255,255,255,255),false)
	
end
