local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
Singularity.Teams = Singularity.Teams or {}
local Teams = Singularity.Teams

Singularity.LoadFile("singularity/classes/team.lua",1)
Teams.Teams = {}

--General Functions
function Teams.CreateTeam(name,color) 
	print("Creating Team: "..name.." Color: "..tostring(color))
	local Team = {} Team = table.Copy(Teams.Class)
	
	Team:Setup(name,color)
	
	Teams.Teams[name]=Team
	return Team
end
