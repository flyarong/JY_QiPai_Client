local basefunc = require "Game/Common/basefunc"
Act_042_MPDHManager = {}
local M = Act_042_MPDHManager
M.key = "act_042_mpdh"
GameButtonManager.ExtLoadLua(M.key, "Act_042_MPDHPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_042_MPDHHintPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_042_MPDHEnterPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key, "act_042_mpdh_config")
M.hint_key = M.key .. MainModel.UserInfo.user_id .. "hint"
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

    -- 对应权限的key
    local _permission_key
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
    return M.IsActive()
end

-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

--鲸鱼福利中调用
function M.CheckIsShowInJYFL(parm)
    
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_042_MPDHPanel.Create(parm.parent,parm.backcall)
    end 
    if parm.goto_scene_parm == "enter" then
        return Act_042_MPDHEnterPrefab.Create(parm.parent)
    end 
    dump(parm,"<color=red>请检查参数</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
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

function M.IsAwardCanGet()
    
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
    lister["EnterScene"] = this.EnterScene
    lister["ExitScene"] = this.ExitScene

end

function M.Init()
	M.Exit()

	this = Act_042_MPDHManager
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

	end
end

function M.OnReConnecteServerSucceed()
end

function M.EnterScene(  )
    Event.Brocast("act_042_mpdh_close")
end

function M.ExitScene(  )
    Event.Brocast("act_042_mpdh_close")
end