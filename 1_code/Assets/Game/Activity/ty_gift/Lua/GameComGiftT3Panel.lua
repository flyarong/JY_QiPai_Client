-- 创建时间:2019-10-24
-- Panel:GameComGiftT3Panel
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

GameComGiftT3Panel = basefunc.class()
local C = GameComGiftT3Panel
C.name = "GameComGiftT3Panel"

function C.Create(parent, backcall, config)
	dump(config,"<color=red>configconfigconfigconfig</color>")
	return C.New(parent, backcall, config)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	GameTipsPrefab.Hide()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent, backcall, config)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	self.backcall = backcall
	self.config = config
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.buy1_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBuyClick(self.shopid[1])
	end)
	self.buy2_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBuyClick(self.shopid[2])
	end)
	self.buy3_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBuyClick(self.shopid[3])
	end)
	PointerEventListener.Get(self.buy1_img.gameObject).onDown = function ()
		GameTipsPrefab.ShowDesc(self:GetContentStr(self.shopid[1]), UnityEngine.Input.mousePosition)
	end
	PointerEventListener.Get(self.buy1_img.gameObject).onUp = function ()
		GameTipsPrefab.Hide()
	end
	PointerEventListener.Get(self.buy2_img.gameObject).onDown = function ()
		GameTipsPrefab.ShowDesc(self:GetContentStr(self.shopid[2]), UnityEngine.Input.mousePosition)
	end
	PointerEventListener.Get(self.buy2_img.gameObject).onUp = function ()
		GameTipsPrefab.Hide()
	end
	PointerEventListener.Get(self.buy3_img.gameObject).onDown = function ()
		GameTipsPrefab.ShowDesc(self:GetContentStr(self.shopid[3]), UnityEngine.Input.mousePosition)
	end
	PointerEventListener.Get(self.buy3_img.gameObject).onUp = function ()
		GameTipsPrefab.Hide()
	end
	self.icon_img = {}
	self.icon_img[#self.icon_img + 1] = self.buy1_img
	self.icon_img[#self.icon_img + 1] = self.buy2_img
	self.icon_img[#self.icon_img + 1] = self.buy3_img

	self.buy1_yes_img = {}
	self.buy1_yes_img[#self.buy1_yes_img + 1] = self.buy1_btn.transform:GetComponent("Image")
	self.buy1_yes_img[#self.buy1_yes_img + 1] = self.buy2_btn.transform:GetComponent("Image")
	self.buy1_yes_img[#self.buy1_yes_img + 1] = self.buy3_btn.transform:GetComponent("Image")

	self.buy_no_img = {}
	self.buy_no_img[#self.buy_no_img + 1] = self.buy1_no_img
	self.buy_no_img[#self.buy_no_img + 1] = self.buy2_no_img
	self.buy_no_img[#self.buy_no_img + 1] = self.buy3_no_img

	self.bg_img.sprite = GetTexture(self.config.bg_img)
	for i=1, 3 do
		self.icon_img[i].sprite = GetTexture(self.config.icon_img[i])
		self.buy1_yes_img[i].sprite = GetTexture(self.config.btn_img[i])
		self.buy_no_img[i].sprite = GetTexture(self.config.btn_img_no[i])
	end
	self.shopid = self.config.gift_id
	self:SetTime()
	self:MyRefresh()
end

function C:MyRefresh()
	for i = 1, 3 do
		local status = MainModel.GetGiftShopStatusByID(self.shopid[i])
		if status == 1 then
			self.buy1_yes_img[i].gameObject:SetActive(true)
			self.buy_no_img[i].gameObject:SetActive(false)
		else
			self.buy1_yes_img[i].gameObject:SetActive(false)
			self.buy_no_img[i].gameObject:SetActive(true)
		end
	end
end


function C:OnBackClick()
	if self.backcall then
		self.backcall()
	end
	self:MyExit()
end
function C:OnExitScene()
	self:MyExit()
end
function C:OnBuyClick(id)
	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
	self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)

    local b1 = MathExtend.isTimeValidity(self.gift_config.start_time, self.gift_config.end_time)

    if b1 then
		if self.status ~= 1 then
			local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
			local s1 = os.date("%m月%d日%H点", self.gift_config.start_time)
			local e1 = os.date("%m月%d日%H点", self.gift_config.end_time)
			HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。\n(%s-%s每天可购买1次)",s1,e1))
			return
		end
    else
		HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
		return
    end
    
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100))
	end
end

function C:on_finish_gift_shop(id)
	self:MyRefresh()
end

function C:GetContentStr(_shopid)
	local config =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, _shopid)
	local str = ""
	if config.content then 
		str = config.content[1]
		for i = 2, #config.content do
			str = str.."\n"..config.content[i]
		end
	end
	return str 
end

function C:SetTime()
	local c = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.shopid[1])
	if c then 
		self.time_txt.text = os.date("%m月%d日%H:%M",c.start_time).."--"..os.date("%m月%d日%H:%M",c.end_time)
	end  
end