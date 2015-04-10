local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

print("AiNode Core Loaded!")

Singularity.AI = {}
local AI = Singularity.AI

AI.NodeFilter = {}
AI.Nodes = {}
AI.DebugMode = false

--The Directions we make the nodes in.
AI.NodeDistance = 200
AI.Directions = {Vector(AI.NodeDistance,0,0),Vector(-AI.NodeDistance,0,0),Vector(0,AI.NodeDistance,0),Vector(0,-AI.NodeDistance,0)}

function AI.GenerateNode(Pos,Data)
	local Data = Singularity.Entities.Modules["Resources"]["AI Node"]

	local ent = ents.Create( Data.E.Class )
	ent:SetModel( Data.E.MyModel )
	ent:SetPos(Pos)
	
	ent:Spawn() ent:Activate()
	ent:GetPhysicsObject():EnableMotion(false)
	
	ent:Compile(Data.M)
	ent.NodeData = Data
	
	--table.insert(AI.NodeFilter,ent)
	return ent
end

function AI.DoTrace(P1,P2)
	local tr = util.TraceLine({start = P1,endpos = P2,filter = AI.NodeFilter,mask = 16395} )
	-- tr.HitPos,tr.Hit,tr.Entity
	return tr
end

function AI.ClosestNode(Pos)
	local Sector =  AI.GetSector(Pos)
	
	local Closest,Dist = nil,9999999
	
	for k, v in pairs(AI.Nodes[tostring(Sector)]) do
		local Distance = Pos:Distance(v.P)
		if Distance<Dist then
			Dist = Distance
			Closest=v
		end
	end
	
	return Closest
end

function AI.GetSector(Pos)
	local SectSize = 1000
	return Vector(math.Round(Pos.x/SectSize),math.Round(Pos.y/SectSize),math.Round(Pos.z/SectSize))
end

function AI.MakeNodeData(Pos)
	local Data = {P=Pos,C={},Cost=1}
	
	function Data:GetPos()
		return self.P
	end
	
	return Data
end

AI.Generator = {}
local Gen = AI.Generator
Gen.UnfinishedNodes = {}
Gen.State = "Generating"
Gen.Prog = 0
Gen.Goal = 1

function Gen.CheckClear(Pos,Sector)
	for k, v in pairs(AI.Nodes[Sector]) do
		if Pos:Distance(v.P)<AI.NodeDistance*0.9 then
			return false
		end
	end
	
	return true
end

function AI.NodeGenerate(Pos)
	--print("Generating Node!")
	
	local Sector = tostring(AI.GetSector(Pos))
	AI.Nodes[Sector]=AI.Nodes[Sector] or {}
	if not Gen.CheckClear(Pos,Sector) then /*print("Node already here.")*/ return end --Nope

	local NodeDat = AI.MakeNodeData(Pos)

	AI.Nodes[Sector][tostring(Pos)] = NodeDat-- Our first node.
	
	for k, v in pairs(AI.Directions) do
		local vPos = Pos+v+Vector(0,0,AI.NodeDistance*0.5)
			
		--local tr = AI.DoTrace(Pos,vPos,Sector)
		--if not tr.Hit then
		local tr = AI.DoTrace(vPos,vPos+Vector(0,0,-AI.NodeDistance*1.8))
		if tr.Hit then
			local HP = tr.HitPos+Vector(0,0,20)
			local vSect = tostring(AI.GetSector(HP))
			AI.Nodes[vSect]=AI.Nodes[vSect] or {}
			
			if Gen.CheckClear(vPos,vSect) then
				tr = AI.DoTrace(Pos,HP)
				if not tr.Hit then --Can We Trace to it?
					table.insert(Gen.UnfinishedNodes,HP)
				end
			end
		end
		--end
	end
	
	if AI.DebugMode then AI.GenerateNode(Pos,NodeDat) end
	return NodeDat
end

function AI.NavNodeGenerate()
	local UnFinished = table.Count(Gen.UnfinishedNodes)
	while UnFinished > 0 do
		local X,XMax = 1, 20
		
		if not AI.DebugMode then XMax = 100 end
		
		for k, v in pairs(Gen.UnfinishedNodes) do
			AI.NodeGenerate(v)
			Gen.UnfinishedNodes[k]=nil
			
			if X>=20 then
				coroutine.wait(0.0001)
				X=1
			else
				X=X+1 
			end
		end
		
		UnFinished = table.Count(Gen.UnfinishedNodes)
	end
	
	Gen.State = "Connecting"
		
	local X,XMax = 1, 20
	if not AI.DebugMode then XMax = 100 end
	
	Gen.Prog = 0
	Gen.Goal,nope = AI.CountNodes()
	Gen.Goal = Gen.Goal*Gen.Goal
	
	for k, m in pairs(AI.Nodes) do
		for s, v in pairs(m) do
			for l, b in pairs(AI.Nodes) do
				for d, n in pairs(b) do
					Gen.Prog = Gen.Prog + 1
					if v.P == n.P then continue end
					if v.P:Distance(n.P)<AI.NodeDistance*2 then
						local tr = AI.DoTrace(v.P,n.P)
						if not tr.Hit then --Can We Trace to it?
							table.insert(v.C,n)
						end
					end
					
					if X>=20 then
						coroutine.wait(0.0001)
						X=1
					else
						X=X+1 
					end
				end
			end
		end
	end

	Gen.State = "Finished"
	coroutine.yield()
end

function AI.CountNodes()
	Sectors = table.Count(AI.Nodes)
	Nodes = 0
	for k, v in pairs(AI.Nodes) do
		Nodes=Nodes+table.Count(v)
	end
	return Nodes,Sectors
end

function AI.GenerateNavNodes(Pos)
	AI.GenStart = SysTime()
	print("Starting Nav Node Generation!")
	AI.NodeGenerate(Vector(math.Round(Pos.x),math.Round(Pos.y),math.Round(Pos.z)))
	Gen.Thread = coroutine.create(function() AI.NavNodeGenerate() end)
	
	Utl:SetupThinkHook("AiNodeGenerator",0,0,function()
		if Gen.State~="Finished" then
			if Gen.State == "Generating" then
				print("Unfinished Nodes: "..tostring(table.Count(Gen.UnfinishedNodes)))
			else
				print("Building Node Networks.... "..tostring(Gen.Prog).." / "..tostring(Gen.Goal))
			end
			coroutine.resume(Gen.Thread)
		else
			local N,S = AI.CountNodes()
			print("Finished Nav Node Generation! Time Took: "..tostring(SysTime()-AI.GenStart)
				.."\nGenerated "..tostring(N).." nodes across "..tostring(S).." sectors.")
			Utl:RemoveThinkHook("AiNodeGenerator")
		end 
	end)
end















