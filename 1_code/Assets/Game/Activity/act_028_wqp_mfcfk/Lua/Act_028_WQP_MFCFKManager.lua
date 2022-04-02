-- 创建时间:2020-06-18
-- Act_028_WQP_MFCFKManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_028_WQP_MFCFKManager = {}
local M = Act_028_WQP_MFCFKManager
M.key = "act_028_wqp_mfcfk"
M.task_ids = {}
GameButtonManager.ExtLoadLua(M.key,"Act_028_WQP_MFCFKPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_028_WQP_MFCFKCardPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_028_WQP_MFCFKEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_028_WQP_MFCFKGetAwardPanel")
--local config = GameButtonManager.ExtLoadLua(M.key,"activity_028_MFCFK_config")
M.award_confg = GameButtonManager.ExtLoadLua(M.key,"act_028_wqp_mfcjk_award_config")

local this
local lister
local base_data = {
    [1] = {2,2,2,2,2},
    [2] = {2,2,2,2,2,2,2,2,2,2,},
    [3] = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    [4] = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,},
}
local base_data_first = {
    [1] = {1,2,2,2,2},
    [2] = {2,2,2,2,2,2,2,2,2,2,},
    [3] = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
    [4] = {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,},
}
local task_ids = {21511,21512,21513,21514}

local awards_max = { 0.05, 0.12, 0.4, 1 }

M.task_ids = task_ids

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    local _permission_key = "actp_own_task_p_wqp_duiju_hongbao"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        dump({a,b},"<color=white>actp_own_task_p_wqp_duiju_hongbao免费抽福卡权限</color>")
        if not a or not b then
            return
        end
    end
	return true
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_028_WQP_MFCFKPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return Act_028_WQP_MFCFKEnterPrefab.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState()
    if  M.IsAwardCanGet() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        local newtime = tonumber(os.date("%Y%m%d", os.time()))
        local user_id = MainModel.UserInfo and MainModel.UserInfo.user_id or ""
        local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. user_id, 0))))
        if oldtime ~= newtime then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Red
        end
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
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
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["AssetChange"] = this.OnAssetChange
    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["free_hall_select_index_change"] = this.on_free_hall_select_index_change
    lister["EnterScene"] = this.EnterScene
    lister["ExitScene"] = this.ExitScene
end

function M.Init()
	M.Exit()

	this = Act_028_WQP_MFCFKManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        --Network.SendRequest("query_one_task_data", {task_id = M.task_id})
	end
end

function M.OnReConnecteServerSucceed()

end

function M.GetData(index)
    return GameTaskModel.GetTaskDataByID(task_ids[index])
end

function M.IsFirstGame(index)
    local is_first = false
    if index == 1 then
        local b = GameTaskModel.GetTaskDataByID(task_ids[index])
        if b ~= nil then
            if b.other_data_str ~= nil then
                local c = basefunc.parse_activity_data(b.other_data_str)
                if tonumber(c.is_first_game) == 1 or tonumber(c.is_first_game) == 2 or tonumber(c.is_first_game) == 3 then
                    is_first = true
                end
            end
        end
    end
    return is_first
end

function M.IsCareID(id)
    for i = 1,#task_ids do
        if task_ids[i] == id then
            return true
        end
    end
    return false
end

function M.on_model_task_change_msg(data)
    if data and M.IsCareID(data.id) then
        Event.Brocast("Act_028_WQP_MFCFK_refresh",data.id)
    end
end

--赢得局数
function M.GetWinTimes(index)
    local data = M.GetData(index)
    if data then
        if M.IsFirstGame(index) and index ==1 and data.now_total_process ~=0 then
            return data.now_total_process-1
        end
        return data.now_total_process
    else
        return ""
    end
end

function M.GetFinshTimes()
    return 0
end

function M.on_model_query_one_task_data_response(data)
    if data and M.IsCareID(data.id) then
        Event.Brocast("Act_028_WQP_MFCFK_refresh",data.id)
    end
end

function M.EnterScene(  )
    Event.Brocast("close_Act_028_WQP_MFCFK")
end

function M.ExitScene(  )
    Event.Brocast("close_Act_028_WQP_MFCFK")
end

function M.OnAssetChange(data)
    if data.change_type and data.change_type == "task_p_freestyle_ddz" then
        
    end
