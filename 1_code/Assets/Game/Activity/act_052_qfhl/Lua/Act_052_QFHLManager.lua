-- 创建时间:2020-12-07
-- Act_052_QFHLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_052_QFHLManager = {}
local M = Act_052_QFHLManager
M.key = "act_052_qfhl"
M.task_id = 21721
M.lottery_key = "prop_fish_drop_act_0"
M.box_ids = {183} 

M.config = GameButtonManager.ExtLoadLua(M.key,"activity_052_qfhl_config")
GameButtonManager.ExtLoadLua(M.key,"Act_052_QFHLPanel")
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
    local check_func = function(_permission_key)
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
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then
            return Act_052_QFHLPanel.Create(parm.parent)
        end
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    local task_data = GameTaskModel.GetTaskDataByID(M.task_id)
    if (task_data and task_data.award_status == 1) or GameItemModel.GetItemCount(M.lottery_key) >= 100 then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get   
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor   
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
    lister["AssetChange"] = this.on_AssetChange
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_052_QFHLManager
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

function M.GetCurrIndex(times)
    local num = GameItemModel.GetItemCount(M.lottery_key)
    if num >= times * 4 then
        return 1
    else
        return 2
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()
end

function M.on_AssetChange()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end