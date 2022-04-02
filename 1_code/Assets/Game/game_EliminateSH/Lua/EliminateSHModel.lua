local basefunc = require "Game.Common.basefunc"
EliminateSHModel = {}
local M = EliminateSHModel
M.xiaoxiaole_sh_defen_cfg = HotUpdateConfig("Game.game_EliminateSH.Lua.xiaoxiaole_sh_defen_cfg")
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

    xc_pt = 3,--消除普通特效时间
    xc_lp = 0.5,--消除令牌特效时间
    xc_lp_sg = 6,--令牌闪光时间

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

    yx_km = 4.5,--英雄开门特效时间,开出英雄时间
    yx_km_zd = 2,--英雄开门震动时间
    yx_km_wc = 4,--英雄开门完成
    yx_xyg = 0.4,--下一个英雄使用技能的时间间隔
    yx_km_yy_jg = 3,--英雄开门语音间隔
    yx_km_yy_sj = 3,--英雄开门语音时间

    yx_1_show = 10,--武松出场
    yx_1_jn_rc_r = 3,--入场人物
    yx_1_jn_rc = 4,--武松技能入场
    yx_1_jn_rc_jb = 1.5,--武松技能入场加倍
    yx_1_jn_rc_js = 5,--武松技能入场结束
    yx_1_jn_zd = 1,--武松加倍震动

    yx_1_jn_jb_sg = 0,--武松加倍闪光
    yx_1_jn_jb_sg_yd = 0.3,--武松加倍闪光拖尾移动时间
    yx_1_jn_jb_sg_js = 6,--武松加倍闪光结束,回收资源
    yx_1_jn_jb_sz_ks_jg = 0.06,--武松加倍数字开始间隔
    yx_1_jn_jb_sz_yd = 0.3,--武松加倍数字移动

    yx_2_show = 4,--鲁智深出场
    yx_2_jn_rc_r = 3,--入场人物
    yx_2_jn_rc = 2,--鲁智深技能入场
    yx_2_jn_zd = 1,--鲁智深技能出现时震动
    yx_2_jn_fr = 0.35,--鲁智深技能摇奖飞入

    yx_2_jsgdsj = 0.1,--鲁智深技能英雄加速滚动时间
    yx_2_ysgdsj = 1.8,--鲁智深技能英雄匀速滚动时间
    yx_2_j_sgdsj = 0.4,--鲁智深技能英雄减速滚动时间
    yx_2_gdyc_sj = 2.3,--鲁智深滚动一次的时间总和

    yx_2_jsgdjg = 0.1,--鲁智深技能英雄加速滚动间隔    
    yx_2_ysgdjg = 0.02,--鲁智深技能英雄匀速滚动一次时间

    yx_2_skill = 0,--鲁智深使用技能时间(会根据英雄数量动态改变)
    yx_2_jn_z_d = 8.6,--鲁智深转动(会根据英雄数量动态改变)
    yx_2_jn_sgdtsxcjg = 4,--鲁智深技能中奖闪光到特殊消除的时间间隔
    yx_2_jn_tsxcjg = 0.4,--4个 鲁智深技能特殊消除时间间隔
    yx_2_jn_tsxctime = 2,--鲁智深技能特殊消除

    yx_3_skill = 13,--李逵技能
    yx_3_jn_rc_r = 3,--入场人物
    yx_3_jn_zd = 2,--李逵技能斧头震动
    yx_3_jn_gb = 1,--李逵技能斧头改变元素
    yx_3_jn_gb_jg = 0.4,--李逵技能斧头改变元素的间隔
    yx_3_jn_gb_jg2 = 0.4,--李逵技能斧头改变元素的间隔
    yx_3_jb_yj_sj = 3,--李逵摇奖时间
    yx_3_jb_yj_zs = 1,--李逵摇奖后展示结果的时间
    yx_3_jn_cf = 4,--李逵技能黑旋风吹飞元素
    yx_3_jn_cf_jg = 0.5,--李逵技能黑旋风吹飞元素
    yx_3_jn_cc = 2.5,--李逵技能出场
    yx_3_jn_dd = 4,--李逵技能元素抖动

    yx_3_jn_ys_jsgdjg = 0.1,--加速滚动间隔
    yx_3_jn_ys_jsgdsj = 0.1,--加速滚动时间
    yx_3_jn_ys_ysgdsj = 1,--匀速滚动时间
    yx_3_jn_ys_ysgdjg = 0.02,--每一次匀速滚动到下一个位置时间
    yx_3_jn_ys_j_sgdjg = 0.1,--减速滚动间隔
    yx_3_jn_ys_j_sgdsj = 0.3,--减速滚动时间

    yx_4_skill = 13,--宋江出场
    yx_4_jn_rc_r = 3,--入场人物
    yx_4_jn_rc = 2,--宋江技能出场
    yx_4_jn_zd = 4,--宋江转动
    yx_4_jn_sg = 3,--宋江闪光
    yx_4_jn_ys_jsgdjg = 0.2,--加速滚动间隔
    yx_4_jn_ys_jsgdsj = 0.2,--加速滚动时间
    yx_4_jn_ys_ysgdsj = 1,--匀速滚动时间
    yx_4_jn_ys_ysgdjg = 0.02,--每一次匀速滚动到下一个位置时间
    yx_4_jn_ys_j_sgdjg = 0.2,--减速滚动间隔
    yx_4_jn_ys_j_sgdsj = 0.6,--减速滚动时间
}

