local basefunc = require "Game.Common.basefunc"

TLOG = {}

local this -- µ¥Àý
local lister = {}
local function AddLister()
	lister={}
	lister["trace_level_fight_msg"] = this.trace_level_fight_msg
	lister["trace_honor_msg"] = this.trace_honor_msg
	lister["trace_task_msg"] = this.trace_task_msg
	for msg, cbk in pairs(lister) do
		Event.AddListener(msg, cbk)
	end
end

local function RemoveLister()
	for msg, cbk in pairs(lister) do
		Event.RemoveListener(msg, cbk)
	end
	lister={}
end

function TLOG.Init()
	TLOG.Exit()

	this = TLOG
	AddLister()
	return this
end

function TLOG.Exit()
	RemoveLister()
	this = nil
end

function TLOG.trace_level_fight_msg(data)
	local tlog = {
		event_id = "1", level = tostring(data.level), fight_value = tostring(data.fight_value)
	}
	Network.SendPostLOG(tlog, function(code)
		print("[TLOG] trace common retcode:" .. code)
	end)
end

function TLOG.trace_task_msg(data)
	--TLOG
	local tlog = {
		event_id = "2", task_id = tostring(data.task_id), task_name = data.task_name, status = data.status
	}

	Network.SendPostLOG(tlog, function(code)
		print("[TLOG] trace task retcode:" .. code)
	end)
end

function TLOG.trace_honor_msg(data)
	local tlog = {
		event_id = "3", honor_id = tostring(data.honor_id), honor_name = "VIP_" .. data.vip_level
	}
	Network.SendPostLOG(tlog, function(code)
		print("[TLOG] trace honor retcode:" .. code)
	end)
end
