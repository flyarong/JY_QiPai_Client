local basefunc = require "Game/Common/basefunc"
Act_028_WYSYYManager = {}
local M = Act_028_WYSYYManager
M.key = "act_028_wysyy"
GameButtonManager.ExtLoadLua(M.key, "Act_028_WYSYYPanel") 
GameButtonManager.ExtLoadLua(M.key, "Act_028_WYSYYPanel_Out") 
local lister
local m_data
local activity_id_year = 16
local activity_id_game = 16
local activity_ID_game = 16
local is_yy = false
local end_time = 1631548799
local start_time = 1630971000
local match_start_time = 1631619000
local match_day_time = 1631548800--比赛当天零点,比如比赛当天是5月1日21:00点.那么这个值就是5月1日00:00点
function M.CheckIsShow()
	return true
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_028_WYSYYPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel_out" then
        return Act_028_WYSYYPanel_Out.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter" then
        
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
    lister["OnLoginResponse"] = M.SendQuery
	lister["act_match_order_msg_change"] = M.on_act_match_order_msg_change
    lister["query_gns_ticket_response"] = M.SetData
    lister["PPC_Created"] = M.on_PPC_Created
    lister["JBS_Created"] = M.on_JBS_Created
    lister["get_gns_ticket_response"] = M.on_get_gns_ticket_response
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

function M.SetData(_,data)
    dump(data,"<color=red>万元赛预约</color>")
    if data and data.result == 0 then 
		if data.status == 1 then 
			is_yy = true
		else
			is_yy = false
		end 
        Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})   
    end
end
function M.on_get_gns_ticket_response( ... )
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})   
end

function M.SendQuery(result)
    if result == 0 then
        Network.SendRequest("query_gns_ticket")
        GameButtonManager.RunFunExt("sys_act_base", "ForceToChangeIndex", nil, M.key,100,function()
            if is_yy then
                return true
            end
        end)
    end
end

function M.GetData()
    if table_is_null(m_data) then
        return nil
    end
    return m_data
end

function M.on_act_match_order_msg_change(data)
    --只在当日做变化
    if os.time() > match_day_time and os.time() < match_start_time then 
    --大厅跳转
        if data.goto_parm then 
            data.goto_parm.match_type_id = 9 
        end 
    --大厅界面处理 
        if data.hall_img then
            data.hall_img.sprite = GetTexture("hall_imgf_wys")
            data.hall_img:SetNativeSize()
            data.hall_img.gameObject.transform.parent.transform:Find("@qys_jb_img").gameObject:SetActive(true)    
            data.hall_img.gameObject.transform.parent.transform:Find("@qys_jb_img/bmsj").gameObject:SetActive(false)    
        end 
    end 
end

function M.IsYuYue()
    return is_yy
end

function M.on_PPC_Created()
    if os.time() > start_time and os.time() < end_time then
        if not is_yy and MainModel.GetHBValue() >= 1 then 
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                Act_028_WYSYYPanel_Out.Create()
                PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
            end
        end
    end 
end

function M.on_JBS_Created()
    if os.time() > start_time and os.time() < end_time then
        if not is_yy and MainModel.GetHBValue() >= 1 then 
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id.."jbs", 0))))
            if oldtime ~= newtime then
                Act_028_WYSYYPanel_Out.Create()
                PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id.."jbs", os.time())
            end
        end
    end 
end

function M.GetMatchStartTime()
    return match_start_time
end

function M.GetActEndTime()
    return end_time
end

function M.IButton()
    
end