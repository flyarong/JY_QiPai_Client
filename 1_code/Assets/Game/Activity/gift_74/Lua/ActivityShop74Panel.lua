-- 创建时间:2019-06-05
-- Panel:ActivityShop74Panel
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

ActivityShop74Panel = basefunc.class()
local C = ActivityShop74Panel
C.name = "ActivityShop74Panel"

local instance
local shopid = 74
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
	self.lister["finish_gift_shop_shopid_"..shopid] = basefunc.handler(self, self.finish_gift_shop_shopid)
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
	self.PayButton = tran:Find("PayButton"):GetComponent("Button")
	self.PayButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnPayClick()
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

function C:OnPayClick()
	if self.status == 0 then
		HintPanel.Create(1, "您已经购买过此商品了，不能重复购买")
		return
	end
    local config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
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

function C:finish_gift_shop_shopid()
	self.status = 0
	self:OnBackClick()
end

function C:OnExitScene()
	self:MyExit()
end