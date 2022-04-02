local basefunc = require "Game/Common/basefunc"

Act_004FKYZDCZManager = basefunc.class()
local M = Act_004FKYZDCZManager
M.key = "act_004_fkyzd_cz"
local config = GameButtonManager.ExtLoadLua(M.key, "act_004_fkyzd_cz_config")
local lister
local function MakeLister()
    lister = {}
    lister["UpdateHallTaskRedHint"] = M.SetHintState
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
end

function M.IsActive(cfg)
    if cfg then
        if not cfg.is_on_off or cfg.is_on_off == 0 then
            return false
        end
    end
    
    -- 活动的开始与结束时间
    local e_time
    local s_time
    
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_crazy_atomic_bomb"
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
    return M.IsActive(cfg)
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

function M.GotoUI(parm)
	dump(parm)
    if parm.goto_scene_parm == "enter" then
        return ActivityTaskPanel.Create(parm.parent,parm.cfg,nil, config)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.CheakStatus()
    for k,t_v in pairs(config.tge) do
        if config[t_v.tge] then
            for i,v in ipairs(config[t_v.tge]) do
                if GameTaskModel.check_reward_state(v.task,v.level) then 
                    GameActivityManager.on_ui_activity_state_msg({key=M.key,state=ACTIVITY_HINT_STATUS_ENUM.AT_Get})
                    return
                else
                    GameActivityManager.on_ui_activity_state_msg({key=M.key,state=ACTIVITY_HINT_STATUS_ENUM.AT_Nor})
                end 
            end
        end
    end
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

function M.Init()
    M.Exit()
    MakeLister()
    AddLister()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.GetHintState(parm)
    for k,t_v in pairs(config.tge) do
        if config[t_v.tge] then
            for i,v in ipairs(config[t_v.tge]) do
                if GameTaskModel.check_reward_state(v.task,v.level) then 
                    return ACTIVITY_HINT_STATUS_ENUM.AT_Get
                end 
            end
        end
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