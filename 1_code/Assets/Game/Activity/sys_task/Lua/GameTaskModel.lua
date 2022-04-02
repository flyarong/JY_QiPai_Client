-- 创建时间:2018-11-06
local basefunc = require "Game/Common/basefunc"
local task_config = SysTaskManager.task_config
GameTaskModel = {}
local M = GameTaskModel
GameTaskModel.TaskType = {
    game = "game",
    vip = "vip",
    day = "day"
}

GameTaskModel.ChangeStatus = {
    game = 0,
    vip = 0,
    day = 0
}

GameTaskModel.CanGetStatus = {
    game = false,
    vip = false,
    day = false
}

local this
local m_data
local lister
local function MakeLister()
    lister = {}
    lister["query_task_data_response"] = this.on_task_req_data_response
    lister["task_data_init_msg"] = this.on_task_data_init_msg

    lister["get_task_award_response"] = this.on_get_task_award_response
    lister["get_duiju_hongbao_upper_limit_response"] = this.on_get_duiju_hongbao_upper_limit_response
    lister["query_one_task_data_response"] = this.on_one_task_data_response

    lister["task_change_msg"] = this.on_task_change_msg
    lister["HallModelInitFinsh"] = this.HallModelInitFinsh

    lister["task_item_change_msg"] = this.task_item_change_msg
end
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end
local function RemoveLister()
    if lister == nil then return end
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function InitData()
	GameTaskModel.data={
    }
    Network.SendRequest("query_task_data", nil)
    print("<color=red>任务初始化</color>")
	m_data = GameTaskModel.data
end
function GameTaskModel.Init()
    this=GameTaskModel
    this.InitUIConfig()
    
    InitData()
    MakeLister()
    AddLister()

    -- this.ReqTaskData()
    return this
end
function GameTaskModel.Exit()
    if this then
        RemoveLister()
        m_data=nil
        this=nil
    end
end

function GameTaskModel.InitUIConfig()
    this.task_config = {
        task_tge = {},
        game = {},
        vip = {},
    }
    this.task_map = {}
    local task_tge = this.task_config.task_tge
    local game = this.task_config.game
    local vip = this.task_config.vip

    for _, v in ipairs(task_config.task_tge) do
        task_tge[v.id] = task_tge[v.id] or {}
        task_tge[v.id] = v
    end
    for _, v in ipairs(task_config.game) do
        game[v.task_id] = game[v.task_id] or {}
        game[v.task_id] = v
        this.task_map[v.task_id] = v
    end
    for _, v in ipairs(task_config.vip) do
        vip[v.task_id] = vip[v.task_id] or {}
        vip[v.task_id] = v
        this.task_map[v.task_id] = v
    end
end

-- 请求任务数据
function GameTaskModel.ReqTaskData()
    -- award_status  0-不能领取 | 1-可领取 | 2-已完成
    -- m_data.task_list = {
    --     [1] = {id=1, now_process=0, need_process=5, award_status=0},
    --     [2] = {id=2, now_process=5, need_process=5, award_status=1},
    --     [3] = {id=3, now_process=2, need_process=5, award_status=0},
    --     [4] = {id=4, now_process=5, need_process=5, award_status=1},
    -- }
    if m_data and m_data.task_list then
        Event.Brocast("model_query_task_data_response")
    else
        Network.SendRequest("query_task_data", nil)
    end
end

-- 获取任务数据
function GameTaskModel.GetConfigDataByType(type)
    if not type then
        return this.task_config
    else
        return this.task_config[type]
    end
end

-- 获取任务数据
function GameTaskModel.GetConfigDataToID(id)
    return this.task_map[id]
end

-- 获取任务数据
function GameTaskModel.GetTaskDataByID(id)
    if id then
        if m_data and m_data.task_list and next(m_data.task_list) then
            return m_data.task_list[id]
        end
    else
        if m_data then
            return m_data.task_list
        end
    end
end

