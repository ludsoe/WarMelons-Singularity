local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

Singularity.PathFinder = {}
local PF = Singularity.PathFinder
local AI = Singularity.AI
local Nodes = AI.Nodes

function IsInTable(Tab,Data)
	for k, v in pairs(Tab) do
		if Data==v then
			return true
		end
	end
	return false
end

function PF.FindPath(Start,End)
	local SN,EN = AI.ClosestNode(Start),AI.ClosestNode(End)--Get the nodes for our points.
	local Path,Open,Checked = {},{},{}
	
	Open[tostring(SN.P)]={N=SN,D=SN.P:Distance(EN.P)}
	
	if SN == EN then return {} end
	
	local OC = table.Count(Open)
	while OC>0 do
		for k, v in pairs(Open) do
			Checked[tostring(v.N.P)]=v
			for x, n in pairs(v.N.C) do
				local NodePos = n.P
				if not Checked[tostring(NodePos)] then
					if EN.P == NodePos then
						table.insert(Path,v.N.P)
						table.insert(Path,EN.P)
						
						PrintTable(Path)
						
						return Path
					else
						if NodePos:Distance(EN.P)<v.D then
							table.insert(Path,v.N.P)
							for b, ns in pairs(v.N.C) do
								local Key = tostring(ns.P)
								if not Checked[Key] and not Checked[Key] then
									Open[Key]={N=ns,D=ns.P:Distance(EN.P)}
								end
							end
							break
						end
					end
				end
			end
		end
		
		OC=table.Count(Open)
	end
	
	return {} --No Path found :(
end
