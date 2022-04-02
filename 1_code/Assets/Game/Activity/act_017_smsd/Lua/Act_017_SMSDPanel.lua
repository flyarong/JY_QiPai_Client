-- 创建时间:2020-06-10
-- Panel:Act_017_SMSDPanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

Act_017_SMSDPanel = basefunc.class()
local C = Act_017_SMSDPanel
C.name = "Act_017_SMSDPanel"
local M = Act_017_SMSDManager
local base_data = M.base_data

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	for k , v in pairs(self.timers) do
		if v then
			v:Stop()
		end
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.timers = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	for i = 1,#base_data do
		self:ShopItemCreator(base_data[i].shop_id,self.ItemNode,base_data[i].tag)
	end
	self.close_btn.onClick:AddListener(function ()
		self:MyExit()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end
--奖励 
function C:AwardItemCreator(item_key,num,parent)
	if item_key == "discount_fish_coin" then
		item_key = "fish_coin"
	end
	local item = GameItemModel.GetItemToKey(item_key)
	if item then
		local b = GameObject.Instantiate(self.award_item,parent)
		b.gameObject:SetActive(true)
		local temp_ui = {}
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.award_img.sprite = GetTexture(item.image)
		temp_ui.award_txt.text = "x"..num
		return b
	end
end

function C:ShopItemCreator(shop_id,parent,tag)
	-- local t = M.AutoRefreshNumAtText(shop_id,temp_ui.award_txt)
	-- self.timers[#self.timers + 1] = t
	local temp_ui = {}
	local config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag,shop_id)
	local b = GameObject.Instantiate(self.shop_item,parent)
	b.gameObject:SetActive(true)
	LuaHelper.GeneratingVar(b.transform,temp_ui)
	temp_ui.money_txt.text = (config.price/100).."元"
	for i = 1,#config.buy_asset_type do
		self:AwardItemCreator(config.buy_asset_type[i],config.buy_asset_count[i],temp_ui.AwardNode)
	end
	if tag then
		temp_ui.tag_img.gameObject:SetActive(true)
		temp_ui.tag_img.sprite = GetTexture(tag)
	end
	local t1 = M.AutoRefreshNumAtText(shop_id,temp_ui.num_txt)
	self.timers[#self.timers + 1] = t1

	local t2 = M.AutoRefreshButtonStatus(temp_ui.get_btn,temp_ui.ButtonMask,shop_id)
	self.timers[#self.timers + 1] = t2
	temp_ui.get_btn.onClick:AddListener(
		function ()
			self:Buy(shop_id)
		end
	)
end

function C:Buy(shop_id)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shop_id).price
	if price == 0 then 
		self:Pay4Free(shop_id)
	else
		self:BuyShop(shop_id)
	end 
end

function C:BuyShop(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:Pay4Free(goodsid)
	local request = {}
    request.goods_id = goodsid
    request.channel_type = "weixin"
    request.geturl = MainModel.pay_url and "n" or "y"
    request.convert = self.convert
    dump(request, "<color=green>创建订单</color>")
    Network.SendRequest(
        "create_pay_order",
        request,
        function(_data)
            dump(_data, "<color=green>返回订单号</color>")
            if _data.result == 0 then
                MainModel.pay_url = _data.url or MainModel.pay_url
                local url = string.gsub(MainModel.pay_url, "@order_id@", _data.order_id)
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
end