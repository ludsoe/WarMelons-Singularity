local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

if(SERVER)then
	Utl:HookNet("barracks_buildlist","",function(D,P)

	end)
else
	local VGUI = {}
	
	function VGUI:SetupList(List,Items,Type)
		List:Clear()
		for k,v in pairs(Items) do
			if Type == 1 then
				List:AddLine(v.M.N)
			else
				List:AddLine(v)
			end
		end	
	end
	
	function VGUI:Init()
		local UnitList = Singularity.Entities.Modules["Melons"]
		
		local FactoryMenu = Singularity.MenuCore.CreateFrame({x=700,y=400},true,true,false,true)
		FactoryMenu:Center()
		FactoryMenu:SetTitle( "Item Materialiser" )
		FactoryMenu:MakePopup()
		
		local schematicBox = Singularity.MenuCore.CreateList(FactoryMenu,{x=150,y=160},{x=10,y=35},false)
		schematicBox:SetParent(FactoryMenu)
		schematicBox:AddColumn("Units") -- Add column
		
		self:SetupList(schematicBox,UnitList)	
			
		local buildque = Singularity.MenuCore.CreateList(FactoryMenu,{x=150,y=160},{x=10,y=200},false)
		buildque:SetParent(FactoryMenu)
		buildque:AddColumn("Queue") 

		------------------
		local ModelDisplay = Singularity.MenuCore.DisplayModel(FactoryMenu,180,{x=520,y=0},"models/maxofs2d/logo_gmod_b.mdl",80,10)
		
		local cancelButton = Singularity.MenuCore.CreateButton(FactoryMenu,{x=180,y=60},{x=520,y=325})
		cancelButton:SetText( "Finish" )
		cancelButton.DoClick = function ()
			--Send in build queue
			FactoryMenu:Remove()
		end
		
		local okButton = Singularity.MenuCore.CreateButton(FactoryMenu,{x=180,y=40},{x=520,y=285})
		okButton:SetText( "Select Melon" )
		okButton.DoClick = function ()
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then
				if self.SelectType == "Queue" then
					local Data = {Name="barracks_setup_queue",Val=1,Dat={
						{N="E",T="E",V=self.Ent},
						{N="T",T="T",V=self.BQue}
					}}
					NDat.AddData(Data)
				else
					
				end
			end
		end
		
	end
	vgui.Register( "BarracksMenu", VGUI )
	
	local Console = {}
	function OpenConsole()
		if Console and IsValid(Console.Base) then Console.Base:Remove() end
		Console.Base = Singularity.MenuCore.CreateFrame({x=700,y=500},true,true,false,true)
		Console.Base:Center()
		Console.Base:SetTitle( "Barracks" )
		Console.Base:MakePopup()
		
		Console.Sheet = Singularity.MenuCore.CreatePSheet(Console.Base,{x=700,y=475},{x=0,y=25})
	end	

	Utl:HookNet("open_barracks","",function(D)
		local Window = vgui.Create( "BarracksMenu")
		Window:SetMouseInputEnabled( true )
		Window:SetVisible( true )
		Window.Ent = D.E
		Window.BQue = D.E.BuildQueue or {}
	end)

end
