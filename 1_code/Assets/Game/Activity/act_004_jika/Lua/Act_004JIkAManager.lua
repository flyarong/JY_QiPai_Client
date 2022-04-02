-- 创建时间:2020-03-10
-- Act_004JIKAManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_004JIKAManager = {}
local M = Act_004JIKAManager
M.key = "act_004_jika"
GameButtonManager.ExtLoadLua(M.key, "Act_004JIKAPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_004JIKAEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "JIKA_JYFLEnterPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key, "jika_config")
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

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_004JIKAPanel.Create(parm.parent,parm.backcall)
    end 
    if parm.goto_scene_parm == "enter" then
        return Act_004JIKAEnterPrefab.Create(parm.parent)
    end 
    if parm.goto_scene_parm == "jyfl_enter" then
        return JIKA_JYFLEnterPrefab.Create(parm.parent, parm)
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
    lister["query_jika_base_info_response"] = this.on_query_jika_base_info_response
    lister["jika_everyday_lottery_response"] = this.on_jika_everyday_lottery_response
    lister["get_one_jika_false_lottery_data_response"] = this.on_get_one_jika_false_lottery_data_response
    lister["jika_base_info_change_msg"] = this.jika_base_info_change_msg
end

function M.Init()
	M.Exit()

	this = Act_004JIKAManager
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
        Network.SendRequest("query_jika_base_info")
        print("<color=red>------------开始请求数据季卡----------</color>")
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

--季卡基础信息
function M.on_query_jika_base_info_response( _,data )
    dump(data,"<color=red>季卡基础消息</color>")
    if data and data.result == 0 then 
        this.isBuy = data.total_remain_num > 0 
        this.isLottery = data.is_lottery == 1
        M.SetHintState()
    end 
end

--每日抽奖信息
function M.on_jika_everyday_lottery_response( _,data )
    dump(data,"<color=red>季卡每日抽奖信息</color>")
    if data and data.result == 0 then 
        
    end 
end

--季卡获得一条信息
function M.on_get_one_jika_false_lottery_data_response(  _,data )
    --dump(data,"<color=red>季卡获得一条信息</color>")
end

function M.BuyShop()
    local shopid = 10168
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function M.jika_base_info_change_msg(_,data)
    dump(data,"<color=red>季卡改变-------------</color>")
    this.isBuy = data.total_remain_num > 0 
    this.isLottery = data.is_lottery == 1
    M.SetHintState()
end

function M.IsAwardCanGet()
    if this.isBuy and not this.isLottery then 
        return true
    else
        return false
    end
end

function M.getIsBuy()
    return this.isBuy
end
function M.getIsLottery()
    return this.isLottery
end
