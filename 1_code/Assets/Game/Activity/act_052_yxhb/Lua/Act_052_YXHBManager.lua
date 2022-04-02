-- 创建时间:2021-02-22
-- Act_052_YXHBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_052_YXHBManager = {}
local M = Act_052_YXHBManager
M.key = "act_052_yxhb"
local config = GameButtonManager.ExtLoadLua(M.key,"act_052_yxhb_config")
GameButtonManager.ExtLoadLua(M.key,"Act_052_YXHBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_052_YXHBPanel")

local this
local lister

local task_day_num = 7 
local act_day_num = 8

local exchange_item_key = "prop_new_player_red_bag"        --红包券

local cmp3day_task_id = 100017
local cmp7day_task_id = 100018

M.exchange_type = 30            
M.exchange_mrlb_id = 182        --明日礼包的兑换Id
local mrlb_task_id = 100001         --明日礼包的任务Id
local mrlb_task_lv = 2              --明日礼包的任务lv

--add_task_progress "105784",100001,20
--money "105784","prop_new_player_red_bag",1000
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if not M.IsActInTime() then
       return false 
    end

    -- 对应权限的key
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_own_task_p_new_player_red_bag", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true

end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        -- dump(parm, "<color=red>不满足条件</color>")
        return
    end

    if parm.goto_scene_parm == "enter" then
        return Act_052_YXHBEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Act_052_YXHBPanel.Create(parm.backcall)
    end

    -- dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.Hint() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg

    lister["query_activity_exchange_response"] = this.on_query_activity_exchange_response
    lister["query_box_exchange_info_response"] = this.on_query_box_exchange_info_response
    lister["get_task_award_response"] = this.on_get_task_award_response
    lister["get_task_award_new_response"] = this.on_get_task_award_new_response
    lister["activity_exchange_response"] = this.on_activity_exchange_response
    lister["box_exchange_response"] = this.on_box_exchange_response
    lister["AssetChange"] = this.on_asset_change
end

function M.Init()
	M.Exit()

	this = Act_052_YXHBManager
    this.m_data = {}
	MakeLister()
    AddLister()
    M.InitConfig()
    --M.UpdateTaskData()

    M.QueryActivityExchangeInfo()
    M.QueryBoxExchangeInfo()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitConfig()
    this.m_data.task_cfg = {}
    local temp_day
    for i = 1, task_day_num do
        temp_day = "day_" .. i
        this.m_data.task_cfg[i] = config[temp_day]
    end

    this.m_data.task_care_arr = {}
    for i = 1, task_day_num do
        local cur_day_task = this.m_data.task_cfg[i]
        for j = 1, #cur_day_task do
            local cur_task = cur_day_task[j]
            if cur_task.task_id and not this.m_data.task_care_arr[cur_task.task_id] then
                this.m_data.task_care_arr[cur_task.task_id] = 1
            end
        end
    end

    this.m_data.mrlb_exchanged = false
    this.m_data.exchange_data = {}
    if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."YXHB_MRLB_OPEN_TIME", 0) ~= 0 then
        this.m_data.mrlb_open_time = PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."YXHB_MRLB_OPEN_TIME")
    else
        if M.GetMrlbTaskStatus() == 2  then
            M.SetMrlbTime()
        else
            this.m_data.mrlb_open_time = 0
        end
    end

end

function M.UpdateTaskData()
    this.m_data.task_data = {}
    for i = 1, task_day_num do
        local temp_data = {}
        local cur_day_cfg = this.m_data.task_cfg[i]
        for j = 1, #cur_day_cfg do
            temp_data[j] = M.TransformData(cur_day_cfg[j])
        end
        this.m_data.task_data[i] = temp_data
    end
end

function M.UpdateCurTaskData()
    M.UpdateTaskData()
    local show_day = M.GetTaskShowDay()
    this.m_data.cur_task_data = {}
    for i = 1, show_day  do
        this.m_data.cur_task_data[i] = this.m_data.task_data[i]
    end
end

function M.GetActEndTime()
    local first_login_time = MainModel.FirstLoginTime()
    return first_login_time + 86400 * act_day_num
end

function M.GetMrlbOpenTime()
    return this.m_data.mrlb_open_time 
end

function M.GetCurDay()
    local first_login_time = MainModel.FirstLoginTime()
    local t1 = basefunc.get_today_id(first_login_time)
    local t2 = basefunc.get_today_id(os.time())
    local t = t2 - t1 + 1
    -- dump(t,"<color=red>当前迎新红包天数</color>")
    -- dump(first_login_time,"<color=red>首次登陆时间</color>")
    return  t < 1 and 1 or t
