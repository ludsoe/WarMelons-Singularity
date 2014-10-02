--[[----------------------------------------------------
Main Init -Loads all the final gameplay functions and sets the universe up.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

local MainF = "singularity/main/"

Singularity.LoadFile(MainF.."sh_teams.lua",1)
Singularity.LoadFile(MainF.."sh_players.lua",1)


function ShouldEntitiesCollide( ent1, ent2 )
	if ent1:IsWorld() or ent2:IsWorld() then return true end
	if ent1 == ent2 then return false end
	if not ent1.IsMelon == ent2.IsMelon then return true end
	if not ent1.IsMelon or not ent2.IsMelon then return true end
	if not ent1.SyncData or not ent2.SyncData then return true end
	if ent1.SyncData.Team or "1" == ent2.SyncData.Team or "2" then
		return false
	else
		return true
	end
	return true
end
hook.Add( "ShouldCollide", "MelonCollide", ShouldEntitiesCollide )