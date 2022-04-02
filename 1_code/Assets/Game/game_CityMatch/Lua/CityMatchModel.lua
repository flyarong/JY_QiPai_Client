--[[
正常消息是指除断线重连以外的消息
]]
local nor_ddz_base_lib = require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"
local nor_ddz_algorithm_lib = require "Game.normal_ddz_common.Lua.nor_ddz_algorithm_lib"

--比赛场ui配置
CityMatchModel = {}

CityMatchModel.Model_Status = {
    --报名成功，收到citymg_signup_response进入状态,此时在等待界面
    wait_begin = "wait_begin",
    --等待分配桌子，收到citymg_begin_msg进入状态，进入游戏界面
    wait_table = "wait_table",
    --游戏状态处于游戏中
    gaming = "gaming",
    --玩家进入晋级
    promoted = "promoted",
    --等待晋级
    wait_result = "wait_result",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

CityMatchModel.Status = {
    wait_join = "wait_join", --等待人员入座，收到citymg_join_room_respone进入状态
    fp = "fp", --发牌， 收到nor_ddz_nor_pai_msg进入状态
    jdz = "jdz", --叫地主， 收到nor_ddz_nor_permit_msg，status进入状态，退出也是通过status判定
    set_dz = "set_dz", --设置地主，
    jiabei = "jiabei", --加倍
    cp = "cp", --出牌
    settlement = "settlement", --结算
    auto = "auto" --玩家进入托管状态
}

local this
local lister
local m_data
local update
local updateDt = 0.1

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --模式
    lister["citymg_all_info"] = this.on_citymg_all_info
    lister["citymg_begin_msg"] = this.on_citymg_begin_msg
    lister["citymg_enter_room_msg"] = this.on_citymg_enter_room_msg
    lister["citymg_join_msg"] = this.on_citymg_join_msg
    lister["citymg_gameover_msg"] = this.on_citymg_gameover_msg
    lister["citymg_score_change_msg"] = this.on_citymg_score_change_msg
    lister["citymg_rank_msg"] = this.on_citymg_rank_msg
    lister["citymg_wait_result_msg"] = this.on_citymg_wait_result_msg
    lister["citymg_promoted_msg"] = this.on_citymg_promoted_msg

    --response
    lister["citymg_signup_response"] = this.on_citymg_signup_response
    lister["citymg_signup_rematch_response"] = this.on_citymg_signup_rematch_response
    lister["citymg_req_cur_signup_num_response"] = this.on_citymg_req_cur_signup_num_response
    lister["citymg_cancel_signup_response"] = this.on_citymg_cancel_signup_response
    lister["citymg_quit_game_response"] = this.on_citymg_quit_game_response

    --玩法
    lister["nor_ddz_nor_status_info"] = this.on_nor_ddz_nor_status_info
    lister["nor_ddz_nor_ready_msg"] = this.on_nor_ddz_nor_ready_msg
    lister["nor_ddz_nor_begin_msg"] = this.on_nor_ddz_nor_begin_msg
    lister["nor_ddz_nor_pai_msg"] = this.on_nor_ddz_nor_pai_msg
    lister["nor_ddz_nor_permit_msg"] = this.on_nor_ddz_nor_permit_msg
    lister["nor_ddz_nor_action_msg"] = this.on_nor_ddz_nor_action_msg
    lister["nor_ddz_nor_dizhu_msg"] = this.on_nor_ddz_nor_dizhu_msg
    lister["nor_ddz_nor_auto_msg"] = this.on_nor_ddz_nor_auto_msg
    lister["nor_ddz_nor_jiabeifinshani_msg"] = this.on_nor_ddz_nor_jiabeifinshani_msg
    lister["nor_ddz_nor_new_game_msg"] = this.on_nor_ddz_nor_new_game_msg
    lister["nor_ddz_nor_start_again_msg"] = this.on_nor_ddz_nor_start_again_msg
    lister["nor_ddz_nor_settlement_msg"] = this.on_nor_ddz_nor_settlement_msg
end

local function MsgDispatch(proto_name, data)
    -- dump(data, "<color=red>MsgDispatch</color>",proto_name)
    local func = lister[proto_name]
    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end

    --临时限制   一般在断线重连时生效  由logic控制
    if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
        return
    end
    if data.status_no then
        if proto_name ~= "nor_ddz_nor_status_info" and proto_name ~= "citymg_all_info" then
            if m_data.status_no + 1 ~= data.status_no and m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no

                print("<color=red>proto_name = " .. proto_name .. "</color>")
                --发送状态编码错误事件
                Event.Brocast("model_citymg_statusNo_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no
    end
    func(proto_name, data)
end
--注册斗地主正常逻辑的消息事件
function CityMatchModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end

--删除斗地主正常逻辑的消息事件
function CityMatchModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
end

function CityMatchModel.Update()
    if m_data then
        if m_data.countdown and m_data.countdown > 0 then
            m_data.countdown = m_data.countdown - updateDt
            if m_data.countdown < 0 then
                m_data.countdown = 0
            end
        end
    end
end

local function InitMatchData()
    CityMatchModel.data = {
        --citymg_match_info ****
        --游戏名
        name = nil,
        --总参与人数
        total_players = nil,
        model_status = nil, --模式状态
        --当前游戏状态（详细说明见文件顶部注释：斗地主状态表status）
        status = nil,
        --在以上信息相同时，判定具体的细节状态；+1递增
        status_no = 0,
        --倒计时
        countdown = 0,
        --当前的权限拥有人
        cur_p = nil,
        --我的牌列表
        my_pai_list = nil,
        --每个人剩余的牌数量
        remain_pai_amount = nil,
        --我的倍数
        my_rate = 1,
        --玩家的托管状态
        auto_status = {},
        --当前已报名人数
        signup_num = nil,
        --当前局数
        race = nil,
        --我的座位号
        seat_num = nil,
        --地主座位号
        dizhu = nil,
        --地主牌
        dz_pai = nil,
        rank = 1,
        --玩家操作列表
        action_list = {},
        --citymg_players_info***
        players_info = {}, --当前房间中玩家的信息(key=seat_num, value=玩家基础信息)
        --citymg_ddz_settlement_info*****
        --4农民  5地主 0都输了（不叫地主的情况）
        --winner
        --玩家得分
        --p_scores
        --玩家的加倍情况
        --p_jiabei
        --玩家的加倍情况
        --p_jdz
        --炸弹数量
        --bomb_count
        --春天 0-无 1-春天  2-反春
        --chuntian
        --玩家剩余的牌的列表
        --remain_pai
        citymg_ddz_settlement_info = nil,
        --citymg_final_result ****
        --rank
        --reward (*citymg_reward)
        citymg_final_result = nil,
        --客户端辅助数据***********
        --当前的地主分数
        base_rate = 0,
        --记牌器
        jipaiqi = nil,
        --比赛轮数信息
        round_info = nil,
        --比赛信息
        match_info = nil,
        --0表示普通晋级 1表示晋级决赛
        promoted_type = nil,
        --赖子牌
        laizi = 0,
        match_type = nil
    }
    m_data = CityMatchModel.data
end

local function InitMatchStatusData(status)
    m_data.status = status
    --倒计时
    m_data.countdown = 0
    --当前的权限拥有人
    m_data.cur_p = nil
    --我的牌列表
    m_data.my_pai_list = nil
    --每个人剩余的牌数量
    m_data.remain_pai_amount = nil
    --我的倍数
    local init_rate = 1
    if m_data.round_info then
        init_rate = m_data.round_info.init_rate
    end
    m_data.my_rate = init_rate or 1
    --玩家的托管状态
    m_data.auto_status = {}
    --玩家操作列表
    m_data.action_list = {}
    --当前的地主分数
    m_data.base_rate = 0
    --记牌器
    m_data.jipaiqi = nil
    --地主座位号
    m_data.dizhu = nil
    --地主牌
    m_data.dz_pai = nil

    m_data.citymg_ddz_settlement_info = nil
end

local function InitMatchRoomData(status)
    InitMatchStatusData(status)
    m_data.players_info = {}
end

local function calDizhuBaserate()
    --记录本局地主底分
    if m_data then
        m_data.base_rate = 0
        if m_data.action_list then
            for _, v in pairs(m_data.action_list) do
                if v.type == 100 and v.rate > m_data.base_rate then
                    m_data.base_rate = v.rate
                end
            end
        end
    end
end

function CityMatchModel.Init()
    InitMatchData()
    this = CityMatchModel
    this.InitDdzMacthUIConfig()
    MakeLister()
    this.AddMsgListener()

    update = Timer.New(CityMatchModel.Update, updateDt, -1, true)
    update:Start()
    --转化成算法需要的配置数据
    CityMatchModel.translate_config = {kaiguan = nor_ddz_base_lib.KAIGUAN, multi = {}}
    --初始化算法库
    CityMatchModel.ddz_algorithm = nor_ddz_algorithm_lib.New(CityMatchModel.translate_config.kaiguan, "nor_ddz_nor")
    return this
end

function CityMatchModel.Exit()
    CityMatchModel.RemoveMsgListener()
    update:Stop()
    update = nil
    this = nil
    lister = nil
    m_data = nil
    CityMatchModel.data = nil
end

--********************response
--比赛报名结果
function CityMatchModel.on_citymg_signup_response(_, data)
    dump(data, "<color=yellow>on_citymg_signup_response</color>")
    if data.result == 0 then
        m_data.model_status = CityMatchModel.Model_Status.wait_begin
        m_data.match_type = data.match_type
        --0-不可以取消  1-可以取消
        m_data.is_cancel_signup = data.is_cancel_signup
        m_data.countdown = data.cancel_signup_cd
        m_data.signup_num = data.signup_num
        m_data.total_players = data.total_players
        MainLogic.EnterGame()
        Event.Brocast("model_citymg_signup_response", data.result)
    end
end

function CityMatchModel.on_citymg_signup_rematch_response(_, data)
    dump(data, "<color=yellow>on_citymg_signup_rematch_response</color>")
    if data.result == 0 then
        m_data.model_status = CityMatchModel.Model_Status.wait_begin
        m_data.match_type = data.match_type
        --0-不可以取消  1-可以取消
        m_data.is_cancel_signup = data.is_cancel_signup
        m_data.countdown = data.cancel_signup_cd
        m_data.signup_num = data.signup_num
        -- m_data.total_round = data.total_round
        MainLogic.EnterGame()
        Event.Brocast("model_citymg_signup_response", data.result)
    end
end

function CityMatchModel.on_citymg_cancel_signup_response(_, data)
    if data.result == 0 then
        m_data.model_status = nil
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        Event.Brocast("model_citymg_cancel_signup_response", data.result)
    end
end

--退出游戏
function CityMatchModel.on_citymg_quit_game_response(proto_name, data)
    if data.result == 0 then
        MainLogic.ExitGame()
        CityMatchLogic.change_panel("CityMatchHallPanel")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function CityMatchModel.on_citymg_req_cur_signup_num_response(_, data)
    if data.result == 0 then
        m_data.signup_num = data.signup_num
    end
    Event.Brocast("model_citymg_req_cur_signup_num_response", data.result)
end

--***********************City
--所有数据
function CityMatchModel.on_citymg_all_info(proto_name, data)
    dump(data, "<color=yellow>所有数据</color>")
    if data.status_no == -1 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
    else
        local s = data
        if s then
            m_data.model_status = s.status
            m_data.game_type = s.game_type
        end

        s = data.nor_ddz_nor_status_info
        if s then
            m_data.status = s.status
            m_data.countdown = s.countdown
            m_data.cur_p = s.cur_p
            m_data.my_pai_list = s.my_pai_list
            if m_data.my_pai_list then
                table.sort(m_data.my_pai_list)
            end
            m_data.remain_pai_amount = s.remain_pai_amount
            m_data.my_rate = s.my_rate
            m_data.action_list = s.act_list
            m_data.auto_status = s.auto_status
            m_data.race = s.cur_race
            m_data.seat_num = s.seat_num

            m_data.seatNum = {}
            m_data.s2cSeatNum = {}
            nor_ddz_base_lib.transform_seat(m_data.seatNum, m_data.s2cSeatNum, m_data.seat_num)

            m_data.dizhu = s.dizhu
            m_data.dz_pai = s.dz_pai
            m_data.jipaiqi = s.jipaiqi

            calDizhuBaserate()

            if m_data.model_status == CityMatchModel.Model_Status.gameover then
                MainLogic.ExitGame()
            end

            m_data.citymg_ddz_settlement_info = s.settlement_info
        end

        s = data.match_info
        if s then
            m_data.name = s.name
            m_data.total_players = s.total_players
            m_data.is_cancel_signup = s.is_cancel_signup
        end

        s = data.players_info
        if s then
            for k, v in pairs(s) do
                m_data.players_info[v.seat_num] = v
            end
        end

        s = data.round_info
        if s then
            m_data.round_info = s
        end

        s = data.signup_num
        if s then
            m_data.signup_num = s
        end

        s = data.promoted_type
        if s then
            m_data.promoted_type = s
        end

        s = data.rank
        if s then
            m_data.rank = s
        end

        s = data.gameover_info
        if s then
            m_data.citymg_final_result = data.gameover_info
        end

        s = data.match_type
        if s then
            m_data.match_type = s
        end

        if
            m_data.model_status == CityMatchModel.Model_Status.gameover or
                m_data.status == CityMatchModel.Status.gameover
         then
            MainLogic.ExitGame()
        end
    end
    Event.Brocast("model_citymg_all_info")
end

--比赛开始
function CityMatchModel.on_citymg_begin_msg(proto_name, data)
    dump(data, "<color=yellow>on_citymg_begin_msg</color>")
    m_data.model_status = CityMatchModel.Model_Status.wait_table
    m_data.rank = data.rank
    m_data.score = data.score
    m_data.total_players = data.total_players
    Event.Brocast("model_citymg_begin_msg")
end

function CityMatchModel.on_citymg_enter_room_msg(proto_name, data)
    dump(data, "<color=yellow>on_citymg_enter_room_msg</color>")
    m_data.model_status = CityMatchModel.Model_Status.gaming
    m_data.status = CityMatchModel.Status.wait_join
    InitMatchStatusData(m_data.status)
    m_data.seat_num = data.seat_num

    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    nor_ddz_base_lib.transform_seat(m_data.seatNum, m_data.s2cSeatNum, m_data.seat_num)

    m_data.round_info = data.round_info
    m_data.my_rate = m_data.round_info.init_rate or 1
    m_data.race = 1

    if data.players_info then
        for k, v in pairs(data.players_info) do
            m_data.players_info[v.seat_num] = v
        end
    end
    Event.Brocast("model_citymg_enter_room_msg")
end

--其他玩家进入游戏
function CityMatchModel.on_citymg_join_msg(proto_name, data)
    dump(data, "<color=yellow>on_citymg_join_msg</color>")
    m_data.players_info[data.player_info.seat_num] = data.player_info
    Event.Brocast("model_citymg_join_msg", data.player_info.seat_num)
end

--等待结果
function CityMatchModel.on_citymg_wait_result_msg(proto_name, data)
    dump(data, "<color=yellow>on_citymg_wait_result_msg</color>")
    m_data.model_status = data.status
    m_data.status = CityMatchModel.Status.wait_join
    InitMatchRoomData(m_data.status)
    Event.Brocast("model_citymg_wait_result_msg")
end

--晋级
function CityMatchModel.on_citymg_promoted_msg(proto_name, data)
    dump(data, "<color=yellow>on_citymg_promoted_msg</color>")
    m_data.countdown = data.countdown
    m_data.promoted_type = data.promoted_type
    m_data.model_status = data.status
    m_data.status = CityMatchModel.Status.wait_join
    Event.Brocast("model_citymg_promoted_msg")
    m_data.promoted_type = nil
    InitMatchRoomData(m_data.status)
end

--比赛结束
function CityMatchModel.on_citymg_gameover_msg(proto_name, data)
    dump(data, "<color=yellow>比赛结束</color>")
    m_data.model_status = CityMatchModel.Model_Status.gameover
    m_data.citymg_final_result = data.final_result
    -- MainLogic.ExitGame()
    Event.Brocast("model_citymg_gameover_msg")
end

--分数改变
function CityMatchModel.on_citymg_score_change_msg(proto_name, data)
    dump(data, "<color=yellow>分数改变</color>")
    if m_data.players_info[m_data.seat_num] then
        m_data.players_info[m_data.seat_num].score = data.score
    end
    Event.Brocast("model_citymg_score_change_msg")
end

--玩家排名有变化,更新玩家排名
function CityMatchModel.on_citymg_rank_msg(proto_name, data)
    m_data.rank = data.rank
    Event.Brocast("model_citymg_rank_msg")
end

--*************************nor
--状态信息
function CityMatchModel.on_nor_ddz_nor_status_info(proto_name, data)
    dump(data, "<color=yellow>on_nor_ddz_nor_status_info</color>")
    local s = data.status_info
    if s then
        m_data.status = s.status
        m_data.countdown = s.countdown
        m_data.cur_p = s.cur_p
        m_data.my_pai_list = s.my_pai_list
        if m_data.my_pai_list then
            table.sort(m_data.my_pai_list)
        end
        m_data.remain_pai_amount = s.remain_pai_amount
        m_data.my_rate = s.my_rate
        m_data.action_list = s.act_list
        m_data.auto_status = s.auto_status
        m_data.race = s.cur_race
        m_data.seat_num = s.seat_num
        m_data.dizhu = s.dizhu
        m_data.dz_pai = s.dz_pai
        m_data.rank = s.rank
        m_data.jipaiqi = s.jipaiqi
        calDizhuBaserate()
    end
    Event.Brocast("model_nor_ddz_nor_status_info")
end

function CityMatchModel.on_nor_ddz_nor_ready_msg(proto_name, data)
    print("<color=yellow>on_nor_ddz_nor_ready_msg</color>")
end

function CityMatchModel.on_nor_ddz_nor_begin_msg(proto_name, data)
    print("<color=yellow>on_nor_ddz_nor_begin_msg</color>")
    Event.Brocast("model_nor_ddz_nor_begin_msg")
end

--发牌
function CityMatchModel.on_nor_ddz_nor_pai_msg(proto_name, data)
    dump(data, "<color=yellow>发牌：on_nor_ddz_nor_pai_msg</color>")
    m_data.status = CityMatchModel.Status.fp
    m_data.my_pai_list = data.my_pai_list
    table.sort(m_data.my_pai_list)
    m_data.remain_pai_amount = data.remain_pai_amount
    m_data.race = data.cur_race
    Event.Brocast("model_nor_ddz_nor_pai_msg")
end

--确认地主
function CityMatchModel.on_nor_ddz_nor_dizhu_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_ddz_nor_dizhu_msg</color>")
    m_data.status = CityMatchModel.Status.set_dz
    m_data.dizhu = data.dz_info.dizhu
    m_data.dz_pai = data.dz_info.dz_pai
    local seat_num = data.dz_info.dizhu
    m_data.remain_pai_amount[seat_num] = m_data.remain_pai_amount[seat_num] + #data.dz_info.dz_pai
    if seat_num == m_data.seat_num then
        for i = 1, #data.dz_info.dz_pai do
            m_data.my_pai_list[#m_data.my_pai_list + 1] = data.dz_info.dz_pai[i]
        end
        table.sort(m_data.my_pai_list)
        m_data.my_rate = m_data.my_rate * 2
    end

    --初始化记牌器
    m_data.jipaiqi = nor_ddz_base_lib.getAllPaiCount()
    nor_ddz_base_lib.jipaiqi({nor = m_data.my_pai_list}, m_data.jipaiqi)
    Event.Brocast("model_nor_ddz_nor_dizhu_msg")
end

--权限信息轮询
function CityMatchModel.on_nor_ddz_nor_permit_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_ddz_nor_permit_msg</color>")
    m_data.status = data.status
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown = (data.countdown - 0.5)
    if m_data.countdown < 0 then
        m_data.countdown = 0
    end
    m_data.cur_p = data.cur_p
    Event.Brocast("model_nor_ddz_nor_permit_msg")
end

--玩家操作
--[[
    0： 过
    1： 单牌
    2： 对子
    3： 三不带
    4： 三带一   --pai[1]代表三张部分 ，p[2]代表被带的牌
    5： 三带一对   --pai[1]代表三张部分 ，p[2]代表被带的对子
    6： 顺子    --pai[1]代表顺子起点牌，p[2]代表顺子终点牌
    7： 连队        --pai[1]代表连队起点牌，p[2]代表连队终点牌
    8： 四带2       --pai[1]代表四张部分 ，p[2]p[3]代表被带的牌
    9： 四带两对
    10：飞机带单牌（只能全部带单牌） --pai[1]代表飞机起点牌，p[2]代表飞机终点牌，后面依次是要带的牌
    11：飞机带对子（只能全部带对子）
    12：飞机  不带
    13：炸弹
    14：王炸
    100：叫地主(rate=0不叫地主，rate>0 对应的地主分值)
    101：加倍(rate=0不加倍，rate>0加倍)
]]
function CityMatchModel.on_nor_ddz_nor_action_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_ddz_nor_action_msg</color>")
    m_data.action_list[#m_data.action_list + 1] = data.action

    local act_type = data.action.type
    --注意可能是断线重连  此时相应的数据可能还没有初始化  所以一定要判断数据是否存在
    --更新玩家手上剩余扑克牌的数量
    if m_data.remain_pai_amount and act_type < 100 and data.action.cp_list and data.action.cp_list.nor then
        m_data.remain_pai_amount[data.action.p] = m_data.remain_pai_amount[data.action.p] - #data.action.cp_list.nor
        if data.action.p ~= m_data.seat_num then
            nor_ddz_base_lib.jipaiqi(data.action.cp_list, m_data.jipaiqi, m_data.laizi)
        end
        --剔除牌
        if data.action.p == m_data.seat_num and m_data.my_pai_list then
            local hash = {}
            for _, no in ipairs(data.action.cp_list.nor) do
                hash[no] = true
            end
            local list = {}
            for _, no in ipairs(m_data.my_pai_list) do
                if not hash[no] then
                    list[#list + 1] = no
                end
            end
            m_data.my_pai_list = list
        end
    end

    --记录本局地主底分
    if m_data.base_rate and act_type == 100 and data.action.rate > m_data.base_rate then
        m_data.base_rate = data.action.rate
        m_data.my_rate = data.action.rate * m_data.round_info.init_rate
    end

    --炸弹翻倍
    if m_data.my_rate and (act_type == 13 or act_type == 14) then
        m_data.my_rate = m_data.my_rate * 2
    end
    Event.Brocast("model_nor_ddz_nor_action_msg")
end

--加倍完成消息
function CityMatchModel.on_nor_ddz_nor_jiabeifinshani_msg(proto_name, data)
    m_data.my_rate = data.my_rate
    Event.Brocast("model_nor_ddz_nor_jiabeifinshani_msg")
end

--托管--
function CityMatchModel.on_nor_ddz_nor_auto_msg(proto_name, data)
    m_data.auto_status[data.p] = data.auto_status
    Event.Brocast("model_nor_ddz_nor_auto_msg", data.p)
end

--结算
function CityMatchModel.on_nor_ddz_nor_settlement_msg(proto_name, data)
    dump(data, "<color=yellow>结算数据</color>")
    m_data.citymg_ddz_settlement_info = data.settlement_info
    --更新玩家的分数
    for seat_num, p_scores in pairs(data.settlement_info.award) do
        if m_data.seat_num ~= seat_num then
            local score = m_data.players_info[seat_num].score
            m_data.players_info[seat_num].score = score + p_scores
        end
    end
    if data.settlement_info.chuntian and data.settlement_info.chuntian > 0 then
        m_data.my_rate = m_data.my_rate * 2
    end
    Event.Brocast("model_nor_ddz_nor_settlement_msg")
end

--打完一局重新发牌
function CityMatchModel.on_nor_ddz_nor_new_game_msg(proto_name, data)
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    m_data.race = data.cur_race
    Event.Brocast("model_nor_ddz_nor_new_game_msg")
end
--都没有叫地主重新开始
function CityMatchModel.on_nor_ddz_nor_start_again_msg(proto_name, data)
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    Event.Brocast("model_nor_ddz_nor_start_again_msg")
end

--***********************************方法
function CityMatchModel.ClearMatchData()
    InitMatchData()
end

--获得我的权限数据
function CityMatchModel.getMyPermitData()
    if m_data then
        if m_data.cur_p and m_data.cur_p == m_data.seat_num then
            if m_data.status == CityMatchModel.Status.jdz then
                return {type = CityMatchModel.Status.jdz, jdz_min = m_data.base_rate + 1}
            elseif m_data.status == CityMatchModel.Status.jiabei then
                return {type = CityMatchModel.Status.jiabei}
            elseif m_data.status == CityMatchModel.Status.cp then
                --判断是否为必须出牌
                local is_must = nor_ddz_base_lib.is_must_chupai(m_data.action_list)
                --判断是否有够大的牌
                local power = 0
                if not is_must then
                    power =
                        CityMatchModel.ddz_algorithm:check_cp_capacity_by_pailist(
                        m_data.action_list,
                        m_data.my_pai_list,
                        m_data.laizi
                    )
                end
                return {type = CityMatchModel.Status.cp, is_must = is_must, power = power}
            end
        end
    end
    return nil
end

--************************************大厅使用
function CityMatchModel.InitDdzMacthUIConfig()
    this.macthUIConfig = {}
    this.macthUIConfig = city_match_config
    this.macthUIConfig.config = CityMatchLogic.parm
end

-- 返回游戏当前状态 (阶段state 和 倒计时的时间time)
function CityMatchModel.GetGameStateData(func)
    local data = this.macthUIConfig.config
    --测试数据写入
    -- data.state = MainModel.CityMatchState.CMS_Null
    -- data.time = 100
    dump(data, "<color=red>游戏的状态数据</color>")
    if data then
        if func then
            func(data)
        end
        return data
    else
        MainModel.RequestCityMatchStateData(
            nil,
            function(_data)
                dump(_data, "<color=red>_data游戏的状态数据</color>")
                if func then
                    func(_data)
                end
                return _data
            end
        )
    end
end

-- 判断是否比赛结束(至少打过一届)
function CityMatchModel.IsMatchGameOver()
    return true
end

--********************
function CityMatchModel.GetDdzMacthUIConfigTxt()
    return city_match_config.config_txt
end

function CityMatchModel.GetDdzMacthUIConfigNum()
    return city_match_config.config_num
end

function CityMatchModel.GetDdzMacthUIConfigFinalsRank()
    return city_match_config.config_finals_rank
end

function CityMatchModel.GetDdzMacthUIConfigTips()
    return city_match_config.config_tips
end

local maxPlayerNumber = 3
-- 返回自己的座位号
function CityMatchModel.GetPlayerSeat()
    return m_data.seat_num
end
-- 返回自己的UI位置
function CityMatchModel.GetPlayerUIPos()
    return CityMatchModel.GetSeatnoToPos(m_data.seat_num)
end
-- 根据座位号获取玩家UI位置
function CityMatchModel.GetSeatnoToPos(seatno)
    local seftSeatno = CityMatchModel.GetPlayerSeat()
    return (seatno - seftSeatno + maxPlayerNumber) % maxPlayerNumber + 1
end
-- 根据UI位置获取玩家座位号
function CityMatchModel.GetPosToSeatno(uiPos)
    local seftSeatno = CityMatchModel.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % maxPlayerNumber + 1
end

-- 根据UI位置获取玩家座位号
function CityMatchModel.GetPosToPlayer(uiPos)
    local seatno = CityMatchModel.GetPosToSeatno(uiPos)
    return m_data.players_info[seatno]
end

-- 是否是自己 玩家自己的UI位置在1号位
function CityMatchModel.IsPlayerSelf(uiPos)
    return uiPos == 1
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function CityMatchModel.GetAnimChatShowPos(id)
    if m_data and m_data.players_info then
        for k, v in ipairs(m_data.players_info) do
            if v.id == id then
                local uiPos = CityMatchModel.GetSeatnoToPos(v.seat_num)
                if CityMatchModel.data.dizhu and CityMatchModel.data.dizhu > 0 then
                    return uiPos, true
                else
                    return uiPos, false
                end
            end
        end
    end
    
    dump(id, "<color=red>发送者ID</color>")
    dump(m_data.players_info, "<color=red>玩家列表</color>")
    return 1, false
end
