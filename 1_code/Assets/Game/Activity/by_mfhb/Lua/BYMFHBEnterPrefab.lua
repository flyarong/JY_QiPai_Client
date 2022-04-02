-- 创建时间:2019-09-25
-- Panel:BYMFHBEnterPrefab
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

BYMFHBEnterPrefab = basefunc.class()
local M = BYMFHBEnterPrefab
M.name = "BYMFHBEnterPrefab"
M.task_data = {}
function M.Create(parent, cfg)
	return M.New(parent, cfg)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
	self.lister = {}
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.handle_task_change)
	self.lister["refresh_gun"] = basefunc.handler(self, self.refresh_gun)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function M:OnDestroy(  )
	self:MyExit()
end

function M:ctor(parent, cfg)
	self.config = cfg
	local obj = newObject("BYMFHBEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function M:InitUI()
	self:SetEnterBtn()
	self:MyRefresh()
end

function M:MyRefresh()
	
end

function M:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	FishingEventFireRedBag.Create()
end

function M:OnDestroy()
	self:MyExit()
end

function M:handle_one_task_data_response(_, data)
	self:RefreshEnterBtn(data)
end

function M:handle_task_change(_, data)
	self:RefreshEnterBtn(data)
end

function M:SetEnterBtn()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
		self:OnEnterClick()
	end)

	local cur_scene = MainLogic.GetCurSceneName() --根据场景进行不同设置
	if cur_scene == GameConfigToSceneCfg.game_FishingHall.SceneName then
		return
	end
	if cur_scene == GameConfigToSceneCfg.game_Fishing.SceneName and (FishingModel.data and FishingModel.data.game_id == 4) then
		return
	end

	if cur_scene == GameConfigToSceneCfg.game_FishingHall.SceneName then
		
	elseif cur_scene == GameConfigToSceneCfg.game_Fishing.SceneName then
		
	elseif cur_scene == "game_Hall" then
		
	elseif cur_scene == GameConfigToSceneCfg.game_MiniGame.SceneName then
		
	end

	self.enter_btn.onClick:AddListener(function()
		self:OnClickFireRedBag(cur_scene)
	end)
	self.can_get = self.enter_btn.transform:Find("can_get")
	print("<color=white>请求任务数据：：：：</color>")
	for k,v in pairs(BYMFHBManager.GetTaskList()) do
		Network.SendRequest("query_one_task_data", {task_id = v})
	end
	self.enter_btn.gameObject:SetActive(true)
end

function M:RefreshEnterBtn(data)
	if not BYMFHBManager.GetTaskHash()[data.id] then return end
	local cfg = BYMFHBManager.GetConfig()
	local count = #cfg["stage" .. data.id] or 6
	local task_data = {}
	task_data = data
	task_data.award_status_all = basefunc.decode_task_award_status(task_data.award_get_status)
	task_data.award_status_all = basefunc.decode_all_task_award_status(task_data.award_status_all,task_data,count)

	M.task_data[data.id] = data
	if not IsEquals(self.enter_btn) then return end
	local function set_can_get_btn(v)
		if not IsEquals(self.can_get) then
			self.can_get = self.enter_btn.transform:Find("can_get")
		end
		if IsEquals(self.can_get) then
			self.can_get.gameObject:SetActive(v)
		end
	end
	local cur_scene = MainLogic.GetCurSceneName()
	if cur_scene == "game_Hall" then
		for k,_v in pairs(M.task_data) do
			for i,v in ipairs(_v.award_status_all) do
				if v == 1 then
					-- set_can_get_btn(true)
					return
				end
			end
		end			
	elseif cur_scene == GameConfigToSceneCfg.game_Fishing.SceneName then
		if FishingModel.data then
			local gid_to_tid = BYMFHBManager.GetTaskList()
			local game_id = FishingModel.data.game_id
			if gid_to_tid[game_id] and data.id == gid_to_tid[game_id] then
				local is_over = true
				for k,v in pairs(data.award_status_all) do
					if v ~= 2 then
						is_over = false
						break
					end
				end
				if is_over then 
					if not self.hb_txt or not IsEquals(self.hb_txt) then
						self.hb_txt = self.enter_btn.transform:Find("hb_txt"):GetComponent("Text")
					end
					self.hb_txt.gameObject:SetActive(false)
					if not self.gun_txt or not IsEquals(self.gun_txt) then
						self.gun_txt = self.enter_btn.transform:Find("gun_txt"):GetComponent("Text")
					end
					self.gun_txt.text = "已完成"

					if not self.gun_txt1 or not IsEquals(self.gun_txt1) then
						self.gun_txt1 = self.enter_btn.transform:Find("gun_txt/gun"):GetComponent("Text")
					end
					if not self.gun_txt2 or not IsEquals(self.gun_txt2) then
						self.gun_txt2 = self.enter_btn.transform:Find("gun_txt/gun (1)"):GetComponent("Text")
					end
					self.gun_txt1.gameObject:SetActive(false)
					self.gun_txt2.gameObject:SetActive(false)
					set_can_get_btn(false)
					return
				end

				local p_d = FishingModel.GetPlayerData()
				local g_rate = FishingModel.GetGunCfg(p_d.index).gun_rate
				local g_num = math.ceil( (data.need_process - data.now_process) / g_rate )
				if not self.gun_txt or not IsEquals(self.gun_txt) then
					self.gun_txt = self.enter_btn.transform:Find("gun_txt"):GetComponent("Text")
				end
				self.gun_txt.text = g_num
				local cur_red = fish_activity_fire_red_bag_config["stage" .. data.id][data.now_lv]
				if not self.hb_txt or not IsEquals(self.hb_txt) then
					self.hb_txt = self.enter_btn.transform:Find("hb_txt"):GetComponent("Text")
				end
				local str = cur_red.desc
				str =  string.gsub(str,"福卡","")
				self.hb_txt.text = str

				for i,v in ipairs(data.award_status_all) do
					if v == 1 then
						set_can_get_btn(true)
						return
					end
				end
			elseif gid_to_tid[game_id] and data.id ~= gid_to_tid[game_id] then
				return
			end
		end
	end
	
	set_can_get_btn(false)
