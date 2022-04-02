-- 创建时间:2020-11-09
-- Act_039_LGFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_039_LGFLManager = {}
local M = Act_039_LGFLManager
M.key = "act_039_lgfl"
local config_01 = GameButtonManager.ExtLoadLua(M.key,"act_039_lgfl_config_01")
local config_02 = GameButtonManager.ExtLoadLua(M.key,"act_039_lgfl_config_02")

local this
local lister
local now_level = 0

local task_ids1
local task_ids2

local task_ids = {
    [1] = {21560,21561,21562,21563,},
    [2] = {21555,21556,21557,21558,21559}
}
-- local year_ids = {
--     104,103
-- }
local permissions = {
    "actp_own_task_p_recharge_rebate_nor",
    "actp_own_task_p_recharge_rebate_v4",
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间

    -- do now_level = 2 end
    -- do return true end

    local e_time = 1606751999
    local s_time = 1606174200
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end
    -- 对应权限的key
    local func = function (_permission_key)
        local is_access = true
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                is_access = false 
            end
        end
        return is_access
    end

    for i = 1, #permissions do
        if func(permissions[i]) then
            now_level = i
            return true
        end
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    --dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    dump(parm,"<color=white>>>>>></color>")
    dump(now_level,"<color=white>>>>>>now_level</color>")
    if now_level == 1 then
        return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil, config_01)
    elseif now_level == 2 then
        return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil, config_02)
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        dump("<color=white>---------GetHintState---------</color>")
        dump(M.IsAwardCanGet(),"<color=white>---------IsAwardCanGet---------</color>")

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
    --return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
    if parm.gotoui == M.key then
        M.SetHintState()
    end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["model_task_change_msg"] = M.model_task_change_msg
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["model_task_change_msg"] = M.on_model_task_change_msg
end

function M.Init()
    M.Exit()

    this = Act_039_LGFLManager
    this.m_data = {}
    MakeLister()
    AddLister()
    M.IsActive()
    M.InitUIConfig()
end
function M.Exit()
    if this then
        RemoveLister()
        this = nil
    end
end
function M.InitUIConfig()
    this.UIConfig = {}

    task_ids1 = M.GetTaskIDS(config_01)
    task_ids2 = M.GetTaskIDS(config_02)
end

function M.OnLoginResponse(result)
    if result == 0 then
        -- 数据初始化
    end
end
function M.OnReConnecteServerSucceed()
end

function M.model_task_change_msg(data)
    --if M.IsHave(data.id) then
        --弹出面板
        --ActivityYearPanel.Create(nil, nil, {ID = year_ids[now_level]}, true)
    --end
end

function M.IsHave(id)
    local is_have = false
    for k ,v in pairs(task_ids[now_level]) do
        is_have = (v == id) and true or false 
    end
    return is_have
end

function M.GetTaskIDS(config)
    local task_ids = {}
    for i=1,#config.tge1 do
        task_ids[#task_ids + 1] = config.tge1[i].task
    end
    return task_ids
end

function M.IsAwardCanGet()
    if now_level == 1 then
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
    if now_level == 2 then
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

function M.on_model_task_change_msg(data)
    M.Refresh_Status()
    if M.IsActive() then
        for i=1,#task_ids1 do
            if task_ids1[i] == data.id then
                ActivityYearPanel.Create()
            end
        end
        for i=1,#task_ids2 do
            if task_ids2[i] == data.id then
                ActivityYearPanel.Create()
            end
        end
    end
end