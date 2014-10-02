local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.

if(SERVER)then
	Utl:HookNet("barracks_buildlist","",function(D,P)

	end)
else
	local VGUI = {}
	function VGUI:Init()
		
		local UnitList = Singularity.Entities.Modules["Melons"]
		
		local FactoryMenu = Singularity.MenuCore.CreateFrame({x=700,y=400},true,true,false,true)
		FactoryMenu:Center()
		FactoryMenu:SetTitle( "Item Materialiser" )
		FactoryMenu:MakePopup()
		
		local schematicBox = Singularity.MenuCore.CreateList(FactoryMenu,{x=150,y=160},{x=10,y=35},false)
		schematicBox:SetParent(FactoryMenu)
		schematicBox:AddColumn("Units") -- Add column
		
		local buildque = Singularity.MenuCore.CreateList(FactoryMenu,{x=150,y=160},{x=10,y=200},false)
		buildque:SetParent(FactoryMenu)
		buildque:AddColumn("Queue") 
				
		--Schematic Items--
		//schematicBox:AddLine("Basic Bomb")
		for k,v in pairs(UnitList) do
			schematicBox:AddLine(v.M.N)
		end
		------------------
		local ModelDisplay = Singularity.MenuCore.DisplayModel(FactoryMenu,180,{x=520,y=0},"models/maxofs2d/logo_gmod_b.mdl",80,10)
		
		local infoBox = vgui.Create( "DPanel", DermaFrame ) 
		infoBox:SetPos( 170, 35 )
		infoBox:SetSize( 350, 350)
		infoBox:SetParent(FactoryMenu)
		infoBox.Paint = function()    
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect( 0, 0, infoBox:GetWide(), infoBox:GetTall() )
			
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then 
			local selectedValue = schematicBox:GetSelected()[1]:GetValue(1) 
			local curselected = {}
			-- Get description data ----------------------
			for k,v in pairs(UnitList) do
				if(selectedValue==v.M.N)then
					curselected = v.M
					itemDesc=v.desc
					break
				end
			end
			if(curselected.M)then
				local View = curselected.CamDist or 20
				ModelDisplay:SetCamPos(Vector(View,View,View))
				ModelDisplay:SetModel(curselected.M)
				ModelDisplay:SetLookAt(Vector(0,0,4))
			end
			-- End description data calls ----------------
					
			--surface.SetFont( "default" )
			surface.SetTextColor( 255, 255, 255, 255 )
			posy = 10
				surface.SetTextPos( 15, posy )
				surface.DrawText(curselected.N)
				posy = posy + 10
				surface.SetTextPos( 15, posy )
				surface.DrawText("------------------")
				posy = posy + 20
				--[[for _, textLine in pairs (itemDesc) do
					surface.SetTextPos( 15, posy )
					surface.DrawText(textLine)
					posy = posy + 10
				end
				posy = posy + 20
				surface.SetTextPos( 15, posy )
				surface.DrawText("Required Resources:")
				posy = posy + 10
				for k, textLine in pairs (curselected.materials) do
					surface.SetTextPos( 15, posy )
					surface.DrawText(textLine..": ["..curselected.matamount[k].."]")
					posy = posy + 10
				end]]
			end	
			
			surface.SetTextColor( 255, 255, 255, 255 )
					
		end
		
		local cancelButton = Singularity.MenuCore.CreateButton(FactoryMenu,{x=180,y=60},{x=520,y=325})
		cancelButton:SetText( "Cancel" )
		cancelButton.DoClick = function ()
			FactoryMenu:Remove()
		end
		
		local okButton = Singularity.MenuCore.CreateButton(FactoryMenu,{x=180,y=40},{x=520,y=285})
		okButton:SetText( "Fabricate" )
		okButton.DoClick = function ()
			if schematicBox:GetSelected() and schematicBox:GetSelected()[1] then

				FactoryMenu:Remove()
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
		Console.Ent = D.E
	end)

end
