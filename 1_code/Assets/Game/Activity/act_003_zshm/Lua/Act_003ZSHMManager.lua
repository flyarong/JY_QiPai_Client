local basefunc = require "Game/Common/basefunc"
Act_003ZSHMManager = {}
local M = Act_003ZSHMManager
M.key = "act_003_zshm"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_003_zshm_config") 
GameButtonManager.ExtLoadLua(M.key, "Act_003ZSHMMorePanel")
GameButtonManager.ExtLoadLua(M.key, "Act_003ZSHMListPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_003ZSHMPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_003ZSHMMyListPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_003ZSHMEnterPrefab") 
local this
local lister
M.task_id = 21179
-- 是否有活动
function M.IsActive()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_box_exchange_14", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    if M.IsActive() then
        -- 活动的开始与结束时间
        local e_time =  1584374399
        local s_time =  1583796600
        if (not e_time or os.time() < e_time) and (not s_time or os.time() > s_time) then
            return true
        end
    end
    return false
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then
            return Act_003ZSHMPanel.Create(parm.parent,parm.backcall)
        end
    end 
    if parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            return Act_003ZSHMEnterPrefab.Create(parm.parent)
        end
    end 
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if MainModel.GetHBValue() >= 1  then
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
    lister["AssetChange"] = this.Refresh
end

function M.Init()
	M.Exit()
	this = Act_003ZSHMManager
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
    this.UIConfig={
    }
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end