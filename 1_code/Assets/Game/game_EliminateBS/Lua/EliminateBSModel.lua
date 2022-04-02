local basefunc = require "Game.Common.basefunc"
EliminateBSModel = {}
local M = EliminateBSModel
M.xiaoxiaole_bs_defen_cfg = HotUpdateConfig("Game.game_EliminateBS.Lua.xiaoxiaole_bs_defen_cfg")
M.kaijiang_maps = "1111111122222222333333334445544444455444333333332222222211111111"
M.size = {
    max_x = 8,
    max_y = 8,
    size_x = 126,
    size_y = 108,
    spac_x = 0,
    spac_y = 1
}

M.slider_value = 0

M.time = {
    xc_pt = 1,
    xc_xyz = 0.75,--消除同屏中的下一组的间隔
    xc_xyp = 0.3,--消除下一屏的间隔
    xc_zdkj = 3,--消除自动开奖
    xc_zdkj_jg = 2,--自动开奖时间
    xc_bj_ys = 0.2,--消除鲸币普通暴击延时
    xc_bj_fd = 0.4,--消除暴击出现放大
    xc_bj_jg = 0.2,--消除暴击放大到缩小延时间隔
    xc_bj_sx = 0.1,--消除暴击出现缩小
    xc_jb_pt_bjb_ys = 0.2,--消除鲸币普通爆鲸币特效延时（爆鲸币的特效）
    xc_jb_bj_sz_fei_jg = 0.2,--消除鲸币暴击数字飞出延时
    xc_jb_pt_sz_fei_jg = 0.3,--消除鲸币普通数字飞出延时
    xc_jb_pt_sz_fd_jg = 0.02,--消除鲸币普通数字放大时间
    xc_jb_pt_sz_yd_sj = 0.3,--消除鲸币普通数字上移时间
    show_clear1 = 1,--展示结算1的延时
    show_clear2 = 1,--展示结算1的延时
    show_clear3 = 1,--展示结算1的延时
    show_clear4 = 1.5,--展示结算1的延时
    ys_yd = 0.2,--元素移动时间
    ys_jxlh = 0.5,--消除后的剩余旧元素下落后的时间间隔
    ys_xxlh = 0.5,--消除后的新元素下落后的时间间隔
    ys_xxldd = 0.2,--新元素下落抖动时间
    ys_jsgdjg = 0.2,--加速滚动间隔
    ys_jsgdsj = 0.2,--加速滚动时间
    ys_ysgdsj = 3,--匀速滚动时间
    ys_ysgdjg = 0.02,--每一次匀速滚动到下一个位置时间
    ys_j_sgdjg = 0.2,--减速滚动间隔
    ys_j_sgdsj = 0.6,--减速滚动时间
    ys_ysgdsj_add = 2,--匀速滚动每次增加的时间
}

M.Model_Status = {
    gaming = "gaming",
    gameover = "gameover"
}

M.is_ew_bet = false

M.status_lottery = {
    wait = "wait",
    --等待开奖
    run = "run",
    --开奖中
    run_prog = "run_prog"
    --进度条开奖
}

M.xc_state = {
    null = "nil",
    nor = "nor",    --普通消除
    bshj = "bshj",  --宝石幻境
}

M.eliminate_enum = {
    null = 0,
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    ts = 6,
    bgj = 7,
    swk = 8,
    zc1 = 100,
    zc2 = 101,
    zc3 = 102,
    
    ts1 = 200,
    ts1_1 = 201,
    ts1_2 = 202,
    ts1_3 = 203,
    ts1_4 = 204,
    ts1_5 = 205,
    ts2 = 210,
    ts2_1 = 211,
    ts2_2 = 212,
    ts2_3 = 213,
    ts2_4 = 214,
    ts2_5 = 215,
    ts3 = 220,
    ts3_1 = 221,
    ts3_2 = 222,
    ts3_3 = 223,
    ts3_4 = 224,
    ts3_5 = 225,

    jd1 = 9,
    jd2 = 10,
    jd3 = 11,
    jd4 = 12,
}

