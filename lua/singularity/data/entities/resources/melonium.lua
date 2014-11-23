local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Type="Resources",
	Class="swm_resource",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.Setup = function(self,Data,MyData)
	self.Seedlings = {self}
	self.Times.Grow = CurTime()
	self.Times.Recap = CurTime()
	
	local SkinRand = math.random(1,50)
	local Skin = 1
	if SkinRand < 25 then Skin = 0 end
	local Found,Scale = false,3
	if not self.SourceParent or not IsValid(self.SourceParent) then
		local entz = ents.FindInSphere(self:GetPos(),130)
		for k, v in pairs(entz) do
			if v.IsResource then
				if v.CenterPeice then
					self.SourceParent = v
					Found = true
					Scale = math.Clamp((200-v:GetPos():Distance(self:GetPos()))/100,0.3,2)+(math.random(-8,8)*0.01)
					Skin=v:GetSkin()
					break
				end
			end
		end
	else
		Scale = math.Clamp((200-self.SourceParent:GetPos():Distance(self:GetPos()))/100,0.3,2)+(math.random(-8,8)*0.01)
		Found = true
	end
	
	self:SetModelScale(Scale,0)
	self:SetAngles(self:LocalToWorldAngles(Angle(0,math.random(-180,180),0)))
	
	if not Found then
		self:SetSkin(Skin)
		if Skin == 1 then
			self:CreateGlow({10,10,150},500,6)
		else
			self:CreateGlow({10,150,10},500,6)
		end
		self.CenterPeice = true
	else
		self.IsMinable = true
		self.Resources["Melonium"]=math.Round(400*Scale)
	end
end

Data.Name = "Melonium Crystal"
Data.MyModel = "models/ce_ls3additional/tiberium/tiberium_normal.mdl"

Data.ThinkSpeed = 0
Data.Think = function(self)
	if self.CenterPeice then
		if self.Times.Grow < CurTime() then
			self.Times.Grow = CurTime()+10
			local X=0
			for I = 0, 30 do
			if table.Count(self.Seedlings)<20 then break end
			--while (table.Count(self.Seedlings)<20 or X>=20) do
				local Spawn,Tr = self:LeapGrowth()
				if Spawn then
					local Pos,Norm = Tr.HitPos,Tr.HitNormal
					if Pos:Distance(self:GetPos())>180 then return end
					local Seed = self:SpawnSelf(Pos+Norm,Norm:Angle()+Angle(90,0,0))
					table.insert(self.Seedlings,Seed)
					Seed.SourceParent = self
					Seed:SetSkin(self:GetSkin())
				end
				X=X+1
			end
		end
		
		if self.Times.Recap < CurTime() then
			self.Times.Recap = CurTime()+6
			for k,v in pairs(self.Seedlings) do
				if not v or not IsValid(v) then
					table.remove(self.Seedlings,k)
				end
			end
		end
	else
		if not self.SourceParent or not IsValid(self.SourceParent) then
			self:Remove()
		end
	end
end

Data.HelpType = "Resources"

Data.HelpInfo = [[Melonium is a crystaline resource
used in the cloning process of melons.
]]

Singularity.Entities.MakeModule(Data)
