local Singularity = Singularity --Localise the global table for speed.
local LoadFile = Singularity.LoadFile --Lel Speed.

Singularity.PreBuilt = {}

local PB = Singularity.PreBuilt

LoadFile("singularity/data/client.lua",0)
LoadFile("singularity/data/effectsys.lua",1)
--Add weapon loading here.
LoadFile("singularity/data/entityloader.lua",1)
LoadFile("singularity/data/ownership.lua",2)















