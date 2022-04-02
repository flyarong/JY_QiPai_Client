local basefunc = require "Game.Common.basefunc"
EliminateSGModel = {}
local M = EliminateSGModel
M.xiaoxiaole_sg_defen_cfg = HotUpdateConfig("Game.game_EliminateSG.Lua.xiaoxiaole_sg_defen_cfg")
M.kaijiang_maps = "1111111122222222333333334446644455566555333333332222222211111111"
M.size = {
    max_x = 5,
    max_y = 4,
    size_x = 105,
    size_y = 105,
    spac_x = 2,
    spac_y = 2
}

M.GamePanelButtomTaskIds = {
    100019,--船
    100020,--箭
}

M.time = {
    xc_xyz = 0.25,--消除同屏中的下一组的间隔
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

    xc_pt = 1.5,--消除普通特效时间
    xc_hf_sg = 6,--虎符闪光时间
    
    swk_xc_qy = 4,--孙悟空消除前摇
    swk_xc_hy = 1,--孙悟空消除后摇
    swk_skill_use_wait = 0.5,--孙悟空技能使用等待
    swk_skill_use = 8,--孙悟空技能使用摇奖
    swk_skill_use0 = 4,--孙悟空技能使用
    swk_skill_use1 = 4,--孙悟空技能1使用
    swk_skill_use2 = 4,--孙悟空技能2使用
    swk_skill_use3 = 12,--孙悟空技能3使用
    swk_jb_sg = 0,--孙悟空加倍闪光
    swk_jb_sg_yd = 0.5,--孙悟空加倍闪光拖尾移动时间
    swk_hyjj = 4,--孙悟空火眼金睛
    swk_jc_bg = 1,--孙悟空奖池白光
    swk_jc_dj = 1,--孙悟空奖池打击
    swk_jc_djzd = 2,--孙悟空打击震动
    swk_jc_djzdt = 2,--孙悟空打击震动
    swk_yj_hide = 6,--孙悟空摇奖隐藏
    swk_yjsx = 1,--孙悟空摇奖缩小
    swk_skill3_change_up_t = 0.1 * 2, --加速时间
	swk_skill3_change_uni_t = 0.02 * 2, --每一次滚动时间
	swk_skill3_change_down_t = 0.1 * 2, --减速时间
	swk_skill3_change_uni_d = 0.5 * 2, --匀速滚动时长
	swk_skill3_change_up_d = 0.1 * 2, --滚动加速间隔
	swk_skill3_change_down_d = 0.1 * 2, --滚动加速间隔

    bgj_sl_dd = 0.1,--白骨精洒落等待
    bgj_sl_yj_yc = 4,--白骨精洒落摇奖隐藏
    bgj_sl = 4,--白骨精洒落总时间
    bgj_sl_tw_jg = 0.14,--白骨精洒落拖尾间隔
    bgj_sl_tw_dd = 0.1,--白骨精洒落拖尾等待
    bgj_sl_tw_yd = 1,--白骨精洒落拖尾移动
    bgj_sl_tw_zs = 1,--白骨精洒落拖尾展示
    bgj_sl_gb = 0.4,--白骨精洒落改变
    bgj_bs = 1,--白骨精变身烟雾到改变图片的时间

    bgj_jc_mini_yd = 0.6,--白骨精小奖池移动
    bgj_jc_fd = 0.4,--白骨精小奖池放大
    bgj_jc_fdzd = 1,--白骨精小奖池放大震动
    bgj_jc_cx = 0.02,--白骨精小奖池放大闪光
    bgj_xc = 1.5,--白骨精消除
    bgj_xc_fx = 1.5,--白骨精消除飞行
    bgj_xc_zd = 0.4,--白骨精消除震动
    bgj_mfyxjr = 7,--白骨精进入免费游戏

    xc_bgj_jg = 1.2,--消除白骨精的间隔
    nor_bgj_jg = 0.15,--不消除白骨精飞行特效间隔

    ts_cxtsk = 1.5,--唐僧摇奖出现提示框
    ts_jrmfyx_wait = 0.04,--唐僧进入免费游戏需要时间
    ts_jrmfyx = 12,--唐僧进入免费游戏需要时间
    ts_mfyxbk = 6,--唐僧免费游戏边框显示
    ts_mfyxkj = 0.3,--唐僧免费游戏开奖
    ts_mfyx_zd = 1,--唐僧免费游戏震动
    ts_mfyx_zj = 1,--唐僧免费游戏次数增加
    ts_mfyx_wait = 0.1,--唐僧免费游戏触发总时长
    ts_mfyx_time = 3,--唐僧免费游戏触发总时长
    ts_mfyx_js = 1,--唐僧免费游戏次数减少
    ts_symfyx = 1,--使用免费游戏
    ts_xc_qy = 1.5,--唐僧消除前摇
    ts_xc_hy = 1,--唐僧消除后摇
    ts_jc_bao = 1,--唐僧奖池爆炸

    free_downcount = 8,--免费游戏倒计时

    big_game_yj_wait = 0.4,--开始摇奖等待
    big_game_yj_time = 15,--开始摇奖时间
    big_game_yj_show = 0.5,--摇奖显示时间
    big_game_jl = 0.4,--BG奖励
    big_game_time = 25,--BigGame时间

    task_add = 0.1,--任务进度增加
    task_sett_wait = 0.02,--任务结算前等待时间
    task_sett_time = 0,5,--任务结算时间
    task_sett_time_award = 8,--任务结算获得奖励时间
    task_sett_bgj_xt = 1.5,--任务结算白骨精血条变化时间
    task_sett_bgj_bs = 2,--任务结算白骨精烟雾出现时间
    task_sett_bgj_get_award = 0.5,--任务结算领取奖励
    task_sett_bgj_hby = 1,--任务结算白骨精红包雨出现时间
    task_sett_bgj_hby_hide = 13,--任务结算白骨精红包雨消失时间
    task_sett_swkgj = 2,--任务结算孙悟空攻击
}

