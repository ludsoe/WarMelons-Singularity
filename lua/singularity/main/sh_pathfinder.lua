local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

Singularity.PathFinder = {}
local PF = Singularity.PathFinder
local AI = Singularity.AI
local Nodes = AI.Nodes

local function heuristic(a, b)
        //Manhattan distance on a square grid
        if not a.Cost then a.Cost = 1 end
        if not b.Cost then b.Cost = 1 end
        return ((a:GetPos():Distance(b:GetPos()))*(a.Cost*b.Cost))
end
 
function PF.FindPath(Start,End)
	local start = AI.ClosestNode(Start)
	local goal = AI.ClosestNode(End)
	local frontier = {}
	table.insert(frontier, start)
	local came_from = {}
	local cost_so_far = {}
	came_from[start] = None
	cost_so_far[start] = 0
	
	while #frontier ~= 0 do
			current = frontier[#frontier]
			if current == goal then
					break
			end
			for k, next in pairs(current.C) do
					new_cost = cost_so_far[current] + (next.Cost)
					if (not table.HasValue(cost_so_far, next)) or (new_cost < cost_so_far[next]) then
							cost_so_far[next] = new_cost
							priority = new_cost + heuristic(goal, next)
							//I'm fucking retarded at tables, but you need to make everything above frontier[priority] move up one keyvalue
							table.insert(frontier, next)
							came_from[next] = current
					end
			end
			frontier[#frontier] = nil
	end
end
