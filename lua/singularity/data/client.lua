local Singularity = Singularity
local Utl = Singularity.Utl --Makes it easier to read the code.

Utl:HookNet("SingEntDatSync","",function(D)
	D.E.SyncData = table.Merge(D.E.SyncData or {},D.T)
	--PrintTable(D.T)
end)

Utl:HookNet("MelonsSyncOrderComplete","",function(D)
	if D.E and IsValid(D.E) then
		if D.E.Orders then
			table.remove(D.E.Orders,1)
		end
	end
end)

function GetWorldTips()
	local Trace = LocalPlayer():GetEyeTrace()
	local Pos = Trace.HitPos
	if EyePos():Distance(Pos) < 512 then
		local TraceEnt = Trace.Entity
		Singularity.TraceEnt=TraceEnt
		
		if TraceEnt.WorldBubble then
			AddWorldTip(1,TraceEnt:WorldBubble(Trace,Pos),1,Pos,NULL)
		end
	else
		Singularity.TraceEnt = nil
    end
end
hook.Add("Think", "GetWorldTips", GetWorldTips)

hook.Add( "PreDrawHalos", "AddHalos", function()
	halo.Add( GetSelectedMelons(), Color( 255, 255, 255 ), 5, 5, 1 )
end )