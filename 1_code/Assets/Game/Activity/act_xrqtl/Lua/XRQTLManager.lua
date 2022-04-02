-- 创建时间:2020-01-15
-- XRQTLManager 管理器

local basefunc = require "Game/Common/basefunc"
XRQTLManager = {}
local M = XRQTLManager
M.key = "act_xrqtl"
XRQTLManager.config = GameButtonManager.ExtLoadLua(M.key, "activity_xrqtl_config")
GameButtonManager.ExtLoadLua(M.key, "XRQTLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "XRQTLPanel")
local this
local lister
local task_ids = {}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    if MainModel.UserInfo.ui_config_id == 1 then return end 
    local e_time
    local s_time = 1581982200
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "drt_block_new_player_happy_seven_day"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            return false
        end
        return true and MainModel.FirstLoginTime() > s_time and M.GetDayIndex() + 1 <= 7 
    else
        return true and MainModel.FirstLoginTime() > s_time and M.GetDayIndex() + 1 <= 7 
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
            return XRQTLPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return XRQTLEnterPrefab.Create(parm.parent, parm.cfg)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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
        if MainModel and MainModel.UserInfo and MainModel.UserInfo.user_id then
            PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
        end
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
    --lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = XRQTLManager
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
    for i=1,#XRQTLManager.config.Info do
        task_ids[i] = XRQTLManager.config.Info[i].task_id
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- for i=1,#task_ids do
        --     Network.RandomDelayedSendRequest("query_one_task_data",{task_id = task_ids[i]})
        -- end
	end
end
function M.OnReConnecteServerSucceed()

end
--从零开始
function M.GetDayIndex()
    local first_login_time = MainModel.FirstLoginTime()
    local t1 = basefunc.get_today_id(first_login_time)
    local t2 = basefunc.get_today_id(os.time())
    return  t2 - t1 < 0 and 0 or t2 - t1
end

-- function M.on_model_query_one_task_data_response(data)
--     if data.id and M.IsCareTask(data.id) then 
--         -- dump(data,"<color=red>新人七天乐======</color>")
--         Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
--     end
-- end

function M.on_model_query_task_data_response()
    local data = GameTaskModel.GetTaskDataByID()
    --dump(data,"<color=red>+++++on_model_query_task_data_response+++++</color>")
    if data then
        for k,v in pairs(data) do
            if M.IsCareTask(v.id) then
                Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
            end
        end
    end
end

function M.on_model_task_change_msg(data)
    if data.id and M.IsCareTask(data.id) then 
        -- dump(data,"<color=red>新人七天乐======</color>")
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
    end
end

function M.IsCareTask(task_id)
    for i=1,#task_ids do
        if task_id == task_ids[i] then 
            return true
        end 
    end
    return false
end

function M.IsAwardCanGet()
    local task_data = M.GetCurrTaskData()
    if task_data and task_data.award_status == 1 then 
        return true
    end
    return false
end

function M.GetCurrTaskData()
    local day =  M.GetDayIndex() + 1
    if day <= #task_ids then
        return GameTaskModel.GetTaskDataByID(task_ids[day])
    end
end

function M.GetTaskDataByDay(index)
    if index  then 
        return GameTaskModel.GetTaskDataByID(task_ids[index])
    end
end

function M.IsShowInExXSYD()
    return M.IsActive() and M.IsAwardCanGet()
end