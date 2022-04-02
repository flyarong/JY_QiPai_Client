-- 创建时间:2020-10-26
-- Act_037_SSYSCManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_037_SSYSCManager = {}
local M = Act_037_SSYSCManager
M.key = "act_037_ssysc"
GameButtonManager.ExtLoadLua(M.key,"Act_037_SSYSCPanel")
local act_037_ssysc_config = GameButtonManager.ExtLoadLua(M.key,"act_037_ssysc_config")

local this
local lister
M.item_key = "prop_double11_giftbox"
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
    if parm.goto_scene_parm == "panel" then
        return Act_037_SSYSCPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanGetAward() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
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
    lister["AssetChange"] = this.OnAssetChange
end

function M.Init()
	M.Exit()

	this = Act_037_SSYSCManager
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
    this.UIConfig.shop_item_config = act_037_ssysc_config.config
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.IsCanGetAward()
    for k,v in pairs(M.UIConfig.shop_item_config) do
        if GameItemModel.GetItemCount(M.item_key) >= v.item_cost then
            if (not v.day_limit or v.day_limit == 0) or v.day_limit > M.GetShopBuyCountToday(v.id) then
                return true
            end
        end
    end
    return false
end

function M.GetShopBuyCountToday(id)
    return PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id .. id .. os.date("%Y-%m-%d"),0)
end

function M.AddShopBuyCountToday(id)
    PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id .. id .. os.date("%Y-%m-%d"),M.GetShopBuyCountToday(id) + 1)
end

function M.OnAssetChange(data)
    M.SetHintState()
end