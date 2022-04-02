-- 创建时间:2018-11-06
local golden_pig_config = GiftGoldenPigManager.golden_pig_config
local update_golden_pig_config
update_golden_pig_config = LocalDatabase.LoadFileDataToTable(gameMgr:getLocalPath("localconfig/golden_pig_config.lua"))
if update_golden_pig_config then
    golden_pig_config = update_golden_pig_config
end


GoldenPigModel = {}

GoldenPigModel.TaskType = {
    gloden_pig = "gloden_pig",
}

GoldenPigModel.ChangeStatus = {
    gloden_pig = 0,
}

GoldenPigModel.CanGetStatus = {
    gloden_pig = false,
}

local this
local m_data
local lister
local function MakeLister()
    lister = {}
    lister["query_goldpig_task_data_response"] = this.on_query_goldpig_task_data_response
    lister["get_goldpig_task_award_response"] = this.on_get_goldpig_task_award_response
    lister["goldpig_task_change_msg"] = this.on_goldpig_task_change_msg
    lister["query_goldpig2_task_data_response"] = this.on_query_goldpig2_task_data_response
    lister["query_goldpig2_task_remain_response"] = this.on_query_goldpig2_task_remain_response
    lister["query_goldpig2_task_today_data_response"] = this.on_query_goldpig2_task_today_data_response

    lister["query_goldpig_task_remain_response"] = this.on_query_goldpig_task_remain_response
    lister["goldpig_task_remain_change_msg"] = this.on_goldpig_task_remain_change_msg
    --购买失败
    lister["ReceivePayOrderMsg"] = this.OnReceivePayOrderMsg
    --购买成功
    lister["finish_gift_shop"] = this.on_finish_gift_shop

    lister["HallModelInitFinsh"] = this.HallModelInitFinsh
end
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end
local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function InitData()
	GoldenPigModel.data={}
	m_data = GoldenPigModel.data
end
function GoldenPigModel.Init()
    this=GoldenPigModel
    this.InitUIConfig()
    InitData()
    MakeLister()
    AddLister()

    this.ReqTaskData()
    this.ReqTaskRemain()
    this.QueryGoldenPig2DayData()
    return this
end
function GoldenPigModel.Exit()
    if this then
        RemoveLister()
        m_data=nil
        this=nil
    end
end

function GoldenPigModel.InitUIConfig()
    this.golden_pig_config = golden_pig_config
end

-- 请求任务数据
function GoldenPigModel.ReqTaskData()
    -- award_status  0-不能领取 | 1-可领取 | 2-已完成
    -- m_data.task_list = {
    --     [1] = {id=4, now_process=0, need_process=5, award_status=0},
    -- }
    if m_data.task_list and next(m_data.task_list) then
        Event.Brocast("model_query_goldpig_task_data_response")
    else
        Network.SendRequest("query_goldpig_task_data", nil)
        GoldenPigModel.QueryGoldenPig2Task()
    end
end

-- 获取任务数据
function GoldenPigModel.GetConfigDataByType(type)
    if not type then
        return this.golden_pig_config
    else
        return this.golden_pig_config[type]
    end
end

-- 获取任务数据
function GoldenPigModel.GetTaskDataByID(id)
    if id then
        if m_data.task_list then
            return m_data.task_list[id]
        end
    else
        return m_data.task_list
    end
end

