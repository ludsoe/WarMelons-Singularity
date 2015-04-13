local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan 
local QO = Singularity.QO

function ENT:SetOrders(O)
	self.Orders = table.Copy(O)
	QO.QueueOrders(self,self.Orders)
end

function ENT:AddOrder(O,I)
	if self.OrderChange then self.OrderChange(O) end
	O.ID=math.random(1,3000)
	O.NoSync = I or false
	table.insert(self.Orders,O)
	QO.QueueOrders(self,self.Orders)
end

function ENT:RemoveOrder(ID)
	self.Orders[ID]=nil
	self.SyncedOrders[ID]=nil
	QO.QueueOrders(self,self.Orders)
end

function ENT:GetOrders()
	return self.Orders or {}
end

function ENT:ClearOrders()
	self.Orders = {}
	self.SyncedOrders={}
	QO.QueueOrders(self,self.Orders)
end

local function Normalize(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

function ENT:RunOrders()
	if table.Count(self.Orders)>0 then
		for k, v in pairs(self.Orders) do
			local Completed = false
			if self.OrderFuncs[v.T] then
				Completed = self.OrderFuncs[v.T](self,v)
			else
				Completed = true
			end
			
			if Completed then
				self:RemoveOrder(k)
			else
				break
			end
		end
	else
		if self.Target and IsValid(self.Target) then
			if self.ManageMovement then
				self:ManageMovement(self.Target:GetPos()+(Normalize(self:GetPos()-self.Target:GetPos())*(self.DNA.Range/2)))
			end
		else
			self.Target = nil
		end
	end
end




