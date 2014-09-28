-- 0 Client 1 Shared 2 Server
function Singularity.LoadFile(Path,Mode)
	Mode=Mode or 1
	if SERVER then
		if Mode >= 1 then
			if Mode == 1 then
				AddCSLuaFile(Path)
			end
			include(Path)
		else
			AddCSLuaFile(Path)
		end
	else
		if Mode <= 1 then
			include(Path)
		end
	end
end