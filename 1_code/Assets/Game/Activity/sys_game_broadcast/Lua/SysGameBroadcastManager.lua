-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
SysGameBroadcastManager = {}
local M = SysGameBroadcastManager
M.key = "sys_game_broadcast"
M.config = GameButtonManager.ExtLoadLua(M.key, "broadcast_config")
GameButtonManager.ExtLoadLua(M.key, "GameBroadcastManager")
GameButtonManager.ExtLoadLua(M.key, "GameBroadcastBulletPanel")
GameButtonManager.ExtLoadLua(M.key, "GameBroadcastBulletPrefab")
GameButtonManager.ExtLoadLua(M.key, "GameBroadcastRollPanel")
GameButtonManager.ExtLoadLua(M.key, "GameBroadcastBulletSendPanel")
GameButtonManager.ExtLoadLua(M.key, "GameBroadcastRollPrefab")
GameButtonManager.ExtLoadLua(M.key, "GameSysBroadcastRollPanel")
GameButtonManager.ExtLoadLua(M.key, "GameSysBroadcastRollPrefab")
GameButtonManager.ExtLoadLua(M.key, "LSSharePop")
local lister
function M.CheckIsShow()
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
    GameBroadcastManager.Init()
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