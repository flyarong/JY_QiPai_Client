-- 创建时间:2020-11-09
-- Act_045_XXLFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_045_XXLFLManager = {}
local M = Act_045_XXLFLManager
M.key = "act_045_xxlfl"
local config = GameButtonManager.ExtLoadLua(M.key,"act_045_xxlfl_config")

local this
local lister

local task_ids 

local permissions = {
    "actp_own_task_p_recharge_rebate_nor",
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间


    do return  true end
     
    local e_time --= 1606751999
    local s_time --= 1606174200
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
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil, config)
        end
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["model_task_change_msg"] = M.on_model_task_change_msg
end

function M.Init()
    M.Exit()

    this = Act_045_XXLFLManager
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
    task_ids = M.GetTaskIDS(config)
end

function M.OnLoginResponse(result)
    if result == 0 then
        -- 数据初始化
    end
end
function M.OnReConnecteServerSucceed()
end

function M.IsHave(id)
    local is_have = false
    for k ,v in pairs(task_ids) do
        is_have = (v == id) and true or false 
    end
    return is_have
end

function M.GetTaskIDS(config)
    local _task_ids = {}
    for i=1,#config.tge1 do
        _task_ids[#_task_ids + 1] = config.tge1[i].task
    end
    return _task_ids
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

function M.on_model_task_change_msg(data)
    if not M.IsHave(data.id) then return end
    M.Refresh_Status()
    if M.IsActive() then
        for i=1,#task_ids do
            if task_ids[i] == data.id then
                ActivityYearPanel.Create()
            end
        end
    end
end