end

function M.GetTaskShowDay()
    local cur_day = M.GetCurDay()
    if cur_day >= task_day_num then
        return task_day_num
    else
        return cur_day + 1
    end
end

function M.GetTaskCfg()
    return this.m_data.task_cfg
end

function M.GetCurTaskData()
    M.UpdateCurTaskData()
    return this.m_data.cur_task_data
end

function M.GetItemNum()
    -- dump(MainModel.GetItemCount(exchange_item_key),"<color=red>红包劵数量</color>")
    return MainModel.GetItemCount(exchange_item_key) 
end

--兑换的状态：0 = 还未进行兑换 ，1 = 已经兑换2福卡还未兑换10福卡 ，2 = 已经兑换10福卡
function M.GetExchangeState()
    if #this.m_data.exchange_data > 1 then
        if this.m_data.exchange_data[1] > 0 then
            return 0
        elseif this.m_data.exchange_data[1] == 0 and this.m_data.exchange_data[2] > 0 then
            return 1
        elseif this.m_data.exchange_data[1] == 0 and this.m_data.exchange_data[2] == 0 then
            return 2
        end
    end
    return 0
end

--明日礼包的状态：0 = 还没有获得 ，1 = 已经获得(但是还未到时间不能打开) ，2 = 可以打开 ， 3 = 已经开启
function M.GetMrGiftState()
    if this.m_data.mrlb_exchanged then
        return 3
    end

    local status = M.GetMrlbTaskStatus()
    if status == 0 or status == 1 then
        return 0
    end
    -- dump(this.m_data.mrlb_open_time,"<color=white>mrlb_open_time</color>")
    -- dump(os.time(),"<color=white>os.time()</color>")

    if status == 2 and not this.m_data.mrlb_exchanged then
        if this.m_data.mrlb_open_time ~= 0 and os.time() > this.m_data.mrlb_open_time then
            return 2
        else
            return 1
        end
    end
end

function M.GetMrlbTaskStatus()
    local task_data = GameTaskModel.GetTaskDataByID(mrlb_task_id)
    if not task_data then
        return 0
    end
    local b = basefunc.decode_task_award_status(task_data.award_get_status)
    b = basefunc.decode_all_task_award_status(b, task_data, 5)
    return b[mrlb_task_lv]
end

function M.Hint()
    
    if not table_is_null(this.m_data.cur_task_data) then
        for i = 1, #this.m_data.cur_task_data do
            for j = 1, #this.m_data.cur_task_data[i] do
                if i <= M.GetCurDay() and this.m_data.cur_task_data[i][j].state == 1 then
                    return true
                end
            end 
        end
    end

    if M.GetMrGiftState() == 2 then
        return true
    end

    if M.GetItemNum() > 200 and M.GetExchangeState() == 0 and M.IsCmp3DayTask() then
        return true
    end

    if M.GetItemNum() > 1000 and M.GetExchangeState() == 1 and M.IsCmp7DayTask() then
        return true
    end

    return false
end

function M.TransformData(_data)
    local re_tab = {}
    local cur_task_id = _data.task_id
    local cur_task_lv
    if _data.task_lv then
        cur_task_lv = _data.task_lv
    end
    local _cur_task_data = GameTaskModel.GetTaskDataByID(cur_task_id)
    -- -- dump(cur_task_id,"<color=red>cur_task_id</color>")
    -- -- dump(_cur_task_data,"<color=red>99999999999999999999999999999999</color>")
    re_tab.state = 0
    re_tab.now_total_process = 0
    re_tab.need_process = 0
    if _cur_task_data then
        local b = basefunc.decode_task_award_status(_cur_task_data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, _cur_task_data, 6)
       
        if not cur_task_lv then
            re_tab.state = _cur_task_data.award_status
            re_tab.need_process = _cur_task_data.need_process
        else
            re_tab.state = b[cur_task_lv]
            re_tab.need_process = _data.total
        end
        re_tab.now_total_process = _cur_task_data.now_total_process    
    end
    return re_tab
end

function M.IsCareTask(task_id)
    return this.m_data.task_care_arr[task_id]
end

function M.IsCmp3DayTask()
    local task_data = GameTaskModel.GetTaskDataByID(cmp3day_task_id)
    -- dump(task_data,"<color=white>第三天任务的数据</color>")
    if task_data and task_data.award_status == 1 then
        return true
    end 
    return false
