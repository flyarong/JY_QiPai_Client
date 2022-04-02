-- 创建时间:2021-11-17
-- Panel:Act_069_ZCJBPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_069_ZCJBPanel = basefunc.class()
local C = Act_069_ZCJBPanel
C.name = "Act_069_ZCJBPanel"
local M = Act_069_ZCJBManager

function C.Create()
	return C.New()
end

local rules = {
	"1.礼包每日限购一次，次日零点重置",
	"2.购买礼包后获得的财力值翻倍，只限当日有效",
	"3.购买礼包最高可获得2000万鲸币",
}

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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	CommonTimeManager.GetCutDownTimer(M.endTime, self.remain_time_txt)
end

function C:InitUI()

	self.back_btn.onClick:AddListener(function()
		self:MyExit()
	end)

	self.buy_btn.onClick:AddListener(function()
		GameManager.BuyGift(10905)
	end)

	self.rule_btn.onClick:AddListener(function()
		self:OpenHelpPanel()
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	local giftStatus = MainModel.GetGiftShopStatusByID(10905)
	if giftStatus ~= 1 then
		self.buy_gray.gameObject:SetActive(true)
	else
		self.buy_gray.gameObject:SetActive(false)
	end
end

function C:on_finish_gift_shop()
	self:MyRefresh()
end

function C:OnExitScene()
	self:MyExit()
end

function C:OpenHelpPanel()
	local str = rules[1]
	for i = 2, #rules do
		str = str .. "\n" .. rules[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end