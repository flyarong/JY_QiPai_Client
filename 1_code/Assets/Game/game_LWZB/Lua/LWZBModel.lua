-- 创建时间:2020-08-26

LWZBModel = {}
local config = LWZBManager.config
local lwzb_stage_config = ext_require("Game.game_LWZB.Lua.lwzb_stage_config").stage
local M = LWZBModel

local this
local game_lister
local lister
local m_data
local update
local updateDt = 0.1

LWZBModel.Model_Status = {
    --游戏状态处于游戏中

    -- 充能
    bet = "bet",
    -- 比牌
    game = "game",
    -- 结算
    settle = "settle",
}
LWZBModel.Status = {
    -- 下注
    xiazhu = "xiazhu",
    -- 比牌
    bipai = "bipai",
}

function M.MakeLister()
	-- 游戏相关
    game_lister = {}

    -- 其他
    lister = {}

    lister["lwzb_all_info_response"] = this.on_all_info
    lister["lwzb_enter_room_response"] = this.on_lwzb_enter_room_response
    lister["lwzb_quit_room_response"] = M.on_lwzb_quit_room_response

    lister["lwzb_game_status_change"] = M.on_lwzb_game_status_change--龙王争霸 的状态改变
    lister["lwzb_total_bet_tb"] = M.on_lwzb_total_bet_tb--龙王争霸 同步 所有下注信息
    lister["lwzb_add_kaijiang_log"] = M.on_lwzb_add_kaijiang_log--龙王争霸 增加开奖记录
    lister["lwzb_player_num_change"] = M.on_lwzb_player_num_change--龙王争霸 人数改变
    lister["lwzb_make_dragon_list_change"] = M.on_lwzb_make_dragon_list_change--龙王争霸的list改变
    lister["lwzb_auto_bet_change_msg"] = M.on_lwzb_auto_bet_change_msg--龙王争霸 自动下注 改变消息

    lister["lwzb_auto_bet_response"] = M.on_lwzb_auto_bet_response--开启自动下注
    lister["lwzb_do_auto_bet_response"] = M.on_lwzb_do_auto_bet_response--请求自动下注的数据
    lister["lwzb_cancel_auto_bet_response"] = M.on_lwzb_cancel_auto_bet_response--取消自动下注
    lister["lwzb_accurate_bet_response"] = M.on_lwzb_accurate_bet_response--精准下注
    lister["lwzb_bet_response"] = M.on_lwzb_bet_response--下注
    lister["lwzb_cancel_bet_response"] = M.on_lwzb_cancel_bet_response--取消下注
    lister["lwzb_continue_bet_response"] = M.on_lwzb_continue_bet_response--连续下注

    lister["lwzb_query_make_dragon_list_response"] = M.on_lwzb_query_make_dragon_list_response--争夺龙王
    lister["lwzb_make_dragon_response"] = M.on_lwzb_make_dragon_response--成为龙王
    lister["lwzb_cancel_dragon_response"] = M.on_lwzb_cancel_dragon_response--取消成为龙王

    lister["EnterBackGround"] = this.on_background_msg--切到后台
    lister["EnterForeGround"] = this.on_foreground_msg--切到前台
    lister["lwzb_qlcf_kaijiang_msg"] = this.on_lwzb_qlcf_kaijiang_msg--其他房间开出了麒麟赐福
end
function M.AddMsgListener()
    for proto_name, _ in pairs(game_lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, _)
    end
end

function M.RemoveMsgListener()
    for proto_name, _ in pairs(game_lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, _)
    end
end

