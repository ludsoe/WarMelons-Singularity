-----------------------------------------------------------
---------------Jupiter Omni Tool Core----------------------
-----------------------------------------------------------

include("singularity/load.lua")
if SERVER then AddCSLuaFile("singularity/load.lua") end
local LoadFile = Singularity.LoadFile --Lel Speed.

LoadFile("singularity/data/entityloader.lua",1)

Singularity.PageData = Singularity.PageData or {}

LoadFile("weapons/gmod_tool/wm_gui_library.lua",1)
LoadFile("weapons/gmod_tool/wm_tool_funcs.lua",1)
LoadFile("weapons/gmod_tool/wmtooldata/infopopup.lua",1)

LoadFile("weapons/gmod_tool/wmtools/settings.lua",1)
LoadFile("weapons/gmod_tool/wmtools/orders.lua",1)
LoadFile("weapons/gmod_tool/wmtools/teammanage.lua",1)
LoadFile("weapons/gmod_tool/wmtools/devices.lua",1)
LoadFile("weapons/gmod_tool/wmtools/serversettings.lua",1)

if game.SinglePlayer() then
	LoadFile("weapons/gmod_tool/wmtools/localiser.lua",1)
end

--Load all the tools we want to display.
local Path = "weapons/gmod_tool/wmtools/addon/"
Files = file.Find(Path.."*.lua", "LUA")
for k, File in ipairs(Files) do
	Msg("Loading: "..File.."...\n")
	LoadFile(Path..File,1)
end

TOOL.Category = "Construction"
TOOL.Name = "MelonWars Omni Tool"
TOOL.Description = "MelonWars Omni Tool"

TOOL.AddToMenu = true -- Tell gmod not to add it. We will do it manually later!
TOOL.Command = nil

TOOL.ConfigName = ""

function TOOL:UpdateGhostEntity( ent, player,angle )
	if !ent or !ent:IsValid() then return end
	local trace = player:GetEyeTrace()
		
	ent:SetAngles( trace.HitNormal:Angle() + (angle or Angle(90,0,0)) )
	ent:SetPos( trace.HitPos - trace.HitNormal * ent:OBBMins().z )
	
	ent:SetNoDraw( false )
end

function TOOL:MakeGhost(model)
	if model then
		if not self.GhostEntity or not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != model then
			local trace = self:GetOwner():GetEyeTrace()
			self:MakeGhostEntity( Model(model), trace.HitPos, trace.HitNormal:Angle() )
		end
		self:UpdateGhostEntity( self.GhostEntity, self:GetOwner() )
	end
end

function TOOL:RemoveGhost()
	if IsValid(self.GhostEntity) then
		self.GhostEntity:Remove()
	end
end

if SERVER then
	local Selects = {}
	
	function TOOL:LeftClick( trace )
		local ply = self:GetOwner()
		if Selects[ply:Nick()] then 
			local Table = Selects[ply:Nick()]
			if Singularity.MT.Tools[Table.T] and Singularity.MT.Tools[Table.T].Primary then
				return Singularity.MT.Tools[Table.T].Primary(trace,ply,Table.S)
			end
		end
		return true
	end
	
	function TOOL:RightClick( trace )
		local ply = self:GetOwner()
		if Selects[ply:Nick()] then 
			local Table = Selects[ply:Nick()]
			if Singularity.MT.Tools[Table.T] and Singularity.MT.Tools[Table.T].Secondary then
				return Singularity.MT.Tools[Table.T].Secondary(trace,ply,Table.S)
			end
		end
		return true
	end
	
	function TOOL:Think()
		local ply = self:GetOwner()
		if Selects[ply:Nick()] then 
			local Table = Selects[ply:Nick()]
			local Tool = Singularity.MT.Tools[Table.T]
			
			if Tool and Tool.Think then
				Tool.Think(ply,Table.S)
			end
			
			if game.SinglePlayer() then
				if not Table then return end
				if Table.S.Spawns then
					self:MakeGhost(Table.S.Spawns.M)
				else
					self:RemoveGhost()
				end
			end	
		end	
	end
	
	util.AddNetworkString('Singularity_ToolHolster')
	function TOOL:Holster()
		local ply = self:GetOwner()
		if Selects[ply:Nick()] then 
			local Table = Selects[ply:Nick()]
			if Singularity.MT.Tools[Table.T] and Singularity.MT.Tools[Table.T].Holster then
				Singularity.MT.Tools[Table.T].Holster(ply,Table.S)
			end
			net.Start( "Singularity_ToolHolster" )
			net.Send( ply )
					
			if game.SinglePlayer() then
				self:RemoveGhost()
			end
		end			
	end

	util.AddNetworkString('Singularityr_ToolMenu')
	function TOOL:Reload()
		local ply = self:GetOwner()
		net.Start( "Singularityr_ToolMenu" )
		net.Send( ply )
	end
	
	util.AddNetworkString('Singularity_ToolSelect')
	net.Receive("Singularity_ToolSelect", function(length, client)
		local Mode,Settings = net.ReadString(),util.JSONToTable(net.ReadString())
		Selects[client:Nick()]={T=Mode,S=Settings}
				
		local Tool = Singularity.MT.Tools[Mode]
		if Tool and Tool.OnSync then
			Tool.OnSync(client,Settings)
		end
	end)
else	
	language.Add( "tool."..TOOL.Mode..".name", TOOL.Name )
	language.Add( "tool."..TOOL.Mode..".desc", TOOL.Description )
	language.Add( "tool."..TOOL.Mode..".0", "Reload: Open Menu" )
	
	function TOOL:Think()
		local ply = self:GetOwner()
		local Tool = Singularity.MT.SelectedTool
		if Tool ~= "" then
			local Table = Singularity.MT.SyncedSettings[Tool]

			if  Singularity.MT.Tools[Tool].Think then
				Singularity.MT.Tools[Tool].Think(ply,Table)
			end
				
			if not game.SinglePlayer() then
				if not Table then return end
				if Table.Server.Spawns then
					self:MakeGhost(Table.Server.Spawns.M)
				else
					self:RemoveGhost()
				end
			end
		end
	end
		
	function TOOL:Holster()
		if not game.SinglePlayer() then
			self:RemoveGhost()
		end
	end
	
	function HolsterTool(ply,Tool)
		local ply = LocalPlayer()
		local Tool = Tool or Singularity.MT.SelectedTool
		if Tool ~= "" and Singularity.MT.Tools[Tool].Holster then
			Singularity.MT.Tools[Tool].Holster(ply,Singularity.MT.SyncedSettings[Tool])
		end	
	end
	net.Receive("Singularity_ToolHolster", function() HolsterTool() end)
	
	net.Receive( "Singularityr_ToolMenu",Singularity.MT.OpenGui)
end