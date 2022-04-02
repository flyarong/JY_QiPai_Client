local basefunc = require "Game.Common.basefunc"

PayPanel = basefunc.class()
local pay_url
local goods_id
local channel_type

local instance
function PayPanel.Create(goodsType, isOpenType,finishCallback,hide_type)
    DSM.PushAct({panel = "PayPanel"})
	if not instance then
		instance = PayPanel.New(goodsType, isOpenType,finishCallback,hide_type)
	end
	return instance
end
-- 关闭
function PayPanel.Close()
    if instance then
        instance:MyExit()
        instance = nil
    end
end

function PayPanel.GetInstance()
    return instance
end

function PayPanel:SetFinishCallBack(cb)
    self.finishCallback = cb
end

function PayPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function PayPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["AssetChange"] = basefunc.handler(self, self.AssetChange)
    self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
    self.lister["pay_exchange_goods_response"] = basefunc.handler(self, self.pay_exchange_goods_response)
    self.lister["pay_lottery_response"] = basefunc.handler(self, self.pay_lottery_response)
    self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
    self.lister["model_vip_upgrade_change_msg"] = basefunc.handler(self, self.model_vip_upgrade_change_msg)
    self.lister["main_model_query_all_gift_bag_status"] = basefunc.handler(self, self.main_model_query_all_gift_bag_status)
end

function PayPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

local function CheckPlayerLevel()
    if AppDefine.IsEDITOR() then return true end

    local UserInfo = MainModel.UserInfo or {}
    local player_level = UserInfo.player_level or 0
    return player_level > 0
end

-- isOpenType 打开方式 normal正常打开 其余是货币不足打开
function PayPanel:ctor(goodsType, isOpenType,finishCallback,hide_type)
    self.finishCallback = finishCallback
    self.hide_type = hide_type
    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.UIEntity = newObject("PayPanel", self.parent.transform)
    self.transform = self.UIEntity.transform
    LuaHelper.GeneratingVar(self.UIEntity.transform, self)

    self:MakeLister()
    self:AddMsgListener()

    self:RefreshAssets()

    self.close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        PayPanel.Close()
    end)

    for k,v in pairs(GOODS_TYPE) do
        if v ~= GOODS_TYPE.gift_bag then
            self:InitTge(v)
            self:InitSV(v)
        end
    end

    for i,v in ipairs(MainModel.GetShopingConfigTge()) do
        self.tge_item_table[v.type].transform:SetSiblingIndex(v.order_id - 1)
    end
    self:SwitchTge(goodsType)

    --app内购--------------
    --开启iOS内购关闭道具按钮
    self.tge_item_table[GOODS_TYPE.jing_bi].transform.gameObject:SetActive(GameGlobalOnOff.ShopJB)
    self.tge_item_table[GOODS_TYPE.goods].transform.gameObject:SetActive(GameGlobalOnOff.ShopZS)
    self.tge_item_table[GOODS_TYPE.item].transform.gameObject:SetActive(GameGlobalOnOff.ShopDJ)

    LuaHelper.AddDeferred(
        function()
            HintPanel.Create(1, "内购未完成")
            self:RemoveShopingJH()
        end
    )

    LuaHelper.AddPurchasingUnavailable(
        function()
            HintPanel.Create(1, "手机设置了禁止APP内购")
            self:RemoveShopingJH()
        end
    )

    LuaHelper.AddPurchaseFailed(
        function()
            HintPanel.Create(1, "购买失败")
            self:RemoveShopingJH()
        end
    )

    local gmToggle = self.transform:Find("GMToggle"):GetComponent("Toggle")
    gmToggle.isOn = PayPanel.IsTest()
    gmToggle.gameObject:SetActive(CheckPlayerLevel())
    gmToggle.onValueChanged:AddListener(function(val)
        PayPanel.SetTest(val)
    end)

    if GameGlobalOnOff.IOSTS then
        local redNode = self.transform:Find("Red")
    redNode.gameObject:SetActive(false)
    end

    DOTweenManager.OpenPopupUIAnim(self.transform)

    Event.Brocast("PayPanelCreate",self.top_node)

    if PayPanel.CheckHaveXSGift() then
        --新手礼包
        GameButtonManager.GotoUI({gotoui = "sys_sclb",goto_scene_parm = "panel"})
    end
end

function PayPanel:OnExitScene()
    PayPanel.Close()
end

function PayPanel:MyExit()
    DSM.PopAct()
    print("<color=red>PayPanel:MyExit</color>")
    self.finishCallback = nil
    self.hide_type = nil
    self.tge_item_table = nil
    self.sv_item_table = nil
    self.obj_id_t = nil
    FullSceneJH.RemoveByTag("ShopingGold")

    self:RemoveListener()
    destroy(self.UIEntity.gameObject)
    Event.Brocast("PayPanelClosed")
end

