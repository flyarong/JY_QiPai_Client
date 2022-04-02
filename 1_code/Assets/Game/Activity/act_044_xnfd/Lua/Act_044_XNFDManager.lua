local basefunc = require "Game/Common/basefunc"
Act_044_XNFDManager = {}
local M = Act_044_XNFDManager
M.key = "act_044_xnfd"
GameButtonManager.ExtLoadLua(M.key,"Act_044_XNFDPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_044_XNFDItem")
local this
local lister
M.task_id = 21673
M.permission_key = "actp_buy_gift_bag_class_hqyd_044_xnfd"
M.gift_ids = {
    10527,
    10528,
    10529,
    10530,
    10531,
    10532,
    10533,    
}
-- 是否有活动
function M.IsActive()
    --活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = M.permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
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
    dump({parm,M.cfg}, "<color=red>新年福袋</color>")
    if parm.goto_scene_parm == "panel" then
        return Act_044_XNFDPanel.Create(parm.parent,parm.cfg)
	end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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

    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response
    lister["model_task_change_msg"] = this.model_task_change_msg
    lister["finish_gift_shop"] = this.finish_gift_shop
end

function M.Init()
	M.Exit()

	this = Act_044_XNFDManager
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
    M.gift_id_hash = {}
    for i,v in ipairs(M.gift_ids) do
        M.gift_id_hash[v] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Network.SendRequest("query_one_task_data", {task_id = M.task_id})
	end
end
function M.OnReConnecteServerSucceed()
end

function M.ActivityTaskPanel_Exit()
    Act_044_XNFDPanel.Close()
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.model_query_one_task_data_response(task_data)
    if task_data.id ~= M.task_id then return end
    M.task_data = GameTaskModel.GetTaskDataByID(task_data.id)
    Event.Brocast("act_044_xnfd_refresh")
end

function M.model_task_change_msg(task_data)
    if task_data.id ~= M.task_id then return end
    M.task_data = GameTaskModel.GetTaskDataByID(task_data.id)
    Event.Brocast("act_044_xnfd_refresh")
    M.SetHintState()
end

function M.finish_gift_shop(gift_id)
    if not M.gift_id_hash or not M.gift_id_hash[gift_id] then return end
    Event.Brocast("act_044_xnfd_refresh")
end

function M.IsAwardCanGet()
    local all_task_award_status = M.GetAllTaskAwardStatus()
    if table_is_null(all_task_award_status) then return end
    for i,v in ipairs(all_task_award_status) do
        if v == 1 then
            return true
        end
    end
    return false
end

function M.GetTaskData()
    M.task_data = GameTaskModel.GetTaskDataByID(M.task_id)
    if table_is_null(M.task_data) then 
        Network.SendRequest("query_one_task_data", {task_id = M.task_id})
    end
    return M.task_data
end

function M.GetAllTaskAwardStatus()
    local atas = GameTaskModel.GetAllTaskAwardStatus(M.task_id,3)
    return atas
end