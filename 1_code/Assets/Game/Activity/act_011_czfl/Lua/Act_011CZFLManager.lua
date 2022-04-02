local basefunc = require "Game/Common/basefunc"

Act_011CZFLManager = basefunc.class()
local M = Act_011CZFLManager
M.key = "act_011_czfl"
local config1 = GameButtonManager.ExtLoadLua(M.key, "act_011_czfl_config1")
local config2 = GameButtonManager.ExtLoadLua(M.key, "act_011_czfl_config2")
local lister
local task_ids
local task_ids1
local task_ids2
M.now_level = 0
local permisstions = {
    "actp_own_task_p_revaluation_rebate_1",
    "actp_own_task_p_revaluation_rebate_2",
}

local function MakeLister()
    lister = {}
    lister["UpdateHallTaskRedHint"] = M.CheakStatus
    lister["model_query_task_data_response"] = M.Refresh_Status
    lister["model_task_change_msg"] = M.Refresh_Status
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
end
function M.CheckIsShow()
    if M.IsActive() then
        return true
    end
end

function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1589817599
    local s_time = 1589239800
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end
    -- 对应权限的key
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="p_revaluation_rebate", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    if M.GetNowPerMiss() then 
        return true
    end
end

function M.GetNowPerMiss()
    local cheak_fun = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        else
            return false
        end
        return true
    end
    M.now_level = nil
    for i = 1,#permisstions do 
        if cheak_fun(permisstions[i]) then
            dump(permisstions[i],"符合条件的权限")
            M.now_level = i  
            return i
        end
    end
end

function M.GotoUI(parm)
    dump(parm)
    if not M.IsActive() then return end
    if parm.goto_scene_parm == "panel" then
        if M.now_level == 1 then
            return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil, config1)
        elseif M.now_level == 2 then
            return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil, config2)
        end
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
    task_ids1 = M.GetTaskIDS(config1)
    task_ids2 = M.GetTaskIDS(config2)
    -- dump(task_ids1,"<color=green>++++++++task_ids1++++++++++</color>")
    -- dump(task_ids2,"<color=green>++++++++task_ids2++++++++++</color>")
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
    if M.IsActive() then
        return true
    end
end

function M.GetTaskIDS(config)
    local task_ids = {}
    for i=1,#config.tge1 do
        task_ids[#task_ids + 1] = config.tge1[i].task
    end
    return task_ids
end



function M.IsAwardCanGet()
    if M.now_level == 1 then
        if task_ids1 then 
            for i=1,#task_ids1 do
                local d = GameTaskModel.GetTaskDataByID(task_ids1[i])
                if d then 
                    if d.award_status == 1 then 
                        return true
                    end 
                end 
            end
        end
    end
    if M.now_level == 2 then
        if task_ids2 then 
            for i=1,#task_ids2 do
                local d = GameTaskModel.GetTaskDataByID(task_ids2[i])
                if d then 
                    if d.award_status == 1 then 
                        return true
                    end 
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

--[[
    GetTexture("cxczsdl_bg_1")
]]