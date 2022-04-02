-- 创建时间:2019-09-11
-- Panel:GameComGiftPanel
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

GameComGiftPanel = basefunc.class()
local C = GameComGiftPanel
C.name = "GameComGiftPanel"

function C.Create(gift_id)
	local cfg = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, gift_id)
    if cfg then
    	local cur_t = os.time()
    	if cfg.on_off == 1 and (cfg.start_time == -1 or cur_t >= cfg.start_time) and (cfg.end_time == -1 or cur_t <= cfg.end_time) then
	    	return C.New(gift_id)
    	else
	    	return
    	end
    else
    	return
    end
	
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop_shopid)
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

function C:ctor(gift_id)

	ExtPanel.ExtMsg(self)

	self.gift_id = gift_id
	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, gift_id)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	PointerEventListener.Get(self.gift_img.gameObject).onClick = function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnShopClick()
	end
	PointerEventListener.Get(self.back_btn.gameObject).onClick = function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end

	-- 资源
	if gift_id == 10025 then
		self.gift_img.sprite = GetTexture("gy_57")
	else
	end
	self.gift_img:SetNativeSize()

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:OnBackClick()
	self:MyExit()
end
function C:OnShopClick()
    local b1 = MathExtend.isTimeValidity(self.gift_config.start_time, self.gift_config.end_time)

    local status = MainModel.GetGiftShopStatusByID(self.gift_config.id)
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

function C:on_finish_gift_shop_shopid(id)
	if id == self.gift_id then
		self:MyRefresh()
	end
end
function C:OnExitScene()
	self:MyExit()
end
