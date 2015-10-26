include('shared.lua')

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan 

function ENT:Compile(T,N)
	if T == nil or N == nil then return end
	--Make a copy of the data pattern.
	local MyData = table.Copy(Singularity.Entities.Modules[T][N].E)
	self.ModuleData = MyData
	self.GetStatusInfo = MyData.WorldTip or self.GetStatusInfo
	self.ExtraData = MyData.WorldTip2 or self.ExtraData
	
	self.CThink = MyData.ClientThink or function() end
	self.ClientSide = true
end

function ENT:Think()
	if self.BSThink then self:BSThink() end
	if not self.ClientSide then
		self.ModType = self:GetNWString("Type","")
		self.ModName = self:GetNWString("Name","WarMelon")
		self.DisplayName = self:GetNWString("DName",self.ModName)
		if self.ModType~="" and self.ModName~="" then	
			self:Compile(self.ModType,self.ModName)
		end
	else
		if self.CThink then
			self.CThink(self,self.Core)
		end
	end
end

--[[
function ENT:BubbleFunc(Txt,Core,Trace,Pos)
	for n, v in pairs( self.BubbleData or {} ) do
		Txt=Txt.."\n"..n..": "..tostring(self:GetNWFloat(v))
	end
	return Txt
end

function ENT:WorldBubble(Trace,Pos)
	local txt = "[ "..(self.DisplayName or self.ModName).." ]"
	for n, v in pairs( self.SyncData or {} ) do
		txt=txt.."\n"..n..": "..tostring(v)
	end
	--Add Stuff Here related to what the ship Module Displays.
	return txt
end
]]

function ENT:AmISelected()
	local Melon = GetSelectedMelons()[self:EntIndex()]
	if Melon and Melon.SyncData then
		
		if Melon.SyncData.Team == LocalPlayer():GetMTeam().name then
			return true
		else
			GetSelectedMelons()[self:EntIndex()]=nil
		end
	end
	return false
end

function ENT:RenderOrder(S,E)
	local effectdata = EffectData()
		effectdata:SetOrigin(S+Vector(0,0,5))
		effectdata:SetStart(E+Vector(0,0,5))
		effectdata:SetEntity(self)
	util.Effect( "order_display", effectdata )
end

function ENT:DrawOrders()
	if self:AmISelected() then
		local RendPos = self:GetPos()
		if self.Orders then
			for k, v in pairs(self.Orders) do
				self:RenderOrder(RendPos,v.V)
				RendPos=v.V
			end
		end
	end
end

function ENT:GetBaseInfo(Info)	
	table.insert(Info,{Type="Label",Value=(self.DisplayName or self.ModName)})
	
	return true
end

function ENT:GetStatusInfo(Info) return false end
function ENT:ExtraData(Info) return false end 

function ENT:Draw( DrawModel )
	local TR = LocalPlayer():GetEyeTrace()
	if TR.Entity == self and EyePos():Distance( TR.HitPos ) < 512 then
		self.SyncData = self.SyncData or {}
		Singularity.MenuCore.RenderWorldTip(self,function(ent)
			local Info = {}
			
			self:GetBaseInfo(Info) 
			table.insert(Info,{Type="Label",Value=""})
			
			if self:GetStatusInfo(Info) then table.insert(Info,{Type="Label",Value=""}) end
			if self:ExtraData(Info) then table.insert(Info,{Type="Label",Value=""}) end
			
			self:FactionData(Info)
			
			return Info
		end)
	end
	
	if DrawModel then self:DrawModel() end
end

function ENT:FactionData(Info)
	local playername = self.SyncData.Team or ""
	if playername == "" then
		playername = "World"
	end
	
	table.insert(Info,{Type="Label",Value="(" .. playername ..")"})
end