local basefunc = require "Game.Common.basefunc"

package.loaded["Game.game_FishingDR.Lua.FishingDRBetPopMenu"] = nil
require "Game.game_FishingDR.Lua.FishingDRBetPopMenu"

FishingDRBetPanel = basefunc.class()
FishingDRBetPanel.name = "FishingDRBetPanel"

local instance = nil
local MAX_CD_TIME = 10
local MAX_BET_LIMIT = 5000000
local MAX_PAGE_ITEM = 9
local MAX_TOTAL_ITEM = 60

local LOCAL_BET_KEY = "_BYDR_LOCAL_BET_"
local LOCAL_MODE_KEY = "_BYDR_LOCAL_MODE_"
local LOCAL_POWER_KEY = "_BYDR_LOCAL_POWER_"

local BET_RATE_TBL = {
	[1] = {
		header = "bydr_game_icon_y1", image = "fkby_btn_3", thumb = "bydr_game_icon_y8"
	},
	[2] = {
		header = "bydr_game_icon_y2", image = "fkby_btn_3", thumb = "bydr_game_icon_y9"
	},
	[3] = {
		header = "bydr_game_icon_y3", image = "fkby_btn_3", thumb = "bydr_game_icon_y10"
	},
	[4] = {
		header = "bydr_game_icon_y4", image = "fkby_btn_3", thumb = "bydr_game_icon_y11"
	},
	[5] = {
		header = "bydr_game_icon_y5", image = "fkby_btn_3", thumb = "bydr_game_icon_y12"
	},
	[6] = {
		header = "bydr_game_icon_y6", image = "fkby_btn_3", thumb = "bydr_game_icon_y13"
	},
	[7] = {
		header = "bydr_game_icon_y7", image = "fkby_btn_3", thumb = "bydr_game_icon_y14"
	}
}

local BET_POWER_TBL = {
	[1] = {
		value = 500
	},
	[2] = {
		value = 5000
	},
	[3] = {
		value = 20000
	},
	[4] = {
		value = 50000
	},
	[5] = {
		value = 100000
	},
	[6] = {
		value = 500000
	},
	[7] = {
		value = 1000000
	}
}

local BET_AUTO_TBL = {
	[1] = {
		value = 5
	},
	[2] = {
		value = 20
	},
	[3] = {
		value = 50
	},
	[4] = {
		value = 100
	},
	[5] = {
		value = 200
	},
	[6] = {
		value = 500
	}
}

local lister = {}
function FishingDRBetPanel:MakeLister()
	lister = {}

	lister["fishing_dr_bet_response"] = basefunc.handler(self, self.handle_bet)
	lister["fishing_dr_again_bet_response"] = basefunc.handler(self, self.handle_again_bet)
	lister["fishing_dr_reset_bet_response"] = basefunc.handler(self, self.handle_reset_bet)
	lister["fishing_dr_histroy_response"] = basefunc.handler(self, self.handle_histroy)
	lister["add_history_log"] = basefunc.handler(self, self.handle_add_histroy)
	lister["fishing_dr_all_bet"] = basefunc.handler(self, self.handle_all_bet)
	lister["model_auto_bet"] = basefunc.handler(self, self.handle_auto_bet)
	lister["model_reset_auto_bet"] = basefunc.handler(self, self.handle_reset_auto_bet)
	lister["model_receive_prize"] = basefunc.handler(self, self.handle_receive_prize)

	--lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)

	lister["bydr_bet_pop_menu_click"] = basefunc.handler(self, self.handle_bet_pop_menu_click)
end

function FishingDRBetPanel:AddMsgListener()
	for proto_name,func in pairs(lister) do
		Event.AddListener(proto_name, func)
	end
end

function FishingDRBetPanel:RemoveListener()
	for proto_name,func in pairs(lister) do
		Event.RemoveListener(proto_name, func)
	end
	lister = {}
end

function FishingDRBetPanel.Create(parent)
	FishingDRBetPanel.Close(true)
	instance = FishingDRBetPanel.New(parent)
	return instance
end

