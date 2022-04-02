local basefunc = require "Game.Common.basefunc"
EliminateCSModel = {}
local M = EliminateCSModel
M.xiaoxiaole_cs_defen_cfg = HotUpdateConfig("Game.game_EliminateCS.Lua.xiaoxiaole_cs_defen_cfg")
M.kaijiang_maps = "3336644433366444333664446665566666655666111662221116622211166222"
M.size = {
    max_x = 8,
    max_y = 8,
    size_x = 114,
    size_y = 114,
    spac_x = 4,
    spac_y = 4,
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

    show_clear1 = 0.4,--展示结算1的延时
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

    xc_pt = 1.5,--消除普通特效时间
    xc_zi3 = 3,--集齐3个字时再消蛋
    xc_zi4 = 5,--集齐4个字时
    xc_zi4_1 = 1,--刚刚集齐4个字时
    xc_chu_zi = 4,--金蛋消除时获得每个字时
    xc_zd = 3,--进入砸蛋时间
    xc_zd1 = 2,--进入砸蛋时间1
    xc_zp = 4.46,--进入转盘时间
    xc_zp_xs = 5,--从天女撒花出现到转盘消失
    xc_zkj = 0.3,--再次开奖间隔时间
    xc_hb = 8,--花瓣特效持续时间

    zd_gzs = 1,--砸出的花展示时间
    xc_zd_xs = 5,--从天女撒花出现到砸蛋消失

    hb_dd = 0.02,--持续掉落的花瓣掉落到中间位置时间
    hb_lx_min = 0,--花瓣落到元素上的时间
    hb_lx_max = 2,--花瓣落到元素上的最长时间

    hb_jsgdsj = 0.2,--花瓣改变加速滚动时间
    hb_ysgdsj = 0.2,--花瓣改变匀速滚动时间
    hb_j_sgdsj = 0.4,--花瓣改变减速滚动时间
    hb_gdycsj = 2.3,--花瓣改变滚动一次的时间总和
    hb_xz = 10,--花瓣选中特效显示时间 * 2

    ji_zi_fd = 0.2,--集字,字放大
    ji_zi_dd = 0.2,--集字,字放大后等待
    ji_zi_fx = 0.4,--集字,字放大后等待后飞行
    ji_zi_zddd = 1,--集字,右侧字出现后等待震动
    ji_zi_zd = 0.6,--集字,右侧字震动

    ji_zi_jq_cx = 1,--集字,集齐4个字出现

    ji_jdt_fx = 1,--集进度条，闪光飞行
}

M.Model_Status = {
    gaming = "gaming",
    gameover = "gameover"
}

M.status_lottery = {
    wait = "wait",--等待开奖
    run = "run",--开奖中
    run_prog = "run_prog",--进度条开奖
}

M.xc_state = {
	nor = "nor", --普通消除
	zd = "zd",	--砸蛋
	zd_tnsh = "zd_tnsh",	--砸蛋天女散花
	zp = "zp",	--转盘
	zp_tnsh = "zp_tnsh",	--转盘天女散花
}

M.csxxl_state_key = "csxxl_state_key"   --财神消消乐当前状态

M.eliminate_enum={
    null = 0,
    one=1,
    two=2,
    three=3,
    four=4,
    five=5,
	lucky=6,
}

M.yxcard_type = "prop_xxl_caishen_card"

local lister
local function MakeLister()
    lister = {}
    lister["xxl_caishen_all_info_response"] = M.xxl_caishen_all_info_response
    lister["xxl_caishen_enter_game_response"] = M.xxl_caishen_enter_game_response
    lister["xxl_caishen_quit_game_response"] = M.xxl_caishen_quit_game_response
    lister["xxl_caishen_kaijiang_response"] = M.xxl_caishen_kaijiang_response
    lister["xxl_caishen_progress_data_kaijiang_response"] = M.xxl_caishen_progress_data_kaijiang_response

    lister["set_csxxl_betlevel"] = M.set_csxxl_betlevel
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
        bet = M.data and M.data.bet or {0,0,0,0,0},
        status_lottery = M.status_lottery.wait,--开奖状态
        
        --s2c
        all_money = 0,--奖励的钱
        all_rate = 0,--倍率
    }
