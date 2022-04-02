-- 创建时间:2019-05-15
-- Panel:PayFastFreePanel
-- 快速购买 礼包

local basefunc = require "Game.Common.basefunc"

PayFastFreePanel = basefunc.class()

local CreateURLCall = function ()
    MainLogic.IsHideAssetsGetPanel = true
end

function PayFastFreePanel.Create(config, signup)
    dump(config, "<color=#FF8109FF>快速购买 PayFastFreePanel config</color>")
        if config.gift_id == 61 or config.gift_id == 60 or config.gift_id == 64 or config.imageIndex == 4 then
            Event.Brocast("show_gift_panel")
            return 
        elseif config.gift_id == 80 or config.gift_id == 82 then 
            Event.Brocast("show_gift_panel")
            return 
        else        
            return PayFastFreePanel.New(config, signup)
        end
end

function PayFastFreePanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function PayFastFreePanel:MakeLister()
    self.lister = {}
    self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function PayFastFreePanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function PayFastFreePanel:ctor(config, signup)

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
    -- 是否是礼包购买
    self.is_pay_gift = false

    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject("PayFastFreePanel", self.parent.transform)
    LuaHelper.GeneratingVar(self.gameObject.transform, self)
    self.CenterRectTransform = self.CenterRect:GetComponent("RectTransform")
    dump(self.gift_config, "<color=white>self.gift_config</color>")
    local asset_types = self.gift_config.buy_asset_type
    local asset_counts =  self.gift_config.buy_asset_count
    for i = 1, #asset_counts do
        local item = GameItemModel.GetItemToKey(asset_types[i])
        if i ~= 3 then
            self["ard" .. i .. "_txt"].text = item.name .. "x" .. tostring(asset_counts[i])
        else
            self["ard" .. i .. "_txt"].text = item.name .. tostring(asset_counts[i]) .. "天"
        end
    end
    self.pay_txt.text = self.gift_config.price / 100 .. "元领取"
    self.confirm_btn.onClick:AddListener(function()
        PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100), function (result)
            if result == 0 then
                self:Close()
            else
                print("<color=blue>EEEEEE 快速购买 礼包 result: " .. result .. "</color>")
            end
        end)   
    end)

     self.close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if self.config and self.config.imageIndex and self.config.imageIndex < 2 then
            self:MyExit()
            Network.SendRequest("query_everyday_shared_award", {type="one_yuan_match"}, "查询请求", function (data)
                local can_share_num = data.status or 0
                if can_share_num > 0  then
                    GameManager.GotoUI({gotoui = "guide_to_match",goto_scene_parm = "panel",backcall = function ()
                        PayPanel.Create(GOODS_TYPE.jing_bi)
                    end})
                else
                    PayPanel.Create(GOODS_TYPE.jing_bi)
                end 
            end)
        else
            self:Close()
        end 
    end)

    --10.26 之前的代码 暂留
   	-- if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
   	--     self.hint_node2_txt.text = "<color=#B98109FF>将自动为您购买<color=#FB9474FF>" .. self.jingbi_config.ui_price .. "</color>的钻石并兑换成鲸币</color>"
    -- 	self.is_pay_gift = false
    -- 	self.num_info_txt.transform.localPosition = Vector3.New(105.2, 242, 0)
    -- 	self.hint_node3.gameObject:SetActive(false)
    -- 	self.hint_node1.gameObject:SetActive(false)
    --     self.CenterRectTransform.sizeDelta = {x=1022, y=652}
	-- else
    --     self.CenterRectTransform.sizeDelta = {x=1022, y=652}
    --     self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)
    --     if self.status == 1 then
    --         self.hint_node2_txt.text = "<color=#B98109FF>将自动为您购买<color=#FB9474FF>" .. "￥" .. (self.gift_config.price / 100) .. "元</color>的钻石并兑换成鲸币</color>"
	-- 		self.is_pay_gift = true
	-- 	    self.num_info_txt.transform.localPosition = Vector3.New(105.2, 204, 0)
	-- 	    self.hint_node3.gameObject:SetActive(false)
	-- 	    self.hint_node1.gameObject:SetActive(true)
    --     else
	--         self.hint_node2_txt.text = "<color=#B98109FF>将自动为您购买<color=#FB9474FF>" .. self.jingbi_config.ui_price .. "元</color>的钻石并兑换成鲸币</color>"
    -- 		self.is_pay_gift = false
	-- 	    self.num_info_txt.transform.localPosition = Vector3.New(105.2, 204, 0)
	-- 	    self.hint_node3.gameObject:SetActive(false)
	-- 	    self.hint_node1.gameObject:SetActive(false)
    --     end
	-- end
    -- self.close_btn.onClick:AddListener(function()
    --     ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    --     if self.config and self.config.imageIndex < 2 then
    --         self:MyExit()
    --         Network.SendRequest("query_everyday_shared_award", {type="one_yuan_match"}, "查询请求", function (data)
    --             local can_share_num = data.status or 0
    --             if can_share_num > 0  then
    --                 GameManager.GotoUI({gotoui = "guide_to_match",goto_scene_parm = "panel",backcall = function ()
    --                     PayPanel.Create(GOODS_TYPE.jing_bi)
    --                 end})
    --             else
    --                 PayPanel.Create(GOODS_TYPE.jing_bi)
    --             end 
    --         end)
    --     else
    --         self:Close()
    --     end 
    -- end)
    -- self.confirm_btn.onClick:AddListener(function()
    --     ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    --     self:OnConfirmClick()
    -- end)

    -- self:InitRect()