M.Model_Status = {
    gaming = "gaming",
    gameover = "gameover"
}

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
    nor = "nor", --普通消除
    select = "select",--二选一
    hscb_1 = "hscb_1", --火烧赤壁点火
    hscb_2 = "hscb_2",  --火烧赤壁
    ccjj_2 = "ccjj_2",  --草船借箭
    ccjj_cs = "ccjj_cs", --草船借箭初始
}

M.xyxxl_state_key = "xyxxl_state_key" --财神消消乐当前状态

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

    jd1 = 9,
    jd2 = 10,
    jd3 = 11,
    jd4 = 12,
}

M.task_id = 85

M.yxcard_type = "prop_xxl_sanguo_card"

local lister
local function MakeLister()
    lister = {}
    lister["xxl_sanguo_all_info_response"] = M.xxl_sanguo_all_info_response
    lister["xxl_sanguo_enter_game_response"] = M.xxl_sanguo_enter_game_response
    lister["xxl_sanguo_quit_game_response"] = M.xxl_sanguo_quit_game_response
    lister["xxl_sanguo_base_kaijiang_response"] = M.xxl_sanguo_base_kaijiang_response
    lister["xxl_sanguo_hscb_kaijiang_msg"] = M.xxl_sanguo_hscb_kaijiang_msg
    lister["xxl_sanguo_ccjj_kaijiang_msg"] = M.xxl_sanguo_ccjj_kaijiang_msg  
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
    }
end

function M.Init()
    InitConfig(M.xiaoxiaole_sg_defen_cfg)
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
function M.xxl_sanguo_all_info_response(p_n, data)
    dump(data, "<color=yellow>xxl_sanguo_all_info_response</color>")
    if data.result == -1 then
        --模块加载失败服务器
        Event.Brocast("model_xxl_sanguo_all_info_error")
        return
    elseif data.result ~= 0 then
        HintPanel.ErrorMsg(
            data.result,
            function()
                Event.Brocast("model_xxl_sanguo_all_info_error")
            end
        )
        return
    end
    --恢复数据
    InitModelData()
    M.data.model_status = M.Model_Status.gaming
    if not data.status_data then
        data.base_data = data.base_data or {}
        data.base_data.xc_data = M.kaijiang_maps
        --data.is_local = true
        M.data.is_new = true
        data.status_data = data.status_data or {}
        data.status_data.status = "nil"
        M.data.state = "nil"
    else
        M.data.state = data.status_data.status
        M.data.is_new = false
    end
    M.ChangeXY(M.data.state)
    M.data.eliminate_data = eliminate_sg_algorithm.compute_eliminate_result(M.ToDealWithData(M.data.state,data))
    
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

    M.SetSkip(false)
    M.SetSpeed(1)
    M.SetAuto(false)
    M.SetDataLotteryEnd()
    M.is_all_info = true
    dump(M.data, "<color=yellow>数据</color>")
    if (M.data.state == M.xc_state.hscb_2) or (M.data.state == M.xc_state.ccjj_2) then
        if M.data.all_money ~= 0 then
            for i,v in ipairs(M.data.bet) do
                M.data.bet[i] = M.data.cur_money / M.data.all_rate
            end
        end
    end
    if M.data.state == M.xc_state.select then
        if M.data.all_money ~= 0 then
            for i,v in ipairs(M.data.bet) do
                M.data.bet[i] = M.data.all_money / M.data.all_rate
            end
            Event.Brocast("model_xxl_sanguo_bet_change")
        end
    end

    Event.Brocast("model_xxl_sanguo_all_info")
    dump(M.data.state,"<color=yellow><size=15>++++++++++M.data.state++++++++++</size></color>")
    if M.data.state == M.xc_state.null then
    elseif M.data.state == M.xc_state.nor then
    elseif M.data.state == M.xc_state.select then
        EliminateSGFreeChoosePanel.Create()
    elseif (M.data.state == M.xc_state.hscb_1) or (M.data.state == M.xc_state.hscb_2) then
        EliminateSGGamePanel_hscb.Create(data)
    elseif M.data.state == M.xc_state.ccjj_2 then
        EliminateSGGamePanel_ccjj.Create(data)
    end
