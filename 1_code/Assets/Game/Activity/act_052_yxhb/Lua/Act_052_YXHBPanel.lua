-- 创建时间:2021-02-22
-- Panel:Act_052_YXHBPanel
--[[ *	  ┌─┐	   ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │				 │
 *   │	   ───	   │
 *   │  ─┬┘	   └┬─  │
 *   │				 │
 *   │	   ─┴─	   │
 *   │				 │
 *   └───┐		 ┌───┘
 *	   │		 │
 *	   │		 │
 *	   │		 │
 *	   │		 └──────────────┐
 *	   │						│
 *	   │						├─┐
 *	   │						┌─┘
 *	   │						│
 *	   └─┐  ┐  ┌───────┬──┐  ┌──┘
 *		 │ ─┤ ─┤	   │ ─┤ ─┤
 *		 └──┴──┘	   └──┴──┘
 *				神兽保佑
 *			   代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]
local basefunc = require "Game/Common/basefunc"

Act_052_YXHBPanel = basefunc.class()
local C = Act_052_YXHBPanel
local M = Act_052_YXHBManager
C.name = "Act_052_YXHBPanel"

function C.Create(backcall)
	return C.New(backcall)
end

function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_yxhb_mrlb_refresh"] = basefunc.handler(self, self.on_model_yxhb_mrlb_refresh)
	self.lister["model_yxhb_task_refresh"] = basefunc.handler(self, self.on_model_yxhb_task_refresh)
	self.lister["model_yxhb_exchange_refresh"] = basefunc.handler(self, self.on_model_yxhb_exchange_refresh)
	self.lister["model_yxhb_get_task_award"] = basefunc.handler(self, self.on_model_yxhb_get_task_award)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.on_enter_background)--切到后台
	self.lister["ExitScene"] = basefunc.handler(self, self.on_exit_scene)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.remain_timer then
		self.remain_timer:Stop()
	end

	if self.mrlb_remain_timer then
		self.mrlb_remain_timer:Stop()
	end

	if self.backcall then
		self.backcall()
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

function C:ctor(backcall)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.backcall = backcall

	self:MakeLister()
	self:AddMsgListener()
	self:InitCfg()
	self:UpdateTodayEndTime()
	self:InitUI()
	M.QueryActivityExchangeInfo()
	M.QueryBoxExchangeInfo()
	self.mrlb_remian_txt.gameObject:SetActive(false)
    Event.Brocast("WQP_Guide_Check",{guide = 3 ,guide_step = 2})
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	self.hb_exchange_btn.onClick:AddListener(function()
		self:ActExchange()
	end)
	self:MyRefresh()
	self:RefreshRemainTime()
end

function C:InitCfg()
	self.cur_task_cfg = M.GetTaskCfg()
	self.act_end_time = M.GetActEndTime()

	self.tx_start_trans = self.hb_num_txt.transform.localPosition
	self.tx_end_trans = self.hb_num_txt.transform.localPosition
	self.cur_award_data = nil
end

-- function C:InitCheckInTime()
-- 	self.check_inTime_timer = Timer.New(function ()
-- 		if os.time() > self.act_end_time then
-- 			self:MyExit()
-- 		end
-- 	end,15,-1)
-- 	self.check_inTime_timer:Start()
-- end

function C:UpdateTodayEndTime()
	local cDateCurrectTime = os.date("*t")
	self.today_end_time = os.time({ year = cDateCurrectTime.year, month = cDateCurrectTime.month, day = cDateCurrectTime.day + 1, hour = 0, min = 0, sec = 0 })
end

function C:UpdateExchangeData()
	self.item_num = M.GetItemNum()
	self.exchange_state = M.GetExchangeState()
end

function C:UpdateCurTaskData()
	self.cur_task_data = M.GetCurTaskData()
	self.task_show_num = 0
	for i = 1, #self.cur_task_data do
		for j = 1, #self.cur_task_data[i] do
			local cur_data = self.cur_task_data[i][j]
			if cur_data.state ~= 2 then
				self.task_show_num = self.task_show_num + 1
			end
			--self.task_show_num = self.task_show_num + #self.cur_task_data[i]
		end
	end
