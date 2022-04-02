-- 创建时间:2019-10-24
-- 通用礼包管理器

local basefunc = require "Game/Common/basefunc"
MoneyCenterQFLBManager = {}
local M = MoneyCenterQFLBManager
M.key = "sys_cfzx_qflb"
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterQFLBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "MoneyCenterQFLBPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSCFZXQFLB_JYFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "QFLBFlyEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "QFLBSharePanel")
GameButtonManager.ExtLoadLua(M.key, "QFLBNoticePanel")
GameButtonManager.ExtLoadLua(M.key, "Share_Panel")
local money_center_qflb_config = GameButtonManager.ExtLoadLua(M.key, "money_center_qflb_config")
local this
local lister

function M.CheckIsShow()
    --指在斗地主结算界面的时候
    if MainModel.myLocation == "game_DDZFree"  then
         return M.IsShowClear()
    end

    if not M.is_show() then
        return
    end
    return true
end

function M.GotoUI(parm)
	if parm.goto_scene_parm == "panel" then
        return MoneyCenterQFLBPanel.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter" then
        return MoneyCenterQFLBEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "jyfl_enter" then
        if not M.is_show() then
            return
        end
        return SYSCFZXQFLB_JYFLEnterPrefab.Create(parm.parent, parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    local cur_state = 0
    if this and this.money_center_qflb_config and this.m_data then
        local task_data
        for i,v in ipairs(this.money_center_qflb_config.qflb) do
            task_data = GameTaskModel.GetTaskDataByID(v.task_id)
            if task_data and task_data.award_status == 1 then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Get
            elseif task_data and task_data.award_status == 0 then
                cur_state = ACTIVITY_HINT_STATUS_ENUM.AT_Mission
            end
        end
    end
    if cur_state ~= 0 then
        return cur_state
    end
    if PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."QFLB",-1) == -1 then 
        return ACTIVITY_HINT_STATUS_ENUM.AT_Red
    end
    cur_state = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
	return cur_state
end

function M.SetHintState()

end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end

function M.on_global_hint_state_change_msg(parm)
    if parm.gotoui ~= M.key then return end
    M.SetHintState()
    Event.Brocast("module_global_hint_state_change_msg",parm)
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
    lister["query_all_return_lb_info_response"] = this.query_all_return_lb_info_response
    lister["query_sczd_all_return_base_info_response"] = this.query_sczd_all_return_base_info_response
    lister["all_return_lb_change_msg"] = this.all_return_lb_change_msg
    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg

    lister["model_get_task_award_response"] = this.model_get_task_award_response
    lister["model_task_change_msg"] = this.model_task_change_msg
    lister["finish_gift_shop"] = this.on_finish_gift_shop

    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["global_hint_state_change_msg"] = this.on_global_hint_state_change_msg

    lister["qflb_qysclear_uichange"] = this.on_qflb_qysclear_uichange
    lister["qflb_back_to_minihall"] = this.on_qflb_back_to_minihall
    
    --请求小游戏累计赢金
    lister["query_little_game_leijiyingjin_value_response"] = this.on_query_little_game_leijiyingjin_value_response

    lister["MoneyCenterQFLBManager_enter_click"] = this.on_MoneyCenterQFLBManager_enter_click
end

function M.Init()
	M.Exit()
	this = MoneyCenterQFLBManager
    this.m_data = {}
    this.yingjin_value = 0
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
    this.m_data.enter_count = true
    this.money_center_qflb_config = money_center_qflb_config
end

function M.OnLoginResponse(result)
    if result == 0 then
        Network.SendRequest("query_all_return_lb_info", nil, "正在获取数据")
        Network.SendRequest("query_sczd_all_return_base_info", nil, "正在获取数据")
        local msg_list = {}
        for i,v in ipairs(this.money_center_qflb_config.qflb) do
            msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = v.task_id}}
            msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = v.task_id}}
            msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = v.task_id}}
        end
        GameManager.SendMsgList(M.key, msg_list)
	end
end

