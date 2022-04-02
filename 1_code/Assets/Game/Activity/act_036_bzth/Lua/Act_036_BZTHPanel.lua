-- 创建时间:2020-10-19
-- Panel:Act_036_BZTHPanel
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
-- 取消按钮音效
-- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
-- 确认按钮音效
-- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
--]]

local basefunc = require "Game/Common/basefunc"

Act_036_BZTHPanel = basefunc.class()
local C = Act_036_BZTHPanel
C.name = "Act_036_BZTHPanel"
local M = Act_036_BZTHManager
local nor_outline_color = Color.New(197/255,50/255,50/255)
local gray_outline_color = Color.New(112/255,86/255,86/255)
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["bztg_036_refresh"] = basefunc.handler(self,self.on_bztg_036_refresh)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.get_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.GotoUI({gotoui = "game_MiniGame"})
		end
	)
	self:InitMainUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.items = self.items
	for i = 1,#M.config do
		local data = M.GetShopData(M.config[i].shop_id)
		if data then
			if data > 0 then
				self.item_img.sprite = GetTexture("bzth_bg_2")
				self.items[i].award_txt.gameObject.transform:GetComponent("Outline").effectColor = nor_outline_color
				self.items[i].yj_txt.color = nor_outline_color
				self.items[i].need2_txt.color = nor_outline_color
				self.items[i].need1_txt.color = nor_outline_color
				self.items[i].gary_im.gameObject:SetActive(false)
				self.items[i].can.gameObject:SetActive(true)
				self.items[i].over.gameObject:SetActive(false)
				if GameItemModel.GetItemCount("prop_bzth_coupon") < M.config[i].need_xfq then
					self.items[i].need2_txt.color = gray_outline_color
					self.items[i].need1_txt.color = gray_outline_color
					self.items[i].gary_im.gameObject:SetActive(true)
				end
				if not M.config[i].wuxian then
					self.items[i].remian_txt.text = "剩"..data
				end
			else
				self.item_img.sprite = GetTexture("bzth_dk_1")
				self.items[i].award_txt.gameObject.transform:GetComponent("Outline").effectColor = gray_outline_color
				self.items[i].yj_txt.color = gray_outline_color
				self.items[i].need2_txt.color = gray_outline_color
				self.items[i].need1_txt.color = gray_outline_color
				self.items[i].can.gameObject:SetActive(false)
				self.items[i].over.gameObject:SetActive(true)
				if not M.config[i].wuxian then
					self.items[i].remian_txt.text = "剩"..data
				end
			end
		end
	end
	self.num_txt.text = GameItemModel.GetItemCount("prop_bzth_coupon")
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_bztg_036_refresh()
	self:MyRefresh()
end
--
function C:InitMainUI()
	self.items = {}
	for i = 1,#M.config do
		local b = GameObject.Instantiate(self.main_item,self.node)
		b.gameObject:SetActive(true)
		local temp = {}
		LuaHelper.GeneratingVar(b.transform,temp)
		self.items[#self.items + 1] = temp
		temp.yj_txt.text = M.config[i].yuanjia
		temp.award_txt.text = M.config[i].award_name
		temp.award_img.sprite = GetTexture(M.config[i].award_image)
		local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, M.config[i].shop_id).price
		if price == 0 then
			temp.need1_txt.text = "消耗"
			temp.need2_txt.text = M.config[i].need_xfq
		else
			temp.need1_txt.text = "¥"..(price/100).."+"
			temp.need2_txt.text = M.config[i].need_xfq
		end
		if M.config[i].tips then
			PointerEventListener.Get(temp.award_img.gameObject).onDown = function ()
				GameTipsPrefab.ShowDesc(M.config[i].tips, UnityEngine.Input.mousePosition)
			end
			PointerEventListener.Get(temp.award_img.gameObject).onUp = function ()
				GameTipsPrefab.Hide()
			end
		end
		if not M.config[i].wuxian then
			temp.remain.gameObject:SetActive(true)
		else
			temp.remain.gameObject:SetActive(false)
		end
		temp.exchange_btn.onClick:AddListener(
			function()				
				if GameItemModel.GetItemCount("prop_bzth_coupon") >= M.config[i].need_xfq then
					self:Buy(M.config[i].shop_id)
				else
					LittleTips.Create("您的消费券不足")
				end
			end
		)
	end
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