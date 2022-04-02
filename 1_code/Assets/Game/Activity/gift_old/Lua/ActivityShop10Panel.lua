-- 创建时间:2018-11-23
-- 10元活动商品

local basefunc = require "Game.Common.basefunc"

ActivityShop10Panel = basefunc.class()
local M = ActivityShop10Panel

M.name = "ActivityShop10Panel"

local instance
function M.Create(parent, backcall)
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 8)
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
    self.lister["finish_gift_shop_shopid_8"] = basefunc.handler(self, self.finish_Shop_8_gift_bag)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["model_query_gift_bag_num_shopid_8"] = basefunc.handler(self, self.model_query_gift_bag_num)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	destroy(self.gameObject)
	self:RemoveListener()
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

	self.Hint1Text = tran:Find("NoActivityRect/HintText"):GetComponent("Text")
	self.Hint2Text = tran:Find("ActivityRect/HintText"):GetComponent("Text")

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

    self.Copy1Button = tran:Find("NoActivityRect/Copy1Button"):GetComponent("Button")
    self.Copy1Button.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnCopy1Click()
    end)
    self.Copy2Button = tran:Find("NoActivityRect/Copy2Button"):GetComponent("Button")
    self.Copy2Button.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnCopy2Click()
    end)
    self.DHButton = tran:Find("DHButton"):GetComponent("Button")
    self.DHButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnDHClick()
    end)

    self.TipsList = {"可通过商城兑换物品",
    "鲸币可用于公益锦标赛打比赛赢福卡",
    "使用记牌器打斗地主获胜的概率更高",
	"联系商户微信开头合伙人资格每邀1人赚5元"}
    for i = 1, 4 do
    	local obj = tran:Find("Tips" .. i)
    	obj.name = i
	    EventTriggerListener.Get(obj.gameObject).onDown = basefunc.handler(self, self.OnDown)
	    EventTriggerListener.Get(obj.gameObject).onUp = basefunc.handler(self, self.OnUp)
    end
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 8)
    self.status = MainModel.GetGiftShopStatusByID(gift_config.id)
	self:InitUI()
end

function M:InitUI()
	self:MyRefresh()
end

function M:RefreshNum()
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 8)
	MainModel.GetGiftShopNumByID(gift_config.id)
end

function M:model_query_gift_bag_num(data)
	local ss = "礼包剩余份数：" .. data.count .. "(售完即止)"
	self.gift_num = data.count
	self.Hint1Text.text = ss
	self.Hint2Text.text = ss
end

function M:MyRefresh()
	self:RefreshNum()
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

function M:OnDown(obj)
    local key = obj.transform.name
    local pos = UnityEngine.Input.mousePosition
    GameTipsDescPrefab.Show(self.TipsList[tonumber(key)], pos)
end

function M:OnUp()
    GameTipsDescPrefab.Hide()
end

function M:OnBackClick()
	self:MyExit()
	if self.backcall then
		self.backcall()
	end
end

function M:OnShopClick()
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取充6元送7元礼包"})
	else
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 8)
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100), function (result)
			if result == 3403 then
				self:RefreshNum()
			end
		end)
	end
end

function M:finish_Shop_8_gift_bag()
	self.status = 0
	self:MyRefresh()
end

function M:OnExitScene()
	self:MyExit()
end

function M:OnCopy1Click()
	UniClipboard.SetText("JY400888")
	LittleTips.Create("已复制微信号请前往微信进行添加")
end

function M:OnCopy2Click()
	UniClipboard.SetText("4008882620")
	LittleTips.Create("已复制QQ号请前往QQ进行添加")	
end

function M:OnDHClick()
	MainModel.OpenDH()
end

