-- 创建时间:2019-05-15
-- Panel:PayFastMatchPanel
-- 快速购买 礼包

local basefunc = require "Game.Common.basefunc"

PayFastMatchPanel = basefunc.class()

local CreateURLCall = function ()
    MainLogic.IsHideAssetsGetPanel = true
end

function PayFastMatchPanel.Create(config, signup)
    dump(config, "<color=#FF8109FF>快速购买 PayFastMatchPanel config</color>")
    if config.gift_id == 80 or config.gift_id == 82 then 
        Event.Brocast("show_gift_panel")
        return 
    else 
        return PayFastMatchPanel.New(config, signup)
    end    
end

function PayFastMatchPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function PayFastMatchPanel:MakeLister()
    self.lister = {}
    self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function PayFastMatchPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function PayFastMatchPanel:ctor(config, signup)

	ExtPanel.ExtMsg(self)

    self:MakeLister()
    self:AddMsgListener()

    self.config = config
    self.signup = signup
    -- 自动兑换成金币
    self.convert = GOODS_TYPE.jing_bi
    -- 只有安卓加了快速充值礼包
    self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.config.gift_id)
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
    	self.jingbi_config = MainModel.GetShopingConfig(GOODS_TYPE.jing_bi, self.config.ios_pay_id)
    else
	    self.jingbi_config = MainModel.GetShopingConfig(GOODS_TYPE.jing_bi, self.config.pay_id)
    end
    dump(self.jingbi_config,"<color=white>jingbi_config</color>")
    dump(self.gift_config,"<color=white>jingbi_config</color>")
    -- 是否是礼包购买
    self.is_pay_gift = false

    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject("PayFastMatchPanel", self.parent.transform)
    LuaHelper.GeneratingVar(self.gameObject.transform, self)
    self.CenterRectTransform = self.CenterRect:GetComponent("RectTransform")

   	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
   	    self.hint_node2_txt.text = "<color=#B98109FF>将自动为您购买<color=#FB9474FF>" .. self.jingbi_config.ui_price .. "</color>的钻石并兑换成鲸币</color>"
    	self.is_pay_gift = false
    	self.num_info_txt.transform.localPosition = Vector3.New(105.2, 242, 0)
    	self.hint_node3.gameObject:SetActive(false)
    	self.hint_node1.gameObject:SetActive(false)
        self.CenterRectTransform.sizeDelta = {x=1022, y=652}
	else
        self.hint_node2_txt.text = "<color=#B98109FF>将自动为您购买<color=#FB9474FF>" .. self.jingbi_config.ui_price .. "元</color>的钻石并兑换成鲸币</color>"
        self.CenterRectTransform.sizeDelta = {x=1022, y=652}
        if self.gift_config then
            self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)
        end
        if self.status == 1 then
			self.is_pay_gift = true
		    self.num_info_txt.transform.localPosition = Vector3.New(105.2, 204, 0)
		    self.hint_node3.gameObject:SetActive(false)
		    self.hint_node1.gameObject:SetActive(true)
        else
			self.is_pay_gift = false
		    self.num_info_txt.transform.localPosition = Vector3.New(105.2, 204, 0)
		    self.hint_node3.gameObject:SetActive(false)
		    self.hint_node1.gameObject:SetActive(false)
        end

	end
    self.close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:Close()
    end)
    self.confirm_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnConfirmClick()
    end)

    self:InitRect()
end
function PayFastMatchPanel:InitRect()
	if self.is_pay_gift then
	    self.num_info_txt.text = StringHelper.ToCash(tonumber(self.config.signup_item_count[#self.config.signup_item_count]) - MainModel.UserInfo.jing_bi)
        self.jing_bi_txt.text = StringHelper.ToCash(self.gift_config.buy_asset_count[1]) .. "鲸币"
        self.hint_node2_txt.text = "<color=#B98109FF>将为您购买<color=#FB9474FF>" .. self.gift_config.price / 100 .. "元</color>的礼包</color>"
	else
	    self.num_info_txt.text = StringHelper.ToCash(tonumber(self.config.signup_item_count[#self.config.signup_item_count]) - MainModel.UserInfo.jing_bi)
	    self.jing_bi_txt.text = self.jingbi_config.ui_title
	end
end

function PayFastMatchPanel:OnConfirmClick()
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        self:BuyForIos()
    else
    	if self.status == 1 then
			PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100), function (result)
	            if result == 0 then
	                self:Close()
	            else
		            print("<color=blue>EEEEEE 快速购买 礼包 result: " .. result .. "</color>")
	            end
			end)    		
    	else
		    local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.goods, self.jingbi_config.goods_id)
			PayTypePopPrefab.Create(goodsData.id, goodsData.ui_price, function (result)
	            if result == 0 then
	                self:Close()
	            else
		            print("<color=blue>EEEEEE 快速购买 商品 result: " .. result .. "</color>")
	            end
			end, self.convert)
    	end
	end
end

function PayFastMatchPanel:BuyForIos()
    local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.goods, self.jingbi_config.goods_id)
    if not LuaHelper.OnPurchaseClicked(
        goodsData.product_id,
        function(receipt, transactionID,definition_id)
            local order = {}
            order.transactionId = transactionID
            order.productId = goodsData.product_id
            order.definition_id = definition_id
            order.receipt = receipt
            order.convert = self.convert
            --是否用沙盒支付 0-no  1-yes
            order.isSandbox = GameGlobalOnOff.PGPayFun and 1 or 0

            IosPayManager.AddOrder(order)
        end
    )then
    	HintPanel.Create(1, "暂时无法连接iTunes Store，请稍后购买")
    	return
    end
end

function PayFastMatchPanel:OnExitScene()
    self:Close()
end

function PayFastMatchPanel:OnReceivePayOrderMsg(msg)
    if msg.result == 0 then
        self:CreateUIPaySuccess(msg)
    else
        HintPanel.ErrorMsg(msg.result)
    end
end

function PayFastMatchPanel:CreateUIPaySuccess(msg)
    UIPaySuccess.Create(function()
        self:Close()
    end)
end

function PayFastMatchPanel:MyExit()
    if IsEquals(self.gameObject) then
        destroy(self.gameObject)
    end
    self:RemoveListener()
end

function PayFastMatchPanel:Close()
    self:MyExit()
end


