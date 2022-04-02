local basefunc = require "Game/Common/basefunc"
Act_027_ZNQWYJNBManager = {}
local M = Act_027_ZNQWYJNBManager
M.key = "act_027_znqwyjnb"
local config = GameButtonManager.ExtLoadLua(M.key, "act_027_znqwyjnb")
local config_cpl = GameButtonManager.ExtLoadLua(M.key, "act_027_znqwyjnb_cpl")
GameButtonManager.ExtLoadLua(M.key,"Act_027_ZNQWYJNBPanel")
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
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
    end
    return true
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
    dump({parm,M.cfg}, "<color=red>我要纪念币</color>")
    if parm.goto_scene_parm == "panel" then
        return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil, M.cfg)
	end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
    lister["ActivityTaskPanel_Had_Finish"] = M.on_ActivityTaskPanel_Had_Finish
    lister["ActivityTaskPanel_Exit"] = M.ActivityTaskPanel_Exit
    lister["model_query_task_data_response"] = M.Refresh_Status
	lister["model_task_change_msg"] = M.Refresh_Status
end

function M.Init()
	M.Exit()

	this = Act_027_ZNQWYJNBManager
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
    M.cfg = {}
    local qx_normal
    local qx_cpl
    local _permission_key = "actp_own_task_21452"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = false}, "CheckCondition")
        if a and b then
            qx_normal = true
        end
    end
    _permission_key = "actp_own_task_21453"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = false}, "CheckCondition")
        if a and b then
            qx_cpl = true
        end
    end
    M.cfg = config
    M.task_id = M.cfg.tge1[1].task
    if qx_normal then
        M.cfg = config
        M.task_id = M.cfg.tge1[1].task
        return
    end
    if qx_cpl then
        M.cfg = config_cpl
        M.task_id = M.cfg.tge1[1].task
        return
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

--创建扩展部分
function M.on_ActivityTaskPanel_Had_Finish(data)
	if data and data.panelSelf then
		if data.panelSelf.act_cfg and data.panelSelf.act_cfg.key ==  M.key then 
			Act_027_ZNQWYJNBPanel.Create()
        end
        data = nil
	end
end

function M.ActivityTaskPanel_Exit()
    Act_027_ZNQWYJNBPanel.Close()
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.IsAwardCanGet()
    local d = GameTaskModel.GetTaskDataByID(M.task_id)
    if d then 
        if d.award_status == 1 then 
            return true
        end 
    end 
    return false
end