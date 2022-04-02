-- 创建时间:2019-03-01

local basefunc = require "Game.Common.basefunc"

ComMatchReviveBuyPanel = basefunc.class()

PopUpType = {
    BuyTicket = 1,
    Revive = 2,
}

local function Check(gameCfg, itemKeys, itemCost, buyCb, noBuyCb, game_id)
    local buyTicket = true
    if itemKeys and itemCost and #itemKeys > 0 and #itemKeys <= #itemCost then
        for i = 1, #itemKeys do
            if itemKeys[i] ~= "jing_bi" and GameItemModel.GetItemCount(itemKeys[i]) >= itemCost[i] then
                buyTicket = false
                break
            end
        end
    end

    if buyTicket then
        if gameCfg.match_type ~= MatchModel.MatchType.qydjs then
            LittleTips.Create("您没有足够的门票报名")
            return
        end

        local itemData = MainModel.GetShopingConfig(GOODS_TYPE.item , 1, ITEM_TYPE.qys_ticket)
        local giftData = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 13)
        local pop = ComMatchReviveBuyPanel.Create(gameCfg, PopUpType.BuyTicket, buyCb)
        pop:SetBuyQYSTicketBtnText(itemData.use_count, giftData.price/100, MainModel.GetGiftShopStatusByID(13) > 0)
    elseif noBuyCb then
        noBuyCb()
    end
end

function ComMatchReviveBuyPanel.CheckBuyTicket(gameCfg, buyCb, noBuyCb, isRevive)
    dump(gameCfg, "<color=yellow>--->>>ComMatchReviveBuyPanel.CheckBuyTicket:</color>")
    if isRevive then
        Check(gameCfg, gameCfg.revive_item, gameCfg.revive_item_count, buyCb, noBuyCb, gameCfg.game_id)
    else
        Check(gameCfg, gameCfg.signup_item, gameCfg.signup_item_count, buyCb, noBuyCb, gameCfg.game_id)
    end
end

function ComMatchReviveBuyPanel.Create(gameCfg, type, confirmCb, cancelCb)
    return ComMatchReviveBuyPanel.New(gameCfg, type, confirmCb, cancelCb)
end

function ComMatchReviveBuyPanel:ctor(gameCfg, type, confirmCb, cancelCb)
    self.gameCfg = gameCfg
    self.type = type
    self.confirmCbk = confirmCb
    self.cancelCbk = cancelCb

    self.UIEntity = newObject("ComMatchReviveBuyPanel", GameObject.Find("Canvas/LayerLv5").transform)
    self.transform = self.UIEntity.transform
    LuaHelper.GeneratingVar(self.transform, self)

    if self.type == PopUpType.BuyTicket then
        -- 万元赛
        if gameCfg.signup_item and gameCfg.signup_item[1] == "prop_3" then
            self.buyTicket = self.transform:Find("Buy_WYS")
            self.buyTicket.gameObject:SetActive(true)
            self.QYSClose_WYS_btn.onClick:AddListener(basefunc.handler(self, self.OnNoClicked))
            self.BuyTicket_WYS_btn.onClick:AddListener(basefunc.handler(self, self.BuyWYSTicket))

        else
            self.buyTicket = self.transform:Find("Buy")
            self.buyTicket.gameObject:SetActive(true)
        
            self.QYSClose_btn.onClick:AddListener(basefunc.handler(self, self.OnNoClicked))
            self.BuyTicket_btn.onClick:AddListener(basefunc.handler(self, self.BuyQYSTicket))
            self.BuyGiftbox_btn.onClick:AddListener(basefunc.handler(self, self.BuyQYSGiftBox))

            self.GetGift13 = function ()
                self:finish_gift_shop_shopid_13()
            end
            Event.AddListener("finish_gift_shop_shopid_13", self.GetGift13)
        end
    elseif self.type == PopUpType.Revive then
        self.revive = self.transform:Find("Revive")
        self.revive.gameObject:SetActive(true)
        
        self.revive_tool_btn.onClick:AddListener(basefunc.handler(self, self.OnReviveToolClicked))
        self.revive_money_btn.onClick:AddListener(basefunc.handler(self, self.OnReviveMoneyClicked))
        self.close_btn.onClick:AddListener(basefunc.handler(self, self.OnNoClicked))
        self.close_btn.gameObject:SetActive(false)
    end

    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function ComMatchReviveBuyPanel:OnClose()
    if self.autoClose then
        self.autoClose:Stop()
        self.autoClose = nil
    end

    self.autoCloseCb = nil
    self.confirmCbk = nil
    self.cancelCbk = nil

    if self.GetGift13 then
        Event.RemoveListener("finish_gift_shop_shopid_13", self.GetGift13)
    end

    if IsEquals(self.UIEntity) then
        GameObject.Destroy(self.UIEntity)
    end
