
local Singularity = Singularity
Singularity.QO = {}
local QO = Singularity.QO
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan 

QO.Queued = {}
QO.Groups = {}

if SERVER then
	function QO.QueueOrders(Ent,Orders)
		QO.Queued[Ent:EntIndex()] = {E=Ent,O=Orders}
	end
	
	function QO.IsOrderMatch(O,G)
		if table.Count(O) ~= table.Count(G.Orders) then return false end
		for i, o in pairs(G.Orders) do
			if O[i]~=nil and o.V ~= O[i].V then
				return false
			end
		end
		return true
	end
	
	function QO.MakeGroup(O)
		local T = {Orders=O,Ents={}}
		table.insert(QO.Groups,T)
		return T
	end
	
	function QO.AddToGroup(O,G)
		G.Ents[O.E:EntIndex()] = {E=O.E}
	end
	
	function QO.CondenseOrders()
		for oi, o in pairs(QO.Queued) do
			local InGroup = false
			for gi, g in pairs(QO.Groups) do
				if QO.IsOrderMatch(o.O,g) then
					QO.AddToGroup(o,g)
					InGroup = true
				end
			end
			
			if not InGroup then
				local g = QO.MakeGroup(o.O)
				QO.AddToGroup(o,g)
			end
			
			QO.Queued[oi]=nil
		end
	end
	
	function QO.SendOrders()
		QO.CondenseOrders()
		
		if table.Count(QO.Groups)<=0 then return end
		NDat.AddDataAll({
			Name="MelonGroupOrders",
			Val=1,
			Dat={{N="G",T="T",V=QO.Groups}}
		})
		
		QO.Groups = {}
	end
	
	Utl:SetupThinkHook("QueuedOrders",0.1,0,QO.SendOrders)
else

	Utl:HookNet("MelonGroupOrders","",function(D)
		for i, g in pairs(D.G) do
			for ei, e in pairs(g.Ents) do
				local Ent = Entity(ei)
				if Ent and IsValid(Ent) then
					Ent.Orders = table.Copy(g.Orders)
				end
			end
		end
	end)
	
end






