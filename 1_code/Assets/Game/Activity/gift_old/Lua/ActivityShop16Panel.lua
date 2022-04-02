-- 创建时间:2019-03-05
-- Panel:ActivityShop16Panel
local basefunc = require "Game/Common/basefunc"

ActivityShop16Panel = basefunc.class()
local C = ActivityShop16Panel
C.name = "ActivityShop16Panel"

local instance
local shopid = 29
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
	self.lister["finish_gift_shop_shopid_29"] = basefunc.handler(self, self.finish_gift_shop_shopid_28)
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

	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)

	self.BannerButton = tran:Find("BannerButton"):GetComponent("Button")
    self.BannerButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnShopClick()
	end)

	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
	self.status = MainModel.GetGiftShopStatusByID(gift_config.id)

	self:InitUI()
end

function C:InitUI()
end

function C:MyRefresh()
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
			HintPanel.Create(1, "您今日已购买过了，请明日再来购买。\n（3月15日9点-3月22日24点每天可购买1次）")
			return
		end
    else
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取礼包"})
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

function C:finish_gift_shop_shopid_28()
	self.status = 0
	self:MyRefresh()
end

function C:OnExitScene()
	self:MyExit()
end