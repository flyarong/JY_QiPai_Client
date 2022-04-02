-- 创建时间:2019-05-29
-- Panel:BYLJYJManager
local basefunc = require "Game/Common/basefunc"

BYLJYJManager = basefunc.class()
local M = BYLJYJManager
M.key = "by_ljyj"
GameButtonManager.ExtLoadLua(M.key, "WheelSurfPanel")
GameButtonManager.ExtLoadLua(M.key, "FishingEventAddGlod")
GameButtonManager.ExtLoadLua(M.key, "BYLJYJEnterPrefab")

M.config = GameButtonManager.ExtLoadLua(M.key, "fish_activity_add_glod_config")
M.task_id = 101
function M.CheckIsShow()
	local m_cfg = BYLJYJManager.GetConfig()
	local active = M.CheckActive(m_cfg.base)
	if active == -1 or active == 0 then
		return
	end
	return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return FishingEventAddGlod.Create()
    elseif parm.goto_scene_parm == "enter" then
        return BYLJYJEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig()
	return M.config
end

function M.GetTask()
    return M.task_id
end

function M.CheckActive(cfg)
	local stamp = os.time()
	if stamp < cfg.begin_time then return 0 end
	if stamp < cfg.end_time then return 1 end
	if stamp < cfg.over_time then return 2 end
	return -1
end