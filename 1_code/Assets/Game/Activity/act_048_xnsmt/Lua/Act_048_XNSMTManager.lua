-- 创建时间:2021-01-18
-- Act_048_XNSMTManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_048_XNSMTManager = {}
local M = Act_048_XNSMTManager
M.key = "act_048_xnsmt"
local config = GameButtonManager.ExtLoadLua(M.key, "act_048_xnsmt_config")
GameButtonManager.ExtLoadLua(M.key,"Act_048_XNSMTEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_048_XNSMTPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_048_XNSMTFAQPanel")

local this
local lister

M.item_key = "prop_maotai_suipian" --茅台碎片
M.lottery_item_key = "prop_050_mtcjq" --抽奖券
M.collect_task_id = 21677
M.box_exchange_id = 161

--有可能返回的Id
M.box_exchange_id_re1 = 159
M.box_exchange_id_re2 = 160


M.help_info = 
{
    "1.	活动期间，完成任务可获得茅台抽奖券，有机会获得飞天茅台",
    "2.	为避免恶意刷量，被邀请的玩家中，有效玩家占比不得低于50%，否则视为有刷量嫌疑，在游戏中成功进行一次兑出且游戏行为正常视为有效",
    "3.	严禁进行刷量行为，一经发现，不予发放任何奖励",
    "4.	本公司保留在法律规定范 围内对上述规则解释的权利",
}

M.end_time = 1613404799
M.answer_type = "answer_2021_2_9"

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1613404799
    local s_time = 1612827000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
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
    dump(parm,"<color=red>ppppppppppppppppppppppppppppppppppppp</color>")
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end

    if parm.goto_scene_parm == "enter" then
        return Act_048_XNSMTEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then 
        return Act_048_XNSMTPanel.Create(parm.parent)
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["query_everyday_shared_award_response"] = this.on_query_everyday_shared_award_response
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
    lister["AssetChange"] = this.on_asset_change
end

function M.Init()
	M.Exit()

	this = Act_048_XNSMTManager
    this.m_data = {}
    this.m_data.tasks_cfg = config.tasks
    this.m_data.lottery_rewards_cfg = config.lottery_rewards
    this.m_data.questions_cfg = config.questions
    this.m_data.collect_rewards_cfg = config.collect_rewards

    this.m_data.tasks_data = {} --key:task_id

    this.m_data.is_share_award = false
	MakeLister()
    AddLister()
    M.InitUIConfig()
    
    -- M.QueryCollectTaskData()
    -- M.QueryTaskData()
    M.QueryShareData()
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

function M.UpdateCollectTaskData(_data)
    this.m_data.collect_task_data = {}
    this.m_data.collect_task_data.now_total_process = _data.now_total_process
    local b = basefunc.decode_task_award_status(_data.award_get_status)
    b = basefunc.decode_all_task_award_status(b, _data, 5)
    this.m_data.collect_task_data.get_state = b
    this.m_data.collect_task_data.need_process = _data.need_process
    this.m_data.collect_task_data.now_process = _data.now_process
    this.m_data.collect_task_data.now_lv = _data.now_lv
end

function M.UpdateTaskData(_data)
    this.m_data.tasks_data[_data.id] = _data
end

function M.GetTaskCfg()
    return this.m_data.tasks_cfg
end

function M.GetLotteryRdCfg()
    return this.m_data.lottery_rewards_cfg
end

function M.GetQuestionCfg()
    return this.m_data.questions_cfg
end

function M.GetCollectRdCfg()
    return this.m_data.collect_rewards_cfg
end

function M.GetCollectTaskData()
    return this.m_data.collect_task_data
end

function M.GetTaskData()
    local task_tab = {}
    local cfg = this.m_data.tasks_cfg
    local data = this.m_data.tasks_data
    for i = 1,#cfg do
        task_tab[i] = {}
        local task_data = data[cfg[i].task_id]
        if task_data then
            local b = basefunc.decode_task_award_status(task_data.award_get_status)
            b = basefunc.decode_all_task_award_status(b, task_data, 6)
            if not cfg[i].level then
                task_tab[i].state = task_data.award_status
            else
                local my_level = cfg[i].level
                task_tab[i].state = b[my_level]
            end
            task_tab[i].now_total_process = task_data.now_total_process
            task_tab[i].need_process = task_data.need_process
        else
            task_tab[i].state = 0
            task_tab[i].now_total_process = 0
            task_tab[i].need_process = 0
        end
    end
    --dump(task_tab,"<color=red>TTTTTTTTTTTTTTTTTTTTTT</color>")
    return task_tab