function PayPanel:InitTge(type)
    local config = MainModel.GetShopingConfigTge(type)
    if not config then return end
    local TG = self.switch_content.transform:GetComponent("ToggleGroup")
    local go = GameObject.Instantiate(self.tgeItem, self.switch_content)
    go.gameObject:SetActive(config.is_show == 1)
    go.name = config.id
    local ui_table = {}
    ui_table.transform = go.transform
    LuaHelper.GeneratingVar(go.transform, ui_table)
    ui_table.item_tge = go.transform:GetComponent("Toggle")
    ui_table.item_tge.group = TG
    ui_table.item_tge.onValueChanged:AddListener(
        function(val)
            ui_table.tge_txt.gameObject:SetActive(not val)
            ui_table.icon_img.gameObject:SetActive(not val)
            ui_table.mark_tge_txt.gameObject:SetActive(val)
            ui_table.mark_icon_img.gameObject:SetActive(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if val then
                self:SwitchGroup(type)
            end
        end
    )
    GetTextureExtend(ui_table.icon_img, config.icon_image, config.is_local_icon)
    GetTextureExtend(ui_table.mark_icon_img, config.icon_image, config.is_local_icon)
    ui_table.tge_txt.text = config.name
    ui_table.mark_tge_txt.text = config.name
    ui_table.new_tag.gameObject:SetActive(config.is_new_tag == 1)

    self.tge_item_table = self.tge_item_table or {}
    self.tge_item_table[type] = ui_table
end

function PayPanel:SwitchTge(goodsType)
    local function switch_tge()
        if GameGlobalOnOff.ShopDJ then
            self.tge_item_table[GOODS_TYPE.item].item_tge.isOn = true
        elseif GameGlobalOnOff.ShopJB then
            self.tge_item_table[GOODS_TYPE.jing_bi].item_tge.isOn = true
        elseif GameGlobalOnOff.ShopZS then
            self.tge_item_table[GOODS_TYPE.goods].item_tge.isOn = true
        end
    end
    if goodsType then
        if goodsType == GOODS_TYPE.item and GameGlobalOnOff.ShopDJ then
            self.tge_item_table[goodsType].item_tge.isOn = true
        elseif goodsType == GOODS_TYPE.jing_bi and GameGlobalOnOff.ShopJB then
            self.tge_item_table[goodsType].item_tge.isOn = true
        elseif goodsType == GOODS_TYPE.goods and GameGlobalOnOff.ShopZS then
            self.tge_item_table[goodsType].item_tge.isOn = true
        else
            switch_tge()
        end
    else
        switch_tge()
    end
end

function PayPanel:InitSV(type)
    local TG = self.switch_content.transform:GetComponent("ToggleGroup")
    local go = GameObject.Instantiate(self.SVItem, self.Center)
    go.gameObject:SetActive(false)
    local ui_table = {}
    ui_table.transform = go.transform
    ui_table.gameObject = go.gameObject
    LuaHelper.GeneratingVar(go.transform, ui_table)
    self.sv_item_table = self.sv_item_table or {}
    self.sv_item_table[type] = ui_table
end

function PayPanel:RefreshAssets()
    -- if self.goodsType == GOODS_TYPE.room_card then
    --     self.GoldIcon_img.sprite = GetTexture("bag_icon_rc")
    --     self.gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.room_card) or "0"
    -- else
    --     self.GoldIcon_img.sprite = GetTexture("com_icon_gold")
    --     self.gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi) or "0"
    -- end
    self.GoldIcon_img.sprite = GetTexture("com_icon_gold")
    if IsEquals(self.gold_txt) and IsEquals(self.diamond_txt) then
        self.gold_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi) or "0"
        self.diamond_txt.text = StringHelper.ToCash(MainModel.UserInfo.diamond) or "0"
        self.red_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
    end
end

function PayPanel:SwitchGroup(goodsType)
    self.goodsType = goodsType
    self:RefreshAssets()
    FullSceneJH.RemoveByTag("ShopingGold")
    self.sv_item_table = self.sv_item_table or {}
    self.sv_item_table[GOODS_TYPE.goods].gameObject:SetActive(GOODS_TYPE.goods == goodsType)
    self.sv_item_table[GOODS_TYPE.jing_bi].gameObject:SetActive(GOODS_TYPE.jing_bi == goodsType)
    self.sv_item_table[GOODS_TYPE.item].gameObject:SetActive(GOODS_TYPE.item == goodsType)
    self.exchange_jing_bi_txt.gameObject:SetActive(not GameGlobalOnOff.IOSTS and GOODS_TYPE.jing_bi == goodsType)
    self.sv_item_table[goodsType].sv_content.localPosition = Vector3.zero
    if goodsType == GOODS_TYPE.jing_bi then
        self:ActCreateGoodsItemsToContent()
    else
        if  self.sv_item_table[goodsType].sv_content2.childCount == 0 then
            self:CreateGoodsItemsToContent(goodsType,  self.sv_item_table[goodsType].sv_content2)
        end    
    end
end

