-- 创建时间:2020-06-18
-- Act_018_MFCDJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_018_MFCDJManager = {}
local M = Act_018_MFCDJManager
M.key = "act_018_mfcdj"
M.task_id = 21366
GameButtonManager.ExtLoadLua(M.key,"Act_018_MFCDJPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_018_MFCDJCardPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_018_MFCDJEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_018_MFCDJGetAwardPanel")
local config = GameButtonManager.ExtLoadLua(M.key,"activity_018_mfcdj_config")

local this
local lister
--福卡券的数量相比较文档里面的是乘以100了得，目的是为了和资产改变给过来的数据对应
M.base_data = {
    [1] = {[1] = {"jing_bi",400},[2] = {"jing_bi",600},[3] = {"jing_bi",1000},[4] = {"shop_gold_sum",2},[5] = {"shop_gold_sum",3}},
    [2] = {[1] = {"jing_bi",500},[2] = {"jing_bi",800},[3] = {"jing_bi",1200},[4] = {"shop_gold_sum",3},[5] = {"shop_gold_sum",4}},
    [3] = {[1] = {"jing_bi",600},[2] = {"jing_bi",1000},[3] = {"jing_bi",1400},[4] = {"shop_gold_sum",4},[5] = {"shop_gold_sum",5}},
    [4] = {[1] = {"jing_bi",700},[2] = {"jing_bi",1200},[3] = {"jing_bi",1600},[4] = {"shop_gold_sum",5},[5] = {"shop_gold_sum",6}},
    [5] = {[1] = {"jing_bi",800},[2] = {"jing_bi",1400},[3] = {"jing_bi",1800},[4] = {"shop_gold_sum",6},[5] = {"shop_gold_sum",7}},
}  


-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx"}, "CheckIsWQP")
    local is_wqp = false
    if a and b then
        is_wqp = true
    end
    return M.IsNewPlayer() and not is_wqp
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
        return Act_018_MFCDJPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return Act_018_MFCDJEnterPrefab.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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
end

function M.Init()
	M.Exit()

	this = Act_018_MFCDJManager
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
        Network.SendRequest("query_one_task_data", {task_id = M.task_id})
	end
end

function M.OnReConnecteServerSucceed()

end

function M.GetData()
    return GameTaskModel.GetTaskDataByID(M.task_id)
end

function M.on_model_task_change_msg(data)
    if data.id == M.task_id then
        Event.Brocast("act_018_mfcd_refresh")
    end
end

function M.GetWinTimes()
    local data = M.GetData()
    if data then
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status2(b, data, 15)
        local sum = 0

        for i = 1,15 do
            if b[i] ~= 0 then
                sum = sum + 1 
            end
        end
        return sum
    end
    return 0
end

function M.GetFinshTimes()
    local data = M.GetData()
    if data then
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status2(b, data, 15)
        local sum = 0

        for i = 1,15 do
            if b[i] == 2 then
                sum = sum + 1 
            end
        end
        return sum
    end
    return 0
end

function M.on_model_query_one_task_data_response(data)
    if data.id == M.task_id then
        Event.Brocast("act_018_mfcd_refresh")
    end
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

function M.GetFakeAwardData()
    local str = {
        "jing_bi_1",
        "jing_bi_2",
        "jing_bi_3",
        "shop_gold_sum_1",
        "shop_gold_sum_2",
    }
    local data = {}
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local level = math.random(1,#config.base)
    for i = 1,4 do
        
        local index = math.random(1,#str)
        local _type = index <=3 and "jing_bi" or "shop_gold_sum"
        local min   = config.base[level][str[index]][1]
        local max   = config.base[level][str[index]][2]
        if index > 3 then
            min = min * 100
            max = max * 100
        end
        local value = math.random(min ,max)        
        data[#data + 1] = {_type,value}
    end
    return data
end

function M.CanGetAwardIndex()
    local index
    local data = M.GetData()
    if data == nil then return end
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status2(b, data, 15)
    for i = 1,15 do
        if b[i] == 1 then
            index = i
            break 
        end 
    end
    return index
end


function M.CanGetNowLevel()
    local index
    local data = M.GetData()
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status2(b, data, 15)
    local now_max_level = 16
    for i = 1,15 do
        if b[i] == 0 then
            now_max_level = i
            break 
        end
    end
    return now_max_level
end

function M.GetRightSum()
    local data = M.GetData()
    local now_max_level = 15
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status2(b, data, 15)
    for i = 1,15 do
        if b[i] ~= 2 then
            now_max_level = i
            break 
        end
    end
    return M.all_ju_func(now_max_level)
end


function M.all_ju_func(i,sum)
	local ju = {1,1,1,1,1,2,2,2,2,2,3,3,3,3,3}
	sum = sum or 0
	if i < 1 then
		return sum
	else
		sum = ju[i] + sum
		return M.all_ju_func(i-1,sum)
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