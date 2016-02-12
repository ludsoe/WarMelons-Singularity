local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.				
local Teams = Singularity.Teams
local GI = Singularity.MenuCore
		
local Tool = {}

function ViewTeamsPage(Base,Tab)
	local MyTab = Tab["View"] or {}
	Tab["View"] = MyTab
	local Name = "Select Group"
	
	MyTab.Base = Base
		
	local OnSelect = function(Data)
		local SelTeam = Teams.Teams[Data]
		if not SelTeam then return end
		
		if SelTeam.Members[LocalPlayer():Nick()] then
			MyTab.JoinButton:SetText("Leave: "..Data)
		else
			MyTab.JoinButton:SetText("Join: "..Data)
		end
		
		MyTab.MemberList:Clear()
		for k,v in pairs(SelTeam.Members) do
			--print(""..k)
			MyTab.MemberList:AddLine(k)
		end
		
		MyTab.Alliances:Clear()
		for k,v in pairs(Teams.GetTeamsSafe()) do
			if Data ~= v.name then
				MyTab.Alliances:AddLine(k,GetRelations(SelTeam,v))
			end
		end
		
		local CheckSettings = {CanJoin="Accepting Members: ",AIMode="Ai Enabled: "}
		
		MyTab.Settings:Clear()
		for k,v in pairs(CheckSettings) do
			MyTab.Settings:AddLine(v,SelTeam.Settings[k])
		end
			
		local Text = "None"
		if SelTeam.Leader then
			LeadEnt = Entity(SelTeam.Leader.ID)
			if LeadEnt and IsValid(LeadEnt) then Text = LeadEnt:Nick() end
		end
		MyTab.Leader:SetText("Leader: "..Text)
		
		MyTab.Selected = Data
	end	
	
	MyTab.TeamList = Singularity.MT.AddList("Teams",Teams.GetTeamsSafe(),function(L) OnSelect(L:GetValue(1)) end,Base,260)
	
	MyTab.RefreshTeams = GI.CreateButton(Base,{x=150,y=40},{x=0,y=270},"Refresh",function() 
		Teams.RequestTeams()
	end)
	
	local Mod = Singularity.MT.AddModular(Base)

	MyTab.JoinButton = Singularity.MT.ModAddButton(Mod,Name,function() 
		local Data = MyTab.Selected
		if Data then
			local SelTeam = Teams.Teams[Data]
			if not SelTeam then return end
			if SelTeam.Members[LocalPlayer():Nick()] then
				NDat.AddData({Name="LeaveTeam",Val=1,Dat={}})
			else
				NDat.AddData({Name="JoinTeam",Val=1,Dat={N=Data}})
			end
			Teams.RequestTeams()
		end
	end)
	
	MyTab.Leader = Singularity.MT.ModAddlabel(Mod,"Leader: ",5)
	
	local A,M,S = vgui.Create( "DPanel" ),vgui.Create( "DPanel" ),vgui.Create( "DPanel" )
	MyTab.Sheet = GI.CreatePSheet(Mod,{x=280,y=220},{x=0,y=90})
	MyTab.Sheet:AddSheet( "Members" , M , "icon16/group.png" , false, false, "Players On This Team." )
	MyTab.Sheet:AddSheet( "Alliances" , A , "icon16/gun.png" , false, false, "This Teams Relations." )
	MyTab.Sheet:AddSheet( "Settings" , S , "icon16/page_gear.png" , false, false, "This Teams Settings." )

	MyTab.MemberList = GI.CreateList(M,{x=264,y=184},{x=0,y=0},false,function() end)
	MyTab.MemberList:AddColumn("Members") -- Add column

	MyTab.Alliances = GI.CreateList(A,{x=264,y=184},{x=0,y=0},false,function() end)
	MyTab.Alliances:AddColumn("Team") -- Add column
	MyTab.Alliances:AddColumn("Relation") -- Add column
	
	MyTab.Settings = GI.CreateList(S,{x=264,y=184},{x=0,y=0},false,function() end)
	MyTab.Settings:AddColumn("Setting") -- Add column		
	MyTab.Settings:AddColumn("Value") -- Add column
