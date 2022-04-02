-- 创建时间:2019-05-29
-- Panel:SYSYKManager
local basefunc = require "Game/Common/basefunc"

SYSYKManager = basefunc.class()
local M = SYSYKManager
M.key = "sys_yk"
M.task_id_list = {65,66}
M.task_id_hash = {[65] = 65,[66] = 66}
GameButtonManager.ExtLoadLua(M.key, "SYSYKEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ShopYueKaPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSYK_JYFLEnterPrefab")
local config = GameButtonManager.ExtLoadLua(M.key, "shop_yueka_config")
local lister
local m_data
local cha_time = 0
local main_timer
local this
SYSYKManager.IsBuy = false
SYSYKManager.IsLJ = false
SYSYKManager.IsBuy1 = false
SYSYKManager.IsBuy2 = false
SYSYKManager.CanBuy2 = false
SYSYKManager.BestShopLevel = 0
function M.CheckIsShow(paem, ui_type)
	if not m_data.base_info then return end

	if ui_type and (ui_type == "ddz_free_js" or ui_type == "pdk_free_js") then
		if SYSYKManager.IsBuy then
			return false
		end
	end
	return true
end
--4/27日
--只有购买了并且还没有领取完奖励的玩家可以显示
function M.CheckIsShowInJYFL(parm)
	local data =  M.GetBaseData()
	if data and M.GetServerTime() < data.task_over_time then
		return true
	else
		return false
	end
end
function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return ShopYueKaPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
		return SYSYKEnterPrefab.Create(parm.parent, parm.cfg)
	elseif parm.goto_scene_parm == "jyfl_enter" then
		if M.CheckIsShowInJYFL(parm) then
	        return SYSYK_JYFLEnterPrefab.Create(parm.parent, parm.cfg)
		end
	elseif parm.goto_scene_parm == "panel_act" then
		return ShopYueKaPanel.Create(nil,nil,"activity",parm.parent)
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
    lister["OnLoginResponse"] = M.OnLoginResponse
	lister["ReConnecteServerSucceed"] = M.OnReConnecteServerSucceed
	--lister["EnterForeGround"] = M.OnReConnecteServerSucceed
	lister["global_hint_state_set_msg"] = M.SetHintState

	lister["yueka_upgrade_asset_change_msg"]=M.set_yk_upgrade
	lister["query_yueka_base_info_response"]=M.set_yk_base_info
	lister["yueka_base_info_change_msg"]=M.set_yk_base_info
	lister["model_query_one_task_data_response"] = M.set_yk_task_data
	lister["model_task_change_msg"]=M.set_yk_task_data
end

function M.set_yk_upgrade(_,data)
	m_data.upgrade = data
	Event.Brocast("sys_yk_manager_yueka_upgrade_asset",data)
end

function M.set_yk_task_data(data)
	if not data or not M.task_id_hash[data.id] then return end
	m_data.task_data = m_data.task_data or {}
	m_data.task_data[data.id] = {}
	m_data.task_data[data.id] = data
	Event.Brocast("sys_yk_manager_task_change",data)
	Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
end

function M.set_yk_base_info(_,data)
	dump(data, "<color=red>set_yk_base_info</color>")
	m_data.base_info = data
	Event.Brocast("sys_yk_manager_yueka_base_info",data)
	if data.is_buy_yueka2== 1 then				 
		Network.SendRequest("query_one_task_data", {task_id = M.task_id_hash[66]})
	elseif data.is_buy_yueka2== 0 and data.is_buy_yueka1 == 1  then 
		Network.SendRequest("query_one_task_data", {task_id = M.task_id_hash[65]})
	end
	data.server_time = data.server_time or os.time()	
	cha_time = data.server_time - os.time()
	if data.is_buy_yueka2==1 then
		SYSYKManager.IsBuy2=true
	else
		SYSYKManager.IsBuy2=false
	end 
	if data.is_buy_yueka1==1 then
		SYSYKManager.IsBuy1=true
	else
		SYSYKManager.IsBuy1=false
	end 
	if (data.is_buy_yueka2 + data.is_buy_yueka1 > 0) and data.task_over_time > data.server_time then
		SYSYKManager.IsBuy=true
	else
		SYSYKManager.IsBuy=false
	end 
	--Event.Brocast("ui_button_data_change_msg", {key = M.key})
	Event.Brocast("global_hint_state_change_msg", {gotoui = M.key})
