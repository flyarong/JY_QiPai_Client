local basefunc = require "Game/Common/basefunc"
Act_065_ZNJNKManager = {}
local M = Act_065_ZNJNKManager
M.key = "act_065_znjnk"
GameButtonManager.ExtLoadLua(M.key, "Act_065_ZNJNKPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_065_ZNJNKEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_065_ZNJNKJYFLEnterPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key, "act_065_znjnk_config")
local this
local lister


M.gift_id_998 = 10893
M.gift_id_2498 = 10894

M.start_time = 1630366200   --2021.08.31
M.end_time = 1630943999     --2021.09.06
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.end_time
    local s_time = M.start_time
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
    if MainModel.myLocation ~= "game_Hall"  then
        if M.isBuy then
            return false
        end
    end
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

function M.CheckIsShowInJYFL(parm)
    if M.getIsBuyOld() then
        if not M.getIsBuy() then return end
        if M.getIsOver() then return end
        return true
    end
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_065_ZNJNKPanel.Create(parm.parent,parm.backcall)
    end 
    if parm.goto_scene_parm == "enter" then
        if M.getIsBuyOld() then
           return 
        end
        local e_time = M.end_time
        local s_time
        if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
            return false
        end
        return Act_065_ZNJNKEnterPrefab.Create(parm.parent)
    end 
    if parm.goto_scene_parm == "jyfl_enter" then
        if not M.CheckIsShowInJYFL(parm) then return end
        return Act_065_ZNJNKJYFLEnterPrefab.Create(parm.parent, parm)
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsAwardCanGet() then
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

    lister["query_jinianka_3_anniversary_data_response"] = this.on_query_jinianka_3_anniversary_data_response
    lister["jinianka_3_anniversary_data_change"] = this.jinianka_3_anniversary_data_change    
    lister["EnterScene"] = this.EnterScene
    lister["ExitScene"] = this.ExitScene
end

function M.Init()
	M.Exit()

	this = Act_065_ZNJNKManager
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
        Network.SendRequest("query_jinianka_3_anniversary_data",nil)
        Network.SendRequest("query_gift_bag_num",{gift_bag_id = M.gift_id_998})
        Network.SendRequest("query_gift_bag_num",{gift_bag_id = M.gift_id_2498})
	end
end

function M.OnReConnecteServerSucceed()
end

function M.on_query_jinianka_3_anniversary_data_response( _,data )
    dump(data,"<color=green>3周年纪念卡</color>")
    if data and data.result == 0 then
        this.data = data
        M.SetHintState()
    end
    Event.Brocast("model_query_jinianka_3_anniversary_data_response", data)
end

function M.BuyShop(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function M.jinianka_3_anniversary_data_change(_,data)
    dump(data,"<color=green>纪念卡改变-------------</color>")
    this.data = data
    M.SetHintState()
    Event.Brocast("model_jinianka_3_anniversary_data_change", data)
end

function M.IsAwardCanGet()
    if M.getIsBuy() and M.getIsLottery() then
        return true
    end
end

function M.getIsBuy()
    return this.data and this.data.is_buy == 1
end

function M.getIsLottery()
    if not this.data then return end
    if this.data.is_buy ~= 1 then return end
    if this.data.day_award_can_get == 1 or this.data.week_award_can_get == 1 or this.data.month_award_can_get == 1 then
        return true
    end
end

function M.getIsOver()
    if not this.data then return end
    if this.data.is_buy ~= 1 then return end
    if this.data.day_remain_award == 0 
        and this.data.day_award_can_get == 0 
        and this.data.week_remain_award == 0 
        and this.data.week_award_can_get == 0 
        and this.data.month_remain_award == 0 
        and this.data.month_award_can_get == 0 then
        return true
    end
end

function M.getIsBuyOld()
    if not this or not this.data then return end
    if this.data.is_buy ~= 1 then return end
    if not this.data.buy_time then return end
    if M.end_time > os.time() and M.start_time < os.time() and M.end_time > this.data.buy_time and M.start_time < this.data.buy_time then
        --活动时间内购买的不是老购买玩家
        return
    end
    return true
end

function M.EnterScene(  )
    Event.Brocast("act_065_znjnk_close")
end

function M.ExitScene(  )
    Event.Brocast("act_065_znjnk_close")
end