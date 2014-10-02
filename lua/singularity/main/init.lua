--[[----------------------------------------------------
Main Init -Loads all the final gameplay functions and sets the universe up.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

local MainF = "singularity/main/"

Singularity.LoadFile(MainF.."sh_teams.lua",1)
Singularity.LoadFile(MainF.."sh_players.lua",1)