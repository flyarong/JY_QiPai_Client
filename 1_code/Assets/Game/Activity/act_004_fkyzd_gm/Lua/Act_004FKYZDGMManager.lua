local basefunc = require "Game/Common/basefunc"

Act_004FKYZDGMManager = basefunc.class()
local M = Act_004FKYZDGMManager
M.key = "act_004_fkyzd_gm"
local config = GameButtonManager.ExtLoadLua(M.key, "act_004_fkyzd_gm_config")
local lister
local function MakeLister()
    lister = {}
    lister["UpdateHallTaskRedHint"] = M.CheakStatus
end
function M.IsActive(cfg)    
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_buy_gift_bag_class_fish_summon_item"
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

function M.GotoUI(parm)
	dump(parm)
    if parm.goto_scene_parm == "enter" then
        return ActivityExchangePanel.Create(parm.parent,parm.cfg,nil, config)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.CheakStatus()
    for k,t_v in pairs(config.tge) do
        if config[t_v.tge] then
            for i,v in ipairs(config[t_v.tge]) do
                GameActivityManager.on_ui_activity_state_msg({key=M.key,state=ACTIVITY_HINT_STATUS_ENUM.AT_Nor})
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
    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor   
end