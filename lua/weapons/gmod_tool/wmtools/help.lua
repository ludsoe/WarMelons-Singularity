local PageData = Singularity.PageData
local Entities = Singularity.Entities

local function MakePage(Base,Page,Tab)
	Tab[Page] = Tab[Page] or {}
	Tab[Page].Labels = Tab[Page].Labels or {}
	
	local Spawns = Singularity.Entities.WMHelp[Page] or {}
	
	local OnSelect = function(Data)
		if not Spawns[Data] then return end
		local Table=Spawns[Data]
		Tab[Page].Models:SetModel(Table.M)
		Tab[Page].Name:SetText(Table.N)
		Tab[Page].Info:SetText(Table.I)
	end	
	
	Tab[Page].Models = Singularity.MenuCore.DisplayModel(Base,120,{x=170,y=0},"models/maxofs2d/logo_gmod_b.mdl",80,10)
	
	Tab[Page].Name = Singularity.MenuCore.CreateText(Base,{x=170,y=120},"Select a Topic!",Color(0,0,0,255))
	Tab[Page].Info = Singularity.MenuCore.CreateText(Base,{x=170,y=160},"",Color(0,0,0,255))
	
	local List = Singularity.MenuCore.CreateList(Base,{x=150,y=325},{x=0,y=0},false,OnSelect)
	List:AddColumn("Selection") -- Add column

	for k,v in pairs(Spawns) do
		List:AddLine(k)
	end

	if Tab[Page].Selected or "" ~= "" then OnSelect(Tab[Page].Selected) end
end

local Tool = {}
Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
	
	Tab.Save = Tab.Save or ToolProps
	
	local C,M,L,R,A = vgui.Create( "DPanel" ),vgui.Create( "DPanel" ),vgui.Create( "DPanel" ),vgui.Create( "DPanel" ),vgui.Create( "DPanel" )
	local Sheet = Singularity.MenuCore.CreatePSheet(Menu,{x=520,y=355},{x=0,y=0})
	Sheet:AddSheet( "Structures" , C , "icon16/building.png" , false, false, "Structure Type Units" )
	Sheet:AddSheet( "Melons" , M , "icon16/bullet_green.png" , false, false, "Melon Type Units" )
	Sheet:AddSheet( "Resources" , R , "icon16/bricks.png" , false, false, "Resource Type Entitys" )
	Sheet:AddSheet( "Advanced" , A , "icon16/font.png" , false, false, "Advanced Information" )
	Sheet:AddSheet( "Incomplete" , L , "icon16/book_error.png" , false, false, "Melon Type Units" )

	MakePage(C,"Structures",Tab)
	MakePage(M,"Melons",Tab)
	MakePage(L,"Incomplete",Tab)
	MakePage(A,"Advanced",Tab)
	MakePage(R,"Resources",Tab)
end --This is clientside only, called when the tool is selected.

Tool.Primary = function(trace,ply,Settings)
	local traceent = trace.Entity
	
	return true
end --Serverside primary fire

Tool.Think = function(ply,Settings) end --Think Function use CLIENT and SERVER to create client and server only thinks.
Singularity.MT.AddTool("Help Tool",Tool)

