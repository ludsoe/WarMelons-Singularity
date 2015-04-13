local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

Singularity.Teams = Singularity.Teams or {}
local Teams = Singularity.Teams

Singularity.LoadFile("singularity/classes/teamai.lua",1)
Singularity.LoadFile("singularity/classes/team.lua",1)
Teams.Teams = {}

--General Functions
if SERVER then
	function Teams.CreateTeam(name,color,persist) 
		print("Creating Team: "..name.." Color: "..tostring(color))
		local Team = {} Team = table.Copy(Teams.Class)
		
		Team:Setup(name,color)
		if persist then 
			Team:ChangeSetting(Persist,true,true)
		end
		
		Teams.Teams[name]=Team
		return Team
	end
	
	Teams.CreateTeam("Red",Color(255,0,0,255),true)
	Teams.CreateTeam("Green",Color(0,255,0,255),true)
	Teams.CreateTeam("Blue",Color(0,0,255,255),true)
	Teams.CreateTeam("Purple",Color(255,0,255,255),true)
	Teams.CreateTeam("Yellow",Color(255,255,0,255),true)
	Teams.UnOwned = Teams.CreateTeam("UnOwned",Color(255,255,255,255),true) --Hidden unowned team.
	Teams.UnOwned:ChangeSetting("Hidden",true,true)
	
	Utl:HookNet("JoinTeam","",function(D,Ply)
		local Team = Teams.Teams[D.N]
		if Team then
			if Team:CanPlayerJoin(Ply) then
				Team:AddMember(Ply)
			end
		end
	end)
	
	Utl:HookNet("LeaveTeam","",function(D,ply)
		ply:GetMTeam():RemoveMember(ply)
		
		ply:MakeMTeam()
	end)
		
	Utl:HookNet("ReqTeamAlly","",function(D,ply)
		local Team = ply:GetMTeam()
		if Team.name == D.T1 then
			if Team:GetLeader() == ply or Utl:CheckAdmin( ply ) then 
				Team:MakeAlly(Teams.Teams[D.T2])
			end
		end
	end)
			
	Utl:HookNet("ReqTeamNeutral","",function(D,ply)
		local Team = ply:GetMTeam()
		if Team.name == D.T1 then
			if Team:GetLeader() == ply or Utl:CheckAdmin( ply ) then 
				Team:MakeNeutral(Teams.Teams[D.T2])
			end
		end
	end)
			
	Utl:HookNet("ReqTeamHostile","",function(D,ply)
		local Team = ply:GetMTeam()
		if Team.name == D.T1 then
			if Team:GetLeader() == ply or Utl:CheckAdmin( ply ) then 
				Team:MakeEnemy(Teams.Teams[D.T2])
			end
		end
	end)
	
	Utl:HookNet("SingTeamSettingsSync","",function(D,Ply)
		print("Received Setting: "..D.T.N.." from "..tostring(Ply:Nick()).." in "..tostring(Ply:GetMTeam().name).." for "..tostring(D.T.T).." Value: "..tostring(D.T.V))
		local Team = Ply:GetMTeam()
		--PrintTable(Team)
		--if Team.name == D.T.T then
			if Team:GetLeader() == ply or Utl:CheckAdmin( ply ) then 
				Team:ChangeSetting(D.T.N,D.T.V,false)
			else
				print("Is Not Team Leader! Or Admin!")
			end
		--end
	end)
else
	
	function Teams.RequestTeams(Tab,Tab2)
		NDat.AddData({Name="TeamRequest",Val=1,Dat={}})
		if Tab and Tab2 then
			Teams.Tab = Tab
			Teams.ATab = Tab2
		end
	end	
end

function Teams.RemakeList()
	if not Teams.Tab or not IsValid(Teams.Tab.Base) then return end
	if Teams.Tab.TeamList and IsValid(Teams.Tab.TeamList) then
		Teams.Tab.TeamList:Clear()
		
		for k,v in pairs(Teams.GetTeamsSafe()) do
			Teams.Tab.TeamList:AddLine(k)
		end
	end
	Teams.Tab.JoinButton:SetText("Select Group")
	Teams.Tab.MemberList:Clear()
	Teams.Tab.Alliances:Clear()

	Teams.Tab.Selected = nil
end

function Teams.ReloadAlliances()
	local MyTab = Teams.ATab
	--print("Reloading Allys")
	if not MyTab then return end
	if not MyTab.TeamList or not IsValid(MyTab.TeamList) then return end
	MyTab.MyTeam = GetMyTeam()
	local MyTeam = MyTab.MyTeam
	if not MyTeam then return end
	--print("Clearing List")
	MyTab.TeamList:Clear()
	for k,v in pairs(Teams.GetTeamsSafe()) do
		if MyTeam.name ~= v.name then
			MyTab.TeamList:AddLine(k,GetRelations(MyTeam,v),GetRelations(v,MyTeam))
		end
	end
	--print("Finished")
end

--Returns a table of the teams without the hidden ones in it.
function Teams.GetTeamsSafe()
	local TeamsSafe = {}
	for k,v in pairs(Singularity.Teams.Teams) do
		local Hidden = v.Settings.Hidden
		if Hidden == false then
			--print("Not Hidden")
			TeamsSafe[k]=v
		else
			--print("Hidden")
		end
	end
	return TeamsSafe
end

Utl:HookNet("TeamRequest","",function(D,Ply)
	if SERVER then
		local Send = {
			Name="TeamRequest",
			Val=1,
			Dat={{N="T",T="T",V=Teams.Teams}}
		}
		NDat.AddData(Send,Ply)	
	else
		Singularity.Teams.Teams=D.T
		Teams.RemakeList()
		Teams.ReloadAlliances()
	end
end)

Utl:HookNet("TeamSyncMsg","",function(D,Ply) Teams.Teams[D.N]=D.T end)
Utl:HookNet("TeamDelete","",function(D,Ply) Teams.Teams[D.N]=nil Teams.RemakeList() end)
Utl:HookNet("TeamMemberJoin","",function(D,Ply) LocalPlayer().MelonTeam = D.N end)

function GetMyTeam()
	for k,v in pairs(Teams.Teams) do
		if v.Members[LocalPlayer():Nick()] then
			return v
		end
	end
end

function GetRelations(T1,T2)
	return T1.Diplomacy[T2.name] or "Neutral"
end






