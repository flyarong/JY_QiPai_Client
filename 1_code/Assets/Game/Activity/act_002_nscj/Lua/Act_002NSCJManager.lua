local basefunc = require "Game/Common/basefunc"
Act_002NSCJManager = {}
local M = Act_002NSCJManager
M.key = "act_002_nscj"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_002_nscj_config") 
GameButtonManager.ExtLoadLua(M.key, "Act_002NSCJMorePanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002NSCJListPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002NSCJPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002NSCJMyListPanel") 
local this
local lister

-- 是否有活动
function M.IsActive()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_box_exchange_13", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return true
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_002NSCJPanel.Create(parm.parent)
    end 
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
	this = Act_002NSCJManager
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