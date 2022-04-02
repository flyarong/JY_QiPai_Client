local basefunc = require "Game/Common/basefunc"
Act_015_YYBJSJManager = {}
local M = Act_015_YYBJSJManager
M.key = "act_015_yybjsj"
M.config = GameButtonManager.ExtLoadLua(M.key, "act_015_yybjsj_config")
GameButtonManager.ExtLoadLua(M.key, "Act_015_YYBJSJPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_015_YYBJSJEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_015_YYBJSJHelpPanel")

M.state = {
    not_sign_up = 1,
    running = 2,
    timeout = 3,
    complete = 4,
}
M.vip_cfg_map = {
    [1] = 0,
    [2] = 1,
    [3] = 4,
    [4] = 8,
}
local lister
M.task_id = 21577
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local s_time = 1612827000
    local e_time = 1613422799  --02.16 04:59:59
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end
    --对应权限的key
    local _permission_key = "actp_own_task_21577"
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
    --dump(M.CheckIsShowByTime(),"<color=red>------M.CheckIsShowByTime()-----</color>")
    return M.IsActive() --and M.CheckIsShowByTime()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShowInActivity() then 
        return 
    end
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShowByTime() then
            local et = StringHelper.GetTodayEndTime()
            UnityEngine.PlayerPrefs.SetString(MainModel.UserInfo.user_id .. M.key, et)
            return Act_015_YYBJSJPanel.Create(parm.parent)
        else
            local et = StringHelper.GetTodayEndTime()
            if et - os.time() < 2.5 * 3600 then
                LittleTips.Create("请于明晚21:30来拆福卡")
            elseif et - os.time() >= 2.5 * 3600 and et - os.time() < 22 * 3600 then
                LittleTips.Create("请于今晚21:30来拆福卡")
            elseif et - os.time() >= 22 * 3600 then
                LittleTips.Create("请于今晚21:30来拆福卡")
            end
            return
        end
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShowByTime() then
            return Act_015_YYBJSJEnterPrefab.Create(parm.parent)
        end    
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    local task_data = GameTaskModel.GetTaskDataByID(M.task_id)
    if task_data and task_data.award_status == 1 then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
	end
	if PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id ..os.date("%x",os.time()),0) == 1 then
		return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
	else
		return ACTIVITY_HINT_STATUS_ENUM.AT_Get
	end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState(parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState(parm)
    if parm.gotoui == M.key then
		PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id  ..os.date("%x",os.time()),1)
		Event.Brocast("global_hint_state_change_msg", parm)
	end
    -- Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
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
    lister["OnLoginResponse"] = M.OnLoginResponse
    lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = M.on_global_hint_state_set_msg
    lister["model_task_change_msg"] = M.model_task_change_msg
    lister["hallpanel_created"] = M.hallpanel_created
end

function M.Init()
	M.Exit()
	M.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end

function M.Exit()
	if M then
		RemoveLister()
	end
end

function M.InitUIConfig()
    M.UIConfig = {}
    for i,v in ipairs(M.config.vipmzfl) do
        M.UIConfig[v.vip] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()
end

function M.model_task_change_msg(data)
	if not data or data.id ~= M.task_id then return end
	Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
end

function M.hallpanel_created()
    local pa = DSM.GetPlayerAct()
    if table_is_null(pa) or #pa == 1 then return end
    local cpa = pa[#pa]
    if cpa.scene ~= "game_Hall" then return end
    cpa = pa[#pa - 1]
    if not(cpa.scene == "game_MiniGame" 
        or cpa.scene == "game_MatchHall"
        or cpa.scene == "game_Free") then 
        return
    end

    local et = StringHelper.GetTodayEndTime()
    if not (et - os.time() < 2.5 * 3600 or et - os.time() > 22 * 3600) then
        --不在在活动9:30 ~ 2:00时间内
        return
    end
    local t = UnityEngine.PlayerPrefs.GetString(MainModel.UserInfo.user_id .. M.key)
    if not t or t == "" or et > tonumber(t) then
        GameManager.GotoUI({gotoui = M.key,goto_scene_parm = "panel"})
    end
end

function M.GetCurTaskData()
    local td = GameTaskModel.GetTaskDataByID(M.task_id)
    dump(td,"<color=white>yybjsj td>>>>>>></color>")
    local lv = VIPManager.get_vip_level()
    if table_is_null(td) then 
        return {cfg = M.UIConfig[lv]}
    end
    local other_data_str = td.other_data_str
    if not other_data_str then 
        return {cfg = M.UIConfig[lv]}
    end
    local  t = td.over_time
    if t - os.time() > 86400 then
        --超过一天表示没有选择任务
        return {cfg = M.UIConfig[lv]}
    end
    local other_data_str = td.other_data_str
    local d = string.split(other_data_str,"_")
    local g = tonumber(d[1])
    lv = M.vip_cfg_map[tonumber(d[2])]
    dump({cfg = M.UIConfig[lv],game = g,td = td},"<color=white>yybjsj cfg>>>>>>></color>")
    return {cfg = M.UIConfig[lv],game = g,td = td}
end

function M.GetActState()
    local td = GameTaskModel.GetTaskDataByID(M.task_id)
    if table_is_null(td) or not td.other_data_str or td.over_time - os.time() > 86400 then
        return M.state.not_sign_up
    end
    if td.over_time <= os.time() then
        return M.state.timeout
    end
    if td.over_time > os.time() and td.over_time - os.time() < 3 * 3600 then
        --有活动在活动中
        if td.award_status == 2 then
            return M.state.complete
        end
        return M.state.running
    end
end

function M.CheckIsShowByTime()
    local state = M.GetActState()
    local et = StringHelper.GetTodayEndTime()

    if state == M.state.running then
        return  true
    elseif state == M.state.not_sign_up then
        if et - os.time() < 2.5 * 3600 or et - os.time() > 22 * 3600 then
            --在活动9:30 ~ 2:00时间内
            return true
        end
        return false
    elseif state == M.state.complete then
        return true
    elseif state == M.state.timeout then
        return false
    end
end