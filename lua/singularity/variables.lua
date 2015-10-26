local Singularity = Singularity

Singularity.DefaultSettings = {}
local Ig = Singularity.DefaultSettings
Ig["PlayerTeamMelonCap"]=40
Ig["PersistTeamMelonCap"]=60
Ig["PlayerTeamBuildingCap"]=6
Ig["PersistTeamBuildingCap"]=8

Ig["EnforceBuildingCap"]=true
Ig["ManualMelonspawn"]=false
Ig["MelonsDoDamage"]=true
Ig["MelonsReqResources"]=false

Singularity.SettingNames = {}
local Ig = Singularity.SettingNames
Ig["PlayerTeamMelonCap"]="Player Team Melon Cap"
Ig["PersistTeamMelonCap"]="Preset Team Melon Cap"

Ig["PlayerTeamBuildingCap"]="Player Team Structure Cap"
Ig["PersistTeamBuildingCap"]="Preset Team Structure Cap"

Ig["EnforceBuildingCap"]="Melon Building Cap Enforcement"
Ig["ManualMelonspawn"]="Melon From Tool Spawning"
Ig["MelonsDoDamage"]="Melons Can Attack"
Ig["MelonsReqResources"]="Melons Require Resources"

if CLIENT then
	Singularity.GradientTex = surface.GetTextureID( "gui/center_gradient" )

	Singularity.GuiThemeColor = {
		BG = Color(50,50,50,150), --BackGround Color
		FG = Color(0,0,0,150), --ForeGround Color
		GC = Color(255, 255, 255, 15), --Gradient Color
		GHO = Color(0,40,150,10),--Gradient Hover Over Color
		Text = Color(0,220,60,200) --Text Color
	}
end
