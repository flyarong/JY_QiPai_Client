local basefunc = require "Game/Common/basefunc"
NmYjcdjManager = {}
local M = NmYjcdjManager
M.key = "act_nm_yjcdj"
M.lottery_type = "ceremony_lottery"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_nm_yjcdj_config")
GameButtonManager.ExtLoadLua(M.key, "NmYjcdjEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "NmYjcdjPanel")
local s_time = 1577316600
local e_time = 1577807999  
local lister
local m_data
local type_info = {
    type = M.lottery_type,
    start_time = s_time,
    end_time = e_time,
    config = M.config
}
function M.CheckIsShow()
    if  M.IsActive() then 
        if MainModel.UserInfo.ui_config_id == 1 then
            if os.time() < e_time and os.time() > s_time then
                return true
            end
        end
    end 
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "enter" then
        if  M.IsActive() then 
            return NmYjcdjPanel.Create(parm.parent, parm.backcall)
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
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.GetData()
    if table_is_null(m_data) then
        return nil
    end
    return m_data
end

function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if  LotteryBaseManager.IsAwardCanGet(type_info.type) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
end

function M.CheckIsShowInActivity(parm)
    return  M.IsActive()
end

function M.IsActive()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_common_lottery_ceremony_lottery", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end