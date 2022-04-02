-- 创建时间:2020-05-27
-- Act_016_CPLXRQTLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_016_CPLXRQTLManager = {}
local M = Act_016_CPLXRQTLManager
M.key = "act_016_cplxrqtl"
GameButtonManager.ExtLoadLua(M.key,"Act_016_CPLXRQTLLBPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_016_CPLXRQTLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_016_CPLXRQTLPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_016_CPLXRQTLCHBPanel")

M.shop_id = 10306
M.total_task_id = 21355
M.task_id = 21354
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    --玩棋牌优化(2021.3.9),玩棋牌CPL渠道
    --3.9号之后注册的玩棋牌CPL渠道新玩家，显示新版迎新红包(act_052_yxhb)，不显示旧版迎新红包(act_016_cplxrqtl)
    if M.IsYxhbView() then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_cpl_daily_task"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return  M.IsBtnShow()
    else
        return  M.IsBtnShow()
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

function M.IsYxhbView() 
    local _permission_key = "actp_own_task_p_new_player_red_bag"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then 
            return Act_016_CPLXRQTLPanel.Create(parm.parent,parm.backcall)
        end 
    end 
    if parm.goto_scene_parm == "get_award" then
        if M.IsCanGetAward() and MainModel.UserInfo.xsyd_status == 1  then
            return Act_016_CPLXRQTLCHBPanel.Create(parm.parent,parm.backcall)
        end
    end 
    if parm.goto_scene_parm == "enter" then
        return Act_016_CPLXRQTLEnterPrefab.Create(parm.parent)
    end 
    --dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response
    lister["newplayer_guide_finish"] = this.on_newplayer_guide_finish
    lister["model_task_change_msg"] = this.model_task_change_msg
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_016_CPLXRQTLManager
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
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Network.SendRequest("query_one_task_data",{task_id = M.task_id})
	end
end

function M.OnReConnecteServerSucceed()

end

--新手引导完成
function M.on_newplayer_guide_finish()
    if M.IsCanGetAward() and  M.IsActive() then
        Act_016_CPLXRQTLCHBPanel.Create()
    end
end

--从1开始
function M.GetDayIndex()
    local first_start_time = M.GetStartTime()
    local t1 = basefunc.get_today_id(first_start_time)
    local t2 = basefunc.get_today_id(os.time())
    return  t2 - t1 < 1 and 1 or t2 - t1 + 1
end

function M.model_query_one_task_data_response(data)
    if data and data.id == M.task_id then
        
    end
end

--今天是否可以领奖
function M.IsCanGetToday()
    -- body
end

function M.model_task_change_msg(data)
    if data and data.id == M.task_id then
        Event.Brocast("cplxrqtl_task_change")
    end
end

function M.IsNew()
    local first_login_time = MainModel.FirstLoginTime()
    if os.time() < first_login_time + 7 * 86400 then
        return true
    end
end

function M.IsCanGetAward()
    if M.IsBtnShow() and M.GetTodayNum() == 0 then
        return true
    end
end
--获取每日得到多少钱
function M.GetTodayNum()
    local task_data = GameTaskModel.GetTaskDataByID(M.task_id)
    --dump(task_data)
    if task_data and task_data.other_data_str then
        local data =  basefunc.parse_activity_data(task_data.other_data_str)
        dump(data)
        return data.get_award_map[M.GetDayIndex()] or 0
    end
    return 0
end

function M.GetTotalNum()
    local task_data = GameTaskModel.GetTaskDataByID(M.task_id)
    if task_data and task_data.other_data_str then 
        local data =  basefunc.parse_activity_data(task_data.other_data_str)
        local sum = 0
        for k ,v in pairs(data.get_award_map) do
            sum = sum + v
        end
        return sum
    end
    return 0 
end

function M.GetDayNum(Index)
    local task_data = GameTaskModel.GetTaskDataByID(M.task_id)
    if task_data and task_data.other_data_str then
        local data =  basefunc.parse_activity_data(task_data.other_data_str)
        return data.get_award_map[Index]
    end
end

function M.GetStartTime()
    local task_data = GameTaskModel.GetTaskDataByID(M.task_id)
    if task_data and task_data.other_data_str then
        local data =  basefunc.parse_activity_data(task_data.other_data_str)
        return  tonumber(data.first_get_time)
    end
    return 0
end

function M.IsBtnShow()
    -- 如果第一天就没有领取过奖励
    if not M.GetDayNum(1) then
        return M.IsNew()
    else
        return M.GetStartTime() + 6 * 86400 + M.get_today_remain_time(M.GetStartTime())  > os.time()
    end
end

function M.get_today_remain_time(_time)
    local day_num = math.floor((_time + 28800) / 86400)
    return (day_num + 1) * 86400 - 28800 - _time
end
