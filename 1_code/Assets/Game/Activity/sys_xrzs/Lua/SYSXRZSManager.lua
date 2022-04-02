-- 创建时间:2019-05-29
-- Panel:SYSXRZSManager
local basefunc = require "Game/Common/basefunc"

SYSXRZSManager = basefunc.class()
local M = SYSXRZSManager
M.key = "sys_xrzs"
local config = GameButtonManager.ExtLoadLua(M.key, "newplayer_lottery_cfg")
local config_new = GameButtonManager.ExtLoadLua(M.key, "newplayer_lottery_cfg_new")
SYSXRZSManager.config_new = config_new
GameButtonManager.ExtLoadLua(M.key, "SYSXRZSEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "NewPlayerActivityPanel")
GameButtonManager.ExtLoadLua(M.key, "NewPlayerActivityPanelBIG_New")
GameButtonManager.ExtLoadLua(M.key, "NewPlayerActivityPanel_New")
local lister
local m_data
local new_type_info = {
	type = "exclusive_newplayer",
	start_time = 1,
    end_time = 2575302399, 
    config = config_new,
}

function M.CheckIsShow()
	if not M.IsActive()	then
		return
	end
	if LotteryBaseManager.IsRightChannel() then 
		if MainModel.UserInfo.ui_config_id ~= 1 then
			if m_data and m_data.at_status == "END" then
				return
			else
				return true
			end
		end
	end 
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
		if M.ShowOldorNew() == "Old" then 
			return NewPlayerActivityPanel.Create(nil, 1)
		elseif LotteryBaseManager.IsRightChannel() then 
			return NewPlayerActivityPanelBIG_New.Create()
		end 
	elseif parm.goto_scene_parm == "panel_small" then
        return NewPlayerActivityPanel_New.Create(parm.parent, nil)
	elseif parm.goto_scene_parm == "enter" then
		if M.IsActive() then 
			return SYSXRZSEnterPrefab.Create(parm.parent, parm.cfg)
		end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

function M.GetConfig()
	return config
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
	lister["query_new_player_lottery_base_info_response"] = M.SetData
	lister["new_player_lottery_base_info_change"] = M.SetData
	lister["get_one_common_lottery_info"] = M.SetData
    lister["OnLoginResponse"] = M.OnLoginResponse
	lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
	lister["global_hint_state_set_msg"] = M.SetHintState
end

function M.Init()
	M.Exit()
	m_data = {}
	MakeLister()
	AddLister()
	if M.ShowOldorNew() == "New" then 
		LotteryBaseManager.AddQuery(new_type_info)
	end 
end

function M.Exit()
	if M then
		RemoveLister() 
	end
end

-- 数据更新
function M.UpdateData()
	print("请求新人专属数据")
	if MainModel.UserInfo.ui_config_id == 2 then
		if M.ShowOldorNew() == "Old" then 
			Network.SendRequest("query_new_player_lottery_base_info", nil, "")
		else
			Network.SendRequest("query_common_lottery_base_info", {lottery_type = new_type_info.type})
		end 
    end
end

function M.SetData(_,data)
	dump(data, "<color=red>SetData</color>")
	if MainModel.UserInfo.ui_config_id ~= 2 then return end  
	if M.ShowOldorNew() == "Old" and data  then 
		dump(data, "<color=red>SetData</color>")
		m_data.at_data = data
		m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
		if not data.over_time or data.over_time <= os.time() or MainModel.UserInfo.ui_config_id ~= 2  then
			m_data.at_status = "END"
		elseif data.now_game_num >= 10 then
			m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
		elseif data.need_credits and data.now_credits then 
			if data.need_credits <= data.now_credits then
				m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Get
			end 
		end
	elseif M.ShowOldorNew() == "New" then 
		m_data.at_data = LotteryBaseManager.GetData(new_type_info.type)
		if M.GetLotteryTimes_New() >= 5 then 
			m_data.at_status = "END"
		elseif LotteryBaseManager.IsAwardCanGet(new_type_info.type) then
			m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Get
		else
			m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
		end 
	end 
	Event.Brocast("ui_button_data_change_msg", {key = M.key})
	Event.Brocast("global_hint_state_set_msg", {gotoui = M.key})
end

function M.OnLoginResponse(result)
	if result == 0 then
		Timer.New(function ()
			M.UpdateData()		
		end, 3, 1):Start()
	end
end

function M.OnReConnecteServerSucceed()
	if m_data.at_data then
		Event.Brocast("ui_button_data_change_msg", {key = M.key})
	else
		M.UpdateData()
	end
end

-- 活动的提示状态
function M.GetHintState(parm)
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
	local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
	if LotteryBaseManager.IsAwardCanGet(new_type_info.type) then 
		return ACTIVITY_HINT_STATUS_ENUM.AT_Get
	else
		if oldtime ~= newtime then
			return ACTIVITY_HINT_STATUS_ENUM.AT_Red
		end
	end 
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

function M.SetHintState(parm)
	if parm.gotoui == M.key then
		PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
		Event.Brocast("global_hint_state_change_msg", parm)
	end
end

--展示新版或旧的新人专属 -- 1576711800 12月19日7；30的时间点后用另外一套
function M.ShowOldorNew()
	if MainModel.FirstLoginTime() > 1576711800 then
		return "New"
	else
		return "Old"
	end 
end

function M.CheckIsShowInActivity( )
	return M.IsActive()
end

function M.IsActive()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_common_lottery_exclusive_newplayer", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return os.time() - MainModel.FirstLoginTime() < 7 * 86400
end

function M.GetLotteryTimes_New()
	dump(LotteryBaseManager.GetData(new_type_info.type),"<color=red>新人专属的数据</color>")
	if LotteryBaseManager.GetData(new_type_info.type) then 
		return LotteryBaseManager.GetData(new_type_info.type).now_game_num
	end
	return 0 
end

function M.IsCanLottery()
	local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_common_lottery_award_exclusive_newplayer"}, "CheckCondition")
    if a and not b then
		return false
    end
    return true
end