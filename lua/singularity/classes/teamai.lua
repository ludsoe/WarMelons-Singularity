local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

local TeamAi = {
	MyTeam = {},
	Squads = {},
	Miners = {},
	QueuedMelons = {}
}

--Available melon types used for attacking.
TeamAi.AttackMelons = {
"Soldier Melon",
"Heavy Melon",
"Explosive Melon",
"Sniper Melon",
"Rapid Melon",
"Medic Melon"
}
TeamAi.MinerMelon = "Mining Melon" --Store the Mining melon entity type.

function TeamAi:LoopTable(tab,func)
	for k, v in pairs(tab) do
		func(k,v)
	end
end

function TeamAi:CountTableEnts(tab)
	local Ents = 0
	
	self:LoopTable(tab,function(k,v)
		if v and IsValid(v) then
			Ents = Ents+1
		else
			tab[k]=nil
		end	
	end)
	
	return Ents
end

--Account for queued melons 
function TeamAi:CheckMiners()
	return self:CountTableEnts(self.Miners)
end

--Identifies the melon type the ai should make next.
function TeamAi:GetNeededMelon()
	if self:CheckMiners() < 3 then --We need more miners!
		return self.MinerMelon
	end
	
	return self.AttackMelons[math.random(1,table.Count(self.AttackMelons))]
end

--Assigns barracks to build melons the ai needs.
function TeamAi:ManageBarracks(Barracks)
	local Needed = self:GetNeededMelon()
	
	if not Barracks:IsTraining() then
		Barracks:AddToQueue(Needed)
		Barracks.WillLoop = false -- Disable the queue loop system.
	end
end

--Gives orders to the building the ai has.
function TeamAi:ManageBuildings()
	self.MyTeam:LoopMels("Buildings",function(i,ent) 
		if ent.IsBarracks then
			self:ManageBarracks(ent)
		end
		
		--Add orders for other types of buildings here.
	end)
end

function TeamAi:CheckSquad(squad)
	return self:CountTableEnts(squad)
end

function TeamAi:ManageSquads()
	--PrintTable(self.Squads)
	
--	print("Managing Squads")
	
	for k, v in pairs(self.Squads) do
		if v:CheckValid() then
		--	print("Updating Center")
			v:UpdateCenter() --Update the Squads center.
			
			if v.Status == 1 then
				local Count = table.Count(v.Melons)
			--	print("Building Up! ")
			--	PrintTable(v.Melons)
				if Count > 10 then
					v.Status = 2
				end
			else
				if not v.Target or not IsValid(v.Target) then
			--		print("Finding target!")
					for i, m in pairs(v.Melons) do
						v.Target = m:ScanEnemysV2(10000)
						break
					end
					
					v:OrderMelons(v.Position)
					
					continue
				end
				
			--	print("Has target")
				
				if v.LastOrder < CurTime() then
				--	print("Issuing Order!")
					v.LastOrder = CurTime()+3
					v:OrderMelons(v.Target:GetPos())
				end
			end
		else
			self.Squads[k]=nil
		end
	end
end

function TeamAi:CreateSquad()
	local Squad = {
		Status=1, --1 Building up, 2 Attacking
		Melons={},
		Position=Vector(0,0,0),
		LastOrder = 0,
		Target = nil
	}
	
	function Squad:AddMelon(Melon) 
		self.Melons[Melon] = Melon
		Melon.AISquad = self
	end
	
	--Removes nil melons from roster
	function Squad:CleanseList()
		for k, v in pairs(self.Melons) do
			if not v or not IsValid(v) then
				self.Melons[k]=nil
			end
		end
	end
	
	function Squad:CheckValid()
		self:CleanseList()
		
		return table.Count(self.Melons)>0
	end
	
	function Squad:OrderMelons(Pos)
		self:CleanseList()
		
		--print("Giving Orders!")
		
		for k, v in pairs(self.Melons) do
			v:ClearOrders()
			v:AddOrder({T="Goto",V=Pos})
		end
		
	end
	
	function Squad:GetCenter()
		self:CleanseList()
		local Position = Vector(0,0,0)
		
		for k, v in pairs(self.Melons) do
			Position=Position+v:GetPos()
		end
		
		return Position/table.Count(self.Melons)	
	end
	
	function Squad:UpdateCenter()
		self.Position = self:GetCenter()
	end
	
	table.insert(self.Squads,Squad)
	
	return Squad
end

function TeamAi:ClosestSquad(Position)
	local C,D = nil,999999999
	
	for k, v in pairs(self.Squads) do
		local Dist = v.Position:Distance(Position)
		if Dist<D then
			D = Dist
			C = v
		end
	end
	
	return C,D
end

--Gives orders to the melons under the ai control.
function TeamAi:ManageMelons()
	self.MyTeam:LoopMels("Units",function(i,ent) 
		if ent.IsMiner then
			if not self.Miners[ent] then
				self.Miners[ent]=ent
			end
		else
			if not ent.AISquad then
				local S,D = self:ClosestSquad(ent:GetPos())
				if not S or D>1000 then
					--print("No Squad nearby, Making new one.")
					S = self:CreateSquad()
					S:AddMelon(ent)
					S:UpdateCenter()
				else
					--print("Squad Nearby! Joining it! "..tostring(D))
					S:AddMelon(ent)
				end
			end
		end
	end)
end

function TeamAi:RunCycle()
	self:ManageMelons()
	self:ManageBuildings()
	self:ManageSquads()
end

Singularity.Teams.AIClass = TeamAi











