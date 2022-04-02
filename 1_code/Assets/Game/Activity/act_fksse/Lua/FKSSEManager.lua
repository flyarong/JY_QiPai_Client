local basefunc = require "Game/Common/basefunc"
FKSSEManager = {}
local M = FKSSEManager
M.key = "act_fksse"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_fksse_config")
GameButtonManager.ExtLoadLua(M.key, "FKSSEEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActivityFKSSEPanel")
GameButtonManager.ExtLoadLua(M.key, "FKSSEListPanel")
local lister
local m_data
local s_time = 1575934200
local e_time = 1576511999
function M.CheckIsShow()
	if MainModel.UserInfo.ui_config_id == 1  and os.time() < e_time and os.time() >  s_time then     
        return true
    end
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return ActivityFKSSEPanel.Create(parm.parent, parm.cfg, parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return FKSSEEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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

local function MakeLister()
	lister = {}
	lister["global_hint_state_set_msg"] = M.SetHintState
	lister["AssetChange"] = M.SetData
	lister["model_task_change_msg"] = M.SetData
end

function M.Init()
    M.Exit()
    m_data = {}
    MakeLister()
    AddLister()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.SetData()
    Event.Brocast("ui_button_data_change_msg", { key = M.key })
    Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
end

function M.GetHintState(parm)
	if parm.gotoui == M.key then
		local newtime = tonumber(os.date("%Y%m%d", os.time()))
		local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
		if oldtime ~= newtime then
			return  M.GetAwardStatus() == false and ACTIVITY_HINT_STATUS_ENUM.AT_Red or ACTIVITY_HINT_STATUS_ENUM.AT_Get
		end
		return M.GetAwardStatus() == false and ACTIVITY_HINT_STATUS_ENUM.AT_Nor or ACTIVITY_HINT_STATUS_ENUM.AT_Get
	end 
end

function M.SetHintState(parm)
    if parm.gotoui == M.key then
        PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
        Event.Brocast("global_hint_state_change_msg", parm)
    end
end

function M.GetAwardStatus()
	if GameTaskModel.check_reward_state(21031,5) or MainModel.GetHBValue() >= 2 then
		return true
	else
		return false
	end 
end