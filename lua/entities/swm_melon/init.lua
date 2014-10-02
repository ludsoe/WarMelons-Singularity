AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:BSSetup(Data,ply)
	self:ClearOrders()
end

function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function ENT:LineOfSight(Vec,Ent)
	local tr = util.TraceLine({start = self:GetPos(),endpos = Vec,filter = self} )
	local Hit,HitEnt = tr.Hit,tr.Entity
	
	if not Hit then
		return true
	else
		if IsValid(Ent) and IsValid(HitEnt) and Ent==HitEnt then
			return true
		else
			return false
		end
	end
end

function ENT:DrawAttack(S,E)
	local effectdata = EffectData()
		effectdata:SetOrigin(S+Vector(0,0,5))
		effectdata:SetStart(E+Vector(0,0,0))
		effectdata:SetEntity(self)
	util.Effect( "attack_beam", effectdata )
end

function ENT:Attack(Ent)
	local EPos = Ent:GetPos()
	if not Ent or not IsValid(Ent) then return end
	local Distance = self:GetPos():Distance(Ent:GetPos())
	if self:LineOfSight(EPos,Ent) and Distance<self.DNA.Range then
		if self.Times.Attack < CurTime() then
			Singularity.DealDamage(Ent,EPos,self.DNA.Damage,self,self)
			self.Times.Attack=CurTime()+self.DNA.AttackRate
			self:DrawAttack(self:GetPos(),Ent:GetPos())
		end
	else
		if Distance>self.DNA.Range*2 then
			self.Enemy = nil
		end
	end
end

function ENT:ScanEnemys()
	if self.Times.Scan < CurTime() then
		local entz = ents.FindInSphere(self:GetPos(),self.DNA.Range*2)
		for k, v in pairs(entz) do
			if v.MelonTeam and not v:IsPlayer() then
				if v.MelonTeam~=self.MelonTeam then
					if self:LineOfSight(v:GetPos(),v) then
						self.Enemy = v
						break
					end
				end
			end
		end
		self.Times.Scan=CurTime()+0.2
	end
end

local MoveRange = 50
function ENT:ManageMovement(Pos)
	local angle1 = Pos - self:GetPos()
	if self:GetPos():Distance(Pos)>MoveRange then
		self:GetPhysicsObject():SetDamping(2, 0)
		if self:GetVelocity():Length() < self.DNA.Speed then
			self:GetPhysicsObject():ApplyForceCenter(Normalize(angle1) * self.DNA.Force)
		end
	else
		return true
	end
	return false
end

function ENT:RunOrders()
	if table.Count(self.Orders)>0 then
		for k, v in pairs(self.Orders) do
			local Completed = false
			if v.T == "Goto" then
				Completed = self:ManageMovement(v.V)
			end
			
			if Completed then
				self:RemoveOrder(k)
			else
				break
			end
		end
	else
		if self.Enemy and IsValid(self.Enemy) then
			self:ManageMovement(self.Enemy:GetPos()+(Normalize(self:GetPos()-self.Enemy:GetPos())*(self.DNA.Range/2)))
		else
			self.Enemy = nil
		end
	end
end

function ENT:AddOrder(O)
	O.ID=CurTime()/200
	table.insert(self.Orders,O)
	self:TransmitOrders()
end

function ENT:RemoveOrder(ID)
	self.Orders[ID]=nil
	self.SyncedOrders[ID]=nil
	self:TransOrderComplete()
end

function ENT:ClearOrders()
	self.Orders = {}
	self.SyncedOrders={}
	self:TransClearOrders()
end

function ENT:WanderAI()

end

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan 

function ENT:TransmitOrders()
	local Data = table.Copy(self.Orders) --Create a copy of the sync data table so we dont mess with the real one.
	local Transmit = {}
	
	--{Name="example",Val=1,Dat={{N="D",T="S",V="example"}}}
	for n, v in pairs( self.SyncedOrders ) do --Update our existing data first.
		if v.ID ~= Data[n].ID then --If Data doesnt match
			self.SyncedOrders[n] = {V=Data[n],C=true} --Set it to the new value and mark as changed.
			Transmit[n] = Data[n]
		else
			v.C = false --Mark It unchanged.
		end
		Data[n]=nil --Remove pre parsed data to make the next part faster.
	end
	
	for n, v in pairs( Data ) do --Lets mark down the new data.
		if not self.SyncedOrders[n] then
			self.SyncedOrders[n] = {ID=v.ID,V=v,C=true} --Tell the data its got to be sent.
			Transmit[n] = v
		end
	end
	
	if table.Count(Transmit)>=1 then
		NDat.AddDataAll({
			Name="MelonsSyncOrders",
			Val=5,
			Dat={{N="E",T="E",V=self},{N="T",T="T",V=Transmit}}
		})
	end
end

function ENT:TransClearOrders()
	NDat.AddDataAll({
		Name="MelonsClearOrders",
		Val=1,
		Dat={{N="E",T="E",V=self}}
	})
end

function ENT:TransOrderComplete()
	NDat.AddDataAll({
		Name="MelonsSyncOrderComplete",
		Val=1,
		Dat={{N="E",T="E",V=self}}
	})
end