-- 创建时间:2020-05-06
-- Panel:Act_042_YGHHLItemBase
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

Act_Ty_ExchangeItemBase = basefunc.class()
local C = Act_Ty_ExchangeItemBase
C.name = "Act_Ty_ExchangeItemBase"
local M = Act_Ty_ExchangeManager
function C.Create(parent,exchange_key,ID)
	return C.New(parent,exchange_key,ID)
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
	if self.is_tip_showing then
		self:HideTipObj()
		self.is_tip_showing = false
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,exchange_key,ID)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.exchange_key = exchange_key
	self.ID = ID 
	self.cfg_base = M.GetExchangeCfg(self.exchange_key)
	self.cfg = self.cfg_base.exchanges[self.ID]
	self.is_tip_showing = false
	LuaHelper.GeneratingVar(self.transform, self)
	--self.cast_img.sprite = GetTexture(self.cfg_base.item_icon)
	self.item_bg_img = self.transform:Find("top/BG"):GetComponent("Image")
	SetTextureExtend(self.item_bg_img,self.cfg_base.style_key.."_".."bg_2")
	SetTextureExtend(self.cast_img,self.cfg_base.style_key.."_".."icon_1")
	
	self:UpdataData()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	--Event.Brocast("ty_exchange_base_item_create_finish",self)
end

function C:UpdataData()
	self.remian_time = M.GetRemainTime(self.exchange_key,self.ID)
	self.is_all_exchange = M.IsAllExhcange(self.exchange_key,self.ID)
end

function C:InitUI()
	EventTriggerListener.Get(self.yellow1_btn.gameObject).onClick = basefunc.handler(self, self.BuyClick)
	EventTriggerListener.Get(self.blue_btn.gameObject).onClick = basefunc.handler(self, self.GoToGameClick)

	PointerEventListener.Get(self.tips_btn.gameObject).onDown = function ()
		self.is_tip_showing = true
		self:ViewTipObj()
	end
	PointerEventListener.Get(self.tips_btn.gameObject).onUp = function ()
		self.is_tip_showing = false
		self:HideTipObj()
	end
	self.gift_image_img.sprite = GetTexture(self.cfg.award_image)
	--self.gift_image_img:SetNativeSize()
	if self.cfg.is_real == 1 then
		self.gift_image_img:GetComponent("RectTransform").sizeDelta = Vector3.New(148,148)
	else
		self.gift_image_img:GetComponent("RectTransform").sizeDelta = Vector3.New(160,160)
	end

	if string.find(self.cfg.award_image, "by_btn") then
		self.gift_image_img:GetComponent("RectTransform").sizeDelta = Vector3.New(120,120)
	end

	self.title_txt.text = self.cfg.award_name
	self.item_cost_text_txt.text = "  "..self.cfg.item_cost_text
	self.blue_txt.text = "前往"
	self.yellow_txt.text = "兑换"

	if self.cfg.gift_id then
		local gift_cfg = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.cfg.gift_id)
		if not gift_cfg then
			return 
		end
		local ui_price = math.floor((gift_cfg.price or 0) / 100)
		self.yellow_txt.text = ui_price.."元兑换"
	end

	self:SetTxt(self.title_txt.transform,self.cfg_base.item_name_fmt)
	self:SetTxt(self.xiaohao_txt.transform,self.cfg_base.item_comsume_fmt)
	self:SetTxt(self.item_cost_text_txt.transform,self.cfg_base.item_comsume_fmt)
	self:SetTxt(self.ex_num_txt.transform,self.cfg_base.item_comsume_fmt)
	self:SetTxt(self.ex_song_txt.transform,self.cfg_base.item_comsume_fmt)

	self.remain_txt.text = self.remian_time == -1 and "无限" or "剩"..self.remian_time

	if M.GetItemCount(self.exchange_key) < tonumber(self.cfg.item_cost_text) then--道具不足
		if self.remian_time > 0 or self.remian_time == -1 then --有剩余次数
			self.gray_img.gameObject:SetActive(false)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(true)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(false)		
		end
	else--道具足
		if self.remian_time > 0 or self.remian_time == -1 then
			self.gray_img.gameObject:SetActive(false)
			self.yellow1_btn.gameObject:SetActive(true)
			self.blue_btn.gameObject:SetActive(false)
		else--没有剩余次数
			self.gray_img.gameObject:SetActive(true)
			self.yellow1_btn.gameObject:SetActive(false)
			self.blue_btn.gameObject:SetActive(false)
		end
	end

	if not self.cfg.tips then
		self.tips_btn.gameObject:SetActive(false)
	end

	if self.cfg_base.type == 1 then
		if self.is_all_exchange then
			self.gray_img.transform:Find("Text"):GetComponent("Text").text = "已兑换"
		end
	end

	self:ViewExtAward()
