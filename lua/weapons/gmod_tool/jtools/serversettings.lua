local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

local Tool = {}
Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
	local Mod = Singularity.MT.AddModular()
	Tab.Save = Tab.Save or {}
	local Settings = Singularity.Settings
	
	Singularity.MT.ModAddButton(Mod,"Reset to Default",function() 

	end)
	
	local Set,Text = "ManualMelonspawn","Manual Melon Spawns: "	
	Tab[Set] = Singularity.MT.ModAddButton(Mod,Text..tostring(Settings[Set]),function() 
		Settings[Set] = not Settings[Set]
		Tab[Set]:SetText(Text..tostring(Settings[Set]))
		Utl:SyncSetting(Set,Settings[Set])
	end)
	
	local Set,Text = "MelonsDoDamage","Melons Can Attack: "	
	Tab[Set] = Singularity.MT.ModAddButton(Mod,Text..tostring(Settings[Set]),function() 
		Settings[Set] = not Settings[Set]
		Tab[Set]:SetText(Text..tostring(Settings[Set]))
		Utl:SyncSetting(Set,Settings[Set])
	end)
	
end --This is clientside only, called when the tool is selected.

Singularity.MT.AddTool("Admin Settings",Tool)


