function PayPanel:CreateGoodsItemsToContent(goodsType, content)
    local objTable = {}
    if goodsType == GOODS_TYPE.jing_bi then
        self.obj_id_t = {}
    end
    for k, v in pairs(MainModel.GetShopingConfig(GOODS_TYPE[goodsType])) do
        if v.is_show and v.is_show == 1 then
            --objTable[k] = self:CreateGoodsItem(k, content, goodsType)
            if (not self:IsExpression(v) or GameGlobalOnOff.ShopBQ) and not self:IsHideType(v) then
                local go = self:CreateGoodsItem(v, goodsType, content)
                table.insert(objTable, go)
                if goodsType == GOODS_TYPE.jing_bi and v.gift_id then
                    self.obj_id_t[v.id] = {data = v,obj = go}
                end
            end
        end
    end
    table.sort(objTable, function(a, b) return tonumber(a.name) < tonumber(b.name) end)
    for k, go in ipairs(objTable) do
        go.transform:SetSiblingIndex(k - 1)
    end

    --首冲礼包设置
    if goodsType == GOODS_TYPE.jing_bi then
        for id,v in pairs(self.obj_id_t) do
            self:SetPayGoodsGift(v.obj,v.data)
        end
    end

    if not GameGlobalOnOff.IOSTS then
        self:SetZSConvertJB(goodsType)
    end
end

function PayPanel:CreateGoodsItem(goodsData, goodsType, parent)
    local go = GameObject.Instantiate(self.ItemGoods,parent)
    go.name = goodsData.ui_order
    local goTable = {}
    LuaHelper.GeneratingVar(go.transform, goTable)

    if self:IsExpression(goodsData) then
        if goodsData.num > 1 then
            goTable.title_txt.text = string.format("%s x %d", goodsData.ui_title, goodsData.num)
        else
            goTable.title_txt.text = goodsData.ui_title
        end
    else
        goTable.title_txt.text = goodsData.ui_title
    end
    goTable.doc_txt.text = goodsData.ui_describe
    local doc = goodsData.ui_price
    doc = string.gsub(doc, "￥", "<size=45>￥</size>")
    if goodsData.ui_givedesc then
        goTable.givedesc_txt.text = goodsData.ui_givedesc
    end
    if goodsData.ui_discount then
        goTable.discount.gameObject:SetActive(true)
        goTable.discount_txt.text = goodsData.ui_discount .. "折"
    else
        goTable.discount.gameObject:SetActive(false)
    end
    if goodsData.ui_gift then
        goTable.ts_img.gameObject:SetActive(true)
        goTable.ts_txt.text = goodsData.ui_gift
    else
        goTable.ts_img.gameObject:SetActive(false)
    end

    goTable.price_txt.text = doc
    -- goTable.icon_bg_img.sprite = GetTexture(goodsData.ui_icon_bg)
    -- goTable.icon_bg_img:SetNativeSize()
    GetTextureExtend(goTable.icon_img, goodsData.ui_icon, goodsData.is_local_icon)
    goTable.icon_img:SetNativeSize()
    if goodsType ~= GOODS_TYPE.goods then
        local d = goTable.diamIcon_img
        local icon_name = "com_icon_diamond"
        if goodsData.use_type == "shop_gold_sum" then
            icon_name = "com_icon_hb"
        elseif goodsData.use_type == "diamond" then
            icon_name = "com_icon_diamond"
        elseif goodsData.use_type == "jing_bi" then
            icon_name = "com_icon_gold"
        end
        d.sprite = GetTexture(icon_name)
        
        if not GameGlobalOnOff.IOSTS and goodsType == GOODS_TYPE.jing_bi and goodsData.use_type == "diamond" then
            d.gameObject:SetActive(false)
        else
            d.gameObject:SetActive(true)
        end
    end

    goTable.pay_item_goods_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.switchGoods = goodsData
            self.is_auto_exchange_jing_bi = false
            if goodsType == GOODS_TYPE.goods then
                self:PayGoods(goodsData)
            elseif goodsType == GOODS_TYPE.jing_bi then
                --现金购买金币
                local canPay = goodsData.use_type == "diamond"
                if GameGlobalOnOff.IOSTS or true then
                    canPay = goodsData.use_type == "diamond" and MainModel.UserInfo.diamond < goodsData.use_count
                end
                if canPay then
                    local goods_data = MainModel.GetShopingConfig(GOODS_TYPE.goods ,goodsData.goods_id)
                    self:PayGoods(goods_data,GOODS_TYPE.jing_bi)                    
                else
                    if goodsData.use_type == GOODS_TYPE.shop_gold_sum then
                        if goodsData.goods_id == 1 or goodsData.goods_id == 101 then
                            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key= "actp_buy_jing_bi_14", is_on_hint = true}, "CheckCondition")
                            if a then
                                if b then
                                    HintPanel.Create(2, goodsData.shop_gold_sum_desc, function ()
                                        self:PayExchangeGoods(goodsData)
                                    end)
                                else
                                    LittleTips.Create("V0才可以进行1福卡兑换鲸币")
                                end
                            else
                                LittleTips.Create("发生未知错误")
                            end
                        else
                            HintPanel.Create(2, goodsData.shop_gold_sum_desc, function ()
                                self:PayExchangeGoods(goodsData)
                            end)
                        end
                    else
                        self:PayExchangeGoods(goodsData)
                    end
                end

                --钻石兑换金币
                -- if goodsData.use_type == "diamond" and MainModel.UserInfo.diamond < goodsData.use_count then
                --     local goods_data = MainModel.GetShopingConfig(GOODS_TYPE.goods, goodsData.goods_id)
                --     PayHintPanel.Create(self.UIEntity.transform, goods_data, goodsData, function ()
                --         self.is_auto_exchange_jing_bi = true
                --         local goods_data = MainModel.GetShopingConfig(GOODS_TYPE.goods ,goodsData.goods_id)
                --         self:PayGoods(goods_data)
                --     end)
                -- else
                --     if (goodsData.goods_id == 5 or goodsData.goods_id == 104) and goodsData.use_type == "shop_gold_sum" then
                --         HintPanel.Create(2, "是否确定消耗50.00福卡来兑换\n51万鲸币？", function ()
                --             self:PayExchangeGoods(goodsData)
                --         end)
                --     else
                --         self:PayExchangeGoods(goodsData)
                --     end
                -- end
            else
                self:PayExchangeGoods(goodsData)
            end
        end
    )
    go.gameObject:SetActive(true)
    return go
