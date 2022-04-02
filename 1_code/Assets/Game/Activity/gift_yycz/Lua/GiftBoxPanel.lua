local basefunc = require "Game/Common/basefunc"

GiftBoxPanel = basefunc.class()

GiftBoxPanel.name = "GiftBoxPanel"

local instance = nil
function GiftBoxPanel.Create()
	if not instance then
		instance = GiftBoxPanel.New()
	end
	return instance
end

--启动事件--
function GiftBoxPanel:ctor()

	ExtPanel.ExtMsg(self)


	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(GiftBoxPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	
	self:InitUI()
end

function GiftBoxPanel:MyExit()
	FullSceneJH.RemoveByTag("ShopingGoldGiftBox")
	self:RemoveListener()
	destroy(self.gameObject)
end

function GiftBoxPanel.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function GiftBoxPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GiftBoxPanel:MakeLister()
    self.lister = {}
    self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
    self.lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
    self.lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function GiftBoxPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function GiftBoxPanel:OnReceivePayOrderMsg(msg)
    if msg.result == 0 then
        UIPaySuccess.Create()
    else
        HintPanel.ErrorMsg(msg.result)
    end
    FullSceneJH.RemoveByTag("ShopingGoldGiftBox")
end

function GiftBoxPanel:OnExitScene()
    GiftBoxPanel.Close()
end

function GiftBoxPanel:InitUI()
	LuaHelper.AddDeferred(function()
		HintPanel.Create(1, "内购未完成")
		FullSceneJH.RemoveByTag("ShopingGoldGiftBox")
	end)

	LuaHelper.AddPurchasingUnavailable(function()
		HintPanel.Create(1, "手机设置了禁止APP内购")
		FullSceneJH.RemoveByTag("ShopingGoldGiftBox")
	end)

	LuaHelper.AddPurchaseFailed(function()
		HintPanel.Create(1, "购买失败")
		FullSceneJH.RemoveByTag("ShopingGoldGiftBox")
	end)

	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GiftBoxPanel.Close()
	end)

	self.buy_btn.onClick:AddListener(function()
		local product_id = "com.jyjjddz.zs.diamond1"
		if not LuaHelper.OnPurchaseClicked(
			product_id,
			function(receipt, transactionID,definition_id)
			local order = {}
			order.transactionId = transactionID
			order.definition_id = definition_id
			order.productId = product_id
			order.receipt = receipt
			--是否用沙盒支付 0-no  1-yes
			order.isSandbox = GameGlobalOnOff.PGPayFun and 1 or 0

			IosPayManager.AddOrder(order)
		    end
		) then
			HintPanel.Create(1, "暂时无法连接iTunes Store，请稍后购买")
			return
		end
		FullSceneJH.Create("", "ShopingGoldGiftBox")
	end)
end
