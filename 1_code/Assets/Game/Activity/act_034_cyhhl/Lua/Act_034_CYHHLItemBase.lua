-- 创建时间:2020-05-06
-- Panel:Act_034_CYHHLItemBase
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

Act_034_CYHHLItemBase = basefunc.class()
local C = Act_034_CYHHLItemBase
C.name = "Act_034_CYHHLItemBase"
local M = Act_034_CYHHLManager
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
	self.lister["LXDH_sw_kfPanel_msg"] = basefunc.handler(self,self.on_LXDH_sw_kfPanel_msg)
	self.lister["xgdh_tips_msg"] = basefunc.handler(self,self.on_xgdh_tips_msg)
end

function C:OnDestroy()
	self:MyExit()
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
	
	self.item_ani = self.yellow1_btn.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.data.ID).price
	if price == 0 then
		self.yellow_txt.text = "兑 换"
	else
		self.yellow_txt.text = (price/100).."元兑换"
	end
	self.xianliang_img.gameObject.transform.localPosition = Vector2.New(-88.5,-3.6)
	self.xianliang_img.gameObject.transform.localScale = Vector2.New(0.70,0.70)
end

function C:InitUI()
	EventTriggerListener.Get(self.yellow1_btn.gameObject).onClick = basefunc.handler(self, self.on_enough_BuyClick)
	EventTriggerListener.Get(self.blue_btn.gameObject).onClick = basefunc.handler(self, self.on_not_enough_BuyClick)
	EventTriggerListener.Get(self.tips_btn.gameObject).onClick = basefunc.handler(self,self.on_tips)

	self.gift_image_img.sprite = GetTexture(self.data.award_image)
	self.gift_image_img:SetNativeSize()
	self.title_txt.text = self.data.award_name
	self.item_cost_text_txt.text = "  "..self.data.item_cost_text
	self.blue_txt.text = "兑换"
	self.yellow_txt.text = "兑换"
	self.remain_txt.text = (self.data.remain_time == -1 or self.data.wuxian == 1) and "无限" or "剩"..self.data.remain_time
	if M.GetItemCount() < tonumber(self.data.item_cost_text) then--道具不足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then--有剩余次数
			self.gray_img.gameObject:SetActive(false)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(true)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(false)		
		end
	else--道具足
		if self.data.remain_time > 0 or self.data.remain_time == -1 then
			self.gray_img.gameObject:SetActive(false)
			self.yellow1_btn.gameObject:SetActive(true)
			self.item_ani:Play("blue1_ani",-1,0)
			self.blue_btn.gameObject:SetActive(false)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(false)
		end
	end
	if not self.data.tips then
		self.tips_btn.gameObject:SetActive(false)
	end

	if self.data.ID == 4 or self.data.ID == 10 then
		--self.xianliang.gameObject:SetActive(false)
		self.xianliang_img.sprite = GetTexture("xghhl_icon_bxl")
	end	
	self:MyRefresh()
end

function C:MyRefresh()
end



function C:on_enough_BuyClick()
	if os.time() >= PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."XGDH") then
		Event.Brocast("XGDH_toggle_set_true_msg")
		HintPanel.Create(2,"是否兑换"..self.data.award_name,function ()
			Event.Brocast("XGDH_toggle_set_false_msg")
			self:Buy(self.data.ID)
			--[[if self.data.type == M.type then
				local string1
				string1="奖品:"..self.data.award_name.."，请联系客服领取奖励\n客服QQ：%s"				
				HintCopyPanel.Create({desc=string1, isQQ=true})
			end--]]
		end,function ()
			Event.Brocast("XGDH_toggle_set_false_msg")
		end)
	else
		self:Buy(self.data.ID)
	end
end

function C:on_not_enough_BuyClick()
	LittleTips.Create("菊花道具不足")
end

function C:on_tips()
	if self.data.tips then
		if self.tips.gameObject.activeSelf then
			self.tips.gameObject:SetActive(false)
		else	
			self.tips.gameObject:SetActive(true)
			self.tips_txt.text = self.data.tips
			Event.Brocast("xgdh_tips_msg",self.data.ID)
		end
	end
end 

function C:on_LXDH_sw_kfPanel_msg(id)
	if id == self.data.ID then
		if self.data.type == 1 then
			local string1
			string1="奖品:"..self.data.award_name.."，请联系客服领取奖励\n客服QQ：%s"				
			HintCopyPanel.Create({desc=string1, isQQ=true})
		end
	end
end

function C:on_xgdh_tips_msg(id)
	if id == self.data.ID then
		return
	else
		if self.data.tips then
			self.tips.gameObject:SetActive(false)
		end
	end
end

function C:Buy(shop_id)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shop_id).price
	if price == 0 then 
		self:Pay4Free(shop_id)
	else
		self:BuyShop(shop_id)
	end 
end

function C:BuyShop(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:Pay4Free(goodsid)
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
            else
                HintPanel.ErrorMsg(_data.result)
            end
        end
    )
end