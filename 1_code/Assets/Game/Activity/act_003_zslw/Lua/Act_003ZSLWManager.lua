-- 创建时间:2020-03-03
-- Act_003ZSLWManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_003ZSLWManager = {}
local M = Act_003ZSLWManager
M.key = "act_003_zslw"

local this
local lister
GameButtonManager.ExtLoadLua(M.key, "Act_003ZSLWEnterPrefab") 
GameButtonManager.ExtLoadLua(M.key, "Act_003ZSLWPanel") 
M.task_ids = {
    [1] = {21171,21175},
    [2] = {21172,21176},
    [3] = {21173,21177},
    [4] = {21174,21178},
}

M.only_show_task_ids = {
    21183,21184,21185,21186
}

-- 是否有活动
function M.IsActive()
    --活动的开始与结束时间
    local e_time = 1584374399
    local s_time = 1583796600
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_21171"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
    return true
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
        if M.IsActive() then 
            return Act_003ZSLWPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then 
        if  M.IsActive() then
            return Act_003ZSLWEnterPrefab.Create(parm.parent)
        end 
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
    lister["model_task_change_msg"] = this.refresh
end

function M.Init()
	M.Exit()

	this = Act_003ZSLWManager
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

function M.IsAwardCanGet()
    for i = 1,#M.task_ids do 
        for j = 1,#M.task_ids[i] do 
            local data = GameTaskModel.GetTaskDataByID(M.task_ids[i][j])
            dump({M.task_ids[i][j],data},"植树活动任务数据")
            if data and data.award_status == 1 then 
                return true
            end
        end
    end
    return false
end

function M.refresh()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end