-- 创建时间:2021-05-25
-- Act_059_DwJrlbManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_059_DwJrlbManager = {}
local M = Act_059_DwJrlbManager
M.key = "act_059_dwjj_jrlb"
GameButtonManager.ExtLoadLua(M.key, "Act_059_DwJrlbPanel")

local this
local lister

M.endTime = 1643039999
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1643039999
    local s_time = 1641857400
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
        return Act_059_DwJrlbPanel.Create(parm.parent)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsHint() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get 
    end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key or parm.gotoui == "act_033_fkzjd" or parm.gotoui == "act_007_fkfl" then
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

function M.Init()
	M.Exit()

	this = Act_059_DwJrlbManager
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

function M.IsHint()
    return M.IsHintQJD() or M.IsHintFL()
end

local function IsHintFromKey(key)
    local parm = { gotoui = key}
    local a,b = GameButtonManager.RunFunExt(key, "GetHintState", nil, parm)
    if a and b == ACTIVITY_HINT_STATUS_ENUM.AT_Get  then
        return true
    end
    return false
end

--疯狂敲金蛋
function M.IsHintQJD()
   return IsHintFromKey("act_033_fkzjd")
end

--疯狂返利
function M.IsHintFL()
   return IsHintFromKey("act_007_fkfl")
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end