function M.OnReConnecteServerSucceed()
    Network.SendRequest("query_all_return_lb_info", nil, "正在获取数据")
    Network.SendRequest("query_sczd_all_return_base_info", nil, "正在获取数据")
    local msg_list = {}
    if this.money_center_qflb_config then
        for i,v in ipairs(this.money_center_qflb_config.qflb) do
            msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = v.task_id}}
            msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = v.task_id}}
            msg_list[#msg_list + 1] = {msg="query_one_task_data", data = {task_id = v.task_id}}
        end
        GameManager.SendMsgList(M.key, msg_list)
    end
end

function M.query_all_return_lb_info_response(_,data)
    dump(data, "<color=yellow>query_all_return_lb_info_response</color>")
    if data.result == 0 then
        this.m_data = this.m_data or {}
        data.result = nil
        this.m_data.all_return_lb_info = {}
        this.m_data.all_return_lb_info = data
    else
        HintPanel.ErrorMsg(data.result)
    end
    Event.Brocast("model_query_all_return_lb_info_response")
    Event.Brocast("global_hint_state_change_msg", {gotoui = MoneyCenterQFLBManager.key})
end

function M.query_sczd_all_return_base_info_response(_,data)
    dump(data, "<color=yellow>query_sczd_all_return_base_info_response</color>")
    if data.result == 0 then
        this.m_data = this.m_data or {}
        data.result = nil
        this.m_data.all_return_base_info = data
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.all_return_lb_change_msg(_,data)
    dump(data, "<color=yellow>all_return_lb_change_msg</color>")
    this.m_data = this.m_data or {}
    this.m_data.all_return_lb_info = this.m_data.all_return_lb_info or {}
    this.m_data.all_return_lb_info[data.lb_type] = data.all_return_lb
    Event.Brocast("model_all_return_lb_change_msg")
    Event.Brocast("global_hint_state_change_msg", {gotoui = MoneyCenterQFLBManager.key})
end

function M.get_data_all_return_lb_info()
    return this.m_data.all_return_lb_info
end

function M.get_cfg()
    return this.money_center_qflb_config
end

function M.on_query_send_list_fishing_msg(tag)
    if tag ~= M.key then return end
    Event.Brocast("global_hint_state_change_msg", {gotoui = MoneyCenterQFLBManager.key})
end

function M.on_finish_gift_shop(id)
	local is_re
	if this.money_center_qflb_config and this.money_center_qflb_config.qflb then
		for i,v in ipairs(this.money_center_qflb_config.qflb) do
			if id == v.good_id then
                is_re = true
                break
			end
		end
	end
    if not is_re then return end
    Event.Brocast("cfzx_qflb_finish_gift_shop",id)
    Event.Brocast("global_hint_state_change_msg", {gotoui = MoneyCenterQFLBManager.key})
end

function M.model_task_change_msg(task)
	local is_re
	if this.money_center_qflb_config and this.money_center_qflb_config.qflb then
		for i,v in ipairs(this.money_center_qflb_config.qflb) do
			if task.id == v.task_id then
                is_re = true
                break
			end
		end
	end
	if not is_re then return end
    Event.Brocast("cfzx_task_change_msg",task)
    Event.Brocast("global_hint_state_change_msg", {gotoui = MoneyCenterQFLBManager.key})
end

function M.model_get_task_award_response(data)
    if data.result == 0 then
        if data.id == 78 or data.id == 79 or data.id == 80 then
            LittleTips.Create("领取成功")
        end
    end
end

function M.get_my_money()
    dump(this.m_data.all_return_base_info, "<color=white>收益。。。</color>")
    local n = 0
    if this.m_data.all_return_base_info then
        for k,v in pairs(this.m_data.all_return_base_info) do
            if k ~= "xj_rebate_1" then
                n = n + v
            end
        end
    end
    return n / 100
end

function M.is_show()
    -- 3月10日更新后，因为礼包可以重复购买了，所以常驻显示了
    if true then
        return true
    end 

    if not this.m_data or not this.money_center_qflb_config or not this.m_data.all_return_lb_info then
        return false
    end
    local is_show = false
    local n = "all_return_lb_"
    local task_data = {}
    local qflb_data = {}
    for i,v in ipairs(this.money_center_qflb_config.qflb) do
        qflb_data = this.m_data.all_return_lb_info[n .. i]
        if qflb_data.is_buy == 0 then
            local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, v.good_id)
            local status = MainModel.GetGiftShopStatusByID(gift_config.id)
            local b1 = MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time)
            if b1 then
                if status ~= 1 then
                    is_show = false
                else
                    is_show = true
                end
            else
                is_show = false
            end
            if i == 1 then
                local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_buy_gift_bag_" .. v.good_id, is_on_hint = true}, "CheckCondition")
                if a then 
                    if b then
                        is_show = true
                    else
                        is_show = false
                    end
                end
            end
            if is_show then return true end
        elseif qflb_data.is_buy == 1 then
            --没有过期没有做完任务
            is_show = qflb_data.over_time > os.time() and qflb_data.remain_num > 0
            if is_show then return true end
            -- if is_show then
            --     task_data = GameTaskModel.GetTaskDataByID(v.task_id)
            --     if task_data then
            --         if task_data.award_status == 1 or task_data.award_status == 2 then
            --             is_show = true
            --         elseif task_data.award_status == 2 or task_data.award_status == 3 then
            --             is_show = false
            --         end
            --     else
            --         is_show = false
            --     end
            -- end
        end
    end
