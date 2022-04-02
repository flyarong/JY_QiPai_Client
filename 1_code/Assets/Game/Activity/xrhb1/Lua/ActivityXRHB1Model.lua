-- 创建时间:2018-12-12
local basefunc = require "Game.Common.basefunc"
local xrhb1_config = GameButtonManager.ExtLoadLua("xrhb1", "xrhb1_config")
ActivityXRHB1Model = {}
ActivityXRHB1Model.CanGetStatus = false
--激活礼包
ActivityXRHB1Model.xrhb1_jblb_id = 10166
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
	lister["stepstep_money_over_time_change_msg"] = this.stepstep_money_over_time_change_msg
end

-- 初始化Data
local function InitMatchData()
    ActivityXRHB1Model.data={
		day_to_task={},
		task={},
    }
    m_data = ActivityXRHB1Model.data
end

function ActivityXRHB1Model.Init()
    this = ActivityXRHB1Model
    InitMatchData()
    MakeLister()
    AddLister()
    ActivityXRHB1Model.InitUIConfig()
    ActivityXRHB1Model.ReqCurrTaskData()
    return this
end

function ActivityXRHB1Model.Exit()
    if this then
        RemoveLister()
		lister=nil
		m_data = nil
        this=nil
    end
end

function ActivityXRHB1Model.InitUIConfig()
	this.Config = {}
	local activity = {}
	local task_map = {}
	local task_to_vip_map = {}-- 任务ID对应vip等级

	local config = xrhb1_config.config
	for k,v in ipairs(config) do
		local da1 = basefunc.deepcopy(v)
		local da2 = {}
		for k1, v1 in ipairs(da1.task_list) do
			da2[#da2 + 1] = xrhb1_config.task_list[v1].task_group
		end
		da1.task_list = da2
		for k1,v1 in ipairs(da2) do
			for i=1,#v1 do
				task_to_vip_map[v1[i]] = v.id
			end
		end
		activity[#activity + 1] = da1
	end
	for k,v in ipairs(xrhb1_config.task) do
		task_map[v.task_id] = v
	end
	this.Config.activity = activity
	this.Config.task_map = task_map
	this.Config.task_to_vip_map = task_to_vip_map
end

-- 请求初始数据
function ActivityXRHB1Model.ReqCurrTaskData()
	Network.SendRequest("query_stepstep_money_data", nil, "请求数据")
end

function ActivityXRHB1Model.query_stepstep_money_data_response(_,data)
	dump(data, "<color=green>query_stepstep_money_data_response</color>")
	if data.result == 0 then
		m_data.now_big_step = data.now_big_step
		m_data.total_hongbao_num = data.total_hongbao_num
		m_data.now_get_hongbao_num = data.now_get_hongbao_num
		m_data.over_time = data.over_time or 0
		m_data.version = data.version
		ActivityXRHB1Model.InitUIConfig()
		local isCompleted = true
		local hasAward = false
		for _, t in pairs(data.step_tasks) do
			GameTaskModel.task_process_int_convent_string(t)
			if t.award_status ~= 1 and t.award_status ~= 2 then
				isCompleted = false
			elseif t.award_status == 1 then
				hasAward = true
			end
			m_data.task[t.id] = t
		end

		if hasAward then
			ActivityXRHB1Model.CanGetStatus = true
			Event.Brocast("global_hint_state_change_msg",{gotoui = ActivityXRHB1Logic.key})
			-- Event.Brocast("UpdateHallBBSCTaskRedHint")
		end
		
		if not ActivityXRHB1Model.forceShow and data.total_hongbao_num == data.now_get_hongbao_num then
			Event.Brocast("all_seven_day_task_completed")
		elseif not ActivityXRHB1Model.forceShow and isCompleted then
			Event.Brocast("model_task_finished")
		else
			ActivityXRHB1Model.query_stepstep_money_big_step_data_response("query_stepstep_money_data", data)
		end
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function ActivityXRHB1Model.query_stepstep_money_big_step_data_response(_,data)
	dump(data, "<color=green>query_stepstep_money_big_step_data_response</color>")
	if data.result == 0 then
		local day = 1
		if this.Config.task_to_vip_map and data.step_tasks and data.step_tasks[1] then
			day = this.Config.task_to_vip_map[data.step_tasks[1].id]
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
		Event.Brocast("global_hint_state_change_msg",{gotoui = ActivityXRHB1Logic.key})
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function ActivityXRHB1Model.stepstep_money_task_change_msg(_,data)
	dump(data, "<color=yellow>stepstep_money_task_change_msg</color>")
	GameTaskModel.task_process_int_convent_string(data.task_item)
	if (data.task_item.award_status == 1 or data.task_item.award_status == 2) and data.task_item.now_process ~= data.task_item.need_process then
		data.task_item.now_process = data.task_item.need_process
	end
	m_data.task[data.task_item.id] = data.task_item
	Event.Brocast("model_stepstep_money_task_change_msg", data.task_item.id)
	Event.Brocast("global_hint_state_change_msg",{gotoui = ActivityXRHB1Logic.key})
end

function ActivityXRHB1Model.stepstep_money_over_time_change_msg(_,data)
	dump(data, "<color=yellow>stepstep_money_over_time_change_msg</color>")
	m_data.over_time = data.over_time
	Event.Brocast("model_stepstep_money_over_time_change_msg", m_data.over_time)
end

function ActivityXRHB1Model.get_stepstep_money_task_award_response(_,data)
	dump(data, "<color=green>get_stepstep_money_task_award_response</color>")
	if data.result == 0 then
		m_data.now_get_hongbao_num = data.now_get_hongbao_num
		Event.Brocast("model_get_stepstep_money_task_award_response", m_data.now_get_hongbao_num)
	else
		HintPanel.ErrorMsg(data.result)
	end
end

function ActivityXRHB1Model.stepstep_money_task_big_step_open(_,data)
	dump(data, "<color=green>stepstep_money_task_big_step_open</color>")
	m_data.now_big_step = data.now_big_step
	data.result = 0
	ActivityXRHB1Model.query_stepstep_money_big_step_data_response("query_stepstep_money_data", data)
end

-- 活动配置
function ActivityXRHB1Model.GetActivity()
	return this.Config.activity
end

-- 任务数据
function ActivityXRHB1Model.GetTaskToID(id)
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

--检测是否有可领取的任务 -- 0-不能领取 | 1-可领取 | 2-已完成 | 3- 未启用
function ActivityXRHB1Model.CheckTaskCanGet()
	ActivityXRHB1Model.CanGetStatus = false
	for k,v in pairs(m_data.task) do
		if v.award_status == 1 then
			ActivityXRHB1Model.CanGetStatus = true
			break
		end
	end
    return ActivityXRHB1Model.CanGetStatus
end

function ActivityXRHB1Model.CheckActivityIsEnd()
	if not this then return false end
	if not ActivityXRHB1Model.data or not this.Config.activity then
		return false
	end
	local task_list = this.Config.activity[#this.Config.activity].task_list
	local task_table = task_list[#task_list]
	local task_id = task_table[#task_table]
	local sever_task = ActivityXRHB1Model.data.task[task_id]
	if sever_task then
		if sever_task.award_status and sever_task.award_status == 2 then
			return true
		end
	end
	return false
end

function ActivityXRHB1Model.IsNewVersion()
	local version = ""
	if m_data.version then
		version = m_data.version
	end
	return version == "new"
end

function ActivityXRHB1Model.IsOver()
	if not m_data or not this or not this.Config or not m_data.now_big_step or not this.Config.activity or #this.Config.activity < m_data.now_big_step then return true end
	if #this.Config.activity == m_data.now_big_step then
		for i,v1 in ipairs(this.Config.activity) do
			for i,v2 in ipairs(v1.task_list) do
				for i,v in ipairs(v2) do
					local sever_task = ActivityXRHB1Model.data.task[v]
					if sever_task then
						if sever_task.award_status and sever_task.award_status ~= 2 then
							return false
						end
					end
				end
			end
		end
		return true
	end
end

function ActivityXRHB1Model.IsShowVIPLevel()
	if not m_data or 
		not this or 
		not this.Config or 
		not m_data.now_big_step or 
		not this.Config.activity then 
		return true 
	end
	if #this.Config.activity == m_data.now_big_step then
		return false
	end
	return true
end

function ActivityXRHB1Model.GetJHLBStatus()
	local s = 1
	if m_data then
		if m_data.now_big_step == 1 then
			s = 1
		elseif m_data.now_big_step == 2 then
			local status = MainModel.GetGiftShopStatusByID(10166)
			if status == 1 then
				s = 2
			else
				s = 3
			end
		end
	end
	return s
end