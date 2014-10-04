local Tool = {}

local Help = {
"---------Left Click:---------",
"OnGround: Area Select",
"OnEntity: Select Entity",
"",
"---------Right Click:--------",
"Anywhere: Order Selected to that position.",
"",
"---------Extra Tips:--------",
"Hold Shift While selecting melons to add them to your existing selection.",
"Holding Shift while issuing orders, queues up the orders.",
"Holding Use [Aka E] while clicking on a contraption selects all entitys welded to it.",
"You can give a Barracks orders, and melons produced by it will inherit those orders."
}

Tool.Open = function(Menu) 
	Menu.Paint = function() end
	
	local Mod =Singularity.MT.AddModular(Menu,520)
	
	for k,v in pairs(Help) do
		Singularity.MT.ModAddlabel(Mod,v,5)
	end
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






















