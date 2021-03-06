local Singularity = Singularity --MAH SPEED
local LoadFile = Singularity.LoadFile --Lel Speed.

Singularity.Entities = {Modules = {},WMHelp = {Incomplete={}}}

local Entities = Singularity.Entities

function Entities.RegisterModule(Name,Type,Data,Base)
	if not Entities.Modules[Type] then
		Entities.Modules[Type]={}
	end
	
	Base.HelpType = Base.HelpType or "Incomplete"
	
	if not Entities.WMHelp[Base.HelpType] then
		Entities.WMHelp[Base.HelpType] = {}
	end
	
	Entities.WMHelp[Base.HelpType][Name] = {N=Data.N,M=Data.M,I=Base.HelpInfo or "There is no Info on this."}
	
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
	--if Data.Info ~= {} then return Data.Info end
	local Info = {}
	
	Info["Health"]=Data.MaxHealth
	if Data.MelonDNA then
		local DNA = Data.MelonDNA
		Info["Move Speed"]= DNA.Speed
		Info["Move Force"]=DNA.Force
		Info["Training Time"]=DNA.TrainTime
		Info["Attack Range"]=DNA.Range
		Info["Attack Damage"]=DNA.Damage
		Info["Attack Rate"]=DNA.AttackRate
		Info["Inventory Capacity"]=DNA.Capacity
	end
	
	return Info
end

function Entities.MakeModule(Data)
	local Name = Data.Name
	local Type = Data.Type or "Generic"
	local Info = Entities.GenerateInfo(Data) Data.Info = Info
	local Mod = {N=Name,T=Type,E=Data.Class,M=Data.MyModel,Sets={},Mods=Data.Extra or {}}
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
local MelPath = ModPath.."melons/"
local ResPath = ModPath.."resources/"
local TactPath = ModPath.."tactical/"
local StraPath = ModPath.."strategic/"

LoadFile(MelPath.."scout.lua",1)
LoadFile(MelPath.."rapid.lua",1)
LoadFile(MelPath.."sniper.lua",1)
LoadFile(MelPath.."heavy.lua",1)
LoadFile(MelPath.."soldier.lua",1)
LoadFile(MelPath.."enginemelon.lua",1)
LoadFile(MelPath.."medic.lua",1)
LoadFile(MelPath.."liftmelon.lua",1)
LoadFile(MelPath.."miner.lua",1)
LoadFile(MelPath.."explosive.lua",1)
LoadFile(MelPath.."drone.lua",1)

LoadFile(TactPath.."sentrybasic.lua",1)
LoadFile(TactPath.."sentrysniper.lua",1)
LoadFile(TactPath.."sentrymedic.lua",1)
LoadFile(TactPath.."noahcannon.lua",1)
LoadFile(TactPath.."nuke.lua",1)

LoadFile(StraPath.."depot.lua",1)
LoadFile(StraPath.."barracks.lua",1)
LoadFile(StraPath.."engine.lua",1)
LoadFile(StraPath.."hover.lua",1)
LoadFile(StraPath.."melhq.lua",1)

LoadFile(ResPath.."melonium.lua",1)
LoadFile(ResPath.."metal.lua",1)

LoadFile(IntPath.."barracks.lua",1)
LoadFile(ModPath.."canister.lua",1)
LoadFile(ModPath.."ainodegen.lua",1)
LoadFile(ModPath.."ainode.lua",1)
LoadFile(ModPath.."pathfinder.lua",1)

LoadFile("singularity/data/helpinfo.lua",1)












