local basefunc = require "Game/Common/basefunc"

PDKActivityManager = basefunc.class()
local M = PDKActivityManager
M.key = "pdk_activity"
local config = GameButtonManager.ExtLoadLua(M.key, "activity_task_gold_pdk")
local lister
local function MakeLister()
    lister = {}
    lister["UpdateHallTaskRedHint"] = M.CheakStatus
end
function M.CheckIsShow()
	return true
end

function M.GotoUI(parm)
	dump(parm)
    if parm.goto_scene_parm == "enter" then
        return ActivityTaskPanel.Create(parm.parent,parm.cfg,nil, config)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.CheakStatus()
    if GameTaskModel.check_reward_state(21030,5) then 
        GameActivityManager.on_ui_activity_state_msg({key="ID_100",state=ACTIVITY_HINT_STATUS_ENUM.AT_Get})
    else
        GameActivityManager.on_ui_activity_state_msg({key="ID_100",state=ACTIVITY_HINT_STATUS_ENUM.AT_Nor})
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

function M.Init()
    M.Exit()
    MakeLister()
    AddLister()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.GetHintState(parm)
    if GameTaskModel.check_reward_state(21030,5) then 
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor   
    end 
end