-- 创建时间:2020-08-03
-- BY3DADMFCJManager 管理器

local basefunc = require "Game/Common/basefunc"
BY3DADMFCJManager = {}
local M = BY3DADMFCJManager
M.key = "by3d_ad_mfcj"
GameButtonManager.ExtLoadLua(M.key, "BY3DADMFCJPanel")
GameButtonManager.ExtLoadLua(M.key, "BY3DADMFCJEnterPanel")
GameButtonManager.ExtLoadLua(M.key, "ADMFCJ_JYFLEnterPrefab")

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
    local _permission_key = "drt_ignore_watch_ad_10"
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
function M.CheckIsShow(parm, type)
    if SYSQXManager.IsNeedWatchAD() then
        return M.IsActive()
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "enter" then
        return BY3DADMFCJEnterPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "jyfl_enter" then
        return ADMFCJ_JYFLEnterPrefab.Create(parm.parent)
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

    lister["query_ad_free_lottery_response"] = this.on_query_ad_free_lottery
    lister["use_ad_free_lottery_response"] = this.on_use_ad_free_lottery
end

function M.Init()
	M.Exit()

	this = BY3DADMFCJManager
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
        M.QueryInfoData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryInfoData()
    if this.m_data.is_query_wc then
        Event.Brocast("by3d_ad_mfcj_query_ad_free_lottery")
    else
        Network.SendRequest("query_ad_free_lottery")
    end
end
function M.on_query_ad_free_lottery(_, data)
    dump(data, "<color=red>EEE query_ad_free_lottery</color>")
    this.m_data.result = data.result
    if data.result == 0 then
        this.m_data.is_query_wc = true
        this.m_data.num = data.num
        if data.time then
            this.m_data.time = tonumber(data.time)
        else
            this.m_data.time = 0
        end
        Event.Brocast("by3d_ad_mfcj_query_ad_free_lottery")
    end
end

function M.on_use_ad_free_lottery(_, data)
    dump(data, "<color=red>EEE use_ad_free_lottery</color>")
    if data.result == 0 then
        this.m_data.num = data.num
        if data.time then
            this.m_data.time = tonumber(data.time)
        else
            this.m_data.time = 0
        end
        Event.Brocast("by3d_ad_mfcj_use_ad_free_lottery")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.GetNum()
    return this.m_data.num or 0
end

function M.GetCDTime()
    if this.m_data.time and this.m_data.time > os.time() then
        return this.m_data.time - os.time()
    end
    return 0
end