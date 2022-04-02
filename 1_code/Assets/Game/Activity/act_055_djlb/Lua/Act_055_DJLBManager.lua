-- 创建时间:2021-04-15
-- Act_055_DJLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_055_DJLBManager = {}
local M = Act_055_DJLBManager
M.key = "act_055_djlb"
GameButtonManager.ExtLoadLua(M.key, "Act_055_DJLBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_055_DJLBTaskPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_055_DJLBBuyPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_055_DJLBHintPanel")
local config = GameButtonManager.ExtLoadLua(M.key, "act_055_djlb_config")

M.rule = {
    "1.礼包购买后立即获得20万鲸币，额外赠送的30万鲸币每日登录可领取2万",
    "2.每日完成2个对局任务可领4福卡，每个任务每日限领1次，共15次",
    "3.任务刷新首次免费，之后每次需要消耗100鲸币",
    "4.所有任务将在次日0点重置刷新，请及时领取奖励；",
    "5.所有任务需在礼包购买后20日内完成，时间截止后任务失效",
}
M.shop_id = 10733
M.day_task_id = 21755
M.father_task_id1 = 21756
M.father_task_id2 = 21757

local this
local lister

--每个任务每日首次刷新免费
local free_refresh_num = 1

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
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
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end

    if parm.goto_scene_parm == "enter" then
        return Act_055_DJLBEnterPrefab.Create(parm.parent)
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

    lister["EnterScene"] = this.on_enter_scene
	lister["finish_gift_shop"] = this.on_finish_gift_shop 
    lister["model_query_one_task_data_response"] = this.on_model_task_get_or_change
    lister["model_task_change_msg"] = this.on_model_task_get_or_change

    lister["query_dui_ju_li_bao_base_info_response"] = this.on_djlb_base_info_get
    lister["dui_ju_li_bao_base_info_change"] = this.on_djlb_base_info_change
end

function M.Init()
	M.Exit()

	this = Act_055_DJLBManager
	this.m_data = {}
    this.m_data.cur_tasks = {}
    this.m_data.cur_tasks[1] = M.day_task_id
    this.m_data.cfg = config
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

function M.IsFreeRefresh()
    if this.m_data.base_info and this.m_data.base_info.refresh_task_num < free_refresh_num then
        return true
    end
    return false
end

function M.IsAllGet()
    local sum = 0
    for i = 1,3 do
        if this.m_data.base_info then
            sum = sum + (this.m_data.base_info["remain_num_"..i] or 0)
        end
        --dump(this.m_data.base_info["remain_num_"..i],"<color=red>剩余次数</color>"..this.m_data["remain_num_"..i])
    end
    return sum == 0
end

function M.IsHint()

    for i = 1, #this.m_data.cur_tasks do
        local b_task_data = GameTaskModel.GetTaskDataByID(this.m_data.cur_tasks[i])
        if b_task_data and b_task_data.award_status == 1 then
            return true
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Network.SendRequest("query_dui_ju_li_bao_base_info")
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_djlb_base_info_change(_,data)
    --dump(data,"<color=red>+++++on_djlb_base_info_change+++++</color>")
    M.HandleBaseInfoData(data)
end

function M.on_djlb_base_info_get(_,data)
    --dump(data,"<color=red>+++++on_djlb_base_info_get+++++</color>")
    if data and data.result == 0 then
        M.HandleBaseInfoData(data)
    end
end

function M.HandleBaseInfoData(data)
    this.m_data.base_info = data
    Event.Brocast("act_055_djlb_base_info_change")
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function M.on_model_task_get_or_change(data)
    --dump(data,"<color=red>+++++on_model_task_get_or_change+++++</color>")
    if not data then
        return
    end

    if data.id == M.father_task_id1 or data.id == M.father_task_id2 or data.id == M.day_task_id then
        M.HandleTask(data.id)
    end

    for i = 1 ,#this.m_data.cfg.task_info do
        if data.id == this.m_data.cfg.task_info[i].task_id then
            Event.Brocast("act_055_djlb_task_change")
        end
    end
end

function M.on_finish_gift_shop(id)
    if id == M.shop_id then
        Act_055_DJLBTaskPanel.Create()
    end
end

function M.on_enter_scene()

    if GameGlobalOnOff.IsOpenGuide and MainModel.UserInfo.xsyd_status ~= 1 then
        return
    end
    --dump(MainModel.myLocation,"<color=red>----------------on_enter_scene-1---------------</color>")

    if MainModel.myLocation ~= "game_Free" then
        return
    end

    local status = MainModel.GetGiftShopStatusByID(M.shop_id)

    if status == 1 and M.GetOverTime() == 0 then --没有买过
        Act_055_DJLBBuyPanel.Create()
        return
    end

    if os.time() < M.GetOverTime() and not M.IsAllGet() then 
        Act_055_DJLBTaskPanel.Create()
        return
    end

    if M.GetOverTime() <= os.time() and not M.IsAllGet() then
		Act_055_DJLBHintPanel.Create(2)
        return
    end
end

function M.ShowType()
    local type = 0
    local status = MainModel.GetGiftShopStatusByID(M.shop_id)
    if status == 1 then
        type = 1
    else
        type = 2
    end
    return type
end

function M.GetCurTasks()
    return this.m_data.cur_tasks
end

function M.GetBaseInfo()
    if this.m_data.base_info then
        return this.m_data.base_info 
    end
end

function M.GetOverTime()
    local t = 0
    if this.m_data.base_info then
        t = this.m_data.base_info.over_time
    end
    return  tonumber(t)
end

function M.GetCfgFromTaskId(_task_id)
    for i = 1 , #this.m_data.cfg.task_info do
        if this.m_data.cfg.task_info[i].task_id == _task_id then
            return this.m_data.cfg.task_info[i]
        end
    end
end

function M.HandleTask(id)
    if id ~= M.day_task_id then
        local father_data = GameTaskModel.GetTaskDataByID(id)
        if not father_data or not father_data.other_data_str then
            dump("-")
            return
        end
        if id == M.father_task_id1 then
            this.m_data.cur_tasks[2] = tonumber(father_data.other_data_str)
        else
            this.m_data.cur_tasks[3] = tonumber(father_data.other_data_str)
        end
    end
    --dump(this.m_data.cur_tasks,"<color=red>-----this.m_data.cur_tasks------</color>")
    Event.Brocast("act_055_djlb_task_change")
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end