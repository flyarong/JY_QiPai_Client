local basefunc = require "Game/Common/basefunc"

CzsnhManager = basefunc.class()
local M = CzsnhManager
M.key = "act_czsnh"
local config = GameButtonManager.ExtLoadLua(M.key, "activity_task_yearend_recharge_config")
local lister
local Task_Ids
local function MakeLister()
    lister = {}
    lister["UpdateHallTaskRedHint"] = M.CheakStatus
    lister["model_query_task_data_response"] = M.Refresh_Status
    lister["model_task_change_msg"] = M.Refresh_Status
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
    Task_Ids = M.GetTaskIDS(config)
    MakeLister()
    AddLister()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
end

function M.CheckIsShowInActivity(parm)
   return true
end

function M.GetTaskIDS(C)
    local _r = {}  
    local _t = M.get_task_id(C)
    for k, v in pairs(_t) do
        _r[#_r + 1] = k
    end
    return _r
end

function M.get_task_id(_config,_t)
    _t = _t or {}
    for k, v in pairs(_config) do
        if type(v) == "table" then
            M.get_task_id(v,_t)
        else
            if k == "task" then
                _t[v] = 1
            end
        end
    end
    return _t
end

function M.IsAwardCanGet()
    local _b = Task_Ids
    if _b then 
        for i=1,#_b do
            local d = GameTaskModel.GetTaskDataByID(_b[i])
            if d then 
                if d.award_status == 1 then 
                    return true
                end 
            end 
        end
    end
    return false
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end