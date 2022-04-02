-- 创建时间:2019-10-23
-- JYZKManager

local basefunc = require "Game/Common/basefunc"
JYZKManager = {}
local M = JYZKManager
M.key = "jyzk"
GameButtonManager.ExtLoadLua(M.key, "JYZK_JYFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActivityShop20Panel")
GameButtonManager.ExtLoadLua(M.key, "JYZKEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "JYZKNewPanel")

M.JB_TASK_ID = 53
M.QYS_TASK_ID = 54

local this
local lister
local m_data
local jb_data_remain_num = 0
function M.CheckIsShow()
	if not this.m_data.jb_task_data or jb_data_remain_num <= 0 then 
		return
	end
    return true
end
function M.CheckIsShowInJYFL(parm)
	return true
end
function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
		if not this.m_data.jb_task_data or jb_data_remain_num <= 0 then 
			return
		end
    	if M.IsBuyQYSZK() then
	        return ActivityShop20Panel.Create()
    	else
            return JYZKNewPanel.Create()
		end
    elseif parm.goto_scene_parm == "enter" then
    	return JYZKEnterPrefab.Create(parm.parent, parm)
	elseif parm.goto_scene_parm == "jyfl_enter" then
		if not this.m_data.jb_task_data or jb_data_remain_num <= 0 then 
			return
		end
    	return JYZK_JYFLEnterPrefab.Create(parm.parent, parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString("HallXYCJHintTime" .. MainModel.UserInfo.user_id, 0))))
	if parm and parm.goto_scene_parm == "jb" then 
		local has_award =  ActivityShop20Panel.CheckTaskActivity(JYZKManager.JB_TASK_ID)
		local m_data = JYZKManager.m_data.jb_data
		if m_data then 
			local next_get_day = m_data.next_get_day or 0
			if has_award and next_get_day == 0 then
				return ACTIVITY_HINT_STATUS_ENUM.AT_Red
			else
				return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
			end
		end  
	end 
	if parm and parm.goto_scene_parm == "qys" then 
		local has_award =  ActivityShop20Panel.CheckTaskActivity(JYZKManager.QYS_TASK_ID)
		local m_data = JYZKManager.m_data.qys_data
		if m_data then 
			local next_get_day = m_data.next_get_day or 0
			if has_award and next_get_day == 0 then
				return ACTIVITY_HINT_STATUS_ENUM.AT_Red
			else
				return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
			end
		end  
	end 
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
function M.SetHintState()
	PlayerPrefs.SetString("HallXYCJHintTime" .. MainModel.UserInfo.user_id, os.time())
	Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
	
	-- 周卡任务数据
    -- lister["model_query_one_task_data_response"] = this.handle_one_task_data_response
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
    -- 千元赛周卡数据
    lister["query_qys_zhouka_remain_response"] = this.on_query_qys_zhouka_remain_response
    lister["qys_zhouka_remain_change_msg"] = this.on_qys_zhouka_remain_change_msg

    -- 鲸币周卡数据
    lister["query_jingbi_zhouka_remain_response"] = this.on_query_jingbi_zhouka_remain_response
    lister["jinbgi_zhouka_remain_change_msg"] = this.on_jinbgi_zhouka_remain_change_msg
end

function M.Init()
	M.Exit()

	this = JYZKManager
	this.m_data = {}
	MakeLister()
    AddLister()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
-- 数据更新
function M.UpdateData()
	-- print("请求幸运抽奖数据")
	-- Network.RandomDelayedSendRequest("query_one_task_data", {task_id = M.JB_TASK_ID})
	-- Network.RandomDelayedSendRequest("query_one_task_data", {task_id = M.QYS_TASK_ID})
end

function M.OnLoginResponse(result)
	if result == 0 then
		M.UpdateData()
	end
end
function M.OnReConnecteServerSucceed()
	M.UpdateData()
end

function M.CheckTaskActivity(task_id)
	local task_data = GameTaskModel.GetTaskDataByID(task_id)
	if not task_data then return false end

	local award_status = basefunc.decode_task_award_status(task_data.award_get_status)
	for k, v in pairs(award_status) do
		if not v then
			return true
		end
	end

	return false
