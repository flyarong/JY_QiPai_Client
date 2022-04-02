-- 创建时间:2020-11-30
-- Act_042_XSHBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_042_XSHBManager = {}
local M = Act_042_XSHBManager
M.key = "act_042_xshb"
M.config = GameButtonManager.ExtLoadLua(M.key, "act_042_xshb_config")
GameButtonManager.ExtLoadLua(M.key, "Act_042_XSHBPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_042_XSHBEnterPrefab")
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time = 1607994000
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
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "enter" then
        return Act_042_XSHBEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Act_042_XSHBPanel.Create(parm.parent,parm.backcall)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
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
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["query_total_xian_shi_hong_bao_data_response"] = this.on_query_total_xian_shi_hong_bao_data_response
    lister["query_xian_shi_hong_bao_system_data_response"] = this.on_query_xian_shi_hong_bao_system_data_response
end

function M.Init()
	M.Exit()

	this = Act_042_XSHBManager
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
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Network.SendRequest("query_total_xian_shi_hong_bao_data")
        Network.SendRequest("query_xian_shi_hong_bao_system_data")
	end
end

function M.on_query_total_xian_shi_hong_bao_data_response(_,data)
    dump(data,"<color=red>红包数据——单人</color>")
    if data.result == 0 then
        for i = 1,#data.data do
            this.m_data[data.data[i].unlock_id] = this.m_data[data.data[i].unlock_id] or {}
            this.m_data[data.data[i].unlock_id].unlock_type = data.data[i].unlock_type 
            this.m_data[data.data[i].unlock_id].unlock_remain  = data.data[i].unlock_remain
        end
        Event.Brocast("xian_shi_hong_bao_change")
    end
end

function M.on_query_xian_shi_hong_bao_system_data_response(_,data)
    dump(data,"<color=red>红包数据——全服</color>")
    if data.result == 0 then
        for i = 1,#data.data do
            this.m_data[data.data[i].unlock_id] = this.m_data[data.data[i].unlock_id] or {}
            this.m_data[data.data[i].unlock_id].total_remain  = data.data[i].total_remain
        end
        Event.Brocast("xian_shi_hong_bao_change")
    end
end

function M.GetDataByTaskID(task_id)
    local unlock_id = M.GetConfigByTaskID(task_id).unlock_id
    return this.m_data[unlock_id]
end

function M.GetConfigByTaskID(task_id)
    for i = 1,#M.config.base do
        if M.config.base[i].task_id == task_id then
            return M.config.base[i]
        end
    end
end

function M.GetConfigByUnLockID(unlock_id)
    for i = 1,#M.config.base do
        if M.config.base[i].unlock_id == unlock_id then
            return M.config.base[i]
        end
    end
end

function M.ShowCheck(_permission_key)
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

function M.UnlockCheck(_permission_key)
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key,is_on_hint = false, cw_btn_desc = "确定"}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end

function M.IsAwardCanGet()
    for i = 1,#M.config.base do
        local task_id = M.config.base[i].task_id
        local task_data = GameTaskModel.GetTaskDataByID(task_id)
        if task_data then
            if task_data.award_status == 1 and task_data.other_data_str and basefunc.parse_activity_data(task_data.other_data_str).is_unlock == 1  then
                return true
            end
        end
    end
end

function M.on_model_task_change_msg()
    Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
end

function M.OnReConnecteServerSucceed()
end