M.baoshi_enum = {
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
}


M.yxcard_type = "prop_xxl_bsmz_card"

local lister
local function MakeLister()
    lister = {}
    lister["xxl_baoshi_all_info_response"] = M.xxl_baoshi_all_info_response
    lister["xxl_baoshi_enter_game_response"] = M.xxl_baoshi_enter_game_response
    lister["xxl_baoshi_quit_game_response"] = M.xxl_baoshi_quit_game_response
    lister["xxl_baoshi_main_kaijiang_response"] = M.xxl_baoshi_main_kaijiang_response
    lister["xxl_baoshi_little_kaijiang_response"] = M.xxl_baoshi_little_kaijiang_response
    lister["xxl_baoshi_little_next_response"] = M.xxl_baoshi_little_next_response
    lister["xxl_baoshi_little_big_box_sel_response"] = M.xxl_baoshi_little_big_box_sel_response
end

local function MsgDispatch(proto_name, data)
    local func = lister[proto_name]
    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if M.data.limitDealMsg and not M.data.limitDealMsg[proto_name] then
        return
    end
    func(proto_name, data)
end

function M.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end

function M.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
end

function M.Update()
end

local function InitConfig(cfg)
end

local function InitModelData(game_id)
    M.data = {
        auto = M.data and M.data.auto or false,
        speed = M.data and M.data.speed or 1,
        skip = M.data and M.data.skip or false,
        bet = M.data and M.data.bet or {0, 0, 0, 0, 0},
        status_lottery = M.status_lottery.wait,
        all_money = 0,
        all_rate = 0,
        main_real_rate = 0,
    }
    
    M.bshj_data = {
        bshj_real_rate = 0,
        bshj_game_index = 0,
    }
end

function M.Init()
    InitConfig(M.xiaoxiaole_bs_defen_cfg)
    InitModelData()
    MakeLister()
    M.AddMsgListener()
    return M
end

function M.Exit()
    M.RemoveMsgListener()
    lister = nil
    M.data = nil
    M = nil
end

--***********************all
function M.xxl_baoshi_all_info_response(p_n, data)
    dump(data, "<color=yellow>xxl_baoshi_all_info_response</color>")
    if data.result == -1 then
        --模块加载失败服务器
        Event.Brocast("model_xxl_baoshi_all_info_error")
        return
    elseif data.result ~= 0 then
        HintPanel.ErrorMsg(
            data.result,
            function()
                Event.Brocast("model_xxl_baoshi_all_info_error")
            end
        )
        return
    end
    --恢复数据
    InitModelData()
    M.data.model_status = M.Model_Status.gaming
    if not data.main_xc_data then
        data.main_xc_data = data.main_xc_data or {}
        data.main_xc_data.xc_data = M.kaijiang_maps
        data.main_xc_data.little_prog = 0
        data.little_status = data.little_status or {}
        data.little_status.award = 0
        data.main_status = data.main_status or {}
        data.main_status.award = 0
        data.little_status.extend_bet = false
        M.data.is_new = true
    else
        M.data.is_new = false
    end
    M.data.eliminate_data = eliminate_bs_algorithm.compute_eliminate_result(M.ToDealWithData(data))
    
    --结果打印
    dump(M.data.eliminate_data, "<color=red>eliminate_data</color>")
    if M.data.eliminate_data.result then
        for k, v in pairs(M.data.eliminate_data.result) do
            dump(v, "<color=red>result:</color>" .. k)
        end
    end
    M.data.cur_money = M.data.eliminate_data.cur_money
    M.data.all_money = M.data.eliminate_data.all_money
    M.data.all_rate = M.data.eliminate_data.all_rate
    
    M.SetBet(data.main_status.bets)
    M.SetSkip(false)
    M.SetSpeed(1)
    M.SetAuto(false)
    M.SetDataLotteryEnd()
    M.is_all_info = true
    dump(M.data, "<color=yellow>数据</color>")
    Event.Brocast("model_xxl_baoshi_all_info")
    --触发宝石幻境
    if data.main_xc_data.little_prog >= 100 then
        if EliminateBSModel.data.state ~= EliminateBSModel.xc_state.bshj then
            EliminateBSHJGamePanel.Create()
        end
    end
