local basefunc = require "Game.Common.basefunc"

package.loaded["Game.CommonPrefab.Lua.golden_egg_big_award_config"] = nil
BigAwardConfig = require "Game.CommonPrefab.Lua.golden_egg_big_award_config"

local task_data = nil

local TASK_ID = 100
local TASK_TABLE = {
	[1] = {
		money = 180000, icon = "matchpop_icon_1", award = "0.8福卡", progress = 99,
	},
	[2] = {
		money = 580000, icon = "matchpop_icon_1", award = "1.8福卡", progress = 361,
	},
	[3] = {
		money = 1880000, icon = "matchpop_icon_1", award = "2.8福卡", progress = 623,
	},
	[4] = {
		money = 4880000, icon = "matchpop_icon_1", award = "4.8福卡", progress = 885,
	},
	[5] = {
		money = 18880000, icon = "matchpop_icon_1", award = "18福卡", progress = 1147,
	},
	[6] = {
		money = 88880000, icon = "gy_15_25", award = "天猫精灵", progress = 1409,
	},
	[7] = {
		money = 380000000, icon = "gy_15_26", award = "zippo打火机", progress = 1671,
	}
}

local function AdaptTaskTable(money)
	for k, v in pairs(BigAwardConfig.stage) do
		if money > v.money then
			return k
		end
	end

	return 0
end

local PROGRESS_WIDTH = 1680
local PROGRESS_HEIGHT = 32

ShatterGoldenEvent = basefunc.class()
ShatterGoldenEvent.name = "ShatterGoldenEvent"

local instance = nil

local lister = {}
function ShatterGoldenEvent:MakeLister()
	lister = {}

	lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
	lister["model_task_change_msg"] = basefunc.handler(self, self.handle_task_change)

	lister["view_sge_close"] = basefunc.handler(self, self.handle_sge_close)
	lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function ShatterGoldenEvent.Create(parent)
	if not instance then
		instance = ShatterGoldenEvent.New(parent)
	end
	return instance
end

