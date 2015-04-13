local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

Singularity.PathFinder = {}
local PF = Singularity.PathFinder
local AI = Singularity.AI
local Nodes = AI.Nodes
 
 --Check Line of sight, and filter out nodes that our melons cant traverse.
function PF.CheckLOS(node,neighbor)
	return true
end

--Override the neighbor_nodes function to use our optimised lists.
function astar.neighbor_nodes(node,nodes)
	local Connected = {}
	local nodes = AI.GetConnected(node)
	
	for k, v in pairs(nodes) do
		if PF.CheckLOS(node,v) then
			table.insert(Connected,v)
		end
	end
	
	return Connected
end

function PF.FindPath(Start,End)
	local start,goal = AI.ClosestNode(Start),AI.ClosestNode(End)
	if start==nil or goal==nil then return end
	
	local Status,Path = astar.getpath(start,goal)
	
	if Status == "NotExist" then
		astar.path(start,goal,Nodes,false,PF.CheckLOS)
		return "Pathing",nil
	elseif Status == "Finished" then
		local PathReal = {}
		
		for k, v in pairs(Path) do
			PathReal[k]=v.P
		end
		
		return Status,PathReal		
	end
	
	return Status,nil
end

/* --Old version
function PF.FindPath(Start,End)
	local start,goal = AI.ClosestNode(Start),AI.ClosestNode(End)
	if start==nil or goal==nil then return end
	
	local Path = astar.path(start,goal,Nodes,false,PF.CheckLOS)
	
	if not Path then return end
	
	local PathReal = {}
	
	for k, v in pairs(Path) do
		PathReal[k]=v.P
	end
	
	return PathReal
end
*/