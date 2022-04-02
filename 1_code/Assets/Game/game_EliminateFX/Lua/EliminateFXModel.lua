local basefunc = require "Game.Common.basefunc"
EliminateFXModel = {}
local M = EliminateFXModel
M.xiaoxiaole_fx_defen_cfg = HotUpdateConfig("Game.game_EliminateFX.Lua.xiaoxiaole_fx_defen_cfg")
M.kaijiang_maps = "11111222223333344444"

M.bigGameRateMap = nil

M.size = {
    max_x = 5,
    max_y = 4,
    size_x = 140,
    size_y = 140,
    spac_x = 30,
    spac_y = 11,
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
    xc_pt = 1.5,--消除普通特效时间
    xc_hf_sg = 4,--虎符闪光时间
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

M.status_lottery = {
    wait = "wait",          --等待开奖
    run = "run",            --开奖中
}

M.xc_state = {
    nor = "nor",            --普通消除
    big_game = "big_game",  --小游戏
}

M.eliminate_enum = {
    null = 0,
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,

    --特殊元素
    sp1 = 100,
    sp2 = 101,
    sp3 = 102,
    sp4 = 103,
}

M.yxcard_type = "prop_xxl_fuxing_card"

local lister
local function MakeLister()
    lister = {}
    lister["xxl_fuxing_all_info_response"] = M.xxl_fuxing_all_info_response
    lister["xxl_fuxing_enter_game_response"] = M.xxl_fuxing_enter_game_response
    lister["xxl_fuxing_quit_game_response"] = M.xxl_fuxing_quit_game_response
    lister["xxl_fuxing_main_kaijiang_response"] = M.xxl_fuxing_main_kaijiang_response
    lister["xxl_fuxing_pool_info"] = M.on_xxl_fuxing_pool_info
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
        award_pools  = M.data and M.data.award_pools or {0, 0, 0, 0},
        xiaochu_award  = M.data and M.data.xiaochu_award or 0,
        little_spec_rate  = M.data and M.data.little_spec_rate or 0,
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
function M.xxl_fuxing_all_info_response(p_n, data)
    dump(data, "<color=yellow>xxl_fuxing_all_info_response</color>")
    if data.result == -1 then
        --模块加载失败服务器
        Event.Brocast("model_xxl_fuxing_all_info_error")
        return
    elseif data.result ~= 0 then
        HintPanel.ErrorMsg(
            data.result,
            function()
                Event.Brocast("model_xxl_fuxing_all_info_error")
            end
        )
        return
    end
    --恢复数据
    InitModelData()
    M.data.model_status = M.Model_Status.gaming

    if not data.main_status or not data.main_xc_data then
        M.data.is_new = true
        data.main_status = {}
        data.main_xc_data = {}
        data.main_xc_data.xc_data = M.kaijiang_maps
    else
        M.data.is_new = false
        if data.main_status.has_little == 1 then
            M.data.eliminate_data_nor = eliminate_fx_algorithm.compute_eliminate_result(M.ToDealWithData(data))
            M.data.all_money_only_xc_nor = M.data.eliminate_data_nor.all_money_only_xc
            M.data.state = "big_game"
            data.main_xc_data.xc_data = data.main_xc_data.xc_data_little
        else
            M.data.eliminate_data_nor = {}
            M.data.state = "nor"
        end
    end

    dump(M.data, "<color=white>MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM</color>")
    M.data.eliminate_data = eliminate_fx_algorithm.compute_eliminate_result(M.ToDealWithData(data))

    --结果打印
    dump(M.data.eliminate_data, "<color=red>eliminate_data</color>")
    if M.data.eliminate_data.result then
        for k, v in pairs(M.data.eliminate_data.result) do
            dump(v, "<color=red>result:</color>" .. k)
        end
    end
    M.data.all_money = M.data.eliminate_data.all_money
    M.data.all_money_only_xc = M.data.eliminate_data.all_money_only_xc
    M.data.all_rate = M.data.eliminate_data.all_rate

    if M.data.eliminate_data.award_pools then
        --不需要在all_info中给奖池赋值，断线重连直接重置奖池
        M.ResetJcData()
    end

    if M.data.eliminate_data.little_spec_rate then
        M.data.little_spec_rate = M.data.eliminate_data.little_spec_rate
    end

    --获得奖池的金额
    if M.data.eliminate_data.take_pool_award then
        M.data.take_pool_award = M.data.eliminate_data.take_pool_award
    end
    --奖池类型
    if M.data.eliminate_data.take_pool_id then
        M.data.take_pool_id = M.data.eliminate_data.take_pool_id
    end

    M.SetSkip(false)
    M.SetSpeed(1)
    M.SetAuto(false)
    M.SetDataLotteryEnd()
    
    -- M.is_all_info = true
    dump(M.data, "<color=yellow>数据</color>")
    Event.Brocast("model_xxl_fxgz_bet_change")
    Event.Brocast("model_xxl_fuxing_all_info")
    dump(M.data.state,"<color=yellow><size=15>++++++++++M.data.state++++++++++</size></color>")
end

--********************response
--进入游戏
function M.xxl_fuxing_enter_game_response(_, data)
    dump(data, "<color=yellow>xxl_fuxing_enter_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_fuxing_enter_game_response", data)
end

--退出游戏
function M.xxl_fuxing_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>xxl_fuxing_quit_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_fuxing_quit_game_response", data)
    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end

--开奖base
function M.xxl_fuxing_main_kaijiang_response(proto_name, data)
    dump(data, "<color=yellow>xxl_fuxing_main_kaijiang_response</color>")
    if data.result == 0 then
        EliminateFXModel.data.state = data.main_status.state or "nor"
        if EliminateFXModel.data.state == "nor" then
            EliminateFXPartManager.CreateTR()
            data.fake_rate_data_little = ""
            for i=1,20 do
                math.randomseed(os.time() + i)
                data.fake_rate_data_little = data.fake_rate_data_little .. tostring(math.random(1,6))
            end
        else
            M.data.all_money_only_xc_nor = M.data.all_money_only_xc
        end
        M.kaijiang_data = data
        M.SetDataLotteryStart()
        if false then
            M.data.eliminate_data = eliminate_fx_algorithm.compute_eliminate_result(EliminateFXLogic.GetTestData("nor"))
        else
            M.data.eliminate_data = eliminate_fx_algorithm.compute_eliminate_result(M.ToDealWithData(data))
        end
        --结果打印
        dump(M.data.eliminate_data, "<color=red>基础eliminate_data</color>")
        if M.data.eliminate_data.result then
            for k, cur_result in pairs(M.data.eliminate_data.result) do
                dump(cur_result, "<color=red>基础result：</color>" .. k)
            end
        end
        if M.data.eliminate_data.all_money then
            M.data.all_money = M.data.eliminate_data.all_money
        end
        if M.data.eliminate_data.all_money_only_xc then
            M.data.all_money_only_xc = M.data.eliminate_data.all_money_only_xc
        end
        if M.data.eliminate_data.all_rate then
            M.data.all_rate = M.data.eliminate_data.all_rate
        end
        if M.data.eliminate_data.award_pools then
            -- M.data.award_pools = M.data.eliminate_data.award_pools
            -- M.HandleJcData(M.data.eliminate_data.award_pools)
        end
        if M.data.eliminate_data.little_spec_rate then
            M.data.little_spec_rate = M.data.eliminate_data.little_spec_rate
        end
        --通过消除获得的奖励(包括小游戏)
        if M.data.eliminate_data.xiaochu_award then
            M.data.xiaochu_award = M.data.eliminate_data.xiaochu_award
        end
        --奖池类型
        if M.data.eliminate_data.take_pool_id then
            M.data.take_pool_id = M.data.eliminate_data.take_pool_id
        end
        --获得奖池的金额
        if M.data.eliminate_data.take_pool_award then
            M.data.take_pool_award = M.data.eliminate_data.take_pool_award
        end
        if M.data.eliminate_data.state ~= "big_game" then
            M.HandleAwardPoolOpen()
        end
        M.data.is_new = nil
        M.ResetGameRateMap()
        Event.Brocast("model_lottery_success")
    else
        if data.result == 1012 then
            --如果是[需要的数量有异常]就弹出充值面板
            Event.Brocast("model_lottery_error_amount")
        else
            HintPanel.ErrorMsg(data.result)
        end
        EliminateFXGamePanel.ExitTimer()
        M.SetAuto(false)
        M.SetDataLotteryEnd()
        Event.Brocast("model_lottery_error")
    end
end

--奖池变动信息
function M.on_xxl_fuxing_pool_info(_, data)
    dump(data, "<color=white>收到服务器推送:奖池改变data</color>")
    if data.award_pools then
        M.HandleJcData(data.award_pools)
        -- M.data.award_pools = data.award_pools
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
    local num = (M.data.all_money_only_xc or 0) + (M.data.all_money_only_xc_nor or 0)
    return num
end

function M.GetAwardRate()
    return M.data.all_rate
end

function M.GetTakePoolAward()
    return tonumber(M.data.take_pool_award)
end

function M.GetAwardPools()
    local awardPools =
    {
        M.GetAwardPool1(),
        M.GetAwardPool2(),
        M.GetAwardPool3(),
        M.GetAwardPool4(),
    }
    -- dump(M.data.award_pools, "<color=white>-----------------------------------</color>")
    return awardPools
end

function M.GetAwardPool1()
    local yazhuNum = M.GetBet()[1] * 5
    local awardPool
    local base = 20000
    local lv = M.GetCurYazhuLv(yazhuNum)
    local double = lv - 3
    -- -- dump(double, "<color=white>double</color>")
    if double > 0 and double <= 4 then
        -- awardPool = base * (2 ^ double)
        awardPool = yazhuNum * 10
    elseif double > 4 then
        -- awardPool = base * (2 ^ 4)
        awardPool = 300000
    end
    return awardPool or base
end

function M.GetAwardPool2()
    local yazhuNum = M.GetBet()[1] * 5
    local awardPool
    local base = 200000
    local lv = M.GetCurYazhuLv(yazhuNum)
    local double = lv - 5

    if double > 0 and double <= 4 then
        -- awardPool = base * (2 ^ double)
        awardPool = yazhuNum * 25
    elseif double > 4 then
        -- awardPool = base * (2 ^ 4)
        awardPool = 3000000
    end
    return awardPool or base
end

function M.GetAwardPool3()
    return M.data.award_pools[3]
end

function M.GetAwardPool4()
    return M.data.award_pools[4]
end

--通过消除获得的奖励（包括小游戏）
function M.GetXiaoChuAward()
    return M.data.xiaochu_award
end

--小游戏中特殊元素 倍率和
function M.GetLittleSpecRate()
    return M.data.little_spec_rate or 0
end

function M.GetCurYazhuLv(jbNum)
    for i = 1, #M.xiaoxiaole_fx_defen_cfg.yazhu do
        if jbNum == M.xiaoxiaole_fx_defen_cfg.yazhu[i].jb then
            return M.xiaoxiaole_fx_defen_cfg.yazhu[i].dw
        end
    end
    return 0
end

--所有消除结果数据
function M.GetAllResultData()
    local result_data = {}
    local temp_list1 = eliminate_fx_algorithm.get_all_del_list(M.data.eliminate_data.result)
    local temp_list2 = {}
    if not table_is_null(M.data.eliminate_data_nor) then
        temp_list2 = eliminate_fx_algorithm.get_all_del_list(M.data.eliminate_data_nor.result)
    end
    local temp_list3 = {}
    if not table_is_null(temp_list2) then
        temp_list3 = basefunc.deepcopy(temp_list2)
    end
    for i=1,#temp_list1 do
        temp_list3[#temp_list3 + 1] = temp_list1[i]
    end
    result_data.all_del_list = temp_list3
    result_data.all_del_rate_list = eliminate_fx_algorithm.get_all_del_rate_list(M.data.eliminate_data.result)
    result_data.all_money = M.data.all_money
    result_data.all_money_only_xc = M.data.all_money_only_xc + (M.data.all_money_only_xc_nor or 0)
    result_data.all_rate = M.data.all_rate
    return result_data
end

function M.GetAllResultLevel()
    local data = M.GetAllResultData()
    if not data then
        return 1
    end
    local x = data.all_rate
    if M.xiaoxiaole_fx_defen_cfg.dangci[4].min <= x and x <= M.xiaoxiaole_fx_defen_cfg.dangci[4].max then
        return 4
    elseif M.xiaoxiaole_fx_defen_cfg.dangci[3].min <= x and x <= M.xiaoxiaole_fx_defen_cfg.dangci[3].max then
        return 3
    elseif M.xiaoxiaole_fx_defen_cfg.dangci[2].min <= x and x <= M.xiaoxiaole_fx_defen_cfg.dangci[2].max then
        return 2
    elseif M.xiaoxiaole_fx_defen_cfg.dangci[1].min <= x and x <= M.xiaoxiaole_fx_defen_cfg.dangci[1].max then
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
                Event.Brocast("model_xxl_fuxing_all_info_error")
            end
        )
        return true
    end
end

--处理数据
function M.ToDealWithData(data)
    local tab = {}
    dump(data,"<color=yellow><size=15>++++++++++ToDealWithData++++++++++</size></color>")
    tab.result = data.result
    tab.all_rate = data.main_status.rate or 0
    tab.all_money = data.main_status.award or 0
    tab.xc_data = data.main_xc_data.xc_data
    tab.has_little = data.main_status.has_little or 0
    tab.rate_data_little = data.main_xc_data.rate_data_little
    tab.award_pools = data.main_status.award_pools or {0, 0, 0, 0}
    tab.xiaochu_award = data.main_status.xiaochu_award or 0
    tab.little_spec_rate = data.main_status.little_spec_rate or 0
    tab.state = EliminateFXModel.data.state
    tab.fake_rate_data_little = data.fake_rate_data_little
    M.SetBet(data.main_status.bets)

    tab.take_pool_id = data.main_status.take_pool_id or 0
    tab.take_pool_award = data.main_status.take_pool_award or 0

    dump(tab,"<color=yellow><size=15>++++++++++tab++++++++++</size></color>")
    return tab
end


function M.BigGame_Kaijiang()
    local tab = basefunc.deepcopy(M.kaijiang_data)
    tab.main_status.state = "big_game"
    tab.main_xc_data.xc_data = tab.main_xc_data.xc_data_little
    Event.Brocast("xxl_fuxing_main_kaijiang_response","xxl_fuxing_main_kaijiang_response",tab)
end

function M.GetBigGameProcessList(index)
    local data = EliminateFXModel.data.eliminate_data.result[index]
    --每轮新增的特殊元素
    local special_list = data.special_list
    --每轮已固定的特殊元素
    local map_new = data.map_new
    local processList = {}
	for i = 1, #special_list do
		local specNewNum = special_list[i].v
		local specNewX = special_list[i].x
		local specNewY = special_list[i].y
		for m = 1, #map_new do
			local z = map_new[m]
			for n = #z, 1, -1 do
				local mapNum = map_new[m][n]
                local mapX = m
                local mapY = n
                local isNeedAdd = false
                local sendX, sendY, sendId
                local acceptX, acceptY, acceptId
                if specNewNum == 100 and mapNum >= 100 and (specNewX ~= mapX or specNewY ~= mapY) then
                    isNeedAdd = true
                    sendX, sendY, sendId = specNewX, specNewY, specNewNum
                    acceptX, acceptY, acceptId = mapX, mapY, mapNum
                elseif (mapNum == 103 and specNewNum == 103 and (specNewX ~= mapX or specNewY ~= mapY))
                or (mapNum < specNewNum and mapNum > 100 and specNewNum > 100) then
                    isNeedAdd = true
                    sendX, sendY, sendId = mapX, mapY, mapNum
                    acceptX, acceptY, acceptId = specNewX, specNewY, specNewNum
                end
                if isNeedAdd then
                    local process = { send = {}, accept = {} }
					process.send.x = sendX
					process.send.y = sendY
					process.send.id = sendId
					process.accept.x = acceptX
					process.accept.y = acceptY
					process.accept.id = acceptId
					process.isHandle = false
					process.hander = function()
                        M.BigGameHandleProcess(process.send, process.accept)
						process.isHandle = true
					end
					processList[#processList + 1] = process
                end
			end
		end
	end
	-- dump(processList, "<color=white>processList befor sort</color>")
    --元宝过程
    local processListYuanBao = {}
    --财神过程
    local processListCaiShen = {}
    for i = 1, #processList do
        if processList[i].send.id == 100 then
            processListYuanBao[#processListYuanBao + 1] = processList[i]
        else
            processListCaiShen[#processListCaiShen + 1] = processList[i]
        end
    end

	local checkObjTab = {"accept", "send"}
	local checkKeyTab = {"id", "x", "y"}
	local checkOrder = {"up", "up", "down"}
	local checkOrderFun = function(aa, bb, key)
		if key == "up" then
			return aa < bb
		elseif key == "down" then
			return aa > bb
		end
	end

	local sortHander = {}
	sortHander.sort1 = function(a, b)
        if a.send.x ~= b.send.x then
            return a.send.x < b.send.x
        elseif a.send.y ~= b.send.y then
            return a.send.y > b.send.y
        elseif a.accept.x ~= b.accept.x then
            return a.accept.x < b.accept.x
        elseif a.accept.y ~= b.accept.y then
            return a.accept.y > b.accept.y
        end
    end

	sortHander.sort2 = function(a, b, indexObj, indexKey)
		local obj = checkObjTab[indexObj]
		local key = checkKeyTab[indexKey]
		local order = checkOrder[indexKey]
		if a[obj][key] ~= b[obj][key] then
			return checkOrderFun(a[obj][key], b[obj][key], order)
		else
			local indexKeyNext = indexKey + 1
			if indexKeyNext <= #checkKeyTab then
				return sortHander.sort2(a, b, indexObj, indexKeyNext)
			else
				local indexObjNext = indexObj + 1
				if indexObjNext <= #checkObjTab then
					return sortHander.sort2(a, b, indexObjNext, 1)
				end
			end
		end
	end
    processList = {}
    if not table_is_null(processListYuanBao) then
        table.sort(processListYuanBao, function(a, b)
            return sortHander.sort1(a, b)
        end)
        for i = 1, #processListYuanBao do
            processList[#processList + 1] = processListYuanBao[i]
        end
        processListYuanBao = {}
    end
    if not table_is_null(processListCaiShen) then
        table.sort(processListCaiShen, function(a, b)
            return sortHander.sort2(a, b, 1, 1)
        end)
        for i = 1, #processListCaiShen do
            processList[#processList + 1] = processListCaiShen[i]
        end
        processListCaiShen = {}
    end
	dump(processList, "<color=white>processList</color>")
    -- M.UpdateSendRateMap(processList)
	return processList
end

function M.HandleBigGameAllProcess()
    M.ResetGameRateMap()
    local data = EliminateFXModel.data.eliminate_data
    for k, v in pairs(data.result) do
        EliminateFXModel.UpdateBaseSendRateMap(k)
        if not table_is_null(v.special_list) then
            local processList = M.GetBigGameProcessList(k)
            for i = 1, #processList do
                if not processList[i].isHandle then
                    processList[i].hander()
                end
            end
            if not table_is_null(processList) then
                M.PrintRateMap(9 - v.free_times)
            end
        end
    end
end

function M.BigGameHandleProcess(send, accept)
    M.bigGameRateMap = M.GetBigGameRateMap()
    M.bigGameRateMap[accept.x][accept.y] = M.bigGameRateMap[accept.x][accept.y] + M.bigGameRateMap[send.x][send.y]
end

--获取当前的倍率表
function M.GetBigGameRateMap()
    M.bigGameRateMap = M.bigGameRateMap or eliminate_fx_algorithm.get_big_game_primary_rate_map()
    return M.bigGameRateMap
end

--重置倍率表
function M.ResetGameRateMap()
    M.bigGameRateMap = eliminate_fx_algorithm.get_big_game_primary_rate_map()
end

function M.IsFullGameRateMap(_map)
    local map = _map or M.bigGameRateMap
    if table_is_null(map) then
        return false
    end
    local isFull = true
    for k, v in pairs(map) do
        for kk, vv in pairs(v) do
            if vv == 0 then
                isFull = false
            end
        end
    end
    return isFull
end


function M.UpdateFirstSendRateMap(need_show_map)
    local data = EliminateFXModel.data.eliminate_data.result[1]
    local littleRateMap = M.data.eliminate_data.little_rate_map
    local map_new = data.map_new
    if table_is_null(need_show_map) then
        return
    end
    for m = 1, #map_new do
        local z = map_new[m]
        for n = 1, #z do
            if need_show_map[m] and need_show_map[m][n] then
                if map_new[m][n] == 100 or map_new[m][n] == 101 then
                    M.bigGameRateMap[m][n] = littleRateMap[m][n]
                end
            end
        end
    end
end

function M.UpdateBaseSendRateMap(index)
    local data = EliminateFXModel.data.eliminate_data.result[index]
    --每轮已固定的特殊元素
    local littleRateMap = M.data.eliminate_data.little_rate_map
    if index == 1 then
        local map_new = data.map_new
        for m = 1, #map_new do
			local z = map_new[m]
			for n = 1, #z do
                if map_new[m][n] == 100 or map_new[m][n] == 101 then
                    M.bigGameRateMap[m][n] = littleRateMap[m][n]
                end
            end
        end
    else
        if not table_is_null(data.special_list) then
            local special_list = data.special_list
            for i = 1, #special_list do
                local specNewNum = special_list[i].v
                local specNewX = special_list[i].x
                local specNewY = special_list[i].y
                if specNewNum == 100 or specNewNum == 101 then
                    M.bigGameRateMap[specNewX][specNewY] = littleRateMap[specNewX][specNewY]
                end
            end
        end
    end
end


--弃用
-- function M.UpdateSendRateMap(processList)
--     if table_is_null(processList) then
--         return
--     end
--     M.bigGameRateMap = M.GetBigGameRateMap()
--     local littleRateMap = M.data.eliminate_data.little_rate_map
--     for i = 1, #processList do
--         local send = processList[i].send
--         local accept = processList[i].accept
--         if M.bigGameRateMap[send.x][send.y] == 0 and littleRateMap[send.x][send.y] ~= 0 then
--             M.bigGameRateMap[send.x][send.y] = littleRateMap[send.x][send.y]
--         end
--         if M.bigGameRateMap[accept.x][accept.y] == 0 and littleRateMap[accept.x][accept.y] ~= 0 then
--             M.bigGameRateMap[accept.x][accept.y] = littleRateMap[accept.x][accept.y]
--         end
--     end
--     dump(M.bigGameRateMap, "<color=white>M.bigGameRateMap</color>")
--     dump(M.data.eliminate_data.little_rate_map, "<color=white>littleRateMap</color>")
-- end

--获取总的倍率，客户端计算的
function M.GetAllBigGameRate(isProcess)
    local allMap = M.GetAllBigGameRateMap(isProcess)
    local rate = 0
    if table_is_null(allMap) then
        return rate
    end
    for k, v in pairs(allMap) do
        for kk, vv in pairs(v) do
            if vv then
                rate = rate + vv
            end
        end
    end
    return rate
end

--isProcess 是否经过的每轮的计算，如果没经过，就直接计算总的，经过了则用当前的倍率表即可
function M.GetAllBigGameRateMap(isProcess)
    if not isProcess then
        M.HandleBigGameAllProcess()
    end
    return M.bigGameRateMap
end

function M.HandleJcData(award_pools)
    dump(award_pools, "<color=white>HandleJcData</color>")
    M.UpdateAwardPool3(award_pools[3])
    M.UpdateAwardPool4(award_pools[4])
end

function M.ResetJcData()
    M.data.award_pools[3] = 0
    M.data.award_pools[4] = 0
end

function M.HandleAwardPoolOpen()
    if M.data.take_pool_id > 0 and tonumber(M.data.take_pool_award) > 0 then
        local _data = { take_pool_id = M.data.take_pool_id, take_pool_award = tonumber(M.data.take_pool_award)}
        Event.Brocast("xxl_fuxing_award_pool_consume", _data)
    end
end

function M.UpdateAwardPool3(value)
    local isNewPool = false
    if M.data.award_pools[3] == 0 and value ~= 0 then
        isNewPool = true
    end
    local _data = {isNewPool = isNewPool, oldPoolValue = M.data.award_pools[3]}
    M.data.award_pools[3] = value
    Event.Brocast("xxl_fuxing_award_pool_3_increase", _data)
end

function M.UpdateAwardPool4(value)
    local isNewPool = false
    if M.data.award_pools[4] == 0 and value ~= 0 then
        isNewPool = true
    end
    local _data = {isNewPool = isNewPool, oldPoolValue = M.data.award_pools[4]}
    M.data.award_pools[4] = value
    Event.Brocast("xxl_fuxing_award_pool_4_increase", _data)
end

function M.PrintRateMap(index)
    local rateMap = M.bigGameRateMap
    local total = 0
    local gridStr = {}
    for j = 1, 4 do
        local rowStr = {}
        for i = 1, 5 do
            rowStr[#rowStr + 1] = rateMap[i][j]
            total = total + rateMap[i][j]
        end
        gridStr[#gridStr + 1] = table.concat(rowStr,"\t")
    end
    print("<color=green><size=20>TTT " .. index .. "</size></color>")
    print("\n" .. table.concat(gridStr,"\n") .. "\n TTT total rate:" .. total)
end

function M.UpdateSetFakeRateDataLittle()
    local str = ""
    for x,_v in ipairs(EliminateFXModel.data.eliminate_data.fake_little_rate_map) do
        for y,v in ipairs(_v) do
            str = str .. v
        end
    end
    M.kaijiang_data.fake_rate_data_little = str
end