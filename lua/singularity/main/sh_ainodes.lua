local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

print("AiNode Core Loaded!")

Singularity.AI = {}
local AI = Singularity.AI

AI.NodeFilter = {}
AI.Nodes = {}
AI.Sectors = {}
AI.NNSettings = {NodeDistance=200,SectorSize=1000}
AI.DebugMode = false

--The Directions we make the nodes in.
AI.Directions = {Vector(AI.NNSettings.NodeDistance,0,0),Vector(-AI.NNSettings.NodeDistance,0,0),
Vector(0,AI.NNSettings.NodeDistance,0),Vector(0,-AI.NNSettings.NodeDistance,0),Vector(AI.NNSettings.NodeDistance,AI.NNSettings.NodeDistance,0),
Vector(-AI.NNSettings.NodeDistance,-AI.NNSettings.NodeDistance,0),Vector(-AI.NNSettings.NodeDistance,AI.NNSettings.NodeDistance,0),
Vector(AI.NNSettings.NodeDistance,-AI.NNSettings.NodeDistance,0)
}

local Map = string.lower(game.GetMap()) --Get the map
local FileName = "wmainn["..Map.."]"

function AI.ParseNodeFile(Data)
	if not Data then print("No Save Data Found!") return end
	local Load = util.JSONToTable(Data)
	table.Merge(AI.Nodes,Load.Nodes)
	table.Merge(AI.NNSettings,Load.Settings)
	print("Successfully Loaded "..tostring(AI.CountNodes()).." Ai Nodes!")
end

function AI.LoadNodeNetwork()
	print("Loading Map Nodes!")
	local Folder = "singularity/main/nodemaps/"
	AI.ParseNodeFile(file.Read(Folder..FileName..".lua","LUA"))
end

function AI.SaveNodeNetwork()
	Data = util.TableToJSON({Nodes=AI.Nodes,Settings=AI.NNSettings})
	
	file.Write( FileName..".txt", Data )
end

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
	local Sector = AI.Nodes[tostring(AI.GetSector(Pos))]
	
	local Closest,Dist = nil,9999999
	
	--PrintTable(Sector)
	
	for k, v in pairs(Sector) do
	--	PrintTable(v)
		local Distance = Pos:Distance(v.P)
		if Distance<Dist then
			Dist = Distance
			Closest=v
		end
	end
	
	return Closest
end

function AI.GetSector(Pos)
	local SectSize = AI.NNSettings.SectorSize
	return Vector(math.Round(Pos.x/SectSize),math.Round(Pos.y/SectSize),math.Round(Pos.z/SectSize))
end

function AI.GetConnected(node)
	local Connected = {}
	
	for k, v in pairs(node.C) do
		local NodeDat = AI.Nodes[v.S][v.N]
		if NodeDat then
			table.insert(Connected,NodeDat)
		end
	end
	
	return Connected	
end

function AI.MakeNodeData(Pos)
	local Data = {P=Pos,C={},Cost=1,Extra={Water=false}}
	Data.x = Pos.x Data.y = Pos.y
	
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
		if Pos:Distance(v.P)<AI.NNSettings.NodeDistance*0.9 then
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
		local vPos = Pos+v+Vector(0,0,AI.NNSettings.NodeDistance*0.5)
			
		--local tr = AI.DoTrace(Pos,vPos,Sector)
		--if not tr.Hit then
		local tr = AI.DoTrace(vPos,vPos+Vector(0,0,-AI.NNSettings.NodeDistance*1.8))
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
		local X,XMax = 1, 100
		
		if not AI.DebugMode then XMax = 200 end
		
		for k, v in pairs(Gen.UnfinishedNodes) do
			AI.NodeGenerate(v)
			Gen.UnfinishedNodes[k]=nil
			
			if X>=XMax then
				coroutine.yield()
				X=1
			else
				X=X+1 
			end
		end
		
		UnFinished = table.Count(Gen.UnfinishedNodes)
	end
	
	Gen.State = "Connecting"
	
	Gen.Prog = 0
	Gen.Goal,nope = AI.CountNodes()
	Gen.Goal = Gen.Goal*Gen.Goal
	Gen.Extra = 0
	Gen.Extra2 = 0
	Gen.LoopStart = SysTime()
	
	local LagPauseCheck = 0
	for k, m in pairs(AI.Nodes) do
		Gen.Extra = Gen.Extra+1
		for s, v in pairs(m) do
			Gen.Extra2 = Gen.Extra2+1
			for l, b in pairs(AI.Nodes) do
				for d, n in pairs(b) do
					Gen.Prog = Gen.Prog + 1
					if v.P == n.P then continue end
					if v.P:Distance(n.P)<AI.NNSettings.NodeDistance*2 then
						local tr = AI.DoTrace(v.P,n.P)
						if not tr.Hit then --Can We Trace to it?
							table.insert(v.C,{S=l,N=d})
						end
					end
					
					if LagPauseCheck>=20000 then
						LagPauseCheck=0
						Gen.LoopPause = SysTime()
						coroutine.yield()
					else
						LagPauseCheck=LagPauseCheck+1
					end
				end
			end
			
			local HasWater = bit.band( util.PointContents( v.P ), CONTENTS_WATER ) == CONTENTS_WATER
			v.Extra["Water"]=HasWater
			
			if HasWater then
				v.Cost = 1.5
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
	Gen.State = "Generating"
	Gen.Thread = coroutine.create(function() AI.NavNodeGenerate() end)
	
	Utl:SetupThinkHook("AiNodeGenerator",0,0,function()
		if Gen.State~="Finished" then
			if Gen.State == "Generating" then
				print("Unfinished Nodes: "..tostring(table.Count(Gen.UnfinishedNodes)))
			else
				local Change = Gen.LoopPause-(Gen.SavedPause or SysTime())
				Gen.SavedPause = Gen.LoopPause
				print("Percent: "..((Gen.Prog/Gen.Goal)*100).." Building Node Networks.... "..tostring(Gen.Prog).." / "..tostring(Gen.Goal).." Working... Sector: "..tostring(Gen.Extra).." Node: "..tostring(Gen.Extra2).." TimeChange: "..Change)
			end
			coroutine.resume(Gen.Thread)
		else
			local N,S = AI.CountNodes()
			print("Finished Nav Node Generation! Time Took: "..tostring(SysTime()-AI.GenStart)
				.."\nGenerated "..tostring(N).." nodes across "..tostring(S).." sectors.")
			Utl:RemoveThinkHook("AiNodeGenerator")
			AI.SaveNodeNetwork() --Save the network to file!
		end 
	end)
end

AI.LoadNodeNetwork()--Load any possible netowrks.














