-- 创建时间:2018-12-12
local basefunc = require "Game.Common.basefunc"

local bbsc_config = ActivitySevenDayLogic.config

ActivitySevenDayModel = {}

ActivitySevenDayModel.CanGetStatus = false

local this
local m_data
local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
    lister["query_stepstep_money_data_response"] = this.query_stepstep_money_data_response
    lister["query_stepstep_money_big_step_data_response"] = this.query_stepstep_money_big_step_data_response
    lister["get_stepstep_money_task_award_response"] = this.get_stepstep_money_task_award_response
	lister["stepstep_money_task_change_msg"] = this.stepstep_money_task_change_msg
	lister["stepstep_money_task_big_step_open"] = this.stepstep_money_task_big_step_open
	lister["HallModelInitFinsh"] = this.HallModelInitFinsh
end

-- 初始化Data
local function InitMatchData()
    ActivitySevenDayModel.data={
		day_to_task={},
		task={},
    }
    m_data = ActivitySevenDayModel.data
end

function ActivitySevenDayModel.Init()
	--屏蔽步步生才
    if not GameGlobalOnOff.BBSC_Task then
        return
    end
    this = ActivitySevenDayModel
    InitMatchData()
    MakeLister()
    AddLister()
    ActivitySevenDayModel.InitUIConfig()
    ActivitySevenDayModel.ReqCurrTaskData()
    return this
