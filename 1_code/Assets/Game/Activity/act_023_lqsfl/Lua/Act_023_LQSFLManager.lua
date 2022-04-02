-- 创建时间:2020-07-21
-- Act_023_LQSFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_023_LQSFLManager = {}
local M = Act_023_LQSFLManager
M.key = "act_023_lqsfl"

local this
local lister
--充值任务ID
M.cz_task_id = 21440
M.cpl_taskid = 21439
M.taskid = 21438
--充值权限
M.cz_permiss = "actp_own_task_p_023_lqshl_ljcz"
M.cpl_ljyj_permiss = "actp_own_task_p_023_lqshl_ljyj_cpl"
M.ljyj_permiss = "actp_own_task_p_023_lqshl_ljyj_nom"
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1597075199
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    M.CheakPerMiss()
    if M.Curr_Per then
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if  M.IsActive() then 
            return Act_023_LQSFLPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        return Act_023_LQSFLEnterPrefab.Create(parm.parent,parm.backcall)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
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
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_023_LQSFLManager
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
        
	end
end

function M.OnReConnecteServerSucceed()
end

function M.CheakPerMiss()
    M.Curr_Per = nil
    local check_func = function(_permission_key)
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
    if check_func(M.cz_permiss) then
        print("<color=red>充值任务+++++++++++</color>")
        if check_func(M.cpl_ljyj_permiss) then
            print("<color=red>CPL任务+++++++++++</color>")
            M.Curr_Per = M.cpl_ljyj_permiss
        elseif check_func(M.ljyj_permiss) then
            print("<color=red>普通任务+++++++++++</color>")
            M.Curr_Per = M.ljyj_permiss
        end
    end
end

function M.GetCurrTaskID()
    if M.Curr_Per == M.ljyj_permiss then
        M.CurrTaskID = M.taskid
        return M.taskid
    elseif  M.Curr_Per == M.cpl_ljyj_permiss then
        M.CurrTaskID = M.cpl_taskid
        return M.cpl_taskid
    end
end

function M.IsAwardCanGet()
    local table = {} 
    table[1] = M.GetCurrTaskID()
    table[2] = M.cz_task_id
    for i = 1,#table do
        local data = GameTaskModel.GetTaskDataByID(table[i])
        if data and data.award_status == 1 then
            return true
        end
    end
    return false
end

GameButtonManager.ExtLoadLua(M.key,"Act_023_LQSFLPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_023_LQSFLEnterPrefab")