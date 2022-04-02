-- 创建时间:2020-04-08
-- Act_008_MFLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_008_MFLBManager = {}
local M = Act_008_MFLBManager
M.key = "act_008_mflb"

GameButtonManager.ExtLoadLua(M.key, "Act_008_MFLBPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_008_MFLBEnterPrefab")
local this
local lister
M.shopid = 10283
local task_id = 0

M.can_lottery = false
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.GetEndTime()
    local s_time = M.GetStartTime()
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        dump(os.time(),"<color=red>免费礼包bug</color>")
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_buy_gift_bag_10283"
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

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then
            return Act_008_MFLBPanel.Create(parm.parent,parm.backcall)
        end
    end
    if parm.goto_scene_parm == "enter" then
        if parm.parent.parent.gameObject.name == "ActivityYearPanel" then
            local b = Act_008_MFLBEnterPrefab.Create(parm.parent)
            CommonHuxiAnim.Start(b.gameObject)
        else
            return Act_008_MFLBEnterPrefab.Create(parm.parent)
        end
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsAwardCanGet()   then
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
    lister["EnterScene"] = this.OnEnterScene
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_008_MFLBManager
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

function M.OnEnterScene()
    local check_can_create = function()
        return M.IsActive() and not M.IsLotteryed()
    end
    if MainModel.myLocation == "game_MiniGame" then
        if check_can_create() then 
            Act_008_MFLBPanel.Create()
        end 
    end
    if MainModel.myLocation == "game_Free" then
        if check_can_create() then 
            Act_008_MFLBPanel.Create()
        end 
    end
    if MainModel.myLocation == "game_MatchHall" then
        if check_can_create() then 
            Act_008_MFLBPanel.Create()
        end 
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end


function M.IsAwardCanGet()
end

function M.BuyShop()
    local shopid = M.shopid 
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function M.IsLotteryed()
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
	for i = 1,4 do
		local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id .. "award" .. i, 0))))
		if oldtime == newtime then
            return true
        end
	end
	return false
end

function M.GetEndTime()
    local gift_config =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, M.shopid)
    if gift_config then
        return gift_config.end_time
    end
    return os.time()
end

function M.GetStartTime()
    local gift_config =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, M.shopid)
    if gift_config then
        return gift_config.start_time
    end
    return os.time()
end