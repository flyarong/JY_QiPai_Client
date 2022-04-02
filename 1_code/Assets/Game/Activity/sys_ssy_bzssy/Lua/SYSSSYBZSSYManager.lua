-- 创建时间:2019-05-29
-- Panel:SYSSSYBZSSYManager
local basefunc = require "Game/Common/basefunc"

SYSSSYBZSSYManager = basefunc.class()
local M = SYSSSYBZSSYManager
M.key = "sys_ssy_bzssy"
local config = GameButtonManager.ExtLoadLua(M.key, "activity_task_recharge_11_config")
function M.CheckIsShow()
	return true
end

function M.GotoUI(parm)
    if parm.goto_scene_parm == "enter" then
        return ActivityTaskPanel.Create(parm.parent,parm.cfg,nil, config)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end