local basefunc = require "Game/Common/basefunc"
SYSSTXTManager = {}
local M = SYSSTXTManager
M.key = "sys_stxt"
M.TP_encourage_config = GameButtonManager.ExtLoadLua(M.key, "TP_encourage_config")
M.invite_game_config = GameButtonManager.ExtLoadLua(M.key, "invite_game_config")
M.master_daily_task_server = GameButtonManager.ExtLoadLua(M.key, "master_daily_task_server")
M.task_master_daily_server = GameButtonManager.ExtLoadLua(M.key, "task_master_daily_server")
M.master_message_config = GameButtonManager.ExtLoadLua(M.key, "master_message_config")
M.st_base_limit = GameButtonManager.ExtLoadLua(M.key, "st_base_limit")

GameButtonManager.ExtLoadLua(M.key, "GetPupilPanel")
GameButtonManager.ExtLoadLua(M.key, "GetTeacherPanel")
GameButtonManager.ExtLoadLua(M.key, "MyPupilPanel")
GameButtonManager.ExtLoadLua(M.key, "MyTeacherPanel")
GameButtonManager.ExtLoadLua(M.key, "TeacherAndPupilPanel")
GameButtonManager.ExtLoadLua(M.key, "ShowTeacherPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSSTXTEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "InviteGamesPanel")
GameButtonManager.ExtLoadLua(M.key, "BrokeTPPanel")
GameButtonManager.ExtLoadLua(M.key, "TpEncouragePanel")
GameButtonManager.ExtLoadLua(M.key, "OnInviteGamesPanel")
GameButtonManager.ExtLoadLua(M.key, "ConfirmPublishTaskPanel")
GameButtonManager.ExtLoadLua(M.key, "TpTaskPanel")
local this
local lister
local m_data
local invite_count_time
local find_over = false
--数据表中的数据满足其中的某一条条件，就属于红点提示
local red_model_my_pupil = 
{
    ["type"] = 2,
    ["type"] = 4,
    ["type"] = 6,
    master_is_can_get_award = 1, 

}
local red_model_my_master = 
{
    ["type"] = 1,
    ["type"] = 3,
    ["type"] = 5,
    ["type"] = 7,
    award_status = 1,
    [1] = {award_status = 0,}
}

function M.CheckIsShow()
	return  true
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return TeacherAndPupilPanel.Create(parm.parent, parm.cfg, parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return SYSSTXTEnterPrefab.Create(parm.parent, parm.cfg)
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
    lister["notify_invite_apprentice_play_from_master"] = this.notify_invite_apprentice_play_from_master
    lister["query_master_personal_info_list_response"] = this.on_query_master_personal_info_list_response
    lister["query_master_notify_info_list_response"] = this.on_query_master_notify_info_list_response
    lister["query_apprentice_notify_info_list_response"] = this.on_query_apprentice_notify_info_list_response
    lister["query_apprentice_personal_info_list_response"] = this.on_query_apprentice_personal_info_list_response
    lister["change_message_from_apprentice_response"] = this.on_change_message_from_apprentice_response
    lister["change_info_from_apprentice_response"] =  this.on_change_info_from_apprentice_response
    lister["get_everyday_task_status_response"] = this.on_get_everyday_task_status_response
    lister["deal_apply_info_from_master_response"] = this.on_deal_apply_info_from_master_response
    lister["OnLoginResponse"] = this.OnLoginResponse
end

function M.Init()
    this = M
    invite_count_time = {}
    M.Exit()
    m_data = {}
    MakeLister()
    AddLister()
    M.InviteCountTimer()
end

function M.Exit()
    if M then
        RemoveLister()
    end
end

function M.SetData()

end

function M.GetData()

end

function M.GetHintState(parm)
    if M.CheakRed() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Red
    end
    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.SetHintState(parm)

end

function M.notify_invite_apprentice_play_from_master(_,data)
    if invite_count_time[data.game_type] then
        if invite_count_time[data.game_type] <= 0 then 
            OnInviteGamesPanel.Create(data.game_type,data.master_info) 
            invite_count_time[data.game_type] = 30
        end 
    else
        OnInviteGamesPanel.Create(data.game_type,data.master_info) 
        invite_count_time[data.game_type] = 30
    end 
   -- OnInviteGamesPanel.Create(data.game_type,data.master_info) 
end

function M.InviteCountTimer()
    this.I_T = Timer.New(function ()
        for k ,v in pairs(invite_count_time) do
            if  invite_count_time[k]>= 0 then 
                invite_count_time[k] = invite_count_time[k] - 1
            end 
        end 
    end,1,-1)
    this.I_T:Start()
end

function M.SendTeacherQuery()
    Network.SendRequest("query_master_personal_info_list")
    Network.SendRequest("query_master_notify_info_list")
end

function M.SendPupilQuery()
    Network.SendRequest("query_apprentice_notify_info_list")
    Network.SendRequest("query_apprentice_personal_info_list")
end

function M.on_query_master_personal_info_list_response(_,data)
    if data and data.result == 0 then 
        m_data.master_personal_info = data
        M.GetTeacherTaskInfo(1)
    end 
end

function M.on_query_master_notify_info_list_response(_,data)
    if data and data.result == 0 then 
        m_data.master_notify_info = data.message
        Event.Brocast("Teacher_Notify_Finsh")
    end 
end

function M.GetTeacherTaskInfo(index)
    if m_data.master_personal_info.master_info and m_data.master_personal_info.master_info[index] then
        Network.SendRequest("query_task_info",{master_id =  m_data.master_personal_info.master_info[index].master_id},"",function (data)
            dump(data,"获取我的师父给我的任务信息：：：：：：：：")
            if data and data.result == 0 or data.result == 5508 then 
                m_data.master_personal_info.master_info[index].task_data = data.task_data
                M.GetTeacherTaskInfo(index + 1)
            end 
        end)
    else
        Event.Brocast("Teacher_Info_Finsh")
    end
end

function M.Get_Teacher_Info()
    return m_data.master_personal_info
end

function M.Get_Teacher_Notify()
    return m_data.master_notify_info
end

function M.on_query_apprentice_personal_info_list_response(_,data)
    if data and data.result == 0 then 
        m_data.apprentice_personal_info = data
        dump(data,"<color=red>徒弟信息================</color>")
        M.GetPupilTaskInfo(1)
    end 
end

function M.on_query_apprentice_notify_info_list_response(_,data)
    if data and data.result == 0 then 
        m_data.apprentice_notify_info = data.message
        Event.Brocast("Pupil_Notify_Finsh")
    end 
end

function M.GetPupilTaskInfo(index)
    if m_data.apprentice_personal_info.apprentice_info and m_data.apprentice_personal_info.apprentice_info[index] then
        Network.SendRequest("query_task_info",{apprentice_id = m_data.apprentice_personal_info.apprentice_info[index].apprentice_id},"",function (data)
            dump(data,"获取我给我的徒弟的任务信息：：：：：：：：")
            if data and data.result == 0 then 
                m_data.apprentice_personal_info.apprentice_info[index].task_data = data.task_data
                if data.task_data then 
                    Network.SendRequest("get_everyday_task_status",{apprentice_id = m_data.apprentice_personal_info.apprentice_info[index].apprentice_id},"",function (_data)
                        dump(_data,"获取我师徒任务奖励的状态：：：：：：：：")
                        if _data and _data.result == 0  then 
                            m_data.apprentice_personal_info.apprentice_info[index].task_data.master_task_status= _data.task_status
                            M.GetPupilTaskInfo(index + 1)
                        else
                            M.GetPupilTaskInfo(index + 1)
                        end 
                    end)
                else
                    M.GetPupilTaskInfo(index + 1)
                end           
            end 
        end)
    else
        Event.Brocast("Pupil_Info_Finsh")
    end
end

function M.on_get_everyday_task_status_response(_,data)
    
end

function M.Get_Pupil_Info()
    return m_data.apprentice_personal_info
end

function M.Get_Pupil_Notify()
    return m_data.apprentice_notify_info
end

function M.on_change_message_from_apprentice_response(_,data)
    if data and data.result == 0 then 
   
    else
        HintPanel.ErrorMsg(data.result)
    end  
end

function M.on_change_info_from_apprentice_response(_,data)
    if data and data.result == 0 then 
       
    else
        HintPanel.ErrorMsg(data.result)
    end  
end

function M.CheakRed(key)
    if key then
        if key == "GetTeacher" then 
            return M.Cheak_GetTeacher_Red()  
        end
        if key == "GetPupil" then 
            return M.Cheak_GetPupil_Red() 
        end
        if key == "MyPupil" then 
            return M.Cheak_MyPupil_Red()
        end
        if key == "MyTeacher" then 
           return M.Cheak_MyTeacher_Red()
        end
    else
        return M.Cheak_GetTeacher_Red() or 
        M.Cheak_GetPupil_Red() or M.Cheak_MyPupil_Red() or M.Cheak_MyTeacher_Red()
    end
end

-- 检查获取师父页签红点
function M.Cheak_GetTeacher_Red()
    return false
end

-- 检查获取徒弟页签红点
function M.Cheak_GetPupil_Red()
    return false
end

-- 检查我的徒弟页签红点
function M.Cheak_MyPupil_Red()
    find_over = false
    local b1 = M.CheakRedModel(m_data.apprentice_personal_info,red_model_my_pupil)
    find_over = false
    local b2 = M.CheakRedModel(m_data.apprentice_notify_info,red_model_my_pupil)
    return b1 or b2
end

-- 检查我的师父页签红点
function M.Cheak_MyTeacher_Red()   
   find_over = false
   local b1 = M.CheakRedModel(m_data.master_personal_info,red_model_my_master)
   find_over = false
   local b2 = M.CheakRedModel(m_data.master_notify_info,red_model_my_master)
   return b1 or b2
end

function M.CheakRedModel(data,red_model)
    if data == nil then return end
    if find_over then return find_over end 
    for k,v in pairs(data) do
        for k1,v1 in pairs(red_model) do
            if k == k1 then 
                if v1 == "not_null_table" then
                    if type(v) == "table" and #v >= 1 then 
                        find_over = true
                        return true
                    end
                end
                if v1 == "null_table" then
                    if type(v) == "table" and table_is_null(v) then
                        find_over = true
                        return true
                    end
                end
                if v1 == v then 
                    find_over = true
                    return true
                end
            else
                if type(v) == "table" then 
                    M.CheakRedModel(v,red_model)
                end
                if type(v1) == "table" then 
                    M.CheakRedModel(data,v1)
                end 
            end
        end
    end
    return find_over
end

function M.OnLoginResponse(result)
    if result ~= 0 then return end
    SYSSTXTManager.SendPupilQuery()
	SYSSTXTManager.SendTeacherQuery()
end

function M.GetLimitByKey(key)
    for k ,v in pairs(M.st_base_limit.base) do 
        if key == v.key then 
            return v.value
        end
    end 
end

function M.on_deal_apply_info_from_master_response(_,data)
    if data and data.result == 0 then 
   
    else
        HintPanel.ErrorMsg(data.result)
    end  
end