-- 创建时间:2020-05-20
-- Sys_013_ZDKPLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_013_ZDKPLBManager = {}
local M = Sys_013_ZDKPLBManager
M.key = "sys_013_zdkplb"
GameButtonManager.ExtLoadLua(M.key, "Sys_013_ZDKPLBPanel")

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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["query_gift_bag_buy_time_response"] = this.on_query_gift_bag_buy_time_response
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
	lister["AssetChange"] = this.OnAssetChange
end

function M.Init()
	M.Exit()

	this = Sys_013_ZDKPLBManager
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
        Network.SendRequest("query_gift_bag_buy_time", {ids = {10257}})
	end
end
function M.OnReConnecteServerSucceed()
end

local last_buy_time = 0
function M.on_query_gift_bag_buy_time_response(_,data )
    dump(data,"捕鱼礼包购买时间-----")
    if data and data.result == 0 then
        if data.ids[1] == 10257 then
            last_buy_time = tonumber(data.times[1] or 0)
            Event.Brocast("zdkplb_Got_New_Info")
        end
    end
end

function M.GetBuyTime()
    return last_buy_time
end

function M.OnAssetChange(data)
	if data.change_type and (data.change_type == "buy_gift_bag_10258" or data.change_type == "buy_gift_bag_10257")  then
        Network.SendRequest("query_gift_bag_buy_time", {ids = {10257}})
	end
end