end

function M.IsCmp7DayTask()
    local task_data = GameTaskModel.GetTaskDataByID(cmp7day_task_id)
    if task_data and task_data.award_status == 1 then
        return true
    end 
    return false
end

function M.IsActInTime()
    return os.time() <= M.GetActEndTime()
end

function M.SetMrlbTime()
    local cDateCurrectTime = os.date("*t")
    local cDateTomorrowTime = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day + 1, hour=0,min=0,sec=0})
    this.m_data.mrlb_open_time = cDateTomorrowTime
    PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."YXHB_MRLB_OPEN_TIME",this.m_data.mrlb_open_time)
end


--兑现
function M.QueryActivityExchangeInfo()
    -- dump(M.exchange_type,"<color=white>M.exchange_type</color>")
    Network.SendRequest("query_activity_exchange",{type = M.exchange_type})
end

--明日礼包
function M.QueryBoxExchangeInfo()
    Network.SendRequest("query_box_exchange_info",{id = M.exchange_mrlb_id})
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_model_query_task_data_response()
    local data = GameTaskModel.GetTaskDataByID()
    -- dump(data,"<color=red>+++++on_model_query_task_data_response+++++</color>")
    if data then
        for k,v in pairs(data) do
            if M.HandleTaskData(v) then
                break
            end
        end
    end
end

function M.on_model_task_change_msg(data)
    -- dump(data,"<color=white>+++++++on_model_task_change_msg+++++++</color>")
    if data then
        M.HandleTaskData(data)
    end
end

function M.on_query_activity_exchange_response(_,data)
    -- dump(data,"<color>+++++++on_query_activity_exchange_response++++++</color>")
    if data and data.result == 0 and data.type == M.exchange_type then
        this.m_data.exchange_data = data.exchange_data
        Event.Brocast("model_yxhb_exchange_refresh")
    end
end

function M.on_query_box_exchange_info_response(_,data)
    -- dump(data,"<color>+++++++on_query_box_exchange_info_response++++++</color>")
    if data and data.result == 0 and data.id == M.exchange_mrlb_id then
        this.m_data.mrlb_exchanged = data.exchange_count > 0
        Event.Brocast("model_yxhb_mrlb_refresh")
    end
end

function M.on_box_exchange_response(_,data)
    -- dump(data,"<color>+++++++on_box_exchange_response++++++</color>")
    if data and data.result == 0 and data.id == M.exchange_mrlb_id then
        M.QueryBoxExchangeInfo()
    end
end

function M.on_get_task_award_new_response(_,data)
    -- dump(data,"<color>+++++++on_get_task_award_new_response++++++</color>")
    if data and data.id then
        if data.id == mrlb_task_id then
            M.SetMrlbTime()
            M.QueryBoxExchangeInfo()
        end
        M.HandleTaskData(data)
    end
end

function M.on_get_task_award_response(_,data)
    -- dump(data,"<color>+++++++on_get_task_award_response++++++</color>")
    if data and data.id then
        M.HandleTaskData(data)
    end
end

function M.on_activity_exchange_response(_,data)
    -- dump(data,"<color>+++++++on_activity_exchange_response++++++</color>")
    if data and data.result == 0 and data.type == M.exchange_type then
        M.QueryActivityExchangeInfo()
    end
end

function M.on_asset_change(data)
	-- dump(data,"<color=white>+++++on_asset_change+++++</color>")
	if data and data.change_type and data.change_type == "box_exchange_active_award_" .. M.exchange_mrlb_id then
		if table_is_null(data.data) then
			return 
		end
        Event.Brocast("AssetGet", data)
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
	end

    if data and data.change_type and data.change_type == ASSET_CHANGE_TYPE.TASK_P_NEW_PLAYER_RED_BAG then
        if table_is_null(data.data) then
			return 
		end
        for i = 1, #data.data do
            if data.data[i].asset_type == exchange_item_key then
                data.data[i].value = data.data[i].value / 100
            end
        end
        -- dump(data,"<color=white>+++++on_asset_change22222+++++</color>")
        Event.Brocast("model_yxhb_get_task_award", data)
    end
end

function M.HandleTaskData(_data)
    if M.IsCareTask(_data.id) then
        M.UpdateCurTaskData()
        Event.Brocast("model_yxhb_task_refresh")
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })

        M.SetHintState()
        return true
    end
    return false
end