--完成但领取奖励的任务
function GoldenPigModel.GetFinishTaskDataToType()
    local task_data = GoldenPigModel.GetTaskDataByID()
    local finish_data
    for i,v in ipairs(task_data) do
        if v.award_status == 1 then
            finish_data = finish_data or {}
            finish_data[#finish_data + 1] = v
        end
    end
    return finish_data
end

function GoldenPigModel.on_query_goldpig_task_data_response(_, data)
    -- dump(data, "<color=yellow>on_query_goldpig_task_data_response</color>")
    if data.result == 0 then
        m_data.task_list = m_data.task_list or {}
        for i,v in ipairs(data.task_list) do
            GameTaskModel.task_process_int_convent_string(v)
            m_data.task_list[v.id] = v
        end
        Event.Brocast("model_query_goldpig_task_data_response")
        GoldenPigModel.ChangeTaskCanGetRedHint()
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GoldenPigModel.on_get_goldpig_task_award_response(_, data)
    dump(data, "<color=yellow>领取任务奖励</color>")
    if data.result == 0 then
        m_data.task_list[data.id].award_status = 2
        Event.Brocast("model_get_goldpig_task_award_response",data)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GoldenPigModel.on_goldpig_task_change_msg(_, data)
    dump(data, "<color=yellow>任务进度改变</color>")
    m_data.task_list = m_data.task_list or {}
    GameTaskModel.task_process_int_convent_string(data.task_item)
    m_data.task_list[data.task_item.id] = data.task_item
    local task_id = data.task_item.id
    --任务可领取才改变红点
    GoldenPigModel.ChangeTaskCanGetRedHint()

    Event.Brocast("model_goldpig_task_change_msg",data.task_item)
end

function GoldenPigModel.ChangeTaskCanGetRedHint()
    if GameGlobalOnOff.GoldenPig == true then
        GoldenPigModel.CheckTaskCanGet()
        Event.Brocast("UpdateHallGoldenPigRedHint")
    end
end

--检测是否有可领取的任务
function GoldenPigModel.CheckTaskCanGet()
    GoldenPigModel.CanGetStatus.gloden_pig = false
    if m_data.task_list then
        for k,v in pairs(m_data.task_list) do
            if GoldenPigModel.CanGetStatus.gloden_pig == false then
                GoldenPigModel.CanGetStatus.gloden_pig = v.award_status == 1
            end
        end
    end
    return GoldenPigModel.CanGetStatus.gloden_pig
end

function GoldenPigModel.OnReceivePayOrderMsg(msg)
    dump(msg, "<color=green>OnReceivePayOrderMsg</color>")
    Event.Brocast("model_receive_pay_order", msg)
end

function GoldenPigModel.on_finish_gift_shop(id)
    dump(id, "<color=green>on_finish_gift_shop</color>")
    if id == 12 or id == 30 or id == 31 or id == 32 or id == 33 then
        RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_Money_Center)
        Event.Brocast("model_finish_gift_shop",id)
    end
end

function GoldenPigModel.GetGiftBagGoodsID()
    local pay_config = GoldenPigModel.GetConfigDataByType("config")
    if pay_config and pay_config.config_t51 then
        return pay_config.config_t51.good_id
	elseif pay_config and pay_config.config then
		return pay_config.config.good_id
    end
    return nil
end

function GoldenPigModel.GetTaskRemain()
    if m_data.remain_num then
        return m_data.remain_num
    end
    return -1
end

-- 请求可领取次数
function GoldenPigModel.ReqTaskRemain()
    -- m_data.remain_num = 30
    Network.SendRequest("query_goldpig_task_remain", nil)
    GoldenPigModel.QueryGoldenPig2Progress()
end