end

function PayPanel:PayGoods(goodsData,convert)
    dump(goodsData, "<color=yellow>购买商品数据</color>")
    dump(convert, "<color=yellow>convert</color>")
    --购买首冲礼包
    if convert and convert == GOODS_TYPE.jing_bi and goodsData.gift_id then
        local gift_status = MainModel.GetGiftShopStatusByID(goodsData.gift_id)
        if gift_status == 1 then
            self:PayGoodsGift(goodsData.gift_id)
            return
        end
    end    

    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        if not LuaHelper or not LuaHelper.OnPurchaseClicked then
            dump(LuaHelper or {}, "[Debug] trace exception:LuaHelper")
        end

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
                order.convert = convert
                dump(order, "[Debug] IOS Pay OK")
                IosPayManager.AddOrder(order)
            end
        ) then
            HintPanel.Create(1, "暂时无法连接iTunes Store，请稍后购买")
            return
        end
        FullSceneJH.Create("", "ShopingGold", self.goods_sv)
    else
        self:CreateUIPayType(goodsData,convert)
    end
end

function PayPanel:PayExchangeGoods(goodsData)
    dump(goodsData, "<color=yellow>PayExchangeGoods</color>")
    if self:IsExpression(goodsData) then
        if self:ShopExpressionHintXYCJ() then
            --幸运抽奖
            return
        end
        if PayPanel.CheckExpressionCondition(goodsData) then
            Network.SendRequest("pay_lottery",
                {type = goodsData.group, time = goodsData.num, tag = goodsData.id},"购买表情")
            print("[debug] goods_expression:" .. goodsData.group .. ", " .. goodsData.num)
        end
    else
        Network.SendRequest("pay_exchange_goods",
            {goods_type = goodsData.type, goods_id = goodsData.id},"购买道具",function (data)
                if data.result ~= 0 then
                    HintPanel.ErrorMsg(data.result)
                end
            end)
    end
end

function PayPanel:pay_exchange_goods_response(_,data)
    dump(data, "<color=yellow>>>>>>>>>>>>>>></color>")
    if data.result == 0 then
        if self.switchGoods.type == GOODS_TYPE.jing_bi then
            self:RefreshAssets()
        end
        if self.finishCallback then self.finishCallback() end
    else
        HintPanel.ErrorMsg(data.result)
        if data.result == 1025 then
            self.diamond_tge.isOn = true
        end
    end
end

function PayPanel.map_lottery_detail(goodsData)
    local result = {}
    local num = goodsData.num or 0
    if num > 1 then
        result["title_extra"] = string.format("%s x %d", goodsData.ui_title, num)
    else
        result["title_extra"] = goodsData.ui_title
    end
    result["title"] = goodsData.ui_title
    result["value"] = num
    result["desc"] = goodsData.ui_describe
    result["image"] = goodsData.ui_icon

    return result
end

function PayPanel:pay_lottery_response(_, data)
    dump(data, "<color=yellow>pay_lottery_response</color>")
    if data.result == 0 then
        self:RefreshAssets()

    local tag = data.tag or 0
    local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.item ,tag, ITEM_TYPE.expression)
    if goodsData == nil then
        print("[lottery] exception: pay_lottery_response goodsData is empty, tag:" .. tag)
        return
    end

    local detail = self.map_lottery_detail(goodsData)
    local showDetail = {}
    showDetail.type = "expression"
    showDetail.value = detail["value"]
    showDetail.desc = detail["title_extra"]
    showDetail.image = detail["image"]

    --extra items
    local items = {}

    --expression
    local lottery_data = data.lottery_data or {}
    local dress_data = lottery_data.dress_data or {}
    local expressions = dress_data.expression or {}
    for k, v in pairs(expressions) do
        local data = PersonalInfoManager.GetDressDataToID(v.id)
        if data ~= nil then
            local item = {}
            item.type = data.name
            item.value = v.num
            item.desc = data.desc
            item.image = data.icon
            table.insert(items, item)

            print("[lottery] expression ok:" .. v.id .. ", " .. v.num)
        else
            print("[lottery] expression invalid:" .. v.id .. ", " .. v.num)
        end
    end

    local asset_datas = lottery_data.asset_data or {}
    for k, v in pairs(asset_datas) do
        local data = GameItemModel.GetItemToKey(v.asset_type)
        if data ~= nil then
            local item = {}
            item.type = v.asset_type
            item.value = v.value
            item.desc = data.name
            item.image = data.image
            table.insert(items, item)

            print("[lottery] asset_data ok:" .. v.asset_type .. ", " .. v.value)
        else
            print("[lottery] asset_data invalid:" .. v.asset_type .. ", " .. v.value)
        end
    end

    if #items <= 0 then
        print("[lottery] exception: pay_lottery_response items is empty")
        return
    end

    Event.Brocast("AssetGet",{data = {showDetail}, skip_data = true, callback = function()
        Event.Brocast("AssetExtraGet",{data = items, animation = true, params = {host = self.switchGoods}})
        return true
    end})

        if self.finishCallback then self.finishCallback() end
    else
        Event.Brocast("CloseAssetsPanel")
        HintPanel.ErrorMsg(data.result)
    end
