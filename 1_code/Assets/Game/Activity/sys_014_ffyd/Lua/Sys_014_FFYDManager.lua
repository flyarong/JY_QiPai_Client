-- 创建时间:2020-05-26
-- Sys_014_FFYDManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_014_FFYDManager = {}
local M = Sys_014_FFYDManager
M.key = "sys_014_ffyd"
GameButtonManager.ExtLoadLua(M.key, "Sys_014_FFYD5ZLBPanel")
GameButtonManager.ExtLoadLua(M.key, "Sys_014_FFYD5ZLBEnterPrefab")
local config = GameButtonManager.ExtLoadLua(M.key, "sys_014_5zlb_config")

local is_show_btn = true
local is_show_injs
local this
local lister
local shopid = {10277,10278,10279}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if MainModel.myLocation == "game_DDZMatch" then
        return is_show_injs and M.IsShow()
    else 
        return is_show_btn and M.IsShow()
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
    if parm.goto_scene_parm == "enter" then
        return Sys_014_FFYD5ZLBEnterPrefab.Create(parm.parent, parm.backcall)
    elseif parm.goto_scene_parm == "panel" then
        return Sys_014_FFYD5ZLBPanel.Create()
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
    lister["jbs_hall_switched"] = this.on_jbs_hall_switched
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["global_sysqx_uichange_msg"] = this.on_global_sysqx_uichange_msg
end

function M.Init()
	M.Exit()

	this = Sys_014_FFYDManager
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

function M.on_jbs_hall_switched(data)
    if data and data.match_type then
        if data.match_type == MatchModel.MatchType.sws or data.match_type == MatchModel.MatchType.qydjs then
            is_show_btn = true
        else
            is_show_btn = false
        end
        Event.Brocast("ui_button_state_change_msg")
    end
end

function M.on_global_sysqx_uichange_msg(data)
    if data and data.key == "match_js" then
        if data.panelSelf.game_type == "hbs" then
            is_show_injs = true 
        else
            is_show_injs = false
        end
        Event.Brocast("ui_button_state_change_msg")
    end
end

function M.IsAllBuy()
    for i = 1,#shopid do
        local status = MainModel.GetGiftShopStatusByID(shopid[i])
        if status == 1 then
            return false
        end
    end
    return true
end

function M.IsShow()
    return not M.IsAllBuy()
end

function M.GetConfig()
    return config.gift
end