end

function M.Init()
	M.Exit()
	this = M
	m_data = {}
	MakeLister()
	AddLister()
	M.InitTimer()
end

function M.Exit()
	if M then
		RemoveLister() 
	end
end

-- 数据更新
function M.UpdateData()
	Network.SendRequest("query_yueka_base_info",nil,"")
end

function M.OnLoginResponse(result)
	if result == 0 then
		M.UpdateData()		
	end
end

function M.OnReConnecteServerSucceed()
	M.UpdateData()
end

-- 活动的提示状态
function M.GetHintState(parm)
	if m_data.task_data then
		for k,data in pairs(m_data.task_data) do
			local b        
			b = basefunc.decode_task_award_status(data.award_get_status)
			b = basefunc.decode_all_task_award_status(b, data, 1)
			if b[1] == 1 then
				SYSYKManager.IsLJ = true
				return ACTIVITY_HINT_STATUS_ENUM.AT_Get
			end
		end
	end
	SYSYKManager.IsLJ = false
	if PlayerPrefs.GetInt(M.key .. MainModel.UserInfo.user_id ..os.date("%x",os.time()),0) == 1 then
		return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
	else
		return ACTIVITY_HINT_STATUS_ENUM.AT_Red
	end
end

function M.SetHintState(parm)
	if parm.gotoui == M.key then
		PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id  ..os.date("%x",os.time()),1)
		Event.Brocast("global_hint_state_change_msg", parm)
	end
end

function M.GetBaseData()
	if m_data.base_info then
		return m_data.base_info
	end
	M.UpdateData()
end

function M.GetBestLevel()
	local data =  M.GetBaseData()
	if  data then
		if data.is_buy_yueka1 == 1 and data.is_buy_yueka2 ==1 and  M.GetServerTime() < data.task_over_time  then 
			BestShopLevel = 0
		elseif  data.is_buy_yueka1==1 and data.is_buy_yueka2 ==0 and M.GetServerTime() < data.task_over_time then 			
			BestShopLevel = 2
		elseif  data.is_buy_yueka2==1 and M.GetServerTime() > data.task_over_time then 			
			BestShopLevel = 3
		elseif data.is_buy_yueka1==1 and data.is_buy_yueka2==0 and M.GetServerTime() > data.task_over_time then 
			BestShopLevel = 1
		elseif data.task_over_time==0 then 
			BestShopLevel = 1
		end
	end
	return BestShopLevel
end

function M.GetServerTime()
	return os.time() + cha_time 
end

function M.Is_Can_Buy_yueka2()
	if self.yueka_realtime == nil then return end
	self.yueka_realtime = self.yueka_realtime - 1
	if self.yueka_realtime <= 1 then
		SYSYKManager.CanBuy2 = false
	else
		SYSYKManager.CanBuy2 = true
	end
end

function M.InitTimer()
    if this.main_timer then
        this.main_timer:Stop()
        this.main_timer = nil
    end
    M.DoAt1s()
    this.main_timer = Timer.New(function()
        M.DoAt1s()
    end, 1, -1)
    this.main_timer:Start()
end
--每一秒做什么
function M.DoAt1s()
    M:Is_Can_Buy_yueka2()
end


function M.Is_Can_Buy_yueka2()
	if M.GetServerTime() <= 1 then
		SYSYKManager.CanBuy2 = false
	else
		SYSYKManager.CanBuy2 = true
	end
end