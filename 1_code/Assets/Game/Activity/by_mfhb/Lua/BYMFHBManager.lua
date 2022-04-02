-- 创建时间:2019-05-29
-- Panel:BYMFHBManager
local basefunc = require "Game/Common/basefunc"

BYMFHBManager = basefunc.class()
local M = BYMFHBManager
M.key = "by_mfhb"
GameButtonManager.ExtLoadLua(M.key, "FishingEventFireRedBag")
GameButtonManager.ExtLoadLua(M.key, "BYMFHBEnterPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key, "fish_activity_fire_red_bag_config")
M.task_id_list = {
	103,
	104,
	105,
}

M.task_id_hash = {
	[103] = 103,
	[104] = 104,
	[105] = 105,
}
function M.CheckIsShow()
	local m_cfg = BYMFHBManager.GetConfig()
	local active = M.CheckActive(m_cfg.base)
	if active == -1 or active == 0 then
		return
	end
	return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return FishingEventFireRedBag.Create()
    elseif parm.goto_scene_parm == "enter" then
        return BYMFHBEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig()
	return M.config
end

function M.GetTaskList()
    return M.task_id_list
end

function M.GetTaskHash(  )
	return M.task_id_hash
end

function M.CheckActive(cfg)
	local stamp = os.time()
	if stamp < cfg.begin_time then return 0 end
	if stamp < cfg.end_time then return 1 end
	if stamp < cfg.over_time then return 2 end
	return -1
end