-- 创建时间:2019-05-23
-- Panel:GameShop1YuanPanel

local basefunc = require "Game.Common.basefunc"

GameShop1YuanPanel = basefunc.class()
local C = GameShop1YuanPanel

C.name = "GameShop1YuanPanel"
local shopid = 10
local instance
function C.Create(parent, backcall)
	if not GameGlobalOnOff.LIBAO then
		if backcall then
			backcall()
		else
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end
		return
	end

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
	self.lister["finish_gift_shop_shopid_10"] = basefunc.handler(self, self.finish_gift_shop_shopid_10)
    self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()	 
	GameObject.Destroy(self.gameObject)
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
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
	    LuaHelper.AddDeferred(function()
            HintPanel.Create(1, "内购未完成")
            FullSceneJH.RemoveByTag("Shoping1YuanGiftBox")
        end)

        LuaHelper.AddPurchasingUnavailable(function()
            HintPanel.Create(1, "手机设置了禁止APP内购")
            FullSceneJH.RemoveByTag("Shoping1YuanGiftBox")
        end)

        LuaHelper.AddPurchaseFailed(function()
            HintPanel.Create(1, "购买失败")
            FullSceneJH.RemoveByTag("Shoping1YuanGiftBox")
        end)
    end

	self:MyRefresh()
end

function C:ReConnecteServerSucceed()
	self:MyRefresh()
end

function C:MyRefresh()
	if IsEquals(self.buy_btn) and IsEquals(self.disable_btn) then
		if self.status == 1 then -- 可以购买
			self.buy_btn.gameObject:SetActive(true)
			self.disable_btn.gameObject:SetActive(false)
		else
			self.buy_btn.gameObject:SetActive(false)
			self.disable_btn.gameObject:SetActive(true)
		end
	end
end

function C:OnBackClick()
	if self.backcall then
		self.backcall()
	end
	self:MyExit()
end

function C:OnShopClick()
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		self:BuyForIos()
	else
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
		PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100),
			function (result)
			end)
	end
end

function C:OnReceivePayOrderMsg(msg)
    if msg.result == 0 then
        -- UIPaySuccess.Create()
    else
        HintPanel.ErrorMsg(msg.result)
    end
    FullSceneJH.RemoveByTag("Shoping1YuanGiftBox")
end
function C:BuyForIos()
    local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not LuaHelper.OnPurchaseClicked(
        goodsData.product_id,
        function(receipt, transactionID,definition_id)
            local order = {}
            order.transactionId = transactionID
            order.productId = goodsData.product_id
			order.receipt = receipt
			order.definition_id = definition_id
            --是否用沙盒支付 0-no  1-yes
            order.isSandbox = GameGlobalOnOff.PGPayFun and 1 or 0

            IosPayManager.AddOrder(order)
        end) then
    	HintPanel.Create(1, "暂时无法连接iTunes Store，请稍后购买")
    	return
    end
    FullSceneJH.Create("", "Shoping1YuanGiftBox")
end

function C:finish_gift_shop_shopid_10()
	self.status = 0
	self:OnBackClick()
end

function C:OnExitScene()
	self:MyExit()
end
