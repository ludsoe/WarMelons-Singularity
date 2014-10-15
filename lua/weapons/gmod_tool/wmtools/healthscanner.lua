local Tool = {}
Tool.Open = function(Menu) 
	Menu.Paint = function() end
end --This is clientside only, called when the tool is selected.

Tool.Think = function(ply,Settings)
	if SERVER then
		local ent = ply:GetEyeTrace().Entity
		local heal = Singularity.GetHealth( ent )
		local Old = Settings.OldEnt
		local Oheal = Settings.OldHealth
		if ent ~= Old or heal ~= Oheal then
			Settings.OldEnt = ent
			Settings.OldHealth = heal
			if not ent or not ent:IsValid() then return end
			
			net.Start( "WM_HealthMessage" )
				net.WriteEntity(ent)
				net.WriteFloat(Singularity.GetHealth( ent ))
			net.Send( ply )
			print("Syncing Health")
		end
	end
end

Tool.Holster = function(ply,Settings)
	if SERVER then
		net.Start( "WM_HealthMessage" )
			net.WriteEntity(nil)
			net.WriteFloat(0)
		net.Send( ply )
	else
		UpdateToolTips() 
	end
end

Singularity.MT.AddTool("Health Scanner",Tool)


if SERVER then
	util.AddNetworkString('WM_HealthMessage')
else
	OldHealthEnt = nil
	function UpdateToolTips()
		local ent,health = net.ReadEntity(),net.ReadFloat()
		
		if ent ~= OldHealthEnt then
			if OldHealthEnt and OldHealthEnt:IsValid() then
				OldHealthEnt.ExtraBubble.Health = nil
			end
			OldHealthEnt = ent
		end
		
		if ent and ent:IsValid() then
			if ent.ExtraBubble then
				ent.ExtraBubble["Health"]=health
			else
				ent.ExtraBubble = {Health=health}
			end
		end
	end
	
	net.Receive("WM_HealthMessage", UpdateToolTips)
end























