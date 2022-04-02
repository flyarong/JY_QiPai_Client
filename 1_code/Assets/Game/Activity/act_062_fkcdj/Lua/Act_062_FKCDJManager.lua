-- 创建时间:2021-07-05
-- Act_062_FKCDJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_062_FKCDJManager = {}
local M = Act_062_FKCDJManager
M.key = "act_062_fkcdj"

local m_config = GameButtonManager.ExtLoadLua(M.key, "act_062_fkcdj_config")
GameButtonManager.ExtLoadLua(M.key, "Act_062_FKCDJPanel")

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

    if parm.goto_scene_parm == "panel" then
        M.HandleOpenPanel()
        return Act_062_FKCDJPanel.Create(parm.parent)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsHint() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get 
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["AssetChange"] = this.OnAssetChange
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
end

function M.Init()
	M.Exit()
	this = Act_062_FKCDJManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitConfig()
    M.AddUnShowAward()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitConfig()
    m_config.task_id = 21855
end

--打开面板的时候更新数据
function M.HandleOpenPanel()
    M.UpdateCurConsumeData()
    Network.SendRequest("query_one_task_data", { task_id = m_config.task_id })
end

--**************************************************

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()
end

function M.on_model_task_change_msg(data)
    --dump(data, "<color=red>疯狂抽大奖:任务数据改变</color>")
    if data and data.id == m_config.task_id then
        M.UpdateCurBoxData(data)
        Event.Brocast("model_fkcdj_task_change")
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key})
    end
end

function M.on_model_query_one_task_data_response(data)
    --dump(data, "<color=red>疯狂抽大奖:任务数据</color>")
    if data and data.id == m_config.task_id then
        M.UpdateCurBoxData(data)
        Event.Brocast("model_fkcdj_task_change")
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key})
    end
end

function M.OnAssetChange(data)
    --dump(data, "<color=red>疯狂抽大奖:资产改变</color>")
    local isCareChangeType = function(data)
        if data.change_type 
        and (data.change_type == "box_exchange_active_award_200" or data.change_type == "box_exchange_active_award_201")
        and not table_is_null(data.data) then
            return true
        end
    end
    local isCareAssetType = function(data)

    end
    if isCareChangeType(data) then
        M.UpdateCurConsumeData()
        Event.Brocast("model_fkcdj_asset_change", data)
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key})
    end
end

--**************************************************

function M.IsHint()
    for i = 1, #m_config.lotterys do
        if M.GetItemCount(i) >= m_config.lotterys[i].lottery_consume then
            return true
        end
    end
    return M.IsBoxAwardCanGet()
end

function M.IsBoxAwardCanGet()
    local data = GameTaskModel.GetTaskDataByID(m_config.task_id)
    if data and data.award_status == 1 then
        return true 
    end
    return false
end

function M.GetLotteryCfg(index)
    return m_config.lotterys[index]
end

function M.GetItemCount(index)
    return GameItemModel.GetItemCount(m_config.lotterys[index].lottery_item)
end

--[1,2]
function M.GetCurConsume(index)
    return this.curConsumeData[index]
end

function M.GetBoxCfg()
    return m_config.boxs
end

function M.GetCurBoxData()
    return this.curBoxData.data
end

function M.GetCurBoxStatus()
    return this.curBoxData.status
end

function M.GetAwardsCfg()
    return m_config.awards
end

function M.GetAwardIndex(_award_id)
    for i = 1,#m_config.awards do
        if m_config.awards[i].award_id == _award_id then
            return m_config.awards[i].ID
        end
    end
end

function M.UpdateCurConsumeData()
    local getItemCount = function(item_key)
        return GameItemModel.GetItemCount(item_key)
    end
    local getItemKey = function(lottery_index)
        return m_config.lotterys[lottery_index].lottery_item
    end
    local getItemConsume = function(lottery_index)
        return m_config.lotterys[lottery_index].lottery_consume
    end
    this.curConsumeData = {}
    local tT = {}
    if getItemCount(getItemKey(1)) >= getItemConsume(1) * 10 then
        tT[1],tT[2] = 1, 1
    elseif getItemCount(getItemKey(1)) < getItemConsume(1) * 10 and getItemCount(getItemKey(1)) >= getItemConsume(1) then
        tT[1],tT[2] = 1, 2
    else
        tT[1],tT[2] = 2, 2
    end
    this.curConsumeData = tT
end

function M.UpdateCurBoxData(data)
    this.curBoxData = {}
    local b = basefunc.decode_task_award_status(data.award_get_status)
    b = basefunc.decode_all_task_award_status(b, data, 5)
    this.curBoxData.data = data
    this.curBoxData.status = b
end

function M.AddUnShowAward()
    local check_func = function (type)
        if type == "box_exchange_active_award_200" or type == "box_exchange_active_award_201" then
            return true
        end
    end
    MainModel.AddUnShow(check_func)
end