local function MsgDispatch(proto_name, data)
    -- dump(data, "<color=red>proto_name:</color>" .. proto_name)
    local func = lister[proto_name]

    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
        return
    end

    if data.status_no then
    	-- 断线重连的数据不用判断status_no
    	-- "all_info" 根据具体游戏命名
        if proto_name ~= "all_info" then
            if m_data.status_no + 1 ~= data.status_no and m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no
                print("<color=red>proto_name = " .. proto_name .. "</color>")
                dump(data)
                --发送状态编码错误事件
                Event.Brocast("model_status_no_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no
    end
    func(proto_name, data)
end
local function InitData()
    M.data = {}
    m_data = M.data
end
function M.Init()
    this = M
    InitData()
    M.InitUIConfig()
    M.MakeLister()
    M.AddMsgListener()

    return this
end

function M.Exit()
    if this then
        M.StopGamingAnimTimer()
        M.RemoveMsgListener()
        this = nil
        game_lister = nil
        lister = nil
        m_data = nil
        M.data = nil
    end
end

function M.InitUIConfig()
    this.UIConfig = {}

    -- 档次配置
    this.UIConfig.rate_list = config.rate

    -- 财神大奖配置 
    this.UIConfig.csdj_info = config.csdj

    --争夺龙王中成为龙王的限制
    this.UIConfig.snatch_limit = config.snatch_limit

    --各个阶段(status)的时间
    this.UIConfig.Phase_time = config.phase_time

    --充能限制
    this.UIConfig.bet_limit = config.bet_limit
end

------------------------------------------
--                 Fun                  --
------------------------------------------

function M.Vec2DLength(vec)
    return math.sqrt(vec.x*vec.x + vec.y*vec.y)
end
function M.Vec2DDotMult(vec1, vec2)
    return vec1.x*vec2.x + vec1.y*vec2.y
end
function M.Vec2DAngle(vec)
    local r = math.acos( M.Vec2DDotMult(vec, {x=1,y=0}), M.Vec2DLength(vec) ) * (180 / math.pi)
    if vec.y < 0 then
        r = 360 - r
    end
    return r
end
-- 获取当前档次倍率表
function M.GetCurYZConfig()
    --[[if not m_data.cur_rate_list then
        local list = this.UIConfig.rate_list
        for k,v in ipairs(list) do
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                m_data.cur_rate_list = v.gun_rate
                break
            end
        end
    end
    if not m_data.cur_rate_list and AppDefine.IsEDITOR() then
        HintPanel.Create(1, "没有对应押注档次")
    end--]]
    local list = this.UIConfig.rate_list
    dump(LWZBManager.GetCurGame_id(),"<color>++++++++++++++++++++</color>")
    return list[LWZBManager.GetCurGame_id()].gun_rate
end
-- 获取推荐索引
function M.GetTJIndex()
    local mm = MainModel.UserInfo.jing_bi
    local zz = mm / 25 -- 用户携带鲸币数量/25
    local list = M.GetCurYZConfig()
    local tj
    for k,v in ipairs(list) do
        if not tj then
            tj = k
        else
            if math.abs(list[tj] - zz) > math.abs(list[k] - zz) then
                tj = k
            end
        end
    end
    m_data.cur_rate_index = tj
    return tj
end
-- 修改倍率
function M.GetChangeGunIndex(index, cg)
    local list = M.GetCurYZConfig()

    for k,v in ipairs(list) do
        if index == k then
            local cgk = k + cg
            if cgk < 1 then
                m_data.cur_rate_index = #list
                return #list
            elseif cgk > #list then
                m_data.cur_rate_index = 1
                return 1
            else
                m_data.cur_rate_index = cgk
                return cgk
            end
        end
    end
end

--获取当前正在使用的倍率索引
function M.GetCurRateIndex()
    return m_data.cur_rate_index
end

--获取6局历史胜负情况
function M.GetHistorySFData(index)
    if not table_is_null(m_data.all_info.history_data) then
        local tab = {}
        local length = 0
        dump(m_data.all_info.history_data,"<color=red>@@@@@@@@@@@@@@@</color>")
        if m_data.all_info.history_data and #m_data.all_info.history_data < 6 then
            length = #m_data.all_info.history_data
        else
            length = 6
        end
        for i=1,length do
            tab[index] = tab[index] or {}
            tab[index][i] = m_data.all_info.history_data[i].win_lost_data[index]
        end
        return tab[index]
    else
        return false
    end
end

function M.GetPXconfig()
    local game_id = LWZBManager.GetCurGame_id()
    local index = "ground"..game_id
    return config[index]
end

function M.on_all_info(_,data)
    dump(data,"<color=yellow>--------------on_all_info--------------</color>")
    if data.result == 0 then
        m_data.all_info = m_data.all_info or {}
        LWZBManager.SetCurGame_id(data.game_id)

        ------------------------针对32位手机---------------------
        for i=1,#data.bet_data.total_bet_data do
            data.bet_data.total_bet_data[i] = tonumber(data.bet_data.total_bet_data[i])
        end
        for i=1,#data.bet_data.my_bet_data do
            data.bet_data.my_bet_data[i] = tonumber(data.bet_data.my_bet_data[i])
        end
        for i=1,#data.settle_data.award_value do
            data.settle_data.award_value[i] = tonumber(data.settle_data.award_value[i])
        end
        data.settle_data.dragon_award = tonumber(data.settle_data.dragon_award)
        if data.settle_data and data.settle_data.qlcf_big_award then
            data.settle_data.qlcf_big_award.award_value = tonumber(data.settle_data.qlcf_big_award.award_value)
        end
        data.dragon_info.jing_bi = tonumber(data.dragon_info.jing_bi)
        data.last_qlcf_big_award.award_value = tonumber(data.last_qlcf_big_award.award_value)
        for i=1,#data.dragon_list do
            data.dragon_list[i].jing_bi = tonumber(data.dragon_list[i].jing_bi)
        end
        ------------------------针对32位手机---------------------


        m_data.Model_Status = data.status_data.status--游戏状态
        m_data.all_info.status_data = data.status_data--状态数据
        m_data.all_info.bet_data = data.bet_data--下注数据，下注阶段能用到的数据
        m_data.all_info.game_data = data.game_data--游戏数据，游戏阶段能用到的数据
        m_data.all_info.settle_data = data.settle_data--结算数据，结算阶段能用到的数据
        m_data.all_info.dragon_info = data.dragon_info--当前龙王的信息
        m_data.all_info.fuhao_rank = data.fuhao_rank--富豪榜
        m_data.all_info.lucky_star = data.lucky_star--幸运星
        m_data.all_info.history_data = data.history_data--历史记录
        m_data.all_info.last_qlcf_big_award = data.last_qlcf_big_award--上次麒麟赐福头奖信息
        m_data.dragon_list = data.dragon_list
        if M.CheckIsReConnecte() then
            Event.Brocast("model_lwzb_all_info_reconnecte_msg")
        else
            Event.Brocast("model_lwzb_all_info_msg")  
        end  
        if data.status_data.status == "game" then
            m_data.gaming_anim_time = this.UIConfig.Phase_time.game.time - m_data.all_info.status_data.time_out
            M.GamingAnimTimer(true,true)
        else
            m_data.gaming_anim_time = 0
            M.GamingAnimTimer(false,true)
        end
               
        Event.Brocast("model_lwzb_recover_finish")
        if LWZBManager.GetLwzbGuideOnOff() and not m_data.onoff then
            m_data.onoff = true
            Event.Brocast("lwzb_guide_check")
        end
    else
        GameManager.GotoSceneName("game_LWZBHall")
    end
end

function M.GetCurStatus()
    if m_data and m_data.Model_Status then
        return m_data.Model_Status
    end
end

function M.GetCurStatusTimeCfg()
    local status = M.GetCurStatus()
    if (M.GetCurStatus() == M.Model_Status.settle) and M.CheckIsQLCF() then--如果当前是结算阶段,且是麒麟赐福
        status = "settle_qlcf"
    end
    print(debug.traceback())
    dump(this.UIConfig.Phase_time,"<color=blue>+++++++this.UIConfig.Phase_time+++++++</color>")
    dump(status,"<color=blue>++++++status++++++++</color>")
    return this.UIConfig.Phase_time[status].time
end

--检查是否是断线重连
function M.CheckIsReConnecte()
    if m_data.all_info.status_data.time_out == M.GetCurStatusTimeCfg() then--正常状态
        return false
    else--断线重连状态
        return true
    end
end

function M.on_lwzb_enter_room_response(_, data)
    dump(data,"<color=yellow>+++++++++on_lwzb_enter_room_response++++++++++</color>")
    if data.result == 0 then
        Event.Brocast("model_lwzb_enter_room_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_lwzb_quit_room_response(_, data)
    dump(data,"<color=yellow>+++++++++on_lwzb_quit_room_response++++++++++</color>")
    if data.result == 0 then
        Event.Brocast("model_lwzb_quit_room_response")

        Event.Brocast("quit_game_success")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.GetAllInfo()
    return m_data.all_info
end


function M.on_lwzb_game_status_change(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_game_status_change--------------</color>")
    if data then
        m_data.all_info = m_data.all_info or {}



        ------------------------针对32位手机---------------------
        for i=1,#data.bet_data.total_bet_data do
            data.bet_data.total_bet_data[i] = tonumber(data.bet_data.total_bet_data[i])
        end
        for i=1,#data.bet_data.my_bet_data do
            data.bet_data.my_bet_data[i] = tonumber(data.bet_data.my_bet_data[i])
        end
        for i=1,#data.settle_data.award_value do
            data.settle_data.award_value[i] = tonumber(data.settle_data.award_value[i])
        end
        data.settle_data.dragon_award = tonumber(data.settle_data.dragon_award)
        if data.settle_data and data.settle_data.qlcf_big_award then
            data.settle_data.qlcf_big_award.award_value = tonumber(data.settle_data.qlcf_big_award.award_value)
        end
        if data.status_data.status == M.Model_Status.settle or data.status_data.status == M.Model_Status.bet then
            data.dragon_info.jing_bi = tonumber(data.dragon_info.jing_bi)
        end
        ------------------------针对32位手机---------------------



        m_data.Model_Status = data.status_data.status--游戏状态
        m_data.all_info.status_data = data.status_data--状态数据
        m_data.all_info.bet_data = data.bet_data--下注数据，下注阶段能用到的数据
        m_data.all_info.game_data = data.game_data--游戏数据，游戏阶段能用到的数据
        m_data.all_info.settle_data = data.settle_data--结算数据，结算阶段能用到的数据
        if data.settle_data and data.settle_data.qlcf_big_award then
            m_data.all_info.last_qlcf_big_award = data.settle_data.qlcf_big_award
        end
        if data.status_data.status == M.Model_Status.settle or data.status_data.status == M.Model_Status.bet then
            m_data.all_info.dragon_info = data.dragon_info
            m_data.all_info.fuhao_rank = data.fuhao_rank
            m_data.all_info.lucky_star = data.lucky_star
        end
        if data.status_data.status == "game" then
            m_data.gaming_anim_time = this.UIConfig.Phase_time.game.time - m_data.all_info.status_data.time_out
            M.GamingAnimTimer(true,false)
        else
            m_data.gaming_anim_time = 0
            M.GamingAnimTimer(false,false)
        end
        M.DeletTemp_data_tab()
        Event.Brocast("model_lwzb_status_change_msg")  
        m_data.bet_type = nil
        Event.Brocast("model_bet_type_has_change_msg")
    end
end

function M.on_lwzb_total_bet_tb(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_total_bet_tb--------------</color>")
    if data then
        m_data.all_info = m_data.all_info or {}
        m_data.all_info.bet_data = m_data.all_info.bet_data or {}
        for i=1,#data.total_bet_data do
            data.total_bet_data[i] = tonumber(data.total_bet_data[i])
        end
        local temp_tab = m_data.all_info.bet_data.total_bet_data
        m_data.all_info.bet_data.total_bet_data = data.total_bet_data--各个神兽总下注
        m_data.all_info.bet_data.lucky_star_bet_pos = data.lucky_star_bet_pos--幸运星的位置
        if table_is_null(temp_tab) then
            Event.Brocast("model_lwzb_total_bet_tb_msg")
        else
            local tab = {}
            for i=1,#data.total_bet_data do
                if data.total_bet_data[i] > temp_tab[i] then
                    tab[i] = 1
                else
                    tab[i] = 0
                end
            end
            Event.Brocast("model_lwzb_total_bet_tb_msg",tab)
        end
    end
end

function M.on_lwzb_add_kaijiang_log(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_add_kaijiang_log--------------</color>")
    if data then
        m_data.all_info = m_data.all_info or {}
        local tab = m_data.all_info.history_data
        m_data.all_info.history_data = {}
        m_data.all_info.history_data[#m_data.all_info.history_data + 1] = data.kaijiang_type
        if not table_is_null(tab) then
            for i=1,#tab do
                m_data.all_info.history_data[#m_data.all_info.history_data + 1] = tab[i]
            end
        end
        if #m_data.all_info.history_data > 50 then
            table.remove(m_data.all_info.history_data,#m_data.all_info.history_data)
        end

        if M.GetCurStatus() == M.Model_Status.settle then
            Event.Brocast("model_lwzb_add_kaijiang_log_msg")
        end
    end
end

function M.on_lwzb_player_num_change(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_player_num_change--------------</color>")
    if data then
        m_data.all_info = m_data.all_info or {}
        m_data.all_info.status_data = m_data.all_info.status_data or {}
        m_data.all_info.status_data.player_num = data.player_num
        Event.Brocast("model_lwzb_player_num_change_msg")
    end
end

function M.on_lwzb_make_dragon_list_change(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_make_dragon_list_change--------------</color>")
    if data then
        for i=1,#data.dragon_list do
            data.dragon_list[i].jing_bi = tonumber(data.dragon_list[i].jing_bi)
        end
        m_data.dragon_list = data.dragon_list
        m_data.all_info = m_data.all_info or {}
        m_data.all_info.dragon_info = data.dragon_list[1]
        Event.Brocast("model_zdlw_dragon_list_change_msg")
    end
end

--设置自动下注
function M.SetAutoBet()
    --[[if m_data.all_info.bet_data.is_auto_bet == 1 then
        Network.SendRequest("lwzb_cancel_auto_bet")     
    else--]]
        Network.SendRequest("lwzb_auto_bet")
    --[[end--]]
end

--在自动下注状态下请求下注的数据
function M.QueryAutoBetDataIfBeAuto()
    if m_data.all_info.bet_data.is_auto_bet == 1 then
        Network.SendRequest("lwzb_do_auto_bet")
    end
end

function M.on_lwzb_do_auto_bet_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_do_auto_bet_response--------------</color>")
    if data and data.result == 0 then
        m_data.all_info.bet_data.is_auto_bet = 1
        m_data.temp_data_tab = m_data.temp_data_tab or {}
        m_data.temp_data_tab[1]= m_data.temp_data_tab[1] or {}
        m_data.temp_data_tab[2]= m_data.temp_data_tab[2] or {}
        m_data.temp_data_tab[3]= m_data.temp_data_tab[3] or {}
        m_data.temp_data_tab[4]= m_data.temp_data_tab[4] or {}

        m_data.temp_data_tab[1][#m_data.temp_data_tab[1] + 1] = data.bet_1
        m_data.temp_data_tab[2][#m_data.temp_data_tab[2] + 1] = data.bet_2
        m_data.temp_data_tab[3][#m_data.temp_data_tab[3] + 1] = data.bet_3
        m_data.temp_data_tab[4][#m_data.temp_data_tab[4] + 1] = data.bet_4
        local tab = {}
        local temp = 0
        for i=1,#m_data.temp_data_tab do
            if not table_is_null(m_data.temp_data_tab[i]) then
                for j=1,#m_data.temp_data_tab[i] do
                    for n=1,#m_data.temp_data_tab[i][j] do
                        temp = temp + M.MathGetBet(m_data.temp_data_tab[i][j][n])
                    end
                end
            end
            tab[#tab + 1] = temp
            temp = 0
        end
        for i=1,#m_data.all_info.bet_data.my_bet_data do
            m_data.all_info.bet_data.my_bet_data[i] = tab[i]
        end
        --[[m_data.all_info.bet_data.my_bet_data[1] = data.bet_1
        m_data.all_info.bet_data.my_bet_data[2] = data.bet_2
        m_data.all_info.bet_data.my_bet_data[3] = data.bet_3
        m_data.all_info.bet_data.my_bet_data[4] = data.bet_4--]]
        Event.Brocast("model_lwzb_auto_bet_data_msg")
        m_data.bet_type = "auto"
        Event.Brocast("model_bet_type_has_change_msg")

    else
        Network.SendRequest("lwzb_cancel_auto_bet")
    end
end

function M.on_lwzb_auto_bet_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_auto_bet_response--------------</color>")
    if data then 
        if data.result == 0 then
            m_data.all_info.bet_data.is_auto_bet = 1
            if not M.GetCurBetType() then
                Network.SendRequest("lwzb_do_auto_bet")
            end
            Event.Brocast("model_lwzb_auto_bet_response")
        else
            if data.result == 5345 then
                LittleTips.Create("上轮未充能，无法自动充能")
            end
        end
    end
end

function M.on_lwzb_cancel_auto_bet_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_cancel_auto_bet_response--------------</color>")
    if data and data.result == 0 then
        m_data.all_info.bet_data.is_auto_bet = 0
        Event.Brocast("model_lwzb_cancel_auto_bet_response")
    end
end

function M.JZBet(index)
    Network.SendRequest("lwzb_accurate_bet",{bet_pos = index})
end

function M.on_lwzb_accurate_bet_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_accurate_bet_response--------------</color>")
    if data and data.result == 0 then

    end
end

function M.Bet(index,rate_index)
    if LWZBManager.GetLwzbGuideOnOff() then
        Event.Brocast("lwzb_bet_response","lwzb_bet_response",{bet_1 = {},bet_2 = {},bet_3 = {1},bet_4 = {},result = 0})
        return
    end
    if MainModel.UserInfo.jing_bi < M.MathGetBet(rate_index) then
        --金币不足,弹商城
        PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
    else
        local bet1 = {}
        local bet2 = {}
        local bet3 = {}
        local bet4 = {}
        if index == 1 then
            bet1[#bet1 + 1] = rate_index
        elseif index == 2 then
            bet2[#bet2 + 1] = rate_index
        elseif index == 3 then
            bet3[#bet3 + 1] = rate_index
        elseif index == 4 then
            bet4[#bet4 + 1] = rate_index
        end
        dump(bet1,"<color>++++++++1+++++++</color>")
        dump(bet2,"<color>++++++++2+++++++</color>")
        dump(bet3,"<color>++++++++3+++++++</color>")
        dump(bet4,"<color>++++++++4+++++++</color>")
        Network.SendRequest("lwzb_bet",{bet_1 = bet1,bet_2 = bet2,bet_3 = bet3,bet_4 = bet4})
    end
end

function M.on_lwzb_bet_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_bet_response--------------</color>")
    if LWZBManager.GetLwzbGuideOnOff() then
        M.GetGuideData("game")
    end
    if data and data.result == 0 then
        m_data.temp_data_tab = m_data.temp_data_tab or {}
        m_data.temp_data_tab[1]= m_data.temp_data_tab[1] or {}
        m_data.temp_data_tab[2]= m_data.temp_data_tab[2] or {}
        m_data.temp_data_tab[3]= m_data.temp_data_tab[3] or {}
        m_data.temp_data_tab[4]= m_data.temp_data_tab[4] or {}

        m_data.temp_data_tab[1][#m_data.temp_data_tab[1] + 1] = data.bet_1
        m_data.temp_data_tab[2][#m_data.temp_data_tab[2] + 1] = data.bet_2
        m_data.temp_data_tab[3][#m_data.temp_data_tab[3] + 1] = data.bet_3
        m_data.temp_data_tab[4][#m_data.temp_data_tab[4] + 1] = data.bet_4
        local tab = {}
        local temp = 0
        for i=1,#m_data.temp_data_tab do
            if not table_is_null(m_data.temp_data_tab[i]) then
                for j=1,#m_data.temp_data_tab[i] do
                    for n=1,#m_data.temp_data_tab[i][j] do
                        temp = temp + M.MathGetBet(m_data.temp_data_tab[i][j][n])
                    end
                end
            end
            tab[#tab + 1] = temp
            temp = 0
        end
        local temp_temp_tab = {}
        for i=1,#m_data.all_info.bet_data.my_bet_data do
            temp_temp_tab[i] = tonumber(m_data.all_info.bet_data.my_bet_data[i])
        end
        
        for i=1,#m_data.all_info.bet_data.my_bet_data do
            m_data.all_info.bet_data.my_bet_data[i] = tab[i]
        end
--------------
        local fun = function ()
            for i=1,#temp_temp_tab do
                if temp_temp_tab[i] > 0 then
                    return true
                end
            end
            return false
        end
        if not fun() then
            Event.Brocast("model_lwzb_bet_response")
        else
            local tab = {}
            for i=1,#m_data.all_info.bet_data.my_bet_data do
                if tonumber(m_data.all_info.bet_data.my_bet_data[i]) > temp_temp_tab[i] then
                    tab[i] = 1
                else
                    tab[i] = 0
                end
            end
            Event.Brocast("model_lwzb_bet_response",tab)
        end
-----------------
        Event.Brocast("model_lwzb_continue_bet_msg",true)
        m_data.bet_type = "normal"
    else
        if data.result == 5350 then
            LittleTips.Create("充能已达到上限，不可继续充能。提升Vip等级可提高充能上限!")
        else
            HintPanel.ErrorMsg(data.result)
        end
    end
end

--清空下注暂存表
function M.DeletTemp_data_tab()
    m_data.temp_data_tab = {}
end

function M.MathGetBet(rate_index)
    local rate_list = M.GetCurYZConfig()
    if rate_list[rate_index] then
        return rate_list[rate_index]
    else
        return 0
    end
end

function M.ContinueBet()
    Network.SendRequest("lwzb_continue_bet")
end

function M.on_lwzb_continue_bet_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_continue_bet_response--------------</color>")
    if data then
        if data.result == 0 then
            m_data.temp_data_tab = m_data.temp_data_tab or {}
            m_data.temp_data_tab[1]= m_data.temp_data_tab[1] or {}
            m_data.temp_data_tab[2]= m_data.temp_data_tab[2] or {}
            m_data.temp_data_tab[3]= m_data.temp_data_tab[3] or {}
            m_data.temp_data_tab[4]= m_data.temp_data_tab[4] or {}

            m_data.temp_data_tab[1][#m_data.temp_data_tab[1] + 1] = data.bet_1
            m_data.temp_data_tab[2][#m_data.temp_data_tab[2] + 1] = data.bet_2
            m_data.temp_data_tab[3][#m_data.temp_data_tab[3] + 1] = data.bet_3
            m_data.temp_data_tab[4][#m_data.temp_data_tab[4] + 1] = data.bet_4
            local tab = {}
            local temp = 0
            for i=1,#m_data.temp_data_tab do
                if not table_is_null(m_data.temp_data_tab[i]) then
                    for j=1,#m_data.temp_data_tab[i] do
                        for n=1,#m_data.temp_data_tab[i][j] do
                            temp = temp + M.MathGetBet(m_data.temp_data_tab[i][j][n])
                        end
                    end
                end
                tab[#tab + 1] = temp
                temp = 0
            end
            for i=1,#m_data.all_info.bet_data.my_bet_data do
                m_data.all_info.bet_data.my_bet_data[i] = tab[i]
            end
            --[[m_data.all_info.bet_data.my_bet_data[1] = data.bet_1
            m_data.all_info.bet_data.my_bet_data[2] = data.bet_2
            m_data.all_info.bet_data.my_bet_data[3] = data.bet_3
            m_data.all_info.bet_data.my_bet_data[4] = data.bet_4--]]
            Event.Brocast("model_lwzb_continue_bet_success_mag")

            m_data.bet_type = "continue"
            Event.Brocast("model_bet_type_has_change_msg")
            
        else
            if data.result ~= 1008 then
                LittleTips.Create("上局无充能记录")
            end
        end
    end
end


function M.QueryMakeDragonData()
    Network.SendRequest("lwzb_query_make_dragon_list")
end

function M.on_lwzb_query_make_dragon_list_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_query_make_dragon_list_response--------------</color>")
    if data and data.result == 0 then
        for i=1,#data.dragon_list do
            data.dragon_list[i].jing_bi = tonumber(data.dragon_list[i].jing_bi)
        end
        m_data.dragon_list = data.dragon_list
        m_data.all_info.dragon_info = data.dragon_list[1]
        Event.Brocast("model_lwzb_query_make_dragon_list_msg")
    end
end

function M.GetDragonList()
    return m_data.dragon_list
end

function M.MakeDragon()
    Network.SendRequest("lwzb_make_dragon",nil,"")
end

function M.on_lwzb_make_dragon_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_make_dragon_response--------------</color>")
    if data and data.result == 0 then
        m_data.dragon_list[#m_data.dragon_list + 1] = {}
        m_data.dragon_list[#m_data.dragon_list].jing_bi = MainModel.UserInfo.jing_bi
        m_data.dragon_list[#m_data.dragon_list].player_info = {}
        m_data.dragon_list[#m_data.dragon_list].player_info.head_image = MainModel.UserInfo.head_image
        m_data.dragon_list[#m_data.dragon_list].player_info.player_id = MainModel.UserInfo.user_id
        m_data.dragon_list[#m_data.dragon_list].player_info.player_name = MainModel.UserInfo.name
        m_data.dragon_list[#m_data.dragon_list].player_info.vip_level = MainModel.UserInfo.vip_level
        m_data.dragon_list[#m_data.dragon_list].remain_num = 8
        Event.Brocast("model_lwzb_make_dragon_msg")
    end
end

function M.CancelDragon()
    Network.SendRequest("lwzb_cancel_dragon",nil,"")
end

function M.on_lwzb_cancel_dragon_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_cancel_dragon_response--------------</color>")
    if data and data.result == 0 then
        dump(m_data.dragon_list)
        dump(MainModel.UserInfo.user_id)
        for k,v in pairs(m_data.dragon_list) do
            if v.player_info.player_id == MainModel.UserInfo.user_id  and k ~= 1 then
                table.remove(m_data.dragon_list,k)
            end
        end
        Event.Brocast("model_lwzb_cancel_dragon_msg")
    end
end

--取消下注
function M.CancelBet()
    Network.SendRequest("lwzb_cancel_bet")
end

--取消自动下注
function M.CancelAutoBet()
    Network.SendRequest("lwzb_cancel_auto_bet")
end

function M.on_lwzb_cancel_bet_response(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_cancel_bet_response--------------</color>")
    if data and data.result == 0 then
        M.DeletTemp_data_tab()
        m_data.all_info.bet_data.my_bet_data[1] = 0
        m_data.all_info.bet_data.my_bet_data[2] = 0
        m_data.all_info.bet_data.my_bet_data[3] = 0
        m_data.all_info.bet_data.my_bet_data[4] = 0
        Event.Brocast("model_on_lwzb_cancel_bet_response")
        Event.Brocast("model_lwzb_continue_bet_msg",false)
        m_data.bet_type = nil
        Event.Brocast("model_bet_type_has_change_msg")
        
    end
end

function M.on_lwzb_auto_bet_change_msg(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_auto_bet_change_msg--------------</color>")
    if data then
        m_data.all_info.bet_data.is_auto_bet = data.is_auto_bet
        Event.Brocast("model_lwzb_auto_bet_change_msg")
    end
end

function M.on_background_msg()
    if m_data.all_info then
        m_data.last_status = m_data.all_info.status_data.status
        m_data.last_status_end_time = os.time() + m_data.all_info.status_data.time_out
        Network.SendRequest("lwzb_cancel_auto_bet")
        m_data.on_background = true
    end
end

function M.on_foreground_msg()
    m_data.on_background = false
    --[[if m_data.last_status == m_data.all_info.status_data.status and os.time() < m_data.last_status_end_time then
        Event.Brocast("model_lwzb_all_info_reconnecte_msg")
    end--]]
end

--获取成为龙王的限制条件
function M.GetSnatchLimit()
    return this.UIConfig.snatch_limit[LWZBManager.GetCurGame_id()].limit
end

--判断是否是麒麟赐福
function M.CheckIsQLCF()
    if m_data.all_info.settle_data.is_qlcf and m_data.all_info.settle_data.is_qlcf == 1 then--是麒麟赐福
        return true
    else
        return false
    end
end

function M.GetQLCFConfig()
    return this.UIConfig.csdj_info
end

function M.GetCurBetType()
    return m_data.bet_type
end

function M.GetPhase_timeConfig()
    return this.UIConfig.Phase_time
end

function M.on_lwzb_qlcf_kaijiang_msg(_,data)
    dump(data,"<color=yellow>--------------on_lwzb_qlcf_kaijiang_msg--------------</color>")
    if data then
        m_data.all_info = m_data.all_info or {}
        m_data.all_info.status_data = m_data.all_info.status_data or {}
        m_data.all_info.status_data.qlcf_award_pool = tonumber(data.qlcf_award_pool)
        m_data.all_info.settle_data = m_data.all_info.settle_data or {}
        data.qlcf_big_award.award_value = tonumber(data.qlcf_big_award.award_value)
        m_data.all_info.settle_data.qlcf_big_award = data.qlcf_big_award
        Event.Brocast("model_on_lwzb_qlcf_kaijiang_msg")
    end
end

function M.CheckIisLW()
    if not table_is_null(m_data.all_info) and m_data.all_info.dragon_info then
        if m_data.all_info.dragon_info.player_info.player_id == MainModel.UserInfo.user_id then
            return true
        end
    end
    return false
end

function M.CheckIisInLWZDList()
    if not table_is_null(m_data.dragon_list) then
        for k,v in pairs(m_data.dragon_list) do
            if v then
                if v.player_info.player_id == MainModel.UserInfo.user_id then
                    return true
                end
            end
        end
    end
    return false
end

function M.GetBetLimit()
    local tab = {}
    tab[1] = {}
    tab[2] = {}
    local bet_list = this.UIConfig.bet_limit
    for i=1,#bet_list do
        if bet_list[i].game_id == 1 then
            tab[1][#tab[1] + 1] = bet_list[i]
        elseif bet_list[i].game_id == 2 then
            tab[2][#tab[2] + 1] = bet_list[i]
        end
    end
    local list = tab[LWZBManager.GetCurGame_id()]
    for k,v in ipairs(list) do
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.permission_key, is_on_hint = true}, "CheckCondition")
        if a and b then
            m_data.base_limit = v.base_limit
            m_data.total_bet_limit = v.total_bet_limit
            m_data.my_total_bet_limit = v.my_total_bet_limit
            break
        end
    end
end

function M.CheckAllBetLimit()
    M.GetBetLimit()
    local my_all_bet = 0
    for i=1,#m_data.all_info.bet_data.my_bet_data do
       my_all_bet = my_all_bet + tonumber(m_data.all_info.bet_data.my_bet_data[i])
    end
    local rate_index = M.GetCurRateIndex()
    local cur_bet = M.MathGetBet(rate_index)
    if my_all_bet + cur_bet > m_data.total_bet_limit then
        return true
    else
        return false
    end
end

function M.CheckSSBetLimit(index)
    M.GetBetLimit()
    local rate_index = M.GetCurRateIndex()
    local cur_bet = M.MathGetBet(rate_index)
    if m_data.all_info.bet_data.my_bet_data[index] + cur_bet > m_data.base_limit[index] then
        return true
    else
        return false
    end
end

function M.CheckAllBetPercentageLimit()
    M.GetBetLimit()
    local my_all_bet = 0
    for i=1,#m_data.all_info.bet_data.my_bet_data do
       my_all_bet = my_all_bet + tonumber(m_data.all_info.bet_data.my_bet_data[i])
    end
    local rate_index = M.GetCurRateIndex()
    local cur_bet = M.MathGetBet(rate_index)
    if (my_all_bet + cur_bet) > (m_data.my_total_bet_limit/100 * (MainModel.UserInfo.jing_bi + my_all_bet)) then
        return true
    else
        return false
    end
end

function M.CheckIIsBetSS(index)
    if m_data.all_info.bet_data.my_bet_data[index] > 0 then
        return true
    else
        return false
    end
end

function M.IsIBetSomeOne()
    if m_data.all_info and m_data.all_info.bet_data and m_data.all_info.bet_data.my_bet_data then
        for i=1,#m_data.all_info.bet_data.my_bet_data do
            if tonumber(m_data.all_info.bet_data.my_bet_data[i]) > 0 then
                return true
            end
        end
    end
    return false
end

--查找我当前能够选中的最大档位的索引
function M.FindMyCanBiggestBet()
    M.GetBetLimit()
    local index1
    local index2
    local my_all_bet = 0
    for i=1,#m_data.all_info.bet_data.my_bet_data do
       my_all_bet = my_all_bet + tonumber(m_data.all_info.bet_data.my_bet_data[i])
    end
    for i=4,1,-1 do
        local cur_bet = M.MathGetBet(i)
        dump(MainModel.UserInfo.jing_bi)
        dump(my_all_bet)
        dump(m_data.my_total_bet_limit/100)
        dump(m_data.my_total_bet_limit/100 * (MainModel.UserInfo.jing_bi + my_all_bet))
        if (my_all_bet + cur_bet) <= (m_data.my_total_bet_limit/100 * (MainModel.UserInfo.jing_bi + my_all_bet)) then
            index1 = i
            break
        end
    end
    local tab = M.GetCurYZConfig()
    for i=#tab,1,-1 do
        if MainModel.UserInfo.jing_bi >= tab[i] then
            index2 = i
            break
        end
    end
    dump({index1 = index1,index2 = index2},"<color=yellow>++++++++++++++++++</color>")
    if index1 and index2 then
        return math.min(index1,index2)
    else
        return 1
    end
end

--金币不足场次下限的提示
function M.CreateHint()
    local PayPanelPrefab = GameObject.Find("Canvas/LayerLv5/PayPanel")
    local Sys_011_YueKa_NewNoticePanelPrefab = GameObject.Find("Canvas/LayerLv5/Sys_011_YueKa_NewNoticePanel")
    if not IsEquals(PayPanelPrefab) and not IsEquals(Sys_011_YueKa_NewNoticePanelPrefab)  then
        Event.Brocast("show_gift_panel")
    end
end

function M.SetHintMark(b)
    m_data.hint_pre = b
end

local bet = {
    game_id = 1,
    bet_data = {
         is_auto_bet      = 0,
         lucky_star_bet_pos = {0,0,0,0},
         my_bet_data = {0,0,0,0},
         total_bet_data = {111300,113100,121200,114200},
     },
    dragon_info = {
         jing_bi     = -1,
         player_info = {
             head_image  = "http://jydown.jyhd919.cn/head_images3/other/lwzb_icon_lwtx.png",
             player_id   = "sys_dragon",
             player_name = "系统龙王",
         },
         remain_num = 999,
     },
    dragon_list = {
         [1] = {
             jing_bi    = -1,
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/other/lwzb_icon_lwtx.png",
                 player_id   = "sys_dragon",
                 player_name = "系统龙王",
             },
            remain_num  = 999,
         },
     },
    fuhao_rank = {
         [1] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/boy/new_boy_head012.jpg",
                 player_id   = "robot_tg7_0_4486",
                 player_name = "夜**歌",
                 vip_level   = 2,
             },
         },
         [2] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/girl/new_girl_head011.jpg",
                 player_id   = "robot_tg7_1_435",
                 player_name = "忘**伤",
                 vip_level   = 2,
             },
         },
         [3] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/girl/new_girl_head014.jpg",
                 player_id   = "robot_tg7_1_3413",
                 player_name = "雪**光",
                 vip_level   = 1,
             },
         },
         [4] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/boy/new_boy_head012.jpg",
                 player_id   = "robot_tg7_0_2386",
                 player_name = "羡**己",
                 vip_level   = 1,
             },
         },
         [5] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/boy/new_boy_head021.jpg",
                 player_id   = "robot_tg7_0_4520",
                 player_name = "只**默",
                 vip_level   = 1,
             },
         },
     },
    game_data = {
         monster_pai = {
         },
     },
    history_data = {
         [1] = {
             win_lost_data = {0,0,0,1},
         },
         [2] = {
             win_lost_data = {0,0,0,0},
         },
         [3] = {
             win_lost_data = {0,1,1,1},
         },
         [4] = {
             win_lost_data = {0,1,1,1},
         },
         [5] = {
             win_lost_data = {0,1,1,1},
         },
         [6] = {
             win_lost_data = {0,1,1,1},
         },
     },
    last_qlcf_big_award = {
         award_value = "500",
         player_info = {
             head_image  = "http://jydown.jyhd919.cn/head_images3/jy/girl/new_girl_head025.jpg",
             player_id   = "robot_tg7_1_4299",
             player_name = "流**暖",
             vip_level   = 1,
         },
         type       = 1,
     },
    lucky_star = {
         player_info = {
             head_image  = "http://jydown.jyhd919.cn/head_images3/jy/boy/new_boy_head020.jpg",
             player_id   = "robot_tg7_0_5869",
             player_name = "娅**神",
             vip_level   = 2,
         },
     },
    result              = 0,
    settle_data = {
         award_value = {"0","0","0","0"},
         dragon_award = "0",
         is_qlcf      = 0,
     },
    status_data = {
         player_num      = 83,
         qlcf_award_pool = 0,
         status         = "bet",
         time_out       = 20,
    },
}

local game = {
    bet_data = {
         is_auto_bet        = 0,
         lucky_star_bet_pos = {0,0,0,0},
         my_bet_data = {0,0,100,0},
         total_bet_data = {234400,313600,113300,335400},
     },
     game_data = {
         long_wang_pai = {
             is_win   = 0,
             pai_data = {13,26,39,34,28},
             pai_rate = 7,
             pai_type = 8,
             rate     = 0,
         },
         monster_pai = {
             [1] = {
                 is_win   = 0,
                 pai_data = {41,18,11,1,7},
                 pai_rate = 1,
                 pai_type = 2,
                 rate     = -7,
             },
             [2] = {
                 is_win   = 0,
                 pai_data = {51,8,20,45},
                 pai_rate = 1,
                 pai_type = 1,
                 rate     = -7,
             },
             [3] = {
                 is_win   = 1,
                 pai_data = {52,52,52,52,45},
                 pai_rate = 12,
                 pai_type = 12,
                 rate     = 10,
             },
             [4] = {
                 is_win   = 0,
                 pai_data = {32,15,17,47,48},
                 pai_rate = 1,
                 pai_type = 1,
                 rate     = -7,
             },
         },
     },
     settle_data = {
         award_value = {"0","0","0","0"},
         dragon_award = "0",
         is_qlcf      = 0,
     },
     status_data = {
         player_num      = 85,
         qlcf_award_pool = 0,
         status          = "game",
         time_out        = 12,
     },
}


local settle = {
    bet_data = {
         is_auto_bet        = 0,
         lucky_star_bet_pos = {0,0,0,0},
         my_bet_data = {0,0,100,0},
         total_bet_data = {232400,225800,28200,314300},
     },
     dragon_info = {
         jing_bi     = -1,
         player_info = {
             head_image  = "http://jydown.jyhd919.cn/head_images3/other/lwzb_icon_lwtx.png",
             player_id   = "sys_dragon",
             player_name = "系统龙王",
         },
         remain_num  = 999,
     },
     fuhao_rank = {
         [1] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/boy/new_boy_head012.jpg",
                 player_id   = "robot_tg7_0_4486",
                 player_name = "夜**歌",
                 vip_level   = 2,
             },
         },
         [2] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/girl/new_girl_head011.jpg",
                 player_id   = "robot_tg7_1_435",
                 player_name = "忘**伤",
                 vip_level   = 2,
             },
         },
         [3] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/girl/new_girl_head014.jpg",
                 player_id   = "robot_tg7_1_3413",
                 player_name = "雪**光",
                 vip_level   = 1,
             },
         },
         [4] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/boy/new_boy_head012.jpg",
                 player_id   = "robot_tg7_0_2386",
                 player_name = "羡**己",
                 vip_level   = 1,
             },
         },
         [5] = {
             player_info = {
                 head_image  = "http://jydown.jyhd919.cn/head_images3/jy/boy/new_boy_head021.jpg",
                 player_id   = "robot_tg7_0_4520",
                 player_name = "只**默",
                 vip_level   = 1,
             },
         },
     },
     game_data = {
         long_wang_pai = {
            is_win   = 0,
             pai_data = {13,26,39,34,28},
             pai_rate = 7,
             pai_type = 8,
             rate     = 0,
         },
         monster_pai = {
             [1] = {
                 is_win   = 0,
                 pai_data = {41,18,11,1,7},
                 pai_rate = 1,
                 pai_type = 2,
                 rate     = -7,
             },
             [2] = {
                 is_win   = 0,
                 pai_data = {51,8,20,45},
                 pai_rate = 1,
                 pai_type = 1,
                 rate     = -7,
             },
             [3] = {
                 is_win   = 1,
                 pai_data = {52,52,52,52,45},
                 pai_rate = 12,
                 pai_type = 12,
                 rate     = 10,
             },
             [4] = {
                 is_win   = 0,
                 pai_data = {32,15,17,47,48},
                 pai_rate = 1,
                 pai_type = 1,
                 rate     = -7,
             },
         },
     },
     lucky_star = {
         player_info = {
             head_image  = "http://jydown.jyhd919.cn/head_images3/jy/boy/new_boy_head020.jpg",
             player_id   = "robot_tg7_0_5869",
             player_name = "娅**神",
             vip_level   = 2,
         },
     },
     settle_data = {
         award_value = {"0","0","1000","0"},
         dragon_award = "-1000",
         is_qlcf      = 0,
     },
     status_data = {
         player_num      = 90,
         qlcf_award_pool = 0,
         status          = "settle",
         time_out        = 5,
     },
}

function M.GetGuideData(status)
    if status == "bet" then
        Event.Brocast("lwzb_all_info_response","lwzb_all_info_response",bet)
    elseif status == "game" then
        Event.Brocast("lwzb_game_status_change","lwzb_game_status_change",game)
    elseif status == "settle" then
        Event.Brocast("lwzb_game_status_change","lwzb_game_status_change",settle)
    end
end

function M.GamingAnimTimer(b1,b2)
    dump(b,"<color=blue><size=13>+++5555555555555555555555555+++++</size></color>")
    M.StopGamingAnimTimer()
    M.SetRandomMap(b1)
    if b1 then
        Event.Brocast("lwzb_in_gaming_anim_init_msg")
        M.UpdateGamingAnimState(b2)
        m_data.gaming_anim_timer = Timer.New(function ()
            m_data.gaming_anim_time = m_data.gaming_anim_time + 1
            M.UpdateGamingAnimState(false)
        end,1,-1)
        m_data.gaming_anim_timer:Start()
    else
        Event.Brocast("lwzb_out_gaming_anim_init_msg")
    end
end

function M.StopGamingAnimTimer()
    if m_data.gaming_anim_timer then
        m_data.gaming_anim_timer:Stop()
        m_data.gaming_anim_timer = nil
    end
end

function M.GetGamingAnimTime()
    return m_data.gaming_anim_time
end

--Stage第几轮,
--Status蓄力还是战斗,(蓄力"StoreUpTheStrength",战斗"Fight")
--Order具体进行到龙王或第几个神兽(龙王0,神兽1、2、3、4)
function M.SetStageStatusOrder(Stage,Status,Order)
    m_data.gaming_state = {Stage = Stage , Status = Status , Order = Order}
end

function M.GetStageStatusOrder()
    return m_data.gaming_state
end

function M.SetRandomMap(b)
    if b then
        m_data.randomMap = m_data.randomMap or {}
    else
        m_data.randomMap = {}
    end
    if table_is_null(m_data.randomMap) then
        for i=1,3 do
            for j=1,8 do
                math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 7)) + i * j)
                local r = math.random(0,100)
                m_data.randomMap[i] = m_data.randomMap[i] or {}
                m_data.randomMap[i][j] = r
            end
        end
    end
end

function M.GetRandomInMap(Stage,index)
    return m_data.randomMap[Stage][index]
end

function M.UpdateGamingAnimState(b)
    if not m_data.on_background then
        local gaming_time = M.GetGamingAnimTime()
        for i=1,#lwzb_stage_config do
            if gaming_time >= lwzb_stage_config[i].timing_min and ((lwzb_stage_config[i].timing_max and gaming_time < lwzb_stage_config[i].timing_max) or not lwzb_stage_config[i].timing_max) then
                M.SetStageStatusOrder(lwzb_stage_config[i].stage,lwzb_stage_config[i].status,lwzb_stage_config[i].order)
                if gaming_time == lwzb_stage_config[i].timing_min then
                    if not b then
                        Event.Brocast("lwzb_gaming_anim_msg")
                    end
                end
            end
        end
    end
    if b then
        Event.Brocast("lwzb_gaming_refresh_msg")
    end
end