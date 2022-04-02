-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
SysActOperatorManager = {}
local M = SysActOperatorManager
M.key = "sys_act_operator"
GameButtonManager.ExtLoadLua(M.key, "OperatorActivityLogic")
GameButtonManager.ExtLoadLua(M.key, "OperatorActivityModel")
GameButtonManager.ExtLoadLua(M.key, "OperatorActivityPanel")
GameButtonManager.ExtLoadLua(M.key, "OperatorActivityDJPanel")
GameButtonManager.ExtLoadLua(M.key, "OperatorActivityLSPanel")
GameButtonManager.ExtLoadLua(M.key, "OperatorActivityCSPanel")
GameButtonManager.ExtLoadLua(M.key, "OperatorActivityCSSharePanel")
GameButtonManager.ExtLoadLua(M.key, "GameExitHintPanel")

local lister
function M.CheckIsShow()
    if M.CheckIsWQP() then return end
    return true
end
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
function M.SetHintState()
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
end

function M.Init()
	M.Exit()
	M.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    OperatorActivityLogic.Init()
end
function M.Exit()
	if M then
		RemoveLister()
		M.m_data = nil
	end
end
function M.InitUIConfig()
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.CanLeaveGameBeforeEnd(parm)
    OperatorActivityLogic.CanLeaveGameBeforeEnd(parm.showHint,parm.callback)
end

--连胜活动
function M.CheckShowLS(game_id)
    if not game_id then return end
    return OperatorActivityModel.IsActivated(game_id, ActivityType.Consecutive_Win) and OperatorActivityLSPanel.CanBeAwarded()
end

function M.CheckIsWQP()
    local _permission_key = "drt_block_liansheng" --自由场连胜
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        -- dump({a,b},"<color=white>drt_block_liansheng权限</color>")
        if a and b then
            return true
        end
    end

    _permission_key = "drt_block_leisheng" --自由场累胜
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        -- dump({a,b},"<color=white>drt_block_leisheng权限</color>")
        if a and b then
            return true
        end
    end
end

function M.CheckIsActivated(parm)
    if M.CheckIsWQP() then return end
    return OperatorActivityModel.IsActivated(parm.game_id, parm.activity_type)
end

function M.IsBigUI()
    if M.CheckIsWQP() then return end
    return OperatorActivityLogic.IsBigUI()
end

function M.GetNotShowID()
    if M.CheckIsWQP() then return end
    return OperatorActivityLogic.GetNotShowID()
end

function M.IsNotShowID(parm)
    if M.CheckIsWQP() then return true end
    return OperatorActivityLogic.IsNotShowID(parm.game_id)
end

function M.CheckCSActivity()
    if M.CheckIsWQP() then return end
    return OperatorActivityLogic.CheckCSActivity()
end

function M.CheckCS()
    if M.CheckIsWQP() then return end
    return OperatorActivityLogic.CheckCS()
end

function M.GetActivatedActivityList()
    if M.CheckIsWQP() then return end
    return OperatorActivityModel.GetActivatedActivityList() 
end

function M.GetActivityConfig(parm)
    if M.CheckIsWQP() then return end
    return OperatorActivityModel.GetActivityConfig(parm.aid)
end

function M.GetActivityStateByFreeID(parm)
    if M.CheckIsWQP() then return end
   return OperatorActivityModel.GetActivityStateByFreeID(parm.game_id) 
end