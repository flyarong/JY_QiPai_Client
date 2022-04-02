-- 创建时间:2020-05-27
-- Act_015_EXCZFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_015_EXCZFLManager = {}
local M = Act_015_EXCZFLManager
M.key = "act_015_EXczfl"

local this
local lister

local task_ids = {
    [1] = {21316,21317,21318,21319,},
    [2] = {21320,21321,21322,21323,21324}
}
local year_ids = {
    80,81
}
local permission = {
    "actp_own_task_p_recharge_rebate_1",
    "actp_own_task_p_recharge_rebate_2",
}
local permission_level = 1
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1592236799
    local s_time = 1591659000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end
    -- 对应权限的key
    local func = function (_permission_key)
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

    for i = 1,#permission do
        if func(permission[i]) then
            permission_level = i
            return true
        end
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
    lister["model_task_change_msg"] = M.model_task_change_msg
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_015_EXCZFLManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.IsActive()
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

function M.model_task_change_msg(data)
    if M.IsHave(data.id) then
        --弹出面板
        ActivityYearPanel.Create(nil, nil, {ID = year_ids[permission_level]}, true)
    end
end

function M.IsHave(id)
    for k ,v in pairs(task_ids[permission_level]) do
        if v == id then
            return true
        end
    end
    return false
end