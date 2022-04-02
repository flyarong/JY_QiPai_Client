local basefunc = require "Game.Common.basefunc"
FishingEventFireRedBag = basefunc.class()
local M = FishingEventFireRedBag
M.name = "FishingEventFireRedBag"

local BigAwardConfig

local task_data = nil
local award_config = nil
local task_ids = {
	103,
	104,
	105,
}

local PROGRESS_WIDTH = 1680
local PROGRESS_HEIGHT = 32

local TASK_BEGIN_TIME
local TASK_END_TIME
local TASK_OVER_TIME

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
	lister["fsg_force_change_fishery"] = basefunc.handler(self, self.fsg_force_change_fishery)

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
	BigAwardConfig = BYMFHBManager.GetConfig()
	TASK_BEGIN_TIME = BigAwardConfig.base[1].begin_time
	TASK_END_TIME = BigAwardConfig.base[1].end_time
	TASK_OVER_TIME = BigAwardConfig.base[1].over_time

	award_config = {}
	for i,v in ipairs(task_ids) do
		award_config[v] = M.InitAwardConfig(BigAwardConfig["award" .. v])
	end
	if not parent then parent = GameObject.Find("Canvas/LayerLv3").transform end
	local obj = newObject(M.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self.scene_name = MainLogic.GetCurSceneName()
	self:MakeLister()
	self:AddMsgListener()
	self.ItemList = {}
	self.hint_close_btn.onClick:AddListener(function(  )
		self.hint.gameObject:SetActive(false)
	end)
	self:InitRect()
	for i,v in ipairs(task_ids) do
		Network.SendRequest("query_one_task_data", {task_id = v})
	end

	if self.scene_name == "game_Hall" or self.scene_name == GameConfigToSceneCfg.game_FishingHall.SceneName then
		for i,v in ipairs(task_ids) do
			self["tgeItem_" .. v .. "_tge"].gameObject:SetActive(true)
			self["content" .. v].gameObject:SetActive(false)
		end
		self["tgeItem_" .. 103 .. "_tge"].isOn = true
	else
		for i,v in ipairs(task_ids) do
			self["tgeItem_" .. v .. "_tge"].gameObject:SetActive(false)
			self["content" .. v].gameObject:SetActive(false)
		end
		if FishingModel.data then
			local game_id = FishingModel.data.game_id
			if game_id == 1 then
				self["tgeItem_" .. 103 .. "_tge"].isOn = true
			elseif game_id == 2 then
				self["tgeItem_" .. 104 .. "_tge"].isOn = true
			elseif game_id == 3 then
				self["tgeItem_" .. 105 .. "_tge"].isOn = true
			end
		end
	end
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

function M:InitTge(t_id)
    local TG = self.center.transform:GetComponent("ToggleGroup")
    local go = self["tgeItem_" .. t_id .. "_tge"]
    local ui_table = {}
    ui_table.transform = go.transform
    LuaHelper.GeneratingVar(go.transform, ui_table)
    ui_table.item_tge = go.transform:GetComponent("Toggle")
    ui_table.item_tge.onValueChanged:AddListener(
		function(val)
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            ui_table.tge_txt.gameObject:SetActive(not val)
            ui_table.mark_tge_txt.gameObject:SetActive(val)
            if val then
				for i,v in ipairs(task_ids) do
					self["content" .. v].gameObject:SetActive(v == t_id)
					self[v .. "_txt"].gameObject:SetActive(v == t_id)
				end
            end
        end
    )
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

	for i,v in ipairs(task_ids) do
		self:CreateAllItem(v)
		self:InitTge(v)
	end
	self.time_txt.text = "活动时间：" .. os.date("%m月%d日%H:%M - ", TASK_BEGIN_TIME) .. os.date("%m月%d日%H:%M", TASK_END_TIME)
end

function M:Refresh(data)
	local transform = self.transform
	if not IsEquals(transform) then return end

	self:RefreshItems(data)
end

function M:ClearItemList(list)
	for k,v_list in pairs(list) do
		for i,v in pairs(v_list) do
			if IsEquals(v) then
				GameObject.Destroy(v.gameObject)
			end
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

function M:CreateAllItem(t_id)
	local componets ={}
	LuaHelper.GeneratingVar(self["content" .. t_id].transform,componets)
	componets.progress_mask_rect = componets.progress_mask:GetComponent("RectTransform")
	componets.progress_mask_rect.sizeDelta = {x = 0, y = PROGRESS_HEIGHT}
	for k, v in ipairs(BigAwardConfig["stage" .. t_id]) do
		local item = self:CreateItem(componets.item_node, self.item_tmpl)
		local item_slider = item.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_20_5")

		local item_bg = item.transform:Find("icon"):GetComponent("Image")
		item_bg.sprite = GetTexture(v.icon)

		local item_award = item.transform:Find("icon/award"):GetComponent("Text")
		item_award.text = v.desc
		self:SetIconStatus(item,0)
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
			data.cur_award_status = task_data[t_id].award_status_all[v.level]
			data.now_level = v.level
			data.task_id = t_id
			GameManager.GotoUI({gotoui = "act_lottery_card",data = data,award_config = award_config})
		end)
		ClipUIParticle(item.transform)
		--item_btn.gameObject:SetActive(false)
		self.ItemList[t_id] = self.ItemList[t_id] or {}
		self.ItemList[t_id][#self.ItemList[t_id] + 1] = item
	end
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

function M:RefreshItems(data)
	dump(task_data, "<color=yellow>task_data</color>")
	local t_id = data.id
	if not task_data or not task_data[t_id] then
		print("[SGE] Event task_data invalid")
		return
	end

	local MAX_LEVEL = #BigAwardConfig["stage" .. t_id]

	for k, v in ipairs(self.ItemList[t_id]) do
		local item_slider = v.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_20_5")
		self:SetIconStatus(v.transform,0)
		local item_getmask = v.transform:Find("getmask")
		item_getmask.gameObject:SetActive(false)

		if task_data[t_id].award_status_all[k] == 2 then
			local item = self.ItemList[t_id][k]
			local getedmask = item.transform:Find("getedmask")
			getedmask.gameObject:SetActive(true)
		end
	end

	--progress dot
	local level = task_data[t_id].now_lv - 1	--AdaptTaskTable(task_data[t_id].now_total_process)
	for idx = 1, level do
		local item = self.ItemList[t_id][idx]
		local item_slider = item.transform:Find("slider"):GetComponent("Image")
		item_slider.sprite = GetTexture("gy_20_7")
	end

	local full_process = false
	if task_data[t_id].now_lv >= MAX_LEVEL then
		if task_data[t_id].now_process == task_data[t_id].need_process then
			local item = self.ItemList[t_id][MAX_LEVEL]
			local item_slider = item.transform:Find("slider"):GetComponent("Image")
			item_slider.sprite = GetTexture("gy_20_7")
			full_process = true
		end
	end

	for i,v in ipairs(task_data[t_id].award_status_all) do
		self:SetIconStatus(self.ItemList[t_id][i],v)
	end

	--progress
	local progress_value = 0
	local factor = Mathf.Clamp(task_data[t_id].now_process / task_data[t_id].need_process, 0, 1)
	if level == 0 then
		progress_value = BigAwardConfig["stage" .. t_id][1].progress * factor
	elseif level >= MAX_LEVEL then
		progress_value = BigAwardConfig["stage" .. t_id][MAX_LEVEL].progress
	else
		progress_value = BigAwardConfig["stage" .. t_id][level].progress + (BigAwardConfig["stage" .. t_id][level + 1].progress - BigAwardConfig["stage" .. t_id][level].progress) * factor
	end

	local progress_mask_rect = self["content" .. t_id].transform:Find("progress_bg/@progress_mask"):GetComponent("RectTransform")
	progress_mask_rect.sizeDelta = {x = progress_value, y = PROGRESS_HEIGHT}
	self:SetGunRedBagTxt(t_id)
end

function M.handle_one_task_data_response(_, data)
	if not BYMFHBManager.GetTaskHash()[data.id] then return end
	task_data = task_data or {}
	local t_id = data.id
	task_data[t_id] = data
	task_data[t_id].award_status_all = basefunc.decode_task_award_status(task_data[t_id].award_get_status)
	task_data[t_id].award_status_all = basefunc.decode_all_task_award_status(task_data[t_id].award_status_all,task_data[t_id],#award_config[t_id])
	if instance then
		instance:Refresh(data)
	end
end

function M.handle_task_change(_, data)
	if not BYMFHBManager.GetTaskHash()[data.id] then return end
	task_data = task_data or {}
	local t_id = data.id
	task_data[t_id] = data
	task_data[t_id].award_status_all = basefunc.decode_task_award_status(task_data[t_id].award_get_status)
	task_data[t_id].award_status_all = basefunc.decode_all_task_award_status(task_data[t_id].award_status_all,task_data[t_id],#award_config[t_id])
	if instance then
		instance:Refresh(data)
	end
end

function M.fsg_force_change_fishery(_, data)
	dump(data, "<color=yellow>fsg_force_change_fishery</color>")
end

function M.CheckActive()
	--if true then return 1 end
	local stamp = os.time()
	if stamp < TASK_BEGIN_TIME then return 0 end
	if stamp < TASK_END_TIME then return 1 end
	if stamp < TASK_OVER_TIME then return 2 end
	return -1
end

function M:SetIconMask(item,num)
	local item_icon = item.transform:Find("icon"):GetComponent("Image")
	item_icon.color = Color.New(num,num,num)
	local item_bg = item.transform:Find("bg"):GetComponent("Image")
	item_bg.color = Color.New(num,num,num)
end

function M:SetIconStatus(item,v)
	local item_getmask = item.transform:Find("getmask")
	local getedmask = item.transform:Find("getedmask")
	local not_start_mask = item.transform:Find("notstartmask")
	local yhd = item.transform:Find("yhd_img")
	not_start_mask.gameObject:SetActive(v == 0)
	item_getmask.gameObject:SetActive(v == 1)
	getedmask.gameObject:SetActive(v == 2)
	yhd.gameObject:SetActive(v == 2)
end

function M:SetGunRedBagTxt(t_id)
	self[t_id .. "_txt"].text = ""
	local t_data =task_data[t_id]
	local is_over = true
	for k,v in pairs(t_data.award_status_all) do
		if v ~= 2 then
			is_over = false
			break
		end
	end
	if is_over then 
		self[t_id .. "_txt"].text = string.format( "<color=#fffc1fff><size=36>已完成</size></color>") 
		return
	end

	local stage_data = BigAwardConfig["stage" .. t_id]
	local g_rate = 1000
	local g_num = 0
	local cur_red = BigAwardConfig["stage" .. t_id][t_data.now_lv]
	if self.scene_name == "game_Hall" or self.scene_name == GameConfigToSceneCfg.game_FishingHall.SceneName then
		g_rate = BigAwardConfig.base[1]["rate" .. t_id] or 1000
		g_num = math.ceil( (t_data.need_process - t_data.now_process) / g_rate )
		self[t_id .. "_txt"].text = string.format( "<color=#fffc1fff><size=36>%s</size></color> 倍炮只需 <color=#fffc1fff><size=36>%s</size></color> 炮，即可抽 <color=#fffc1fff><size=36>%s</size></color> ",g_rate , g_num,cur_red.desc)
	else
		local p_d = FishingModel.GetPlayerData()
		g_rate = FishingModel.GetGunCfg(p_d.index).gun_rate
		g_num = math.ceil( (t_data.need_process - t_data.now_process) / g_rate )
		self[t_id .. "_txt"].text = string.format( "<color=#fffc1fff><size=36>%s</size></color> 倍炮只需 <color=#fffc1fff><size=36>%s</size></color> 炮，即可抽 <color=#fffc1fff><size=36>%s</size></color> ",g_rate , g_num,cur_red.desc)
	end
	
end

function M:CheckIsMTask(id)
	local is_m_task = false
	for i,v in ipairs(task_ids) do
		if id == v then is_m_task = true end
	end
	return is_m_task
end