function FishingDRBetPanel:ctor(parent)
	if not parent then
		parent = GameObject.Find("Canvas/LayerLv3").transform
	end
	local obj = newObject(FishingDRBetPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = obj

	self.local_bet_key = MainModel.UserInfo.user_id .. LOCAL_BET_KEY
	self.local_mood_key = MainModel.UserInfo.user_id .. LOCAL_MODE_KEY
	self.local_power_key = MainModel.UserInfo.user_id .. LOCAL_POWER_KEY
	--LOCAL_MODE_KEY = MainModel.UserInfo.user_id .. LOCAL_MODE_KEY
	--LOCAL_POWER_KEY = MainModel.UserInfo.user_id .. LOCAL_POWER_KEY
	LuaHelper.GeneratingVar(self.transform, self)
	ExtPanel.ExtMsg(self)
	self:MakeLister()
	self:AddMsgListener()

	self.fishList = {}
	self.scrollList = {}
	self.fish_data = {}
	self.fish_ui_data = {}

	self.rateList = {}
	self.rankList = {}
	self.rankItemList = {}
	self.rankPage = 0
	self.lastRank = -1
	self.newRank = 0
	self.showMode = -1
	self.rank_data = {}
	self.rank_ui_data = {}

	self.rateFactor = 0
	self.rateTable = {}

	self:LoadLastRates()

	FishingDRBetPanel.TweenLocalMove(self.transform, Screen.width, true, 0.3, function()
		self:InitRect()
	end)
end

function FishingDRBetPanel.Close(immediate)
	immediate = immediate or false

	FishingDRBetPopMenu.Close()
	if instance then
		if immediate then
			instance:ClearAll()
			instance = nil
		else
			FishingDRBetPanel.TweenLocalMove(instance.transform, Screen.width, false, 0.3, function()
				if instance then
					instance:ClearAll()
					instance = nil
				end
			end)
		end
	end
end

function FishingDRBetPanel.GetFishImages(idx)
	return BET_RATE_TBL[idx]
end

function FishingDRBetPanel:InitRect()
	local transform = self.transform
	if not IsEquals(transform) then return end

	self.fish_tmpl = transform:Find("Left/fish_tmpl")
	self.fish_list_node = transform:Find("Left/fish_list_node")

	for k, v in ipairs(BET_RATE_TBL) do
		local item = self:CreateItem(self.fish_list_node, self.fish_tmpl)
		local icon_img = item.transform:Find("icon_img"):GetComponent("Image")
		icon_img.sprite = GetTexture(v.header)
		icon_img:SetNativeSize()
		icon_img.gameObject:SetActive(false)
		self.fishList[k] = item
	end

	self.pop_gold_tmpl = GetPrefab("PopGlod")

	------------------------------------------------------------------------------------------

	local btns_node = transform:Find("Middle/btns")

	self.repeat_img = btns_node:Find("repeat_img")
	self.repeat_btn = btns_node:Find("repeat_btn"):GetComponent("Button")
	self.repeat_btn.onClick:AddListener(function()
		if self.lastRates == nil or #self.lastRates <= 0 then return end
		if not self:CanSetBet() then
			LittleTips.Create("当前自动下注，无法手动购买")
			return
		end
		if not self:CheckTime(true) then return end
		if not self:CheckMoney(self.lastRates, 0, 0) then return end
		local data = {}
		for k, v in ipairs(self.lastRates) do
			if v > 0 then
				table.insert(data, {id = k, bet = v})
			end
		end
		self:send_again_bet(data)
	end)
	if self.lastRates == nil or #self.lastRates <= 0 then
		self.repeat_btn.gameObject:SetActive(false)
		self.repeat_img.gameObject:SetActive(true)
	else
		self.repeat_btn.gameObject:SetActive(true)
		self.repeat_img.gameObject:SetActive(false)
	end

	self.undo_btn = btns_node:Find("undo_btn"):GetComponent("Button")
	self.undo_btn.onClick:AddListener(function()
		if not self:CanSetBet() then
			LittleTips.Create("当前自动下注，无法取消")
			return
		end
		if not self:CheckTime(false) then return end

		self:send_reset_bet()
	end)

	local lastPower = PlayerPrefs.GetInt(self.local_power_key, 2)
	self.rateFactor = BET_POWER_TBL[lastPower].value

	self.power_anchor = btns_node:Find("power_anchor")
	self.power_txt = btns_node:Find("power_btn/power_txt"):GetComponent("Text")
	self.power_btn = btns_node:Find("power_btn"):GetComponent("Button")
	
	self.power_btn.onClick:AddListener(function()
		local list = {}
		for k, v in ipairs(BET_POWER_TBL) do
			table.insert(list, string.format("充能金额:%s", StringHelper.ToCash(v.value)))
		end
		FishingDRBetPopMenu.Create(self.power_anchor, "power", list)
	end)
	self.power_txt.text = string.format("充能金额:%s", StringHelper.ToCash(self.rateFactor))

	self.auto_anchor = btns_node:Find("auto_anchor")
	self.auto_txt = btns_node:Find("auto_btn/auto_txt"):GetComponent("Text")
	self.auto_btn = btns_node:Find("auto_btn"):GetComponent("Button")
	self.auto_btn.onClick:AddListener(function()
		--HintPanel.Create(1, "暂未开放")
		--if true then return end

		local list = {}
		for k, v in ipairs(BET_AUTO_TBL) do
			table.insert(list, string.format("自动购买:%d轮", v.value))
		end
		FishingDRBetPopMenu.Create(self.auto_anchor, "auto", list)
	end)
	self.auto_btn.gameObject:SetActive(false)
	self.auto_txt.text = "请选择挂机轮数"

	self.cancel_auto_txt = btns_node:Find("cancel_auto_btn/text_txt"):GetComponent("Text")
	self.cancel_auto_cnt = btns_node:Find("cancel_auto_btn/cnt_txt"):GetComponent("Text")
	self.cancel_auto_btn = btns_node:Find("cancel_auto_btn"):GetComponent("Button")
	self.cancel_auto_btn.onClick:AddListener(function()
		self:send_reset_auto_bet()
	end)
	self.cancel_auto_btn.gameObject:SetActive(false)

	self.reward_txt = btns_node:Find("reward_btn/text_txt"):GetComponent("Text")
	self.reward_cnt = btns_node:Find("reward_btn/cnt_txt"):GetComponent("Text")
	self.reward_btn = btns_node:Find("reward_btn"):GetComponent("Button")
	self.reward_btn.onClick:AddListener(function()
		self:send_receive_prize()
	end)
	self.reward_btn.gameObject:SetActive(false)

	self.bet_tmpl = transform:Find("Middle/bet_tmpl")
	self.bet_list_node = transform:Find("Middle/bet_list_node")

	self.cd_txt = transform:Find("Middle/cd_img/count_txt"):GetComponent("Text")
	self.PPAnimator = transform:Find("Middle/cd_img"):GetComponent("Animator")
	------------------------------------------------------------------------------------------

	self.rank1_tmpl = transform:Find("Right/style1/rank_tmpl")
	self.rank1_list_node = transform:Find("Right/style1/Scroll View/Viewport/rank_list_node")
	self.rank2_tmpl = transform:Find("Right/style2/rank_tmpl")
	self.rank2_list_node = transform:Find("Right/style2/Scroll View/Viewport/rank_list_node")

	self.rank1_scroll_rect = transform:Find("Right/style1/Scroll View"):GetComponent("ScrollRect")
	EventTriggerListener.Get(self.rank1_scroll_rect.gameObject).onEndDrag = basefunc.handler(self, self.OnEndDrag)
	self.rank2_scroll_rect = transform:Find("Right/style2/Scroll View"):GetComponent("ScrollRect")
	EventTriggerListener.Get(self.rank2_scroll_rect.gameObject).onEndDrag = basefunc.handler(self, self.OnEndDrag)
	self.rankPage = 1
	self.help_btn=transform:Find("Right/help_btn"):GetComponent("Button")
	self.help_btn.onClick:AddListener(function()
		FishingDRHelpPanel.Create()
	end)
	self.mode_btn = transform:Find("Right/mode_btn"):GetComponent("Button")
	self.mode_btn.onClick:AddListener(function()
		local showMode = (self.showMode + 1) % 2
		--self:SwitchMode(showMode)
		--self:RefreshRight()
	end)
	self.mode_btn.gameObject:SetActive(false)
	local lastMode = PlayerPrefs.GetInt(self.local_mood_key, 0)
	lastMode = 0
	self:SwitchMode(lastMode)

	for k, v in ipairs(BET_RATE_TBL) do
		local rate_idx = k
		local item = self:CreateItem(self.bet_list_node, self.bet_tmpl)
		local bg = item.transform:Find("bg")
		bg:GetComponent("Image").sprite = GetTexture(v.image)
		EventTriggerListener.Get(bg.gameObject).onClick = function()
			self:chooseBetBtn(k)

			if not self:CanSetBet() then
				LittleTips.Create("当前自动下注，无法手动购买")
				return
			end
			if not self:CheckTime(true) then return end
			if not self:CheckMoney(self.rateTable, rate_idx, self.rateFactor) then return end
			self:send_bet({id = rate_idx, bet = self.rateFactor})
		end

		self.rateList[rate_idx] = item
		self.rateTable[rate_idx] = 0
	end
	self:chooseBetBtn(-1)

	if FishingDRModel and FishingDRModel.data and FishingDRModel.data.game_data then
		MAX_CD_TIME = FishingDRModel.data.game_data.countdown_time or MAX_CD_TIME
	end
	self.cd_txt.text = MAX_CD_TIME
	self.cdCount = MAX_CD_TIME
	self.cdTimer = Timer.New(function()
		self.cdCount = self.cdCount - 1
		if IsEquals(self.cd_txt) then
			self.cd_txt.text = self.cdCount
			if self.cdCount >=5 then 
				self.PPAnimator:Play("by_bet_paopao")
			elseif self.cdCount >=0 then
				self.PPAnimator:Play("by_bet_paopao2")
			end 
		end
		if self.cdCount < 6 then
			ExtendSoundManager.PlaySound(audio_config.by_dr.sod_game_timeout_game_fishingdr.audio_name)
		end
		if self.cdCount == 0 then
			self:SaveLastRates()
			--FishingDRBetPanel.Close()
		end
	end, 1, MAX_CD_TIME)
	self.cdTimer:Start()

	--sync data
	local data = FishingDRModel.data
	if data then
		for k, v in ipairs(data.bet or {}) do
			self.fish_data[k] = v
			self.fish_ui_data[k] = v
		end

		if data.auto_bet_data and data.auto_bet_data.accomplish == 0 then
			dump(data.auto_bet_data, "auto_bet_data")

			for k, v in ipairs(data.auto_bet_data.bet or {}) do
				self.rateTable[k] = v
			end
		else
			for k, v in ipairs(data.my_bet or {}) do
				self.rateTable[k] = v
			end
		end
	end

	self:Refresh()

	self:send_histroy(self.rankPage, MAX_PAGE_ITEM)
end

function FishingDRBetPanel:MyExit()
	self:SaveLastRates()
	self:RemoveListener()
	for k, v in ipairs(self.scrollList) do
		v:Close()
	end
	self.scrollList = {}

	self:ClearItemList(self.fishList)
	self.fishList = {}

	self:ClearItemList(self.rateList)
	self.rateList = {}

	for _, v in ipairs(self.rankItemList) do
		self:ClearItemList(v)
	end
	self.rankItemList = {}

	self:ClearItemList(self.rankList)
	self.rankList = {}

	if self.cdTimer then
		self.cdTimer:Stop()
		self.cdTimer = nil
	end

	self.fish_tmpl = nil
	self.fish_list_node = nil
	self.pop_gold_tmpl = nil

	self.repeat_img = nil
	self.repeat_btn = nil
	self.undo_btn = nil
	self.power_anchor = nil
	self.power_txt = nil
	self.power_btn = nil
	self.auto_btn = nil

	self.bet_tmpl = nil
	self.bet_list_node = nil
	self.cd_txt = nil

	self.rank1_tmpl = nil
	self.rank1_list_node = nil
	self.rank2_tmpl = nil
	self.rank2_list_node = nil

	self.rank1_scroll_rect = nil
	self.rank2_scroll_rect = nil

	self.mode_btn = nil

	destroy(self.gameObject)
end
function FishingDRBetPanel:ClearAll()
	self:MyExit()
end

function FishingDRBetPanel:Refresh()
	if not IsEquals(self.transform) then return end

	self:RefreshLeft()
	self:RefreshMiddle()
	self:RefreshRight()
end


function FishingDRBetPanel:RefreshLeft()
	if not IsEquals(self.transform) then return end

	local data = self.fish_ui_data
	if #data <= 0 then return end

	for k, v in ipairs(self.fishList) do
		local money_txt = v.transform:Find("money/money_txt"):GetComponent("Text")
		money_txt.text = StringHelper.ToCash(data[k] or 0)
	end
end

function FishingDRBetPanel:RefreshMiddle()
	if not IsEquals(self.transform) then return end
	for k, v in ipairs(self.rateList) do
		local money = v.transform:Find("money"):GetComponent("Text")
		money.text = StringHelper.ToCash(self.rateTable[k])
	end

	self:RefreshGun()
	self:UpdateAutoBet()
end

function FishingDRBetPanel:RefreshGun()
	local gundata = FishingModel.data.gun
	if not gundata then return end
	for k, v in ipairs(self.rateTable) do
		if gundata[k] then
			if v > 0 then
				gundata[k].level = 2
			else
				gundata[k].level = 1
			end
		end

		local tran = GameObject.Find("FishingDR2DUI/GunNode/Node" .. k).transform
		local Gun = tran:Find("GunAnim/Gun"):GetComponent("SpriteRenderer")
		Gun.sprite = GetTexture(string.format("fkby_pt%d_icon_2",gundata[k].level))

		local GunDz = tran:Find("GunDz"):GetComponent("SpriteRenderer")
		GunDz.sprite = GetTexture(string.format("fkby_pt%d_icon_1",gundata[k].level))

	end
end

function FishingDRBetPanel:UpdateAutoBet()
	if not IsEquals(self.transform) or not IsEquals(self.gameObject) then return end
	if not IsEquals(self.cancel_auto_btn) or not IsEquals(self.reward_btn) or not IsEquals(self.auto_btn) then return end
	self.cancel_auto_btn.gameObject:SetActive(false)
	self.reward_btn.gameObject:SetActive(false)
	self.auto_btn.gameObject:SetActive(false)
	
	local autoBet = self:GetAutoBetData()

	if autoBet then
		if autoBet.accomplish == 0 then
			self.cancel_auto_btn.gameObject:SetActive(true)
			self.cancel_auto_txt.text = string.format("点击停止挂机(%d/%d)", autoBet.current_frequency or 0, autoBet.total_frequency or 0)
			self.cancel_auto_cnt.text = string.format("累积赢金:%s", StringHelper.ToCash(autoBet.reward or 0))
			return
		elseif autoBet.accomplish == 1 then
			self.reward_btn.gameObject:SetActive(true)
			self.reward_txt.text = "挂机结束，点击领取奖励"
			self.reward_cnt.text = string.format("累积赢金:%s", StringHelper.ToCash(autoBet.reward or 0))
			return
		end
	end

	self.auto_btn.gameObject:SetActive(true)
	self.auto_txt.text = "请选择挂机轮数"
end

--[[function FishingDRBetPanel:RefreshRight()
	if not IsEquals(self.transform) then return end

	--shrink data
	local data = self.rank_data
	local count = #data
	if count <= 0 then return end

	local tail_idx = data[count].idx
	local head_idx = math.max(1, tail_idx - MAX_TOTAL_ITEM)
	local ui_offset = tail_idx - head_idx
	local ui_count = ui_offset + 1

	local ui_data = {}
	for cursor = count, 1, -1 do
		local idx = data[cursor].idx
		local fishs = data[cursor].fishs
		if idx < head_idx then break end

		ui_data[idx - head_idx + 1] = {idx, 0, fishs}
	end

	for i = 1, ui_count do
		if not ui_data[i] then
			ui_data[i] = {head_idx - 1 + i, 0, {}}
		end
	end

	dump(ui_data, "ui_data")

	--fill data
	local offset = #self.rankList
	local rank_tmpl = nil
	local rank_list_node = nil
	
	if self.showMode == 0 then
		rank_tmpl = self.rank1_tmpl
		rank_list_node = self.rank1_list_node
	else
		rank_tmpl = self.rank2_tmpl
		rank_list_node = self.rank2_list_node
	end

	local item = nil
	for i = offset + 1, ui_count do
		item = self:CreateItem(rank_list_node, rank_tmpl)
		self.rankList[i] = item
	end

	--update ui element
	for i = 1, ui_count do
		self:UpdateRank(i, ui_data[i][3], ui_data[i][1] == self.newRank)
	end
end]]--

function FishingDRBetPanel:RefreshRight()
	if not IsEquals(self.transform) then return end

	--shrink data
	local data = self.rank_data
	local count = #data
	if count <= 0 then return end

	local ui_data = {}
	for cursor = count, 1, -1 do
		table.insert(ui_data, data[cursor] or {})

		if #ui_data > MAX_TOTAL_ITEM then break end
	end

	--fill data
	local offset = #self.rankList
	local rank_tmpl = nil
	local rank_list_node = nil
	
	if self.showMode == 0 then
		rank_tmpl = self.rank1_tmpl
		rank_list_node = self.rank1_list_node
	else
		rank_tmpl = self.rank2_tmpl
		rank_list_node = self.rank2_list_node
	end

	local item = nil
	for i = offset + 1, #ui_data do
		item = self:CreateItem(rank_list_node, rank_tmpl)
		self.rankList[i] = item
	end

	--update ui element
	for k, v in ipairs(ui_data) do
		self:UpdateRank(k, v.fishs, v.idx == self.newRank)
	end
end

function FishingDRBetPanel:UpdateRank(idx, fishs, showNew)
	local itemList = self.rankItemList[idx] or {}
	self:ClearItemList(itemList)
	self.rankItemList[idx] = {}
	self:FillRank(idx, fishs, showNew)
end

function FishingDRBetPanel:FillRank(idx, fishs, showNew)
	local item = self.rankList[idx]
	if not IsEquals(item) then return end

	local icon_tmpl = item.transform:Find("icon_tmpl")
	local icon_list_node = item.transform:Find("list_node")

	local itemList = self.rankItemList[idx] or {}

	if self.showMode == 0 then
		--line
		for i = 1, 7 do
			local item = self:CreateItem(icon_list_node, icon_tmpl)
			itemList[#itemList + 1] = item
			local icon_img = item.transform:Find("icon_img")
			local cnt_img = item.transform:Find("cnt_img"):GetComponent("Image")
			icon_img.gameObject:SetActive(false)
			cnt_img.gameObject:SetActive(false)
			for _, v in ipairs(fishs) do				
				if i == v[1] then
					icon_img.gameObject:SetActive(true)

					if v[2] >= 2 and v[2] <= 4 then
						cnt_img.sprite = GetTexture("bydr_game_imgf_bs" .. v[2])
						cnt_img.gameObject:SetActive(true)
					end

					break
				end
			end
		end
	else
		for _, v in ipairs(fishs) do
			local item = self:CreateItem(icon_list_node, icon_tmpl)
			itemList[#itemList + 1] = item
			local icon_img = item.transform:Find("icon_img")
			local icon = icon_img:GetComponent("Image")
			icon.sprite = GetTexture(BET_RATE_TBL[v[1]].thumb)
			icon_img.gameObject:SetActive(true)
		end
	end

	self.rankItemList[idx] = itemList

	local new_img = item.transform:Find("new_img")
	new_img.gameObject:SetActive(showNew)

	if showNew then
		if self.lastRank ~= self.newRank then
			if self.lastRank > 0 and self.lastRank < #self.rankList then
				local item = self.rankList[self.lastRank]
				new_img = item.transform:Find("new_img")
				new_img.gameObject:SetActive(false)
			end
			self.lastRank = self.newRank
		end
	end

	item.transform:SetAsLastSibling()
end

function FishingDRBetPanel:SwitchMode(newMode)
	if self.showMode == newMode then return end
	self.showMode = newMode
	PlayerPrefs.SetInt(self.local_mood_key, newMode)

	for _, v in ipairs(self.rankItemList) do
		self:ClearItemList(v)
	end
	self.rankItemList = {}

	self:ClearItemList(self.rankList)
	self.rankList = {}

	local transform = self.transform
	local style1 = transform:Find("Right/style1")
	local style2 = transform:Find("Right/style2")

	local rank_tmpl = nil
	local rank_list_node = nil

	if newMode == 0 then
		style1.gameObject:SetActive(true)
		style2.gameObject:SetActive(false)
		rank_tmpl = self.rank1_tmpl
		rank_list_node = self.rank1_list_node
	else
		style1.gameObject:SetActive(false)
		style2.gameObject:SetActive(true)
		rank_tmpl = self.rank2_tmpl
		rank_list_node = self.rank2_list_node
	end
	self.rank1_scroll_rect.verticalNormalizedPosition = 0
	self.rank2_scroll_rect.verticalNormalizedPosition = 0

	local item = nil
	for i = 1, MAX_PAGE_ITEM do
		item = self:CreateItem(rank_list_node, rank_tmpl)
		self.rankList[i] = item
	end
end

function FishingDRBetPanel:HandleScrollEndDrag(scroll_rect)
	local page = self.rankPage or 0
	if page <= 0 then return end

	if scroll_rect.verticalNormalizedPosition <= 0 then
		page = math.max(1, math.ceil(#self.rankList / MAX_PAGE_ITEM + 0.5))
		if self.rankPage ~= page then
			--self:send_histroy(page, MAX_PAGE_ITEM)
		end
	end
end

function FishingDRBetPanel:OnEndDrag()
	if self.showMode == 0 then
		self:HandleScrollEndDrag(self.rank1_scroll_rect)
	else
		self:HandleScrollEndDrag(self.rank2_scroll_rect)
	end
end

function FishingDRBetPanel:CreateItem(parent, tmpl)
	if not IsEquals(tmpl) or not IsEquals(parent) then return end
	local obj = GameObject.Instantiate(tmpl, parent)

	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one
	obj.transform:SetAsLastSibling()

	obj.gameObject:SetActive(true)

	return obj
end

function FishingDRBetPanel:ClearItemList(list)
	for k, v in ipairs(list) do
		destroy(v.gameObject)
	end
end

function FishingDRBetPanel:OnExitScene()
	FishingDRBetPanel.Close()
end

function FishingDRBetPanel:CheckMoney(rateTable, rate_idx, rateFactor)
	--check upper
	local total = 0
	for k, v in ipairs(rateTable) do
		total = total + v
	end
	total = total + rateFactor

	if total > MAX_BET_LIMIT then
		HintPanel.Create(1, "当前购买已经达到上限")
		return false
	end

	local jing_bi = MainModel.UserInfo.jing_bi
	--check money
	if rateFactor > 0 then
		total = rateFactor
	end
	if jing_bi < total then
		HintPanel.Create(1, "鲸币不足，请先充值", function()
			Event.Brocast("show_gift_panel")
		end)
		return false
	end

	return true
end

function FishingDRBetPanel:CheckTime(showTip)
	if self.cdCount <= 0 then
		if showTip then
			LittleTips.Create("当前时间无法购买")
		end
		return false
	end

	return true
end

function FishingDRBetPanel:LoadLastRates()
	self.lastRates = {}	
	local str = PlayerPrefs.GetString(self.local_bet_key, "")
	if str == "" then
		self.lastRates = FishingDRModel.lastRates
		self:CheckLastRates()
		return
	end
	local bets = basefunc.string.split(str, "#")
	if #bets ~= #BET_RATE_TBL then
		PlayerPrefs.DeleteKey(self.local_bet_key)
		return
	end
	for k, v in ipairs(bets) do
		self.lastRates[k] = tonumber(v)
	end
	dump(self.lastRates,"<color=white> Get lasttttt1111111111tttttttttttttt</color>")
	self:CheckLastRates()
end

function FishingDRBetPanel:SaveLastRates()
	local total = 0
	self.lastRates = {}
	for k, v in ipairs(self.rateTable) do
		self.lastRates[k] = v
		total = total + v
	end

	local str = self.rateTable[1]
	for i = 2, #self.rateTable do
		str = str .. "#" .. self.rateTable[i]
	end
	PlayerPrefs.SetString(self.local_bet_key, str)
	FishingDRModel.lastRates = self.rateTable
end

function FishingDRBetPanel:CheckLastRates()
	if not self.lastRates then return end
	local total = 0
	for k, v in ipairs(self.lastRates) do
		total = total + v
	end
	if total <= 0 then
		self.lastRates = {}
	end
end

function FishingDRBetPanel:FishPopMoney(idx, value)
	if not self.fishList then return end
	local item = self.fishList[idx]
	if not IsEquals(item) then return end
	local anchor = item.transform:Find("anchor")

	local pop_gold = GameObject.Instantiate(self.pop_gold_tmpl, anchor)
	pop_gold.transform.localPosition = Vector3.zero
	local gold_bg = pop_gold.transform:Find("gold_bg")
	local gold_txt = pop_gold.transform:Find("gold_bg/gold_txt"):GetComponent("Text")
	gold_txt.text = "+" .. StringHelper.ToCash(value)

	local offH = 60
	FishingDRBetPanel.TweenLocalMove(gold_bg, offH, false, 1, function()
		if IsEquals(gold_bg) then
			gold_bg.localPosition = Vector3.New(0, offH, 0)
		end
		destroy(pop_gold)
	end, "y", 0)

	self.fish_ui_data[idx] = (self.fish_ui_data[idx] or 0) + value
	self:RefreshLeft()
end

function FishingDRBetPanel:PushFishBet(idx, delta)
	if delta <= 0 then return end

	local splitCnt = 2
	local mod = delta % 1000
	delta = delta - mod

	if delta <= 1000 then
		delta = delta + mod
		self:FishPopMoney(idx, delta)
	else
		local div = delta / splitCnt

		local callbacks = {}
		for i = 1, 2 do
			callbacks[i] = {
				stamp = 0.3,
				method = function()
					self:FishPopMoney(idx, div)
				end
			}
		end

		if mod > 0 then
			callbacks[#callbacks + 1] = {
				stamp = 0.3,
				method = function()
					self:FishPopMoney(idx, mod)
				end
			}
		end

		FishingDRBetPanel.TweenDelay(callbacks, function()
		end)
	end


	--print("pushfishbet:", idx, delta)

	--[[local scroll = self.scrollList[idx]
	if not IsEquals(scroll) then return end

	local mod = delta % 1000
	delta = delta - mod

	if delta > 1000 then
		local div = (delta - mod) / 2
		for idx = 1, 2 do
			scroll:Push(div)
		end
	else
		scroll:Push(delta)
	end

	if mod > 0 then
		scroll:Push(mod)
	end]]--
end

function FishingDRBetPanel:GetAutoBetData()
	local data = FishingDRModel.data
	if not data then return nil end
	return data.auto_bet_data
end

function FishingDRBetPanel:CanSetBet()
	local autoBet = self:GetAutoBetData()
	if autoBet then
		if autoBet.accomplish == 0 or autoBet.accomplish == 1 then
			return false
		end
	end

	return true
end

function FishingDRBetPanel:send_bet(data)
	ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_xiaopiaojinbi.audio_name)
	local bet_data = {}
	table.insert(bet_data, data)
	Network.SendRequest("fishing_dr_bet", {bet_data = bet_data}, "正在购买")

	--test
	--self:handle_bet(_, {result = 0, id = data.id, bet = data.bet})
end

function FishingDRBetPanel:handle_bet(_, msg)
	dump(msg, "FishingDRBetPanel:handle_bet")

	if msg.result == 0 then
		local rate_idx = msg.id
		local delta = msg.bet or 0
		self.rateTable[rate_idx] = self.rateTable[rate_idx] or 0
		self.rateTable[rate_idx] = self.rateTable[rate_idx] + delta
		self:RefreshMiddle()
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

function FishingDRBetPanel:send_again_bet(data)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	Network.SendRequest("fishing_dr_again_bet", {bet_data = data}, "正在购买")

	--test
	--self:handle_again_bet(_, {result = 0})
end

function FishingDRBetPanel:handle_again_bet(_, msg)
	dump(msg, "FishingDRBetPanel:handle_again_bet")

	if msg.result == 0 then
		for k, v in ipairs(self.lastRates) do
			self.rateTable[k] = v
		end
		self:RefreshMiddle()
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

function FishingDRBetPanel:send_reset_bet()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	Network.SendRequest("fishing_dr_reset_bet", nil, "正在重置")

	--test
	--self:handle_reset_bet(_, {result = 0})
end

function FishingDRBetPanel:handle_reset_bet(_, msg)
	dump(msg, "FishingDRBetPanel:handle_reset_bet")

	if msg.result == 0 then
		for k, v in ipairs(self.rateTable) do
			self.rateTable[k] = 0
		end
		self:RefreshMiddle()
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

function FishingDRBetPanel:send_histroy(page, max_page_item)
	Network.SendRequest("fishing_dr_histroy")

	--test
	--[[local msg = {
		result = 0,
		history_data = {
			[1] = {
				periods = 1,
				fish = {
					[1] = {id = 1, count = 1},
					[2] = {id = 2, count = 2},
					[3] = {id = 3, count = 3}
				}
			},
			[2] = {
				periods = 2,
				fish = {
					[1] = {id = 4, count = 1},
					[2] = {id = 5, count = 2},
					[3] = {id = 6, count = 3}
				}
			},
			[3] = {
				periods = 62,
				fish = {
					[1] = {id = 7, count = 1},
					[2] = {id = 1, count = 2},
					[3] = {id = 2, count = 3}
				}
			}
		}
	}
	self:handle_histroy(_, msg)]]--

	--[[msg = {
		result = 0,
		history_data = {
			[1] = {
				periods = 8,
				fish = {
					[1] = {id = 3, count = 1},
					[2] = {id = 4, count = 2},
					[3] = {id = 5, count = 3}
				}
			},
			[2] = {
				periods = 30,
				fish = {
					[1] = {id = 4, count = 1},
					[2] = {id = 5, count = 2},
					[3] = {id = 6, count = 3}
				}
			},
			[3] = {
				periods = 50,
				fish = {
					[1] = {id = 7, count = 1},
					[2] = {id = 1, count = 2},
					[3] = {id = 2, count = 3}
				}
			}
		}
	}

	self:handle_add_histroy(_, msg)]]--
end

function FishingDRBetPanel:handle_histroy(_, msg)
	--dump(msg, "FishingDRBetPanel:handle_histroy")

	if msg.result == 0 then
		local history_data = msg.history_data

		self.rank_data = {}
		for k, v in ipairs(history_data) do
			local list = {}
			for _, fish in ipairs(v.fish or {}) do
				table.insert(list, {fish.id, fish.count})
			end
			self.newRank = math.max(self.newRank, v.periods)

			table.insert(self.rank_data, {idx = v.periods, fishs = list})
		end
		self:RefreshRight()
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

function FishingDRBetPanel:handle_add_histroy(_, msg)
	local history_data = msg.history_data or {}

	for k, v in ipairs(history_data) do
		local list = {}
		for _, fish in ipairs(v.fish or {}) do
			table.insert(list, {fish.id, fish.count})
		end
		self.newRank = math.max(self.newRank, v.periods)

		table.insert(self.rank_data, {idx = v.periods, fishs = list})
	end
	self:RefreshRight()
end

function FishingDRBetPanel:send_auto_bet(times)
	Network.SendRequest("fishing_dr_auto_bet", {frequency = times})
end

function FishingDRBetPanel:handle_auto_bet(data)
	dump(data, "FishingDRBetPanel:handle_auto_bet")

	self:RefreshMiddle()
end

function FishingDRBetPanel:send_reset_auto_bet()
	Network.SendRequest("fishing_dr_reset_auto_bet")
end

function FishingDRBetPanel:handle_reset_auto_bet(data)
	dump(data, "FishingDRBetPanel:handle_reset_auto_bet")

	for k, v in ipairs(self.rateTable) do
		self.rateTable[k] = 0
	end

	self:RefreshMiddle()
end

function FishingDRBetPanel:send_receive_prize()
	Network.SendRequest("fishing_dr_receive_prize")
end

function FishingDRBetPanel:handle_receive_prize(data)
	dump(data, "FishingDRBetPanel:handle_receive_prize")

	for k, v in ipairs(self.rateTable) do
		self.rateTable[k] = 0
	end

	self:RefreshMiddle()
end

function FishingDRBetPanel:handle_all_bet(_, msg)
	--dump(msg, "FishingDRBetPanel:handle_all_bet")

	self.fish_data = {}
	for k, v in ipairs(msg.game_bet) do
		self.fish_data[k] = v
	end
	--self:RefreshLeft()

	local ui_data = self.fish_ui_data or {}
	local raw_data = self.fish_data or {}
	for k, v in ipairs(raw_data) do
		local delta = v - (ui_data[k] or 0)
		self:PushFishBet(k, delta)
	end
end

function FishingDRBetPanel:handle_bet_pop_menu_click(data)
	if not data then return end
	if not IsEquals(self.power_txt) then return end

	local key = data[1] or ""
	local idx = data[2] or 0

	if key == "power" then
		local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishingdr_".. idx,vip_hint_type = 2, cw_btn_desc = "确定"}, "CheckCondition")
        if a and not b then
            return
        end
		self.rateFactor = BET_POWER_TBL[idx].value
		self.power_txt.text = string.format("充能金额:%s", StringHelper.ToCash(self.rateFactor))

		PlayerPrefs.SetInt(self.local_power_key, idx)
	elseif key == "auto" then
		--self.auto_txt.text = string.format("自动购买:%d轮", self.autoFactor)

		self:send_auto_bet(BET_AUTO_TBL[idx].value)
	end
end

function FishingDRBetPanel:SendRanking(page, max_page_item)
	local offset = (page - 1) * max_page_item
	--[[local data = {
		[1] = {idx = offset + 1, fish = {1,2,3,4,5,6,7}},
		[2] = {idx = offset + 2, fish = {4,5}},
		[3] = {idx = offset + 3, fish = {1,3,5,7}},
		[4] = {idx = offset + 4, fish = {1}},
		[5] = {idx = offset + 6, fish = {2,3,5,6}},
		[6] = {idx = offset + 7, fish = {4,5,7}},
		[7] = {idx = offset + 8, fish = {2,4,5}}
	}]]--
	--[[local data = {
		[1] = {idx = offset + 1, fish = {2,3,5,7}},
		[2] = {idx = offset + 2, fish = {4,5}},
		[3] = {idx = offset + 3, fish = {1,3,6,7}},
		[4] = {idx = offset + 4, fish = {1}},
		[5] = {idx = offset + 6, fish = {2,3,5,6}},
		[6] = {idx = offset + 7, fish = {4,5,7}},
		[7] = {idx = offset + 8, fish = {2,4,5}}
	}]]--

	self.rank_data = self.rank_data or {}
	for k, v in ipairs(data) do
		table.insert(self.rank_data, v)
	end
	self.rankPage = page
	self:RefreshRight()
end

function FishingDRBetPanel:chooseBetBtn(idx)
	for k, v in ipairs(self.rateList) do
		v.transform:Find("choose_bg").gameObject:SetActive(k == idx)
		v.transform:Find("choose_arr").gameObject:SetActive(k == idx)
	end
end

function FishingDRBetPanel.TweenLocalMove(tran, offset, inverse, period, callback, axis, delay)
	if not IsEquals(tran) then return end

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)

		if IsEquals(tran) then
			tran.localPosition = Vector3.zero
		end

		if callback then callback() end
	end)

	axis = axis or "x"
	if axis == "x" then
		if inverse then
			seq:Append(tran:DOLocalMoveX(offset, period):From())
		else
			seq:Append(tran:DOLocalMoveX(offset, period))
		end
	elseif axis == "y" then
		if inverse then
			seq:Append(tran:DOLocalMoveY(offset, period):From())
		else
			seq:Append(tran:DOLocalMoveY(offset, period))
		end
	else
		print("[SGE] TweenLocalMove axis is invalid:" .. axis)
	end

	delay = delay or 0
	if delay > 0 then
		seq:AppendInterval(delay):AppendCallback(function()
			--delay
		end)
	end
end

function FishingDRBetPanel.TweenDelay(callbacks, finally_callback)
	local traceTbl = {}

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey)

		for k, v in ipairs(traceTbl) do
			if not v then
				if callbacks[k].method then callbacks[k].method() end
			end
		end

		if finally_callback then finally_callback() end
	end)

	for k, v in ipairs(callbacks) do
		traceTbl[k] = false
		seq:AppendInterval(v.stamp):AppendCallback(function()
			traceTbl[k] = true
			if v.method then v.method() end
		end)
	end

	return tweenKey
end
