local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan 

function ENT:SetOrders(O)
	self:TransClearOrders()
	self.Orders = table.Copy(O)
	self:TransmitOrders()
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

function ENT:GetOrders()
	return self.Orders or {}
end

function ENT:ClearOrders()
	self.Orders = {}
	self.SyncedOrders={}
	self:TransClearOrders()
end

function ENT:TransmitOrders()
	local Data = table.Copy(self.Orders) --Create a copy of the sync data table so we dont mess with the real one.
	local Transmit = {}
	
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




