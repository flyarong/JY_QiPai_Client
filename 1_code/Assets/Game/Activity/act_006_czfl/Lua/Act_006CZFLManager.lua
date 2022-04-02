local basefunc = require "Game/Common/basefunc"

Act_006CZFLManager = basefunc.class()
local M = Act_006CZFLManager
M.key = "act_006_czfl"
local config = GameButtonManager.ExtLoadLua(M.key, "act_006_czfl_config")
local lister
local task_ids
local function MakeLister()
    lister = {}
    lister["UpdateHallTaskRedHint"] = M.CheakStatus
    lister["model_query_task_data_response"] = M.Refresh_Status
    lister["model_task_change_msg"] = M.Refresh_Status
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
end
function M.CheckIsShow()
    return true
end

function M.GotoUI(parm)
    dump(parm)
    if parm.goto_scene_parm == "panel" then
        return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil, config)
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
    MakeLister()
    AddLister()
    task_ids = M.GetTaskIDS(config)
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
end

function M.CheckIsShowInActivity(parm)
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_own_task_p_revaluation_rebate", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
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
    if task_ids then 
        for i=1,#task_ids do
            local d = GameTaskModel.GetTaskDataByID(task_ids[i])
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

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
end
