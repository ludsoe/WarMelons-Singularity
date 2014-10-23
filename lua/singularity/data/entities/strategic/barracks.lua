local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

local Data = {
	Type="Strategic",
	Class="swm_ent",
	Wire = {},
	Extra = {},
	Info = {}
}

Data.Name = "Barracks"
Data.MyModel = "models/props_lab/kennel_physics.mdl"
Data.MaxHealth = 1000

Data.Setup = function(self,Data,MyData)
	self.IsBarracks = true
	self.Training = {A=false,S=0,E=0,T=""}
	
	self.CanAfford = function(self,Data)
		if Singularity.Settings["MelonsReqResources"] then
			if Data.ResourceCost then
				for k,v in pairs(Data.ResourceCost) do
					if not self.MelonTeam:CanUseResource(k,v) then
						return false
					end
				end
			end
		end
		return true
	end
	
	self.FinishTraining = function(self,Train)
		
		local tr = util.TraceLine({start = self:GetPos(),endpos = self:LocalToWorld(Vector(0,0,20)),filter = self} )

		if not tr.Hit and self:CanAfford(Train.E) then	
			local Data = Train.E
			local ent = ents.Create( Data.Class )
			
			ent:SetModel( Data.MyModel )
			ent:SetPos( self:LocalToWorld(Vector(0,0,20)))
			ent:SetAngles( self:GetAngles() )
			
			ent:Spawn() ent:Activate()
			ent:GetPhysicsObject():Wake()
			
			ent.BarracksTrained = true
			
			ent:Compile(Train.M,nil,self.MelonTeam)
			
			Singularity.GivePlyProp(Singularity.GetPropOwner(self),ent)
			
			ent:SetOrders(self:GetOrders())
			
			if Singularity.Settings["MelonsReqResources"] then
				if Data.ResourceCost then
					for k,v in pairs(Data.ResourceCost) do
						self.MelonTeam:UseResource(k,v)
					end
				end
			end
			
			return true
		else
			return false
		end
	end
	
	self.ClearQueue = function(self)
		self.BuildQueue = {}
		self.Training{A=false,S=0,E=0,T=""}
	end
	
	self.AddToQueue = function(self,Name)
		if Singularity.Entities.Modules["Melons"][Name] then
			SendAdd(self,Name)
			self.BuildQueue = self.BuildQueue or {}
			table.insert(self.BuildQueue,Name)			
		end
	end
end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
	
	local Train = self.Training
	if not Train.A and self.BuildQueue then
		local Name = self.BuildQueue[1]
		if table.Count(self.BuildQueue)>0 then
			local Unit = Singularity.Entities.Modules["Melons"][Name]
			if Unit then
				if self:CanAfford(Unit.E) then
					Train.A = true
					Train.S=CurTime()
					Train.E=CurTime()+Unit.E.MelonDNA.TrainTime
					Train.T=Name
					Train.U=Unit
					SendTraining(self,Train)
				end
			else
				table.remove(self.BuildQueue,1)
				SendRemove(self)
			end
		end
	else
		if Train.E < CurTime() and Train.A and self.MelonTeam:CanMakeMelon(true) then
			if self:FinishTraining(Train.U) then
				Train.A = false
				SendRemove(self)
				if self.WillLoop then
					SendAdd(self,Train.T)
					table.insert(self.BuildQueue,Train.T)
				end
				table.remove(self.BuildQueue,1)
			end
		end
	end
end

Data.OnUse = function(self,name,activator,caller)
	BarracksMenu(activator,self)
end

Singularity.Entities.MakeModule(Data)

if SERVER then
	function BarracksMenu(Ply,self)
		local Data = {Name="open_barracks",Val=1,Dat={
			{N="E",T="E",V=self}
		}}
		NDat.AddData(Data,Ply)
	end
	
	function SendRemove(self)
		NDat.AddDataAll({Name="barracks_queue_remove",Val=1,Dat={
			{N="E",T="E",V=self}
		}})
	end
	
	function SendAdd(self,Name)
		NDat.AddDataAll({Name="barracks_queue_add",Val=1,Dat={
			{N="E",T="E",V=self},
			{N="S",T="S",V=Name},
		}})
	end
	
	function SendTraining(self,Train)
		NDat.AddDataAll({Name="barracks_start_training",Val=1,Dat={
			{N="E",T="E",V=self},
			{N="Sta",T="F",V=Train.S},
			{N="End",T="F",V=Train.E}
		}})		
	end
end