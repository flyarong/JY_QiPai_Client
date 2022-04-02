--[[
正常消息是指除断线重连以外的消息
]]
local nDdzFunc=require "Game.normal_ddz_common.Lua.normal_ddz_func_lib"

million_status = {
    wait_begin = "wait_begin", --wait_begin 报名成功，收到dbwg_signup_response进入状态
    wait_table = "wait_table", --wait_table:等待分配桌子，收到dbwg_begin_msg进入状态
    wait_join="wait_join",
    wait_p = "wait_p", --wait_p：等待人员入座，收到dbwg_join_room_respone进入状态
    fp = "fp", --fp： 发牌， 收到dbwg_pai_msg进入状态
    jdz = "jdz", --jdz： 叫地主， 收到dbwg_permit_msg，status进入状态，退出也是通过status判定
    set_dz = "set_dz", --set_dz： 设置地主，
    jiabei = "jiabei", --jiabei： 加倍
    cp = "cp", --cp： 出牌
    settlement = "settlement", --settlement： 结算
    report = "report", --report： 上报战果
    gameover="gameover",--游戏结束
    auto = "auto",   --玩家进入托管状态
    promoted = "promoted", --玩家进入晋级
    wait_fuhuo = "wait_fuhuo", --等待晋级

}

DdzMillionModel={}

DdzMillionRankModel=  {
    rank_list = {},
    my_rank = {},
    rank_date = 0,
    rank_issue = 0,
    match_issue = 0,
}

local this 
local lister
local m_data
local update
local updateDt=0.1

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister={}
    lister["dbwg_begin_msg"] = this.on_dbwg_begin_msg
    lister["dbwg_enter_room_msg"] = this.on_dbwg_enter_room_msg
    lister["dbwg_join_msg"] = this.on_dbwg_join_msg
    lister["dbwg_pai_msg"] = this.on_dbwg_pai_msg
    lister["dbwg_permit_msg"] = this.on_dbwg_permit_msg
    lister["dbwg_action_msg"] = this.on_dbwg_action_msg
    lister["dbwg_dizhu_msg"] = this.on_dbwg_dizhu_msg
    lister["dbwg_auto_msg"] = this.on_dbwg_auto_msg

    lister["dbwg_ddz_settlement_msg"] = this.on_dbwg_ddz_settlement_msg
    lister["dbwg_new_game_msg"] = this.on_dbwg_new_game_msg
    lister["dbwg_grades_change_msg"] = this.on_dbwg_grades_change_msg
    lister["dbwg_gameover_msg"] = this.on_dbwg_gameover_msg
    lister["dbwg_wait_fuhuo_msg"] = this.on_dbwg_wait_fuhuo_msg
    lister["dbwg_promoted_msg"] = this.on_dbwg_promoted_msg
    lister["dbwg_discard_msg"] = this.on_dbwg_discard_msg
    lister["dbwg_jiabeifinshani_msg"] = this.on_dbwg_jiabeifinshani_msg


    lister["dbwg_start_again_msg"] = this.on_dbwg_start_again_msg

    lister["dbwg_status_info"] = this.on_dbwg_status_info
    lister["dbwg_all_info"] = this.on_dbwg_all_info

    --response
    lister["dbwg_req_game_list_response"] = this.on_dbwg_req_game_list_response
    lister["dbwg_signup_response"] = this.on_dbwg_signup_response
    lister["dbwg_cancel_signup_response"] = this.on_dbwg_cancel_signup_response

    lister["dbwg_quit_game_response"] = this.on_dbwg_quit_game_response

    lister["dbwg_bonus_rank_list_response"] = this.on_dbwg_bonus_rank_list_response
    --