end

function M:refresh_gun(f_data)
	if f_data.seat_num ~= FishingModel.GetPlayerSeat() then return end
	if not IsEquals(self.enter_btn) then return end
	local gid_to_tid =  BYMFHBManager.GetTaskList()
	local game_id = FishingModel.data.game_id
	if not game_id then return end
	dump(M.task_data, "<color=white>M.task_data</color>")
	local data = M.task_data[gid_to_tid[game_id]]
	dump(data, "<color=white>data</color>")
	if not data or not next(data) then return end

	local is_over = true
	for k,v in pairs(data.award_status_all) do
		if v ~= 2 then
			is_over = false
			break
		end
	end
	if is_over then 
		if not self.hb_txt or not IsEquals(self.hb_txt) then
			self.hb_txt = self.enter_btn.transform:Find("hb_txt"):GetComponent("Text")
		end
		self.hb_txt.gameObject:SetActive(false)
		if not self.gun_txt or not IsEquals(self.gun_txt) then
			self.gun_txt = self.enter_btn.transform:Find("gun_txt"):GetComponent("Text")
		end
		if not self.gun_txt1 or not IsEquals(self.gun_txt1) then
			self.gun_txt1 = self.enter_btn.transform:Find("gun_txt/gun"):GetComponent("Text")
		end
		if not self.gun_txt2 or not IsEquals(self.gun_txt2) then
			self.gun_txt2 = self.enter_btn.transform:Find("gun_txt/gun (1)"):GetComponent("Text")
		end
		self.gun_txt.text = "已完成"
		self.gun_txt1.gameObject:SetActive(false)
		self.gun_txt2.gameObject:SetActive(false)
		return
	end

	if not self.hb_txt or not IsEquals(self.hb_txt) then
		self.hb_txt = self.enter_btn.transform:Find("hb_txt"):GetComponent("Text")
	end
	self.hb_txt.gameObject:SetActive(true)
	if not self.gun_txt or not IsEquals(self.gun_txt) then
		self.gun_txt = self.enter_btn.transform:Find("gun_txt"):GetComponent("Text")
	end
	if not self.gun_txt1 or not IsEquals(self.gun_txt1) then
		self.gun_txt1 = self.enter_btn.transform:Find("gun_txt/gun"):GetComponent("Text")
	end
	if not self.gun_txt2 or not IsEquals(self.gun_txt2) then
		self.gun_txt2 = self.enter_btn.transform:Find("gun_txt/gun (1)"):GetComponent("Text")
	end
	self.gun_txt1.gameObject:SetActive(true)
	self.gun_txt2.gameObject:SetActive(true)

	local g_rate = f_data.gun_rate
	local g_num = math.ceil( (data.need_process - data.now_process) / g_rate )
	if not self.gun_txt or not IsEquals(self.gun_txt) then
		self.gun_txt = self.enter_btn.transform:Find("gun_txt"):GetComponent("Text")
	end
	self.gun_txt.text = g_num
end