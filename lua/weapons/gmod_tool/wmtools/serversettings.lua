local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local GI = Singularity.MenuCore

local Tool = {}

function MelonCaps(Base,Tab)
	local Settings = Singularity.Settings

	local MyTab = Tab["Caps"] or {}
	Tab["Caps"] = MyTab
	MyTab.Base = Base
	
	local Caps = {
		PlayerTeamMelonCap="Player Team Melon Cap",
		PersistTeamMelonCap="Preset Team Melon Cap",
		PlayerTeamBuildingCap="Player Team Structure Cap",
		PersistTeamBuildingCap="Preset Team Structure Cap"
	}
	
	GI.CreateText(Base,{x=0,y=0},"Changes Only take effect after return is pressed while editing.(Enter Key)",Color(255,100,50,255))
	local I = 20
	for Set,Text in pairs(Caps) do
		GI.AdvTextInput(Base,{x=260,y=20},{x=0,y=I},Text,Settings[Set],function(V)
			Settings[Set]=V Utl:SyncSetting(Set,Settings[Set])
		end)
		
		I=I+20
	end
end

function MelonToggle(Base,Tab)
	local Settings = Singularity.Settings

	local MyTab = Tab["Toggle"] or {}
	Tab["Toggle"] = MyTab
	MyTab.Base = Base
	
	local Toggles = {
		ManualMelonspawn="Manual Melon Spawns: ",
		MelonsDoDamage="Melons Can Attack: ",
		EnforceBuildingCap="Structure Cap Enforcement: ",
		MelonsReqResources="Melons Require Resources: "
	}		
	
	local I = 0
	for Set,Text in pairs(Toggles) do
		Tab[Set] = GI.CreateButton(Base,{x=260,y=20},{x=0,y=I},Text..tostring(Settings[Set]),function() 
			Settings[Set] = not Settings[Set]
			Tab[Set]:SetText(Text..tostring(Settings[Set]))
			Utl:SyncSetting(Set,Settings[Set])
		end)
		
		I=I+20
	end
end

function MelonButtons(Base,Tab)
	local Settings = Singularity.Settings

	local MyTab = Tab["Buttons"] or {}
	Tab["Buttons"] = MyTab
	MyTab.Base = Base
	
	GI.CreateButton(Base,{x=260,y=20},{x=0,y=0},"Reset to Default",function()
		Utl.NetMan.AddData({Name="SingSettingsReset",Val=1,Dat={}})
	end)
	
	GI.CreateButton(Base,{x=260,y=20},{x=0,y=20},"CleanUp WarMelons",function()
		Utl.NetMan.AddData({Name="ClearAllMelons",Val=1,Dat={}})
	end)	
end

Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
	Tab.Save = Tab.Save or {}
	
	local Sheet = Singularity.MenuCore.CreatePSheet(Menu,{x=520,y=355},{x=0,y=0})
	local B,C,T = vgui.Create( "DPanel",Sheet),vgui.Create( "DPanel",Sheet),vgui.Create( "DPanel",Sheet )
	
	Sheet:AddSheet( "Server Buttons" , B , "icon16/eye.png" , false, false, "Hit Buttons that control things." )
	Sheet:AddSheet( "Server Caps" , C , "icon16/eye.png" , false, false, "Change the Melon And Structure Caps" )
	Sheet:AddSheet( "Server Toggle-ables" , T , "icon16/eye.png" , false, false, "Change The toggle-able settings." )

	MelonCaps(C,Tab)
	MelonToggle(T,Tab)
	MelonButtons(B,Tab)
end --This is clientside only, called when the tool is selected.

Singularity.MT.AddTool("Admin Settings",Tool)


















