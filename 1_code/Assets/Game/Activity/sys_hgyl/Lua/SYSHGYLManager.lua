-- 创建时间:2019-05-29
-- Panel:SYSHGYLManager
local basefunc = require "Game/Common/basefunc"

SYSHGYLManager = basefunc.class()
local M = SYSHGYLManager
M.key = "sys_hgyl"
GameButtonManager.ExtLoadLua(M.key, "BackPlayerTaskPanel")

function M.CheckIsShow()
	return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return BackPlayerTaskPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return BackPlayerTaskPanel.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end