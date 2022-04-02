-- 创建时间:2020-02-04
-- YCS_CSSLManager 1 管理器

local basefunc = require "Game/Common/basefunc"
YCS_CSSLManager = {}
local M = YCS_CSSLManager
M.key = "act_ycs_cssl"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_ycs_cssl_config") 
GameButtonManager.ExtLoadLua(M.key, "YCS_CSSLListPanel")
GameButtonManager.ExtLoadLua(M.key, "YCS_CSSLMorePanel")
GameButtonManager.ExtLoadLua(M.key, "YCS_CSSLPanel")
GameButtonManager.ExtLoadLua(M.key, "YCS_CSSLMyListPanel") 
local this
local lister

M.item1_key = "prop_051_gold_yuanbao"
M.item2_key = "shop_gold_sum"
M.item1_consume_num = 4
M.item2_consume_num = 200
M.endTime = 1614009599

-- 是否有活动
function M.IsActive()
    return true
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return true
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return YCS_CSSLPanel.Create(parm.parent)
    end 
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsHintGet()  then
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
    lister["AssetChange"] = this.Refresh
end

function M.Init()
	M.Exit()
	this = YCS_CSSLManager
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
    this.UIConfig={
    }
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.IsHintGet()
    if MainModel.GetItemCount(M.item1_key) > M.item1_consume_num 
    or MainModel.GetItemCount(M.item2_key) > M.item2_consume_num then
        return true
    end
    return false
end

function M.GetItemCount(kind)
    if kind == 1 then
        return MainModel.GetItemCount(M.item1_key)
    elseif kind == 2 then 
        return MainModel.GetItemCount(M.item2_key)
    end
    return 0
end