end

function PayPanel:CreateUIPayType(goodsData,convert)
    PayTypePopPrefab.Create(goodsData.id, goodsData.ui_price,nil,convert)
end

function PayPanel:CreateUIPaySuccess()
    UIPaySuccess.Create(function ()
        if self.is_auto_exchange_jing_bi then
            self:PayExchangeGoods(self.switchGoods)
            self.is_auto_exchange_jing_bi = false
        end
    end)
    if self.finishCallback then self.finishCallback() end
end

function PayPanel:OnReceivePayOrderMsg(msg)
    if msg.result == 0 then
        self:CreateUIPaySuccess(msg)
    else
        HintPanel.ErrorMsg(msg.result)
    end
    self:RemoveShopingJH()
end
function PayPanel:RemoveShopingJH()
    FullSceneJH.RemoveByTag("ShopingGold")
end

function PayPanel:AssetChange(msg)
    self:RefreshAssets()
    self:ActCreateGoodsItemsToContent()
end

function PayPanel:IsExpression(item)
    return item.type == "expression"
end

function PayPanel.CheckExpressionCondition(item)
    local conditions = item.condition or {}
    for _, v in pairs(conditions) do
        if not ConditionManager.CheckCondition(v, 2) then
        return false
    end
    end
    local use_count = item.use_count or 0
    local current_count = MainModel.UserInfo.jing_bi
    if current_count < use_count then
        HintPanel.Create(1, "鲸币不足")
    return false
    end

    return true
end

function PayPanel:IsHideType(item)
    if self.hide_type and item.type then
        return item.type == self.hide_type
    end
    return false
end

--设置首冲礼包ui
function PayPanel:SetPayGoodsGift(go,goodsData)
    local goTable = {}
    LuaHelper.GeneratingVar(go.transform, goTable)
    --鲸币首冲
    local gift_status = MainModel.GetGiftShopStatusByID(goodsData.gift_id)
    if gift_status == 1 then
        local gift_data = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, goodsData.gift_id)
        if gift_data then
            if gift_data.random then
                --随机商品特殊处理
                if gift_data.buy_limt then
                    if gift_data.buy_limt == 0 then
                        goTable.ts_txt.text = "只能购买1次"
                    elseif gift_data.buy_limt == 1 then
                        goTable.ts_txt.text = "每日限购1次"
                    elseif gift_data.buy_limt == 2 then
                        goTable.ts_txt.text = "无限制"
                    end
                    goTable.ts_img.gameObject:SetActive(true)
                end
                if gift_data.random_ui and next(gift_data.random_ui) then
                    local _min = gift_data.random_ui[1]
                    local _max = gift_data.random_ui[2]
                    goTable.title_txt.text = StringHelper.ToCash(_min) .. "~" .. StringHelper.ToCash(_max)
                end
                goTable.doc_txt.text = "随机获得鲸币" 
            else
                if gift_data.buy_asset_count then
                    local add_jb = gift_data.buy_asset_count[1] - goodsData.jing_bi
                    goTable.givedesc_txt.text = "加赠" .. add_jb
                    goTable.give_img.gameObject:SetActive(true)
                else
                    goTable.givedesc_txt.text = ""
                    goTable.give_img.gameObject:SetActive(false)
                end
            end
        else
            goTable.givedesc_txt.text = ""
        end
    else
        goTable.ts_img.gameObject:SetActive(false)
        goTable.doc_txt.text = goodsData.ui_describe
        goTable.givedesc_txt.text = ""
    end
end

function PayPanel:main_model_query_all_gift_bag_status()
    self:RefreshGoodsGift()
end

function PayPanel:on_finish_gift_shop(id)
    dump(id, "<color=white>finish_gift_shop id :</color>")
    self:RefreshGoodsGift(id)
end

function PayPanel:model_vip_upgrade_change_msg(id)
    dump(id, "<color=white>finish_gift_shop id :</color>")
    self:RefreshGoodsGift(id)
end

function PayPanel:RefreshGoodsGift(id)
    self:ActCreateGoodsItemsToContent()
    -- if self.obj_id_t then
    --     for k,v in pairs(self.obj_id_t) do
    --         if id == v.data.gift_id then
    --             self:SetPayGoodsGift(v.obj,v.data)
    --         end
    --     end
    -- end
