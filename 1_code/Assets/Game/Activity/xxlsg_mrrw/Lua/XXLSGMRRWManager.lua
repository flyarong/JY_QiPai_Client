-- 创建时间:2019-05-29
-- Panel:XXLSGMRRWManager
local basefunc = require "Game/Common/basefunc"

XXLSGMRRWManager = basefunc.class()
local M = XXLSGMRRWManager
M.key = "xxlsg_mrrw"
GameButtonManager.ExtLoadLua(M.key, "ExtendEliminateSGEveryDayTask")
local config = GameButtonManager.ExtLoadLua(M.key, "extend_eliminate_sg_every_day_config")
local lister
local m_data

-- 是否有活动
function M.IsActive()
    local _permission_key = "drt_block_little_game_daily_task" -- 屏蔽水浒消消乐、水果消消乐、街机捕鱼内的日常任务
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            return false
        end
	end
	
	local _permission_key = "actp_own_task_p_xiaoxiaole_daily_task" --水果消消乐中的每日消除任务（除玩棋牌平台外，其他都挂载）
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if not a or not b then
            return
        end
    end

	return true
end
function M.CheckIsShow()
	return M.IsActive()
end

function M.GotoUI(parm)
	if not M.IsActive() then
		return
	end
	if parm.goto_scene_parm == "enter" then
		return ExtendEliminateSGEveryDayTask.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig(  )
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
	-- if result == 0 then
	-- 	Timer.New(function ()
	-- 		M.UpdateData()		
	-- 	end, 3, 1):Start()
	-- end
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