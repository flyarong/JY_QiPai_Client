-- 创建时间:2021-08-03
-- Panel:EliminateBSHJMoneyPanel
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

EliminateBSHJMoneyPanel = basefunc.class()
local C = EliminateBSHJMoneyPanel
C.name = "EliminateBSHJMoneyPanel"
local M = EliminateBSModel

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
	self.lister["view_lottery_start"] = basefunc.handler(self, self.eliminate_lottery_start)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.eliminate_lottery_end)
    self.lister["view_lottery_error"] = basefunc.handler(self, self.view_lottery_error)
    self.lister["view_lottery_sucess"] = basefunc.handler(self, self.view_lottery_sucess)
	self.lister["AssetChange"] = basefunc.handler(self, self.AssetChange)
	self.lister["PayPanelClosed"] = basefunc.handler(self, self.OnClosePayPanel)
	self.lister["view_bshj_lottery_end"] = basefunc.handler(self, self.view_bshj_lottery_end)
	self.lister["view_bshj_all_lottery_end"] = basefunc.handler(self, self.view_bshj_all_lottery_end)
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
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj																															
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self:RefreshGoldText(true)
end

function C:InitUI()					
	self.PayBtn = self.gameObject.transform:Find("GoldInfo/PayBtn"):GetComponent("Button")												
    self.GoldText = self.gameObject.transform:Find("GoldInfo/GoldText"):GetComponent("Text")
    self.Content = self.transform:Find("Viewport/layoutgroup")
	self.RemainTimeImg = self.gameObject.transform:Find("RemainTime"):GetComponent("Image")
	--EventTriggerListener.Get(self.PayBtn.gameObject).onClick = basefunc.handler(self, function()
		--PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
	--end)
	self.jiaqian = {}
	self:MyRefresh()
	self:InitBetList()
	self:InitBetIndex()
	self:InitChildButton()
	self:RefreshRemainTime()

	if EliminateBSModel.is_ew_bet then
		self.ew_img.gameObject:SetActive(true)
	else
		self.ew_img.gameObject:SetActive(false)
	end
    self.jiaqianText = self.gameObject.transform:Find("AddMoney/Text"):GetComponent("Text")
	local rate = EliminateBSModel.is_ew_bet and 1.25 or 1
    self.jiaqianText.text = StringHelper.ToCash(self.jiaqian[self.index] * rate) 
end

function C:MyRefresh()
end

function C:InitBetIndex()
	local jiaqian_card = EliminateBSModel.data.bet[1] * 5
	for k,v in ipairs(self.jiaqian) do
		if v == jiaqian_card then
			self.index = k
		end
	end
end

--初始化押注的档次表
function C:InitBetList()
    for key, value in pairs(EliminateBSModel.xiaoxiaole_bs_defen_cfg.yazhu) do
        self.jiaqian[value.dw] = value.jb
    end
end

--初始化子按钮
function C:InitChildButton()
    self.childs = {}
	for i = 1, 5 do
        local child = EliminateBSButtonPrefab.Create(i, self.jiaqian[self.index] / 5, self.Content)
        self.childs[i] = child
    end
end

function C:RefreshGoldText(isFirst)
	if isFirst and EliminateBSModel.bshj_data.primaryGold then
		self.GoldText.text = StringHelper.ToCash(EliminateBSModel.bshj_data.primaryGold)
	else
		self.GoldText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
	end
end

function C:RefreshRemainTime(time)
	local time = time or 0
	if time < 0 or time > 6 then
		return
	end
	local viewNum = 6 - time
	self.RemainTimeImg.sprite = GetTexture("xyx_imgf_" .. viewNum)
end

function C:AssetChange(data)
	--self:RefreshGoldText()
end

function C:eliminate_lottery_start()

end

function C:eliminate_lottery_end()
	self:RefreshGoldText()
end

function C:view_lottery_sucess()
	self:RefreshGoldText()
end

function C:view_lottery_error()
	self:RefreshGoldText()
end

function C:OnClosePayPanel()
	self:RefreshGoldText()
end

--开奖错误
function C:view_quit_game()
    self:MyClose()
end

function C:view_bshj_lottery_end(data)
	self:RefreshRemainTime(data.lottery_num)
end

function C:view_bshj_all_lottery_end()
	self:RefreshGoldText()
end