end

--********************response
--进入游戏
function M.xxl_baoshi_enter_game_response(_, data)
    dump(data, "<color=yellow>xxl_baoshi_enter_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_baoshi_enter_game_response", data)
end

--退出游戏
function M.xxl_baoshi_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>xxl_baoshi_quit_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_baoshi_quit_game_response", data)
    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end

--开奖
function M.xxl_baoshi_main_kaijiang_response(proto_name, data)
    dump(data, "<color=yellow>xxl_baoshi_main_kaijiang_response</color>")
    if data.result == 0 then
        EliminateBSModel.data.state = EliminateBSModel.xc_state.nor
        M.SetDataLotteryStart()
        if false then
            M.data.eliminate_data = eliminate_bs_algorithm.compute_eliminate_result(EliminateBSLogic.GetTestData("nor"))
        else
            M.data.eliminate_data = eliminate_bs_algorithm.compute_eliminate_result(M.ToDealWithData(data))
        end
        --结果打印
        dump(M.data.eliminate_data, "<color=red>基础eliminate_data</color>")
        if M.data.eliminate_data.result then
            for k, cur_result in pairs(M.data.eliminate_data.result) do
                dump(cur_result, "<color=red>基础result：</color>" .. k)
            end
        end
        if M.data.eliminate_data.cur_money then
            M.data.cur_money = M.data.eliminate_data.cur_money
        end
        if M.data.eliminate_data.all_money then
            M.data.all_money = M.data.eliminate_data.all_money
        end
        if M.data.eliminate_data.all_rate then
            M.data.all_rate = M.data.eliminate_data.all_rate
        end

        M.data.is_new = nil
        Event.Brocast("model_lottery_success")
    else
        if data.result == 2253 then
            --如果是[需要的数量有异常]就弹出充值面板
            Event.Brocast("model_lottery_error_amount")
        else
            HintPanel.ErrorMsg(data.result)
        end
        EliminateBSGamePanel.ExitTimer()
        M.SetAuto(false)
        M.SetDataLotteryEnd()
        Event.Brocast("model_lottery_error")
    end
end

--TODO:宝石幻境对数据的处理
local function HandleDataBSHJ(_little_status, _little_xc_data)
    if _little_status then
        if M.data.eliminate_data then
            M.data.eliminate_data.all_money = M.data.eliminate_data.cur_money + _little_status.award
            M.data.all_money = M.data.eliminate_data.all_money
        end
        M.bshj_data.bshj_game_index = _little_status.game_index
        M.bshj_data.big_sel_list = _little_status.big_sel_list
        M.bshj_data.bshj_real_rate = _little_status.real_rate / 100
    end
end

--宝石幻境开奖 --弃用
-- function M.xxl_baoshi_little_kaijiang_response(proto_name, data)
--     dump(data, "<color=yellow>xxl_baoshi_main_kaijiang_response</color>")
--     if data.result == 0 then
--         M.bshj_data.little_status = data.little_status
--         M.bshj_data.little_xc_data = data.little_xc_data
--         HandleDataBSHJ(M.bshj_data.little_status, M.bshj_data.little_xc_data)
--         --Event.Brocast("model_bshj_lottery_success")
--         EliminateBSHJGamePanel.Create()
--     else
--         HintPanel.ErrorMsg(data.result)
--     end
-- end

--宝石幻境单轮开奖
function M.xxl_baoshi_little_next_response(proto_name, data)
    dump(data, "<color=red>+++++xxl_baoshi_little_next_response+++++</color>")
    if data.result == 0 then
        M.bshj_data.little_status = data.little_status
        HandleDataBSHJ(M.bshj_data.little_status)
        Event.Brocast("model_bshj_next_lottery_success")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--宝石幻境大宝箱点亮返回