end

--首冲礼包购买
function PayPanel:PayGoodsGift(goodsId)
    dump(goodsId, "<color=yellow>goodsId</color>")
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请关注“%s”公众号领取首冲礼包"})
    else
        local goodsData = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, goodsId)
        local price = "￥" .. (tonumber(goodsData.price) / 100)
        PayTypePopPrefab.Create(goodsData.id, price)
    end
end

function PayPanel:SetZSConvertJB(goodsType)
    if goodsType ~= GOODS_TYPE.goods then return end
    local goods_data
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        goods_data = MainModel.GetShopingConfig(GOODS_TYPE.jing_bi,106)
    else
        goods_data = MainModel.GetShopingConfig(GOODS_TYPE.jing_bi,7)
    end
    dump(goods_data, "<color=white>商品数据</color>")
    if table_is_null(goods_data) then return end
    local go = self:CreateGoodsItem(goods_data, GOODS_TYPE.jing_bi, self.sv_item_table[GOODS_TYPE.goods].sv_content2)
    local goTable = {}
    LuaHelper.GeneratingVar(go.transform,goTable)
    if IsEquals(go) then
        go.transform:SetSiblingIndex(0)
        goTable.pay_item_goods_btn.onClick:RemoveAllListeners()
        goTable.pay_item_goods_btn.onClick:AddListener(function()
            self:PayExchangeGoods(goods_data)
        end)
        goTable.price_txt.text = goods_data.use_count
        local d = goTable.diamIcon_img
        d.sprite = GetTexture("com_icon_diamond")
        d.gameObject:SetActive(true)
    end
end

--购买表情提示幸运抽奖
function PayPanel:ShopExpressionHintXYCJ()
     if GameGlobalOnOff.ShopExpressionHintXYCJ then
        HintPanel.Create(2,"该功能已下架，游戏主界面“幸运抽奖”功能可以产生大量福卡，立即前往试试吧！",function (  )
            Network.SendRequest("query_luck_box_lottery_status", nil, "", function (data)
                if data.result == 0 then
                    PayPanel.Close()
                    GameManager.GotoUI({gotoui="xycj", goto_scene_parm="panel"})
                else
                    local pre = HintPanel.Create(2, "单笔充值6元及以上金额可开启幸运抽奖，是否立刻前往？", function ()
                        self:SwitchTge(GOODS_TYPE.jing_bi)
                    end)
                    pre:SetButtonText(nil, "前 往")
                end
            end)
        end)
        return true
    end
end


local TEST_KEY = "_PAY_TEST_"

function PayPanel.SetTest(enable)
    if not CheckPlayerLevel() then return end
    if enable then
        PlayerPrefs.SetInt(TEST_KEY, 1)
    else
        PlayerPrefs.DeleteKey(TEST_KEY)
    end
end

function PayPanel.IsTest()
    if not CheckPlayerLevel() then return false end
    return PlayerPrefs.GetInt(TEST_KEY, 0) > 0
end


--商城2.0
function PayPanel.CheckHaveXSGift()
    local is_f, is_t = GameButtonManager.RunFun({gotoui = "sys_sclb"}, "GetCurrentShopID")
    return is_f and is_t ~= nil
end

