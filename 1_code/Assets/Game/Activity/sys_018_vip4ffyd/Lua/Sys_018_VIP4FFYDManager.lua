-- 创建时间:2020-06-15
-- Sys_018_VIP4FFYDManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_018_VIP4FFYDManager = {}
local M = Sys_018_VIP4FFYDManager
M.key = "sys_018_vip4ffyd"
M.shop_ids = {10316,10317,10318,10319}
GameButtonManager.ExtLoadLua(M.key,"Sys_018_VIP4FFYDPanel")
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    return VIPManager.get_vip_level() == 4
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
        return Sys_018_VIP4FFYDPanel.Create(parm.parent)
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["vip_upgrade_change_msg"] = this.on_vip_upgrade_change_msg
    lister["finish_gift_shop"] = this.on_finish_gift_shop
    lister["game_act_left_prefab_created"] = this.on_game_act_left_prefab_created
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["shop_info_get"] = this.shop_info_get
end

function M.Init()
	M.Exit()

	this = Sys_018_VIP4FFYDManager
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

function M.on_finish_gift_shop(id)
    if M.IsCareShopID(id)  then
        Event.Brocast("vip4_ffyd_refresh")
        M.RefreshLeftPrefab()
    end
    if id == 10295 then
        --vip4直通 礼包购买后 立马将VIP4专属礼包的状态设置为1 ，服务器刷新会有延迟
        MainModel.UserInfo.GiftShopStatus[10316] = MainModel.UserInfo.GiftShopStatus[10316] or {}
        MainModel.UserInfo.GiftShopStatus[10316].status = 1
        Event.Brocast("ui_button_data_change_msg",{key = M.key})
    end
    if id == 10319 then
        Event.Brocast("ui_button_data_change_msg",{key = M.key})
    end
end

function M.IsCareShopID(id)
    for i = 1,#M.shop_ids do
        if M.shop_ids[i] == id then
            return i
        end
    end
end

function M.GetCanBuyShopIDIndex()
    for i = 1,#M.shop_ids do
        if MainModel.GetGiftShopStatusByID(M.shop_ids[i]) == 1 then
            return i
        end
    end
end

function M.BuyShop(shopid)
    local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not gb then return end
	local price = gb.price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end
local PS
function M.on_game_act_left_prefab_created(data)
    if data and data.panelSelf then
        if data.panelSelf.config.parmData == M.key then
            PS = data.panelSelf
            M.RefreshLeftPrefab()
        end
    end
end

local str = {"VIP4专属礼包","VIP4专属礼包Ⅱ","VIP4专属礼包Ⅲ","VIP5直通礼包"}
function M.RefreshLeftPrefab()
   if PS and IsEquals(PS.gameObject) then
        PS.title1_txt.text = str[M.GetCanBuyShopIDIndex()]
        PS.title2_txt.text = str[M.GetCanBuyShopIDIndex()]
   end
end

function M.on_vip_upgrade_change_msg(_,data)
    if data.vip_level == 5 then
        Event.Brocast("ui_button_data_change_msg",{key = M.key})
    end
end

function M.shop_info_get()
    M.RefreshLeftPrefab()
end