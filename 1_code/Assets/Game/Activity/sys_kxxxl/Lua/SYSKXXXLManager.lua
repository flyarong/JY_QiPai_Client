-- 创建时间:2019-05-29
-- Panel:BYDRBManager
local basefunc = require "Game/Common/basefunc"

SYSKXXXLManager = basefunc.class()
local M = BYDRBManager
M.key = "by_drb"
GameButtonManager.ExtLoadLua(M.key, "SYSKXXXLEnterPrefab")
local config --= GameButtonManager.ExtLoadLua(M.key, "fish_activity_rank_config")

function M.CheckIsShow()
	dump(config, "<color=white>config>>>>>>>>>>>>>>>捕鱼达人榜</color>")
	local active = M.CheckActive(config.base[1])
	if active == -1 or active == 0 then
		return
	end
	return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "enter" then
        return SYSKXXXLEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig()
	return config
end

function M.CheckActive(cfg)
	local stamp = os.time()
	if stamp < cfg.begin_time then return 0 end
	if stamp < cfg.end_time then return 1 end
	if stamp < cfg.over_time then return 2 end
	return -1
end