end

function C:MyRefresh()
	self:RefreshTask()
	self:RefreshExchange()
	self:RefreshMrlb()
end

function C:RefreshTask()
	self:UpdateCurTaskData()
	self:RefreshTaskUI()
end

function C:RefreshExchange()
	self:UpdateExchangeData()
	self:RefreshExchangeUI()
end

function C:RefreshMrlb()
	self:RefreshMrGiftUI()
end

------------------------------------------------------------
function C:on_model_yxhb_mrlb_refresh()
	self:RefreshMrlb()
end

function C:on_model_yxhb_task_refresh()
	self:RefreshTask()
	self:RefreshExchange()
end

function C:on_model_yxhb_exchange_refresh()
	self:RefreshExchange()
end

function C:on_enter_background()
	self:MyExit()
end

function C:on_exit_scene()
	self:MyExit()
end

------------------------------------------------------------
function C:RefreshTaskUI()

	if IsEquals(self.Content.transform) then
		self:RefreshTaskPrefab()
	end

	if self.task_show_num >= 1 then
		self:RefreshTaskContent()
	end
end

function C:RefreshTaskPrefab()
	local pre_num = self.Content.transform.childCount
	if pre_num < self.task_show_num then
		self:AddTaskPrefab(self.task_show_num - pre_num)
	elseif pre_num > self.task_show_num then
		self:DeleTaskPrefab(pre_num - self.task_show_num)
	end
end

function C:AddTaskPrefab(num)
	for i = 1, num do
		local cur_task = newObject("Act_052_YXHBItem", self.Content)
	end
end

function C:DeleTaskPrefab(num)
	for i = 1, num do
		local obj = self.Content.transform:GetChild(self.Content.transform.childCount - 1)
		destroy(obj.gameObject)
	end
end

function C:RefreshTaskContent()
	local cur_item_num = 1
	local cur_day = M.GetCurDay()

	local check_1 = function(_data, is_tm)
		if _data.state == 1 and not is_tm then
			return true
		end
	end

	local check_2 = function(_data, is_tm)
		if _data.state == 0 and not is_tm then
			return true
		end
	end

	local check_3 = function(_data, is_tm)
		if is_tm then
			return true
		end
	end

	local traver_task = function(check)
		for i = 1, #self.cur_task_data do
			local _is_tm = i > cur_day
			for j = 1, #self.cur_task_data[i] do
				local cur_data = self.cur_task_data[i][j]
				if check(cur_data, _is_tm) then
					self:LoadTaskItem(cur_item_num, cur_data, self.cur_task_cfg[i][j], _is_tm, i)
					cur_item_num = cur_item_num + 1
				end
			end
		end
	end
	traver_task(check_1)
	traver_task(check_2)
	traver_task(check_3)
end


