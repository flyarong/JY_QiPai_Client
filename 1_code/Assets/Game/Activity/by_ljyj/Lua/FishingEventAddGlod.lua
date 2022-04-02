local basefunc = require "Game.Common.basefunc"
FishingEventAddGlod = basefunc.class()
local M = FishingEventAddGlod
M.name = "FishingEventAddGlod"

local task_data = nil
local award_config = nil

local PROGRESS_WIDTH = 1680
local PROGRESS_HEIGHT = 32

local instance = nil

local lister = {}

function M:AddMsgListener()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end
function M:MakeLister()
	lister = {}

	lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
	lister["model_task_change_msg"] = basefunc.handler(self, self.handle_task_change)

	lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function M:RemoveListener()
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function M.Create(parent)
	if not instance then
		instance = M.New(parent)
	end
	return instance
end

function M:ctor(parent)
	self.task_id = BYLJYJManager.GetTask()
	self.config = BYLJYJManager.GetConfig()
	award_config = M.InitAwardConfig(self.config.award)
	if not parent then parent = GameObject.Find("Canvas/LayerLv4").transform end
	local obj = newObject(M.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()
	self.ItemList = {}
	self.hint_close_btn.onClick:AddListener(function(  )
		self.hint.gameObject:SetActive(false)
	end)
	self:InitRect()
	Network.SendRequest("query_one_task_data", {task_id = self.task_id})
end

function M.Close()
	if instance then
		instance:RemoveListener()
		instance:ClearAll()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function M.InitAwardConfig(cfg)
	local _cfg = {}
	for i,v in ipairs(cfg) do
		_cfg[v.level_id] = _cfg[v.level_id] or {}
		table.insert(_cfg[v.level_id],v)
	end
	return _cfg
end

function M.IsShow()
	if not instance then return false end
	return instance.transform.gameObject.activeSelf
end

function M:InitRect()
	local transform = self.transform

	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		M.Close()
	end)

	self.rule_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self.hint.gameObject:SetActive(not self.hint.gameObject.activeSelf)
	end)

	self.progress_mask_rect = self.progress_mask:GetComponent("RectTransform")
	self.progress_mask_rect.sizeDelta = {x = 0, y = PROGRESS_HEIGHT}
	for k, v in ipairs(self.config.stage) do
		local item = self:CreateItem(self.item_node, self.item_tmpl)

		local item_title = item.transform:Find("title"):GetComponent("Text")
		item_title.text = StringHelper.ToCash(v.money)

		local item_slider = item.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_20_5_activity_by_ljyj")

		local item_bg = item.transform:Find("icon"):GetComponent("Image")
		item_bg.sprite = GetTexture(v.icon)

		local item_award = item.transform:Find("icon/award"):GetComponent("Text")
		item_award.text = v.desc
		self:SetIconMask(item,1)
		local item_getmask = item.transform:Find("getmask")
		item_getmask.gameObject:SetActive(false)

		local touch = item.transform:Find("icon/touch"):GetComponent("Image")

		PointerEventListener.Get(touch.gameObject).onDown = function(  )
			local pos = UnityEngine.Input.mousePosition
    		GameTipsPrefab.ShowDesc(v.tips, pos)
		end
    	PointerEventListener.Get(touch.gameObject).onUp = function(  )
			GameTipsPrefab.Hide()
		end

		local item_btn = item.transform:Find("getmask/go_btn"):GetComponent("Button")
		item_btn.onClick:AddListener(function ()
			local data = {}
			data.cur_award_status = task_data.award_status_all[v.level]
			data.now_level = v.level
			data.task_id = self.task_id
			WheelSurfPanel.Create(data,award_config[v.level])
		end)
		ClipUIParticle(item.transform)
		--item_btn.gameObject:SetActive(false)

		self.ItemList[#self.ItemList + 1] = item
	end
end

function M:Refresh()
	local transform = self.transform
	if not IsEquals(transform) then return end

	self:RefreshItems()
end

function M:ClearItemList(list)
	for i,v in pairs(list) do
		if IsEquals(v) then
			GameObject.Destroy(v.gameObject)
		end
	end
end

function M:ClearAll()
	if IsEquals(self.transform) then
		self.transform:SetParent(nil)
	end
	self:ClearItemList(self.ItemList)
	self.ItemList = {}
	award_config = {}
end

function M:CreateItem(parent, tmpl)
	local obj = GameObject.Instantiate(tmpl)
	obj.transform:SetParent(parent)
	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one

	obj.gameObject:SetActive(true)

	return obj
end

function M:OnExitScene()
	M.Close()
end

function M:RefreshItems()
	if not task_data then
		print("[SGE] Event task_data invalid")
		return
	end

	local MAX_LEVEL = #self.config.stage

	for k, v in ipairs(self.ItemList) do
		self:SetIconMask(v.transform,1)

		local item_slider = v.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_20_5_activity_by_ljyj")

		local item_getmask = v.transform:Find("getmask")
		item_getmask.gameObject:SetActive(false)

		if task_data.award_status_all[k] == 2 then
			local item = self.ItemList[k]
			local getedmask = item.transform:Find("getedmask")
			getedmask.gameObject:SetActive(true)
		end
	end

	--progress dot
	local level = task_data.now_lv - 1	--AdaptTaskTable(task_data.now_total_process)
	for idx = 1, level do
		local item = self.ItemList[idx]
		local item_slider = item.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_20_7_activity_by_ljyj")
	end

	local full_process = false
	if task_data.now_lv >= MAX_LEVEL then
		if task_data.now_process == task_data.need_process then
			local item = self.ItemList[MAX_LEVEL]
			local item_slider = item.transform:Find("slider"):GetComponent("Image")
			item_slider.sprite = GetTexture("gy_20_7_activity_by_ljyj")
			full_process = true
		end
	end

	dump(task_data.award_status_all, "<color=yellow>task_data.award_status_all</color>")
	for i,v in ipairs(task_data.award_status_all) do
		if v == 0 then
			local item = self.ItemList[i]
			local item_getmask = item.transform:Find("getmask")
			item_getmask.gameObject:SetActive(false)
			self:SetIconMask(item,1)
		elseif v == 1 then
			local item = self.ItemList[i]
			local item_getmask = item.transform:Find("getmask")
			item_getmask.gameObject:SetActive(true)
		elseif v == 2 then
			local item = self.ItemList[i]
			local item_getmask = item.transform:Find("getmask")
			item_getmask.gameObject:SetActive(false)
			self:SetIconMask(item,0.75)
		end
	end

	--progress
	local progress_value = 0
	local factor = Mathf.Clamp(task_data.now_process / task_data.need_process, 0, 1)
	if level == 0 then
		progress_value = self.config.stage[1].progress * factor
	elseif level >= MAX_LEVEL then
		progress_value = self.config.stage[MAX_LEVEL].progress
	else
		progress_value = self.config.stage[level].progress + (self.config.stage[level + 1].progress - self.config.stage[level].progress) * factor
	end

	self.progress_mask_rect.sizeDelta = {x = progress_value, y = PROGRESS_HEIGHT}
	self.current_money_txt.text = StringHelper.ToCash(task_data.now_total_process)
	self.next_money_txt.text = StringHelper.ToCash(task_data.need_process - task_data.now_process)
end

function M:handle_one_task_data_response(_, data)
	if data.id ~= BYLJYJManager.GetTask() then return end
	task_data = data
	task_data.award_status_all = basefunc.decode_task_award_status(task_data.award_get_status)
	task_data.award_status_all = basefunc.decode_all_task_award_status(task_data.award_status_all,task_data,#award_config)
	self:Refresh()
end

function M:handle_task_change(_, data)
	if data.id ~= BYLJYJManager.GetTask() then return end
	task_data = data
	task_data.award_status_all = basefunc.decode_task_award_status(task_data.award_get_status)
	task_data.award_status_all = basefunc.decode_all_task_award_status(task_data.award_status_all,task_data,#award_config)
	self:Refresh()
end

function M:CopyWxCode()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    LittleTips.Create("已复制QQ号请前往QQ进行添加")
    UniClipboard.SetText("4008882620")
end

function M:SetIconMask(item,num)
	local item_icon = item.transform:Find("icon"):GetComponent("Image")
	item_icon.color = Color.New(num,num,num)
	local item_bg = item.transform:Find("bg"):GetComponent("Image")
	item_bg.color = Color.New(num,num,num)
end