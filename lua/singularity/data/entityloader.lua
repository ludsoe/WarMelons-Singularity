local Singularity = Singularity --MAH SPEED
local LoadFile = Singularity.LoadFile --Lel Speed.

Singularity.Entities = {}
Singularity.Entities.Modules = {}

local Entities = Singularity.Entities

function Entities.RegisterModule(Name,Type,Data,Base)
	if not Entities.Modules[Type] then
		Entities.Modules[Type]={}
	end
	
	Entities.Modules[Type][Name]={M=Data,E=Base}
end

function Entities.CompileSetting(Name,Default)
	local Data = {
		ID = Name,
		Type = type(Default),
		Value = Default
	}
	return Data
end

function Entities.GenerateInfo(Data)
	if Data.Info ~= {} then return Data.Info end
	local Info = {}
	
	return Info
end

function Entities.MakeModule(Data)
	local Name = Data.Name
	local Type = Data.Type or "Generic"
	local Info = Entities.GenerateInfo(Data)
	local Mod = {N=Name,T=Type,E=Data.Class,M=Data.MyModel,Sets={},Info=Info or {},Mods=Data.Extra or {}}
	if Data.Propertys then
		for k,v in pairs(Data.Propertys) do
			if v.ID then
				Mod.Sets[k]=v
			else
				Mod.Sets[v.Name]=Entities.CompileSetting(v.Name,v.Value)
			end
		end
	end
	Entities.RegisterModule(Name,Type,Mod,Data)
	print("Registered: "..Name.." as a "..Type)
end

--Ship Modules.
local ModPath = "singularity/data/entities/"
local IntPath = "singularity/data/userinterfaces/"

LoadFile(ModPath.."melon.lua",1)
LoadFile(ModPath.."barracks.lua",1)

LoadFile(IntPath.."barracks.lua",1)














