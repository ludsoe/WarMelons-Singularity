--[[----------------------------------------------------
Singularity AutoRun -Starts up the whole mod.
----------------------------------------------------]]--
print("Singularity AutoRun Core Loading!")
local StartTime = SysTime()

Singularity = {} --Create our Global Table.
local Singularity = Singularity --Localise the global table for speed.
Singularity.Settings = Singularity.Settings or {} --Setup our settings table.
Singularity.SettingsName = "singularitysettings"
Singularity.SaveDataPath = "singularity/"
Singularity.Version = "InDev V:32"
Singularity.DebugMode = "Verbose" 
Singularity.EnableMenu = true --Debug Menu

include("singularity/load.lua")
if SERVER then AddCSLuaFile("singularity/load.lua") end
local LoadFile = Singularity.LoadFile --Lel Speed.
local CoreF,DataF,MainF = "singularity/core/","singularity/data/","singularity/main/"

--Shared
LoadFile("singularity/variables.lua",1)
LoadFile("singularity/menusys.lua",1)
LoadFile("singularity/debug.lua",1)
LoadFile(CoreF.."sh_utility.lua",1)
LoadFile(CoreF.."engine/sh_networking.lua",1)
LoadFile(CoreF.."engine/sh_constraints.lua",1)
LoadFile(CoreF.."sh_health_calc.lua",1)
LoadFile(CoreF.."sv_damage_core.lua",2)
LoadFile(CoreF.."damage/weapon_corefunc.lua",1)
LoadFile(DataF.."init.lua",1)
LoadFile(MainF.."init.lua",1)

if CLIENT then
	language.Add( "worldspawn", "World" )
	language.Add( "trigger_hurt", "Environment" )
else
	--[[hook.Add("GetGameDescription", "GameDesc", function() 
		return "Singularity: "..Singularity.Version
	end)]]
	resource.AddWorkshop( "324447523" ) --Ourself!
end

print("Singularity AutoRun Finished! Took "..(SysTime()-StartTime).."'s to load.")
