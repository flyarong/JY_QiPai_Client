-- 创建时间:2018-07-14
-- 快速购买 充值

local basefunc = require "Game.Common.basefunc"

PayFastOtherPanel = basefunc.class()

local CreateURLCall = function ()
    MainLogic.IsHideAssetsGetPanel = true
end

function PayFastOtherPanel.Create(config, signup)
    dump(config, "<color=#FF8109FF>快速购买PayFastOtherPanel config</color>")
    return PayFastOtherPanel.New(config, signup)
end

function PayFastOtherPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function PayFastOtherPanel:MakeLister()
    self.lister = {}
    self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self, self.AssetsGetPanelConfirmCallback)
end

function PayFastOtherPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function PayFastOtherPanel:ctor(config, signup)

	ExtPanel.ExtMsg(self)

    self:MakeLister()
    self:AddMsgListener()
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" and config.ios_pay_id then
        self.pay_id = config.ios_pay_id
    else
        self.pay_id = config.pay_id
    end
    self.diamond_id = config.diamond_id
    self.signup = signup
    if config.enterMin then
        self.jinbi = config.enterMin
    end
    if config.enter_condi_count then
        self.jinbi = config.enter_condi_count
    end
    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject("PayFastOtherPanel", self.parent.transform)
    LuaHelper.GeneratingVar(self.gameObject.transform, self)

    local is_goto_shop = self.pay_id == 0
    self.goto_btn.gameObject:SetActive(is_goto_shop)
    self.goto_num_info_txt.gameObject:SetActive(is_goto_shop)
    self.confirm_btn.gameObject:SetActive(not is_goto_shop)
    self.jing_bi_root.gameObject:SetActive(not is_goto_shop)
    self.num_info_txt.gameObject:SetActive(not is_goto_shop)

    if is_goto_shop then
        self.gameObject:SetActive(true)
        if (tonumber(self.jinbi) - MainModel.UserInfo.jing_bi) <= 0 then
            self:Close()
            return
        end
        if IsEquals(self.goto_num_info_txt) then
            self.goto_num_info_txt.text = string.format( "您进入当前场次还需要<color=#FF8109FF><size=60>%s</size></color>鲸币", StringHelper.ToCash(tonumber(self.jinbi) - MainModel.UserInfo.jing_bi))
        end

        self.close_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:Close()
        end
        )

        self.goto_btn.onClick:AddListener(
            function()
                ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                PayPanel.Create(GOODS_TYPE.jing_bi)
                self:Close()
            end
        )
    else
        self.config_pay = MainModel.GetShopingConfig(GOODS_TYPE.goods, self.diamond_id)
        self.config_change = MainModel.GetShopingConfig(GOODS_TYPE.jing_bi, self.pay_id)

        self.gameObject:SetActive(false)
        self:InitRect()
    end
end
function PayFastOtherPanel:InitRect()
    self.gameObject:SetActive(true)
    self.num_info_txt.text = StringHelper.ToCash(tonumber(self.jinbi) - MainModel.UserInfo.jing_bi)
    if self.config_change then
        self.jing_bi_img.sprite = GetTexture(self.config_change.ui_icon)
        self.jing_bi_txt.text = self.config_change.ui_title
        self.pay_txt.text = StringHelper.ToCash(tonumber(self.config_change.use_count))
    end
    
    self.close_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:Close()
        end
    )

    self.confirm_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnConfirmClick()
        end
    )
end

-- 创建充值
function PayFastOtherPanel:CreateUIPayType()
    local goodsData = self.config_pay
    PayTypePopPrefab.Create(self.config_pay.id, goodsData.ui_price, CreateURLCall)
end

function PayFastOtherPanel:CreateUIPaySuccess(msg)
    UIPaySuccess.Create(function()
        local jb = MainModel.UserInfo.jing_bi
        if self.jinbi and jb >= self.jinbi then
            if self.signup then
                self.signup()
            end
            self:Close()
        else
            local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 7)
            if msg.goods_id ==gift_config.id then
                if self and IsEquals(self.gameObject) and not self.gameObject.activeInHierarchy then
                    self:InitRect()
                end
            else
                self:OnConfirmClick()
            end
        end
    end)
end

function PayFastOtherPanel:OnReceivePayOrderMsg(msg)
    if msg.result == 0 then
        self:CreateUIPaySuccess(msg)
    else
        HintPanel.ErrorMsg(msg.result)
    end
end

function PayFastOtherPanel:MyExit()
    MainLogic.IsHideAssetsGetPanel = nil
    destroy(self.gameObject)
    self:RemoveListener()
end

function PayFastOtherPanel:Close()
    self:MyExit()
end

function PayFastOtherPanel:OnConfirmClick()
    local is_goto_shop = self.pay_id == 0
    if is_goto_shop then
        self:Close()
    else
        local dd = MainModel.UserInfo.diamond
        if self.config_change then
            if dd >= tonumber(self.config_change.use_count) then
                --自己钻石够，直接兑换
                Network.SendRequest(
                    "pay_exchange_goods",
                    {goods_type = "jing_bi", goods_id = self.config_change.id},
                    function(_data)
                        self.pay_exchange_goods_callback = function()
                            if _data.result == 0 then
                                if self.signup then
                                    self.signup()
                                end
                                self:Close()
                            else
                                HintPanel.ErrorMsg(_data.result)
                            end
                        end
                    end
                )
            else
                PayHintPanel.Create(self.gameObject.transform, self.config_pay, self.config_change, function ()
                    self:OnShowPay()
                end)
            end
        end
    end
end
function PayFastOtherPanel:OnShowPay()
    if GameGlobalOnOff.PayZS then
        if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
            --开启苹果内购的时候到商店购买钻石
            PayPanel.Create(GOODS_TYPE.goods)
        else
            self:CreateUIPayType()
        end
    else
        HintPanel.Create(1,"您的钻石不足以兑换本次比赛所需鲸币")
    end
end
function PayFastOtherPanel:OnExitScene()
    self:Close()
end

function PayFastOtherPanel:AssetsGetPanelConfirmCallback()
    if self.pay_exchange_goods_callback then
        self.pay_exchange_goods_callback()
        self.pay_exchange_goods_callback = nil
    end
end