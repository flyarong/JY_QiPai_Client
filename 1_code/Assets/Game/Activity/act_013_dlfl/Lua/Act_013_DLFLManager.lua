-- 创建时间:2020-05-11
-- Act_013_DLFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_013_DLFLManager = {}
local M = Act_013_DLFLManager
M.key = "act_013_dlfl"
Act_013_DLFLManager.award_config = GameButtonManager.ExtLoadLua(M.key,"act_013_award_config")
GameButtonManager.ExtLoadLua(M.key,"Act_013_DLFLPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_013_DLFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_013_DLFLBeforeBuyPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_013_DLFLAfterBuyPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_013_DLFLLotteryPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_013_DLFLEnterPrefab_InFLPanel")
local this
local lister
local qfxl_gift_id = 10246
local qfxl_gift_id2 = 10247
local _time_UnrealyData
local _time_IsAfter7Day
local _time_QFXL
local _time_benefits_data
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time = 1590449400
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then--NowTime - (NowTime + 8 * 3600) % 86400 
        return false
    end

    local dlfl_time = PlayerPrefs.GetInt(MainModel.UserInfo.user_id.."dlfl")
    if dlfl_time and dlfl_time == 0 and os.time() >= 1591027199 then
        return false--前7天内没买过的就不显示入口
    end

    if dlfl_time and dlfl_time ~= 0 and os.time() - (dlfl_time - (dlfl_time + 8*3600)%86400) >= 15552000 then
        return false--从购买礼包起,180天后,活动消失
    end

    -- 对应权限的key
    local _permission_key = "login_welfare"
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
        if M.CheckIsShow() then
            return Act_013_DLFLPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() and os.time() < 1591027199 then
            return Act_013_DLFLEnterPrefab.Create(parm.parent, parm.cfg)
        end 
    elseif parm.goto_scene_parm == "jyfl_enter" then
        if M.CheckIsShow() and os.time() >= 1591027199 then
            return Act_013_DLFLEnterPrefab_InFLPanel.Create(parm.parent)
        end
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end

end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if not M.IsActive() then return ACTIVITY_HINT_STATUS_ENUM.AT_Nor end
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

    --请求基本信息
    lister["query_player_login_benefits_base_info_response"] = this.on_query_player_login_benefits_base_info_response
    --请求全服限量的个数
    lister["query_gift_bag_num_response"] = this.on_query_gift_bag_num_response
    --请求假数据
    lister["get_one_login_benefits_false_lottery_data_response"] = this.on_get_one_login_benefits_false_lottery_data_response
    --请求抽奖数据
    lister["login_benefits_lottery_response"] = this.on_login_benefits_lottery_response
    --每日领取成功
    lister["login_benefits_receive_award_response"] = this.on_login_benefits_receive_award_response
    --监听礼包购买成功
    lister["finish_gift_shop"] = this.on_finish_gift_shop
end

function M.Init()
	M.Exit()

	this = Act_013_DLFLManager
	this.m_data = {}
    M.Init_M_Data()
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
    M.StopUpdateTime_benefits()
    M.StopUpdateTime_QFXL()
    M.StopUpdateTime_IsAfter7Day()
    M.StopUpdateTime_UnrealyData()
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
        if true or M.IsActive() then
            M.update_time_IsAfter7Day(true)--判断是否满7天了(7天后才请求跑马灯假数据并显示)
            Timer.New(function ()
                M.QueryData()
            end, 1, 1):Start()
        end
	end
end
function M.OnReConnecteServerSucceed()
end


function M.Init_M_Data()
    this.m_data.is_have_data = false--是否有基本数据
    this.m_data.is_have_num = false--是否有全服限量礼包的个数
    this.m_data.buy_time = 0
    this.m_data.qfxl_num = 200
    this.m_data.total_remain_num = 0
    this.m_data.login_day = 0
    this.m_data.is_receive = 0
end


function M.IsAwardCanGet()
    if this.m_data.buy_time ~= 0 and this.m_data.is_receive == 0 then
        return true
    else
        return false
    end

end

function M.StopUpdateTime_IsAfter7Day()
    if _time_IsAfter7Day then
        _time_IsAfter7Day:Stop()
        _time_IsAfter7Day = nil
    end
end
function M.update_time_IsAfter7Day(b)
    M.StopUpdateTime_IsAfter7Day()
    if b then
        dump(os.time(),"<color=blue>++++++++++++++++++++++++++++++</color>")
        _time_IsAfter7Day = Timer.New(function ()
            dump(os.time(),"<color=blue>++++++++++++++++++++++++++++++</color>")
            if os.time() >= 1591027199 then
                dump("<color=blue>++++++++++++++++++++++++++++++</color>")
                --Event.Brocast("model_dlfl_EnterPrefab_move")
                M.update_time_UnrealyData(true)
                M.StopUpdateTime_IsAfter7Day()
            end
        end, 60, -1, nil, true)
        _time_IsAfter7Day:Start()
    end
end

function M.StopUpdateTime_UnrealyData()
    if _time_UnrealyData then
        _time_UnrealyData:Stop()
        _time_UnrealyData = nil
    end
end
function M.update_time_UnrealyData(b)
    M.StopUpdateTime_UnrealyData()
    if b then
        M.QueryUnrealyData()
        _time_UnrealyData = Timer.New(function ()
            dump("<color=blue>++++++++++++++++++++++++++++++</color>")
            M.QueryUnrealyData()
        end, 30, -1, nil, true)
        _time_UnrealyData:Start()
    end
end
function M.QueryUnrealyData()
    Network.SendRequest("get_one_login_benefits_false_lottery_data")
end


function M.StopUpdateTime_QFXL()
    if _time_QFXL then
        _time_QFXL:Stop()
        _time_QFXL = nil
    end