end

--********************response
--进入游戏
function M.xxl_sanguo_enter_game_response(_, data)
    dump(data, "<color=yellow>xxl_sanguo_enter_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_sanguo_enter_game_response", data)
end

--退出游戏
function M.xxl_sanguo_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>xxl_sanguo_quit_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_sanguo_quit_game_response", data)
    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end

--开奖base
function M.xxl_sanguo_base_kaijiang_response(proto_name, data)
    dump(data, "<color=yellow>xxl_sanguo_base_kaijiang_response</color>")
    if data.result == 0 then
        EliminateSGModel.data.state = EliminateSGModel.xc_state.nor
        M.ChangeXY(EliminateSGModel.data.state)
        M.SetDataLotteryStart()
        if false then
            M.data.eliminate_data = eliminate_sg_algorithm.compute_eliminate_result(EliminateSGLogic.GetTestData("nor"))
        else
            M.data.eliminate_data = eliminate_sg_algorithm.compute_eliminate_result(M.ToDealWithData("nor",data))
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
        if data.result == 1012 then
            --如果是[需要的数量有异常]就弹出充值面板
            Event.Brocast("model_lottery_error_amount")
        else
            HintPanel.ErrorMsg(data.result)
        end
        EliminateSGGamePanel.ExitTimer()
        M.SetAuto(false)
        M.SetDataLotteryEnd()
        Event.Brocast("model_lottery_error")
    end
end


--开奖hscb
function M.xxl_sanguo_hscb_kaijiang_msg(proto_name, data)
    dump(data, "<color=yellow>xxl_sanguo_hscb_kaijiang_msg</color>")
    if data then
        EliminateSGModel.data.state = EliminateSGModel.xc_state.hscb_2
        M.ChangeXY(EliminateSGModel.data.state)
        M.SetDataLotteryStart()
        if false then
            M.data.eliminate_data = eliminate_sg_algorithm.compute_eliminate_result(EliminateSGLogic.GetTestData("hscb_2"))
        else
            M.data.eliminate_data = eliminate_sg_algorithm.compute_eliminate_result(M.ToDealWithData("hscb_2",data))
        end
        --结果打印
        dump(M.data.eliminate_data, "<color=red>火烧赤壁eliminate_data</color>")
        if M.data.eliminate_data.result then
            for k, cur_result in pairs(M.data.eliminate_data.result) do
                dump(cur_result, "<color=red>火烧赤壁result：</color>" .. k)
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
        Event.Brocast("model_lottery_success")
    else
        --处理默认显示的数据(此时还没有服务器的数据)
        EliminateSGModel.data.state = EliminateSGModel.xc_state.hscb_1
        M.ChangeXY(EliminateSGModel.data.state)
        local data = EliminateSGLogic.GetTestData("hscb_1")
        M.data.eliminate_data = eliminate_sg_algorithm.compute_eliminate_result(data)
        Event.Brocast("model_lottery_success")
    end
end

--开奖ccjj
function M.xxl_sanguo_ccjj_kaijiang_msg(proto_name, data)
    dump(data, "<color=yellow>xxl_sanguo_ccjj_kaijiang_msg</color>")
    if data then
        EliminateSGModel.data.state = EliminateSGModel.xc_state.ccjj_2
        M.ChangeXY(EliminateSGModel.data.state)
        M.SetDataLotteryStart()
        if false then
            M.data.eliminate_data = eliminate_sg_algorithm.compute_eliminate_result(EliminateSGLogic.GetTestData("ccjj_cs"))
        else
            M.data.eliminate_data = eliminate_sg_algorithm.compute_eliminate_result(M.ToDealWithData("ccjj_2",data))
        end
        --结果打印
        dump(M.data.eliminate_data, "<color=red>草船借箭eliminate_data</color>")
        if M.data.eliminate_data.result then
            for k, cur_result in pairs(M.data.eliminate_data.result) do
                dump(cur_result, "<color=red>草船借箭result：</color>" .. k)
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
        Event.Brocast("model_lottery_success")
    else
        --处理默认显示的数据(此时还没有服务器的数据)
        EliminateSGModel.data.state = EliminateSGModel.xc_state.ccjj_cs
        M.ChangeXY(EliminateSGModel.data.state)
        local data = EliminateSGLogic.GetTestData("ccjj_cs")
        M.data.eliminate_data = eliminate_sg_algorithm.compute_eliminate_result(data)
        Event.Brocast("model_lottery_success")
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
    if EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2 then
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
    result_data.all_del_list = eliminate_sg_algorithm.get_all_del_list(M.data.eliminate_data.result)
    result_data.all_del_rate_list = eliminate_sg_algorithm.get_all_del_rate_list(M.data.eliminate_data.result)
    result_data.cur_money = M.data.cur_money
    result_data.all_money = M.data.all_money
    result_data.all_rate = M.data.all_rate
    return result_data
