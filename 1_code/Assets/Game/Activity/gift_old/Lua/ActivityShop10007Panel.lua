-- 创建时间:2019-05-27
-- Panel:ActivityShop77Panel
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
-- 七夕节礼包
local basefunc = require "Game/Common/basefunc"

ActivityShop10007Panel = basefunc.class()
local C = ActivityShop10007Panel
C.name = "ActivityShop10007Panel"

local instance
local shopid = 10007
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
	self.lister["EnterForeGround"] = basefunc.handler(self, self.onEnterForeGround)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	self.lister["finish_gift_shop_shopid_" .. shopid] = basefunc.handler(self, self.finish_gift_shop_shopid)
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

	self.ShopButton = tran:Find("BuyButton"):GetComponent("Button")
	self.ShopButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnShopClick()
	end)
	self.TimeText = tran:Find("TimeText"):GetComponent("Text")

	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
	self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)
	
	self:InitUI()
end

function C:UpdateTime()
	local str = StringHelper.formatTimeDHMS(self.time)
	if IsEquals(self.TimeText) then
		self.TimeText.text = "剩余时间：" .. str
	end

	if self.time <= 0 then
		if self.update_time then
			self.update_time:Stop()
		end
		self.update_time = nil
	end
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.time = self.gift_config.end_time - os.time()

	self.update_time = Timer.New(function ()
		self.time = self.time - 1
		self:UpdateTime()
	end, 1, -1, nil, true)
	self.update_time:Start()
	self:UpdateTime()
end

function C:OnBackClick()
	self:MyExit()
	if self.backcall then
		self.backcall()
	end
end

function C:OnShopClick()
    local b1 = MathExtend.isTimeValidity(self.gift_config.start_time, self.gift_config.end_time)

    if b1 then
		if self.status ~= 1 then
			local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
			local s1 = os.date("%m月%d日%H点", self.gift_config.start_time)
			local e1 = os.date("%m月%d日%H点", self.gift_config.end_time)
			HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。\n(%s-%s每天可购买1次)",s1,e1))
			return
		end
    else
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100))
	end
end

function C:ReConnecteServerSucceed()
	self:MyRefresh()
end

function C:finish_gift_shop_shopid()
	self.status = 0
	self:MyRefresh()
end

function C:OnExitScene()
	self:MyExit()
end

function C:onEnterForeGround()
	self:MyRefresh()
end

function C:onEnterBackGround()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
end
