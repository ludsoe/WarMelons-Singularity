local Tool = {}
Tool.Open = function(Menu) 
	Menu.Paint = function() end
end --This is clientside only, called when the tool is selected.

Tool.Think = function(ply,Settings)
	if SERVER then
		if ply:KeyDown(IN_ATTACK) then
			ply:SelectMelons(ply:KeyDown(IN_SPEED),ply:KeyDown(IN_USE))
		end
	end
end

Tool.Secondary = function(trace,ply,Settings)
	ply:OrderMelons(ply:KeyDown(IN_SPEED))
end

Tool.Holster = function(ply,Settings)
	if SERVER then

	else
	
	end
end

Singularity.MT.AddTool("Melon Orders",Tool)






















