-- 创建时间:2020-08-03
-- Sys_025_OpenBoxManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_025_OpenBoxManager = {}
local M = Sys_025_OpenBoxManager
M.key = "sys_025_openbox"
GameButtonManager.ExtLoadLua(M.key, "Sys_025_OpenBoxPanel")
local this
local lister = {}

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
    lister["AssetChange"] = this.OnAssetChange
    lister["hallpanel_created"] = this.on_hallpanel_created
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["OpenBox_panel_new"] = this.on_OpenBox_panel_new
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Sys_025_OpenBoxManager
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

function M.on_OpenBox_panel_new(data)
    if M.IsActive() then
        Sys_025_OpenBoxPanel.Create(data)
    else
        HintPanel.Create(1,"宝箱开启时间为11月10日7:30~11月16日23:59:59")
    end
end
local hallpanel
function M.OnAssetChange(data)
    M.RefreshRed()
end

function M.on_hallpanel_created(data)
    if M.IsActive()  then
        if data and data.panelSelf then
            hallpanel = data.panelSelf
            M.RefreshRed()
        end
    end
end


local keys = {
    "prop_rare_box",
    "prop_epic_box",
    "prop_legend_box",
    "prop_random_goldcoin_box",
    "prop_new_year_red_packet",
    -- "prop_guess_apple_bet_1",
    -- "prop_guess_apple_bet_2",
    -- "prop_guess_apple_bet_3",
    -- "prop_guess_apple_bet_4",
    -- "prop_guess_apple_bet_5",
}

function M.RefreshRed()
    if hallpanel and IsEquals(hallpanel.gameObject) then
        -- local red = hallpanel.bag_hint.transform:GetComponent("Image")
        hallpanel.bag_hint.gameObject:SetActive(M.CheakRed())
        --red.sprite = GetTexture("hall_icon_lfl")
        --red:SetNativeSize()
        --hallpanel.bag_hint.gameObject:SetActive(M.CheakRed())
    end
end


function M.CheakRed()
    local check_func = function (str)
        if GameItemModel.GetItemCount(str) > 0 then
            return true
        end
    end
    for i = 1,#keys do
        if check_func(keys[i]) then
            if os.time() > 1612972800 then
                return true
            end
        end
    end
    return false
end