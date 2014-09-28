AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetTrigger( true )
	self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
	
	local phy = self:GetPhysicsObject()
	if phy:IsValid() then phy:Wake() end
end

function ENT:Compile(Data,ply)
	--Tell the clientside what we are.
	if not Data.T or not Data.N then print("ZOMG ERROR NO DATA!!!") return end
		
	self:SetNWString("Type", Data.T)
	self:SetNWString("Name", Data.N)
	
	self.InitData = Data
	
	print("Compiling: "..Data.N.." from "..Data.T)
	
	--Make a copy of the data pattern.
	local MyData = table.Copy(Singularity.Entities.Modules[Data.T][Data.N].E)
	self.ModuleData = MyData
	
	self.DNA = MyData.MelonDNA
	self.Ply = ply
	
	--Lets setup our functions now.
	if MyData.Setup then MyData.Setup(self,Data,MyData) end
	
	self.ModuleInstall = MyData.Install or function() end
	self.ModuleUninstall = MyData.UnLink or function() end
	self.ModuleThink = MyData.Think or function() return true end
	self.ModuleUse = MyData.OnUse or function() end
	self.OnKilled = MyData.OnDeath or function() end
	self.OnBreakOff = MyData.OnBreakOff or function() end
	
	self.ThinkSpeed = MyData.ThinkSpeed or 1
	
	if MyData.Wire then
		if MyData.Wire.In then
			self.Inputs = WireLib.CreateSpecialInputs( self, MyData.Wire.In.ID, MyData.Wire.In.T or {} )
		end
		if MyData.Wire.Out then
			self.Outputs = WireLib.CreateSpecialOutputs( self, MyData.Wire.Out.ID , MyData.Wire.Out.T or {})	
		end
		self.TriggerInput = MyData.Wire.Func or function() end
	end
end

function ENT:Think()
	self:ModuleThink()
	
	if self.BSThink then self:BSThink() end
	if self.Times.Transmit < CurTime() then
		self.Times.Transmit=CurTime()+0.2
		self:TransmitData()
	end
	self:NextThink(CurTime()+0.1)
	return true
end

function ENT:AcceptInput(name,activator,caller)
	if self.ModuleUse then
		self:ModuleUse(name,activator,caller)
	end
end
	
function ENT:BuildDupeData()
	return self.InitData or {}
end

function ENT:OnRestore()
	if WireLib then WireLib.Restored(self) end
end

function ENT:PreEntityCopy()
	local Data = self:BuildDupeData()
	duplicator.StoreEntityModifier( self, "JupiterModule", Data )
	
    if WireLib then
		local DupeInfo = WireLib.BuildDupeInfo(self)
        if DupeInfo then
            duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
        end
    end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if Ent.EntityMods and Ent.EntityMods.JupiterModule then
		self:Compile(Ent.EntityMods.JupiterModule)
	end
	
    Ent.Owner = Player
    if WireLib and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
        WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
    end
end

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan 

util.AddNetworkString('SingEntDatSync')
function ENT:TransmitData()
	local Data = table.Copy(self.SyncData) --Create a copy of the sync data table so we dont mess with the real one.
	local Transmit = {}
	
	--{Name="example",Val=1,Dat={{N="D",T="S",V="example"}}}
	for n, v in pairs( self.OldData ) do --Update our existing data first.
		if v.V ~= Data[n] then --If Data doesnt match
			self.OldData[n] = {V=Data[n],C=true} --Set it to the new value and mark as changed.
			Transmit[n] = Data[n]
		else
			v.C = false --Mark It unchanged.
		end
		Data[n]=nil --Remove pre parsed data to make the next part faster.
	end
	
	for n, v in pairs( Data ) do --Lets mark down the new data.
		if not self.OldData[n] then
			self.OldData[n] = {V=v,C=true} --Tell the data its got to be sent.
			Transmit[n] = v
		end
	end
	
	if table.Count(Transmit)>=1 then
		NDat.AddDataAll({
			Name="SingEntDatSync",
			Val=1,
			Dat={{N="E",T="E",V=self},{N="T",T="T",V=Transmit}}
		})
	end
end

function ENT:TransmitAllData(Ply)
	local Transmit = {}
	
	if self.OldData == {} then return end
	
	for n, v in pairs( self.OldData ) do --Lets mark down the new data.
		Transmit[n] = v.V
	end
	
	local Send = {
		Name="SingEntDatSync",
		Val=1,
		Dat={{N="E",T="E",V=self},{N="T",T="T",V=Transmit}}
	}
	NDat.AddData(Send,Ply)
end
