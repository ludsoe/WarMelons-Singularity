function ENT:BuildDupeData()
	local Data = self.InitData or {}
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
	if Ent.EntityMods and Ent.EntityMods.JupiterModule then
		self:Compile(Ent.EntityMods.JupiterModule,Player)
	end
	
    Ent.Owner = Player
    if WireLib and (Ent.EntityMods) and (Ent.EntityMods.WireDupeInfo) then
        WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
    end
end