end

function ComMatchReviveBuyPanel:OnReviveToolClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.confirmCbk then
        self.confirmCbk(self.gameCfg)
    end
    --self:OnClose()
end
function ComMatchReviveBuyPanel:OnReviveMoneyClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.confirmCbk then
        self.confirmCbk(self.gameCfg)
    end
    --self:OnClose()
end

function ComMatchReviveBuyPanel:OnNoClicked()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if self.cancelCbk then
        self.cancelCbk()
    end
    self:OnClose()
end

function ComMatchReviveBuyPanel:SetReviveBtnTitle(revive, tickCount, giveup)
    if self.type == PopUpType.Revive then
        self.revive_txt.text = revive
        self.reviveTicket_txt.text = "x" .. tickCount
        self.giveup_txt.text = giveup
    end
end

function ComMatchReviveBuyPanel:SetAutoClose(delay, cb)
    self.countDown = delay
    self.autoCloseCb = cb
    self.autoClose = Timer.New(function ()
        self.countDown = self.countDown - 1
        self.giveup_txt.text = "(" .. self.countDown .. "s) 不复活"
        
        if self.countDown == 0 then
            if self.autoCloseCb then
                self.autoCloseCb()
            end
            self:OnClose()
        end
    end, 1, delay, false)
    self.autoClose:Start()
end

function ComMatchReviveBuyPanel:SetBuyQYSTicketBtnText(coin, cash, canBuyGift)
    self.BuyTicket_txt.text = coin
    self.BuyGiftbox_txt.text = cash .. "元购买"
    local box = canBuyGift and self.transform:Find("Buy/TicketAndGift") or self.transform:Find("Buy/OnlyTicket")
    box.gameObject:SetActive(true)
    self.QYSClose_btn.transform.position = box:Find("close").position
    self.transform:Find("Buy/BuyTicket").position = box:Find("ticket").position
    if canBuyGift then
        local gift = self.transform:Find("Buy/BuyGiftBox")
        gift.position = box:Find("gift").position
        -- gift.gameObject:SetActive(true)
        gift.gameObject:SetActive(GameGlobalOnOff.LIBAO)
    end
end

function ComMatchReviveBuyPanel:BuyQYSTicket()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if MainModel.UserInfo.jing_bi < 100000 then
        -- PayFastPanel.Create(self.gameCfg)
        local hint = HintPanel.Create(4, "你的鲸币不足!\n是否前往商城购买鲸币？", function ()
            PayPanel.Create(GOODS_TYPE.jing_bi)
        end)
        hint:SetBtnTitle("确  定", "取  消")
    else
        local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.item , 1, ITEM_TYPE.qys_ticket)
        dump(goodsData, "<color=yellow>--->>>pay_exchange_goods</color>")
        Network.SendRequest("pay_exchange_goods", {goods_type = goodsData.type, goods_id = goodsData.id}, "购买千元赛门票", function (data)
            dump(data, "<color=yellow>----->>>>pay_exchange_goods:</color>")
            if data.result == 0 then
                Event.Brocast("finish_gift_shop_shopid_13")
            else
                HintPanel.ErrorMsg(data.result)
            end
        end)
    end
end

function ComMatchReviveBuyPanel:BuyWYSTicket()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local signup_item,signup_item_count = MatchModel.GetSignupItem(self.gameCfg.game_id)
    local jb_count
    for i,v in ipairs(signup_item or {}) do
        if v == "jing_bi" then
            jb_count = signup_item_count[i]
        end
    end
    if jb_count and MainModel.UserInfo.jing_bi < jb_count then
        local hint = HintPanel.Create(4, "你的鲸币不足!\n是否前往商城购买鲸币？", function ()
            PayPanel.Create(GOODS_TYPE.jing_bi)
        end)
        hint:SetBtnTitle("确  定", "取  消")
    end
end

function ComMatchReviveBuyPanel:BuyQYSGiftBox()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取比赛门票礼包"})
        self:OnNoClicked()
	else
		local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 13)
        PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100), function (result) 
            dump(data, "<color=yellow>----->>>>Buy gift box:</color>")
            if result == 0 then
                --FullSceneJH.Create("购买千元赛礼包...", "buy_ticket_prop_2")
            end
        end)
	end
end

function ComMatchReviveBuyPanel:finish_gift_shop_shopid_13()
    --FullSceneJH.RemoveByTag("buy_ticket_prop_2")
    if self.confirmCbk then
        self.confirmCbk(self.gameCfg)
    end
    self:OnClose()
end
