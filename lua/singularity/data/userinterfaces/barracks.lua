local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Singularity.Utl.NetMan --Ease link to the netdata table.
local Glob = {}

if(SERVER)then

else
	local VGUI = {}
	
	function VGUI:SetupList(List,Items,Type)
		if not List then return end
		List:Clear()
		if table.Count(Items or {})<=0 then return end
		for k,v in pairs(Items) do
			if Type == 1 then
				List:AddLine(v.M.N)
			else
				List:AddLine(v)
			end
		end	
	end
	
	function VGUI:SetupQueue(Items) self:SetupList(self.BQ,Items) end
	function VGUI:ToggleLoop(set)
		if not set==nil then
			self.WillLoop = set 
		else
			self.WillLoop = not self.WillLoop
		end
		self.Loop:SetText("Queue Loop: "..tostring(self.WillLoop))
	end
	
	function VGUI:Init()
		local UnitList = Singularity.Entities.Modules["Melons"]
		
		local FactoryMenu = Singularity.MenuCore.CreateFrame({x=700,y=400},true,true,false,true)
		FactoryMenu:Center()
		FactoryMenu:SetTitle( "Melon Barracks" )
		FactoryMenu:MakePopup()
		
		self.Selected = ""
		self.WillLoop = false
		
		local schematicBox = Singularity.MenuCore.CreateList(FactoryMenu,{x=150,y=160},{x=10,y=35},false,function(V)
			if V then
				self.Selected = V
				self.SelectType = "Build"
				self.ADD:SetText( "Add: "..V )
			end
		end)
		schematicBox:SetParent(FactoryMenu)
		schematicBox:AddColumn("Units") -- Add column
		
		self:SetupList(schematicBox,UnitList,1)	
			
		local buildque = Singularity.MenuCore.CreateList(FactoryMenu,{x=150,y=160},{x=10,y=200},false,function(V)
			if V then
				self.Selected = V
				self.SelectType = "Queue"
				self.ADD:SetText( "Add: "..V )
			end
		end)
		buildque:SetParent(FactoryMenu)
		buildque:AddColumn("Queue") 
		
		self.BQ = buildque
		
		------------------
		local ModelDisplay = Singularity.MenuCore.DisplayModel(FactoryMenu,180,{x=520,y=0},"models/maxofs2d/logo_gmod_b.mdl",80,10)
		
		local finish = Singularity.MenuCore.CreateButton(FactoryMenu,{x=180,y=60},{x=520,y=325})
		finish:SetText( "Finish" )
		finish.DoClick = function ()
			if table.Count(self.BQue or {}) > 0 then
				local Data = {Name="barracks_setup_queue",Val=1,Dat={
					{N="E",T="E",V=self.Ent},
					{N="T",T="T",V=self.BQue or {}},
					{N="B",T="B",V=self.WillLoop}
				}}
				NDat.AddData(Data)
			end
			
			FactoryMenu:Remove()
			Glob.Window = nil
		end
		
		local Punc = function()
			local Ent = self.Ent
			if not Ent then return 0 end
			local S,E=Ent.TrainS or 0,Ent.TrainE or 0
			return (S-CurTime())/(S-E)
		end
		Singularity.MenuCore.CreatePBar(FactoryMenu,{x=150,y=20},{x=10,y=365},Punc)
		
		self.ADD = Singularity.MenuCore.CreateButton(FactoryMenu,{x=180,y=40},{x=520,y=185})
		self.ADD:SetText( "Select Melon" )
		self.ADD.DoClick = function ()
			if self.Selected and self.Selected ~= "" then
				table.insert(self.BQue,self.Selected)
				self:SetupList(buildque,self.BQue)
			end
		end

		local Clear = Singularity.MenuCore.CreateButton(FactoryMenu,{x=180,y=40},{x=520,y=230})
		Clear:SetText( "Clear List" )
		Clear.DoClick = function ()
			self.BQue = {}
			self:SetupList(buildque,self.BQue)
		end
		
		self.Loop = Singularity.MenuCore.CreateButton(FactoryMenu,{x=180,y=40},{x=520,y=275})
		self.Loop:SetText( "Queue Loop: "..tostring(self.WillLoop) )
		self.Loop.DoClick = function()
			self:ToggleLoop(not self.WillLoop)
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
		
		local Ent = D.E
		Window.Ent = Ent
		Window.BQue = Ent.BuildQueue or {}
		
		Window:ToggleLoop(Ent.WillLoop)
		Window:SetupQueue(D.E.BuildQueue)
		
		Glob.Window = Window
	end)

end

Utl:HookNet("barracks_setup_queue","",function(D,P)
	local Ent = D.E

	if Ent and IsValid(Ent) then
		Ent.BuildQueue = D.T
		Ent.WillLoop = D.B
		
		if SERVER then		
			NDat.AddDataAll({Name="barracks_setup_queue",Val=1,Dat={
				{N="E",T="E",V=Ent},
				{N="T",T="T",V=D.T or {}},
				{N="B",T="B",V=D.B}
			}})
		else
			local Window = Glob.Window
			if Window and IsValid(Window) and Window.Ent == Ent then
				Window:ToggleLoop(D.B)
				Window:SetupQueue(D.T)
			end
		end
	end
end)

Utl:HookNet("barracks_queue_add","",function(D,P)
	local Ent = D.E
	
	if not Ent.BuildQueue then return end

	if Ent and IsValid(Ent) then
		table.insert(Ent.BuildQueue,D.S)
	end
	
	local Window = Glob.Window
	if Window and IsValid(Window) and Window.Ent == Ent then
		Window:SetupQueue(Ent.BuildQueue)
	end
end)

Utl:HookNet("barracks_queue_remove","",function(D,P)
	local Ent = D.E
	
	if not Ent.BuildQueue then return end
	
	if Ent and IsValid(Ent) then
		table.remove(Ent.BuildQueue,1)
	end
	
	local Window = Glob.Window
	if Window and IsValid(Window) and Window.Ent == Ent then
		Window:SetupQueue(Ent.BuildQueue)
	end
end)

Utl:HookNet("barracks_start_training","",function(D,P)
	local Ent = D.E

	if Ent and IsValid(Ent) then
		Ent.TrainE = D.End
		Ent.TrainS = D.Sta
	end
end)