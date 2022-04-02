-- 创建时间:2019-03-29
-- 踏青礼包

local basefunc = require "Game/Common/basefunc"

ActivityShop18Panel = basefunc.class()
local C = ActivityShop18Panel
C.name = "ActivityShop18Panel"

local instance
local shopid = 38
function C.Create(parent, backcall)
	if not instance then
		instance = C.New(parent, backcall)
	else
		instance:MyRefresh()
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	self.lister["finish_gift_shop_shopid_38"] = basefunc.handler(self, self.finish_gift_shop_shopid_38)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	destroy(self.gameObject)
	self:RemoveListener()
	instance=nil

	 
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.ActivityRect = tran:Find("ActivityRect")
	self.NoActivityRect = tran:Find("NoActivityRect")

	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)

	self.ShopButton = tran:Find("ActivityRect/ShopButton"):GetComponent("Button")
    self.ShopButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnShopClick()
	end)

	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
	self.status = MainModel.GetGiftShopStatusByID(gift_config.id)
	local s1, e1, s2, e2 = self:GetTime(gift_config)
	tran:Find("time_txt"):GetComponent("Text").text = "活动时间：" .. s2.month .. "月" .. s2.day .. "日" .. s1 .. "--" .. e2.month .. "月" .. e2.day .. "日" .. e1

	self:InitUI()
end

function C:GetTime(gift_config)
	local s1 = os.date("%H:%M", gift_config.start_time)
	local e1 = os.date("%H:%M", gift_config.end_time)
	local s2 = os.date("*t", gift_config.start_time)
	local e2 = os.date("*t", gift_config.end_time)
	return s1, e1, s2, e2
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.status == 1 then -- 可以购买
		print("可以购买")
		self.ActivityRect.gameObject:SetActive(true)
		self.NoActivityRect.gameObject:SetActive(false)
	else
		print("不可以购买")
		self.ActivityRect.gameObject:SetActive(false)
		self.NoActivityRect.gameObject:SetActive(true)
	end
end

function C:OnBackClick()
	self:MyExit()
	if self.backcall then
		self.backcall()
	end
end

function C:OnShopClick()
    local config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    local b1 = MathExtend.isTimeValidity(config.start_time, config.end_time)

    if b1 then
		if self.status ~= 1 then
			local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
			local s1, e1, s2, e2 = self:GetTime(gift_config)
			HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。\n(%s月%s日%s点-%s月%s日%s点每天可购买1次)",s2.month,s2.day,s1,e2.month,e2.day,e1))
			return
		end
    else
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取夏日回馈礼包"})
	else
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100),
			function (result)
			end)
	end
end

function C:ReConnecteServerSucceed()
	self:MyRefresh()
end

function C:finish_gift_shop_shopid_38()
	self.status = 0
	self:MyRefresh()
end

function C:OnExitScene()
	self:MyExit()
end
