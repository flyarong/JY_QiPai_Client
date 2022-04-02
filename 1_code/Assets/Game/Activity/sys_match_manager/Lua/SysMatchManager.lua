-- 创建时间:2019-10-24
local basefunc = require "Game/Common/basefunc"
SysMatchManager = {}

local M = SysMatchManager
M.key = "sys_match_manager"
M.match_hall_config = GameButtonManager.ExtLoadLua(M.key, "match_hall_config")
M.match_game_config = GameButtonManager.ExtLoadLua(M.key, "match_game_config")
M.match_type_config = GameButtonManager.ExtLoadLua(M.key, "match_type_config")
M.match_award_config = GameButtonManager.ExtLoadLua(M.key, "match_award_config")
GameButtonManager.ExtLoadLua(M.key, "MatchLogic")
GameButtonManager.ExtLoadLua(M.key, "MatchModel")
local lister
function M.CheckIsShow()
    return true
end

function M.GotoUI(parm)
    
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

function M.Init()
	M.Exit()
    MatchLogic.Init()
end

function M.Exit()
    MatchLogic.Exit()
end