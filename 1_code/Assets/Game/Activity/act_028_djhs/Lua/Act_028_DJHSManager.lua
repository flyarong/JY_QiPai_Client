-- 创建时间:2020-09-01
-- Act_028_DJHSManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_028_DJHSManager = {}
local M = Act_028_DJHSManager
M.key = "act_028_djhs"
GameButtonManager.ExtLoadLua(M.key, "Act_028_DJHSEnterPrefab")

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
    local _permission_key = "drt_ignore_watch_ad_12"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            return false
        end
    end
    if gameRuntimePlatform == "Ios" then
        return false
    end
    return true
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    if this.m_data.data then
        return M.IsActive()
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow() then
        return
    end
    if parm.goto_scene_parm == "enter" then
        return Act_028_DJHSEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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

    lister["model_act_028_djhs_msg"] = this.on_model_act_028_djhs_msg
end

function M.Init()
	M.Exit()

	this = Act_028_DJHSManager
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
	end
end
function M.OnReConnecteServerSucceed()
end

function M.CloseData()
    this.m_data.data = nil
end

function M.GetData()
    return this.m_data.data
end

function M.on_model_act_028_djhs_msg(data)
    if not SYSQXManager.IsNeedWatchAD() then
        return
    end
    if data and data.count and data.ad_award and tonumber(data.ad_award) then
        this.m_data.data = data
        Event.Brocast("ui_button_state_change_msg")
    end
end