end

-- function M.handle_one_task_data_response(data)
-- 	if data and data.id and (data.id == M.JB_TASK_ID or data.id == M.QYS_TASK_ID) then
-- 		dump(data, "<color=red>ACT JYZKManager handle_one_task_data_response</color>")
-- 		if data.id == M.QYS_TASK_ID then
-- 			this.m_data.qys_task_data = data
-- 			Network.SendRequest("query_qys_zhouka_remain")
-- 		end
-- 		if data.id == M.JB_TASK_ID then
-- 			this.m_data.jb_task_data = data
-- 			Network.SendRequest("query_jingbi_zhouka_remain")
-- 		end
-- 	end
-- end

function M.HandleTaskData()
	if data and data.id and (data.id == M.JB_TASK_ID or data.id == M.QYS_TASK_ID) then
		dump(data, "<color=red>ACT JYZKManager handle_one_task_data_response</color>")
		if data.id == M.QYS_TASK_ID then
			this.m_data.qys_task_data = data
			Network.SendRequest("query_qys_zhouka_remain")
		end
		if data.id == M.JB_TASK_ID then
			this.m_data.jb_task_data = data
			Network.SendRequest("query_jingbi_zhouka_remain")
		end
	end
end

function M.on_model_query_task_data_response()
    local data = GameTaskModel.GetTaskDataByID()
    --dump(data,"<color=red>+++++on_model_query_task_data_response+++++</color>")
    if data then
        for k,v in pairs(data) do
            M.HandleTaskData(v)
        end
    end
end

function M.on_query_qys_zhouka_remain_response(_, data)
	dump(data, "<color=red>ACT JYZKManager on_query_qys_zhouka_remain_response</color>")
	this.m_data.qys_data = data

	Event.Brocast("ui_button_data_change_msg", {key = M.key, goto_scene_parm="qys"})
	Event.Brocast("global_hint_state_change_msg", {gotoui=M.key, goto_scene_parm="qys"})
end
function M.on_qys_zhouka_remain_change_msg(_, data)
	dump(data, "<color=red>ACT JYZKManager on_qys_zhouka_remain_change_msg</color>")
	if this.m_data.qys_data then
		this.m_data.qys_data.remain_num = data.task_remain
		Event.Brocast("ui_button_data_change_msg", {key = M.key, goto_scene_parm="qys"})
		Event.Brocast("global_hint_state_change_msg", {gotoui=M.key, goto_scene_parm="qys"})
	end
end
function M.on_query_jingbi_zhouka_remain_response(_, data)
	dump(data, "<color=red>ACT JYZKManager on_query_jingbi_zhouka_remain_response</color>")
	this.m_data.jb_data = data
	jb_data_remain_num = data.remain_num
	Event.Brocast("ui_button_data_change_msg", {key = M.key, goto_scene_parm="jb"})
	Event.Brocast("global_hint_state_change_msg", {gotoui=M.key, goto_scene_parm="jb"})
end
function M.on_jinbgi_zhouka_remain_change_msg(_, data)
	dump(data, "<color=red>ACT JYZKManager on_jinbgi_zhouka_remain_change_msg</color>")
	if this.m_data.jb_data then
		this.m_data.jb_data.remain_num = data.task_remain
		Event.Brocast("ui_button_data_change_msg", {key = M.key, goto_scene_parm="jb"})
		Event.Brocast("global_hint_state_change_msg", {gotoui=M.key, goto_scene_parm="jb"})
	end
end

function M.IsBuyJBZK()
	local task_data = GameTaskModel.GetTaskDataByID(M.JB_TASK_ID)
	local zk_data = this.m_data.jb_data
	if (not zk_data or not zk_data.remain_num or zk_data.remain_num <= 0) or not task_data then
		return false
	else
		return true
	end	
end
function M.IsBuyQYSZK()
	local task_data = GameTaskModel.GetTaskDataByID(M.QYS_TASK_ID)
	local zk_data = this.m_data.qys_data
	if (not zk_data or not zk_data.remain_num or zk_data.remain_num <= 0) or not task_data then
		return false
	else
		return true
	end	
end
