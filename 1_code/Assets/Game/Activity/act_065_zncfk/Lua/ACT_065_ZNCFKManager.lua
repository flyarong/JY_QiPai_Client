-- 创建时间:2021-08-16
-- ACT_065_ZNCFKManager 管理器

local basefunc = require "Game/Common/basefunc"
ACT_065_ZNCFKManager = {}
local M = ACT_065_ZNCFKManager
M.key = "act_065_zncfk"
local config = GameButtonManager.ExtLoadLua(M.key,"act_065_zncfk_config")
GameButtonManager.ExtLoadLua(M.key,"ACT_065_ZNCFKEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"ACT_065_ZNCFKItemBase")
GameButtonManager.ExtLoadLua(M.key,"ACT_065_ZNCFKPanel")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = config.base_info.end_t
    local s_time = config.base_info.sta_t
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    if parm.goto_scene_parm == "panel" then
        return ACT_065_ZNCFKPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return ACT_065_ZNCFKEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsCanGet() then
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
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
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

    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

	this = ACT_065_ZNCFKManager
	this.m_data = {}
	MakeLister()
    AddLister()
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

    this.UIConfig.task_ids = {}
    for k,v in pairs(config.task_info) do
        this.UIConfig.task_ids[#this.UIConfig.task_ids + 1] = v.task_id
    end
    this.UIConfig.task_ids[#this.UIConfig.task_ids + 1] = config.base_info.task_id
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetCfg()
    return config
end

function M.IsCanGet()
    for k,v in pairs(this.UIConfig.task_ids) do
        local data = GameTaskModel.GetTaskDataByID(v)
        if data then
            if data.award_status == 1 then
                return true
            end
        end
    end
    return false
end

function M.on_model_task_change_msg(data)
    if M.CheckIsCareTaskId(data.id) then
        Event.Brocast("act_065_zncfk_task_data_is_change_msg")
    end
end

function M.CheckIsCareTaskId(id)
    for k,v in pairs(this.UIConfig.task_ids) do
        if v == id then
            return true
        end
    end
    return false
end