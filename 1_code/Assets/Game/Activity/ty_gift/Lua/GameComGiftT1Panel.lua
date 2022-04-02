-- 创建时间:2019-10-24
-- Panel:GameComGiftT1Panel
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

GameComGiftT1Panel = basefunc.class()
local C = GameComGiftT1Panel
C.name = "GameComGiftT1Panel"

function C.Create(parent, backcall, config)
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
	self.buy_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBuyClick()
	end)
	self.buyimg_btn = self.bg_img.transform:GetComponent("Button")
	self.buyimg_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBuyClick()
	end)

	self.buy_yes_img = self.buy_btn.transform:GetComponent("Image")

	self.bg_img.sprite = GetTexture(self.config.bg_img)
	if self.config.btn_img and #self.config.btn_img > 0 then
		self.gift_rect.gameObject:SetActive(true)
		self.buy_yes_img.sprite = GetTexture(self.config.btn_img[1])
		self.buy_no_img.sprite = GetTexture(self.config.btn_img_no[1])
	else
		self.gift_rect.gameObject:SetActive(false)
	end

	if type(self.config.gift_id) == "table" then
		self.shopid = tonumber(self.config.gift_id[1])
	else
		self.shopid = tonumber(self.config.gift_id)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	local status = MainModel.GetGiftShopStatusByID(self.shopid)
	if status == 1 then
		self.buy_yes_img.gameObject:SetActive(true)
		self.buy_no_img.gameObject:SetActive(false)
	else
		self.buy_yes_img.gameObject:SetActive(false)
		self.buy_no_img.gameObject:SetActive(true)
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
function C:OnBuyClick()
	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, self.shopid)
	self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)

    local b1 = MathExtend.isTimeValidity(self.gift_config.start_time, self.gift_config.end_time)

    if b1 then
    	if self.gift_config.buy_limt == 0 then
            if status == 0 then
				HintPanel.Create(1, "您已购买过此礼包了")
                return
            end
        elseif self.gift_config.buy_limt == 1 then
            if status == 0 then
				local s1 = os.date("%m月%d日%H点", self.gift_config.start_time)
				local e1 = os.date("%m月%d日%H点", self.gift_config.end_time)
				HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。\n(%s-%s每天可购买1次)",s1,e1))
                return
            end
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
	if id == self.shopid then
		self:MyRefresh()
	end
end

