-- 创建时间:2020-03-24
-- Panel:SYSVip2UpPanel
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

SYSVip2UpPanel = basefunc.class()
local C = SYSVip2UpPanel
C.name = "SYSVip2UpPanel"

function C.Create(parent, backcall)
	return C.New(parent, backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:OnDestroy()
	self:MyExit()
end
function C:MyExit()
	if self.backcall then
		self.backcall()
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

	self.backcall = backcall
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.shopid = 10173 -- VIP3直通礼包ID

	self:InitUI()
	HandleLoadChannelLua(C.name,self)
end

function C:InitUI()
	PointerEventListener.Get(self.tips_rect.gameObject).onDown = function ()
		GameTipsPrefab.ShowDesc("1万特殊鱼币，5元充值优惠券*1，千元赛门票*1", UnityEngine.Input.mousePosition)
	end
	PointerEventListener.Get(self.tips_rect.gameObject).onUp = function ()
		GameTipsPrefab.Hide()
	end
	self.buy_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBuyClick(self.shopid)
	end)

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnBuyClick(id)
	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, id)
	self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)

    local b1 = MathExtend.isTimeValidity(self.gift_config.start_time, self.gift_config.end_time)

    if b1 then
		if self.status ~= 1 then
			HintPanel.Create(1, "您已购买过了")
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