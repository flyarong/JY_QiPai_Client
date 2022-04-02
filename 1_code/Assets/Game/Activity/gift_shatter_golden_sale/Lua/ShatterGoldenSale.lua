local basefunc = require "Game.Common.basefunc"

ShatterGoldenSale = basefunc.class()
ShatterGoldenSale.name = "ShatterGoldenSale"

local instance = nil

local lister = {}
function ShatterGoldenSale:MakeLister()
	lister = {}

	lister["view_sge_close"] = basefunc.handler(self, self.handle_sge_close)
	lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)

	--if gameRuntimePlatform == "Ios" then
		--lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
	--end

	---lister["view_sge_sale_countdown"] = basefunc.handler(self, self.handle_sge_sale_countdown)
end

function ShatterGoldenSale.Create(parent, hammer_idx, closeCbk)
	if not instance or not IsEquals(instance.gameObject) then
		instance = ShatterGoldenSale.New(parent, hammer_idx, closeCbk)
	end
	return instance
end

function ShatterGoldenSale:ctor(parent, hammer_idx, closeCbk)
	parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(ShatterGoldenSale.name, parent)
	self.transform = obj.transform
	self.gameObject = obj.gameObject
	self.closeCbk = closeCbk
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	ShatterGoldenEggLogic.setViewMsgRegister(lister, ShatterGoldenSale.name)

	self:InitRect(hammer_idx)
end

function ShatterGoldenSale:MyExit()
	if self._timer then 
		self._timer:Stop()
	end 
	self._timer = nil 
	if self.closeCbk then
		self.closeCbk(self.isBought)
	end
	ShatterGoldenEggLogic.clearViewMsgRegister(ShatterGoldenSale.name)
	self:ClearAll()
	destroy(self.transform.gameObject)
	instance = nil
end

function ShatterGoldenSale.IsShow()
	if not instance then return false end
	return instance.transform.gameObject.activeSelf
end

function ShatterGoldenSale:InitRect(hammer_idx)
	local transform = self.transform
	self.hammer_idx = hammer_idx

	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		LuaHelper.AddDeferred(function()
			HintPanel.Create(1, "内购未完成")
			FullSceneJH.RemoveByTag("ShatterGoldenSale")
		end)

		LuaHelper.AddPurchasingUnavailable(function()
			HintPanel.Create(1, "手机设置了禁止APP内购")
			FullSceneJH.RemoveByTag("ShatterGoldenSale")
		end)

		LuaHelper.AddPurchaseFailed(function()
			HintPanel.Create(1, "购买失败")
			FullSceneJH.RemoveByTag("ShatterGoldenSale")
		end)
	end

	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)

	local logic = ShatterGoldenEggModel.getLogicConfig(hammer_idx)
	if not logic or not logic.sale then
		print("[ZJD] ShatterGoldenSale exception. sale is nil:" .. hammer_idx)
		return
	end
	local sale = logic.sale
	local item_id = sale.item_id
	local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, item_id)

	self.buy_btn.onClick:AddListener(function()
		if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
			--[[local product_id = sale.product_id
			LuaHelper.OnPurchaseClicked(
				product_id,
				function(receipt, transactionID)
					local order = {}
					order.transactionId = transactionID
					order.productId = product_id
					order.receipt = receipt
					--是否用沙盒支付 0-no  1-yes
					order.isSandbox = GameGlobalOnOff.PGPayFun and 1 or 0

					IosPayManager.AddOrder(order)
			end)
			FullSceneJH.Create("", "ShatterGoldenSale")]]--

			GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取敲敲乐限时特惠礼包"})
		else
			PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100), function (result)
				if result == 0 then
					self.isBought = true
					self:MyExit()
				end
			end)
		end
	end)

	self.icon_img.sprite = GetTexture(logic.icon == "zjd_icon16_activity_gift_shatter_golden_sale" and "com_award_icon_cz31" or logic.icon)
	self.name_txt.text = string.format(sale.item_title, gift_config.buy_asset_count[1])
	local btn_img = self.buy_btn.gameObject:GetComponent("Image")
	btn_img.sprite = GetTexture(sale.item_btn)

	self:InitTimer()
end

function ShatterGoldenSale:Refresh()
	local transform = self.transform
	if not IsEquals(transform) then return end

end

function ShatterGoldenSale:ClearAll()
	if IsEquals(self.transform) then
		self.transform:SetParent(nil)
	end

	Event.Brocast("view_sge_sale_close", self.hammer_idx)
	self.hammer_idx = 0
end

function ShatterGoldenSale:handle_sge_close()
	self:MyExit()
end

function ShatterGoldenSale:OnReceivePayOrderMsg(msg)
	if msg.result == 0 then
		UIPaySuccess.Create()
	else
		HintPanel.ErrorMsg(msg.result)
	end
	FullSceneJH.RemoveByTag("ShatterGoldenSale")
end

function ShatterGoldenSale:OnExitScene()
	self:MyExit()
end


function ShatterGoldenSale:handle_sge_sale_countdown(data)
	if not IsEquals(self.timer_txt) then return end

	local txt = data.timer

	self.timer_txt.text = txt
	if txt == "00:00:00" and data.hammer_idx == self.hammer_idx then
		self:MyExit()
	end
end


function ShatterGoldenSale:InitTimer()
	local shop_id = self:GetGiftID()
	dump(shop_id, "shop_id=")
	if not shop_id then
		self:MyExit()
	else
		local t = MainModel.GetGiftEndTimeByID(shop_id)
		if t <= os.time() then
			self:MyExit()
		else
			self.countdown = t - os.time()
			self.timer_txt.text = ShatterGoldenEggLogic.FormatCountdownFimer(self.countdown)
			if self._timer then 
				self._timer:Stop()
			end 
			self._timer = nil 
			self._timer = Timer.New(function ()
				if IsEquals(self.timer_txt) then 
					self.countdown = self.countdown - 1  
					self.timer_txt.text  = 	ShatterGoldenEggLogic.FormatCountdownFimer(self.countdown)
					if self.countdown <= 0 then 
						self:MyExit()
					end 
				end 
			end,1,-1)
			self._timer:Start()	
		end
	end
end

function ShatterGoldenSale:GetGiftID()
	for i=1,#GameFlashSaleGiftManager.Config["qql"] do 
		if GameFlashSaleGiftManager.Config["qql"][i].idx == self.hammer_idx then 
			local shop_id = GameFlashSaleGiftManager.Config["qql"][i].gift_ids[1]
			return shop_id
		end
	end
end
--[[
	GetTexture("gy_18_1")
	GetTexture("gy_18_2")
	GetTexture("com_award_icon_cz31")
--]]