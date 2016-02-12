--[[----------------------------------------------------
Singularity AutoRun -Starts up the whole mod.
----------------------------------------------------]]--

local LineBar = "--------------------------------------------------------------------------------------"

print(LineBar.." \n".."		WarMelons AutoRun Core Loading!".." \n"..LineBar)
local StartTime = SysTime()

Singularity = Singularity or {} --Create our Global Table. (Or reuse it if it exists.... It happens...)
local Singularity = Singularity --Localise the global table for speed.
Singularity.Settings = Singularity.Settings or {} --Setup our settings table.
Singularity.SettingsName = "singularitysettings"
Singularity.SaveDataPath = "singularity/"
Singularity.Version = "Beta V:75.2"
Singularity.DebugMode = "Verbose" 
Singularity.EnableMenu = true --Debug Menu

include("singularity/load.lua")
if SERVER then AddCSLuaFile("singularity/load.lua") end
local LoadFile = Singularity.LoadFile --Lel Speed.
local CoreF,DataF,MainF = "singularity/core/","singularity/data/","singularity/main/"
		
print("Loading Debug Systems....")
local succ, err = pcall( function()
	LoadFile("singularity/variables.lua",1)
	--LoadFile("singularity/menusys.lua",1)
	LoadFile("singularity/sh_vguiease.lua",1)
	LoadFile("singularity/debug.lua",1)
end)

if succ then
	print("Loading Mod Systems.")
	local succ, err = pcall( function()
		
		print("Loading Utilities Lua.")
		LoadFile(CoreF.."sh_utility.lua",1)
		LoadFile(CoreF.."engine/sh_networking.lua",1)
		LoadFile(CoreF.."sh_ordersync.lua",1)
		LoadFile(CoreF.."engine/sh_constraints.lua",1)
		LoadFile(CoreF.."engine/sh_astar.lua",1)
		LoadFile(CoreF.."sh_health_calc.lua",1)
		LoadFile(CoreF.."sv_damage_core.lua",2)
		LoadFile(CoreF.."damage/weapon_corefunc.lua",1)
		LoadFile(DataF.."init.lua",1)
		LoadFile(MainF.."init.lua",1)

		if CLIENT then
			language.Add( "worldspawn", "World" )
			language.Add( "trigger_hurt", "Environment" )
		else
			resource.AddWorkshop( "324447523" ) --Ourself!
		end
	end)


	if succ then
		print(LineBar.." \n".."Warmelons AutoRun Finished! Took "..(SysTime()-StartTime).."'s to load.".." \n"..LineBar)
	else
		print(LineBar.." \n".."Warmelons AutoRun Errored! Mod not fully functional.".." \n".."Error: "..tostring(err).." \n"..LineBar)
		Singularity.Debug(tostring(err),1,"Lua Error")
	end
else
	print(LineBar.." \n".."Warmelons Debug Systems Errored! Mod not functional.".." \n".."Error: "..tostring(err).." \n"..LineBar)
end