-- 创建时间:2020-12-29
-- Act_050_YXBXManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_050_YXBXManager = {}
local M = Act_050_YXBXManager
M.key = "act_050_yxbx"
GameButtonManager.ExtLoadLua(M.key,"Act_050_YXBXPanel")
local this
local lister


M.end_time = 1614614399
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
        return true
    else
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
        return Act_050_YXBXPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
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

function M.Refresh()
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
    lister["AssetChange"] = this.Refresh
end

function M.Init()
	M.Exit()

	this = Act_050_YXBXManager
	this.m_data = {}
    MainModel.AddUnShow(function(type)
        if type == "task_p_046_khtj_first" then
            return true
        end
    end)
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
    local num = GameItemModel.GetItemCount("prop_fish_drop_act_2")
    if num >= 50 then
        return true
    end
end