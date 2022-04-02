VIPGiftModel = {}
local M = VIPGiftModel
local vip_gift_config = VIPGiftLogic.vip_gift_config

M.GiftID = {
    gift_id = 43,
}

M.TaskType = {
    vip_gift = "vip_gift",
}

M.TaskID = {
    qys = 55,
    fishing = 56,
}

M.ChangeStatus = {
    vip_gift = 0,
}

M.CanGetStatus = {
    vip_gift = false,
}

local this
local m_data
local lister
local function MakeLister()
    lister = {}
    lister["query_vip_lb_base_info_response"] = this.query_vip_lb_base_info_response
    lister["vip_lb_base_info_change_msg"] = this.vip_lb_base_info_change_msg

    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response
	lister["model_task_change_msg"] = this.model_task_change_msg

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
	M.data={}
	m_data = M.data
end
function M.Init()
    this=M
    this.InitUIConfig()
    InitData()
    MakeLister()
    AddLister()

    this.ReqTaskData()
    this.ReqTaskBaseData()
    return this
end
function M.Exit()
    if this then
        RemoveLister()
        m_data=nil
        this=nil
    end
end

function M.InitUIConfig()
    this.vip_gift_config = vip_gift_config
    -- this.vip_gift_config.not_pay = vip_gift_config.not_pay[1]
    -- dump(this.vip_gift_config, "<color=green>vip_gift_config</color>")
end

-- 请求礼包数据
function M.ReqTaskBaseData()
    if not m_data.base_data then
        Network.SendRequest("query_vip_lb_base_info", nil)
    else
        Event.Brocast("model_query_vip_lb_base_info_response")
    end
end

-- 请求任务数据
function M.ReqTaskData()
    if not m_data.task_list or not next(m_data.task_list) then
        Network.SendRequest("query_one_task_data", {task_id = M.TaskID.qys})
        Network.SendRequest("query_one_task_data", {task_id = M.TaskID.fishing})    
    else
        local function check_one_task(t_id)
            if not M.CheckIsVIPGiftTask(t_id) then return end
            if not m_data.task_list[t_id] then
                Network.SendRequest("query_one_task_data", {task_id = t_id})    
            else
                Event.Brocast("model_query_one_task_data_response_vip_gift",{task_id = t_id})
            end
        end
        check_one_task(M.TaskID.qys)
        check_one_task(M.TaskID.fishing)
    end
end

