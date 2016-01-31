--[[----------------------------------------------------
MelonThink - Optimizes the melon ai so its not as hard on servers/computers.
----------------------------------------------------]]--

local Singularity = Singularity --Localise the global table for speed.
local Utl = Singularity.Utl --Makes it easier to read the code.

Singularity.MelonThink = Singularity.MelonThink or {Loop="",Melons={},Entities={}}
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
	local LagPrevent = 0
	local status, error = pcall(function()
		for k, v in pairs(IThink.Melons) do
			if IsValid(v.E) then
				if v.E.SlowThink and v.T < CurTime() then
					v.E:SlowThink(IThink.Entities)
					v.T = CurTime()+0.1
				end
				
				if LagPrevent < 20 then
					LagPrevent=LagPrevent+1
				else
					LagPrevent=0
					coroutine.yield()
				end
			else
				IThink.Melons[k]=nil--Remove from the table
			end
		end
	end)
	if error then Singularity.Debug(error,2,"MelonThink Error") end
	
	coroutine.yield()--Make sure it doesnt loop endlessly in a single think.
	IThink.Think()--Restart the Loop....
end

function IThink.RegisterThinker(ent)
	table.insert(IThink.Melons,{E=ent,T=CurTime()+0.1})
end

function IThink.RunThink()
	IThink.CleanTable(IThink.Entities)--Purge any none existant entities from the table.
	coroutine.resume(Singularity.MelonThink.Loop)
end

Singularity.Utl:SetupThinkHook("MelonThinks",0,0,function()
	IThink.RunThink()
end)

function IThink.Initialize()
	Singularity.MelonThink.Loop=coroutine.create(IThink.Think)
end

IThink.Initialize()--Intialize the system.

















