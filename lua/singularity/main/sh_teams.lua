local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

Singularity.Teams = Singularity.Teams or {}
local Teams = Singularity.Teams

Singularity.LoadFile("singularity/classes/team.lua",1)
Teams.Teams = {}

--General Functions
if SERVER then
	function Teams.CreateTeam(name,color) 
		print("Creating Team: "..name.." Color: "..tostring(color))
		local Team = {} Team = table.Copy(Teams.Class)
		
		Team:Setup(name,color)
		
		Teams.Teams[name]=Team
		return Team
	end
	
	Utl:HookNet("JoinTeam","",function(D,Ply)
		local Team = Teams.Teams[D.N]
		if Team then
			Team:AddMember(Ply)
		end
	end)
	
	Utl:HookNet("LeaveTeam","",function(D,ply)
		ply:GetMTeam():RemoveMember(ply)
		
		local VC = ply:GetPlayerColor()
		local Col = Color((VC.x*255),(VC.y*255),(VC.z*255),255)
		ply:SetMTeam(Teams.CreateTeam(ply:Nick(),Col))
	end)
else
	
	function Teams.RequestTeams(List)
		NDat.AddData({Name="TeamRequest",Val=1,Dat={}})	
		Teams.TList = List
	end
end

Utl:HookNet("TeamRequest","",function(D,Ply)
	if SERVER then
		local Send = {
			Name="TeamRequest",
			Val=1,
			Dat={{N="T",T="T",V=Singularity.Teams.Teams}}
		}
		NDat.AddData(Send,Ply)	
	else
		Singularity.Teams.Teams=D.T
		if Teams.TList and IsValid(Teams.TList) then
			Teams.TList:Clear()
			
			for k,v in pairs(D.T) do
				Teams.TList:AddLine(k)
				PrintTable(v)
			end
		end
	end
end)
