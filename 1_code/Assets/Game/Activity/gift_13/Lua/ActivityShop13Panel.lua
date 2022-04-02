-- 创建时间:2018-12-27

local basefunc = require "Game.Common.basefunc"

ActivityShop13Panel = basefunc.class()
local M = ActivityShop13Panel

M.name = "ActivityShop13Panel"

local instance
function M.Create(parent, backcall)
	if not GameGlobalOnOff.LIBAO then
		PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		if backcall then
			backcall()
		end
		return
	end

	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 13)
	if not gift_config or gift_config.on_off == 0 then
		return
	end
	if instance then
		return instance
	end
	instance = M.New(parent, backcall)
	return instance
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	self.lister["finish_gift_shop_shopid_13"] = basefunc.handler(self, self.finish_gift_shop_shopid_13)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	instance = nil
	self:RemoveListener()
	destroy(self.gameObject)
end
function M:MyClose()
	self:MyExit()
	instance = nil
end

function M:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.ActivityRect = tran:Find("ActivityRect")
	self.NoActivityRect = tran:Find("NoActivityRect")

	self.HintText = tran:Find("HintText"):GetComponent("Text")
	self.RankText = tran:Find("RankText"):GetComponent("Text")

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
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 13)
	self.status = MainModel.GetGiftShopStatusByID(gift_config.id)
	self:InitUI()
end

function M:InitUI()
	self.HintText.text = "<color=#b95c15ff>每周二、四、六的21点公益锦标赛--千元大奖赛准时参赛哦！</color>"
	self.RankText.text = "<color=#b95c15ff>第一名：1000元现金\n第二名：300元现金\n第三名：100元现金</color>"
	self:MyRefresh()
end

function M:ReConnecteServerSucceed()
	self:MyRefresh()
end

function M:MyRefresh()
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

function M:OnBackClick()
	GameObject.Destroy(self.gameObject)
	self:MyExit()
	Event.Brocast("close_gift_shop_shopid_13")
	if self.backcall then
		self.backcall()
	end
end

function M:OnShopClick()
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取千元大奖赛礼包"})
	else
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 13)
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100),
			function (result)
			end)
	end
end

function M:finish_gift_shop_shopid_13()
	self.status = 0
	self:MyRefresh()
	Event.Brocast("call_finish_gift_shop_shopid_13")
end

function M:OnExitScene()
	self:MyExit()
end
