function ENT:BuildDupeData()
	local Data = self.InitData or {}
	
	--Incase Classes need to change that.
	if self.OnBuildDupeData then
		self:OnBuildDupeData(Data)
	end
	
	return Data
end

function ENT:OnRestore()
	if WireLib then WireLib.Restored(self) end
end

function ENT:PreEntityCopy()
	local Data = self:BuildDupeData()
	duplicator.StoreEntityModifier( self, "JupiterModule", Data )
	
    if WireLib then
		local DupeInfo = WireLib.BuildDupeInfo(self)
        if DupeInfo then
            duplicator.StoreEntityModifier( self, "WireDupeInfo", DupeInfo )
        end
    end
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if not Ent.EntityMods then return end
	if Ent.EntityMods.JupiterModule then
		self.MelonTeam = Player:GetMTeam()
		self:Compile(Ent.EntityMods.JupiterModule,Player)
		
		self:TransmitData()
	end
	
    Ent.Owner = Player
    if WireLib and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
        WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
    end
end

function ENT:OnEntityCopyTableFinish(data)
	--Clear Junk Data Out to reduce dupe size.
	data.MelonTeam = nil
	data.LSSOwner = nil
	data.SyncData = {}
	data.OldData = {}
	data.Target = nil
	data.Orders = {}
	data.SyncedOrders = {}
	
	--Incase Classes need to change that.
	if self.OnEntityCopyFinish then
		self:OnEntityCopyFinish(data)
	end	
end