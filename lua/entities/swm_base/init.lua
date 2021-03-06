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
	
	self.SyncData = {}
	self.OldData = {}
	
	self.Times = table.Copy(self.TimesTable)
	self.ModuleData = {}
	self.Singularity = {}
	self.InitData = {}
	self.OrderFuncs = {}
	
	self.Orders = {}
	self.SyncedOrders = {}
	self.DNA = {}
	self.Inventory = {}
end

function ENT:Compile(Data,ply,Team)
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
	
	if MyData.Weight then
		self:GetPhysicsObject():SetMass(MyData.Weight)
	end
	
	if ply and IsValid(ply) then
		self.MelonTeam = Team or ply:GetMTeam()
	else
		self.MelonTeam = Team or Singularity.Teams.UnOwned
	end
	
	
	if self.IsResource then
		self.MelonTeam = nil
	else
		self.SyncData.Team = self.MelonTeam.name
		self:SetColor(self.MelonTeam.color)
		Singularity.SetMaxHealth( self,MyData.MaxHealth )
	end
	
	if self.BSSetup then
		self:BSSetup(Data,ply,MyData)
	end
	
	--Lets setup our functions now.
	if MyData.Setup then MyData.Setup(self,Data,MyData) end
	
	self.ModuleRemove = MyData.OnRemove or function() end
	self.ModuleThink = MyData.Think or function() return true end
	self.ModuleUse = MyData.OnUse or function() end
	self.OnKilled = MyData.OnDeath or function() end
	self.OnBreakOff = MyData.OnBreakOff or function() end
	self.OnBuildDupeData = MyData.OnBuildDupeData or function() end
	self.OnEntityCopyFinish = MyData.OnEntityCopyFinish or function() end
		
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
	
	self:TransmitData()
	
	Singularity.MelonThink.RegisterThinker(self)--Stick ourselfs into the optimized think lists.
end

function ENT:OnRemove()
	if self.ModuleRemove then
		self:ModuleRemove()
	end
	
	if self.BSRemove then
		self:BSRemove()
	end
end

function ENT:SlowThink()
	if not self.ModuleThink then return end
	self:ModuleThink()
	
	if self.BSThink then self:BSThink() end
	if self.Times.Transmit < CurTime() then
		self.Times.Transmit=CurTime()+0.2
		self:TransmitData()
	end
	
	if not self.IsResource then
		if self.Times.Welds < CurTime() then
			self.Times.Welds = CurTime()+5
			self:TeamBaseWelds()
		end
		
		if self:WaterLevel() >= 2 then
			Singularity.DealDamage(self,self:GetPos(),10,self,self)
		end
	end
end

/*
function ENT:Think()

	
	self:NextThink(CurTime()+0.1)
	return true
end
*/

function ENT:AcceptInput(name,activator,caller)
	if self.ModuleUse then
		self:ModuleUse(name,activator,caller)
	end
end

AddCSLuaFile("includes/dupesupport.lua")
include("includes/extra.lua")
include("includes/networking.lua")
include("includes/orders.lua")
include("includes/movement.lua")
