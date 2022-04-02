local basefunc = require "Game/Common/basefunc"
Act_005YMFLHYZHManager = {}
local M = Act_005YMFLHYZHManager
M.key = "act_005_ymfl_hyzh"
M.config = GameButtonManager.ExtLoadLua(M.key, "act_005_ymfl_hyzh_config") 
GameButtonManager.ExtLoadLua(M.key, "Act_005YMFLHYZHPanel")
local lister
M.task_id = M.config.tge1[1].task

-- 是否有活动
function M.IsActive(cfg)
    -- 活动的开始与结束时间
    local e_time
    local s_time 

    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if table_is_null(M.children_list) then
        return       
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
    end

	return true
end

-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end

-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    dump("<color=yellow>****---------+++++++++++++/////////////</color>")
    if parm.goto_scene_parm == "panel" then
        return Act_005YMFLHYZHPanel.Create(parm.parent,parm.cfg)
    end 
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        for k,t_v in pairs(M.config.tge) do
            if M.config[t_v.tge] then
                for i,v in ipairs(M.config[t_v.tge]) do
                    if GameTaskModel.check_reward_state(v.task,v.level) then 
                        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
                    end 
                end
            end
        end
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end 
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
    lister["UpdateHallTaskRedHint"] = M.SetHintState
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
    lister["recall_children_query_recall_children_list_response"] = M.recall_children_query_recall_children_list_response
    lister["recall_children_recall_children_list_change_msg"] = M.recall_children_recall_children_list_change_msg
    lister["model_task_change_msg"] = M.on_model_task_change_msg
	lister["model_query_one_task_data_response"] = M.on_model_query_one_task_data_response
end

function M.Init()
	M.Exit()
	M.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end

function M.Exit()
	if M then
		RemoveLister()
	end
end

function M.InitUIConfig()
    M.UIConfig={
    }
end

function M.OnLoginResponse(result)
    if result == 0 then
        Network.SendRequest("recall_children_query_recall_children_list")
        Network.SendRequest("query_one_task_data",{task_id = M.task_id})
	end
end

function M.OnReConnecteServerSucceed()
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end

-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.recall_children_query_recall_children_list_response (_,data)
    dump(data,"<color=white>recall_children_query_recall_children_list</color>")
    if data.result ~= 0 then return end
    M.children_list = data.children_list
    Act_005YMFLHYZHPanel.Refresh()
end

function M.recall_children_recall_children_list_change_msg (_,data)
    dump(data,"<color=white>recall_children_recall_children_list_change_msg</color>")
    M.children_list = data.children_list
    Act_005YMFLHYZHPanel.Refresh()
end

function M.on_model_task_change_msg(data)
    --dump(data,"<color=white>on_model_task_change_msg</color>")
    if not data or data.id ~= M.task_id then return end
    M.task_data = data
    Act_005YMFLHYZHPanel.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.on_model_query_one_task_data_response(data)
    if not data or data.id ~= M.task_id then return end
    dump(data,"<color=white>on_model_query_one_task_data_response</color>")
    M.task_data = data
    Act_005YMFLHYZHPanel.Refresh()
end