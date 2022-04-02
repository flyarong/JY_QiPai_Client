-- 创建时间:2019-05-29
-- Panel:SYSXYJLManager
local basefunc = require "Game/Common/basefunc"

SYSXYJLManager = basefunc.class()
local M = SYSXYJLManager
M.key = "sys_xyjl"
GameButtonManager.ExtLoadLua(M.key, "AccurateTaskPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSXYJLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "XYJLShopManager")
GameButtonManager.ExtLoadLua(M.key, "TaskAwardPanel")
local config = GameButtonManager.ExtLoadLua(M.key, "task_accurate_config")
local m_config = {}

function M.CheckIsShow()
	local acc_task = M.GetAccurateTaskData() or XYJLShopManager.GetData()
	if not acc_task then
		return
	end
	return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return AccurateTaskPanel.Create(parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return SYSXYJLEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local lister
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
	-- lister["global_hint_state_set_msg"] = M.SetHintState
	lister["model_task_change_msg"] = M.model_task_item_change_msg
	lister["model_task_item_change_msg"] = M.model_task_item_change_msg
end

function M.model_task_item_change_msg(data)	
	-- self:CheckAccurateTask()
	-- self:CheckShowAccurateTaskPanel(data)
end

function M.GetConfig()
	return config
end

function M.Init()
	m_config = M.InitTaskAccurateCfg(config)
end

function M.Exit()
	
end

function M.InitTaskAccurateCfg(cfg)
    local m_cfg = {}
    m_cfg.task = {}
    for i,v in ipairs(cfg.task) do
        m_cfg.task[v.task_id] = v
    end
    m_cfg.award = {}
    for i,v in ipairs(cfg.award) do
        m_cfg.award[v.task_id] = m_cfg.award[v.task_id] or {}
        m_cfg.award[v.task_id][#m_cfg.award[v.task_id] + 1] = v
    end
    return m_cfg
end

function M.GetTaskAccurateCfg(id)
    local accurate_task = M.GetAccurateTaskData()
    if not accurate_task or not next(accurate_task) then
        return
    end
    if id and accurate_task[id] then
        return m_config.task[id]
    end
    local task_map = {}
    for k,v in pairs(accurate_task) do
        task_map[v.id] = m_config.task[v.id]
    end
    return task_map
end

function M.GetTaskAccurateAwardCfg(id)
    local accurate_task = M.GetAccurateTaskData()
    if not accurate_task or not next(accurate_task) then
        return
    end
    if id and accurate_task[id] then
        return m_config.award[id]
    end
    local task_map = {}
    for k,v in pairs(accurate_task) do
        task_map[v.id] = m_config.award[v.id]
    end
    return task_map
end

--检测是否有可领取的任务
function M.CheckTaskAccurateCanGet()
   local is_can_get_award = false
    local accurate_task = M.GetAccurateTaskData()
    if not accurate_task or not next(accurate_task) then
        return is_can_get_award
    end
    for k,v in pairs(accurate_task) do
        if is_can_get_award == false then
            is_can_get_award = v.award_status == 1
        else
            break
        end
    end
    return is_can_get_award
end

-- 请求任务数据
function M.GetAccurateTaskData()
    -- award_status  0-不能领取 | 1-可领取 | 2-已完成
    -- task_list = {
    --     [1] = {id=1, now_process=0, need_process=5, award_status=0},
    --     [2] = {id=2, now_process=5, need_process=5, award_status=1},
    --     [3] = {id=3, now_process=2, need_process=5, award_status=0},
    --     [4] = {id=4, now_process=5, need_process=5, award_status=1},
	-- }
	local task_list = GameTaskModel.GetTaskDataByID()
    if task_list then
        local acc = {}
        for k,v in pairs(task_list) do
            if v.task_type == "accurate_task" and v.start_valid_time < os.time() and (v.end_valid_time > os.time() or v.award_status == 1) then
                acc[v.id] = v
            end
        end
        if next(acc) then
            return acc
        end
    end
end
