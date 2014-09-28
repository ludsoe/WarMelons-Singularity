local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.
local Teams = Singularity.Teams
local ENT,PLY = FindMetaTable( "Entity" ),FindMetaTable( "Player" )

if SERVER then
	function MISpawn(ply)
		ply:SetMTeam(Teams.CreateTeam(ply:Nick(),Color(math.random(150,255),math.random(150,255),math.random(150,255),255)))
	
		ply.SelectedMelons = {}
		ply.LastSelect = 0
	end

	function MLeave(ply)
		ply:GetMTeam():RemoveMember(ply)
	end

	Utl:HookHook("PlayerInitialSpawn","MelonsISpawn",MISpawn,1)
	Utl:HookHook("PlayerDisconnected","MelonsLeave",MLeave,1)
end

function PLY:GetMTeam()
	return Teams.Teams[self.MelonTeam]
end

function PLY:SetMTeam(Team)
	Team:AddMember(self)
	self.SelectedMelons = {} --Clear selected melons.
end

function PLY:SelectMelons(Shift,Use)
	local tr = self:GetEyeTrace()
	local Pos,Ent = tr.HitPos,tr.Entity
	local Rad = 500 if Use then Rad = 50 end

	if self.LastSelect > CurTime() then return end
	
	if not Shift then self.SelectedMelons = {} end
	local entz = ents.FindInSphere(Pos,Rad)
	if Ent and IsValid(Ent) then
		if Ent.MelonTeam then
			if Ent.MelonTeam.name==self.MelonTeam then
				self.SelectedMelons[Ent:EntIndex()]=Ent
			end
		end
	else
		for k, v in pairs(entz) do
			if v:GetClass() == "swm_melon" then
				if v.MelonTeam.name==self.MelonTeam then
					self.SelectedMelons[v:EntIndex()]=v
				end
			end
		end
	end
	self.LastSelect=CurTime()+0.1
end

function PLY:OrderMelons(Shift)
	local tr = self:GetEyeTrace()
	local Pos,Ent = tr.HitPos,tr.Entity
	
	if table.Count(self.SelectedMelons) > 0 then
		--DoSoundthingy
		for k, v in pairs(self.SelectedMelons) do
			if v and IsValid(v) then
				if Shift then
					table.insert(v.TargetVec,Pos)
				else
					v.TargetVec={}
					v.TargetVec[1]=Pos
				end
			else
				self.SelectedMelons[k]=nil
			end
		end
	end
end