M.Model_Status = {
    gaming = "gaming",
    gameover = "gameover"
}

M.status_lottery = {
    wait = "wait",--等待开奖
    run = "run",--开奖中
}

M.eliminate_enum={
    null = 0,
    one=1,
    two=2,
    three=3,
    four=4,
    five=5,
	lucky=6,
}

M.yxcard_type = "prop_xxl_shuihu_card"

local lister
local function MakeLister()
    lister = {}
    lister["xxl_shuihu_all_info_response"] = M.xxl_shuihu_all_info_response
    lister["xxl_shuihu_enter_game_response"] = M.xxl_shuihu_enter_game_response
    lister["xxl_shuihu_quit_game_response"] = M.xxl_shuihu_quit_game_response
    lister["xxl_shuihu_kaijiang_response"] = M.xxl_shuihu_kaijiang_response
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
        award_money = 0,--奖励的钱
        award_rate = 0,--倍率
    }
    if M.Manually then
        M.data.auto = false
    end
end

function M.Init()
    M.Manually = EliminateSHLogic.Manually --手动消除
    InitConfig(M.xiaoxiaole_sh_defen_cfg)
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
function M.xxl_shuihu_all_info_response(p_n, data)
    dump(data, "<color=yellow>xxl_shuihu_all_info_response</color>")
    if EliminateSHLogic.is_test then
        data = EliminateSHLogic.GetTestData()
    end
    if data.result ~= 0 then
        if data.result == -1 then
            Event.Brocast("model_xxl_all_info_error")
            return
        end
        HintPanel.ErrorMsg(data.result,function()
            Event.Brocast("model_xxl_shuihu_all_info_error")
        end)
        return
    end
    InitModelData()
    M.data.model_status = M.Model_Status.gaming
    --恢复数据
    M.data.award_money = data.award_money
    M.data.award_rate = data.all_rate / 10
    if not data.total_xc_data then
        data.total_xc_data={}
        data.total_xc_data[1] = M.kaijiang_maps
        M.data.is_new = true
    else
        M.data.is_new = nil
    end
    M.data.eliminate_data = eliminate_sh_algorithm.compute_eliminate_result(data,M.cfg)

    --结果打印
    dump(M.data.eliminate_data, "<color=red>eliminate_data</color>")
    if M.data.eliminate_data.result then
        for k,v in pairs( M.data.eliminate_data.result) do
            dump(v, "<color=red>result:</color>" .. k)
        end
    end
    
    M.SetSkip(false)
    M.SetSpeed(1)
    M.SetAuto(false)
    M.SetDataLotteryEnd()

    dump(M.data, "<color=yellow>数据</color>")
    Event.Brocast("model_xxl_shuihu_all_info")
end

--********************response
--进入游戏
function M.xxl_shuihu_enter_game_response(_, data)
    dump(data, "<color=yellow>xxl_shuihu_enter_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_shuihu_enter_game_response", data)
end

--退出游戏
function M.xxl_shuihu_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>xxl_shuihu_quit_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_shuihu_quit_game_response", data)
    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end

