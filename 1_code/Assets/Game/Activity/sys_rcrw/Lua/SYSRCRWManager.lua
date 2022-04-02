-- 创建时间:2021-04-06
-- SYSRCRWManager 管理器
local basefunc = require "Game/Common/basefunc"
SYSRCRWManager = {}
local M = SYSRCRWManager
M.key = "sys_rcrw"

local config = GameButtonManager.ExtLoadLua(M.key, "sys_rcrw_config")
GameButtonManager.ExtLoadLua(M.key, "RCRWPanel")

local this
local lister

local root_task_id = 21200

-- 是否有活动
function M.IsActive()
	-- 活动的开始与结束时间
	local e_time
	local s_time
	if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
		return false
	end

	-- 对应权限的key
	local _permission_key
	if _permission_key then
		local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = _permission_key, is_on_hint = true }, "CheckCondition")
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
		return RCRWPanel.Create(parm.parent)
	end

	dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
	for msg, cbk in pairs(lister) do
		Event.AddListener(msg, cbk)
	end
end

local function RemoveLister()
	if lister then
		for msg, cbk in pairs(lister) do
			Event.RemoveListener(msg, cbk)
		end
	end
	lister = nil
end
local function MakeLister()
	lister = {}
	lister["OnLoginResponse"] = this.OnLoginResponse
	lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
	lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
	lister["model_query_one_task_data_response"] = this.on_model_task_get_or_change
	lister["model_task_change_msg"] = this.on_model_task_get_or_change
end

function M.Init()
	M.Exit()

	this = SYSRCRWManager
	this.m_data = {}
	this.m_data.cur_task_id = nil
	this.m_data.cur_task_id = 21212
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

local function HandleError()
	HintPanel.Create(1,"Data Handle Error:" .. "sys_rcrw")
	dump(debug.traceback(), "<color=red>Data Handle Error</color>")
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

function M.on_model_task_get_or_change(data)
	if not data then
		return
	end

	if data.result ~= 0 then
		return
	end

	if data.id == M.root_task_id then
		local root_task_data = GameTaskModel.GetTaskDataByID(M.root_task_id)
		if not root_task_data or not root_task_data.other_data_str then
			HandleError()
			return
		end
		this.m_data.cur_task_id = root_task_data.other_data_str
		Event.Brocast("model_rcrw_task_change")
	end

	if this.m_data.cur_task_id and data.id == this.m_data.cur_task_id then
		Event.Brocast("model_rcrw_task_change")
	end
end

function M.GetCurTaskData()

	local data = {}
	data.cur_task_id = 21211
	data.now_total_process = 0
	data.need_process = 0
	return data
	
	-- local data = {}
	-- data.cur_task_id = this.m_data.cur_task_id
	-- local task_data = GameTaskModel.GetTaskDataByID(this.m_data.cur_task_id)
	-- if not task_data then
	-- 	HandleError()
	-- end
	-- data.now_total_process = task_data.now_total_process
	-- data.need_process = task_data.need_process
	-- return data
end

function M.GetCurTaskCfg()
	M.GetCfgToTaskId(this.m_data.cur_task_id)
end

function M.GetCfgToTaskId(_task_id)
	for i = 1, #config.Tasks do
		if config.Tasks[i].task_id == _task_id then
			return config.Tasks[i]
		end
	end
	HandleError()
end