end

function AlliancePage(Base,Tab)
	local MyTab = Tab["Ally"] or {}
	Tab["Ally"] = MyTab

	local OnSelect = function(Data) MyTab.Selected = Data end	
	
	MyTab.TeamList = GI.CreateList(Base,{x=300,y=310},{x=5,y=5},false,function(L) OnSelect(L:GetValue(1)) end)
	MyTab.TeamList:AddColumn("Team") -- Add column
	MyTab.TeamList:AddColumn("Our Stance") -- Add column
	MyTab.TeamList:AddColumn("Their Stance") -- Add column

	
	MyTab.MyTeam = GetMyTeam()
	
	GI.CreateButton(Base,{x=190,y=40},{x=310,y=5},"Alliance",function() 
		local Data = MyTab.Selected
		if Data then
			NDat.AddData({Name="ReqTeamAlly",Val=1,Dat={T1=MyTab.MyTeam.name,T2=Data}})
		end
		
		Teams.RequestTeams()
	end)
	
	GI.CreateButton(Base,{x=190,y=40},{x=310,y=50},"Neutral",function() 
		local Data = MyTab.Selected
		if Data then
			NDat.AddData({Name="ReqTeamNeutral",Val=1,Dat={T1=MyTab.MyTeam.name,T2=Data}})
		end		
		
		Teams.RequestTeams()
	end)
	
	GI.CreateButton(Base,{x=190,y=40},{x=310,y=95},"Hostile",function() 
		local Data = MyTab.Selected
		if Data then
			NDat.AddData({Name="ReqTeamHostile",Val=1,Dat={T1=MyTab.MyTeam.name,T2=Data}})
		end		
		
		Teams.RequestTeams()
	end)
		
	GI.CreateButton(Base,{x=190,y=40},{x=310,y=275},"Refresh",function() 
		Teams.RequestTeams()
	end)	
end

function SettingsPage(Base,Tab)
	local MyTab = Tab["Settings"] or {}
	Tab["Settings"] = MyTab
	MyTab.Base = Base
	MyTab.MyTeam = GetMyTeam()
	local Team = MyTab.MyTeam
	
	
	local Toggles = {
		CanJoin = "Accepting Members: ",
		AIMode = "AI Manager: "
	}
	
	local I = 0
	for Set,Text in pairs(Toggles) do
		Tab[Set] = GI.CreateButton(Base,{x=260,y=20},{x=0,y=I},Text..tostring(Team.Settings[Set]),function() 
			Team.Settings[Set] = not Team.Settings[Set]
			Tab[Set]:SetText(Text..tostring(Team.Settings[Set]))
			Utl:SyncTeamSetting(Set,Team.name,Team.Settings[Set])
		end)
		
		I=I+20
	end
end

Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
	
	Tab.Save = Tab.Save or {}
	
	local C,M,A = vgui.Create( "DPanel" ),vgui.Create( "DPanel" ),vgui.Create( "DPanel" )
	local Sheet = GI.CreatePSheet(Menu,{x=520,y=355},{x=0,y=0})
	Sheet:AddSheet( "View Teams" , C , "icon16/eye.png" , false, false, "View All Teams" )
	Sheet:AddSheet( "Team Settings" , M , "icon16/cog.png" , false, false, "Manage Your Teams Settings" )
	Sheet:AddSheet( "Team Alliances" , A , "icon16/gun.png" , false, false, "Manage Your Teams Relations with others" )

	ViewTeamsPage(C,Tab)
	AlliancePage(A,Tab)
	SettingsPage(M,Tab)
		
	Teams.RequestTeams(Tab["View"],Tab["Ally"])
end --This is clientside only, called when the tool is selected.

Singularity.MT.AddTool("Team Management",Tool)

function Utl:SyncTeamSetting(Name,Team,Value)
	print("Sending Team Setting Change: "..tostring(Name).." "..tostring(Value).." For team "..tostring(Team))
	Utl.NetMan.AddData({
		Name="SingTeamSettingsSync",Val=1,Dat={
			T={N=Name,T=Team,V=Value}	
		}
	})
end	









