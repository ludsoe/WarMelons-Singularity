--[[----------------------------------------------------
MelonThink - Optimizes the melon ai so its not as hard on servers/computers.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

Singularity.MelonThink = Singularity.MelonThink or {Melons={},Entities={}}
local IThink = Singularity.MelonThink

--Melons table is entities that require the optimized think function.
--Entities table is a list of entities that warmelons can interact with.

function IThink.CleanTable(tab)
	for k, v in pairs(tab) do
		if not IsValid(v) then
			tab[k]=nil--Remove the listing from the table.
		end
	end
end

function IThink.Think()
	xpcall(function()
		local LagPrevent = 0
		for k, v in pairs(IThink.Melons) do
			if IsValid(v.E) then
				if v.E.SlowThink and v.T < CurTime() then
					v.E:SlowThink(IThink.Entities)
					v.T = CurTime()+0.1
				end
			else
				table.remove(IThink.Melons,k)--Remove from the table
			end
			
			if LagPrevent < 20 then
				LagPrevent=LagPrevent+1
			else
				LagPrevent=0
				coroutine.yield()
			end
		end
	end,
	function(err)
		Singularity.Debug(err,2,"MelonThink Error")
	end)
	
	coroutine.yield()--Make sure it doesnt loop endlessly in a single think.
end

function IThink.RegisterThinker(ent)
	--MsgAll("Registering "..tostring(ent).." as a thinker!")
	table.insert(IThink.Melons,{E=ent,T=CurTime()+0.1})
end

function IThink.RunThink()
	IThink.CleanTable(IThink.Entities)--Purge any none existant entities from the table.
	
	local MelonMaster = Singularity.MelonThink.Loop
	if not MelonMaster then
		Singularity.MelonThink.Loop = coroutine.create(IThink.Think)
	else
		local Status = coroutine.status(MelonMaster)
		--MsgAll(tostring(Status).." \n")
		if Status=="dead" then
			Singularity.MelonThink.Loop = coroutine.create(IThink.Think)
		else
			coroutine.resume(MelonMaster)
		end
	end
		
	coroutine.resume(Singularity.MelonThink.Loop)
end

Singularity.Utl:SetupThinkHook("MelonThinks",0,0,function()
	IThink.RunThink()
end)

function IThink.Initialize()
	Singularity.MelonThink.Loop=coroutine.create(IThink.Think)
end

--IThink.Initialize()--Intialize the system.
