function M.xxl_baoshi_little_big_box_sel_response(proto_name, data)
    dump(data, "<color=red>+++++xxl_baoshi_little_big_box_sel_response+++++</color>")
    if data.result == 0 then
        M.bshj_data.little_status = data.little_status
        HandleDataBSHJ(M.bshj_data.little_status)
        Event.Brocast("model_bshj_big_box_sel_success", data)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--*******************************方法
function M.SetDataLotteryEnd()
    M.data.status_lottery = M.status_lottery.wait
    M.SetSkip(false)
end

function M.SetDataLotteryStart()
    M.data.status_lottery = M.status_lottery.run
end

function M.SetDataLotteryStartProg()
    M.data.status_lottery = M.status_lottery.run_prog
end

function M.SetAuto(v)
    if not v and type(v) ~= "boolean" then
        return
    end
    M.data = M.data or {}
    M.data.auto = v
    if v then
        M.SetSpeed(2)
    else
        M.SetSpeed(1)
    end
end

function M.GetAuto()
    if M.data and M.data.auto then
        return M.data.auto
    end
end

function M.SetSpeed(v)
    if not v and type(v) ~= "number" then
        return
    end
    M.data = M.data or {}
    M.data.speed = v
end

function M.GetSpeed()
    if M.data and M.data.speed then
        return M.data.speed
    end
    return 1
end

function M.SetSkip(v)
    if not v and type(v) ~= "boolean" then
        return
    end
    M.data = M.data or {}
    M.data.skip = v
end

function M.GetSkip()
    if M.data and M.data.skip then
        return M.data.skip
    end
end

function M.SetBet(v)
    if not v and type(v) ~= "tabel" then
        return
    end
    M.data = M.data or {}
    M.data.bet = v
end

function M.GetBet()
    if not M then
        return
    end
    if M.data and M.data.bet then
        return M.data.bet
    end
end

function M.GetTime(t,speed)
    t = t or 1
    if speed then
        return t / speed / 2
    end
    if M and M.data and M.data.speed then
        M.data.speed = M.data.speed or 1
        return t / M.data.speed / 2
    else
        return 0.02
    end
end

function M.GetAwardMoney()
    if EliminateBSModel.data.state == EliminateBSModel.xc_state.bshj then
        return M.data.all_money or 0
    else
        return M.data.cur_money or 0
    end
end

function M.GetAwardRate()
    return M.data.all_rate
end

--所有消除结果数据
function M.GetAllResultData()
    local result_data = {}
    result_data.all_del_list = eliminate_bs_algorithm.get_all_del_list(M.data.eliminate_data.result)
    result_data.all_del_rate_list = eliminate_bs_algorithm.get_all_del_rate_list(M.data.eliminate_data.result)
    result_data.cur_money = M.data.cur_money
    result_data.all_money = M.data.all_money
    result_data.all_rate = M.data.all_rate
    if EliminateBSModel.data.eliminate_data.is_free_game then
        result_data.real_rate = M.bshj_data.bshj_real_rate
    else
        result_data.real_rate = M.data.main_real_rate
    end
    dump(result_data.real_rate, "<color=white>结算倍率</color>")
    return result_data
end

function M.GetAllResultLevel()
    local data = M.GetAllResultData()
    if not data then
        return 1
    end
    local x = data.real_rate
    if M.xiaoxiaole_bs_defen_cfg.dangci[5].min <= x and x <= M.xiaoxiaole_bs_defen_cfg.dangci[5].max then
        return 5
    elseif M.xiaoxiaole_bs_defen_cfg.dangci[4].min <= x and x <= M.xiaoxiaole_bs_defen_cfg.dangci[4].max then
        return 4
    elseif M.xiaoxiaole_bs_defen_cfg.dangci[3].min <= x and x <= M.xiaoxiaole_bs_defen_cfg.dangci[3].max then
        return 3
    elseif M.xiaoxiaole_bs_defen_cfg.dangci[2].min <= x and x <= M.xiaoxiaole_bs_defen_cfg.dangci[2].max then
        return 2
    elseif M.xiaoxiaole_bs_defen_cfg.dangci[1].min <= x and x <= M.xiaoxiaole_bs_defen_cfg.dangci[1].max then
        return 1
    else
        return 1
    end