end
function ActivitySevenDayModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end
function ActivitySevenDayModel.InitUIConfig()
	this.Config = {}
	local activity = {}
	local task_map = {}
	local task_to_day_map = {}-- 任务ID对应日期(天)

	local config = bbsc_config.config
	if this.IsNewVersion() then
		config = bbsc_config.config_new
	end
	for k,v in ipairs(config) do
		local da1 = basefunc.deepcopy(v)
		local da2 = {}
		for k1, v1 in ipairs(da1.task_list) do
			da2[#da2 + 1] = bbsc_config.task_list[v1].task_group
		end
		da1.task_list = da2
		for k1,v1 in ipairs(da2) do
			for i=1,#v1 do
				task_to_day_map[v1[i]] = v.day
			end
		end
		activity[#activity + 1] = da1
	end
	for k,v in ipairs(bbsc_config.task) do
		task_map[v.task_id] = v
	end
	this.Config.activity = activity
	this.Config.task_map = task_map
	this.Config.task_to_day_map = task_to_day_map
end

-- 请求初始数据
function ActivitySevenDayModel.ReqCurrTaskData()
	Network.SendRequest("query_stepstep_money_data", nil, "请求数据")
end

function ActivitySevenDayModel.query_stepstep_money_data_response(_,data)
	dump(data, "<color=green>query_stepstep_money_data_response</color>")
	if data.result == 0 then
		m_data.now_big_step = data.now_big_step
		m_data.total_hongbao_num = data.total_hongbao_num
		m_data.now_get_hongbao_num = data.now_get_hongbao_num
		m_data.over_time = data.over_time or 0
		m_data.version = data.version

		ActivitySevenDayModel.InitUIConfig()
		if this.IsNewVersion() then
			local TASK_ID = 61
			Network.SendRequest("query_one_task_data", {task_id = TASK_ID})
		end

		local isCompleted = true
		local hasAward = false
		for _, t in pairs(data.step_tasks) do
			GameTaskModel.task_process_int_convent_string(t)
			if t.award_status ~= 1 and t.award_status ~= 2 then
				isCompleted = false
			elseif t.award_status == 1 then
				hasAward = true
			end
		end

		if hasAward then
			ActivitySevenDayModel.CanGetStatus = true
			Event.Brocast("UpdateHallBBSCTaskRedHint")
		end
		
		if not ActivitySevenDayModel.forceShow and data.total_hongbao_num == data.now_get_hongbao_num then
			Event.Brocast("all_seven_day_task_completed")
		elseif not ActivitySevenDayModel.forceShow and isCompleted then
			Event.Brocast("model_task_finished")
		else
			ActivitySevenDayModel.query_stepstep_money_big_step_data_response("query_stepstep_money_data", data)
		end

		m_data.countdown_time = m_data.over_time - os.time()
		if m_data.countdown_time < 0 then m_data.countdown_time = 0 end

		--test
		--m_data.version = "new"
		--m_data.countdown_time = 20

	else
		HintPanel.ErrorMsg(data.result)
	end
end

-- 请求对应日期的任务数据
function ActivitySevenDayModel.ReqTaskByDay(day, isforce)
	if isforce then
		Network.SendRequest("query_stepstep_money_big_step_data", {big_step=day}, "请求数据")
	else
		if m_data.day_to_task[day] then
			Event.Brocast("model_query_stepstep_money_big_step_data", day)
		else
			Network.SendRequest("query_stepstep_money_big_step_data", {big_step=day}, "请求数据")			
		end
	end
end
function ActivitySevenDayModel.query_stepstep_money_big_step_data_response(_,data)
	dump(data, "<color=green>query_stepstep_money_big_step_data_response</color>")
	if data.result == 0 then
		local day = 1
		if this.Config.task_to_day_map and data.step_tasks and data.step_tasks[1] then
			day = this.Config.task_to_day_map[data.step_tasks[1].id]
		end
		m_data.day_to_task = m_data.day_to_task or {}
		day = day or 1
		m_data.day_to_task[day] = 1
		for k,v in ipairs(data.step_tasks) do
			GameTaskModel.task_process_int_convent_string(v)
			if (v.award_status == 1 or v.award_status == 2) and v.now_process ~= v.need_process then
				v.now_process = v.need_process
			end
			m_data.task[v.id] = v
		end
		Event.Brocast("model_query_stepstep_money_big_step_data", day)
		ActivitySevenDayModel.ChangeTaskCanGetRedHint()
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function ActivitySevenDayModel.stepstep_money_task_change_msg(_,data)
	dump(data, "<color=yellow>stepstep_money_task_change_msg</color>")
	GameTaskModel.task_process_int_convent_string(data.task_item)
	if (data.task_item.award_status == 1 or data.task_item.award_status == 2) and data.task_item.now_process ~= data.task_item.need_process then
		data.task_item.now_process = data.task_item.need_process
	end
	m_data.task[data.task_item.id] = data.task_item
	Event.Brocast("model_stepstep_money_task_change_msg", data.task_item.id)
	--任务可领取才改变红点
    ActivitySevenDayModel.ChangeTaskCanGetRedHint()
end

function ActivitySevenDayModel.stepstep_money_task_big_step_open(_,data)
	dump(data, "<color=green>stepstep_money_task_big_step_open</color>")
	m_data.now_big_step = data.now_big_step
	data.result = 0
	ActivitySevenDayModel.query_stepstep_money_big_step_data_response("query_stepstep_money_data", data)
end

function ActivitySevenDayModel.get_stepstep_money_task_award_response(_,data)
	dump(data, "<color=green>get_stepstep_money_task_award_response</color>")
	if data.result == 0 then
		m_data.now_get_hongbao_num = data.now_get_hongbao_num
		Event.Brocast("model_get_stepstep_money_task_award_response", m_data.now_get_hongbao_num)
	else
		HintPanel.ErrorMsg(data.result)
	end
end

-- 活动配置
function ActivitySevenDayModel.GetActivity()
	if this then
		return this.Config.activity
	end
end

-- 任务数据
function ActivitySevenDayModel.GetTaskToID(id)
	local data = basefunc.deepcopy(this.Config.task_map[id])
	local task = m_data.task[id]
	if task then
		data.now_process = task.now_process
		data.need_process = task.need_process
		data.award_status = task.award_status
		return data
	else
		return nil
	end
end

-- 0-不能领取 | 1-可领取 | 2-已完成 | 3- 未启用
-- 新手引导 获取第一个新人福卡的状态
function ActivitySevenDayModel.GetOneStepStart()
	--屏蔽步步生才
    if not GameGlobalOnOff.BBSC_Task then
        return 3
    end
    if not this then
    	return 0
    end
	local id = this.Config.activity[1].task_list[1][1]
	if m_data.task[id] then
		return m_data.task[id].award_status
	else
		if MainModel.UserInfo.step_task_status then
			return MainModel.UserInfo.step_task_status[1]
		else
			return 2
		end
	end
end
-- 新手引导 获取第二个新人福卡的状态
function ActivitySevenDayModel.GetTwoStepStart()
	--屏蔽步步生才
    if not GameGlobalOnOff.BBSC_Task then
        return 3
    end
    if not this then
    	return 0
    end
	local id = this.Config.activity[1].task_list[2][1]
	if m_data.task[id] then
		return m_data.task[id].award_status
	else
		if MainModel.UserInfo.step_task_status then
			return MainModel.UserInfo.step_task_status[2]
		end
		return 2
	end
end

function ActivitySevenDayModel.ChangeTaskCanGetRedHint()
    if GameGlobalOnOff.BBSC_Task == true then
		ActivitySevenDayModel.CheckTaskCanGet()
        Event.Brocast("UpdateHallBBSCTaskRedHint")
    end
end

--检测是否有可领取的任务
function ActivitySevenDayModel.CheckTaskCanGet()
	ActivitySevenDayModel.CanGetStatus = false
	for k,v in pairs(m_data.task) do
		if v.award_status == 1 then
			ActivitySevenDayModel.CanGetStatus = true
			break
		end
	end
    return ActivitySevenDayModel.CanGetStatus
end

function ActivitySevenDayModel.HallModelInitFinsh()
    ActivitySevenDayModel.ChangeTaskCanGetRedHint()
end

function ActivitySevenDayModel.CheckActivityIsEnd()
	dump(ActivitySevenDayModel.data, "<color=green>新人福卡数据</color>")
	if not this then return false end
	dump(this.Config.activity, "<color=green>新人福卡配置</color>")
	if not ActivitySevenDayModel.data or not this.Config.activity then
		return false
	end
	local task_list = this.Config.activity[#this.Config.activity].task_list
	local task_table = task_list[#task_list]
	local task_id = task_table[#task_table]
	local sever_task = ActivitySevenDayModel.data.task[task_id]
	if sever_task then
		if sever_task.award_status and sever_task.award_status == 2 then
			return true
		end
	end
	if MainModel.UserInfo.bbsc_over_time and MainModel.UserInfo.bbsc_over_time < os.time() then
		return true
	end
	return false
end

function ActivitySevenDayModel.GetCountdownTime()
	return m_data.countdown_time or -1
end

function ActivitySevenDayModel.SetCountdownTime(v)
	m_data.countdown_time = v
end

function ActivitySevenDayModel.IsNewVersion()
	local version = ""
	if m_data.version then
		version = m_data.version
	end
	return version == "new"
end
