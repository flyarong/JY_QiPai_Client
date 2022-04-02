-- 创建时间:2021-06-15
-- Panel:Act_060_YXCardSelectPanel
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

Act_060_YXCardSelectPanel = basefunc.class()
local C = Act_060_YXCardSelectPanel
C.name = "Act_060_YXCardSelectPanel"
local M = Act_060_YXCardManager

local level_bg = {
	"yxk_bg_1",
	"yxk_bg_2",
	"yxk_bg_3",
}

local yxk_icon = {
	"yxk_mcxxl",
	"yxk_shxxl",
	"yxk_csxxl",
	"yxk_xyxxl",
	-- "yxk_cjxxl",
	"yxk_sgxxl",
	"yxk_sjyxk",
}

function C.Create(chosedBackcall)
	return C.New(chosedBackcall)
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

function C:ctor(chosedBackcall)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.chip_key = M.CurYXCardChip("GET", nil)
	self.cardCfg = M.GetConfigByChip(self.chip_key)
	self.card_list = self.cardCfg.card_list
	self.chip_level = self.cardCfg.index
	self.chosedBackcall = chosedBackcall
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	self.comfirm_btn.onClick:AddListener(function()
		self:Comfirm()
	end)
	self:InitYXCardPre()

	if self.cardCfg.consume_type ~= "shop_gold_sum" then
		self.consume_txt.text = self.cardCfg.consume_num .. GameItemModel.GetItemToKey(self.cardCfg.consume_type).name
	else
		self.consume_txt.text = self.cardCfg.consume_num / 100 .. GameItemModel.GetItemToKey(self.cardCfg.consume_type).name
	end

	self:MyRefresh()
end

function C:InitYXCardPre()
	if table_is_null(self.card_list) then
		return
	end
	self.yxCardPre = {}
	for i = 1, #self.card_list + 1 do
		local b = GameObject.Instantiate(self.yx_item, self.yx_content.transform)
		local b_ui = {}
		LuaHelper.GeneratingVar(b.transform, b_ui)
		b.gameObject:SetActive(true)
		b_ui.item_img.sprite = GetTexture(yxk_icon[i])
		b_ui.item_bg_img.sprite = GetTexture(level_bg[self.chip_level])
		b_ui.yx_btn.onClick:AddListener(function()
			self:Chose(i)
		end)
		self.yxCardPre[i] = b_ui
	end
end

function C:Chose(index)
	if self.curIndex then
		self.yxCardPre[self.curIndex].yx_chose.gameObject:SetActive(false)
	end
	self.yxCardPre[index].yx_chose.gameObject:SetActive(true)
	self.curIndex = index
end

function C:Comfirm()
	if self.curIndex then
		if self.curIndex <= #self.card_list then
			M.CurChosedYXCard("SET", self.card_list[self.curIndex])
		else
			M.CurChosedYXCard("SET", nil) --随机
		end
		if self.chosedBackcall then
			self.chosedBackcall()
		end
	end
	self:MyExit()
end

function C:MyRefresh()
end
