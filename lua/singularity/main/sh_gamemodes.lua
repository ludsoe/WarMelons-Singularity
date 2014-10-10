local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

local Debug = function(MSG) Singularity.Debug(MSG,2,"JEGM") end
local Map = string.lower(game.GetMap()) --Get the map
local LoadFile = Singularity.LoadFile --Lel Speed.

Singularity.GameMode = Singularity.GameMode or {}

local GM = Singularity.GameMode

if SERVER then
	Debug("Loading Map Lua file.")
	LoadFile("singularity/main/maps/"..Map..".lua",2)
	if Singularity.Gamemode == "SandBox" then
		Debug("It appears a lua file wasnt found for the map.")
	end
end

function GM.SpawnEntity(Data)
	local ent = ents.Create( Data.E )
	
	ent:SetModel( Data.M )
	ent:SetPos( Data.P )
	ent:SetAngles( Data.A )
	
	ent:Spawn() ent:Activate()
	ent:GetPhysicsObject():EnableMotion(false)
	ent:GetPhysicsObject():Sleep()

	ent:Compile(Data)
	
	return ent
end
