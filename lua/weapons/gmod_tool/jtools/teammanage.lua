local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.				
local Teams = Singularity.Teams

local Tool = {}

function ViewTeamsPage(Base,Tab)
	local MyTab = Tab["View"] or {}
	local Name = "Select Group"
		
	local OnSelect = function(Data)
		if Teams.Teams[Data].Members[LocalPlayer():Nick()] then
			MyTab.JoinButton:SetText("Leave: "..Data)
		else
			MyTab.JoinButton:SetText("Join: "..Data)
		end
		
		for k,v in pairs(Teams.Teams[Data].Members) do
			print(""..k)
			MyTab.MemberList:AddLine(k)
		end
		
		MyTab.Selected = Data
	end	
	
	MyTab.TeamList = Singularity.MT.AddList("Teams",Teams.Teams,OnSelect,Base,260)
		
	MyTab.RefreshTeams = Singularity.MenuCore.CreateButton(Base,{x=150,y=40},{x=0,y=270},"Refresh",function() 
		Teams.RequestTeams(MyTab.TeamList)
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
		end
	end)
	
	MyTab.MemberList = Singularity.MenuCore.CreateList(Mod,{x=150,y=200},{x=0,y=80},false,function() end)
	MyTab.MemberList:AddColumn("Members") -- Add column

end

Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
	local Mod = Singularity.MT.AddModular()
	Tab.Save = Tab.Save or {}
	
	local C,M = vgui.Create( "DPanel" ),vgui.Create( "DPanel" )
	local Sheet = Singularity.MenuCore.CreatePSheet(Menu,{x=520,y=355},{x=0,y=0})
	Sheet:AddSheet( "View Teams" , C , "icon16/lightning.png" , false, false, "" )
	Sheet:AddSheet( "Manage Team" , M , "icon16/lightning.png" , false, false, "" )

	ViewTeamsPage(C,Tab)
end --This is clientside only, called when the tool is selected.

Singularity.MT.AddTool("Team Management",Tool)