end

function C:MyRefresh()
	self:UpdataData()
	self:InitUI()
end

function C:BuyClick()
	if self.cfg.gift_id then --进行购买
		self:BuyGift()
	else
		self:ExchangeClick()
	end
end

function C:ExchangeClick()
	local send_request = function ()
		Network.SendRequest("activity_exchange",{ type = self.cfg_base.exchange_type , id = self.cfg.ID })
	end

	if os.time() >= PlayerPrefs.GetInt(MainModel.UserInfo.user_id..self.exchange_key) then
		Event.Brocast("ty_exchange_toggle_set_true_msg")
		HintPanel.Create(2,"是否兑换"..self.cfg.award_name,function ()
			Event.Brocast("ty_exchange_toggle_set_false_msg",true)
			send_request()
			--[[if self.data.type == M.type then
				local string1
				string1="奖品:"..self.data.award_name.."，请联系客服领取奖励\n客服QQ：%s"				
				HintCopyPanel.Create({desc=string1, isQQ=true})
			end--]]
		end,function ()
			Event.Brocast("ty_exchange_toggle_set_false_msg",false)
		end)
	else
		send_request()
	end
end

function C:BuyGift()

	local gift_cfg = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.cfg.gift_id)
	if not gift_cfg then
		return 
	end
	local gift_status = MainModel.GetGiftShopStatusByID(self.cfg.gift_id)
	local isInTime = MathExtend.isTimeValidity(gift_cfg.start_time, gift_cfg.end_time)

	if not isInTime then
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
	end

	if gift_status ~= 1 then
		local s1 = os.date("%m月%d日%H点", gift_cfg.start_time)
		local e1 = os.date("%m月%d日%H点", gift_cfg.end_time)
		HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。",s1,e1))
		return
	end

	if gift_cfg.price == 0 then
		self:Pay4Free(self.cfg.gift_id)
		return
	end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(self.cfg.gift_id, "￥" .. (gift_cfg.price / 100))
	end
end

function C:GoToGameClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local gotoUI = self.cfg_base.gotoUI and self.cfg_base.gotoUI or "game_MiniGame"
	GameManager.GotoUI({gotoui = gotoUI})
end

function C:SetTxt(txt_trans, fmt_cfg)
	if #fmt_cfg >= 1 then
		txt_trans:GetComponent("Text").color = M.ColorToRGB(fmt_cfg[1])
	end

	local outline_com = txt_trans:GetComponent("Outline")
	if #fmt_cfg == 1 then
		if outline_com then
			destroy(outline_com)
		end
	end

	if #fmt_cfg == 2 then
		if not outline_com then
			outline_com =  txt_trans.gameObject:AddComponent(typeof(UnityEngine.UI.Outline))
		end
		outline_com.effectColor = M.ColorToRGB(fmt_cfg[2])
    end
end

--附加奖励
function C:ViewExtAward()
	if self.cfg.ex_award_num then
		self.ex_award_node.gameObject:SetActive(true)
		self.ex_icon_img = self.ex_icon_btn:GetComponent("Image")
		SetTextureExtend(self.ex_icon_img,self.cfg_base.style_key.."_".."icon_4")
		self.ex_num_txt.text = "x" .. self.cfg.ex_award_num
	else
		self.ex_award_node.gameObject:SetActive(false)
	end
end

function C:ViewTipObj()
    if not self.cfg.tips then return end

    self.tip.gameObject:SetActive(true)
    local parent = GameObject.Find("Canvas/LayerLv5").transform
    self.tip.transform:SetParent(parent)

    self.tips_tit_txt.text = self.cfg.tips[1]
    self.tips_desc_txt.text = self.cfg.tips[2]
end

function C:HideTipObj()
    if not self.cfg.tips then return end
    self.tip.transform:SetParent(self.transform)
    self.tip.gameObject:SetActive(false)
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