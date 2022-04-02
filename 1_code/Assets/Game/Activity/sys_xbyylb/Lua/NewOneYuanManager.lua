local basefunc = require "Game/Common/basefunc"
NewOneYuanManager = {}
local M = NewOneYuanManager
M.key = "sys_xbyylb" -- 新人一元
local task_id = 21032
local shop_id = 10080
local task_count = 4
GameButtonManager.ExtLoadLua(M.key, "NewOneYuanPanel")
GameButtonManager.ExtLoadLua(M.key, "NewOneYuanEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSXBYYLB_JYFLEnterPrefab")
local lister
function M.CheckIsShow()
    if MainModel.UserInfo.ui_config_id == 1 then
        return
    end
    local shop_status = MainModel.GetGiftShopStatusByID(shop_id)
    local task_data = GameTaskModel.GetTaskDataByID(task_id)
    dump(shop_status,"<color=red>一元礼包购买状态</color>")
    dump(task_data,"<color=red>一元礼包任务</color>")
    if shop_status == 1 or (shop_status == 0 
    and task_data and M.DisappearTime(task_data.create_time) > os.time()) then
        return true
    end 
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then 
            return NewOneYuanPanel.Create(parm)
        end 
    elseif parm.goto_scene_parm == "enter" then
        return NewOneYuanEnterPrefab.Create(parm.parent, parm.cfg)
    elseif parm.goto_scene_parm == "jyfl_enter" then 
        return SYSXBYYLB_JYFLEnterPrefab.Create(parm.parent)
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
    lister["model_task_change_msg"] = M.SetData
    lister["model_query_task_data_response"] = M.RefreshJYFLEnter
    lister["global_hint_state_set_msg"] = M.SetHintState
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

function M.SetData(data)
    if data and data.id == task_id then 
        Event.Brocast("ui_button_data_change_msg", { key = M.key })
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
    end 
end

function M.GetData()
    if table_is_null(m_data) then
        return nil
    end
    return m_data
end

function M.GetHintState(parm)
    local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
    if MainModel.GetGiftShopStatusByID(shop_id) == 1 and MainModel.UserInfo.ui_config_id == 2 then 
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
    local task_data = GameTaskModel.GetTaskDataByID(task_id)
    if task_data then
        local b = basefunc.decode_task_award_status(task_data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, task_data, NewOneYuanManager.GetTaskCount()) 
        if b[M.GetDayIndex()] and b[M.GetDayIndex()] == 1 then 
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end 
    end 
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

function M.GetDayIndex()
    local data = GameTaskModel.GetTaskDataByID(task_id)
    if data then 
        local t1 = basefunc.get_today_id(tonumber(data.create_time))
        local t2 = basefunc.get_today_id(os.time())
        return  t2 - t1
    end 
end

function M.GetTaskID()
    return task_id
end

function M.GetShopID()
    return shop_id
end

function M.GetTaskCount()
    return task_count
end

function M.DisappearTime(buy_time)
    local day = 5
    local offset_time = 0 
    local Greenwich_off = 8 * 60 * 60
    local t = buy_time
    local f = math.floor((t + Greenwich_off)/ 86400)
    return (f + day) * 86400 - Greenwich_off + offset_time
end

function M.RefreshJYFLEnter()
    Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
end