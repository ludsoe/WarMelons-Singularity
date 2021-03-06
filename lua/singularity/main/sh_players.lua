local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local Teams,NDat = Singularity.Teams,Utl.NetMan 
local ENT,PLY = FindMetaTable( "Entity" ),FindMetaTable( "Player" )

local Develpers = {
"STEAM_0:1:21922427",--Spudsoe
"STEAM_0:1:23264416"--Mechanos
}

if SERVER then
	function MISpawn(ply)
		ply.SelectedMelons = {}
		ply.SyncedMelons = {}
		ply.LastSelect = 0
		
		timer.Create(ply:Nick().."TCreate",1,1,function()
			ply:MakeMTeam()
		end)
		
		--Mark Developers with a special variable!
		for k, v in pairs(Develpers) do
			if ply:SteamID() == v then
				ply.WarMelonDeveloper = true
			end
		end
	end

	function MLeave(ply)
		ply:GetMTeam():RemoveMember(ply)
	end

	Utl:HookHook("PlayerInitialSpawn","MelonsISpawn",MISpawn,1)
	Utl:HookHook("PlayerDisconnected","MelonsLeave",MLeave,1)
	util.AddNetworkString('SelectedMelons')
else

function GetSelectedMelons() return LocalPlayer().SelectedMelons or {} end

Utl:HookNet("SelectedMelons","",function(D)
	local Selected = LocalPlayer().SelectedMelons or {}

	for k, v in pairs(D.T) do
		if v.A == "Add" then
			Selected[v.K]=Entity(v.K)
		elseif v.A == "Remove" then
			Selected[v.K]=nil
		end
	end

	LocalPlayer().SelectedMelons = Selected
end)

end

function PLY:MakeMTeam()
	local VC = self:GetPlayerColor()
	local Col = Color((VC.x*255),(VC.y*255),(VC.z*255),255)
	local PlyTeam = Teams.CreateTeam(self:Nick(),Col)
	self:SetMTeam(PlyTeam)
	
	PlyTeam:LockTeam()
end

function PLY:GetMTeam()
	return Teams.Teams[self.MelonTeam]
end

function PLY:SetMTeam(Team)
	Team:AddMember(self)
	self:ClearSelectedMelons() --Clear selected melons.
end

function PLY:SyncSelected()
	local Melons,Sync = self.SelectedMelons,self.SyncedMelons
	local Transmit = {}
	
	--print("Syncing")
	
	for k, v in pairs(Sync) do
		if Melons[k]==nil or not IsValid(Melons[k]) then
			Transmit[k]={A="Remove",K=k}
			Sync[k]=nil
		end
	end
	
	for k, v in pairs(Melons) do
		if Sync[k]==nil then
			Sync[k]=v
			Transmit[k]={A="Add",K=k}
		end
	end
	
	if table.Count(Transmit)>=1 then
		local Send = {
			Name="SelectedMelons",
			Val=1,
			Dat={E=self,T=Transmit}
		}
		NDat.AddData(Send,self)
	end
end

function PLY:ClearSelectedMelons(NoSync)
	self.SelectedMelons = {}
	if not NoSync then
		self:SyncSelected()
	end
end

function PLY:ContraptionSelect(Ent)
	local Ents = constraint.GetAllConstrainedEntities_B( Ent )
	
	for k, v in pairs( Ents ) do
		if v.MelonTeam and v.MelonOrders then
			if v.MelonTeam.name==self.MelonTeam then
				self.SelectedMelons[v:EntIndex()]=v
			end
		end
	end
end

function PLY:SelectMelons(Shift,Use)
	local tr = self:GetEyeTrace()
	local Pos,Ent = tr.HitPos,tr.Entity
	local Rad = 100 if Use then Rad = 50 end

	if self.LastSelect > CurTime() then return end
	
	if not Shift then self:ClearSelectedMelons(true) end
	--print("Selectig")
	if Ent and IsValid(Ent) then
		if Use then
			--print("Contraption select")
			self:ContraptionSelect(Ent)
		else
			if Ent.MelonTeam and Ent.MelonOrders then
				if Ent.MelonTeam.name==self.MelonTeam then
					self.SelectedMelons[Ent:EntIndex()]=Ent
				end
			end		
		end
	else
		local entz = ents.FindInSphere(Pos,Rad)
		for k, v in pairs(entz) do
			if v:GetClass() == "swm_melon" then
				if v.MelonTeam.name==self.MelonTeam then
					self.SelectedMelons[v:EntIndex()]=v
				end
			end
		end
	end
	self.LastSelect=CurTime()+0.1
	self:SyncSelected()
end

function PLY:OrderSelection(v,Ent,Pos)
	if v.NoahCannon or v.SuperWeapon then
		v:AddOrder({T="Fire",V=Pos})
		return
	end
	
	if Ent and IsValid(Ent) then
		if Ent.MelonTeam == v.MelonTeam then
			if Ent.MelonLoadable then
				if v.IsBarracks or v.IsMelon then
					v:AddOrder({T="Enter",V=Ent:GetPos(),E=Ent})
					return
				end
			end
		end
	end
	
	if v.IsBarracks or v.IsMelon or v.MovementOrderable then
		v:AddOrder({T="Goto",V=Pos})
	end
end

function PLY:LoopMelons(Function)
	if table.Count(self.SelectedMelons) > 0 then
		for k, v in pairs(self.SelectedMelons) do
			if v and IsValid(v) then
				Function(self,k,v)
			else
				self.SelectedMelons[k]=nil
			end
		end
	end
end

function PLY:OrderMelons(Pos,Ent)
	local Shift,Use = self:KeyDown(IN_SPEED),self:KeyDown(IN_USE)
	
	self:LoopMelons(function(self,k,v)
		if Use then
			v:ClearOrders()
		else
			if not Shift then v:ClearOrders() end
			self:OrderSelection(v,Ent,Pos)
		end
	end)
	
	self:SyncSelected()
end


