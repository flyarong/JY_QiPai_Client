-- 创建时间:2020-05-06
-- Panel:Act_011_CZQDPanel
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

Act_012_CZQDPanel = basefunc.class()
local C = Act_012_CZQDPanel
C.name = "Act_012_CZQDPanel"
local M = Act_012_CZQDManager
local help_info = {
	[1]=
	{
		id = 1,
		text = "1.活动期间，连续7日领取话费礼包，必得2000话费碎片，价值20元",
	},
	[2]=
	{
		id = 2,
		text = "2.连续购买如果在某天断掉了，可通过补签购买的形式获得兑换券",
	},
	[3]=
	{
		id = 3,
		text = "3.活动时间结束后，兑换券会被清0，请您及时兑换",
	},
}
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
	self.lister["act_012_czqd_info_get"] = basefunc.handler(self,self.on_act_012_czqd_info_get)
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.Timer then
		self.Timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.award1_txt.text = "30000鲸币"
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:OnButtonClick(M.GetDayIndex() >= 7 and 7 or M.GetDayIndex())
	Network.SendRequest("tel_bill_data")
end

function C:InitUI()
	self.button_items = {}
	for i = 1,7 do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.button_item,self.buttonnode)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.mid_txt.text = "第"..i.."天"
		temp_ui.mask_txt.text = "第"..i.."天"
		self.button_items[i] = temp_ui
		temp_ui.click_btn.onClick:AddListener(
			function ()
				self:OnButtonClick(i)
			end
		)
	end
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			self:OpenHelpPanel()
		end
	)
	self.buy_btn.onClick:AddListener(
		function ()
			self:OnBuyBtnClick()
		end
	)
	self.get_btn.onClick:AddListener(
		function ()
			if GameItemModel.GetItemCount("prop_hfdhq") >= 7 then
				self:ExchangeGoods()
			else
				HintPanel.Create(1,"您的话费券不足！")
			end
		end
	)
end

function C:BuyNormalShop()
	self:BuyShop(M.Normal_shopid)
end

function C:BuyBuQianShop()
	self:BuyShop(M.BuQian_shopids[self.currIndex])
end

function C:ExchangeGoods()
	Network.SendRequest("pay_exchange_goods",
					{goods_type = "prop_web_chip_huafei", goods_id = 26},"购买道具",function (data)
						if data.result ~= 0 then
							HintPanel.ErrorMsg(data.result)
						end
					end)
end

function C:BuyShop(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:OnButtonClick(index)
	if not IsEquals(self.gameObject) then return end
	for i = 1,7 do
		self.button_items[i].mask.gameObject:SetActive(false)
	end
	if not IsEquals(self.button_items[index].mask) then return end
	self.button_items[index].mask.gameObject:SetActive(true)
	self.currIndex = index
	self:RefreshUI()
	--dump(index,"<color=red>按钮按下</color>")
end

function C:OnDestroy()
	self:MyExit()
end

function C:OpenHelpPanel()
	local str = help_info[1].text
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i].text
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:on_act_012_czqd_info_get()
	self:OnButtonClick(M.GetDayIndex() >= 7 and 7 or M.GetDayIndex())
	local data = M.GetMainData()
	self.title2_txt.text = "<size=40>当前拥有:</size>"..GameItemModel.GetItemCount("prop_hfdhq").."话费券"
	dump(data,"<color=red>主要数据00000</color>")
	if data and data.result == 0 then
		self.m_data = data
		if not table_is_null(data.days) then
			if self.m_data.start_time then
				self:InitTimer()
			else
				self.out_time_txt.gameObject:SetActive(false)
				if self.Timer then
					self.Timer:Stop()
				end
			end
			self:RefreshUI()
		end	
	end
end
--补签未购买
function C:status_1()
	self.tag_img.gameObject:SetActive(true)
	self.buy_btn.gameObject:SetActive(true)
	self.buy_txt.text = "6元领取"
	self.award1_txt.text = "60000鲸币"
	self.buy_mask.gameObject:SetActive(false)
end
--补签已购买
function C:status_2()
	self.tag_img.gameObject:SetActive(true)
	self.buy_btn.gameObject:SetActive(false)
	self.buy_mask.gameObject:SetActive(true)
	self.award1_txt.text = "60000鲸币"
end
--普通未购买
function C:status_3()
	self.tag_img.gameObject:SetActive(false)
	self.buy_mask.gameObject:SetActive(false)
	self.buy_btn.gameObject:SetActive(true)
	self.award1_txt.text = "30000鲸币"
	self.buy_txt.text = "3元领取"
end
--普通已购买
function C:status_4()
	self.tag_img.gameObject:SetActive(false)
	self.buy_btn.gameObject:SetActive(false)
	self.buy_mask.gameObject:SetActive(true)
	self.award1_txt.text = "30000鲸币"
end
--话费已领取
function C:status_5()
	self.get_mask.gameObject:SetActive(true)
	self.get_btn.gameObject:SetActive(false)
end
--话费未领取
function C:status_6()
	self.get_mask.gameObject:SetActive(false)
	self.get_btn.gameObject:SetActive(true)
end

function C:RefreshUI()
	if self.currIndex and self.m_data and self.m_data.days then
		dump(self.currIndex,"<color=red>当前选中+++++</color>")
		if self.m_data.days[self.currIndex] == 0 then
			if M.GetDayIndex() <= self.currIndex then
				self:status_3()
			else
				self:status_1()
			end
		elseif self.m_data.days[self.currIndex] == 1 then
			self:status_4()
		elseif self.m_data.days[self.currIndex] == 2 then
			self:status_2()
		end
		for i = 1,M.GetDayIndex() - 1 do
			if i <= 7 then
				if self.m_data.days[i] == 0 then
					self.button_items[i].buqian.gameObject:SetActive(true)
				else
					self.button_items[i].buqian.gameObject:SetActive(false)
				end
			end
		end
	end
end

function C:InitTimer()
	self.out_time_txt.gameObject:SetActive(true)
	self.data_time = (self.m_data.start_time or os.time()) + 8 * 86400 - os.time()
	if self.Timer then
		self.Timer:Stop()
	end
	self.out_time_txt.text = StringHelper.formatTimeDHMS3(self.data_time)
	self.Timer = Timer.New(function()
		self.data_time = self.data_time - 1
		self.out_time_txt.text = StringHelper.formatTimeDHMS3(self.data_time)
	end,1,-1)
	self.Timer:Start()
end

function C:OnBuyBtnClick()
	if self.currIndex and self.m_data then
		--买过礼包
		if self.m_data.days and self.m_data.days[self.currIndex] == 0 then
			if M.GetDayIndex() == self.currIndex then
				self:BuyNormalShop()
			elseif M.GetDayIndex() < self.currIndex then
				HintPanel.Create(1,"只能购买当天的礼包哦！")
			elseif M.GetDayIndex() > self.currIndex then
				self:BuyBuQianShop()
			end
		else--当一个礼包都没有买的时候
			if self.currIndex == 1 then
				self:BuyNormalShop()
			else
				HintPanel.Create(1,"只能购买当天的礼包哦！")
			end
		end
	end	
end

function C:OnAssetChange(_,data)
	Network.SendRequest("tel_bill_data")
end