local basefunc = require "Game/Common/basefunc"
LMQRJManager = {}
local M = LMQRJManager
M.key = "act_lmqrj"
M.lottery_type = "romantic_valentine_day"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_lmqrj_config")
GameButtonManager.ExtLoadLua(M.key, "LMQRJEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActivityLMQRJPanel")
local s_time = 1581377400
local e_time = 1581955199
local lister
local m_data
local type_info = {
    type = M.lottery_type,
    start_time = s_time,
    end_time = e_time,
    config = M.config
}
function M.CheckIsShow()
	if MainModel.UserInfo.ui_config_id == 1 and M.CheckPermiss()  then
        if os.time() < e_time and os.time() > s_time then
            return true
        end
    end
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return ActivityLMQRJPanel.Create(parm.parent, parm.cfg, parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return LMQRJEnterPrefab.Create(parm.parent, parm.cfg)
        end 
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
	lister["get_one_common_lottery_info"] = M.SetData
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
        if LotteryBaseManager.IsAwardCanGet(M.lottery_type) then
            m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end
    Event.Brocast("ui_button_data_change_msg", { key = M.key })
    Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
end

function M.GetData()
    if table_is_null(m_data) then
        return nil
    end
    return m_data
end

function M.CheckPermiss()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_common_lottery_romantic_valentine_day", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end