local Tool = {}
Tool.Open = function(Menu,Tab) 
	Menu.Paint = function() end
end --This is clientside only, called when the tool is selected.

Tool.Primary = function(trace,ply,Settings)
	local traceent = trace.Entity
	
	if not traceent or not IsValid(traceent) then return false end
	
	local Locale = {}
	
	Locale.E = traceent:GetClass()
	Locale.M = traceent:GetModel()
	Locale.P = traceent:GetPos()
	Locale.A = traceent:GetAngles()
	
	Data = util.TableToJSON(Locale)
	
	file.Append( "localiseoutput.txt", Data )
	
	return true
end --Serverside primary fire
Tool.Think = function(ply,Settings) end --Think Function use CLIENT and SERVER to create client and server only thinks.
Singularity.MT.AddTool("Localizer",Tool)

