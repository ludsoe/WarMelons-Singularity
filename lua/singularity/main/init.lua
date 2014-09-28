--[[----------------------------------------------------
Main Init -Loads all the final gameplay functions and sets the universe up.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

local MainF = "singularity/main/"
local ScorF = "singularity/scoreboard/"

Singularity.LoadFile(ScorF.."init.lua",1)
Singularity.LoadFile(MainF.."pda.lua",1)
Singularity.LoadFile(MainF.."sh_teams.lua",1)
Singularity.LoadFile(MainF.."sh_players.lua",1)
