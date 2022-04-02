-- 创建时间:2019-05-23
-- Panel:GameShop3YuanPanel

local basefunc = require "Game.Common.basefunc"

GameShop3YuanPanel = basefunc.class()
local C = GameShop3YuanPanel

C.name = "GameShop3YuanPanel"
local shopid = 72
local instance
function C.Create(parent, backcall)
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
	if not gift_config or gift_config.on_off == 0 then
		return
	end
	if instance then
		return instance
	end
	instance = C.New(parent, backcall)
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
	self.lister["finish_gift_shop_shopid_72"] = basefunc.handler(self, self.finish_gift_shop_shopid_72)
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
	instance = nil
end
function C:MyClose()
	self:MyExit()
	instance = nil
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
	LuaHelper.GeneratingVar(self.transform, self)

	self.buy_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnShopClick()
	end)
	self.CloseBuy_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
	end)

	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
	self.status = MainModel.GetGiftShopStatusByID(gift_config.id)
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:ReConnecteServerSucceed()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.status == 1 then -- 可以购买
		self.buy_btn.gameObject:SetActive(true)
		self.disable_btn.gameObject:SetActive(false)
	else
		self.buy_btn.gameObject:SetActive(false)
		self.disable_btn.gameObject:SetActive(true)
	end
end

function C:OnBackClick()
	self:MyClose()
	if self.backcall then
		self.backcall()
	end
end

function C:OnShopClick()
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取3元超值礼包"})
	else
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100),
			function (result)
			end)
	end
end

function C:finish_gift_shop_shopid_72()
	self.status = 0
	self:OnBackClick()
end

function C:OnExitScene()
	self:MyExit()
end