function C:LoadTaskItem(index, _data, _cfg, is_tomorrow, cur_day)
	local item = self.Content.transform:GetChild(index - 1)
	local temp_ui = {}
	LuaHelper.GeneratingVar(item.transform, temp_ui)
	temp_ui.award_1_img.sprite = GetTexture(_cfg.award_icon[1])
	temp_ui.award_2_img.sprite = GetTexture(_cfg.award_icon[2])
	temp_ui.award_1_txt.text = _cfg.award_txt[1]
	temp_ui.award_2_txt.text = _cfg.award_txt[2]
	temp_ui.desc_txt.text = _cfg.task
	if tonumber(_data.now_total_process) > tonumber(_data.need_process) then
		--temp_ui.pg_txt.text = "进度:" .. _data.need_process .. "/" .. _data.need_process
		if _cfg.task_id == 100007 or _cfg.task_id == 100016 then
			temp_ui.pg_txt.text = _data.need_process/100 .. "/" .. _data.need_process/100
		else
			temp_ui.pg_txt.text = _data.need_process .. "/" .. _data.need_process
		end
	else
		--temp_ui.pg_txt.text = "进度:" .. _data.now_total_process .. "/" .. _data.need_process
		if _cfg.task_id == 100007 or _cfg.task_id == 100016 then
			temp_ui.pg_txt.text = _data.now_total_process/100 .. "/" .. _data.need_process/100
		else
			temp_ui.pg_txt.text = _data.now_total_process .. "/" .. _data.need_process
		end
	end

	temp_ui.Slider.transform:GetComponent("Slider").value = _data.now_total_process / _data.need_process
	temp_ui.cur_day_txt.text = "第 " .. cur_day .. " 天"
	if temp_ui.get_btn_100001_1 then
		temp_ui.get_btn = temp_ui.get_btn_100001_1.transform:GetComponent("Button")
		temp_ui.get_btn.gameObject.name = "@get_btn"
	end

	temp_ui.get_btn.gameObject:SetActive(false)
	temp_ui.goto_btn.gameObject:SetActive(false)
	if _data.state == 0 and _cfg.gotoUI then
		temp_ui.goto_btn.gameObject:SetActive(true)
		temp_ui.goto_btn.onClick:RemoveAllListeners()
		temp_ui.goto_btn.onClick:AddListener(function()
			self:Goto(_cfg.gotoUI)
		end)
	elseif _data.state == 1 then
		if is_tomorrow then
			temp_ui.tm_get_txt.gameObject:SetActive(true)
		else
			temp_ui.get_btn.gameObject:SetActive(true)
			temp_ui.get_btn.onClick:RemoveAllListeners()
			if _cfg.task_lv then
				temp_ui.get_btn.onClick:AddListener(function()
					self.tx_start_trans = temp_ui.award_2_img.transform.position
					Network.SendRequest("get_task_award_new", { id = _cfg.task_id, award_progress_lv = _cfg.task_lv })
				end)
			else
				temp_ui.get_btn.onClick:AddListener(function()
					self.tx_start_trans = temp_ui.award_2_img.transform.position
					Network.SendRequest("get_task_award", { id = _cfg.task_id })
				end)
			end
		end

		--玩棋牌新手引导特殊处理
		if _cfg.task_id == 100001 and _cfg.task_lv == 1 then
			temp_ui.get_btn.gameObject.name = "@get_btn_100001_1"
		end
	end

	
end

function C:Goto(_gotoui)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameManager.CommonGotoScence({gotoui = _gotoui[1],goto_scene_parm = _gotoui[2]})
end

function C:ActExchange()
	if self.exchange_state == 0 then
		if self.item_num < 200 then
			HintPanel.Create(1, "红包券不足~")
			return
		end

		if not M.IsCmp3DayTask() then
			HintPanel.Create(1, "完成前三天任务后可提取！")
			return
		end
		-- dump("<color=white>AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</color>")
		Network.SendRequest("activity_exchange", { type = M.exchange_type, id = 1 })

	elseif self.exchange_state == 1 then
		if self.item_num < 1000 then
			HintPanel.Create(1, "红包券不足~")
			return
		end

		if not M.IsCmp7DayTask() then
			HintPanel.Create(1, "完成所有任务后可提取！")
			return
		end
		-- dump("<color=white>AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA</color>")
		Network.SendRequest("activity_exchange", { type = M.exchange_type, id = 2 })
	end
end

function C:RefreshExchangeUI()
	self.hb_num_txt.text = self.item_num / 100
	if self.exchange_state == 0 then
		self.hb_desc_txt.text = "满2元可兑！"
	else
		self.hb_desc_txt.text = "满10元可兑！"
	end
end

