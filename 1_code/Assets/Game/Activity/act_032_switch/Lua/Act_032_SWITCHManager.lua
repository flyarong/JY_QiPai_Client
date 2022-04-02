-- 创建时间:2020-07-24
-- Act_024_SWICHManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_032_SWITCHManager = {}
local M = Act_032_SWITCHManager
M.key = "act_032_switch"
M.base_config = {
    [1] = {gotoui = "act_032_xxldh"},
    [2] = {gotoui = "act_032_xxlzb"},
    [3] = {gotoui = "act_032_jflb"},
}

GameButtonManager.ExtLoadLua(M.key,"Act_032_SWITCHPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_032_SWITCHEnterPrefab")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1602518399
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_032_xchl"
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
        if M.IsActive() then
            return Act_032_SWITCHPanel.Create(parm.parent,parm.backcall)
        end
    end 
    if parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            return Act_032_SWITCHEnterPrefab.Create(parm.parent)
        end
    end 
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.CheakChildStatus() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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
	this = Act_032_SWITCHManager
	MakeLister()
    AddLister()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end


function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()

end

function M.CheakChildStatus()
    for i = 1,#M.base_config do
        local IsAct, result = GameButtonManager.RunFun( {gotoui = M.base_config[i].gotoui},"GetHintState")
        if IsAct and result == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
            return true
        end
    end
end

function M.GetConfig()
	local data = {}
	for i = 1,#M.base_config do
		local isHaveFunc,result =  GameButtonManager.RunFun({gotoui = M.base_config[i].gotoui},"CheckIsShow")
		if isHaveFunc and result then
			data[#data + 1] = M.base_config[i]
		end
    end
	return data
end