--开奖
function M.xxl_shuihu_kaijiang_response(proto_name, data)
    dump(data, "<color=yellow>xxl_shuihu_kaijiang_response</color>")
    if data.result == 0 then
        M.SetDataLotteryStart()
        if data.award_money then
            M.data.award_money = data.award_money
        end
        if data.all_rate then
            M.data.award_rate = data.all_rate / 10
        end

        M.data.eliminate_data = eliminate_sh_algorithm.compute_eliminate_result(data,M.cfg)
        --结果打印
        dump( M.data.eliminate_data, "<color=red>eliminate_data</color>")
        if M.data.eliminate_data.result then
            for k,cur_result in pairs( M.data.eliminate_data.result) do
                dump(cur_result, "<color=red>result：</color>" .. k)
            end
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
        EliminateSHGamePanel.ExitTimer()
        EliminateSHObjManager.ExitTimer()
        EliminateSHAnimManager.ExitTimer()
        M.SetAuto(false)
        M.SetDataLotteryEnd()
        Event.Brocast("model_lottery_error")
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


function M.SetAuto(v)
    if not v and type(v) ~= "boolean" then return end
    M.data = M.data or {}
    M.data.auto = v
    if v then
        M.SetSpeed(2)
    else
        M.SetSpeed(1)
    end

    if M.Manually then
        M.data.auto = false
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
    return M.data.award_money or 0
end

function M.GetAwardRate()
    return M.data.award_rate
end

--所有消除结果数据
function M.GetAllResultData()
    local result_data = {}
    result_data.award_money = M.data.award_money
    result_data.award_rate = M.data.award_rate
    result_data.all_del_list = eliminate_sh_algorithm.get_all_del_list(M.data.eliminate_data.result,false)
    result_data.all_del_rate_list = eliminate_sh_algorithm.get_all_del_rate_list(M.data.eliminate_data.result,false)
    return result_data
end

function M.GetAllResultLevel()
    local data = M.GetAllResultData()
    if not data then return 1 end
    local x = data.award_rate
    if EliminateSHModel.xiaoxiaole_sh_defen_cfg.dangci[4].min <= x and x < EliminateSHModel.xiaoxiaole_sh_defen_cfg.dangci[4].max then
        return 4
    elseif EliminateSHModel.xiaoxiaole_sh_defen_cfg.dangci[3].min <= x and x < EliminateSHModel.xiaoxiaole_sh_defen_cfg.dangci[3].max then
        return 3
    elseif EliminateSHModel.xiaoxiaole_sh_defen_cfg.dangci[2].min <= x and x < EliminateSHModel.xiaoxiaole_sh_defen_cfg.dangci[2].max then
        return 2
    elseif EliminateSHModel.xiaoxiaole_sh_defen_cfg.dangci[1].min <= x and x < EliminateSHModel.xiaoxiaole_sh_defen_cfg.dangci[1].max then
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
    local bet = EliminateSHModel.GetBet()
    if not table_is_null(bet) and bet[1] then
        return cur_rate * bet[1]
    end
    return 0
end

--获取英雄2已经中奖的lucky个数
function M.GetHeroLuckyedCount(cur_result,k)
    local lucky_count = 0
    local k = 2
    for h_id=1,4 do
        if cur_result.hero[k].lucky[h_id] then
            lucky_count = lucky_count + 1
        end
    end
    return lucky_count
end
--获取英雄2当前需要摇奖的英雄个数
function M.GetHeroCurChangeLuckyCount(cur_result,k)
    local k = 2
    local change_lucky = 0
    local x = 1
    for y=1,4 do
        if not M.CheckHero2IndexIsLuckyed(cur_result.hero[k],y) then
            change_lucky = change_lucky + 1
        end
    end
    return change_lucky
end

--检查英雄2中的某一个索引是否已经中奖过
function M.CheckHero2IndexIsLuckyed(hero2,index)
    return not hero2.cur_lucky[index] and hero2.lucky[index]
end

function M.CheckHeroIsCreateInAllResult()
    if M and M.data and M.data.eliminate_data and M.data.eliminate_data.result then
        for k,v in pairs( M.data.eliminate_data.result) do
            if not table_is_null(v.hero) and not table_is_null(v.hero[1]) then
                return true
            end
        end
    end
end