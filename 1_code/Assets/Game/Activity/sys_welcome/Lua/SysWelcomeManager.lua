-- 创建时间:2021-07-19
-- SysWelcomeManager 管理器

local basefunc = require "Game/Common/basefunc"
SysWelcomeManager = {}
local M = SysWelcomeManager
M.key = "sys_welcome"

GameButtonManager.ExtLoadLua(M.key, "SysWelcomePanel")

local this
local lister

local permissions = {
    "wellcome_login_tips_1",
    "wellcome_login_tips_2",
    "wellcome_login_tips_3",
    "wellcome_login_tips_4",
}

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
    --lister["EnterScene"] = this.OnEnterScene
    lister["hallpanel_created"] = this.on_hallpanel_created
end

function M.Init()
	M.Exit()

	this = SysWelcomeManager
	this.m_data = {}
    this.m_data.lv = 0
    this.isFirstView = true
	MakeLister()
    AddLister()
	M.InitUIConfig()
    M.InitMyLv()
end

function M.InitMyLv()
    local checkPermiss = function(_p)
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key =_p, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    end

    for i = 1, #permissions do
        if checkPermiss(permissions[i]) then
            this.m_data.lv = i
        end
    end
end

function M.IsHaveWelcome()

    if GameGlobalOnOff.IsOpenGuide and MainModel.UserInfo.xsyd_status ~= 1 then
        return false
    end

    if this.m_data.lv == 0 then
        return false
    end
    return this.isFirstView
end

function M.OnEnterScene()
    if MainModel.myLocation == "game_Hall" then
        M.OnIntoHall()
    end
end

function M.on_hallpanel_created()
    if MainModel.myLocation == "game_Hall" then
        M.OnIntoHall()
    end
end

--进入大厅时
function M.OnIntoHall()
    if M.IsHaveWelcome() then
        SysWelcomePanel.Create(this.m_data.lv)
        this.isFirstView = false
    end
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