--完成但领取奖励的任务
function GameTaskModel.GetFinishTaskDataToType()
    local task_data = GameTaskModel.GetTaskDataByID()
    local finish_data
    for i,v in ipairs(task_data) do
        if v.award_status == 1 then
            finish_data = finish_data or {}
            finish_data[#finish_data + 1] = v
        end
    end
    return finish_data
end

function GameTaskModel.on_task_req_data_response(_, data)
    dump(data, "<color=yellow>任务数据</color>")
    if data.result == 0 then
        
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameTaskModel.on_task_data_init_msg(_,data)
    dump(data,"<color=red>任务+++++++++++++++++++++++++++++++++++++++++++++++++++++++</color>")
    m_data.task_list = m_data.task_list or {}
        for k,v in ipairs(data.task_item or {}) do
        GameTaskModel.task_process_int_convent_string(v)
        m_data.task_list[v.id] = v
    end
    Event.Brocast("model_query_task_data_response")
    GameTaskModel.ChangeTaskCanGetRedHint()
end



function GameTaskModel.on_get_task_award_response(_, data)
    dump(data, "<color=yellow>领取任务奖励</color>")
    if data.result == 0 then
        -- m_data.task_list[data.id].award_status = 2
        Event.Brocast("model_get_task_award_response",data)
    elseif data.result == 3802 then
        --领取达到上限
        HintPanel.Create(1,string.format( "今日已领满%s福卡，请明日再来",StringHelper.ToRedNum(m_data.hb_data.real_upper_limit / 100)))
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameTaskModel.on_one_task_data_response(_, data)
    dump(data, "<color=yellow>单个任务获取</color>")
    if data.result == 0 then
        if data.task_data then
            GameTaskModel.task_process_int_convent_string(data.task_data)
            m_data.task_list = m_data.task_list or {}
            m_data.task_list[data.task_data.id] = data.task_data
            GameTaskModel.ChangeTaskCanGetRedHint()
            Event.Brocast("model_query_one_task_data_response", data.task_data)
            Event.Brocast("model_query_one_task_data_response_proto_name","model_query_one_task_data_response_proto_name", data.task_data)
	    end
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameTaskModel.on_task_change_msg(_, data)
    -- dump(data, "<color=yellow>任务进度改变</color>")
    m_data.task_list = m_data.task_list or {}
    m_data.task_list[data.task_item.id] = data.task_item
    GameTaskModel.task_process_int_convent_string( data.task_item)
    local task_id = data.task_item.id
    local config = GameTaskModel.GetConfigDataToID(task_id)
    --任务进度改变红点
    -- GameTaskModel.ChangeModelChangeStatus(config.task_type,task_id)
    --任务可领取才改变红点
    GameTaskModel.ChangeTaskCanGetRedHint()

    Event.Brocast("model_task_change_msg",data.task_item)
    Event.Brocast("model_task_finish_msg")
    Event.Brocast("model_task_change_msg_proto_name","model_task_change_msg_proto_name",data.task_item)
end

function GameTaskModel.task_item_change_msg(_, data)
    dump(data, "<color=yellow>任务改变</color>")
    if not data or not data.task_item or not next(data.task_item) then return end
    for k,v in pairs(data.task_item) do
        GameTaskModel.task_process_int_convent_string(v)
        if v.change_type == "add" then
            Network.SendRequest("query_one_task_data", {task_id = v.task_id})
        elseif v.change_type == "delete" then
            if  m_data.task_list then
                m_data.task_list[v.task_id] = nil
            end
        end
    end
    Event.Brocast("model_task_item_change_msg",data)
end

function GameTaskModel.InitTaskRedHint()
    GameTaskModel.ChangeStatus.game = PlayerPrefs.GetInt("task_game", 0)
    GameTaskModel.ChangeStatus.vip = PlayerPrefs.GetInt("task_vip", 0)
    GameTaskModel.ChangeStatus.day = PlayerPrefs.GetInt("task_day", 0)
    Event.Brocast("UpdateHallTaskRedHint")
end

function GameTaskModel.ChangeModelChangeStatus(type, task_id)
    if type == GameTaskModel.TaskType.game then
        GameTaskModel.ChangeStatus.game = task_id
    elseif type == GameTaskModel.TaskType.vip then
        GameTaskModel.ChangeStatus.vip = task_id
    elseif type == GameTaskModel.TaskType.day then
        GameTaskModel.ChangeStatus.vip = task_id
    end
    Event.Brocast("UpdateHallTaskRedHint")
end

function GameTaskModel.ChangeTaskCanGetRedHint()
    -- dump(GameTaskModel.CanGetStatus, "<color=white>ChangeTaskCanGetRedHint</color>")
    if GameGlobalOnOff.Task == true then
        GameTaskModel.CheckTaskCanGet()
    end
    Event.Brocast("UpdateHallTaskRedHint")
end

--检测是否有可领取的任务
function GameTaskModel.CheckTaskCanGet()
    GameTaskModel.CanGetStatus.game, GameTaskModel.CanGetStatus.vip, GameTaskModel.CanGetStatus.day = false , false, false
    if m_data.task_list then
        for k,v in pairs(m_data.task_list) do
            local config = GameTaskModel.GetConfigDataToID(v.id)
            if GameTaskModel.CanGetStatus.game == false then
                GameTaskModel.CanGetStatus.game = v.award_status == 1 and config.task_type == GameTaskModel.TaskType.game
            end
            if GameTaskModel.CanGetStatus.vip == false then
                GameTaskModel.CanGetStatus.vip = v.award_status == 1 and config.task_type == GameTaskModel.TaskType.vip
            end
            if GameTaskModel.CanGetStatus.day == false then
                GameTaskModel.CanGetStatus.day = v.award_status == 1 and config.task_type == GameTaskModel.TaskType.day
            end
        end
    end
    return GameTaskModel.CanGetStatus.game, GameTaskModel.CanGetStatus.vip, GameTaskModel.CanGetStatus.day
end

-- 请求每日福卡数据
function GameTaskModel.ReqHBData()
    print("<color=green>请求每日福卡数据</color>")
    Network.SendRequest("get_duiju_hongbao_upper_limit",nil)
end

function GameTaskModel.on_get_duiju_hongbao_upper_limit_response(_, data)
    if data.result == 0 then
        m_data.hb_data = m_data.hb_data or {}
        m_data.hb_data = data
        Event.Brocast("model_get_duiju_hongbao_upper_limit_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GameTaskModel.HallModelInitFinsh()
    GameTaskModel.ChangeTaskCanGetRedHint()
end

--检查奖励状态
function GameTaskModel.check_reward_state(task_id,count)
	local task_data = GameTaskModel.GetTaskDataByID(task_id)
	if not task_data then return false end

	local award_status_all = basefunc.decode_task_award_status(task_data.award_get_status)
	award_status_all = basefunc.decode_all_task_award_status(award_status_all, task_data, count)
	for i = 1, #award_status_all, 1 do
		if award_status_all[i] == 1 then return true end
	end
	return false
end

function GameTaskModel.task_process_int_convent_string(task_item)
    if task_item then
        if task_item.task_condition_type and 
            task_item.task_condition_type == "charge_any" or
            task_item.task_condition_type == "freestyle_settle_exchange_hongbao" or 
            task_item.task_condition_type == "pre_charge_any" then
            if task_item.now_total_process then
                if not task_item.m_now_total_process then
                    task_item.now_total_process = tonumber(task_item.now_total_process) / 100
                    task_item.m_now_total_process = task_item.now_total_process
                end
            end
            if task_item.now_process then
                if not task_item.m_now_process then
                    task_item.now_process = tonumber(task_item.now_process) / 100
                    task_item.m_now_process = task_item.now_process
                end
            end
            if task_item.need_process then
                if not task_item.m_need_process then
                    task_item.need_process = tonumber(task_item.need_process) / 100
                    task_item.m_need_process = task_item.need_process
                end
            end
        else
            if task_item.now_total_process then
                task_item.now_total_process = tonumber(task_item.now_total_process)
            end
            if task_item.now_process then
                task_item.now_process = tonumber(task_item.now_process)
            end
            if task_item.need_process then
                task_item.need_process = tonumber(task_item.need_process)
            end
        end
        if task_item.end_valid_time then
            task_item.end_valid_time = tonumber(task_item.end_valid_time)
        end
        if task_item.over_time then
            task_item.over_time = tonumber(task_item.over_time)
        end
        if task_item.start_valid_time then
            task_item.start_valid_time = tonumber(task_item.start_valid_time)
        end
    end
end

function M.GetAllTaskAwardStatus(task_id,count)
   if not task_id or not count then return end 
   local td = M.GetTaskDataByID(task_id)
   if table_is_null(td) then return end
   local all_task_award_status = basefunc.decode_task_award_status(td.award_get_status)
   all_task_award_status = basefunc.decode_all_task_award_status(all_task_award_status, td, count)
   return all_task_award_status
end