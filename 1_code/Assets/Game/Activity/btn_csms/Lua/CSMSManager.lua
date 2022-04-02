local basefunc = require "Game/Common/basefunc"
CSMSManager = {}
local M = CSMSManager
M.key = "btn_csms"

local lister
local m_data
local s_time = - 1
GameButtonManager.ExtLoadLua(M.key, "CSMSEnterPrefab")
function M.CheckIsShow()
	return true
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "enter" then
		return CSMSEnterPrefab.Create(parm.parent)
    else 
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local function AddLister()
    for msg, cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg, cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister = nil
end

local function MakeLister()
	lister = {}
end

function M.Init()
    M.Exit()
    m_data = {}
    MakeLister()
    AddLister()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end
