-- 创建时间:2019-05-29
-- Panel:XXLSGLJYJManager
local basefunc = require "Game/Common/basefunc"

XXLSGLJYJManager = basefunc.class()
local M = XXLSGLJYJManager
M.key = "xxlsg_ljyj"
GameButtonManager.ExtLoadLua(M.key, "XXLSGLJYJEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "EliminateLJYJEvent")
local config = GameButtonManager.ExtLoadLua(M.key, "eliminate_ljyj_award_config")
local lister
local m_data

function M.CheckIsShow()
	return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return EliminateLJYJEvent.Create()
    elseif parm.goto_scene_parm == "enter" then
		return XXLSGLJYJEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig()
	return config
end

function M.GetData()
	return m_data
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
	lister["EnterForeGround"] = M.OnReConnecteServerSucceed
	lister["global_hint_state_set_msg"] = M.SetHintState
end

function M.Init()
	M.Exit()
	m_data = {}
	MakeLister()
    AddLister()
end

function M.Exit()
	if M then
		RemoveLister() 
	end
end

-- 数据更新
function M.UpdateData()
	
end

function M.OnLoginResponse(result)
	if result == 0 then
		Timer.New(function ()
			M.UpdateData()		
		end, 3, 1):Start()
	end
end

function M.OnReConnecteServerSucceed()
	M.UpdateData()
end

-- 活动的提示状态
function M.GetHintState(parm)
	
end

function M.SetHintState(parm)
	if parm.gotoui == M.key then
		Event.Brocast("global_hint_state_change_msg", parm)
	end
end