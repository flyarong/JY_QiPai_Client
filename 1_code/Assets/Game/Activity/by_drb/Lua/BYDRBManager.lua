-- 创建时间:2019-05-29
-- Panel:BYDRBManager
local basefunc = require "Game/Common/basefunc"

BYDRBManager = basefunc.class()
local M = BYDRBManager
M.key = "by_drb"
GameButtonManager.ExtLoadLua(M.key, "FishingActivityRankPanel")
GameButtonManager.ExtLoadLua(M.key, "BYDRBEnterPrefab")
local config = GameButtonManager.ExtLoadLua(M.key, "fish_activity_rank_config")

function M.CheckIsShow()
	dump(config, "<color=white>config>>>>>>>>>>>>>>>捕鱼达人榜</color>")
	-- local active = M.CheckActive(config.base[1])
	-- if active == -1 or active == 0 then
	-- 	return
	-- end
	if  M.CheckPermiss() then 
		return true
	end 
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
		if  M.CheckPermiss() then 
			return FishingActivityRankPanel.Create()
		end 
	elseif parm.goto_scene_parm == "enter" then
		if  M.CheckPermiss() then 
			return BYDRBEnterPrefab.Create(parm.parent, parm.cfg)
		end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
function M.GetConfig()
	return config
end

-- function M.CheckActive(cfg)
-- 	local stamp = os.time()
-- 	if stamp < cfg.begin_time then return 0 end
-- 	if stamp < cfg.end_time then return 1 end
-- 	if stamp < cfg.over_time then return 2 end
-- 	return -1
-- end

function M.CheckPermiss()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="rank_buyu_every_week_rank", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end

-- function M.CheckIsInTime()
-- 	local endTime = 1616428799
-- 	if os.time() <= endTime then
-- 		return true
-- 	end
-- 	return false
-- end