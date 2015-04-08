local Tool = {}

local Help = {
"---------Left Click:---------",
"OnGround: Area Select",
"OnEntity: Select Entity",
"",
"---------Right Click:--------",
"Anywhere: Order Selected to that position.",
"While Holding Use [Aka E], RightClick anywhere to clear orders.",
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
		local tr = ply:GetEyeTrace()
		local Pos,Ent = tr.HitPos,tr.Entity
		
		if ply:KeyDown(IN_ATTACK) then
			ply:SelectMelons(ply:KeyDown(IN_SPEED),ply:KeyDown(IN_USE))
		end
		
		if ply:KeyDown(IN_ATTACK2) then
			if not ply.OrderGive then
				ply.OrderGive = true
				ply.OrderStart = Pos
				ply.OrderTime = CurTime()+0.1
				ply.Change = nil
			else
				if ply.OrderTime < CurTime() then
					local PlyPos = ply:GetPos()
					ply.Change = (Pos:Distance(PlyPos)-ply.OrderStart:Distance(PlyPos))
					print(tostring(ply.Change))
				end
			end
		else
			if ply.OrderGive then
				ply.OrderGive = false
				ply:OrderMelons(ply.OrderStart+Vector(0,0,(ply.Change or 0)),Ent)
			end
		end
	end
end

Tool.Holster = function(ply,Settings)
	if SERVER then

	else
	
	end
end

Singularity.MT.AddTool("Melon Orders",Tool)






















