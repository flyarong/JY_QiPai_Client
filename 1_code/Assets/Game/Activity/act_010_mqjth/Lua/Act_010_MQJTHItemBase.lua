-- 创建时间:2020-04-23
-- Panel:Act_010_MQJTHItemBase
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

local basefunc = require "Game/Common/basefunc"

Act_010_MQJTHItemBase = basefunc.class()
local C = Act_010_MQJTHItemBase
C.name = "Act_010_MQJTHItemBase"

function C.Create(parent,data)
	return C.New(parent,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}

    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end


function C:ctor(parent,data)
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.item_ani = self.transform:GetComponent("Animator")
	self.award_outline = self.award_txt.transform:GetComponent("Outline")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.enough_buy_btn.gameObject).onClick = basefunc.handler(self, self.on_enough_BuyClick)
	EventTriggerListener.Get(self.not_enough_buy_btn.gameObject).onClick = basefunc.handler(self, self.on_not_enough_BuyClick)

	self.award_txt.text = self.data.award_text
	self.item_img.sprite = GetTexture(self.data.Item_image)
	self.item_img:SetNativeSize()

	if self.data.gift_id == 10231 then
		self.eggs_nameBG1_img.sprite = GetTexture("mqjth_icon_hb")
		self.eggs_nameBG2_img.sprite = GetTexture("mqjth_icon_hb")
	end
	if self.data.origin_RMB_cost == "" then
		self.origin_line_txt.gameObject:SetActive(false)
		self.origin_RMB_cost_txt.text = self.data.origin_RMB_cost
	else
		self.origin_line_txt.gameObject:SetActive(true)
		self.origin_RMB_cost_txt.text = "原价:￥"..self.data.origin_RMB_cost
	end
	self.need_RMB_cost_txt.text = "￥"..self.data.need_RMB_cost.." +"
	self.flower_cost_txt.text = " "..self.data.flower_cost
	if Act_010_MQJTHManager.GetFlowerCount() < tonumber(self.data.flower_cost) then
		if self.data.remain_time > 0 and self.data.num > 0 then
			self.enough_buy_btn.gameObject:SetActive(false)
			self.not_enough_buy_btn.gameObject:SetActive(true)
			self:ChangeImgBtnTxtStatus(true)
		else
			self.enough_buy_btn.gameObject:SetActive(false)
			self.not_enough_buy_btn.gameObject:SetActive(false)
			self:ChangeImgBtnTxtStatus(false)			
		end
	else
		if self.data.remain_time > 0 and self.data.num > 0 then
			self.item_ani:Play("item_scale_ani",-1,0)
			self.enough_buy_btn.gameObject:SetActive(true)
			self.not_enough_buy_btn.gameObject:SetActive(false)
			self:ChangeImgBtnTxtStatus(true)
		else
			self.enough_buy_btn.gameObject:SetActive(false)
			self.not_enough_buy_btn.gameObject:SetActive(false)
			self:ChangeImgBtnTxtStatus(false)
		end
	end

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:ChangeImgBtnTxtStatus(bool)
	self.BG_yellow.gameObject:SetActive(bool)
	self.BG_gray.gameObject:SetActive(not bool)
	self.cost.gameObject:SetActive(bool)
	self.sold_out.gameObject:SetActive(not bool)
	if bool then--黄BG
		self.award_outline.effectColor = Color.New(190/255,69/255,27/255,1)
		self.origin_RMB_cost_txt.color = Color.New(198/255,68/255,27/255,1)
		self.origin_line_txt.color = Color.New(198/255,68/255,27/255,1)
	else--灰BG
		self.transform.localScale = Vector3.New(1,1,1)
		self.award_outline.effectColor = Color.New(122/255,87/255,55/255,1)
		self.origin_RMB_cost_txt.color = Color.New(122/255,65/255,38/255,1)
		self.origin_line_txt.color = Color.New(122/255,65/255,38/255,1)
	end
end

function C:BuyShop(shopid)
	dump(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function C:Pay4Free(shopid)
	goodsid = shopid
	local request = {}
    request.goods_id = goodsid
    request.channel_type = "weixin"
    request.geturl = MainModel.pay_url and "n" or "y"
    request.convert = self.convert
    dump(request, "<color=green>创建订单</color>")
    Network.SendRequest(
        "create_pay_order",
        request,
        function(_data)
            dump(_data, "<color=green>返回订单号</color>")
            if _data.result == 0 then
                MainModel.pay_url = _data.url or MainModel.pay_url
                local url = string.gsub(MainModel.pay_url, "@order_id@", _data.order_id)
            	if self.data.type == 1 then
					HintPanel.Create(1, "请联系客服QQ：4008882620领取奖励")
				end
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
end

function C:on_enough_BuyClick()
	if self.data.need_RMB_cost == "0" then
		self:Pay4Free(self.data.gift_id)
	else
		self:BuyShop(self.data.gift_id)
	end
end

function C:on_not_enough_BuyClick()
	HintPanel.Create(1, "康乃馨不足")
end