end

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
        if proto_name~="dbwg_status_info" and  proto_name~="dbwg_all_info" then
            if m_data.status_no+1 ~= data.status_no and  m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no

                print("<color=red>proto_name = " .. proto_name .. "</color>")
                --发送状态编码错误事件
                Event.Brocast("dbwgModel_dbwg_statusNo_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no 
    end
    func(proto_name, data)
    
end
--注册斗地主正常逻辑的消息事件
function DdzMillionModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end


--删除斗地主正常逻辑的消息事件
function DdzMillionModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
end
function DdzMillionModel.Update()
    if m_data then
        if m_data.countdown and m_data.countdown>0 then
            m_data.countdown=m_data.countdown-updateDt
            if m_data.countdown<0 then
                m_data.countdown=0
            end
        end
        if this.dbwg_match_list_countdwon and this.dbwg_match_list_countdwon>0 then
            this.dbwg_match_list_countdwon=this.dbwg_match_list_countdwon-updateDt
            if this.dbwg_match_list_countdwon<=0 then
                this.dbwg_match_list_countdwon=nil
                 this.dbwg_match_list=nil
            end
        end
    end
end
local function InitMatchData()
    DdzMillionModel.data={
                        --dbwg_match_info ****
                        --游戏名
                        name=nil,
                        --总参与人数
                        total_players =nil,


                        --dbwg_room_info****
                        --房间数据信息
                        room_id = nil, --当前房间ID
                        table_num = nil, --当前房间中桌子位置


                        --当前游戏状态（详细说明见文件顶部注释：斗地主状态表status）
                        status = nil, 
                        --在以上信息相同时，判定具体的细节状态；+1递增
                        status_no = 0, 
                        --倒计时
                        countdown=0,
                        --当前的权限拥有人
                        cur_p = nil, 
                        --我的牌列表
                        my_pai_list =nil,
                        --每个人剩余的牌数量
                        remain_pai_amount=nil,
                        --我的倍数
                        my_rate =1,
                        --玩家的托管状态
                        auto_status={},
                        --当前已报名人数
                        signup_num =nil,
                        --当前轮数
                        round =nil,
                        --当前局数
                        race =nil,
                        --我的座位号
                        seat_num =nil,
                        --地主座位号
                        dizhu =nil,
                        --地主牌
                        dz_pai =nil,
                        grades=nil,
                        rank=nil,
                        --玩家操作列表
                        action_list ={},
                        
                        --dbwg_players_info***
                        players_info = {}, --当前房间中玩家的信息(key=seat_num, value=玩家基础信息)

                        
                        --dbwg_ddz_settlement_info*****
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
                        dbwg_ddz_settlement_info =nil,     

                        --dbwg_final_result ****
                            --rank 
                            --reward (*dbwg_reward)
                        dbwg_final_result=nil,    
                        --客户端辅助数据***********
                        --当前的地主分数
                        base_rate=0,
                        --记牌器
                        jipaiqi=nil,
                        --比赛轮数信息
                        round_info = nil,
                        --比赛信息
                        match_info = nil,
                        --#当前人数
                        player_num = 0,
                        --至少需要的人数
                        min_player = 0,
    }
    m_data=DdzMillionModel.data
end
local function InitMatchStatusData(status)

    m_data.status = status
    --倒计时
    m_data.countdown=0
    --当前的权限拥有人
    m_data.cur_p = nil 
    --我的牌列表
    m_data.my_pai_list =nil
    --每个人剩余的牌数量
    m_data.remain_pai_amount=nil
    --我的倍数
    local init_rate=1
    if m_data.round_info then
        init_rate=m_data.round_info.init_rate
    end
    m_data.my_rate = init_rate or 1
    --玩家的托管状态
    m_data.auto_status={}
    --玩家操作列表
    m_data.action_list ={}
    --当前的地主分数
    m_data.base_rate=0
    --记牌器
    m_data.jipaiqi=nil
      --地主座位号
    m_data.dizhu =nil
    --地主牌
    m_data.dz_pai =nil

    m_data.dbwg_ddz_settlement_info =nil

     --#当前人数
     player_num = 0
     --至少需要的人数
     min_player = 0

end
local function InitMatchRoomData(status)
    InitMatchStatusData(status)
    m_data.room_id = nil
    m_data.table_num = nil
    m_data.players_info={}
end
local function calDizhuBaserate()
    --记录本局地主底分
    if m_data then
         m_data.base_rate=0
        if m_data.action_list then
            for _,v in pairs(m_data.action_list) do
                if  v.type == 100 and v.rate > m_data.base_rate then
                    m_data.base_rate = v.rate
                end
            end
        end
    end
end
function DdzMillionModel.Init()
    InitMatchData()
    this=DdzMillionModel
    this.dbwg_match_list=nil
    --收到dbwg_match_list的时间
    this.dbwg_match_list_time=nil
    -- this.InitDdzMillionUIConfig()
    MakeLister()
    this.AddMsgListener()

    update=Timer.New(DdzMillionModel.Update,updateDt,-1,true)
    update:Start()

    return this
end
function DdzMillionModel.Exit()
    DdzMillionModel.RemoveMsgListener()
    update:Stop()
    update=nil
    this=nil
    lister=nil
    m_data=nil
    DdzMillionModel.data=nil
    DdzMillionModel.dbwg_match_list=nil
    DdzMillionModel.dbwg_match_list_time=nil
end
function DdzMillionModel.DdzMillionLogic()
    
end

function DdzMillionModel.on_dbwg_bonus_rank_list_response(_,data)
    if data.result==0 then
        DdzMillionRankModel.rank_list = data.rank_list
        DdzMillionRankModel.my_rank = data.my_rank
        DdzMillionRankModel.rank_date = data.date
        DdzMillionRankModel.rank_issue = data.issue
    end
    Event.Brocast("dbwgModel_dbwg_bonus_rank_list_response",data.result)
end

function DdzMillionModel.on_dbwg_req_game_list_response(_,data)
    if data.result==0 then
        this.dbwg_match_list=data.match_list_info
        DdzMillionRankModel.match_issue = data.match_list_info.issue
        --30秒后自动销毁
        this.dbwg_match_list_countdwon=3600
    end
    Event.Brocast("dbwgModel_dbwg_req_game_list_response",data.result)
end

--1.比赛报名结果
function DdzMillionModel.on_dbwg_signup_response(_, data)
    if data.result == 0 then
        m_data.status = million_status.wait_begin
        m_data.match_info=data.match_info

        MainLogic.EnterGame()
        Event.Brocast("dbwgModel_dbwg_signup_response",data.result)
    else
        Event.Brocast("dbwgModel_dbwg_signup_fail_response",data.result)
    end
     
end

function DdzMillionModel.on_dbwg_cancel_signup_response(_, data)
    if data.result==0 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        Event.Brocast("dbwgModel_dbwg_cancel_signup_response",data.result)
    else
        Event.Brocast("dbwgModel_dbwg_cancel_signup_fail_response",data.result)
    end
end


--退出游戏
function DdzMillionModel.on_dbwg_quit_game_response(proto_name,data)
    if data.result==0 then
        MainLogic.ExitGame()
        DdzMillionLogic.change_panel("DdzMillionHallPanel")
    else

    end
end

--2.比赛开始
function DdzMillionModel.on_dbwg_begin_msg(proto_name, data)
    m_data.status = million_status.wait_table
    Event.Brocast("dbwgModel_dbwg_begin_msg")
end

function DdzMillionModel.on_dbwg_enter_room_msg(proto_name, data)
    m_data.status = million_status.wait_p
    InitMatchStatusData(m_data.status)
    m_data.room_id=data.room_info.room_id
    m_data.table_num=data.room_info.t_num
    m_data.seat_num=data.room_info.seat_num

    m_data.seatNum={}
    m_data.s2cSeatNum={}
    nDdzFunc.transform_seat(m_data.seatNum,m_data.s2cSeatNum,m_data.seat_num)

    m_data.round_info = data.round_info
    m_data.my_rate= m_data.round_info.init_rate or 1
    m_data.race = 1
    m_data.grades = data.players_info.p_info[data.room_info.seat_num].grades
   
    if data.players_info then
        for k, v in pairs(data.players_info.p_info) do
            m_data.players_info[v.seat_num] = v
        end
    end
    Event.Brocast("dbwgModel_dbwg_enter_room_msg")
end

--其他玩家进入游戏
function DdzMillionModel.on_dbwg_join_msg(proto_name, data)
    m_data.players_info[data.player_info.seat_num]=data.player_info
    Event.Brocast("dbwgModel_dbwg_join_msg",data.player_info.seat_num)
end

--6.进入游戏的人数达到3人，自动发牌,游戏开始，人数满足要求，发牌开局
function DdzMillionModel.on_dbwg_pai_msg(proto_name, data)
    m_data.status=million_status.fp
    m_data.my_pai_list=data.my_pai_list
    table.sort(m_data.my_pai_list)
    m_data.remain_pai_amount=data.remain_pai_amount
    m_data.round=data.round
    m_data.race=data.race

    Event.Brocast("dbwgModel_dbwg_pai_msg")

end

--7.确认地主--
function DdzMillionModel.on_dbwg_dizhu_msg(proto_name, data)
    m_data.status = million_status.set_dz
    m_data.dizhu = data.dz_info.dizhu
    m_data.dz_pai = data.dz_info.dz_pai
    local seat_num = data.dz_info.dizhu
    m_data.remain_pai_amount[seat_num]=m_data.remain_pai_amount[seat_num]+#data.dz_info.dz_pai
    if seat_num==m_data.seat_num then
        for i=1,#data.dz_info.dz_pai do
            m_data.my_pai_list[#m_data.my_pai_list+1]=data.dz_info.dz_pai[i]
        end
        table.sort(m_data.my_pai_list)
        m_data.my_rate=m_data.my_rate*2
    end
    --初始化记牌器
    m_data.jipaiqi=nDdzFunc.getAllPaiCount()
    nDdzFunc.jipaiqi(m_data.my_pai_list,m_data.jipaiqi)
    Event.Brocast("dbwgModel_dbwg_dizhu_msg")
    
end

--8.权限信息轮询
function DdzMillionModel.on_dbwg_permit_msg(proto_name, data)
    m_data.status=data.status
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown=(data.countdown-0.5)
    if m_data.countdown<0 then
        m_data.countdown=0
    end
    m_data.cur_p=data.cur_p
    Event.Brocast("dbwgModel_dbwg_permit_msg")
end


--9.玩家操作
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
function DdzMillionModel.on_dbwg_action_msg(proto_name, data)
    m_data.action_list[#m_data.action_list+1]=data.action

    local act_type = data.action.type
    --注意可能是断线重连  此时相应的数据可能还没有初始化  所以一定要判断数据是否存在
    --更新玩家手上剩余扑克牌的数量
    if  m_data.remain_pai_amount and act_type < 100 and data.action.cp_list then
        m_data.remain_pai_amount[data.action.p] = m_data.remain_pai_amount[data.action.p] - #data.action.cp_list
        if data.action.p ~=m_data.seat_num then 
            nDdzFunc.jipaiqi(data.action.cp_list,m_data.jipaiqi)
        end
        --剔除牌
        if data.action.p==m_data.seat_num and m_data.my_pai_list then
            local hash={}
            for _,no in ipairs(data.action.cp_list) do
                hash[no]=true
            end
            local list={}
            for _,no in ipairs(m_data.my_pai_list) do
                if not hash[no] then
                    list[#list+1]=no
                end
            end
            m_data.my_pai_list=list
        end
    end

    --记录本局地主底分
    if m_data.base_rate and act_type == 100 and data.action.rate > m_data.base_rate then
        m_data.base_rate = data.action.rate
        m_data.my_rate = data.action.rate*m_data.round_info.init_rate
    end

    --炸弹翻倍
    if m_data.my_rate and (act_type == 13 or act_type == 14) then
        m_data.my_rate = m_data.my_rate * 2
    end
    Event.Brocast("dbwgModel_dbwg_action_msg")
end

--加倍完成消息
function DdzMillionModel.on_dbwg_jiabeifinshani_msg(proto_name, data)
    m_data.my_rate=data.my_rate
    Event.Brocast("dbwgModel_dbwg_jiabeifinshani_msg")
end

--托管--
function DdzMillionModel.on_dbwg_auto_msg(proto_name, data)
    m_data.auto_status[data.p] =  data.auto_status
    Event.Brocast("dbwgModel_dbwg_auto_msg",data.p)
end

--分数改变
function DdzMillionModel.on_dbwg_grades_change_msg(proto_name, data)
    m_data.grades=data.grades
    if m_data.players_info[m_data.seat_num] then
        m_data.players_info[m_data.seat_num].grades = data.grades
    end
    Event.Brocast("dbwgModel_dbwg_grades_change_msg")
end

--10.结算
function DdzMillionModel.on_dbwg_ddz_settlement_msg(proto_name, data)
    m_data.dbwg_ddz_settlement_info =data.settlement_info
    --更新玩家的分数
    for seat_num,p_scores in pairs(data.settlement_info.p_scores) do
        if seat_num ~= m_data.seat_num then
            m_data.players_info[seat_num].grades = m_data.players_info[seat_num].grades + p_scores
        end
    end
    if data.settlement_info.chuntian and data.settlement_info.chuntian>0 then
        m_data.my_rate=m_data.my_rate*2
    end
    Event.Brocast("dbwgModel_dbwg_ddz_settlement_msg")
end

--等待复活
function DdzMillionModel.on_dbwg_wait_fuhuo_msg(proto_name,data)
    m_data.fuhuo_count = data.fuhuo_count
    m_data.fuhuo_status = data.fuhuo_status
    m_data.countdown = data.countdown
    m_data.round_count = data.round_count
    m_data.round = data.round
    m_data.status=data.status
    Event.Brocast("dbwgModel_dbwg_wait_fuhuo_msg")
    InitMatchRoomData(data.status)
end

--晋级
function DdzMillionModel.on_dbwg_promoted_msg(proto_name,data)
    m_data.countdown = data.countdown
    m_data.status=data.status
    Event.Brocast("dbwgModel_dbwg_promoted_msg")
    InitMatchRoomData(data.status)
end

--11.打完一局重新发牌
function DdzMillionModel.on_dbwg_new_game_msg(proto_name, data)
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    m_data.race =data.race
    Event.Brocast("dbwgModel_dbwg_new_game_msg")
end
--14.都没有叫地主重新开始
function DdzMillionModel.on_dbwg_start_again_msg(proto_name, data)
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    Event.Brocast("dbwgModel_dbwg_start_again_msg")
end

--13.比赛结束，进入排名界面
function DdzMillionModel.on_dbwg_gameover_msg(proto_name, data)
    -- 
    m_data.status=million_status.gameover
    m_data.dbwg_final_result =data.final_result
    -- MainLogic.ExitGame()
    --登顶 0-失败  1-成功
    if data.final_result.is_win == 1 then
        --胜利奖金
        Event.Brocast("dbwgModel_dbwg_gameover_msg")
    else
        --安慰奖
        Event.Brocast("dbwgModel_dbwg_consolation_ward_msg")
    end
    
end

--比赛人数不够结束
function DdzMillionModel.on_dbwg_discard_msg(proto_name, data)
    m_data.player_num =data.player_num
    m_data.min_player =data.min_player
    Event.Brocast("dbwgModel_dbwg_discard_msg_response")
end

function DdzMillionModel.ClearMatchData()
    InitMatchData()
end

function DdzMillionModel.on_dbwg_status_info(proto_name, data)
    local s=data.status_info
    if s then
        m_data.status=s.status
        m_data.countdown=s.countdown
        m_data.cur_p=s.cur_p
        m_data.my_pai_list=s.my_pai_list
        if m_data.my_pai_list then
            table.sort(m_data.my_pai_list)
        end
        m_data.remain_pai_amount=s.remain_pai_amount
        m_data.my_rate=s.my_rate
        m_data.action_list=s.act_list
        m_data.auto_status=s.auto_status
        m_data.signup_num=s.signup_num
        m_data.round=s.round
        m_data.race=s.race
        m_data.seat_num=s.seat_num
        m_data.dizhu=s.dizhu
        m_data.dz_pai=s.dz_pai
        m_data.grades=s.grades
        m_data.rank=s.rank
        m_data.jipaiqi=s.jipaiqi
        m_data.match_info=s.match_info
        m_data.round_info=s.round_info
        calDizhuBaserate()
    end
    Event.Brocast("dbwgModel_dbwg_status_info")
end
function DdzMillionModel.on_dbwg_all_info(proto_name, data)
    if data.status_no==-1 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
    else
        local s=data.status_info
        if s then
            m_data.status=s.status
            m_data.countdown=s.countdown
            m_data.cur_p=s.cur_p
            m_data.my_pai_list=s.my_pai_list
            if m_data.my_pai_list then
                table.sort(m_data.my_pai_list)
            end
            m_data.remain_pai_amount=s.remain_pai_amount
            m_data.my_rate=s.my_rate
            m_data.action_list=s.act_list
            m_data.auto_status=s.auto_status
            m_data.signup_num=s.signup_num
            m_data.round=s.round
            m_data.race=s.race
            m_data.seat_num=s.seat_num

            m_data.seatNum={}
            m_data.s2cSeatNum={}
            nDdzFunc.transform_seat(m_data.seatNum,m_data.s2cSeatNum,m_data.seat_num)


            m_data.dizhu=s.dizhu
            m_data.dz_pai=s.dz_pai
            m_data.grades=s.grades
            m_data.rank=s.rank
            m_data.jipaiqi=s.jipaiqi
            m_data.round_info=s.round_info
            calDizhuBaserate()
            if  m_data.status==million_status.gameover then
                MainLogic.ExitGame()
            end
        end
        s=data.match_info
        if s then
            m_data.name=s.name
            m_data.match_info=s
        end

        s=data.room_info
        if s then
            m_data.room_id=s.room_id
            m_data.table_num=s.table_num
        end

        s=data.players_info
        if s then
            s=s.p_info
            for k,v in pairs(s) do
                m_data.players_info[v.seat_num]=v
            end
        end
        s=data.round_info
        if s then
           m_data.round_info = s
        end

        m_data.dbwg_ddz_settlement_info=data.settlement_info
        m_data.dbwg_final_result=data.final_result
    end

    Event.Brocast("dbwgModel_dbwg_all_info")
end
--获得我的权限数据
--[[
    type: 
        "jdz"  (数据为 几分以上)
        "jb"   ()
        “cp”   (数据为 是否必须出，有无够大的牌power)

        {type,is_must,power,jdz_min}
--]]
function DdzMillionModel.getMyPermitData()
    if m_data then
        if m_data.cur_p and m_data.cur_p==m_data.seat_num then
            if m_data.status==million_status.jdz then
                return {type=million_status.jdz,jdz_min=m_data.base_rate+1} 
            elseif m_data.status==million_status.jiabei then
                return {type=million_status.jiabei} 
            elseif m_data.status==million_status.cp then
                --判断是否为必须出牌
                local is_must=nDdzFunc.is_must_chupai(m_data.action_list)
                --判断是否有够大的牌
                local power=0
                if not is_must then
                    power=nDdzFunc.check_cp_capacity_by_pailist(m_data.action_list,m_data.my_pai_list)
                end
                return {type=million_status.cp,is_must=is_must,power=power}
            end
        end

    end
    return nil
end

-- 时间转换
function DdzMillionModel.ToTimeH2M2(time)
    return os.date("%H:%M", time)
end
function DdzMillionModel.ToTimeM2D2(time)
    return os.date("%m月%d日", time)
end
function DdzMillionModel.ToTimeM2S2(time)
    return os.date("%M:%S", time)
end

function DdzMillionModel.CheckRank()
    if DdzMillionRankModel.rank_date and DdzMillionRankModel.rank_issue then
        if  DdzMillionRankModel.match_issue then
            --游戏期数比排名期数大2，说明排名期数该更新
            if  DdzMillionRankModel.match_issue -  DdzMillionRankModel.rank_issue > 1 then
                return false
            else
                return true
            end
        end
         --游戏排名超过一天，排行榜需要更新
        if os.time() - DdzMillionRankModel.rank_date > 86400 then
            return false
        else
            return true
        end
    else
        return false
    end
end

local maxPlayerNumber = 3
-- 返回自己的座位号
function DdzMillionModel.GetPlayerSeat ()
    return m_data.seat_num
end
-- 返回自己的UI位置
function DdzMillionModel.GetPlayerUIPos ()
    return DdzMillionModel.GetSeatnoToPos (m_data.seat_num)
end
-- 根据座位号获取玩家UI位置
function DdzMillionModel.GetSeatnoToPos (seatno)
    local seftSeatno = DdzMillionModel.GetPlayerSeat()
    return (seatno - seftSeatno + maxPlayerNumber) % maxPlayerNumber + 1
end
-- 根据UI位置获取玩家座位号
function DdzMillionModel.GetPosToSeatno (uiPos)
    local seftSeatno = DdzMillionModel.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % maxPlayerNumber + 1
end

-- 根据UI位置获取玩家座位号
function DdzMillionModel.GetPosToPlayer (uiPos)
    local seatno = DdzMillionModel.GetPosToSeatno (uiPos)
    return m_data.players_info[seatno]
end

-- 是否是自己 玩家自己的UI位置在1号位
function DdzMillionModel.IsPlayerSelf (uiPos)
    return uiPos == 1
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function DdzMillionModel.GetAnimChatShowPos (id)
    if m_data and m_data.players_info then
        for k,v in ipairs(m_data.players_info) do
            if v.id == id then
                local uiPos = DdzMillionModel.GetSeatnoToPos (v.seat_num)
                if DdzMillionModel.data.dizhu and DdzMillionModel.data.dizhu > 0 then
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