function PayPanel:ActCreateGoodsItemsToContent()
    if not self.sv_item_table then return end
    local goodsType = GOODS_TYPE.jing_bi
    destroyChildren(self.sv_item_table[goodsType].sv_content1)
    destroyChildren(self.sv_item_table[goodsType].sv_content2)
    local objTable = {}
    if goodsType == GOODS_TYPE.jing_bi then
        self.obj_id_t = {}
    end
    
    local vip_lv 
    if VIPManager then
        vip_lv = VIPManager.get_vip_level()
    end
    local sgs = MainModel.UserInfo.shop_gold_sum
    local xz_condition
    --推荐
    local tj = {}
    local g_state
    for i,v in ipairs(shoping_config_revise.tj) do
        if #tj == 2 then
            break
        end
        local is_tj = false
        for j,v_xz_type in ipairs(v.xz_type) do
            xz_condition = v[v_xz_type]
            if xz_condition then
                --验证vip
                if v_xz_type == "vip" then
                    if #xz_condition == 1 then
                        if vip_lv >= xz_condition[1] then
                            is_tj = true
                        else
                            is_tj = false
                            break
                        end
                    elseif #xz_condition == 2 then
                        if vip_lv >= xz_condition[1] and vip_lv <= xz_condition[2] then
                            is_tj = true
                        else
                            is_tj = false
                            break
                        end
                    end
                end                
            end
        end
        if is_tj then
            if v.tj_type and next(v.tj_type) then
                for i_,v_type in ipairs(v.tj_type) do
                    if #tj == 2 then
                        break
                    end
                    if v_type == "gift_bag" then
                        g_state = MainModel.GetGiftShopStatusByID(v.tj_id[i_])
                        if g_state == 1 then
                            table.insert(tj,{type = "gift",id = v.tj_id[i_]} )
                        end
                    elseif v_type == "yk" then
                        local b, yk = GameButtonManager.RunFun({gotoui="sys_yk"}, "GetBestLevel")
                        if b then
                            if yk == 1 then
                                table.insert( tj,{type = "gift",id = 10002} )
                            -- elseif yk == 2 then
                            --     table.insert( tj,{type = "gift",id = 10003} )
                            elseif yk == 3 then
                                table.insert( tj,{type = "gift",id = 10004} )
                            end
                        end
                    end
                end
            end
        end
    end
 
    local hbq = {}
    --福卡
    for i,v in ipairs(shoping_config_revise.hbq) do
        local is_tj = false
        for j,v_xz_type in ipairs(v.xz_type) do
            xz_condition = v[v_xz_type]
            if xz_condition then
                --验证vip
                if v_xz_type == "vip" then
                    if #xz_condition == 1 then
                        if vip_lv >= xz_condition[1] then
                            is_tj = true
                        else
                            is_tj = false
                            break
                        end
                    elseif #xz_condition == 2 then
                        if vip_lv >= xz_condition[1] and vip_lv <= xz_condition[2] then
                            is_tj = true
                        else
                            is_tj = false
                            break
                        end
                    end
                elseif v_xz_type == "shop_gold_sum" then
                    if #xz_condition == 1 then
                        if sgs >= xz_condition[1] then
                            is_tj = true
                        else
                            is_tj = false
                            break
                        end
                    elseif #xz_condition == 2 then
                        if sgs >= xz_condition[1] and sgs <= xz_condition[2] then
                            is_tj = true
                        else
                            is_tj = false
                            break
                        end
                    end
                end                
            end
        end
        if is_tj then
            for i_,v_ in ipairs(v.tj_id) do
                table.insert( hbq,{type = v.tj_type[i_],id = v_} )
            end
        end
    end

    --剩下的道具设置
    local jb_cfg = basefunc.deepcopy(MainModel.GetShopingConfig(GOODS_TYPE.jing_bi))
    local hbq_cfg = {}
    if not table_is_null(jb_cfg) then
        local v = {}
        for i=#jb_cfg,1, -1 do
            v = jb_cfg[i]
            if v.use_type == "shop_gold_sum" and v.is_show == 1 then
                if not table_is_null(hbq) then
                    for i_,v_ in ipairs(hbq) do
                        if v_.id == v.id then
                            table.insert(hbq_cfg,basefunc.deepcopy(v))
                        end
                    end
                end
                table.remove(jb_cfg,i)
            end
        end
    end
    dump(jb_cfg, "<color=white>jb_cfg</color>")

    local tj_c = #tj
    local hbq_c = #hbq_cfg
    dump(tj, "<color=white>推荐物品</color>")
    local tj_obj = {}
    if not table_is_null(tj) then
        --推荐物品设置
        for i,v in ipairs(tj) do
            local go
            if v.id == 10002 or v.id == 10003 or v.id == 10004 then
                if IsEquals(self.ImgGoods) then
                    --推荐月卡
                    go = GameObject.Instantiate(self.ImgGoods,self.sv_item_table[goodsType].sv_content1)
                    local goTable = {}
                    LuaHelper.GeneratingVar(go.transform, goTable)
                    goTable.pay_item_goods_btn.onClick:AddListener(function(  )
                        --打开月卡
                        GameManager.GotoUI({gotoui="sys_yk", goto_scene_parm="panel"})
                        -- PayPanel.Close()
                    end)
                    go.gameObject:SetActive(true)
                end
            else
                local gift_data = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, v.id)
                dump(gift_data, "<color=white>gift_data</color>")
                go = self:CreateActGoodsItem(gift_data,goodsType,self.sv_item_table[goodsType].sv_content1)
            end
            table.insert(tj_obj, go)
        end
        self.sv_item_table[goodsType].sv_content1.gameObject:SetActive(true)
    end

    dump(hbq_cfg, "<color=white>推荐福卡</color>")
    local hgq_obj = {}
    if not table_is_null(hbq_cfg) then
        --福卡设置
        local sv1
        if tj_c == 1 then
            --sv1
            sv1 = true
        else
            --sv2
        end
        local go
        for i,v in ipairs(hbq_cfg) do
            if sv1 then
                go = self:CreateGoodsItem(v, goodsType, self.sv_item_table[goodsType].sv_content1)
            else
                go = self:CreateGoodsItem(v, goodsType, self.sv_item_table[goodsType].sv_content2)
            end
            table.insert(objTable, go)
            table.insert(hgq_obj, go)
        end
    end
    
    if not table_is_null(jb_cfg) then
        local sv1
        local sv1_c = 0
        if tj_c == 1 then
            --sv1
            --第一个是sv1
            sv1 = true
            if hbq_c == 0 then
                sv1_c = 2
            elseif hbq_c == 1 then
                sv1_c = 1
            end
        else
            --sv2
        end
        for i,v in ipairs(jb_cfg) do
            if v.is_show and v.is_show == 1 then
                --objTable[k] = self:CreateGoodsItem(k, content, goodsType)
                if (not self:IsExpression(v) or GameGlobalOnOff.ShopBQ) and not self:IsHideType(v) then
                    local go
                    if not vip_lv or vip_lv < 6 then
                        if sv1 and i == 1 and (sv1_c == 1 or sv1_c == 2) then
                            go = self:CreateGoodsItem(v, goodsType, self.sv_item_table[goodsType].sv_content1)
                        elseif sv1 and i == 2 and sv1_c == 2 then
                            go = self:CreateGoodsItem(v, goodsType, self.sv_item_table[goodsType].sv_content1)
                        else
                            go = self:CreateGoodsItem(v, goodsType, self.sv_item_table[goodsType].sv_content2)
                        end
                    else
                        if sv1 and i == #jb_cfg and (sv1_c == 1 or sv1_c == 2) then
                            go = self:CreateGoodsItem(v, goodsType, self.sv_item_table[goodsType].sv_content1)
                        elseif sv1 and i == #jb_cfg - 1 and sv1_c == 2 then
                            go = self:CreateGoodsItem(v, goodsType, self.sv_item_table[goodsType].sv_content1)
                        else
                            go = self:CreateGoodsItem(v, goodsType, self.sv_item_table[goodsType].sv_content2)
                        end
                    end
                    table.insert(objTable, go)
                    if goodsType == GOODS_TYPE.jing_bi and v.gift_id then
                        local is_add = true
                        if tj then
                            for i_,v_ in ipairs(tj) do
                                if v.gift_id == v_.id then
                                    is_add = false
                                end
                            end
                        end
                        if is_add then
                            self.obj_id_t[v.id] = {data = v,obj = go}
                        end
                    end
                end
            end
        end
        if not vip_lv or vip_lv < 6 then
            table.sort(objTable, function(a, b) return tonumber(a.name) < tonumber(b.name) end)
        else
            table.sort(objTable, function(a, b) return tonumber(a.name) > tonumber(b.name) end)
        end
        
        for k, go in ipairs(objTable) do
            go.transform:SetSiblingIndex(k - 1)
        end

        if sv1 then
            if sv1_c == 1 then
                objTable[1].transform:SetAsLastSibling()
            elseif sv1_c == 2 then
                objTable[1].transform:SetAsLastSibling()
                objTable[2].transform:SetAsLastSibling()
            end
        end

        --首冲礼包设置
        if goodsType == GOODS_TYPE.jing_bi then
            for id,v in pairs(self.obj_id_t) do
                self:SetPayGoodsGift(v.obj,v.data)
            end
        end

        if not GameGlobalOnOff.IOSTS then
            self:SetZSConvertJB(goodsType)
        end
    end

    if not table_is_null(hgq_obj) then
        for i,v in ipairs(hgq_obj) do
            v.transform:SetSiblingIndex(i - 1)
        end
    end

    if not table_is_null(tj_obj) then
        for i,v in ipairs(tj_obj) do
            v.transform:SetSiblingIndex(i - 1)
        end
    end
