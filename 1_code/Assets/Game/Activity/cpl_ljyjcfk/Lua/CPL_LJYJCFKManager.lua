local basefunc = require "Game/Common/basefunc"
CPL_LJYJCFKManager = {}
local M = CPL_LJYJCFKManager
M.key = "cpl_ljyjcfk"
GameButtonManager.ExtLoadLua(M.key,"CPL_LJYJCFKPanel")
GameButtonManager.ExtLoadLua(M.key,"CPL_LJYJCFKCardPrefab")
GameButtonManager.ExtLoadLua(M.key,"CPL_LJYJCFKEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"CPL_LJYJCFKLotteryPanel")
GameButtonManager.ExtLoadLua(M.key,"CPL_LJYJCFKLotteryPrefab")
GameButtonManager.ExtLoadLua(M.key,"CPL_LJYJCFKTCPanel")

GameButtonManager.ExtLoadLua(M.key,"CPL_LJYJCFK_CJXXLPrefab")
GameButtonManager.ExtLoadLua(M.key,"CPL_LJYJCFKGetAwardPanel")
M.config = GameButtonManager.ExtLoadLua(M.key,"cpl_ljyjcfk_config")

local b = true
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    print("<color=red>PPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP</color>")

    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return
    end

    local _permission_key = "actp_own_task_p_wqp_minigame_cumulative_wingold" --小游戏累计赢金（玩棋牌特有）
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if not a or not b then
            return
        end
    end
    
    if not M.GetData() then
        return  false
    end

    if not M.GetData() then
        return  false
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
        return CPL_LJYJCFKPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        return CPL_LJYJCFKEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel_lottery" then
        return CPL_LJYJCFKLotteryPanel.Create(parm,parm.parent)
    elseif parm.goto_scene_parm == "panel_tc" then
        return CPL_LJYJCFKTCPanel.Create(parm,parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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
    lister["EnterScene"] = this.OnEnterScene
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
    lister["model_get_task_award_response"] = this.on_model_get_task_award_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = CPL_LJYJCFKManager
    this.m_data = {}
    M.InitUIConfig()
	MakeLister()
    AddLister()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    if b then
        for i=1,#M.config.base do
            M.config.base[i].show_hb = M.config.base[i].show_hb / 100
            for j=1,#M.config.base[i].hb do
                M.config.base[i].hb[j] = M.config.base[i].hb[j] / 100
            end
        end

        M.task_id = M.config.base[1].task
        M.task_c = #M.config.base
        b = false
    end
end

function M.OnLoginResponse(result)
	if result ~= 0 then return end
    -- 数据初始化
    Network.SendRequest("query_one_task_data", {task_id = M.task_id})
end

function M.OnReConnecteServerSucceed()

end

function M.GetData()
    return GameTaskModel.GetTaskDataByID(M.task_id)
end

function M.on_model_task_change_msg(data)
    if data.id ~= M.task_id then return end
    dump(data,"<color=green>CPL玩棋牌累计赢金抽福卡任务</color>")
    Event.Brocast("cpl_ljyjcfk_refresh")
end

function M.GetWinTimes()
    local data = M.GetData()
    if data then
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status2(b, data, M.task_c)
        local sum = 0

        for i = 1,M.task_c do
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
        b = basefunc.decode_all_task_award_status2(b, data, M.task_c)
        local sum = 0

        for i = 1,M.task_c do
            if b[i] == 2 then
                sum = sum + 1 
            end
        end
        return sum
    end
    return 0
end

function M.on_model_query_one_task_data_response(data)
    if data.id ~= M.task_id then return end
    dump(data,"<color=green>CPL玩棋牌累计赢金抽福卡任务</color>")
    Event.Brocast("cpl_ljyjcfk_refresh")
end

function M.on_model_get_task_award_response(data)
    if not data or data.id ~= M.task_id then return end
    --M.SetFirstGetAward()
    Event.Brocast("cpl_ljyjcfk_get_task_award_response",data)
end

local jing_bi_max = 3
local shop_gold_sum_max = 2

function M.CanGetAwardIndex()
    local index
    local data = M.GetData()
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status2(b, data, M.task_c)
    for i = 1,M.task_c do
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
    b = basefunc.decode_all_task_award_status2(b, data, M.task_c)
    local now_max_level = M.task_c + 1
    for i = 1,M.task_c do
        if b[i] == 0 then
            now_max_level = i
            break 
        end
    end
    return now_max_level
end

function M.GetRightSum()
    local data = M.GetData()
    local now_max_level = M.task_c
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status2(b, data, M.task_c)
    for i = 1,M.task_c do
        if b[i] ~= 2 then
            now_max_level = i
            break 
        end
    end
    return M.all_ju_func(now_max_level)
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

function M.GetHBRateConfigByIDIndex(lv)
    if not lv then return end
    return M.config.base[lv].hb
end

function M.GetCurTaskFinishLv()
    local td = M.GetData()
    if not td then return 0 end
    return td.now_lv - 1
end

function M.CheckMiniGame(parm)
    local is_active = M.IsActive()
    if is_active then
        GameManager.GotoUI({gotoui = M.key,goto_scene_parm = "panel_tc",callback = parm.callback})
    end
    return is_active
end

function M.SetFirstGetAward()
    if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."LJYJCFK_FIRST2") == 0 then
        PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."LJYJCFK_FIRST2",1)
    end
end

function M.IsFirstGetAward()

    if not M.CheckIsWQPCPL() then
        return false
    end

    if PlayerPrefs.GetInt(MainModel.UserInfo.user_id .. "LJYJCFK_FIRST2") ~= 0 then
        return false
    end

    return true
end

function M.CheckIsWQPCPL()
    if gameMgr:getMarketPlatform() == "wqp" then 
        return true
    end
end
function M.OnEnterScene()
    dump(MainModel.myLocation,"<color=red>3333333333333</color>")
    if MainModel.myLocation == "game_EliminateCJ" and M.IsActive() then
        CPL_LJYJCFK_CJXXLPrefab.Create()
    end
end