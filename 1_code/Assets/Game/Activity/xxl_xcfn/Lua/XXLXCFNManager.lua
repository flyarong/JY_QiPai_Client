-- 创建时间:2019-05-29
-- Panel:XXLXCFNManager
local basefunc = require "Game/Common/basefunc"

XXLXCFNManager = basefunc.class()
local M = XXLXCFNManager
M.key = "xxl_xcfn"
M.lottery_type = "19_october_lottery"--开奖唯一表示
GameButtonManager.ExtLoadLua(M.key, "XXLXCFNEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Lottery10YuePanelBIG")
GameButtonManager.ExtLoadLua(M.key, "JF10YueRankPanel")
local config = GameButtonManager.ExtLoadLua(M.key, "10yue_lottery_cfg")
local config_rank = GameButtonManager.ExtLoadLua(M.key, "10yue_rank_activity_config")
local lister
local m_data

function M.CheckIsShow()
	if not m_data.base_info then return end
	return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return Lottery10YuePanelBIG.Create()
    elseif parm.goto_scene_parm == "enter" then
		return XXLXCFNEnterPrefab.Create(parm.parent, parm.cfg)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig()
	return config
end

function M.GetConfigRank(  )
	return config_rank
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

	lister["yueka_upgrade_asset_change_msg"] = M.set_yk_upgrade

	lister["common_lottery_base_info_change"] = M.common_lottery_base_info
	lister["query_common_lottery_base_info_response"] = M.common_lottery_base_info

	lister["common_lottery_kaijaing_response"] = M.common_lottery_kaijaing
	lister["common_lottery_get_broadcast_response"] = M.common_lottery_get_broadcast
end

function M.set_yk_upgrade(_,data)
	m_data.upgrade = data
	Event.Brocast("sys_yk_manager_yueka_upgrade_asset",data)
end

function M.common_lottery_kaijaing(data)
	if not data or data.lottery_type ~= M.lottery_type then return end
	m_data.kaijiang = data
	Event.Brocast("xxl_xcfn_common_lottery_kaijaing",data)
end

function M.common_lottery_get_broadcast(data)
	if not data or data.lottery_type ~= M.lottery_type then return end
	m_data.broadcast = data
	Event.Brocast("xxl_xcfn_common_lottery_get_broadcast",data)
end

function M.common_lottery_base_info(_,data)
	dump(data, "<color=wite>消消乐消除烦恼： base_data</color>")
	if data.lottery_type ~= M.lottery_type then return end
	m_data.base_info = data
	Event.Brocast("xxl_xcfn_common_lottery_base_info",data)

	Event.Brocast("ui_button_data_change_msg", {key = M.key})
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
	Network.SendRequest("query_common_lottery_base_info", { lottery_type = M.lottery_type }, "")
end

function M.OnLoginResponse(result)
	if result == 0 then
		Timer.New(function ()
			M.UpdateData()		
		end, 3, 1):Start()
	end
end

function M.OnReConnecteServerSucceed()
	M.UpdateData()
end

-- 活动的提示状态
function M.GetHintState(parm)
	local data = M.GetBaseData()
	if data then
		local config = M.GetConfig()
		local now_game_num = data.now_game_num
		if now_game_num > 9 then  now_game_num = 9 end 
		if 	data.ticket_num >= config.JP1[now_game_num + 1].need_credits then
			return ACTIVITY_HINT_STATUS_ENUM.AT_Get
		end
	end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.SetHintState(parm)
	if parm.gotoui == M.key then
		Event.Brocast("global_hint_state_change_msg", parm)
	end
end

function M.GetBaseData()
	if m_data.base_info then
		return m_data.base_info
	end
	M.UpdateData()
end