end

function PayPanel:CreateActGoodsItem(goodsData, goodsType, parent)
    local go = GameObject.Instantiate(self.ActGoods,parent)
    local goTable = {}
    LuaHelper.GeneratingVar(go.transform, goTable)
    local gift_status = MainModel.GetGiftShopStatusByID(goodsData.id)
    if gift_status == 1 then
        --随机商品特殊处理
        if goodsData.buy_limt then
            if goodsData.buy_limt == 0 then
                goTable.ts_txt.text = "只能购买1次"
            elseif goodsData.buy_limt == 1 then
                goTable.ts_txt.text = "每日限购1次"
            elseif goodsData.buy_limt == 2 then
                goTable.ts_txt.text = "无限制"
            elseif goodsData.buy_limt == 4 then
                goTable.ts_txt.text = "每日限购1次"
            end
            goTable.ts_img.gameObject:SetActive(true)
        end
        if goodsData.random then
            if goodsData.random_ui and next(goodsData.random_ui) then
                local _min = goodsData.random_ui[1]
                local _max = goodsData.random_ui[2]
                goTable.title_txt.text = "获得" .. StringHelper.ToCash(_min) .. "~" .. StringHelper.ToCash(_max)
            end
            goTable.doc_txt.text = ""
        else
            goTable.title_txt.text = "获得" .. StringHelper.ToCash(goodsData.buy_asset_count[1])
            goTable.doc_txt.text = "" 
            goTable.givedesc_txt.text = "加赠" .. goodsData.buy_asset_count[2]
            goTable.givedesc_img.gameObject:SetActive(true)
        end
    else
        goTable.ts_img.gameObject:SetActive(false)
        goTable.doc_txt.text = ""
        goTable.givedesc_txt.text = ""
        goTable.givedesc_img.gameObject:SetActive(false)
    end
    goTable.price_txt.text = "<size=45>￥</size>" .. goodsData.price / 100
    GetTextureExtend(goTable.icon_img, "pay_icon_gold9", 1)
    goTable.icon_img:SetNativeSize()
    goTable.pay_item_goods_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:PayGoodsGift(goodsData.id)
        end
    )
    go.gameObject:SetActive(true)
    return go
end