-- 创建时间:2021-12-01
-- Panel:Act_070_ZQLBPanel
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

Act_070_ZQLBPanel = basefunc.class()
local C = Act_070_ZQLBPanel
C.name = "Act_070_ZQLBPanel"
local M = Act_070_ZQLBManager

local rules = {
	"1.礼包每日限购一次，次日零点重置",
	"2.购买礼包后获得的火羽翻倍，只限当日有效",
	"3.购买礼包最高可获得2000万鲸币",
}

local lv_sprites = {
	"zqlb_imgf_gj",
	"zqlb_imgf_tj",
	"zqlb_imgf_zz",
}

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)

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
	self.config = M.GetCurConfig()
	self.lv = M.GetCurLv()
	self:InitUI()
	local lvTextureName = lv_sprites[self.lv]
	if lvTextureName then
		self.lv_img.sprite = GetTexture(lvTextureName)
	end 
end

function C:InitUI()
	self:InitGiftContent()
	self:InitGiftBtn()
	CommonTimeManager.GetCutDownTimer(M.endTime, self.remain_time_txt)
	self.back_btn.onClick:AddListener(function()
		self:MyExit()
	end)

	self.rule_btn.onClick:AddListener(function()
		self:OpenHelpPanel()
	end)

	self.buy_btn.onClick:AddListener(function()
		GameManager.BuyGift(self.config.gift_id)
	end)
	self:MyRefresh()
end

function C:InitGiftContent()
	for i = 1, 5 do
		self["num_" .. i .. "_txt"].text = self.config.show_txt[i]
	end
end

function C:InitGiftBtn()
	self.price_txt.text = self.config.gift_price .. "元"
	self.price_gray_txt.text = self.config.gift_price .. "元"
end

function C:RefreshGiftBtn()
	local giftStatus = MainModel.GetGiftShopStatusByID(self.config.gift_id)
	if giftStatus ~= 1 then
		self.buy_gray.gameObject:SetActive(true)
	else
		self.buy_gray.gameObject:SetActive(false)
	end
end

function C:OpenHelpPanel()
	local str = rules[1]
	for i = 2, #rules do
		str = str .. "\n" .. rules[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:MyRefresh()
	self:RefreshGiftBtn()
end

function C:on_finish_gift_shop()
	self:MyRefresh()
end

function C:OnExitScene()
	self:MyExit()
end