end

function M.Init()
    InitConfig(M.xiaoxiaole_cs_defen_cfg)
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
function M.xxl_caishen_all_info_response(p_n, data)
    dump(data, "<color=yellow>xxl_caishen_all_info_response</color>")
    if EliminateCSLogic.is_test then
        data = EliminateCSLogic.GetTestData()
    end
    if data.result ~= 0 then
        if data.result == -1 then
            Event.Brocast("model_xxl_all_info_error")
            return
        end
        HintPanel.ErrorMsg(data.result,function()
            Event.Brocast("model_xxl_caishen_all_info_error")
        end)
        return
    end
    --恢复数据
    InitModelData()
    M.data.model_status = M.Model_Status.gaming
    if not data.xc_data then
        data.xc_data = M.kaijiang_maps
        data.type = M.xc_state.nor
        M.data.is_new = true
        M.data.state = nil
    else
        M.data.is_new = nil
        M.data.state = PlayerPrefs.GetString(M.csxxl_state_key,"")
        if M.data.state == "" then
            M.data.state = nil
        end
    end
    if data.type == M.xc_state.nor then
        M.data.eliminate_data = eliminate_cs_algorithm.compute_eliminate_result_nor(data,M.cfg)
    elseif data.type == M.xc_state.zp then
        if table_is_null(data.tnsh_all_data) then
            data.tnsh_all_data = {
                index = data.index,
                all_jindan_value = data.all_jindan_value,
            }
        else
            data.tnsh_all_data.index = data.index
            data.tnsh_all_data.all_jindan_value = data.all_jindan_value
        end
        M.data.eliminate_data = eliminate_cs_algorithm.compute_eliminate_result_zp(data,M.cfg)
    end

    --结果打印
    dump(M.data.eliminate_data, "<color=red>eliminate_data</color>")
    if M.data.eliminate_data.result then
        for k,v in pairs( M.data.eliminate_data.result) do
            dump(v, "<color=red>result:</color>" .. k)
        end
    end
    
    M.data.all_money = M.data.eliminate_data.all_money
    M.data.all_rate = M.data.eliminate_data.all_rate / 10
    M.data.all_jindan_value = M.data.eliminate_data.all_jindan_value
    
    M.SetSkip(false)
    M.SetSpeed(1)
    M.SetAuto(false)
    M.SetDataLotteryEnd()

    dump(M.data, "<color=yellow>数据</color>")
    Event.Brocast("model_xxl_caishen_all_info")
end

--********************response
--进入游戏
function M.xxl_caishen_enter_game_response(_, data)
    dump(data, "<color=yellow>xxl_caishen_enter_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_caishen_enter_game_response", data)
end

--退出游戏
function M.xxl_caishen_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>xxl_caishen_quit_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_caishen_quit_game_response", data)
    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end

--开奖
function M.xxl_caishen_kaijiang_response(proto_name, data)
    dump(data, "<color=yellow>xxl_caishen_kaijiang_response</color>")
    if data.result == 0 then
        M.SetDataLotteryStart()
        M.data.eliminate_data = eliminate_cs_algorithm.compute_eliminate_result_nor(data,M.cfg)
        --结果打印
        dump( M.data.eliminate_data, "<color=red>eliminate_data</color>")
        if M.data.eliminate_data.result then
            for k,cur_result in pairs( M.data.eliminate_data.result) do
                dump(cur_result, "<color=red>result：</color>" .. k)
            end
        end
        if M.data.eliminate_data.all_money then
            M.data.all_money = M.data.eliminate_data.all_money
        end
        if M.data.eliminate_data.all_rate then
            M.data.all_rate = M.data.eliminate_data.all_rate / 10
        end
        if M.data.eliminate_data.all_jindan_value then
            M.data.all_jindan_value = M.data.eliminate_data.all_jindan_value
        end
        M.data.is_new=nil
        Event.Brocast("model_lottery_success")
    else
        if data.result == 1012 then
            --如果是[需要的数量有异常]就弹出充值面板
            Event.Brocast("model_lottery_error_amount")
        else
            HintPanel.ErrorMsg(data.result)
        end
        EliminateCSGamePanel.ExitTimer()
        M.SetAuto(false)
        M.SetDataLotteryEnd()
        Event.Brocast("model_lottery_error")
    end
