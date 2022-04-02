-- 创建时间:2019-05-14
-- Panel:FishingTaskPanel
local basefunc = require "Game/Common/basefunc"

FishingTaskPanel = basefunc.class()
local C = FishingTaskPanel
C.name = "FishingTaskPanel"


FishingTaskPanel.TaskState = 
{
	TS_Nor = "第一次创建",
	TS_Null = "任务为空",
	TS_Day = "每日任务",
	TS_TZ = "挑战任务",
	TS_TZAnim = "播放挑战任务出现动画",
	TS_TZAnimFinish = "播放挑战任务出现动画完成",
	TS_Out = "任务超量",
}

function C.Create(parent, panelSelf)
	return C.New(parent, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_query_fish_daily_children_tasks"] = basefunc.handler(self, self.on_query_response)
    self.lister["model_fish_daily_children_tasks_change_msg"] = basefunc.handler(self, self.on_task_addOrdel_change)
    self.lister["by_task_model_task_change_msg"] = basefunc.handler(self, self.on_task_change)

    self.lister["ui_appearTZ_task_msg"] = basefunc.handler(self, self.AppearTZTask)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.tz_pre:MyExit()
	self.big_pre:MyExit()
	self.small_pre:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent, panelSelf)
	ExtPanel.ExtMsg(self)

	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.TaskRect = tran:Find("TaskRect")
	self.TZTaskRect = tran:Find("TZTaskRect")
	self.TaskRectGroup = self.TaskRect:GetComponent("CanvasGroup")
	self.TZTaskRectGroup = self.TZTaskRect:GetComponent("CanvasGroup")
	
	self.task_state = FishingTaskPanel.TaskState.TS_Nor

	self.tz_pre = FishingTZTaskPrefab.Create(self.TZTaskRect)
	self.big_pre = FishingTaskBigPrefab.Create(self.TaskRect)
	self.small_pre = FishingTaskSmallPrefab.Create(self.TaskRect, function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnSmallClick()
	end)
	self.children_task_ids = {}
	self.children_task_map = {}
	self.tz_task_id = -1

	BYTaskManager.QueryData()
end
function C:UpdateData()
	-- 详情在左边
	self.is_big_left = false
	if GameGlobalOnOff.FishingTask then
		if FishingModel.data and FishingModel.data.game_id then
			Network.SendRequest("query_fish_daily_children_tasks", {fish_game_id=FishingModel.data.game_id})
		end
	end
