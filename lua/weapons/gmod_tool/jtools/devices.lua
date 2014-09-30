local PageData = Singularity.PageData

local ToolProps = {
	Basic = {
		Weld = {
			ID = "Weld?",
			Type = "Boolean",
			Value = true
		},
		NoCollide = {
			ID = "Nocollide?",
			Type = "Boolean",
			Value = true
		},
		Freeze = {
			ID = "Freeze?",
			Type = "Boolean",
			Value = true
		}
	}
}

local function MakePage(Base,Page,Tab)
	Tab[Page] = Tab[Page] or {}
	Tab[Page].Labels = Tab[Page].Labels or {}
	
	local Save = Tab.Save[Page] or ToolProps
	local Spawns = Singularity.Entities.Modules[Page] or {}
	
	local OnSelect = function(Data)
		if not Spawns[Data] then return end
		local Table=Spawns[Data].M
		Tab[Page].Models:SetModel(Table.M)
		Tab[Page].Name:SetText(Table.N)
		
		PageData.OnSelect(Base,Data,Table,Tab[Page].Labels)
		
		local EntT = Save[Table.N]
		EntT = {Entity=Table.Sets or {}} or EntT 
		Tab.PropGrid,Tab.Propertys=Singularity.MT.ModUpdSettings(Tab.PropGrid,table.Merge(Save,EntT),true)
		
		Tab.Server.Spawns = Table
		Tab[Page].Selected = Data
	end	
	
	Tab[Page].Models = Singularity.MenuCore.DisplayModel(Base,120,{x=170,y=0},"models/maxofs2d/logo_gmod_b.mdl",80,10)
	
	Tab[Page].Name = Singularity.MenuCore.CreateText(Base,{x=170,y=120},"Select a Entity!",Color(0,0,0,255))
	
	local List = Singularity.MenuCore.CreateList(Base,{x=150,y=325},{x=0,y=0},false,OnSelect)
	List:AddColumn("Selection") -- Add column

	for k,v in pairs(Spawns) do
		List:AddLine(k)
	end
	
	local Grid = Singularity.MenuCore.PropertyGrid(Base,{x=170,y=300},{x=330,y=0})
	Grid.IsPropGrid = true
	Tab.PropGrid = Grid
	
	Singularity.MT.ModUpdSettings(Grid,Save)

	if Tab[Page].Selected or "" ~= "" then OnSelect(Tab[Page].Selected) end
end

local Tool = {}
Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
	
	Tab.Save = Tab.Save or ToolProps
	
	local C,M,L = vgui.Create( "DPanel" ),vgui.Create( "DPanel" ),vgui.Create( "DPanel" )
	local Sheet = Singularity.MenuCore.CreatePSheet(Menu,{x=520,y=355},{x=0,y=0})
	Sheet:AddSheet( "Tactical" , C , "icon16/wrench.png" , false, false, "Base Defense and Offensive Weapons" )
	Sheet:AddSheet( "Strategic" , M , "icon16/shield.png" , false, false, "Unit Barracks and Resource Management" )
	Sheet:AddSheet( "Test" , L , "icon16/lightning.png" , false, false, "Test Page for spawning test shit" )

	MakePage(C,"Tactical",Tab)
	MakePage(M,"Strategic",Tab)
	MakePage(L,"Test",Tab)
end --This is clientside only, called when the tool is selected.

Tool.Primary = function(trace,ply,Settings)
	if not Settings.Spawns then return false end
	local traceent = trace.Entity
	local ent = Singularity.MT.CreateDevice(ply, trace, Settings.Spawns.E, Settings.Spawns.M)
	if ent.Compile then
		ent:Compile(Settings.Spawns,ply)
	end
	
	--PrintTable(Settings.Propertys)
	
	if not traceent:IsWorld() and not traceent:IsPlayer() then
		local WeldSet = Settings.Propertys.Weld
		local NocSet = Settings.Propertys.NoCollide
		
		if tobool(WeldSet.V) == true  then
			weld = constraint.Weld( ent, traceent, 0, trace.PhysicsBone, 0 )
		end
		if tobool(NocSet.V) == true then
			nocollide = constraint.NoCollide( ent, traceent, 0, trace.PhysicsBone )
		end
	end
	
	local phys = ent:GetPhysicsObject()
	local Freeze = Settings.Propertys.Freeze
	if tobool(Freeze.V) == true then
		phys:EnableMotion( false ) 
		ply:AddFrozenPhysicsObject( ent, phys )
	end
	return true
end --Serverside primary fire
Tool.Think = function(ply,Settings) end --Think Function use CLIENT and SERVER to create client and server only thinks.
Singularity.MT.AddTool("Device Systems",Tool)