function GoldenPigModel.on_query_goldpig_task_remain_response(_, data)
    -- dump(data, "<color=yellow>金猪次数</color>")
    if data.result == 0 then
        m_data.remain_num = data.remain_num
        Event.Brocast("model_query_goldpig_task_remain_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GoldenPigModel.on_goldpig_task_remain_change_msg(_, data)
    dump(data, "<color=yellow>金猪剩余次数改变</color>")
    m_data.remain_num = data.task_remain
    Event.Brocast("model_goldpig_task_remain_change_msg")
end

function GoldenPigModel.HallModelInitFinsh()
    GoldenPigModel.ChangeTaskCanGetRedHint()
end

function GoldenPigModel.QueryGoldenPig2Task()
    Network.SendRequest("query_goldpig2_task_data")
end

function GoldenPigModel.on_query_goldpig2_task_data_response(pName, data)
    -- dump(data, "<color=yellow>GoldenPigModel.on_query_goldpig2_task_data_response</color>")
    if data.result == 0 then
        m_data.task_list = m_data.task_list or {}
        for i,v in ipairs(data.task_list) do
            GameTaskModel.task_process_int_convent_string(v)
            m_data.task_list[v.id] = v
        end
        Event.Brocast("model_query_goldpig_task_data_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GoldenPigModel.QueryGoldenPig2Progress()
    Network.SendRequest("query_goldpig2_task_remain")
end

function GoldenPigModel.on_query_goldpig2_task_remain_response(pName, data)
    -- dump(data, "<color=yellow>GoldenPigModel.on_query_goldpig2_task_remain_response</color>")
    if data.result == 0 then
        m_data.pig2_num = data.remain_num or 0
    else
        m_data.pig2_num = 0
        --HintPanel.ErrorMsg(data.result)
    end
    Event.Brocast("model_query_goldpig2_task_remain_msg")
end

function GoldenPigModel.QueryGoldenPig2DayData()
    Network.SendRequest("query_goldpig2_task_today_data", nil, "")
    GoldenPigModel.QueryGoldenPig2Progress()
end

function GoldenPigModel.on_query_goldpig2_task_today_data_response(pName, data)
    -- dump(data, "<color=yellow>GoldenPigModel.on_query_goldpig2_task_today_data_response</color>")
    if data.result == 0 then
        m_data.pig2_day_num = data.total_num  or 0
        m_data.pig2_day_left = data.remain_num or 0
        Event.Brocast("model_query_goldpig2_task_today_data_msg")
    else
        m_data.pig2_day_num  = 0
        m_data.pig2_day_left = 0
        --HintPanel.ErrorMsg(data.result)
    end
end

function GoldenPigModel.IsNewPig1TaskExist()
    dump(m_data, "<color=yellow>m_data.task_list:</color>")
    local ret = false
    if m_data.task_list then
        for i, t in pairs(m_data.task_list) do
            if t.id == 51 then
                ret = true
                break
            end
        end
    end
    return ret
end

function GoldenPigModel.IsNewPig2TaskExist()
    local ret = false
    if m_data.task_list then
        for i, t in pairs(m_data.task_list) do
            if t.id == 52 then
                ret = true
                break
            end
        end
    end
    return ret
end

function GoldenPigModel.IsRuningOldPig1TaskExist()
    local ret = false
    if m_data.task_list then
        for i, t in pairs(m_data.task_list) do
            if t.id == 7 then
                ret = true
                break
            end
        end
    end
    return ret
end

function GoldenPigModel.ResetTaskData()
    if m_data.task_list then
        m_data.task_list = nil
    end
end

function GoldenPigModel.GetPig2RemainNum()
    return m_data.pig2_num or 0
end

function GoldenPigModel.CheckGiftIsShow(id)
    local pig = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 12)
    local pig1 = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 30)
    local pig11 = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 31)
    local pig2 = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 32)
    local pig21 = MainModel.GetItemStatus(GOODS_TYPE.gift_bag, 33)

    if id == 12 then
        if GoldenPigModel.IsRuningOldPig1TaskExist() then
            return true,true
        else
            return false,false
        end
    elseif id == 30 then
        if GoldenPigModel.IsRuningOldPig1TaskExist() then
            return false,false
        else
            if not GoldenPigModel.data.remain_num then GoldenPigModel.data.remain_num = 0 end
            if not pig1 then pig1 = 0 end
            return GoldenPigModel.data.remain_num >= 0,pig1 == 0
        end
    elseif id == 31 then
        if GoldenPigModel.IsRuningOldPig1TaskExist() then
            return false,false
        else
            if not GoldenPigModel.data.remain_num then GoldenPigModel.data.remain_num = 0 end
            if not pig11 then pig11 = 0 end
            return GoldenPigModel.data.remain_num < 0,pig11 == 0
        end
    elseif id == 32 then
        return pig21 == 0 and (GoldenPigModel.IsNewPig1TaskExist() or GoldenPigModel.IsNewPig2TaskExist() or pig2 == 1),pig2 == 0
    elseif id == 33 then
        return  pig21 == 1,pig21 == 0
    end
end

function GoldenPigModel.CheckTaskIsShow(task_id)
    dump({task_id,GoldenPigModel.data}, "<color=blue>金猪礼包判定</color>")
    if GoldenPigModel.data and GoldenPigModel.data.task_list and GoldenPigModel.data.task_list[task_id] then
        local task_data = GoldenPigModel.data.task_list[task_id]
        local rn = 0
        if task_id == 7 or task_id == 51 then
            rn = GoldenPigModel.data.remain_num
        elseif task_id == 52 then
            rn = GoldenPigModel.data.pig2_num
        end
        if rn > 0 or task_data.award_status ~= 2 then
            return true
        end
    end
    return false
end