end

function M.IsNewPlayer()
    local _permission_key = "actp_own_task_p_freestyle_ddz"
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end
local jing_bi_max = 3
local shop_gold_sum_max = 2

function M.GetFakeAwardData(value)
    local data = M.GetAwardByValue(value)
    local r_d = {}
    for i = 1,#data.award_list do
        local _type = data.award_type
        local v =  data.award_list[i]
        if value ~= v then
            r_d[#r_d + 1] = {_type,v}
        end
    end
    return r_d
end

function M.CanGetAwardIndex(index)

    local cur_data=M.GetCurBaseData(index)
    local data = M.GetData(index)
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status2(b, data, #cur_data[index])
    for i = 1,#cur_data[index] do
        if b[i] == 1 then
            index = i
            break 
        end 
    end
    return index
end


function M.CanGetNowLevel(index)
    local cur_data=M.GetCurBaseData(index)
    local data = M.GetData(index)
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status2(b, data, #cur_data[index])
    local now_max_level = #cur_data[index] + 1
    for i = 1,#cur_data[index] do
        if b[i] == 0 then
            now_max_level = i
            break 
        end
    end
    return now_max_level
end

function M.GetRightSum(index)
    local cur_data=M.GetCurBaseData(index)
    local data = M.GetData(index)
    if not data then
        return M.all_ju_func(1,index)
    end
    local now_max_level = #cur_data[index]
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status2(b, data, #cur_data[index])
    for i = 1,#cur_data[index] do
        if b[i] ~= 2 then
            now_max_level = i
            break 
        end
    end
    return M.all_ju_func(now_max_level,index)
end


function M.all_ju_func(i,index,sum)
    sum = sum or 0
    if i < 1 then
        return sum
    else
        if M.IsFirstGame(index) then
            sum = base_data_first[index][i] + sum
        else
            sum = base_data[index][i] + sum
        end

        return M.all_ju_func(i-1,index,sum)
    end
end


function M.IsNextBeOldPlayer()
    local first_time = MainModel.FirstLoginTime()
    if  first_time + 6 * 86400 + M.get_today_remain_time(first_time) -  86400 < os.time() then
        return true
    else
        return false
    end 
end

function M.get_today_remain_time(_time)
    local day_num = math.floor((_time + 28800) / 86400)
    return (day_num + 1) * 86400 - 28800 - _time
end

function M.GetBaseData()
    return base_data
end

function M.GetBaseDataFirst()
    return base_data_first
end

function M.GetCurBaseData(index)
    if M.IsFirstGame(index) then
        return  base_data_first
    else
        return  base_data
    end
end

function M.IsAwardCanGet()
    for i = 1,4 do
        local data = M.GetData(i)
        if data and data.award_status == 1 then
            return true  
        end
    end
end
local can_show = true
function M.on_free_hall_select_index_change(data)
    if data and data.game_id == 25 then
        can_show = false
    else
        can_show = true
    end
    Event.Brocast("act_028_wqp_btn_refresh")
end

function M.IsCanShowBtn()
    return can_show
end

function M.SetFirstGetAward()
    if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."MFCFK_FIRST1") == 0 then
        PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."MFCFK_FIRST1",1)
    end
end

function M.IsFirstGetAward()
    if not M.CheckIsWQPCPL() then
        return false
    end

    --权限:玩棋牌需要新手引导的权限
    local _permission_key = "wqp_need_novice_guidance"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
    end

    if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."MFCFK_FIRST1") ~= 0 then
        return false
    end
    return true
end

function M.CheckIsWQPCPL()
    if gameMgr:getMarketPlatform() == "wqp" and gameMgr:getMarketChannel() ~= "wqp" then
        return true
    end
end

function M.GetCurAwardByCCJD(cc,jd)
    if not M.award_confg or not M.award_confg["cc_" .. cc] or not M.award_confg["cc_" .. cc][jd] then return end
    return M.award_confg["cc_" .. cc][jd]
end

--！！！这里不同阶段如果有部分奖励相同的话就会有Bug
function M.GetAwardByValue(value)
    if not M.award_confg then return end
    for k,v1 in pairs(M.award_confg) do
        for i,v in ipairs(v1) do
            for j,v2 in ipairs(v.award_list) do
                if v2 == value then
                    return v
                end
            end
        end
    end
end