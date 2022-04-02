-- 创建时间:2021-06-15
-- Panel:Act_060_YXCardComposePanel
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

Act_060_YXCardComposePanel = basefunc.class()
local C = Act_060_YXCardComposePanel
C.name = "Act_060_YXCardComposePanel"

local M = Act_060_YXCardManager

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
	self.lister["xxl_card_chip_merge_response"] = basefunc.handler(self, self.on_xxl_card_chip_merge_response)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.selectPanel then
		self.selectPanel:MyExit()
	end
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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.curChip = M.CurYXCardChip("GET")
	self.curCard = M.CurChosedYXCard("GET")
	self.chipCfg = M.GetConfigByChip(self.curChip)

	self.randomIcon = {
		"yxk_wh",
		"yxk_wh_2",
		"yxk_wh_3",
	}

	--一开始是随机的
	self.isRandom = true
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.selectPanel = nil
	self.close_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	self.compose_one_btn.onClick:AddListener(function()
		self:ComposeOne()
	end)
	self.compose_all_btn.onClick:AddListener(function()
		self:ComposeAll()
	end)
	self.select_btn.onClick:AddListener(function()
		self:SlectCard()
	end)
	self.cur_chip_txt.text = self.chipCfg.level .. "碎片"
	self.need_chip_num_txt.text = self.chipCfg.need_chip_num
	self.cur_chip_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.curChip).image)
	self.consumr_type = GameItemModel.GetItemToKey(self.chipCfg.consume_type).name
	self:RefreshCardView()
	self:RefreshChipNumView()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:RefreshCardView()
	if self.isRandom then
		self.cur_card_img.sprite = GetTexture(self.randomIcon[self.chipCfg.index])
		self.cur_card_txt.text = "随机游戏卡"
	else
		self.cur_card_img.sprite = GetTexture(GameItemModel.GetItemToKey(self.curCard).image)
		self.cur_card_txt.text = GameItemModel.GetItemToKey(self.curCard).name
	end
end

function C:RefreshChipNumView()
	self.cur_chip_num_txt.text = GameItemModel.GetItemCount(self.curChip)

	if self.isRandom then
		self.compose_one_txt.text = ""
		self.compose_all_txt.text = ""
		return
	end

	self:ConsumeTxtView(self.compose_one_txt, self.chipCfg.consume_num)
	self.consume_all_num = self.chipCfg.consume_num * math.floor(GameItemModel.GetItemCount(self.curChip) / self.chipCfg.need_chip_num)
	self:ConsumeTxtView(self.compose_all_txt, self.consume_all_num)
end

function C:ConsumeTxtView(txt_obj, count)
	if self.chipCfg.consume_type ~= "shop_gold_sum" then
		txt_obj.text = "消耗" .. StringHelper.ToCash(count) .. self.consumr_type
	else
		txt_obj.text = "消耗" .. StringHelper.ToCash(count / 100) .. self.consumr_type
	end
end


-- _is_all:是否全部兑换
-- _is_random:是否随机兑换
local function Compose(_is_all, _is_random)
	local data = {
		is_all = _is_all,
		chip_type = M.CurYXCardChip("GET"),
	}
	if not _is_random then
		data.card_type = M.CurChosedYXCard("GET")
	end
	dump(data, "<color=red>合成碎片DATA</color>")
	Network.SendRequest("xxl_card_chip_merge", data)
end

function C:CheckIsCompose(need_chip_num, need_consum_num)
	if GameItemModel.GetItemCount(self.curChip) < self.chipCfg.need_chip_num then
		LittleTips.Create("碎片不足")
		return false
	end

	if not self.isRandom and GameItemModel.GetItemCount(self.chipCfg.consume_type) < need_consum_num then
		LittleTips.Create(self.consumr_type .. "不足")
		return false
	end
	return true
end

--合成一个
function C:ComposeOne()
	if self:CheckIsCompose(self.chipCfg.need_chip_num, self.chipCfg.consume_num) then
		Compose(0, self.isRandom)
	end
end

--全部合成
function C:ComposeAll()
	if self:CheckIsCompose(self.chipCfg.need_chip_num, self.consume_all_num) then
		Compose(1, self.isRandom)
	end
end

--选择游戏卡
function C:SlectCard()
	local chosedBackcall = function()
		self.curCard = M.CurChosedYXCard("GET")
		if self.curCard == nil then
			self.isRandom = true
		else
			self.isRandom = false
		end
		self:RefreshCardView()
		self:RefreshChipNumView()
	end
	self.selectPanel = Act_060_YXCardSelectPanel.Create(chosedBackcall)
end

function C:on_xxl_card_chip_merge_response(_, data)
	dump(data, "<color=red>合成碎片RESPONSE</color>")
	if data.result == 0 then
		self:RefreshChipNumView()
	end
end