end
--是否在千元赛结算的时候显示全返礼包按钮
function M.IsShowQFLBEnterInQYSClear()
    local qflb_data2 = this.m_data.all_return_lb_info["all_return_lb_2"]
    dump(qflb_data2)
    if qflb_data2 then 
        if qflb_data2.is_buy == 0 or (qflb_data2.is_buy == 1 and qflb_data2.over_time < os.time()) then 
            return true
        end
    end
    return false
end
--是否小游戏大厅显示按钮
function M.IsShowQFLBEnterInMiniHall()
    if not this.m_data or not this.m_data.all_return_lb_info then return end
    local qflb_data3 = this.m_data.all_return_lb_info["all_return_lb_3"]
    dump(qflb_data3)
    if qflb_data3 then 
        if  (qflb_data3.is_buy == 0 or qflb_data3.over_time < os.time()) and this.yingjin_value >= 2000000 then 
            return true
        end
    end
    return false
end

--是否在某些结算界面显示
function M.IsShowClear()
    if M.IsBuy2() and M.IsBuy3() then
        return false
    else
        return true
    end
end

function M.IsBuy2( )
    local data = this.m_data.all_return_lb_info["all_return_lb_2"]
    if data then 
        if  (data.is_buy == 0 or data.over_time < os.time() or data.remain_num == 0)  then 
            return false
        end
    end
    return true
end

function M.IsBuy3()
    local data = this.m_data.all_return_lb_info["all_return_lb_3"]
    if data then 
        if  (data.is_buy == 0 or data.over_time < os.time() or data.remain_num == 0) then 
            return false
        end
    end
    return true
end

function M.on_qflb_qysclear_uichange(data)
    if data and data.panelSelf then 
        if M.IsShowQFLBEnterInQYSClear() and IsEquals(data.panelSelf.gameObject)  then 
            data.panelSelf.qflb_btn.onClick:RemoveAllListeners()
            data.panelSelf.qflb_btn.onClick:AddListener(
                function ()
                    QFLBNoticePanel.Create(nil,{title = "福利提示",tips = "买全返礼包Ⅱ送10张千元赛门票，\n<size=40>每次参赛<color=#ea1e1e>不论输赢</color>可领取<color=#ea1e1e>10元！</color></size>",_type = 2})
                end
            )
            
            dump(data.panelSelf.win_one_more_btn.gameObject.activeSelf,"<anniu>")
            dump(data.panelSelf.game_type,"qys")
            data.panelSelf.qflb_btn.gameObject:SetActive(data.panelSelf.game_type == "gms" or data.panelSelf.game_type == "hbs")
        else
            data.panelSelf.qflb_btn.gameObject:SetActive(false)
        end
    end
end

function M.on_qflb_back_to_minihall()
    Network.SendRequest("query_little_game_leijiyingjin_value")
end

function M.on_query_little_game_leijiyingjin_value_response(_,data)
    if data and data.result == 0 then 
        this.yingjin_value = data.yingjin_value
        if M.IsShowQFLBEnterInMiniHall() then 
            QFLBFlyEnterPrefab.Create()
        end 
    end
end 

function M.on_MoneyCenterQFLBManager_enter_click()
    this.m_data.enter_count = false
end

function M.GetEnterCount()
    return this.m_data.enter_count
end