-- 创建时间:2019-05-29
-- Panel:SYSXRZSManager
local basefunc = require "Game/Common/basefunc"
LTQFManager = {}
local M = LTQFManager
M.key = "act_ltqf"
M.lottery_type = "dragon_blessing"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_ltqf_config")
GameButtonManager.ExtLoadLua(M.key, "LTQF_EnterPreab")
GameButtonManager.ExtLoadLua(M.key, "ActivityLTQFPanel")
local s_time = 1581982200
local e_time = 1582559999
local lister
local m_data
local type_info = {
	type = M.lottery_type,
	start_time = s_time,
	end_time = e_time,
	config = M.config
}
function M.CheckIsShow()
	if MainModel.UserInfo.ui_config_id == 1 and LotteryBaseManager.IsRightChannel() then
		if os.time() < e_time and os.time() > s_time then 
			if M.CheckPermiss() then 
				return true
			end 
		end 
    end
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
		if M.CheckPermiss() then
			return ActivityLTQFPanel.Create(parm.parent, parm.cfg, parm.backcall)
		end 
	elseif parm.goto_scene_parm == "enter" then
		if M.CheckPermiss() then 
			return LTQF_EnterPrefab.Create(parm.parent, parm.cfg)
		end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig()
	return M.config
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
	lister["get_one_common_lottery_info"] = M.SetData
	lister["global_hint_state_set_msg"] = M.SetHintState
end

function M.Init()
	M.Exit()
	m_data = {}
	MakeLister()
	AddLister()
	LotteryBaseManager.AddQuery(type_info)
end

function M.Exit()
	if M then
		RemoveLister() 
	end
end

function M.SetData()
	local data = LotteryBaseManager.GetData(M.lottery_type)
	if data then
		m_data.at_data = data
		m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
		if LotteryBaseManager.IsAwardCanGet(M.lottery_type,M.config) then 
			m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            m_data.at_status =  ACTIVITY_HINT_STATUS_ENUM.AT_Nor	
		end 
	end
	Event.Brocast("ui_button_data_change_msg", {key = M.key})
	Event.Brocast("global_hint_state_set_msg", {gotoui = M.key}) 
end

function M.GetData()
	if table_is_null(m_data) then 
		return nil 
	end
	return  m_data
end

function M.GetHintState(parm)
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
	if oldtime ~= newtime then
		return ACTIVITY_HINT_STATUS_ENUM.AT_Red
	end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.SetHintState(parm)
	if parm.gotoui == M.key then
		PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
		Event.Brocast("global_hint_state_change_msg", parm)
	end
end

function M.CheckPermiss()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_common_lottery_dragon_blessing", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end