function M.query_vip_lb_base_info_response(_, data)
    dump(data, "<color=yellow>query_vip_lb_base_info_response</color>")
    if data.result == 0 then
        m_data.base_data = data
        Event.Brocast("model_query_vip_lb_base_info_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.vip_lb_base_info_change_msg(_, data)
    dump(data, "<color=yellow>vip_lb_base_info_change_msg</color>")
    m_data.base_data = data
    Event.Brocast("model_vip_lb_base_info_change_msg")
end

function M.model_query_one_task_data_response(data)
    if not M.CheckIsVIPGiftTask(data.id) then return end
    dump(data, "<color=yellow>model_query_one_task_data_response</color>")
    m_data.task_list = m_data.task_list or {}
    m_data.task_list[data.id] = data
    Event.Brocast("model_query_one_task_data_response_vip_gift")
    M.ChangeTaskCanGetRedHint()
end

function M.model_task_change_msg(data)
    if not M.CheckIsVIPGiftTask(data.id) then return end
    dump(data, "<color=yellow>任务进度改变</color>")
    m_data.task_list = m_data.task_list or {}
    m_data.task_list[data.id] = data
    local task_id = data.id
    --任务可领取才改变红点
    M.ChangeTaskCanGetRedHint()
    Event.Brocast("model_task_change_msg_vip_gift",data)
end

function M.OnReceivePayOrderMsg(msg)
    dump(msg, "<color=green>OnReceivePayOrderMsg</color>")
    Event.Brocast("model_receive_pay_order", msg)
end

function M.on_finish_gift_shop(id)
    dump(id, "<color=green>on_finish_gift_shop</color>")
    if id == M.GetGiftBagGoodsID() then
        Event.Brocast("model_finish_gift_shop",id)
    end
end

--获取任务配置
function M.GetTaskConfig(t_id)
    local cfg = M.GetConfigDataByType("pay")
    if t_id == M.TaskID.qys then
        return cfg.qys_cfg
    elseif t_id == M.TaskID.fishing then
        return cfg.fishing_cfg
    end
    return nil
end

-- 获取配置
function M.GetConfigDataByType(type)
    if not type then
        return this.vip_gift_config
    else
        if type == "pay" then
            return this.vip_gift_config[type]
        elseif type == "not_pay" then
            return this.vip_gift_config[type][1]
        end
    end
end

-- 获取任务数据
function M.GetTaskDataByID(id)
    if m_data and m_data.task_list then
        if id then
            return m_data.task_list[id]
        else
            return m_data.task_list
        end
    end
    return nil
end

function M.GetTaskBaseDataByID(id)
    if not m_data then
        return
    end
    if id and m_data.base_data  then
        local bd = {}
        if id == M.TaskID.qys then
            bd.get_num = m_data.base_data.task_get_num1 
            bd.max_num = m_data.base_data.task_max_num1 
        elseif id == M.TaskID.fishing then
            bd.get_num = m_data.base_data.task_get_num2 
            bd.max_num = m_data.base_data.task_max_num2
        end
        return bd
    else
        return m_data.base_data
    end
end

function M.ChangeTaskCanGetRedHint()
    if GameGlobalOnOff.VIPGift == true then
        M.CheckTaskCanGet()
        Event.Brocast("UpdateHallVIPGiftRedHint")
    end
end

--检测是否有可领取的任务
function M.CheckTaskCanGet()
    M.CanGetStatus.vip_gift = false
    if m_data.task_list then
        for k,v in pairs(m_data.task_list) do
            if M.CanGetStatus.vip_gift == false then
                M.CanGetStatus.vip_gift = v.award_status == 1
            end
        end
    end
    return M.CanGetStatus.vip_gift
end

function M.GetGiftBagGoodsID()
    local pay_config = M.GetConfigDataByType("not_pay")
    if pay_config then
        return pay_config.good_id
    end
    return nil
end

function M.HallModelInitFinsh()
    M.ChangeTaskCanGetRedHint()
end

function M.ResetTaskData()
    if m_data.task_list then
        m_data.task_list = nil
    end
end

function M.CheckIsBuy()
    if m_data and m_data.base_data and m_data.base_data.is_buy_vip_lb then
        return m_data.base_data.is_buy_vip_lb == 1
    end
    return false
end

function M.CheckIsVIPGiftTask(t_id)
    return t_id == M.TaskID.fishing or t_id == M.TaskID.qys
end

function M.GetVIPStatus()
    local bd = VIPGiftModel.GetTaskBaseDataByID()
    local is_running = false
    local status = 0 --0正常，1VIP任务完成，2VIP礼包失效
    if bd then
        if bd.is_buy_vip_lb == 0 then
            is_running = true
        elseif bd.is_buy_vip_lb == 1 then
            if bd.task_get_num1 == bd.task_max_num1 and bd.task_get_num2 == bd.task_max_num2 then
                status = 1
            else
                if bd.task_overdue_time then
                    local countdown = bd.task_overdue_time - os.time()
                    if countdown > 0 then
                        is_running = true
                    else
                        status = 2
                    end
                end
            end
        end
    end
    return is_running, status
end

function M.GetVIPStatusByTaskID(t_id)
    local bd = VIPGiftModel.GetTaskBaseDataByID()
    local is_running = false
    local status = 0 --0正常，1VIP任务完成，2VIP礼包失效
    if bd then
        if bd.is_buy_vip_lb == 0 then
            
        elseif bd.is_buy_vip_lb == 1 then
            if t_id == 55 then
                if bd.task_get_num1 == bd.task_max_num1 then
                    status = 1
                elseif bd.task_get_num1 < bd.task_max_num1 then
                    if bd.task_overdue_time then
                        local countdown = bd.task_overdue_time - os.time()
                        if countdown > 0 then
                            is_running = true
                        else
                            status = 2
                        end
                    end
                end
            elseif t_id == 56 then
                if bd.task_get_num2 == bd.task_max_num2 then
                    status = 1
                elseif bd.task_get_num2 < bd.task_max_num2 then
                    if bd.task_overdue_time then
                        local countdown = bd.task_overdue_time - os.time()
                        if countdown > 0 then
                            is_running = true
                        else
                            status = 2
                        end
                    end
                end
            end
        end
    end
    return is_running, status
end