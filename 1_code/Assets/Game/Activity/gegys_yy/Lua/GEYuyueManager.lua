local basefunc = require "Game/Common/basefunc"
GEYuyueManager = {}
GEYuyueManager = basefunc.class()
local M = GEYuyueManager
M.key = "gegys_yy"
GameButtonManager.ExtLoadLua(M.key, "GEYuyuePanel")

function M.CheckIsShow()
	return false
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return GEYuyuePanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end