function ShatterGoldenEvent:ctor(parent)
	local obj = newObject(ShatterGoldenEvent.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	ShatterGoldenEggLogic.setViewMsgRegister(lister, ShatterGoldenEvent.name)

	self.ItemList = {}

	self:InitRect()
	self:HideBigReward()

	EventTriggerListener.Get(self.CloseShow_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseBigReward)
	EventTriggerListener.Get(self.CloseGet_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseBigReward)
	EventTriggerListener.Get(self.copy_wx_btn.gameObject).onClick = basefunc.handler(self, self.CopyWxCode)

	Network.SendRequest("query_one_task_data", {task_id = TASK_ID})
end

function ShatterGoldenEvent.Close()
	if instance then
		ShatterGoldenEggLogic.clearViewMsgRegister(ShatterGoldenEvent.name)
		instance:ClearAll()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function ShatterGoldenEvent.IsShow()
	if not instance then return false end
	return instance.transform.gameObject.activeSelf
end

function ShatterGoldenEvent:InitRect()
	local transform = self.transform

	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		ShatterGoldenEvent.Close()
	end)

	self.rule_btn.onClick:AddListener(function()
		IllustratePanel.Create({self.introduce_txt}, transform)
	end)

	self.progress_mask_rect = self.progress_mask:GetComponent("RectTransform")
	self.progress_mask_rect.sizeDelta = {x = 0, y = PROGRESS_HEIGHT}
	for k, v in ipairs(BigAwardConfig.stage) do
		local item = self:CreateItem(self.item_node, self.item_tmpl)

		local item_title = item.transform:Find("title"):GetComponent("Text")
		item_title.text = StringHelper.ToCash(v.money)

		local item_slider = item.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_15_8")

		local item_bg = item.transform:Find("bg"):GetComponent("Image")
		item_bg.sprite = GetTexture(v.icon)

		local item_award = item.transform:Find("bg/award"):GetComponent("Text")
		item_award.text = v.award

		local item_mask = item.transform:Find("bg/mask"):GetComponent("Image")
		item_mask.gameObject:SetActive(false)

		local item_getmask = item.transform:Find("bg/getmask")
		item_getmask.gameObject:SetActive(false)

		--local item_focus = item.transform:Find("bg/getmask/focus"):GetComponent("Image")
		--item_focus.gameObject:SetActive(false)

		local touch = item.transform:Find("bg/touch"):GetComponent("Image")
		PointerEventListener.Get(touch.gameObject).onClick = function()
			--print("touch....................")
			if self:CanShowAwards(k) then
				local item = self.ItemList[k]
				if not IsEquals(item) then return end

				local item_getmask = item.transform:Find("bg/getmask")
				if item_getmask.gameObject.activeSelf then
					self:ShowBigReward(k, true)
				else
					self:ShowBigReward(k, false)
				end
			end
		end

		local item_btn = item.transform:Find("bg/getmask/go_btn"):GetComponent("Button")
		item_btn.onClick:AddListener(function ()
			if not self:CanShowAwards(k) then
				Network.SendRequest("get_task_award", {id = TASK_ID})
			else
				self:ShowBigReward(k, true)
			end
		end)
		ClipUIParticle(item.transform)
		--item_btn.gameObject:SetActive(false)

		self.ItemList[#self.ItemList + 1] = item
	end
end

function ShatterGoldenEvent:Refresh()
	local transform = self.transform
	if not IsEquals(transform) then return end

	self:RefreshItems()
end

function ShatterGoldenEvent:ClearItemList(list)
	for i,v in pairs(list) do
		if IsEquals(v) then
			GameObject.Destroy(v.gameObject)
		end
	end
end

function ShatterGoldenEvent:ClearAll()
	if IsEquals(self.transform) then
		self.transform:SetParent(nil)
	end
	self:ClearItemList(self.ItemList)
	self.ItemList = {}
end

function ShatterGoldenEvent:CreateItem(parent, tmpl)
	local obj = GameObject.Instantiate(tmpl)
	obj.transform:SetParent(parent)
	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one

	obj.gameObject:SetActive(true)

	return obj
end

function ShatterGoldenEvent:handle_sge_close()
	ShatterGoldenEvent.Close()
end

function ShatterGoldenEvent:OnExitScene()
	ShatterGoldenEvent.Close()
end

function ShatterGoldenEvent:RefreshItems()
	if not task_data then
		print("[SGE] Event task_data invalid")
		return
	end

	local MAX_LEVEL = #BigAwardConfig.stage

	for k, v in ipairs(self.ItemList) do
		local item_mask = v.transform:Find("bg/mask"):GetComponent("Image")
		item_mask.gameObject:SetActive(false)

		local item_slider = v.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_15_8")

		local item_getmask = v.transform:Find("bg/getmask")
		item_getmask.gameObject:SetActive(false)
	end

	--progress dot
	local level = task_data.now_lv - 1	--AdaptTaskTable(task_data.now_total_process)
	for idx = 1, level do
		local item = self.ItemList[idx]
		local item_slider = item.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_15_10")
	end

	local full_process = false
	if task_data.now_lv >= MAX_LEVEL then
		if task_data.now_process == task_data.need_process then
			local item = self.ItemList[MAX_LEVEL]
			local item_slider = item.transform:Find("slider"):GetComponent("Image")
			item_slider.sprite = GetTexture("gy_15_10")
			full_process = true
		end
	end

	--get or wait get
	for idx = 1, task_data.task_round - 1 do
		local item = self.ItemList[idx]
		local item_mask = item.transform:Find("bg/mask"):GetComponent("Image")
		item_mask.gameObject:SetActive(true)
	end

	if task_data.award_status == 1 then
		local item = self.ItemList[task_data.task_round]
		local item_getmask = item.transform:Find("bg/getmask")
		item_getmask.gameObject:SetActive(true)

		--hardcode
		if level >= (MAX_LEVEL - 1) then
			item = self.ItemList[MAX_LEVEL - 1]
			item_getmask = item.transform:Find("bg/getmask")
			item_getmask.gameObject:SetActive(true)

			if full_process then
				item = self.ItemList[MAX_LEVEL]
				item_getmask = item.transform:Find("bg/getmask")
				item_getmask.gameObject:SetActive(true)
			end
		end
	end

	--progress
	local progress_value = 0
	local factor = Mathf.Clamp(task_data.now_process / task_data.need_process, 0, 1)
	if level == 0 then
		progress_value = BigAwardConfig.stage[1].progress * factor
	elseif level >= MAX_LEVEL then
		progress_value = BigAwardConfig.stage[MAX_LEVEL].progress
	else
		progress_value = BigAwardConfig.stage[level].progress + (BigAwardConfig.stage[level + 1].progress - BigAwardConfig.stage[level].progress) * factor
	end

	self.progress_mask_rect.sizeDelta = {x = progress_value, y = PROGRESS_HEIGHT}
	self.current_money_txt.text = StringHelper.ToCash(task_data.now_total_process)
	self.next_money_txt.text = StringHelper.ToCash(task_data.need_process - task_data.now_process)
end

function ShatterGoldenEvent.handle_one_task_data_response(_, data)
	dump(data, "ShatterGoldenEvent.handle_one_task_data_response")
	task_data = data

	--[[task_data.now_process = 120000
	task_data.need_process = 120000
	task_data.now_lv = 6
	task_data.award_status = 1
	task_data.task_round = 4]]--

	if instance then
		instance:Refresh()
	end
end

function ShatterGoldenEvent.handle_task_change(_, data)
	dump(data, "ShatterGoldenEvent.handle_task_change")
	task_data = data
	if instance then
		instance:Refresh()
	end
end

--2019年4月4日 9:00~4月10日23:59
local TASK_BEGIN_TIME = 1554339600
local TASK_END_TIME = 1554911999
local TASK_OVER_TIME = 1555084799

--test
--[[TASK_BEGIN_TIME = 1552548300
TASK_END_TIME = TASK_BEGIN_TIME + 30
TASK_OVER_TIME = TASK_END_TIME + 30]]--


function ShatterGoldenEvent.CheckActive()
	--if true then return 1 end

	local stamp = os.time()
	if stamp < TASK_BEGIN_TIME then return 0 end
	if stamp < TASK_END_TIME then return 1 end
	if stamp < TASK_OVER_TIME then return 2 end
	return -1
end

function ShatterGoldenEvent:CanShowAwards(id)
	local ret = false
	for _, d in ipairs(BigAwardConfig.config) do
		if d.award_id == id then
			ret = true
			break
		end
	end
	return ret
end

function ShatterGoldenEvent:InitBigReward(id, isGet)
	if not self.awardsList then
		self.awardsList = {}
	end

	for _, d in ipairs(BigAwardConfig.config) do
		if d.award_id == id then
			self.icon_img.sprite = GetTexture(d.icon)
			self.icon_img:SetNativeSize()
			self.desc_txt.text = d.desc or ""
			
			local container = (isGet and self.GetList.transform or self.ShowList.transform)
			local reward = GameObject.Instantiate(self.Reward_tmpl, container)
			local btn = reward.transform:Find("showtip_btn")
			reward.gameObject:SetActive(true)
			self.awardsList[#self.awardsList + 1] = reward

			PointerEventListener.Get(btn.gameObject).onDown = function ()
				GameTipsPrefab.ShowDesc(d.tip, UnityEngine.Input.mousePosition)
				if GameTipsPrefab.instance then
					GameTipsPrefab.instance.transform.parent = self.transform.parent
				end
			end
			PointerEventListener.Get(btn.gameObject).onUp = function ()
				GameTipsPrefab.Hide()
			end
		end
	end
end

function ShatterGoldenEvent:OnCloseBigReward()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:HideBigReward()
end

function ShatterGoldenEvent:HideBigReward()
	self.ShowReward.gameObject:SetActive(false)
	self.GetReward.gameObject:SetActive(false)
	
	if self.awardsList then
		for _, o in ipairs(self.awardsList) do
			GameObject.Destroy(o.gameObject)
		end
		self.awardsList = nil
	end
end

function ShatterGoldenEvent:ShowBigReward(id, isGet)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:InitBigReward(id, isGet)
	self.ShowReward.gameObject:SetActive(not isGet)
	self.GetReward.gameObject:SetActive(isGet)
end

function ShatterGoldenEvent:CopyWxCode()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    LittleTips.Create("已复制QQ号请前往QQ进行添加")
    UniClipboard.SetText("4008882620")
end
