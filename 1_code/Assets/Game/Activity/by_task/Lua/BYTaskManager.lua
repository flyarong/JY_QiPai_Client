-- 创建时间:2020-08-31
-- BYTaskManager 管理器

local basefunc = require "Game/Common/basefunc"
BYTaskManager = {}
local M = BYTaskManager
M.key = "by_task"
GameButtonManager.ExtLoadLua(M.key, "FishingTaskPanel")
GameButtonManager.ExtLoadLua(M.key, "FishingTaskSmallPrefab")
GameButtonManager.ExtLoadLua(M.key, "FishingTaskBigPrefab")
GameButtonManager.ExtLoadLua(M.key, "FishingTZTaskPrefab")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_buyu_daily_task"
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
function M.CheckIsShow()
    if not this.m_data.children_task_map or not next(this.m_data.children_task_map) then
        return false
    end
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "bytop_area" then
        return FishingTaskPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
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

    lister["fishing_ready_finish"] = this.on_fishing_ready_finish
    lister["query_fish_daily_children_tasks_response"] = this.on_query_response
    lister["fish_daily_children_tasks_change_msg"] = this.on_task_addOrdel_change
    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

	this = BYTaskManager
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
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryData(b)
    Network.SendRequest("query_fish_daily_children_tasks", {fish_game_id=FishingModel.game_id})
end

-- 
function M.on_fishing_ready_finish()
    M.QueryData()
end

function M.on_query_response(_, data)
    dump(data, "<color=red>query_fish_daily_children_tasks</color>")
    if data.result == 0 then
        this.m_data.children_task_map = this.m_data.children_task_map or {}
        for i,v in ipairs(data.children_tasks) do
            GameTaskModel.task_process_int_convent_string(v)
        end
        this.m_data.task_data = data
        for k,v in ipairs(data.children_tasks) do
            this.m_data.children_task_map[v.id] = v
        end
        Event.Brocast("model_query_fish_daily_children_tasks")
        Event.Brocast("ui_button_state_change_msg")
    end
end

function M.GetTaskData()
    return this.m_data.task_data
end

function M.on_task_addOrdel_change(_, data)
    this.m_data.children_task_map = this.m_data.children_task_map or {}
    for i,v in ipairs(data.children_tasks) do
        GameTaskModel.task_process_int_convent_string(v)
    end
    this.m_data.task_data = data
    for k,v in ipairs(data.children_tasks) do
        this.m_data.children_task_map[v.id] = v
    end
    Event.Brocast("model_fish_daily_children_tasks_change_msg")
    Event.Brocast("ui_button_state_change_msg")
end
function M.on_model_task_change_msg(data)
    if this.m_data.children_task_map and this.m_data.children_task_map[data.id] then
        dump(data, "<color=white>on_task_change</color>")
        this.m_data.children_task_map[data.id] = data
        Event.Brocast("by_task_model_task_change_msg", data)
    end
end