end

function M.GetAwardIndex(_award_id)
    for i = 1, #this.m_data.lottery_rewards_cfg do
        for j = 1, #this.m_data.lottery_rewards_cfg[i].award_id do
            if this.m_data.lottery_rewards_cfg[i].award_id[j] == _award_id then
                return i
            end
        end
    end
end

function M.GetItemCount()
    return MainModel.GetItemCount(M.item_key)
end


function M.IsContainTask(task_id)
    for i = 1, #this.m_data.tasks_cfg do
        if this.m_data.tasks_cfg[i].task_id == task_id then
            return true
        end
    end
    return false
end


function M.IsHint()
    if MainModel.GetItemCount(M.lottery_item_key) >= 3 then
        return true
    end

    if this.m_data.is_share_award then
        return true
    end
    
    if not table_is_null(this.m_data.tasks_data) then
        local _data = M.GetTaskData()
        for i = 1, #_data do 
            if _data[i].state == 1 then
                return true
            end
        end
    end

    if not table_is_null(this.m_data.collect_task_data) then
        local _data = M.GetCollectTaskData().get_state
        for i = 1, #_data do 
            if _data[i] == 1 then
                return true
            end
        end
    end

    return false
end

function M.QueryCollectTaskData()
    Network.SendRequest("query_one_task_data", { task_id = M.collect_task_id })
end

function M.QueryTaskData()
    local task_id_lis = {}
    local cur_task_id
    for i = 1, #this.m_data.tasks_cfg do
        local _cfg = this.m_data.tasks_cfg[i]
        if cur_task_id ~= _cfg.task_id then
            Network.SendRequest("query_one_task_data", { task_id = _cfg.task_id })
            cur_task_id = _cfg.task_id
        end 
    end
end

function M.QueryShareData()
    --Network.SendRequest("query_everyday_shared_award", {type="shared_friend"})
    --ShareModel.ReqQueryEverydaySharedAward(ShareModel.EverydaySharedAwardType.shared_timeline)
    ShareModel.ReqQueryEverydaySharedAward(ShareModel.EverydaySharedAwardType.shared_friend)
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

function M.on_model_query_one_task_data_response(data)
    --dump(data,"<color=white>+++++++on_model_query_one_task_data_response+++++++</color>")
    if data then
        M.HandleTaskData(data)
    end
end

function M.on_model_task_change_msg(data)
    --dump(data,"<color=white>+++++++on_model_task_change_msg+++++++</color>")
    if data then
        M.HandleTaskData(data)
    end
end

function M.on_query_everyday_shared_award_response(data)
    dump(data,"<color=white>+++++++on_query_everyday_shared_award_response+++++++</color>")
    if not data then
		return 
    end
    local _is_share_award = false
	if data.status and data.status > 0 then
        _is_share_award = true
    end
    this.m_data.is_share_award = _is_share_award
    Event.Brocast("model_xnsmt_share_refresh",{is_share_award = _is_share_award})
end

function M.on_asset_change(_data)
    dump(_data,"<color=green>+++++++on_asset_change+++++++</color>")
    if _data and _data.data and not table_is_null(_data.data) then
        for i = 1 , #_data.data do 
            if _data.data[i].asset_type == M.lottery_item_key then
                M.SetHintState()
            end
        end
	end
end

function M.HandleTaskData(data)
    if data.id == M.collect_task_id then
        M.UpdateCollectTaskData(data)
        Event.Brocast("model_xnsmt_collect_refresh")
        M.SetHintState()
    end

    if M.IsContainTask(data.id) then
        M.UpdateTaskData(data)
        Event.Brocast("model_xnsmt_task_refresh")
        M.SetHintState()
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()

end