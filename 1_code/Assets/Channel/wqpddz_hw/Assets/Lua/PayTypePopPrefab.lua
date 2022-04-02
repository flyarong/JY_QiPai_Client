-- 创建时间:2018-09-20
-- 华为支付方式界面

local basefunc = require "Game.Common.basefunc"

PayTypePopPrefab = basefunc.class()

local instance = nil

function PayTypePopPrefab.Create(goodsid, desc, createcall,convert)
    -- 防沉迷
    local b,c = GameButtonManager.RunFunExt("sys_fcm", "IsPopupHint", nil, {type="chong_zhi"})
    if b and c then
        GameManager.GotoUI({gotoui="sys_fcm", goto_scene_parm="panel"})
        return
    end
    
	local iconFile = "com_icon_diamond.png"
	local imgFile = resMgr.DataPath .. iconFile
	if not File.Exists(imgFile) then
		if not resMgr:ExtractSprite(iconFile, imgFile) then
			print("[Pay] extract sprite failed:" .. iconFile)
			return
		end
	end

    local goods_data = PayTypePopPrefab.GetGoodsDataByID(goodsid)

	local request = {}
	request.goods_id = goodsid
	request.convert = convert
	if PayPanel.IsTest() then
		request.is_test = 1
	else
		request.is_test = 0
    end
    
    print("PayTypePopPrefab.Create" .. goodsid)

	Network.SendRequest("huawei_wqp_create_pay_order", request, function(_data)
		dump(_data, "<color=green>返回订单号</color>")
		if _data.result == 0 then
			local luaData = {
				productId = goodsid,
				productName = goods_data.pay_title,
				amount = string.format("%.2f",goods_data.price / 100),
				priceType = 0,
				developerPayload = _data.order_id
				--productDesc = goods_data.ui_describe or goods_data.pay_title,
			}
			if convert then
				luaData.productName = luaData.productName .. "-->jing_bi"
			end
		    
            dump(luaData)

            sdkMgr:Pay(lua2json(luaData), nil)
		else
			HintPanel.ErrorMsg(_data.result)
		end
	end)

	-- instance = PayTypePopPrefab.New(goodsid, desc, createcall,convert)
    -- return instance
end

function PayTypePopPrefab:ctor(goodsid, desc, createcall,convert)
	local parent = GameObject.Find("Canvas/LayerLv50").transform
    self.gameObject = newObject("UIPayType", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform
    self.goodsid = goodsid
    self.convert = convert
    self.desc = desc
    self.createcall = createcall
    self.goods_data = PayTypePopPrefab.GetGoodsDataByID(goodsid)
    dump(self.goods_data, "<color=yellow>购买商品：：：：：</color>")
	self.goTable = {}
    LuaHelper.GeneratingVar(tran, self.goTable)

    self:InitRect()
end
function PayTypePopPrefab:InitRect()
	self.goTable.goods_price_txt.text = self.desc

    self.goTable.pay_type_close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        MainLogic.IsHideAssetsGetPanel = nil
        destroy(self.gameObject)
    end)
    self.goTable.zfb_btn.onClick:AddListener(function ()
        if self.goods_data and self.goods_data.zfb_pay and self.goods_data.zfb_pay == 2 then
            local str = self.goods_data.zfb_pay_desc or "暂不微信支持购买"
            LittleTips.Create(str)
            return
        end
        self:OnAlipayClick()
	end)

    self.goTable.wx_btn.onClick:AddListener(function ()
        if self.goods_data and self.goods_data.wx_pay and self.goods_data.wx_pay == 2 then
            local str = self.goods_data.wx_pay_desc or "暂不微信支持购买"
            LittleTips.Create(str)
            return
        end
      	self:OnWeixinClick()
    end)
    if self.goods_data then
        local v = self.goods_data
        if v.wx_pay then
            if v.wx_pay == 0 then
                self.goTable.wx_btn.gameObject:SetActive(false)
            elseif v.wx_pay == 1 then
                self.goTable.wx_btn.gameObject:SetActive(true)
            elseif v.wx_pay == 2 then
                self.goTable.wx_btn.gameObject:SetActive(true)
                local img = self.goTable.wx_btn.transform:GetComponent("Image")
                if img then
                    img.material = GetMaterial("imageGrey")
                end
            end
        end
        self.goTable.wx_doc_txt.text = v.wx_pay_desc or ""

        if v.zfb_pay then
            if v.zfb_pay == 0 then
                self.goTable.zfb_btn.gameObject:SetActive(false)
            elseif v.zfb_pay == 1 then
                self.goTable.zfb_btn.gameObject:SetActive(true)
            elseif v.zfb_pay == 2 then
                self.goTable.zfb_btn.gameObject:SetActive(true)
                local img = self.goTable.zfb_btn.transform:GetComponent("Image")
                if img then
                    img.material = GetMaterial("imageGrey")
                end
            end
        end
        self.goTable.zfb_doc_txt.text = v.zfb_pay_desc or ""

        if v.wx_pay and v.zfb_pay then
            if v.wx_pay == 0 and v.zfb_pay ~= 0 then
                self.goTable.zfb_btn.transform.localPosition = Vector3.New(0,-105,0)
            elseif v.wx_pay ~= 0 and v.zfb_pay == 0 then
                self.goTable.wx_btn.transform.localPosition = Vector3.New(0,-105,0)
            end
        end
    end
end

function PayTypePopPrefab:OnAlipayClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not GameGlobalOnOff.ZFBPay then
        --支付宝没有开启
        HintPanel.Create(1, "支付宝支付尚未开通")
        return
    end
    --到网页购买
    self:SendPayRequest("alipay")
    destroy(self.gameObject)
end

function PayTypePopPrefab:OnWeixinClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if not GameGlobalOnOff.WXPay then
        --微信支付没有开启
        HintPanel.Create(1, "微信支付尚未开通")
        return
    end
    --到网页购买
    self:SendPayRequest("weixin")
    destroy(self.gameObject)
end

function PayTypePopPrefab:SendPayRequest(channel_type)
    local request = {}
    request.goods_id = self.goodsid
    request.channel_type = channel_type
    request.geturl = MainModel.pay_url and "n" or "y"
    request.convert = self.convert
    dump(request, "<color=green>创建订单</color>")
    Network.SendRequest(
        "create_pay_order",
        request,
        function(_data)
            dump(_data, "<color=green>返回订单号</color>")
            if _data.result == 0 then
                if self.createcall then
                    self.createcall(_data.result)
                end
                MainModel.pay_url = _data.url or MainModel.pay_url

                local url = string.gsub(MainModel.pay_url, "@order_id@", _data.order_id)
                UnityEngine.Application.OpenURL(url)
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
end

function PayTypePopPrefab.GetGoodsDataByID(id)
    local goods_data
    goods_data = MainModel.GetShopingConfig(GOODS_TYPE.goods, id)
    if table_is_null(goods_data) then
        goods_data = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
    end
    return goods_data
end