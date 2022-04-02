-- 创建时间:2021-06-01
-- Act_058_JRLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_058_JRLBManager = {}
local M = Act_058_JRLBManager
M.key = "act_058_jrlb"
GameButtonManager.ExtLoadLua(M.key, "Act_058_JRLBPanel")
local config = GameButtonManager.ExtLoadLua(M.key, "act_058_jrlb_config") 
local this
local lister

M.mrlb_task = 21856

M.endTime = 1632153599
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.endTime
    local s_time = 1630971000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if this.m_data.cur_lv == 0 then
        return false
    end

    -- 对应权限的key
    local _permission_key
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
    if parm.goto_scene_parm == "panel" then
        return Act_058_JRLBPanel.Create(parm.parent)
    end
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
end

function M.Init()
	M.Exit()

	this = Act_058_JRLBManager
	this.m_data = {}
    this.m_data.cur_lv = 0
	MakeLister()
    AddLister()
    M.InitConfig()
	M.InitUIConfig()
end

local function UpdateCurLv()
    local check_func = function(_permission_key)
        local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = _permission_key, is_on_hint = true }, "CheckCondition")
        if a and b then
            return true
        end
    end
    for i = 1, #config do
        if check_func(config[i].permission) then
            this.m_data.cur_lv = i
        end
    end
end

function M.IsHint()
    local taskData = GameTaskModel.GetTaskDataByID(M.mrlb_task)
    if taskData then
        return taskData.award_status == 1
    end
end

function M.InitConfig()
    UpdateCurLv()
end

function M.GetCurCfg()
    return config[this.m_data.cur_lv]
end

function M.GetLv()
    return this.m_data.cur_lv
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

function M.on_model_query_task_data_response()
    -- dump("<color=white>JJJJJJJRLB+++111++++on_model_query_task_data_response+++++++</color>")
    local data = GameTaskModel.GetTaskDataByID()
    if data then
        for k,v in pairs(data) do
            if data.id == M.mrlb_task then
                Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
            end
        end
    end
end

function M.on_model_task_change_msg(data)
    if data.id == M.mrlb_task then
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    end
end