end
function PayFastFreePanel:InitRect()
	-- if self.is_pay_gift then
	--     self.num_info_txt.text = StringHelper.ToCash(tonumber(self.config.enterMin) - MainModel.UserInfo.jing_bi)
	--     self.jing_bi_txt.text = StringHelper.ToCash(self.gift_config.buy_asset_count[1]) .. "鲸币"
	-- else
	--     self.num_info_txt.text = StringHelper.ToCash(tonumber(self.config.enterMin) - MainModel.UserInfo.jing_bi)
	--     self.jing_bi_txt.text = self.jingbi_config.ui_title
	-- end
end

function PayFastFreePanel:OnConfirmClick()
	-- if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
    --     self:BuyForIos()
    -- else
    -- 	if self.status == 1 then
	-- 		PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100), function (result)
	--             if result == 0 then
	--                 self:Close()
	--             else
	-- 	            print("<color=blue>EEEEEE 快速购买 礼包 result: " .. result .. "</color>")
	--             end
	-- 		end)    		
    -- 	else
	-- 	    local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.goods, self.jingbi_config.goods_id)
	-- 		PayTypePopPrefab.Create(goodsData.id, goodsData.ui_price, function (result)
	--             if result == 0 then
	--                 self:Close()
	--             else
	-- 	            print("<color=blue>EEEEEE 快速购买 商品 result: " .. result .. "</color>")
	--             end
	-- 		end, self.convert)
    -- 	end
	-- end
end

function PayFastFreePanel:BuyForIos()
    -- local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.goods, self.jingbi_config.goods_id)
    -- if not LuaHelper.OnPurchaseClicked(
    --     goodsData.product_id,
    --     function(receipt, transactionID,definition_id)
    --         local order = {}
    --         order.transactionId = transactionID
    --         order.productId = goodsData.product_id
    --         order.definition_id = definition_id
    --         order.receipt = receipt
    --         order.convert = self.convert
    --         --是否用沙盒支付 0-no  1-yes
    --         order.isSandbox = GameGlobalOnOff.PGPayFun and 1 or 0

    --         IosPayManager.AddOrder(order)
    --     end
    -- )then
    -- 	HintPanel.Create(1, "暂时无法连接iTunes Store，请稍后购买")
    -- 	return
    -- end
end

function PayFastFreePanel:OnExitScene()
    self:Close()
end

function PayFastFreePanel:OnReceivePayOrderMsg(msg)
    if msg.result == 0 then
        --self:CreateUIPaySuccess(msg)
    else
        HintPanel.ErrorMsg(msg.result)
    end
end

function PayFastFreePanel:CreateUIPaySuccess(msg)
    UIPaySuccess.Create(function()
        -- local jb = MainModel.UserInfo.jing_bi
        -- if self.jinbi and jb >= self.jinbi then
        --     if self.signup then
        --         self.signup()
        --     end
        --     self:Close()
        -- else
        --     local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 7)
        --     if msg.goods_id ==gift_config.id then
        --         if self and IsEquals(self.UIEntity) and not self.UIEntity.gameObject.activeInHierarchy then
        --             self:InitRect()
        --         end
        --     else
        --         self:OnConfirmClick()
        --     end
        -- end
    end)
end

function PayFastFreePanel:MyExit()
    destroy(self.gameObject)
    self:RemoveListener()

	 
end

function PayFastFreePanel:Close()
    self:MyExit()
    PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end


