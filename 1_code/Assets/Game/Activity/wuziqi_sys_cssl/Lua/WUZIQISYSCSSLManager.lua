-- 创建时间:2020-10-11
-- WUZIQISYSCSSLManager 管理器

local basefunc = require "Game/Common/basefunc"
WUZIQISYSCSSLManager = {}
local M = WUZIQISYSCSSLManager
M.key = "wuziqi_sys_cssl"
GameButtonManager.ExtLoadLua(M.key,"WUZIQISYSCSSLPanel")
GameButtonManager.ExtLoadLua(M.key,"WUZIQISYSCSLBPanel")
GameButtonManager.ExtLoadLua(M.key,"WUZIQISYSCSSLEnterPrefab")
local this
local lister

M.gift_id = 10536 

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
        return WUZIQISYSCSSLPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return WUZIQISYSCSSLEnterPrefab.Create(parm.parent, parm.cfg)
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

    lister["query_jjsl_data_response"] = this.on_query_jjsl_data_response
    lister["get_jjsl_award_response"] = this.on_get_jjsl_award_response
    lister["PayPanelClosed"] = this.on_PayPanelClosed
    lister["ReceivePayOrderMsg"] = this.on_ReceivePayOrderMsg
end

function M.Init()
	M.Exit()

	this = WUZIQISYSCSSLManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
        if this.m_data.onLoginQuery then
            this.m_data.onLoginQuery:Stop()
            this.m_data.onLoginQuery = nil
        end
        M.StopTimer()
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
        this.m_data.onLoginQuery = Timer.New(function ()
            M.QueryData()
        end,1,1)
        this.m_data.onLoginQuery:Start()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryData()
    Network.SendRequest("query_jjsl_data")
end

function M.on_query_jjsl_data_response(_,data)
    dump(data,"<color=yellow>++++++++++on_query_jjsl_data_response+++++++++</color>")
    if data and data.result == 0 then 
        this.m_data.award = data.award--礼金
        --状态:1="立即激活",2="立即领取",3="倒计时"
        if not data.time or data.time and tonumber(data.time) == 0 then
            this.m_data.status = 1
        elseif os.time() >= tonumber(data.time) then
            this.m_data.status = 2
        else
            this.m_data.status = 3
        end
        this.m_data.level = data.level--礼金等级
        if data.time then
            this.m_data.remain_time = tonumber(data.time) - os.time()--下次领奖的时间(0 or nil 未激活)
        end
        Event.Brocast("sys_jjsl_data_msg")
    end
end

function M.GetStatus()
    return this.m_data.status
end


function M.GetRemainTime()
    return this.m_data.remain_time
end

function M.GetLevel()
    return this.m_data.level
end

function M.GetAward()
    return this.m_data.award
end

--倒计时
function M.RunDownCount(b)
    M.StopTimer()
    if b then
        M.RefreshDJS()
        this.m_data.downcount_timer = Timer.New(function ()
            this.m_data.remain_time = this.m_data.remain_time - 1
            M.RefreshDJS()
            if this.m_data.remain_time <= 0 then
                M.QueryData()
            end
        end,1,-1)
        this.m_data.downcount_timer:Start()
    end
end

function M.StopTimer()
    if this.m_data.downcount_timer then
        this.m_data.downcount_timer:Stop()
        this.m_data.downcount_timer = nil
    end
end

function M.RefreshDJS()
    Event.Brocast("sys_jjsl_Refresh_djs_msg",this.m_data.remain_time)
end

function M.IsCanGet()
    if this.m_data and this.m_data.status and this.m_data.status == 2 then
        return true
    else
        return false
    end
end

function M.IsCanGetGift()
    local s = MainModel.GetGiftShopStatusByID(M.gift_id)
    return s == 1
end

function M.on_get_jjsl_award_response(_,data)
    dump(data,"<color=yellow>++++++++++on_get_jjsl_award_response+++++++++</color>")
    if data and data.result == 0 then
        if data.time then
            this.m_data.remain_time = tonumber(data.time) - os.time()--下次领奖的时间(0 or nil 未激活)
        end
        this.m_data.award = data.award--礼金
        --状态:1="立即激活",2="立即领取",3="倒计时"
        if not data.time or data.time and tonumber(data.time) == 0 then
            this.m_data.status = 1
        elseif os.time() >= tonumber(data.time) then
            this.m_data.status = 2
        else
            this.m_data.status = 3
        end 
        Event.Brocast("sys_jjsl_data_msg")
    end
end

function M.on_PayPanelClosed()
    M.QueryData()
end

function M.on_AssetChange()
    M.QueryData()
end

function M.on_ReceivePayOrderMsg(data)
    if data and data.result == 0 then
        M.QueryData()
    end
end

