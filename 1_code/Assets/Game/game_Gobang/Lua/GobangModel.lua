
require "Game.game_Gobang.Lua.gobang_algorithm"
local gobang_robot_ai = require "Game.game_Gobang.Lua.gobang_robot_ai"
local basefunc = require "Game.Common.basefunc"

GobangModel = {}

GobangModel.maxPlayerNumber = 2
GobangModel.isWaitStart = false


local MAX_GRID = 15

local this
local lister
local chessboard = {}
local algorithm
local m_data

GobangModel.Model_Status = {
    --等待分配桌子，疯狂匹配中
    wait_table = "wait_table",
    --报名成功，在桌子上等待开始游戏
    wait_begin = "wait_begin",
    --游戏状态处于游戏中
    gaming = "gaming",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

GobangModel.Status =
{
    start = "start",-- 开始游戏
    wait_table = "wait_table", -- 等待配桌
    wait_p = "wait_p", -- 等待人员入座
    begin = "begin",
    xhz = "xhz", -- 选执黑子方
    xq = "xq", -- 下棋

    settlement="settlement",
    gameover="gameover",
}

local function MsgDispatch(proto_name, data)
    local func = lister[proto_name]
    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
        return
    end

    if data.status_no then
        if proto_name ~= "fg_status_info" and proto_name ~= "fg_all_info" then
            if m_data.status_no + 1 ~= data.status_no and m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no

                print("<color=red>proto_name = " .. proto_name .. "</color>")
                --发送状态编码错误事件
                Event.Brocast("model_fg_statusNo_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no
    end
    func(proto_name, data)
end

local function MakeLister()
	lister = {}
	lister["wzq_place_chess_response"] = GobangModel.handle_place_chess_response

    --模式
    lister["fg_all_info"] = this.on_fg_all_info
    lister["fg_enter_room_msg"] = this.on_fg_enter_room_msg
    lister["fg_join_msg"] = this.on_fg_join_msg
    lister["fg_leave_msg"] = this.on_fg_leave_msg
    lister["fg_gameover_msg"] = this.on_fg_gameover_msg
    lister["fg_score_change_msg"] = this.on_fg_score_change_msg
    lister["fg_auto_cancel_signup_msg"] = this.on_fg_auto_cancel_signup_msg
    lister["fg_auto_quit_game_msg"] = this.on_fg_auto_quit_game_msg
    lister["fg_ready_msg"] = this.on_fg_ready_msg
    lister["fg_activity_data_msg"] = this.on_fg_activity_data_msg
    lister["nor_gobang_nor_game_bankrupt_msg"] = this.on_nor_gobang_nor_game_bankrupt_msg

    --response
    lister["fg_signup_response"] = this.on_fg_signup_response
    lister["fg_switch_game_response"] = this.on_fg_switch_game_response
    lister["fg_cancel_signup_response"] = this.on_fg_cancel_signup_response
    lister["fg_replay_game_response"] = this.on_fg_replay_game_response
    lister["fg_quit_game_response"] = this.on_fg_quit_game_response
    lister["fg_huanzhuo_response"] = this.on_fg_huanzhuo_response
    lister["fg_ready_response"] = this.on_fg_ready_response

    --玩法
    lister["nor_gobang_nor_ready_msg"] = this.on_nor_gobang_nor_ready_msg
    lister["nor_gobang_nor_begin_msg"] = this.on_nor_gobang_nor_begin_msg
    lister["nor_gobang_nor_action_msg"] = this.on_nor_gobang_nor_action_msg
    lister["nor_gobang_nor_permit_msg"] = this.on_nor_gobang_nor_permit_msg
    lister["nor_gobang_nor_xhz_msg"] = this.on_nor_gobang_nor_xhz_msg
    lister["nor_gobang_nor_settlement_msg"] = this.on_nor_gobang_nor_settlement_msg
    lister["nor_gobang_nor_xiaqi_response"] = this.on_nor_gobang_nor_xiaqi_response
    lister["nor_gobang_nor_score_change_msg"] = this.on_nor_gobang_nor_score_change_msg

    --资产改变
    lister["AssetChange"] = this.AssetChange
end

local function AddMsgListener(lister)
	for proto_name, _ in pairs(lister) do
        if proto_name == "AssetChange" then
            Event.AddListener(proto_name, _)
        else
            Event.AddListener(proto_name, MsgDispatch)
        end
    end
end

local function RemoveMsgListener(lister)
    for proto_name, _ in pairs(lister) do
        if proto_name == "AssetChange" then
            Event.RemoveListener(proto_name, _)
        else
            Event.RemoveListener(proto_name, MsgDispatch)
        end
    end
end

local function InitMatchData(gameID)
    if not GobangModel.baseData then
        GobangModel.baseData = {}
    end

    GobangModel.data = {
        --游戏名
        gameName = nil,
        --0是练习场  1是自由场
        gameModel=nil,
        --房间数据信息
        roomId = nil, --当前房间ID

        --当前游戏状态（详细说明见文件顶部注释：状态表status）
        status = nil,
        --在以上信息相同时，判定具体的细节状态；+1递增
        status_no = 0, 
        --倒计时
        countdown = 0,
        --倒计时上限
        countdown_max = 30,
        --当前的权限拥有人
        cur_p = nil, 
        --当前局数
        cur_race = nil,
        -- 总局数
        sumRace = nil,
        --我的座位号
        seat_num = nil,
        -- 玩家的操作
        actionList = {},
        -- 底分
        init_stake=nil,
        -- 玩家信息
        playerInfo ={},
        settlement_players_info=nil,
        -- 对局时间
        p_race_times = {},
        -- 黑子玩家
        first_seat = 0,

        score_change_list = {},
        activity_data = nil,
        game_bankrupt = nil,
        yingfengding = nil,
    }
    m_data = GobangModel.data
    m_data.chessboard = {}
    for i = 1, MAX_GRID do
        m_data.chessboard[i] = {}
        for j = 1, MAX_GRID do
            m_data.chessboard[i][j] = 0
        end
    end
end
local function InitMatchStatusData(status)
    m_data.status = status
    m_data.countdown = 0
    m_data.countdown_max = 30
    m_data.cur_p = nil 
    m_data.actionList = {}
    for i=1,2 do
        m_data.playerInfo=m_data.playerInfo or {}
        m_data.playerInfo[i]=m_data.playerInfo[i] or {}
    end
    m_data.settlement_players_info=nil
    m_data.first_seat = 0
    m_data.p_race_times = {}
    m_data.score_change_list = {}
    m_data.game_bankrupt = nil
    m_data.yingfengding = nil
    m_data.chessboard = {}
    for i = 1, MAX_GRID do
        m_data.chessboard[i] = {}
        for j = 1, MAX_GRID do
            m_data.chessboard[i][j] = 0
        end
    end
end

function GobangModel.InitGameData()
    if not m_data then
        print("<color=red>InitGameData m_data nil</color>")
        return
    end
    print("<color=red>InitGameData m_data 重置</color>")
    m_data.countdown = 0
    m_data.cur_p = nil
    m_data.actionList = {}
    m_data.first_seat = 0
    m_data.p_race_times = {}    
    m_data.settlement_info=nil
    m_data.glory_score_count = nil
    m_data.glory_score_change = nil
    m_data.ls_count = 1
    m_data.settlement_players_info=nil
    m_data.chessboard = {}
    for i = 1, MAX_GRID do
        m_data.chessboard[i] = {}
        for j = 1, MAX_GRID do
            m_data.chessboard[i][j] = 0
        end
    end
end
function GobangModel.Init()
	this = GobangModel
    InitMatchData()
	MakeLister()
	AddMsgListener(lister)

	return this
end

function GobangModel.Exit()

	RemoveMsgListener(lister)
	chessboard = {}

	this = nil
end

function GobangModel.GetChessboard()
	return m_data.chessboard
end

--function GobangModel.handle_place_chess_response(msg, result)
function GobangModel.handle_place_chess_response(result)
	dump(result,"<color=yellow>------------  handle_place_chess_response</color>")
	if result.result ~= 0 then
		print("[WZQ] handle_place_chess_response exception:" .. result.result)
		HintPanel.ErrorMsg(result.result)
		Event.Brocast("model_wzq_exception", result.result)
		return
	end

	local data = result.data
	local x = data.x
	local y = data.y
	local c = data.color
	if not chessboard[x] then chessboard[x] = {} end
	chessboard[x][y] = c

	Event.Brocast("model_wzq_place_chess", result.data)
end

--资产改变
function GobangModel.AssetChange(proto_name, data)
    if m_data and m_data.seat_num then
        data = {score = MainModel.UserInfo.jing_bi}
        dump(data, "<color=yellow>AssetChange</color>")
        m_data.score = data.score
        if m_data.playerInfo[m_data.seat_num] and m_data.playerInfo[m_data.seat_num].base then
            m_data.playerInfo[m_data.seat_num].base.score = data.score
        end

        Event.Brocast("model_fg_score_change_msg")
    end
end

----------------------------------------------------------------------------------------- new
--所有数据
function GobangModel.on_fg_all_info(proto_name, data)
    dump(data, "<color=yellow>on_fg_all_info</color>")
    if data.status_no == -1 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        GobangLogic.change_panel( GobangLogic.panelNameMap.hall )
    else
        local s = data
        if s then
            m_data.model_status = s.status            
            GobangModel.game_type = s.game_type
            m_data.countdown = s.countdown
            GobangModel.baseData.room_rent = s.room_rent

            if m_data.model_status == GobangModel.Model_Status.wait_table and m_data.countdown > 0 then
                m_data.countdown = m_data.countdown + 1
            end

            if s.game_kaiguan then
                kaiguan = basefunc.decode_kaiguan(s.game_type , s.game_kaiguan)
            end
            if s.game_multi then
                multi = basefunc.decode_multi(s.game_type , s.game_multi)
            end
        end

        algorithm = gobang_algorithm.New(MAX_GRID, MAX_GRID)

        m_data.playerInfo=m_data.playerInfo or {}
        for i=1, GobangModel.maxPlayerNumber do
            m_data.playerInfo[i] = m_data.playerInfo[i] or {}
            m_data.playerInfo[i].base = nil
        end

        s = data.players_info
        if s then
            for k, v in pairs(s) do
                m_data.playerInfo[v.seat_num].base=v
                if v.id == MainModel.UserInfo.user_id then
                    m_data.seat_num = v.seat_num
                end
            end
        end

        s = data.settlement_players_info
        if s then
            for k, v in pairs(s) do
                m_data.playerInfo[v.seat_num].settlement_base=v
            end
        end
        
        s = data.nor_gobang_nor_status_info
        if m_data.seat_num and s then
            m_data.status=s.status
            m_data.countdown=s.countdown
            if not m_data.countdown then
                m_data.countdown = 0
            end
	    m_data.countdown_max = s.countdown_max
            m_data.p_race_time_max = s.p_race_time_max
            m_data.is_over = s.is_over
            m_data.cur_p=s.cur_p
            m_data.cur_race=s.cur_race
            m_data.ready=s.ready
            if not m_data.ready then
                m_data.ready = {0,0}
            end
            m_data.init_stake = s.init_stake
            m_data.init_rate = s.init_rate
            m_data.race_count = s.race_count
            m_data.p_race_times = s.p_race_times
            m_data.first_seat = s.first_seat

            if s.settlement_info then
                m_data.settlement_info=s.settlement_info
                if s.settlement_info.yingfengding then
                    m_data.yingfengding = s.settlement_info.yingfengding
                end
            end
            
            m_data.actionList = s.act_list
            if s.act_list then
                for k,v in ipairs(s.act_list) do
                    local chess = gobang_algorithm.parse_pos(v.pos)
                    m_data.chessboard[chess.x][chess.y] = chess.c
                end
            end

            if s.game_bankrupt then
                m_data.game_bankrupt = s.game_bankrupt
            end

            m_data.score_change_list = s.score_change_list
        end

        s = data.room_info
        if s then
            m_data.init_stake = s.init_stake
            m_data.init_rate = s.init_rate
            GobangModel.baseData.game_id = s.game_id
        end

        m_data.glory_score_count = data.glory_score_count
        m_data.glory_score_change = data.glory_score_change

        if data.activity_data then
            m_data.activity_data = data.activity_data
            GobangModel.GetLSCount(data.activity_data)
        else
            m_data.ls_count = 1
        end
    end

    if m_data then
        dump(nil, "<color=green>发送活动消息</color>")
        Event.Brocast("activity_fg_all_info",{activity_data = m_data.activity_data,game_type = GobangModel.game_type,game_id = GobangModel.baseData.game_id,model_status = m_data.model_status,status = m_data.status})
    end
    Event.Brocast("model_fg_all_info")
end


--进入房间
function GobangModel.on_fg_enter_room_msg(proto_name, data)
    dump(data, "<color=yellow>on_fg_enter_room_msg</color>")
    m_data.model_status = GobangModel.Model_Status.gaming
    m_data.status = GobangModel.Status.wait_p
    InitMatchStatusData(m_data.status)

    for k, v in pairs(data.players_info) do
        m_data.playerInfo[v.seat_num].base = v
        if v.id == MainModel.UserInfo.user_id then
            m_data.seat_num = v.seat_num
        end
    end

    m_data.race = 1

    Event.Brocast("model_fg_enter_room_msg")
    Event.Brocast("activity_fg_enter_room_msg")
end

--其他玩家进入游戏
function GobangModel.on_fg_join_msg(proto_name, data)
    dump(data, "<color=yellow>on_fg_join_msg</color>")

    local seatno = data.player_info.seat_num
    m_data.playerInfo[seatno]= m_data.playerInfo[seatno] or {}
    m_data.playerInfo[seatno].base = data.player_info

    Event.Brocast("model_fg_join_msg",  data.player_info.seat_num )
    Event.Brocast("activity_fg_join_msg", data.player_info.seat_num)
end

--其他玩家离开游戏
function GobangModel.on_fg_leave_msg(proto_name, data)
    dump(data, "<color=yellow>on_fg_leave_msg</color>")
    m_data.playerInfo[data.seat_num].base = nil

    Event.Brocast("model_fg_leave_msg", data.seat_num)
    Event.Brocast("activity_fg_leave_msg", data.seat_num)
end

--比赛结束
function GobangModel.on_fg_gameover_msg(proto_name, data)
    dump(data, "<color=red>比赛结束</color>")
    m_data.model_status = GobangModel.Model_Status.gameover
    for k, v in pairs(m_data.playerInfo) do
        if v.base then
            v.base.ready = 0
        end
    end

    m_data.glory_score_count = data.glory_score_count
    m_data.glory_score_change = data.glory_score_change

    Event.Brocast("model_fg_gameover_msg")
    Event.Brocast("activity_fg_gameover_msg")
end


--分数改变
function GobangModel.on_fg_score_change_msg(proto_name, data)
    dump(data, "<color=yellow>分数改变</color>")
    if m_data.playerInfo[m_data.seat_num] and m_data.playerInfo[m_data.seat_num].base then
        m_data.playerInfo[m_data.seat_num].base.score = data.score
    end
    Event.Brocast("model_fg_score_change_msg")
end

---- 自动取消报名
function GobangModel.on_fg_auto_cancel_signup_msg(proto_name, data)
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_cancel_signup_msg")
end

---- 自动退出游戏报名
function GobangModel.on_fg_auto_quit_game_msg(proto_name, data)
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_quit_game_msg")
end

---- 准备
function GobangModel.on_fg_ready_msg(proto_name, data)
    local seatno = data.seat_num
    if m_data.playerInfo[seatno] and m_data.playerInfo[seatno].base then
        m_data.playerInfo[seatno].base.ready = 1
        Event.Brocast("model_fg_ready_msg", seatno)
        Event.Brocast("activity_fg_ready_msg", seatno)
    end
end

-------------------------------------------------------------------response
--比赛报名结果
function GobangModel.on_fg_signup_response(_, data)
    dump(data, "<color=yellow>on_fg_signup_response</color>")
    if data.result == 0 then
        GobangModel.InitGameData()
        m_data.model_status = GobangModel.Model_Status.wait_table
        m_data.status = nil
        if m_data.playerInfo then
            for k, v in ipairs(m_data.playerInfo) do
                v.base = nil
            end
        end
        --0-不可以取消  1-可以取消
        m_data.is_cancel_signup = data.is_cancel_signup
        m_data.countdown = data.cancel_signup_cd

        GobangModel.game_type = data.game_type

        MainLogic.EnterGame()
        Event.Brocast("model_fg_signup_response", data.result)
    else
        Event.Brocast("model_fg_signup_fail_response", data.result)
    end
end
function GobangModel.on_fg_switch_game_response(proto_name, data)
    GobangModel.on_fg_signup_response(proto_name, data)
end

function GobangModel.on_fg_cancel_signup_response(_, data)
    if data.result == 0 then
        m_data.model_status = nil
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        Event.Brocast("model_fg_cancel_signup_response", data.result)
    else
        Event.Brocast("model_nor_mg_cancel_signup_fail_response", data.result)
    end
end


--再玩一把
function GobangModel.on_fg_replay_game_response(proto_name, data)
    dump(data, "<color=red>再玩一把</color>")
    if data.result == 0 then
        GobangModel.on_fg_signup_response(proto_name, data)
    else
        if data.result == 1022 then
            --钻石不足
            HintPanel.Create(
                3,
                "您鲸币不足，请购买足够鲸币",
                function()
                    PayPanel.Create(GOODS_TYPE.jing_bi)
                end
            )
        else
            local msg = errorCode[data.result] or ("错误：" .. data.result)
            HintPanel.Create(
                1,
                msg,
                function()
                    --清除数据
                    InitMatchData()
                    MainLogic.ExitGame()
                    GobangLogic.change_panel( GobangLogic.panelNameMap.hall )
                end
            )
        end
    end
end

--退出游戏
function GobangModel.on_fg_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>on_fg_quit_game_response</color>")
    if data.result == 0 then
        InitMatchData()
        MainLogic.ExitGame()
        GobangLogic.change_panel( GobangLogic.panelNameMap.hall )
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--换桌
function GobangModel.on_fg_huanzhuo_response(proto_name, data)
    dump(data, "<color=yellow>on_fg_huanzhuo_response</color>")
    Event.Brocast("fg_huanzhuo_response_code", data.result)
    if data.result == 0 then
        GobangModel.InitGameData()
        m_data.model_status = GobangModel.Model_Status.wait_table
        m_data.status = nil

        for k, v in pairs(m_data.playerInfo) do
            v.base = nil
        end
        Event.Brocast("model_fg_huanzhuo_response")
    end
end

-- 准备
function GobangModel.on_fg_ready_response(_, data)
    dump(data, "<color=yellow>on_fg_ready_response</color>")
    Event.Brocast("fg_ready_response_code", data.result)
    if data.result == 0 then
        GobangModel.InitGameData()
        m_data.model_status = GobangModel.Model_Status.wait_begin
        m_data.status = nil
        m_data.playerInfo[m_data.seat_num].base.ready = 1
        Event.Brocast("model_fg_ready_response")
    end
end


function GobangModel.on_nor_gobang_nor_ready_msg(proto_name, data)
    print("<color=red>WWWWWWWWWWWWWWWW on_nor_gobang_nor_ready_msg</color>")
    dump(data)
end
-- 开始游戏
function GobangModel.on_nor_gobang_nor_begin_msg(proto_name, data)
    dump(data, "<color=red>开始游戏</color>")
    m_data.model_status = GobangModel.Model_Status.gaming
    m_data.status = GobangModel.Status.begin
    m_data.race = data.cur_race
    m_data.p_race_times = data.p_race_times
    m_data.countdown_max = data.countdown_max
    m_data.p_race_time_max = data.p_race_time_max

    for k,v in ipairs(m_data.playerInfo) do
        v.base.ready = 0
    end
    Event.Brocast("model_nor_gobang_nor_begin_msg")
end

function GobangModel.on_nor_gobang_nor_action_msg(proto_name, data)
    dump(data, "玩家的操作")
    m_data.actionList[#m_data.actionList + 1] = data.action
    local caozuo = data.action.type
    if caozuo == "xq" then
        m_data.p_race_times[data.action.p] = data.action.race_time

        local chess = gobang_algorithm.parse_pos(data.action.pos)
        m_data.chessboard[chess.x][chess.y] = chess.c

        Event.Brocast("model_wzq_place_chess", chess)
    else
        Event.Brocast("model_nor_gobang_nor_action_msg", data.action)
    end
end
-- 权限
function GobangModel.on_nor_gobang_nor_permit_msg(proto_name, data)
    dump(data, "权限")
    m_data.cur_p = data.cur_p
    m_data.status = data.status
    m_data.countdown = data.countdown
    Event.Brocast("model_nor_gobang_nor_permit_msg", data)
end

-- 选执黑方
function GobangModel.on_nor_gobang_nor_xhz_msg(proto_name, data)
    dump(data, "<color=red>选执黑方</color>")
    m_data.first_seat = data.first_seat
    Event.Brocast("model_nor_gobang_nor_xhz_msg", data.first_seat )
end

-- 结算
function GobangModel.on_nor_gobang_nor_settlement_msg(proto_name, data)
    dump(data, "<color=red>结算</color>")
    m_data.status= GobangModel.Status.settlement
    m_data.settlement_info = data.settlement_info
    m_data.is_over = data.is_over

    for k,v in ipairs(m_data.settlement_info) do
         m_data.playerInfo[v.seat_num].settlement_base = m_data.playerInfo[v.seat_num].base
    end

    if data.score_change_list then
        m_data.score_change_list = data.score_change_list
    end

    if data.settlement_info.yingfengding then
        m_data.yingfengding = data.settlement_info.yingfengding
    end
    
    Event.Brocast("model_nor_gobang_nor_settlement_msg")
end

function GobangModel.on_nor_gobang_nor_xiaqi_response(_,data)
    dump(data, "<color=yellow>on_nor_gobang_nor_xiaqi_response</color>")
    if data.result == 0 then
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function GobangModel.on_nor_gobang_nor_score_change_msg(_,data)
    dump(data, "<color=yellow>on_nor_gobang_nor_score_change_msg</color>")
    for k,v in ipairs(data.data) do
        if m_data.seat_num ~= v.cur_p then
            if m_data.playerInfo and  m_data.playerInfo[v.cur_p] and m_data.playerInfo[v.cur_p].base then
                m_data.playerInfo[v.cur_p].base.score = m_data.playerInfo[v.cur_p].base.score + v.score
            end
        end
    end
    Event.Brocast("model_nor_gobang_nor_score_change_msg", data)
end

function GobangModel.on_fg_activity_data_msg(proto_name, data)
    dump(data, "<color=yellow>-------------------on_fg_activity_data_msg->"..proto_name.."</color>")
    if data.activity_data then
        m_data.activity_data = data.activity_data
        GobangModel.GetLSCount(data.activity_data)
    else
        m_data.ls_count = 1
    end

    --天降财神
    if m_data and m_data.activity_data then
        local m_ad = {}
        for i,v in ipairs(m_data.activity_data) do
            m_ad[v.key] = v.value
        end
        if m_ad.activity_id == ActivityType.TianJiangCaiShen then
            if m_ad.cs_seat then
                Event.Brocast("activity_fg_activity_data_msg", data)
                Event.Brocast("activity_fg_all_info",{activity_data = m_data.activity_data,game_type = GobangModel.game_type,game_id = GobangModel.baseData.game_id,model_status = m_data.model_status,status = m_data.status})
                if not m_ad.cs_is_win then
                    --游戏开始时的数据更新
                    Event.Brocast("activity_nor_begin_msg")
                else
                    --游戏结算时的数据更新
                    Event.Brocast("activity_nor_settlement_msg")
                end
            end
        else
            Event.Brocast("activity_fg_activity_data_msg", data)
        end
    end
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
function GobangModel.hz_call()
    Network.SendRequest("fg_huanzhuo", nil, "请求换桌")
end
function GobangModel.zb_call()
    Network.SendRequest("fg_ready", nil, "请求准备")
end
function GobangModel.hintCondition(call)
    local game_id = GobangModel.baseData.game_id
    local ui_config = GameFreeModel.GetGameIDToConfig(game_id)
    PayFastFreePanel.Create(ui_config, call)
end
function GobangModel.checkCondition(call)
    local game_id = GobangModel.baseData.game_id
    local ss = GameFreeModel.IsAgainRoomEnter(game_id)
    if ss == 1 then
        GobangModel.hintCondition(call)
        return false
    elseif ss == 2 then
        local _,data = GameFreeModel.CheckRapidBeginGameID ()
        local pre = HintPanel.Create(2, "您太富有了，更高级的场次才适合您！", function ()
            Network.SendRequest("fg_switch_game", {id = data.game_id}, "正在报名")
        end)
        pre:SetButtonText("取消", "前往高级场")
        return false
    end
    return true
end
-- 换桌检查
function GobangModel.HZCheck()
    if GobangModel.checkCondition(GobangModel.hz_call) then
        GobangModel.hz_call()
    end
end
-- 准备检查
function GobangModel.ZBCheck()
    if GobangModel.checkCondition(GobangModel.zb_call) then
        GobangModel.zb_call()
    end
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- 返回自己的座位号
function GobangModel.GetPlayerSeat()
    if m_data.seat_num then
        return m_data.seat_num
    else
        return 1
    end
end

-- 返回自己的UI位置
function GobangModel.GetPlayerUIPos()
    return GobangModel.GetSeatnoToPos(m_data.seat_num)
end

-- 根据座位号获取玩家UI位置
function GobangModel.GetSeatnoToPos(seatno)
    local seftSeatno = GobangModel.GetPlayerSeat()
    return (seatno - seftSeatno + GobangModel.maxPlayerNumber) % GobangModel.maxPlayerNumber + 1
end

-- 根据UI位置获取玩家座位号
function GobangModel.GetPosToSeatno(uiPos)
    local seftSeatno = GobangModel.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % GobangModel.maxPlayerNumber + 1
end

-- 根据UI位置获取玩家数据
function GobangModel.GetPosToPlayer(uiPos)
    local seatno = GobangModel.GetPosToSeatno(uiPos)
    return m_data.playerInfo[seatno]
end

-- 根据座位号获取玩家数据
function GobangModel.GetSeatnoToPlayer(seatno)
    return m_data.playerInfo[seatno]
end

-- 是否是自己 玩家自己的UI位置在1号位
function GobangModel.IsPlayerSelf(uiPos)
    return uiPos == 1
end

-- 返回该座位号是否是黑子
function GobangModel.IsBlackBySeatno(seatno)
    if m_data.first_seat and seatno == m_data.first_seat then
        return true
    end
end

-- 发送下棋消息
function GobangModel.SendPlaceChess(x, y)
    local c = 2
    if GobangModel.IsBlackBySeatno(m_data.seat_num) then
        c =  1
    end
    local pos = gobang_algorithm.pack_pos({x=x,y=y,c=c})
    Network.SendRequest("nor_gobang_nor_xiaqi", {pos=pos}, "发送请求")
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function GobangModel.GetAnimChatShowPos (id)
    if GobangModel.data and GobangModel.data.playerInfo then
        for k,v in ipairs(GobangModel.data.playerInfo) do
            if v.base and tostring(v.base.id) == tostring(id) then
                local uiPos = GobangModel.GetSeatnoToPos (v.base.seat_num)
                return uiPos, false, true
            end
        end             
    end
    dump(id, "<color=red>发送者ID</color>")
    dump(GobangModel.data.playerInfo, "<color=red>玩家列表</color>")
    return 1, false, true
end

function GobangModel.CheckWin(x, y)
	return algorithm:check_win(x, y, GobangModel.GetChessboard())
end

function GobangModel.ChangeWaitStart(statues)
    GobangModel.isWaitStart = statues
end
