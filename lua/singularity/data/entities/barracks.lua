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
Data.MaxHealth = 200

Data.Setup = function(self,Data,MyData) end

Data.ThinkSpeed = 0
Data.Think = function(self)
	self.SyncData.Health = Singularity.GetHealth( self ).."/"..Singularity.GetMaxHealth( self )
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
	
	Utl:HookNet("barracks_setup_queue","",function(D)
		if D.E and IsValid(D.E) then
			D.E.BuildQueue = D.T or {}
		end
	end)
end