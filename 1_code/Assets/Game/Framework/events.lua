--[[
Auth:Chiuan
like Unity Brocast Event System in lua.
]]

local EventLib = require "Game.Common.3rd.eventlib.eventlib"

Event = {}
local events = {}
local events_flag={}
function Event.AddListener(event,handler)
	if not event or type(event) ~= "string" then
		error("event parameter in addlistener function has to be string, " .. type(event) .. " not right.")
	end
	if not handler or type(handler) ~= "function" then
		error("handler parameter in addlistener function has to be function, " .. type(handler) .. " not right")
	end

	if not events[event] then
		--create the Event with name
		events[event] = EventLib:new(event)
	end

	events_flag[event]=events_flag[event] or {}
	if events_flag[event][handler] then
		print("error AddListener  repeat !!!   event : "..event)
		print(debug.traceback())
		return 
	else
		events_flag[event][handler]=true
	end
	--conn this handler
	events[event]:connect(handler)
end

function Event.Brocast(event,...)
	if not events[event] then
		-- logWarn("brocast " .. event .. " has no event.")
	else
		-- print("event>>>>>>>","/",event,"/",...,"/")
		events[event]:fire(...)
	end
end

function Event.RemoveListener(event,handler)
	if not events[event] then
		-- error("remove " .. event .. " has no event.")
	else
		events[event]:disconnect(handler)
		if event and events_flag[event] and handler then
			events_flag[event][handler]=nil
		end
	end
end

function Event.IsExist(event)
	if events[event] then
		return true;
	else
		return false;
	end
end

return Event