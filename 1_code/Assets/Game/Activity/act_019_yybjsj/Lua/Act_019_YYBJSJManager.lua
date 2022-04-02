-- 创建时间:2020-06-22
-- Act_019_YYBJSJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_019_YYBJSJManager = {}
local M = Act_019_YYBJSJManager
M.key = "act_019_yybjsj"
M.task_id = 21390
M.chb_task_ids = {21391}
M.level = 1
local permisstions = {}
local this
local lister
GameButtonManager.ExtLoadLua(M.key,"Act_019_YYBJSJPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_019_YYBJSJEnterPrefab")

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1595282400
    local s_time = 1594076400
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key    
    local func = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        else
            return true
        end
    end
    return M.IsShowBtn()
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity(parm)
    if parm.goto_scene_parm == "act_panel" then
        return true
    end
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_019_YYBJSJPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter"  then
        if M.IsShowBtn() then
            return Act_019_YYBJSJEnterPrefab.Create(parm.parent)
        end
    elseif parm.goto_scene_parm == "act_panel"  then
        if M.IsShowBtn() then
            return Act_019_YYBJSJPanel.Create(parm.parent)
        else
            HintPanel.Create(1,"请于今晚来21:30拆红包")
        end
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        -- dump(M.IsAwardCanGet(),"XXXXXXXXXXXXXXXXXXXX")
        -- dump(MainModel.UserInfo.user_id.."xxxxxx"..M.GetDayIndex(),"fffffffffffffffffffffffffffffffffffffffff")
        -- dump(PlayerPrefs.GetInt("act_019_yybjsj"..MainModel.UserInfo.user_id..M.GetDayIndex(),0),"LLLLLLLLLLLLLLLLLL")
        if  M.IsAwardCanGet() or (PlayerPrefs.GetInt("act_019_yybjsj"..MainModel.UserInfo.user_id..M.GetDayIndex(),0) == 0 and M.IsDuringTime()) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            -- local newtime = tonumber(os.date("%Y%m%d", os.time()))
            -- local user_id = MainModel.UserInfo and MainModel.UserInfo.user_id or ""
            -- local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. user_id, 0))))
            -- if oldtime ~= newtime then
            --     return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            -- end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["hallpanel_created"] = this.hallpanel_created
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_019_YYBJSJManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化       
        Network.SendRequest("sleep_act_new_get_task")
        Network.SendRequest("query_one_task_data",{task_id = M.task_id})
	end
end

function M.OnReConnecteServerSucceed()

end


function M.IsDuringTime()
    local time_during = {
        [1] = {
            s_t = 21.5 * 3600,
            e_t = 24 * 3600
        },
        [2] = {
            s_t = 0 * 3600,
            e_t = 2 * 3600
        }
    }
    local get_unix_time = function (x)
        local t = os.time() + 8*60*60
        local f = math.floor(t/86400)
        return f * 86400 + x -8*60*60
    end
    local now_t = os.time()
    for i = 1,#time_during do
        if  get_unix_time(time_during[i].s_t) <= now_t and get_unix_time(time_during[i].e_t) >= now_t then
            return i
        end
    end
    return false
end

function M.get_unix_time(x)
    local t = os.time() + 8*60*60
    local f = math.floor(t/86400)
    return f * 86400 + x -8*60*60
end

function M.model_query_one_task_data_response(data)
    if data.id == M.task_id then
        Event.Brocast("act_019_yybjsj_refresh")
    end
    if data.id == M.chb_task_ids[M.level] then
        Event.Brocast("act_019_yybjsj_chb_refresh")
    end
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function M.GetCHBTimes()
    local data = GameTaskModel.GetTaskDataByID(M.chb_task_ids[M.level])
    local sum = 0
    if data then
        local b = basefunc.decode_task_award_status(data.award_get_status)
		b = basefunc.decode_all_task_award_status2(b, data, 2)
        for i = 1,2 do
            if b[i] == 2 then 
                sum = sum + 1
            end
        end
    end
    return sum
end

function M.GetCHBMaxStr()
    local level = VIPManager.get_vip_level()
    local str = {
        "188福卡","388福卡","888福卡","1888福卡",
    }
    if level == 0 then
        return str[1]
    elseif level > 0 and level <= 3 then
        return str[2]
    elseif level >3 and level <=7 then
        return str[3]
    else
        return str[4]
    end

end

function M.IsFreeToRefresh()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
	if data then
		local str_map = json2lua(data.other_data_str)
		dump(str_map,"<color=red>Str_Map</color>")
        if str_map then
            if str_map.refresh_task_num == nil then
                return true
            elseif str_map.refresh_task_num > 0 then
                return false
            end
        end
    end
    return true
end

function M.GetTaskOverTime()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
    if data then
        --超出所有时间限制 属于非法时间
        if data.over_time >=  1595282400 then
            return 0 
        end
		return data.over_time
    end
    return 0
end

function M.IsSignUP()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
	if data then
		local str_map = json2lua(data.other_data_str)
		dump(str_map,"<color=red>Str_Map</color>")
        if str_map then
            if str_map.task_status == "begin" then
                return true
            end
        end
    end
    return false
end

function M.on_model_task_change_msg(data)
    if data.id == M.task_id then
        Event.Brocast("act_019_yybjsj_refresh")
    end
    if data.id == M.chb_task_ids[M.level] then
        Event.Brocast("act_019_yybjsj_chb_refresh")
    end
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function M.IsAwardCanGet()
    local task = {}
    task[1] = M.task_id
    task[2] = M.chb_task_ids[M.level]
    for i = 1,#task do
        local data = GameTaskModel.GetTaskDataByID(task[i])
        if data and data.award_status == 1 then
            return true
        end
    end
end

function M.IsEnd()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
	if data then
		local str_map = json2lua(data.other_data_str)
        if str_map then
            if str_map.task_status == "end" then
                return true
            end
        end
    end
    return false
end

local Hall_Created_Times = 0
function M.hallpanel_created()
    if M.IsActive() and Hall_Created_Times > 0 and MainModel.UserInfo.xsyd_status == 1 then
        if PlayerPrefs.GetInt("act_019_yybjsj"..MainModel.UserInfo.user_id..M.GetDayIndex(),0) == 0 then
            Act_019_YYBJSJPanel.Create()
        end
    end
    Hall_Created_Times = Hall_Created_Times + 1
end

function M.IsNotOp(arg1, arg2, arg3)
    
end

--今天到21:30到第二天的2点都为1天计算
function M.GetDayIndex()
    local base_index_func = function ()
        local first_start_time = 1594076400
        local t1 = basefunc.get_today_id(first_start_time)
        local t2 = basefunc.get_today_id(os.time())
        return  t2 - t1 < 1 and 1 or t2 - t1 + 1
    end
    local base_index = base_index_func()
    if M.IsDuringTime() == 2 then
        return base_index - 1
    end
    return base_index
end


function M.IsShowBtn()
    if (not M.IsSignUP()) and (not M.IsEnd())then
        return M.IsDuringTime()
    else
        return os.time() < M.GetTaskOverTime()
    end
end