end

--转盘开奖
function M.xxl_caishen_progress_data_kaijiang_response(proto_name, data)
    dump(data, "<color=yellow>xxl_caishen_progress_data_kaijiang_response</color>")
    if data.result == 0 then
        M.SetDataLotteryStartProg()
        data.tnsh_all_data = {
            index = data.index,
            all_money = data.all_money,
            all_rate = data.all_rate,
            all_jindan_value = data.all_jindan_value,
            xc_data = data.xc_data,
            change_data = data.change_data,
        }
        M.data.eliminate_data = eliminate_cs_algorithm.compute_eliminate_result_zp(data,M.cfg)
    
        --结果打印
        dump( M.data.eliminate_data, "<color=red>eliminate_data</color>")
        if M.data.eliminate_data.result then
            for k,cur_result in pairs( M.data.eliminate_data.result) do
                dump(cur_result, "<color=red>result：</color>" .. k)
            end
        end
        if M.data.eliminate_data.all_money then
            M.data.all_money = M.data.eliminate_data.all_money
        end
        if M.data.eliminate_data.all_rate then
            M.data.all_rate = M.data.eliminate_data.all_rate / 10
        end
        if M.data.eliminate_data.all_jindan_value then
            M.data.all_jindan_value = M.data.eliminate_data.all_jindan_value
        end
        M.data.is_new=nil
        Event.Brocast("model_lottery_success_zp")
    else
        HintPanel.ErrorMsg(data.result)
        EliminateCSGamePanel.ExitTimer()
        M.SetAuto(false)
        M.SetDataLotteryEnd()
        Event.Brocast("model_lottery_error_zp")
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
    if not v and type(v) ~= "boolean" then return end
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
    if not v and type(v) ~= "number" then return end
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
    if not v and type(v) ~= "boolean" then return end
    M.data = M.data or {}
    M.data.skip = v
end

function M.GetSkip()
    if M.data and M.data.skip then
        return M.data.skip
    end  
end

function M.SetBet(v)
    if not v and type(v) ~= "tabel" then return end
    M.data = M.data or {}
    M.data.bet = v
end

function M.GetBet()
    if not M then return end
    if M.data and M.data.bet then
        return M.data.bet
    end  
end

function M.GetTime(t)
    t = t or 1
    if M and M.data and M.data.speed then
        M.data.speed = M.data.speed or 1
        return t / M.data.speed / 2
    else
        return 0.02
    end
end


function M.GetAwardMoney()
    return M.data.all_money or 0
end

function M.GetAwardRate()
    return M.data.all_rate
end

--所有消除结果数据
function M.GetAllResultData()
    local result_data = {}
    result_data.all_money = M.data.all_money
    result_data.all_jindan_value = M.data.all_jindan_value
    result_data.all_rate = M.data.all_rate
    result_data.all_del_list = eliminate_cs_algorithm.get_all_del_list(M.data.eliminate_data.result)
    result_data.all_del_rate_list = eliminate_cs_algorithm.get_all_del_rate_list(M.data.eliminate_data.result)
    result_data.all_tnsh_list = M.data.eliminate_data.all_tnsh_list
    return result_data
end

function M.GetAllResultLevel()
    local data = M.GetAllResultData()
    if not data then return 1 end
    local x = data.all_rate
    --去掉金蛋的额外倍率
    if data.total_jindan_extra_rate then
        x = x - data.total_jindan_extra_rate
    end
    if M.xiaoxiaole_cs_defen_cfg.dangci[4].min <= x and x < M.xiaoxiaole_cs_defen_cfg.dangci[4].max then
        return 4
    elseif M.xiaoxiaole_cs_defen_cfg.dangci[3].min <= x and x < M.xiaoxiaole_cs_defen_cfg.dangci[3].max then
        return 3
    elseif M.xiaoxiaole_cs_defen_cfg.dangci[2].min <= x and x < M.xiaoxiaole_cs_defen_cfg.dangci[2].max then
        return 2
    elseif M.xiaoxiaole_cs_defen_cfg.dangci[1].min <= x and x < M.xiaoxiaole_cs_defen_cfg.dangci[1].max then
        return 1
    else
        return 1
    end
