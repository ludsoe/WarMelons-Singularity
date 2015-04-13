local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

local TeamAi = {
	MyTeam = {},
	Squads = {},
	Miners = {},
	QueuedMelons = {},
	SuperWeps={Noah={},BigBoy={}},
	SetupProperly = false
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
		
		if ent.NoahCannon then
			self.SuperWeps.Noah[ent]=ent
			
			if ent.LastOrder or 0 < CurTime() then
				--print("Issuing Order!")
				ent.LastOrder = CurTime()+3
				local Target = self:FindBase(ent:GetPos()) or self:FindTarget(ent:GetPos())
				if Target and IsValid(Target) then
					ent:ClearOrders()
					ent:AddOrder({T="Fire",V=Target:GetPos()})
				end
			end
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
			
			--print(tostring(v.Type))
		
			if v.Status == 1 then
				local Count = table.Count(v.Melons)
				--print("Building Up! ")
				--PrintTable(v.Melons)
				if Count > v.Cap or v.Birth>CurTime() then
					v.Status = 2
				end
			else
				if v.Type >= 8 then
					if not v.Target or not IsValid(v.Target) then
						v.NoahCheck=(v.NoahCheck or 0)+1
						if v.NoahCheck>5 then v.Type = 1 end
						
						v.Target = self:FindNoah()
						
						--print("Noah: "..tostring(v.Target))
						
						v:OrderMelons(v.Position)
						
						continue
					end			
					
					if v.LastOrder < CurTime() then
						--print("Issuing Order!")
						v.LastOrder = CurTime()+3
						v:OrderMelons(v.Target:GetPos(),v.Target)
					end
				else
					if not v.Target or not IsValid(v.Target) then
						--print("Finding target!")
						if v.Type<=4 then
							v.Target = self:FindTarget(v.Position)
						else
							v.Target = self:FindBase(v.Position) or self:FindTarget(v.Position)
						end
						
						v:OrderMelons(v.Position)
						
						continue
					end
									
					if v.LastOrder < CurTime() then
						--print("Issuing Order!")
						v.LastOrder = CurTime()+3
						v:OrderMelons(v.Target:GetPos())
					end
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
		Target = nil,
		Cap = math.random(5,12),
		Type = math.random(1,12),
		Birth = CurTime()+30,
		PathStatus = "NotExist",
		PathDatCache = {},
		Pathing = false
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
	
	function Squad:OrderMelons(Pos,Ent)
		self:CleanseList()
		
		--print("Giving Orders!")
		
		local Path = {}
		
		--If Available, generate a path.
		if table.Count(Singularity.AI.Nodes)>0 then
			self.PathStatus,Path = Singularity.PathFinder.FindPath(self.PathDatCache.Start or self.Position,self.PathDatCache.Goal or Pos)
			if self.PathStatus == "Pathing" then
				if not self.Pathing then
					self.PathDatCache={Start=self.Position,Goal=Pos}
					self.PathTimeOut = CurTime()+20
					self.Pathing = true
				end	
				
				if self.PathTimeOut<CurTime() then
					self.PathDatCache = {}
					self.PathStatus = "NotExist"
					Path = {}
					self.Pathing = false
				--	print("Path Timed out....")
				else
					return --Path isnt finished yet...
				end
			else
				self.PathDatCache = {}
				self.Pathing = false
				--print("Path found!")
			end
			Path = Path or {}
		end
		
		for k, v in pairs(self.Melons) do
			v:ClearOrders()
			
			if table.Count(Path)>0 then
				for n, p in pairs(Path) do
					if n == 1 then continue end
					v:AddOrder({T="Goto",V=p},true)
				end
			end
			
			if Ent and IsValid(Ent) then
				v:AddOrder({T="Enter",V=Ent:GetPos(),E=Ent},true)
			else
				v:AddOrder({T="Goto",V=Pos},true)
			end
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
		if v.Status == 1 then --Only Give Orders to Groups that are building up.
			local Dist = v.Position:Distance(Position)
			if Dist<D then
				D = Dist
				C = v
			end
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
				if not S or D>500 then
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

function TeamAi:InstallAi()
	local MyTeam =  self.MyTeam
	
	MyTeam:SetDefaultDiplomacy(false)
	
	self.SetupProperly = true
end

function TeamAi:RunCycle()
	if not self.SetupProperly then
		self:InstallAi()
	end
	self:ManageSquads()
	self:ManageMelons()
	self:ManageBuildings()
end

function TeamAi:FindNoah()
	--PrintTable(self.SuperWeps)
	
	for k, v in pairs(self.SuperWeps.Noah) do
		if v and IsValid(v) then
			return v
		else
			self.SuperWeps.Noah[K]=nil
		end
	end
end

function TeamAi:FindTarget(Pos)
	--local entz = ents.FindInSphere(Pos,30000)
	--for k, v in pairs(entz) do
	--print("Finding Target!")
	for ti, t in pairs(Singularity.Teams.Teams) do
		local MyRelation = self.MyTeam:GetRelations(t)
		--print(t.name.." "..MyRelation)
		if MyRelation == "Hostile" and not t:IsHidden() then
			for k, v in pairs(t.Melons.Units) do
				local Ent = v.E
				if not Ent or not IsValid(Ent) then t.Melons.Units[k]=nil continue end
				if self.MyTeam:CanAttack(Ent) then
					return Ent
				end
			end
		end
	end
end

function TeamAi:FindBase(Pos)
	--local entz = ents.FindInSphere(Pos,30000)
	--for k, v in pairs(entz) do
	--print("Finding Base!")
	for ti, t in pairs(Singularity.Teams.Teams) do
		local MyRelation = self.MyTeam:GetRelations(t)
		--print(t.name.." "..MyRelation)
		if MyRelation ~= "Allied" and not t:IsHidden() then
			for k, v in pairs(t.Melons.Buildings) do
				local Ent = v.E
				if not Ent or not IsValid(Ent) then t.Melons.Buildings[k]=nil continue end
				if self.MyTeam:CanAttack(Ent) then
					if Ent.NoahCannon or Ent.IsBarracks or Ent.SuperWeapon then
						return Ent
					end
				else
					if Ent.NoahCannon or Ent.SuperWeapon then
						self.MyTeam:MakeEnemy(t,false) 
						return Ent
					end
				end
			end
		end
	end
end

Singularity.Teams.AIClass = TeamAi











