-- 创建时间:2020-03-17
-- Act_005_HGJXManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_005_HGJXManager = {}
local M = Act_005_HGJXManager
M.key = "act_005_hgjx"
M.config = GameButtonManager.ExtLoadLua(M.key,"activity_005_hgjx_config")
GameButtonManager.ExtLoadLua(M.key,"Act_005_HGJXPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_005HGJXEnterPrefab")
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end
    local _a,t = GameButtonManager.RunFun({gotoui="sys_qx"}, "GetRegressTime")
	t = t or os.time()
    -- 对应权限的key
    local _permission_key = actp_own_task_p_regress_surprised
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true and not M.IsAllFinish() and (7 * 86400 - os.time() + t > 0)
    else
        return true and not M.IsAllFinish() and (7 * 86400 - os.time() + t > 0)
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
            return Act_005_HGJXPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        return Act_005HGJXEnterPrefab.Create(parm.parent,parm.backcall)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanGetAward() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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
end

function M.Init()
	M.Exit()

	this = Act_005_HGJXManager
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

function M.IsAllFinish()
    for i = 1,#M.config.base do 
        local data = GameTaskModel.GetTaskDataByID(M.config.base[i].task)
        if data then 
            if M.config.base[i].shop_id then 
                if data.now_total_process < 1 then 
                    return false
                end
            else
                if data.award_status ~= 2 then 
                    return false
                end
            end
        end 
    end
    return true
end

function M.IsCanGetAward()
    for i = 1,2 do 
        local data = GameTaskModel.GetTaskDataByID(M.config.base[i].task)
        if data then 
            if data.award_status == 1 then 
                return true
            end
        end 
    end
    return false
end