end

--传入一个倍率，计算获得了多少奖励 注意：当前的游戏模式，没有单独对某一个元素进行押注，所以所有元素的押注都是一样的
function M.GetAwardGold(cur_rate)
    if not M or not cur_rate then
        return 0
    end
    local bet = M.GetBet()
    if not table_is_null(bet) and bet[1] then
        return cur_rate * bet[1]
    end
    return 0
end

--传入一个倍率，计算获得了多少奖励 注意：当前的游戏模式，没有单独对某一个元素进行押注，所以所有元素的押注都是一样的
function M.GetAwardGold_2(cur_special_rate)
    if not M or not cur_special_rate then
        return {0,}
    end
    local bet = M.GetBet()
    if not table_is_null(bet) and bet[1] then
        for i=1,#cur_special_rate do
            cur_special_rate[i] = cur_special_rate[i] * bet[1]
        end
        return cur_special_rate
    else
        return {0,}
    end
end

function M.GetBetLevel()
    return Bet_Level
end

function M.DataDamage()
    if not M or not M.data or table_is_null(M.data) then
        HintPanel.Create(
            1,
            "数据异常",
            function()
                Event.Brocast("model_xxl_baoshi_all_info_error")
            end
        )
        return true
    end
end

function M.GetTaskData()
    if not M or not M.data or not M.task_data then return end
    return M.task_data
end

function M.GetTaskAward()
    if not M or not M.data or not M.data.task_award then return end
    return M.data.task_award
end

function M.InitTaskAward()
    if not M or not M.data then return end
    M.data.task_award = nil
end

--处理数据
function M.ToDealWithData(data)
    local tab = {}
    dump(data,"<color=yellow><size=15>++++++++++ToDealWithData++++++++++</size></color>")
    tab.result = data.result
    tab.all_rate = data.main_xc_data.all_rate
    tab.xc_data = data.main_xc_data.xc_data
    if data.little_status.award then
        tab.all_award = data.main_status.award + data.little_status.award
    else
        tab.all_award = data.main_status.award
    end

    tab.cur_award = data.main_status.award
    if not data.main_xc_data.little_prog then
        data.main_xc_data.little_prog = 0
    end

    tab.little_prog = data.main_xc_data.little_prog
    tab.is_free_game = data.main_xc_data.little_prog >= 100

    tab.is_ew_bet = EliminateBSModel.is_ew_bet
    if not table_is_null(data.little_status) then
        tab.is_ew_bet = tonumber(data.little_status.extend_bet) == 1
    end

    M.bshj_data.little_status = data.little_status
    M.bshj_data.little_xc_data = data.little_xc_data

    if data.main_status.real_rate then
        M.data.main_real_rate = data.main_status.real_rate / 100 or 0
    end

    if data.little_status.real_rate then
        M.bshj_data.bshj_real_rate = data.little_status.real_rate / 100
    end

    if data.main_xc_data.little_prog >= 100 then
        M.bshj_data.bshj_map_data = eliminate_bs_algorithm.get_bshj_map_data(data.little_xc_data.xc_data)
        M.bshj_data.bshj_lottery_data = eliminate_bs_algorithm.get_bshj_lottery_data(data.little_xc_data.xc_data)
        M.bshj_data.bshj_game_index = data.little_status.game_index
        M.bshj_data.big_sel_list = data.little_status.big_sel_list
    end
    --[[tab.free_game_rate = data.base_data.free_game_rate
    tab.state = data.status_data.status
    tab.cur_award = data.status_data.cur_award
    tab.all_award = data.status_data.all_award
    tab.time_out = data.status_data.time_out--]]
    return tab
end