end

function M.GetAllResultLevel()
    local data = M.GetAllResultData()
    if not data then
        return 1
    end
    local x = data.all_rate
    if M.xiaoxiaole_sg_defen_cfg.dangci[4].min <= x and x <= M.xiaoxiaole_sg_defen_cfg.dangci[4].max then
        return 4
    elseif M.xiaoxiaole_sg_defen_cfg.dangci[3].min <= x and x <= M.xiaoxiaole_sg_defen_cfg.dangci[3].max then
        return 3
    elseif M.xiaoxiaole_sg_defen_cfg.dangci[2].min <= x and x <= M.xiaoxiaole_sg_defen_cfg.dangci[2].max then
        return 2
    elseif M.xiaoxiaole_sg_defen_cfg.dangci[1].min <= x and x <= M.xiaoxiaole_sg_defen_cfg.dangci[1].max then
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

function M.GetBetLevel()
    return Bet_Level
end

function M.DataDamage()
    if not M or not M.data or table_is_null(M.data) then
        HintPanel.Create(
            1,
            "数据异常",
            function()
                Event.Brocast("model_xxl_sanguo_all_info_error")
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
function M.ToDealWithData(type,data)
    local tab = {}
    dump(data,"<color=yellow><size=15>++++++++++ToDealWithData++++++++++</size></color>")
    if type == "nor" or type == "nil" or type == "select" or type == "hscb_1" or type == "ccjj_1" then
        tab.result = data.result
        tab.all_rate = data.base_data.all_rate
        tab.free_game_rate = data.base_data.free_game_rate
        tab.xc_data = data.base_data.xc_data
        tab.is_free_game = data.base_data.is_free_game

        tab.state = data.status_data.status
        tab.cur_award = data.status_data.cur_award
        tab.all_award = data.status_data.all_award
        tab.time_out = data.status_data.time_out
    elseif type == "hscb_2" then
        tab.result = 0
        tab.all_rate = data.hscb_data.all_rate
        tab.start_fire_index = data.hscb_data.start_fire_index
        tab.fire_ship_num = data.hscb_data.fire_ship_num
        tab.xc_data = data.hscb_data.xc_data
        tab.wind_data = data.hscb_data.wind_data
        tab.state = data.status_data.status

        tab.cur_award = data.status_data.cur_award
        tab.all_award = data.status_data.all_award
        tab.time_out = data.status_data.time_out
    elseif type == "ccjj_cs" or type == "ccjj_2" then
        tab.result = 0 
        tab.all_rate = data.ccjj_data.all_rate 
        tab.tot_arrow_num = data.ccjj_data.tot_arrow_num 
        tab.arrow_num = data.ccjj_data.arrow_num 
        tab.xc_data = data.ccjj_data.xc_data 
        tab.state = data.status_data.status

        tab.cur_award = data.status_data.cur_award
        tab.all_award = data.status_data.all_award
        tab.time_out = data.status_data.time_out
    end
    dump(tab,"<color=yellow><size=15>++++++++++tab++++++++++</size></color>")
    return tab
end

--改变横纵
function M.ChangeXY(type)
    if type == "nor" or type == "nil" or type == "select" then
        EliminateSGModel.size.max_x = 8
        EliminateSGModel.size.max_y = 8
        EliminateSGModel.size.size_x = 105
        EliminateSGModel.size.size_y = 105
        EliminateSGModel.size.spac_x = 0
        EliminateSGModel.size.spac_y = 1
    else
        EliminateSGModel.size.max_x = 5
        EliminateSGModel.size.max_y = 4
        EliminateSGModel.size.size_x = 200
        EliminateSGModel.size.size_y = 135
        EliminateSGModel.size.spac_x = 0
        EliminateSGModel.size.spac_y = 5
    end
end