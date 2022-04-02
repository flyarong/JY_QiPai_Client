-- 创建时间:2021-02-24
-- Act_052_JBZKManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_052_JBZKManager = {}
local M = Act_052_JBZKManager
M.key = "act_052_jbzk"
GameButtonManager.ExtLoadLua(M.key, "Act_052_JBZKPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_052_JBZKEnterPrefab")
local this
local lister
local is_new_player = false
local is_during_act = false
local award_data = 0
local active_time = 0
-- 是否有活动
function M.IsActive()
    if gameMgr:getMarketPlatform() == "wqp" and not is_during_act then
        return false
    end
    -- return AdvertisingManager.IsCanWatchAD() and (os.time() < M.GetOverTimer(active_time) or os.time() < M.GetOverTimer(MainModel.FirstLoginTime()))
    return os.time() < M.GetOverTimer(active_time) or os.time() < M.GetOverTimer(MainModel.FirstLoginTime())
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end

	if parm.goto_scene_parm == "panel" then
		return Act_052_JBZKPanel.Create(parm.parent)
	elseif parm.goto_scene_parm == "enter" then
		return Act_052_JBZKEnterPrefab.Create(parm.parent)
	end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    local data = M.GetList()
    if data then
        for i = 1,M.GetDayIndex() do
            if data[i] == 0 then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Get
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
    lister["query_jbzk_info_response"] = this.on_query_jbzk_info_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_052_JBZKManager
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
        Network.SendRequest("query_jbzk_info")
	end
end

function M.on_query_jbzk_info_response(_,data)
    if data.result == 0 then
        if os.time() - data.active_time < 7 * 86400 then
            is_during_act = true
            award_data = data.award_data
            active_time = data.active_time
        end
        Event.Brocast("jbzk_refresh")
        M.SetHintState()
    end
end

function M.IsAct()
    return is_during_act
end

function M.GetList()
    local len = 7
    local re = {}

    local g_func
    g_func = function(num,l)
        local r = num % 2
        num = math.floor(num / 2)
        if l >= len then
            return
        else      
            table.insert(re, r)
            g_func(num,l + 1)
        end
    end
    g_func(award_data,0)
    return re
end

function M.GetDayIndex()
    local t1 = basefunc.get_today_id(active_time)
    local t2 = basefunc.get_today_id(os.time())
    return  t2 - t1 + 1
end

function M.GetActiveTime()
    return active_time
end

function M.OnReConnecteServerSucceed()

end

function M.GetOverTimer(start_time)
    return start_time + 6 * 86400 + M.get_today_remain_time(start_time) 
end

function M.get_today_remain_time(_time)
    local day_num = math.floor((_time + 28800) / 86400)
    return (day_num + 1) * 86400 - 28800 - _time
end
