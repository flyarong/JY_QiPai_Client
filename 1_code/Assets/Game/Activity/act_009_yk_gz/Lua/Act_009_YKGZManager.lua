-- 创建时间:2020-03-24
-- Act_009_YKGZManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_009_YKGZManager = {}
local M = Act_009_YKGZManager
M.key = "act_009_yk_gz"
GameButtonManager.ExtLoadLua(M.key, "Act_009_YKGZPanel")
local this
local lister
M.task_id = 65
M.gift_id = 10002
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
        return Act_009_YKGZPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter" then
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    local m_data = SYSYKManager.GetData()
    if m_data.task_data and m_data.task_data[M.task_id] then
        local data = m_data.task_data[M.task_id]
		local b        
        b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, 1)
        if b[1] == 1 then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        end
	end
	if PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id ..os.date("%x",os.time()),0) == 1 then
		return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
	else
		return ACTIVITY_HINT_STATUS_ENUM.AT_Red
	end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState(parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState(parm)
    if parm.gotoui == M.key then
		PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id  ..os.date("%x",os.time()),1)
		Event.Brocast("global_hint_state_change_msg", parm)
	end
    -- Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
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
    lister["model_task_change_msg"] = M.model_task_change_msg
    lister["GameActivityPanel_Create_Complete"] = M.GameActivityPanel_Create_Complete
    lister["finish_gift_shop"] = M.finish_gift_shop
end

function M.Init()
	M.Exit()

	this = Act_009_YKGZManager
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

function M.model_task_change_msg(data)
	if not data or data.id ~= M.task_id then return end
	Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
end

function M.GameActivityPanel_Create_Complete(data)
    if not data or not data.panel then return end
    local cell_list = data.panel.CellList
    M.sore_cell_list(cell_list,SYSYKManager.IsBuy1)
end

function M.finish_gift_shop(id)
    if id ~= M.gift_id then return end
    Event.Brocast("AssetsGetPanelConfirmCallback",{change_type = "buy_gift_bag_" .. M.gift_id})
end

function M.sore_cell_list(cell_list,is_buy)
    if not cell_list then return end
    for i,v in ipairs(cell_list) do
        if v.config and v.config.ID == 128 then
            local b = is_buy
            if b then
                v.transform:SetSiblingIndex(#cell_list - 2) 
            end
            break
        end
    end
end