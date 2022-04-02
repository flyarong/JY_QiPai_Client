-- 创建时间:2021-04-26
-- SysYdJfExchangeManager 管理器

local basefunc = require "Game/Common/basefunc"
SysYdJfExchangeManager = {}
local M = SysYdJfExchangeManager
M.key = "sys_ydjf_exchange"
GameButtonManager.ExtLoadLua(M.key,"SysYdjfExchangePanel")
GameButtonManager.ExtLoadLua(M.key,"SysYdjfVerifyPanel")

local this
local lister

--验证码获取的冷却时间
local verify_duration = 60

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

    -- dump("<color=white>SysYdJfExchangeManager.GotoUI</color>")
    -- dump("<color=white>SysYdJfExchangeManager.GotoUI</color>")
    -- dump("<color=white>SysYdJfExchangeManager.GotoUI</color>")
    if parm.goto_scene_parm == "panel" then
        return SysYdjfExchangePanel.Create(parm.parent, parm.type)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
end

--玩棋牌移动积分兑换
function M.Init()
	M.Exit()

	this = SysYdJfExchangeManager
	this.m_data = {}
    this.m_data.last_verify_time = -1
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

function M.SetLastVerifyTime()
    this.m_data.last_verify_time = os.time()
end

function M.ClearLastVerifyTime()
    this.m_data.last_verify_time = -1
end

function M.IsInVerifyCd()
    if this.m_data.last_verify_time == -1 then
        return false
    end
    if os.time() - this.m_data.last_verify_time >= verify_duration then
        M.ClearLastVerifyTime()
        return false
    end
    return true
end

function M.GetVerifyCdNum()
    if not M.IsInVerifyCd() then
        return 0
    end
    return verify_duration - ( os.time() - this.m_data.last_verify_time )
end

function M.OnReConnecteServerSucceed()
end
