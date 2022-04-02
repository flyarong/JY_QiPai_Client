-- 创建时间:2019-05-29
-- Panel:SYSXSFLManager
local basefunc = require "Game/Common/basefunc"

SYSXSFLManager = basefunc.class()
local M = SYSXSFLManager
M.key = "sys_xsfl"
GameButtonManager.ExtLoadLua(M.key, "XSFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "YearXSFLpanel")
local config = GameButtonManager.ExtLoadLua(M.key, "year_xsfl_config")

function M.CheckIsShow()
	local cur_t = os.time()
	if cur_t >= config.time[#config.time].endtime or cur_t < config.time[#config.time].starttime then 
		return  
	end
	return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return YearXSFLpanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return XSFLEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig()
	return config
end