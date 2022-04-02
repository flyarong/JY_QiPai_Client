-- 创建时间:2020-03-24
-- Panel:SYSVip3GuidePanel
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

SYSVip3GuidePanel = basefunc.class()
local C = SYSVip3GuidePanel
C.name = "SYSVip3GuidePanel"

function C.Create(parent)
	return C.New(parent)
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
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

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
	self.tips_rect_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		HintPanel.Create(2,"成为Vip4可免费领<color=#EC8A12FF>5～1000元</color>比赛福卡，次数不限！", function ()
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end)
	end)
	self.buy_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		local shopid = 10295
		local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
		if not gb then return end
		local price = gb.price
		if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
			ServiceGzhPrefab.Create({desc="请前往公众号获取"})
		else
			PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
		end
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end
