--[[----------------------------------------------------
Main Init -Loads all the final gameplay functions and sets the universe up.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

local MainF = "singularity/main/"

Singularity.LoadFile(MainF.."sh_teams.lua",1)
Singularity.LoadFile(MainF.."sh_players.lua",1)

if SERVER then
	Utl:HookNet("SingSettingsSync","",function(D,ply)
		if not Utl:CheckAdmin( ply ) then return end
		if Singularity.Settings[D.T.N] == nil then return end
		Singularity.Settings[D.T.N]=D.T.V
		
		local N = Singularity.SettingNames[D.T.N]
		
		Utl:NotifyPlayers("WarMelons",ply:Nick().." has changed "..N.." to "..tostring(D.T.V),Color(30,150,255))
		Utl:SyncSettings()
	end)
	
	function Utl:ChangeSetting(Name,Value)
		if Singularity.Settings[Name] == nil then return end
		local Type = type(Singularity.Settings[Name])
		if Type == "boolean" then Value = tobool(Value) end
		if Type == "number" then Value = tonumber(Value) end
		Singularity.Settings[Name]=Value
		
		local N = Singularity.SettingNames[Name]
		
		Utl:NotifyPlayers("WarMelons","Console has changed "..N.." to "..tostring(Value),Color(30,150,255))
		Utl:SyncSettings()		
	end
	
	Utl:HookNet("SingSettingsReset","",function(D,ply)
		if not Utl:CheckAdmin( ply ) then return end
		Singularity.Settings=table.Copy(Singularity.DefaultSettings)
				
		Utl:NotifyPlayers("WarMelons",ply:Nick().." has reset the WarMelons Settings!",Color(30,150,255))
		Utl:SyncSettings()
	end)
else
	Utl:HookNet("SingSettingsSync","",function(D,ply)
		Singularity.Settings = D.T or {}
	end)
end