end
function C:MyRefresh()
	if self.tz_task_id or (self.children_task_ids and #self.children_task_ids > 0) then
		self.tz_task_id = self:GetTZTaskIndex()

		if self.tz_task_id then
			dump(self.task_state, "<color=red>task_statetask_state >>>>>>>> </color>")
		end
		if self.tz_task_id and
			(self.task_state == FishingTaskPanel.TaskState.TS_Nor or
			self.task_state == FishingTaskPanel.TaskState.TS_TZAnimFinish or
			self.task_state == FishingTaskPanel.TaskState.TS_TZ) then
			self.task_state = FishingTaskPanel.TaskState.TS_TZ
			if IsEquals(self.tz_pre.transform) then
				self.tz_pre.transform.localPosition = Vector3.New(0, 0, 0)
			end
			self.tz_pre:UpdateData( self.children_task_map[ self.tz_task_id ] )
			if IsEquals(self.TZTaskRect) then
				self.TZTaskRect.gameObject:SetActive(true)
			end
			if IsEquals(self.TaskRect) then
				self.TaskRect.gameObject:SetActive(false)
			end
		else
			-- 屏蔽水浒消消乐、水果消消乐、街机捕鱼内的日常任务
		    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_little_game_daily_task", is_on_hint = true}, "CheckCondition")
		    if a and b then
				self.TaskRect.gameObject:SetActive(false)
				Event.Brocast("FishingTaskBigPrefab_ShowOrHide_Changed",{isShow = false})
		        return
		    end
			self.TZTaskRect.gameObject:SetActive(false)
			self.TaskRect.gameObject:SetActive(true)
			if #self.children_task_ids == 1 then
				self.task_state = FishingTaskPanel.TaskState.TS_Day
				self.big_pre.transform.localPosition = Vector3.New(0, 0, 0)
				self.big_pre:UpdateData( self.children_task_map[ self.children_task_ids[1] ] )
			elseif #self.children_task_ids == 2 then
				self.task_state = FishingTaskPanel.TaskState.TS_Day
				if self.is_big_left then
					self.big_pre.transform.localPosition = Vector3.New(-94, 0, 0)
					self.small_pre.transform.localPosition = Vector3.New(194, 0, 0)
					self.big_pre:UpdateData( self.children_task_map[ self.children_task_ids[1] ] )
					self.small_pre:UpdateData( self.children_task_map[ self.children_task_ids[2] ] )
				else
					self.big_pre.transform.localPosition = Vector3.New(94, 0, 0)
					self.small_pre.transform.localPosition = Vector3.New(-194, 0, 0)
					self.big_pre:UpdateData( self.children_task_map[ self.children_task_ids[2] ] )
					self.small_pre:UpdateData( self.children_task_map[ self.children_task_ids[1] ] )
				end
			else
				self.task_state = FishingTaskPanel.TaskState.TS_Out
				self.big_pre:UpdateData()
				self.small_pre:UpdateData()
				dump(self.children_task_map, "<color=red>捕鱼任务数量异常 </color>")
			end
		end
	else
		self.task_state = FishingTaskPanel.TaskState.TS_Null
		self.big_pre:UpdateData()
		self.small_pre:UpdateData()
		self.tz_pre:UpdateData()
	end
	Event.Brocast("FishingTaskBigPrefab_ShowOrHide_Changed",{isShow = not (self.task_state == FishingTaskPanel.TaskState.TS_Null)})
end

function C:GetTZTaskIndex()
	local tz_task_index
	for k, v in pairs(self.children_task_map) do
		if v.task_type and v.task_type == "buyu_challenge_children_task" then
			tz_task_index = k
			break
		end
	end
	dump(tz_task_index, "<color=red>tz_task_index  </color>")
	return tz_task_index
end

function C:OnSmallClick()
	self.is_big_left = not self.is_big_left
	self:MyRefresh()
end

function C:call_update_data(data, is_force)
	dump(data, "<color=red>=====================call_update_data</color>")
	self.children_task_ids = {}
	self.children_task_map = {}

	self.tz_task_id = nil
	if data.children_tasks then
		for k,v in ipairs(data.children_tasks) do
			GameTaskModel.task_process_int_convent_string(v)
			self.children_task_map[v.id] = v
			if v.task_type == "buyu_challenge_children_task" then
				self.tz_task_id = v.id
			else
				self.children_task_ids[#self.children_task_ids + 1] = v.id
			end
		end
	end
	if not self.children_task_ids or #self.children_task_ids <= 0 then
		self.task_state = FishingTaskPanel.TaskState.TS_Null
	end
	if is_force then
		self.task_state = FishingTaskPanel.TaskState.TS_Nor
	end
	if self.tz_task_id then
		self.task_state = FishingTaskPanel.TaskState.TS_TZ
	end
	self:MyRefresh()
end

function C:on_query_response()
	self.task_state = FishingTaskPanel.TaskState.TS_Nor
	self:call_update_data(BYTaskManager.GetTaskData(), true)
end
function C:on_task_addOrdel_change()
	self:call_update_data(BYTaskManager.GetTaskData())
end
function C:on_task_change(data)
	if self.children_task_map[data.id] then
		dump(data, "<color=white>on_task_change</color>")
		self.children_task_map[data.id] = data
		-- 挑战任务完成瞬间
		if self.task_state == FishingTaskPanel.TaskState.TS_TZ and self.tz_task_id then
			local dd = self.children_task_map[ self.tz_task_id ]
			if dd and dd.now_process >= dd.need_process and dd.award_status == 1 then
				ExtendSoundManager.PlaySound(audio_config.by.bgm_by_tiaozhanrenwancheng.audio_name)
			end
		end
		self:MyRefresh()
	end
end

-- 挑战任务出现 出现的坐标
function C:AppearTZTask(parm)
	if parm.seat_num == 1 and self.panelSelf then
		ExtendSoundManager.PlaySound(audio_config.by.bgm_by_tiaozhanrenwuchuxian.audio_name)
		self.task_state = FishingTaskPanel.TaskState.TS_TZAnim
		local endPos = self.TaskRect.position
		FishingAnimManager.PlayTZTaskAppear(self.panelSelf.FlyGoldNode, parm.pos, endPos, function ()
			ExtendSoundManager.PlaySound(audio_config.by.bgm_by_tiaozhanrenxianshi.audio_name)
			self.task_state = FishingTaskPanel.TaskState.TS_TZAnimFinish
			self:MyRefresh()
		end)
	end
end