end

function M.GetHeroData()
    if not M.data.eliminate_data then return end
    return M.data.eliminate_data.result[#M.data.eliminate_data.result].hero
end

function M.CheckIsHero1(cur_result)
    if table_is_null(cur_result) or 
        table_is_null(cur_result.hero) or 
        table_is_null(cur_result.hero[1]) then 
        return
    end
    return true
end

--传入一个倍率，计算获得了多少奖励 注意：当前的游戏模式，没有单独对某一个元素进行押注，所以所有元素的押注都是一样的
function M.GetAwardGold(cur_rate)
    if not M then return 0 end
    local bet = M.GetBet()
    if not table_is_null(bet) and bet[1] then
        return cur_rate * bet[1]
    end
    return 0
end

--获得当前的档次
local Bet_Level = 1
function M.set_csxxl_betlevel(_,betlevel)
    Bet_Level = betlevel
    Event.Brocast("csxxl_betlevel_changed")
end

function M.GetBetLevel()
   return Bet_Level
end

--是否有财神
function M.IsZD()
    if not table_is_null(M.data.eliminate_data) and not table_is_null(M.data.eliminate_data.result) then
        for i,v in ipairs(M.data.eliminate_data.result) do
            if v.state == M.xc_state.zd then
                return true
            end
        end
    end
end

function M.GetNorXCLastResult()
    local result
    if not table_is_null(M.data.eliminate_data) and not table_is_null(M.data.eliminate_data.result) then
        for i,v in ipairs(M.data.eliminate_data.result) do
            if v.state == M.xc_state.zd then
                return result
            end
            result = v
        end
    end
end

function M.GetAllResultDataInNor()
    local result_data = {}
    if not table_is_null(M.data.eliminate_data) then
        if not table_is_null(M.data.eliminate_data.result) then
            for i,_v in ipairs(M.data.eliminate_data.result) do
                if _v.state ~= M.xc_state.nor then
                    break
                end
                if not table_is_null(_v.del_list) then
                    for i,v in ipairs(_v.del_list) do
                        result_data.all_del_list = result_data.all_del_list or {}
                        table.insert( result_data.all_del_list,basefunc.deepcopy(v))
                    end
                end
                if not table_is_null(_v.del_rate_list) then
                    for i,v in ipairs(_v.del_rate_list) do
                        result_data.all_del_rate_list = result_data.all_del_rate_list or {}
                        table.insert( result_data.all_del_rate_list,basefunc.deepcopy(v))
                    end
                end
            end
        end
    end
    return result_data
end

function M.GetResultInNor()
    local result_data = {}
    if not table_is_null(M.data.eliminate_data) and not table_is_null(M.data.eliminate_data.result) then
        for i,_v in ipairs(M.data.eliminate_data.result) do
            if _v.state ~= M.xc_state.nor then
                break
            end
            table.insert(result_data,_v)
        end
    end
    return result_data
end

function M.GetResultInZD()
    local result_data = {}
    if not table_is_null(M.data.eliminate_data) and not table_is_null(M.data.eliminate_data.result) then
        result_data.eliminate_data = {}
        result_data.eliminate_data.result = {}
        for i,_v in ipairs(M.data.eliminate_data.result) do
            if _v.state == M.xc_state.zd or _v.state == M.xc_state.zd_tnsh then
                table.insert(result_data.eliminate_data.result,_v)
            end
        end
    end
    return result_data
end

function M.GetResultInZP()
    local result_data = {}
    if not table_is_null(M.data.eliminate_data) and not table_is_null(M.data.eliminate_data.result) then
        result_data.eliminate_data = {}
        result_data.eliminate_data.result = {}
        for i,_v in ipairs(M.data.eliminate_data.result) do
            if _v.state == M.xc_state.zp or _v.state == M.xc_state.zp_tnsh then
                table.insert(result_data.eliminate_data.result,_v)
            end
        end
    end
    return result_data
end

function M.DataDamage()
    if not M or not M.data or table_is_null(M.data) then 
        HintPanel.Create(1,"数据异常",function()
            Event.Brocast("model_xxl_caishen_all_info_error")
        end)
        return true
    end
end