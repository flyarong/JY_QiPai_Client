-- 创建时间:2021-09-18
-- Act_068_XRHLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_068_XRHLManager = {}
local M = Act_068_XRHLManager
M.key = "act_068_xrhl"
GameButtonManager.ExtLoadLua(M.key, "Act_068_XRHLPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_068_XRHLTaskItem")
GameButtonManager.ExtLoadLua(M.key, "Act_068_XRHLEnter")
local config = GameButtonManager.ExtLoadLua(M.key, "act_068_xrhl_config")

local this
local lister

local act_day_num = 15      --活动显示15天
M.rules = {
    "1.累计赢金任务不统计苹果大战小游戏的数据",
    -- "2.街机捕鱼小游戏的累计赢金数据只统计一半",
    "2.街机打鱼小游戏的累计赢金数据只统计一半",
    "3.充值任务不统计游戏内带有“超值”标签的商品",
    "4.活动时间结束后，活动会自动消失，未领取的奖励视为自动放弃",
}

-- 是否有活动
function M.IsActive()
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    --活动不在时间内return
    if not M.IsActInTime() then
        return false 
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_new_player_gift"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
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
        dump(parm, "<color=red>不满足条件</color>")
        return
    end
    --10.12
    --关闭玩棋牌迎新红包
    --关闭彩云麻将福卡任务 
    if parm.goto_scene_parm == "enter" then
        return Act_068_XRHLEnter.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return Act_068_XRHLPanel.Create(parm.backcall)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsHint() then
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
    lister["hallpanel_created"] = this.on_hallpanel_created
end

function M.Init()
	M.Exit()

	this = Act_068_XRHLManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    M.InitConfig()
    M.InitData()
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.InitConfig()
    this.task_yj_cfg = {}
    this.task_cz_cfg = {}
    for i = 1, #config.task_yj do
        this.task_yj_cfg[#this.task_yj_cfg + 1] = config.task_yj[i]
    end
    for i = 1, #config.task_cz do
        this.task_cz_cfg[#this.task_cz_cfg + 1] = config.task_cz[i]
    end
end

function MakeNewStateData(task_total)
    local data = {}
    for i = 1, task_total do
        data[i] = 0
    end
    return data
end

function MakeNewData(task_lv, task_total)
    local data = {}
    if not task_lv then
        data.state = 0
    else
        data.state = MakeNewStateData(task_lv)
    end
    data.now_total_process = 0
    data.need_process = task_total or 0
    data.task_lv = task_lv
    return data
end

function AddStateData(task_id, task_lv)
    for i = this.taskData[task_id].task_lv, task_lv do
        this.taskData[task_id].state[i] = 0
    end
    this.taskData[task_id].task_lv = task_lv
end

function M.InitData()
    this.taskData = {}
    local checkAndMakeData = function(task_id, task_lv, task_total)
        if not this.taskData[task_id] then
            this.taskData[task_id] = MakeNewData(task_lv, task_total)
        elseif this.taskData[task_id].task_lv and this.taskData[task_id].task_lv < task_lv then
            AddStateData(task_id, task_lv)
        end
    end
    for i = 1, #this.task_yj_cfg do
        local task_id = this.task_yj_cfg[i].task_id
        local task_lv = this.task_yj_cfg[i].task_lv
        local task_total = this.task_yj_cfg[i].task_total
        checkAndMakeData(task_id, task_lv, task_total)
    end
    for i = 1, #this.task_cz_cfg do
        local task_id = this.task_cz_cfg[i].task_id
        local task_lv = this.task_cz_cfg[i].task_lv
        local task_total = this.task_cz_cfg[i].task_total
        checkAndMakeData(task_id, task_lv, task_total)
    end
    -- dump(this.taskData, "<color=white>XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX</color>")
    
end

function M.HandleTaskData(data)
    local curTaskId = data.id
    if not this.taskData[curTaskId] then
        return
    end
    if not this.taskData[curTaskId].task_lv then
        this.taskData[curTaskId].state = data.award_status
        this.taskData[curTaskId].need_process = data.need_process
    else
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, this.taskData[curTaskId].task_lv)
        this.taskData[curTaskId].state = b
    end
    this.taskData[curTaskId].now_total_process = data.now_total_process
    Event.Brocast("act_068_xrhl_task_change")
    M.SetHintState()
end

function M.on_model_query_task_data_response()
    local data = GameTaskModel.GetTaskDataByID()
    if data then
        for k,v in pairs(data) do
            M.HandleTaskData(v)
        end
    end
end

function M.on_model_task_change_msg(data)
    if data then
        M.HandleTaskData(data)
    end
end

function M.GetConfigFromPageIndex(index)
    if index == 1 then
        return M.SortYjCfg()
    elseif index == 2 then
        return M.SortCzCfg()
    end
end

function M.GetTaskData(task_id)
    if this.taskData[task_id] then
        return this.taskData[task_id]
    end
end

function M.IsActInTime()
    return os.time() <= M.GetActEndTime()
end

function M.GetActEndTime()
    local firstLoginTime = MainModel.FirstLoginTime()
    return firstLoginTime + 86400 * act_day_num
end

function M.IsHint()
    return M.IsHintCz() or M.IsHintYj()
end

function IsHintTaskTab(cfg)
    local checkedTask = {}
    local isHint = false
    for i = 1, #cfg do
        local task_id = cfg[i].task_id
        if this.taskData[task_id] and not checkedTask[task_id] then
            local task_lv = cfg[i].task_lv
            if task_lv then
                for j = 1, #this.taskData[task_id].state do
                    if this.taskData[task_id].state[j] == 1 then
                        return true
                    end
                end
            else
                if this.taskData[task_id].state == 1 then
                    return true
                end
            end
        end
        checkedTask[task_id] = 2
    end
end

function M.IsHintYj()
    return IsHintTaskTab(this.task_yj_cfg)
end

function M.IsHintCz()
    return IsHintTaskTab(this.task_cz_cfg)
end

local function SortCfg(cfg)
    local rCfg = basefunc.deepcopy(cfg)
    -- dump(rCfg, "<color=white> AAAAAAAAAAAAAAAAAAAAAAAAAAAA</color>")
	table.sort(rCfg, function(a, b)
        local stateA = M.GetTaskState(a.task_id, a.task_lv)
        local stateB = M.GetTaskState(b.task_id, b.task_lv)

        if stateA == 1 then
            stateA = -1
        end

        if stateB == 1 then
            stateB = -1
        end

        if stateA < stateB then
            return true
        elseif stateA > stateB then
            return false
        elseif a.index < b.index then
            return true
        elseif a.index > b.index then
            return false
        end
        return false
    end)
    return rCfg
end

function M.SortYjCfg()
    return SortCfg(this.task_yj_cfg)
end

function M.SortCzCfg()
    return SortCfg(this.task_cz_cfg)
end

function M.GetTaskState(task_id, task_lv)
    if this.taskData[task_id] then
        if not task_lv then
            return this.taskData[task_id].state
        else
            return this.taskData[task_id].state[task_lv]
        end
    end
    return 0
end

function M.on_hallpanel_created()
    if MainModel.lastmyLocation == "game_Free" or 
    MainModel.lastmyLocation == "game_MatchHall" or 
    MainModel.lastmyLocation == "game_MiniGame" then
        if M.IsActive() and M.IsHint() then
	        Act_068_XRHLPanel.Create()
        end
    end
end