end
function M.update_time_QFXL(b)
    M.StopUpdateTime_QFXL()
    if b then
        _time_QFXL = Timer.New(function ()
            M.QueryQFXLGiftData()
        end, 5, -1, nil, true)
        _time_QFXL:Start()
    end
end
function M.QueryQFXLGiftData()
    Network.SendRequest("query_gift_bag_num",{gift_bag_id = qfxl_gift_id})
end

function M.on_query_gift_bag_num_response(_,data)
    -- dump(data,"<color=blue>on_query_gift_bag_num_response</color>")
    if data.result == 0 and data.gift_bag_id == 10246 then
        this.m_data.qfxl_num = data.num
        Event.Brocast("model_dlfl_qfxl_num_change_msg")--刷新全服限量个数
        this.m_data.is_have_num = true
    end
end
function M.QueryData()
    if this.m_data.is_have_data and this.m_data.is_have_num then
        Event.Brocast("model_dlfl_data_change_msg")--刷新基本信息
    else
        M.query_data()
        M.QueryQFXLGiftData()
    end
end

function M.query_data()
    Network.SendRequest("query_player_login_benefits_base_info")   
end

function M.on_query_player_login_benefits_base_info_response(_,data)
    dump(data,"<color=blue>on_query_player_login_benefits_base_info_response</color>")
    if data.result == 0 then
        this.m_data.buy_time = data.buy_time                --购买时间
        this.m_data.total_remain_num = data.total_remain_num--剩余天数
        this.m_data.is_receive = data.is_receive            --是否领取
        this.m_data.login_day = data.login_day              --登录天数
        this.m_data.lottery_num = data.lottery_num          --抽奖次数
        this.m_data.server_time = data.server_time          --服务器时间
        Event.Brocast("model_dlfl_data_change_msg")--刷新基本信息
        M.SetHintState()
        this.m_data.is_have_data = true
        if this.m_data.buy_time ~= 0 then
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."dlfl",this.m_data.buy_time)
        end
    end
end

function M.on_get_one_login_benefits_false_lottery_data_response(_,data)
    dump(data,"<color=blue>on_get_one_login_benefits_false_lottery_data_response</color>")
    if data.result == 0 then
        if not this.m_data.unrealy then
            this.m_data.unrealy = {}
        end
        this.m_data.unrealy.name = data.name            --虚假数据的玩家昵称
        this.m_data.unrealy.award_name = data.award_name--虚假数据的奖励名称
        this.m_data.unrealy.award_id = data.award_id    --虚假数据的奖励id
        Event.Brocast("model_dlfl_unrealy_change_msg")--刷新假数据
    end
end


function M.on_login_benefits_lottery_response(_,data)
    dump(data,"<color=blue>on_login_benefits_lottery_response</color>")
    if data.result == 0 then
        if not this.m_data.lottery then
            this.m_data.lottery = {}
        end
        this.m_data.lottery.award_name = data.award_name--抽奖的奖励名称
        this.m_data.lottery.award_id = data.award_id    --抽奖的奖励id
        this.m_data.lottery.name = data.name            --抽奖的玩家昵称
        this.m_data.lottery_num = data.lottery_num      --抽奖次数
        Event.Brocast("model_dlfl_lottery_change_msg")
    end
end

function M.on_login_benefits_receive_award_response(_,data)
    dump(data,"<color=blue>on_login_benefits_receive_award_response</color>")
    if data.result == 0 then
        this.m_data.is_receive = 1

        Network.SendRequest("query_player_login_benefits_base_info")
        Event.Brocast("model_dlfl_receive_award_change_msg")--播放领取后抽奖次数增加的的特效
    end
end


function M.on_finish_gift_shop(id)
    dump(id,"<color=blue>on_finish_gift_shop</color>")
    if id == 10246 or id == 10247 then
        Network.SendRequest("query_player_login_benefits_base_info")
    end
end

--获取全服限量的个数
function M.GetQFXLNum()
    return this.m_data.qfxl_num
end

------------------------------

--获取购买时间(可以判断是否购买过)
function M.GetBuyTime()
    return this.m_data.buy_time
end

--获取当前剩余天数
function M.GetTotalRemainNum()
    return this.m_data.total_remain_num
end

--获取当前是否领取
function M.GetIsReceive()
    return this.m_data.is_receive
end

--获取当前登录天数
function M.GetLoginDay()
    return this.m_data.login_day
end

--获取当前抽奖次数
function M.GetLotteryNum()
    return this.m_data.lottery_num
end

---------------------

--获取虚假数据的玩家名字
function M.GetUnrealyPlayerName()
    return this.m_data.unrealy.name
end

--获取虚假数据的奖励名称
function M.GetUnrealyAwardName()
    return this.m_data.unrealy.award_name
end

--获取虚假数据的奖励id
function M.GetUnrealyAwardID()
    return this.m_data.unrealy.award_id
end

---------------------

--获取抽奖的奖励名称
function M.GetLotteryAwardName()
    return this.m_data.lottery.award_name
end

--获取抽奖的奖励id
function M.GetLotteryAwardId()
    return this.m_data.lottery.award_id
end

--获取抽奖的玩家名字
function M.GetLotteryPlayerName()
    return this.m_data.lottery.name
end


function M.StopUpdateTime_benefits()
    if _time_benefits_data then
        _time_benefits_data:Stop()
        _time_benefits_data = nil
    end
end
function M.update_time_benefits(b)
    M.StopUpdateTime_benefits()
    if b then
        _time_benefits_data = Timer.New(function ()
            M.query_data()
        end, 10, -1, nil, true)
        _time_benefits_data:Start()
    end
end