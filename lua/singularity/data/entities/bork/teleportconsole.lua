local Singularity,SubSpaces = Singularity,SubSpaces
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

local Data = {
	Name="Teleport Console",
	Type="Generic",
	Class="sing_smod",
	MyModel="models/sbep_community/d12console.mdl",
	Wire = {},
	Extra = {}
}

Data.OnUse = function(self,name,activator,caller)
	--Opens up a interface to teleport between nearby shipspaces.
end

Singularity.ShipMods.MakeModule(Data)

if SERVER then
	function OpenShipConsole(Ply)
		--print("syncing "..Name.." subspace")
		local Data = {Name="open_shipconsole",Val=1,Dat={
			{N="DryDock",T="B",V=true}
		}}
		NDat.AddData(Data,Ply)
	end	
end