function C:RefreshMrGiftUI()

	if not IsEquals(self.mrlb_btn) then
		return 
	end

	self.mrlb_btn.gameObject:SetActive(false)
	local mr_state = M.GetMrGiftState()
	-- dump(mr_state, "<color=white>mr_state</color>")

	local set_open_mrlb_btn = function()
		self.mrlb_btn.onClick:RemoveAllListeners()
		self.mrlb_btn.onClick:AddListener(function()
			Network.SendRequest("box_exchange", { id = M.exchange_mrlb_id, num = 1 })
		end)
		CommonHuxiAnim.Start(self.mrlb_btn.gameObject,1)
	end
	
	if mr_state == 1 then
		self.mrlb_btn.gameObject:SetActive(true)
		self.mrlb_btn.onClick:AddListener(function()
			LTTipsPrefab.Show2(self.mrlb_btn.transform, "明日礼包", "次日可开启，有机会获得10元现金或10元话费或千元赛门票1张")
		end)

		if self.mrlb_remain_timer then
			self.mrlb_remain_timer:Stop()
		end

		self.mrlb_remain_time = M.GetMrlbOpenTime()

		-- local refresh_mrlb_txt = function()
		-- 	self.mrlb_remian_txt.text = StringHelper.formatTimeDHMS3(self.mrlb_remain_time - os.time()) .. "后领取"
		-- end

		self.mrlb_remain_timer = Timer.New(function()
			if os.time() > self.mrlb_remain_time then
				self.mrlb_remian_txt.gameObject:SetActive(false)
				set_open_mrlb_btn()
				self.mrlb_remain_timer:Stop()
			else
				--refresh_mrlb_txt()
			end
		end, 1, -1)
		--refresh_mrlb_txt()
		self.mrlb_remain_timer:Start()
	elseif mr_state == 2 then
		self.mrlb_btn.gameObject:SetActive(true)
		self.mrlb_remian_txt.gameObject:SetActive(false)
		set_open_mrlb_btn()
	end
end


function C:RefreshRemainTime()
	if self.remain_timer then
		self.remain_timer:Stop()
	end

	local refresh_remain_time = function()
		local remian_second = self.act_end_time - os.time()
		local remain_time_txt = string.format("%d天%d小时", math.floor(remian_second / 86400), math.fmod(math.floor(remian_second / 3600), 24))
		self.act_remian_txt.text = "剩余时间:" .. remain_time_txt
	end
	self.remain_timer = Timer.New(function()
		refresh_remain_time()
		if os.time() > self.act_end_time then
			Event.Brocast("act_052_yxhb_out_time")
			self:MyExit()
		end
		-- dump(os.time(), "<color=red>当前时间戳</color>")
		-- dump(self.today_end_time, "<color=red>刷新时间戳</color>")
		if os.time() > self.today_end_time then
			local cDateCurrectTime = os.date("*t")
			self.today_end_time = os.time({ year = cDateCurrectTime.year, month = cDateCurrectTime.month, day = cDateCurrectTime.day + 1, hour = 0, min = 0, sec = 0 })
			self:RefreshTask()
			Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
		end
	end, 15, -1)
	refresh_remain_time()
	self.remain_timer:Start()
end


function C:on_model_yxhb_get_task_award(data)
	local anim_call = function ()
		--dump(data,"<color=white>----Event.Brocast(AssetGet)---</color>")
		Event.Brocast("AssetGet", data)
	end
	--dump(data,"<color=white>----PlayGetAnim---</color>")
	self:PlayGetAnim(anim_call)
end

function C:PlayGetAnim(call)
	--local cur_tx = GameObject.Instantiate(self.tx_lizituowei,self.transform)
	self.tx_lizituowei.gameObject:SetActive(true)
	self.tx_lizituowei.transform.localPosition = self.tx_start_trans
	local seq = DoTweenSequence.Create({ dotweenLayerKey = "yxhb_tween" })

    local path = {}
    path[1] = self.tx_start_trans
    path[2] = self.tx_end_trans
	if IsEquals(self.tx_lizituowei) then
		seq:Append(self.tx_lizituowei.transform:DOLocalPath(path, 1, DG.Tweening.PathType.CatmullRom))
		--seq:AppendInterval(1)
		seq:OnKill(function()
			call()
			if IsEquals(self.tx_lizituowei) then
				self.tx_lizituowei.gameObject:SetActive(false)
			else
				self:MyExit()
			end
		end)
	end
end