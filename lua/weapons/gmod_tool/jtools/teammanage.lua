local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.				
local Teams = Singularity.Teams

local Tool = {}

function ViewTeamsPage(Base,Tab)
	local MyTab = Tab["View"] or {}
	local Name = "Select Group"
	
	MyTab.Base = Base
		
	local OnSelect = function(Data)
		if Teams.Teams[Data].Members[LocalPlayer():Nick()] then
			MyTab.JoinButton:SetText("Leave: "..Data)
		else
			MyTab.JoinButton:SetText("Join: "..Data)
		end
		
		MyTab.MemberList:Clear()
		
		for k,v in pairs(Teams.Teams[Data].Members) do
			--print(""..k)
			MyTab.MemberList:AddLine(k)
		end
		
		local Text = "None"
		if Teams.Teams[Data].Leader then
			LeadEnt = Entity(Teams.Teams[Data].Leader.ID)
			if LeadEnt and IsValid(LeadEnt) then Text = LeadEnt:Nick() end
		end
		MyTab.Leader:SetText("Leader: "..Text)
		
		MyTab.Selected = Data
	end	
	
	MyTab.TeamList = Singularity.MT.AddList("Teams",Teams.Teams,OnSelect,Base,260)
	Teams.RequestTeams(MyTab)
	
	MyTab.RefreshTeams = Singularity.MenuCore.CreateButton(Base,{x=150,y=40},{x=0,y=270},"Refresh",function() 
		Teams.RequestTeams(MyTab)
	end)
	
	local Mod = Singularity.MT.AddModular(Base)

	MyTab.JoinButton = Singularity.MT.ModAddButton(Mod,Name,function() 
		local Data = MyTab.Selected
		if Data then
			if Teams.Teams[Data].Members[LocalPlayer():Nick()] then
				NDat.AddData({Name="LeaveTeam",Val=1,Dat={}})
			else
				NDat.AddData({Name="JoinTeam",Val=1,Dat={{N="N",T="S",V=Data}}})
			end
			Teams.RequestTeams(MyTab)
		end
	end)
	
	MyTab.Leader = Singularity.MT.ModAddlabel(Mod,"Leader: ",5)
	
	MyTab.MemberList = Singularity.MenuCore.CreateList(Mod,{x=150,y=200},{x=0,y=110},false,function() end)
	MyTab.MemberList:AddColumn("Members") -- Add column
end

function AlliancePage(Base,Tab)
	local MyTab = Tab["Ally"] or {}
	local OnSelect = function(Data) MyTab.Selected = Data end	
	
	MyTab.TeamList = Singularity.MenuCore.CreateList(Base,{x=300,y=310},{x=5,y=5},false,OnSelect)
	MyTab.TeamList:AddColumn("Team") -- Add column
	MyTab.TeamList:AddColumn("Our Stance") -- Add column
	MyTab.TeamList:AddColumn("Their Stance") -- Add column

	Teams.RequestAllys(MyTab)
	
	MyTab.MyTeam = GetMyTeam()
	
	Singularity.MenuCore.CreateButton(Base,{x=190,y=40},{x=310,y=5},"Alliance",function() 
		local Data = MyTab.Selected
		if Data then
			NDat.AddData({Name="ReqTeamAlly",Val=1,Dat={{N="T1",T="S",V=MyTab.MyTeam.name},{N="T2",T="S",V=Data}}})
		end
		
		Teams.RequestAllys(MyTab)
	end)
	
	Singularity.MenuCore.CreateButton(Base,{x=190,y=40},{x=310,y=50},"Neutral",function() 
		local Data = MyTab.Selected
		if Data then
			NDat.AddData({Name="ReqTeamNeutral",Val=1,Dat={{N="T1",T="S",V=MyTab.MyTeam.name},{N="T2",T="S",V=Data}}})
		end		
		
		Teams.RequestAllys(MyTab)
	end)
	
	Singularity.MenuCore.CreateButton(Base,{x=190,y=40},{x=310,y=95},"Hostile",function() 
		local Data = MyTab.Selected
		if Data then
			NDat.AddData({Name="ReqTeamHostile",Val=1,Dat={{N="T1",T="S",V=MyTab.MyTeam.name},{N="T2",T="S",V=Data}}})
		end		
		
		Teams.RequestAllys(MyTab)
	end)
		
	Singularity.MenuCore.CreateButton(Base,{x=190,y=40},{x=310,y=275},"Refresh",function() 
		Teams.RequestAllys(MyTab)
	end)	
end

Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
	
	Tab.Save = Tab.Save or {}
	
	local C,M,A = vgui.Create( "DPanel" ),vgui.Create( "DPanel" ),vgui.Create( "DPanel" )
	local Sheet = Singularity.MenuCore.CreatePSheet(Menu,{x=520,y=355},{x=0,y=0})
	Sheet:AddSheet( "View Teams" , C , "icon16/eye.png" , false, false, "" )
	Sheet:AddSheet( "Team Settings" , M , "icon16/cog.png" , false, false, "" )
	Sheet:AddSheet( "Team Alliances" , A , "icon16/gun.png" , false, false, "" )

	ViewTeamsPage(C,Tab)
	AlliancePage(A,Tab)
end --This is clientside only, called when the tool is selected.

Singularity.MT.AddTool("Team Management",Tool)










