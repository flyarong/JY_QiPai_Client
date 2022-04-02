--[[
正常消息是指除断线重连以外的消息
]]
local nor_ddz_base_lib=require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"
local cfg_trans_nor_ddz_nor=require "Game.normal_ddz_common.Lua.cfg_trans_nor_ddz_nor"
local nor_ddz_algorithm_lib = require "Game.normal_ddz_common.Lua.nor_ddz_algorithm_lib"

DdzFKModel={}
DdzFKModel.game_type = {
    nor = "nor_ddz_nor",
    lz = "nor_ddz_lz",
    er = "nor_ddz_er"
}
DdzFKModel.maxPlayerNumber = 3
DdzFKModel.Model_Status =
{
    wait_join = "wait_join", -- 
    wait_begin = "wait_begin",--房间状态处于等待启动
    gaming = "gaming",--房间状态处于游戏中
    gameover = "gameover",--房间状态处于结束
}

DdzFKModel.Status = {
    ready = "ready", -- 准备状态
    wait_begin = "wait_begin", --wait_begin 报名成功，收到dfg_signup_response进入状态
    wait_table = "wait_table", --wait_table:等待分配桌子，收到dfg_begin_msg进入状态
    wait_join="wait_join",
    wait_p = "wait_p", --wait_p：等待人员入座，收到dfg_join_room_respone进入状态
    fp = "fp", --fp： 发牌， 收到dfg_pai_msg进入状态
    jdz = "jdz", --jdz： 叫地主， 收到dfg_permit_msg，status进入状态，退出也是通过status判定
    set_dz = "set_dz", --set_dz： 设置地主，
    jiabei = "jiabei", --jiabei： 加倍
    cp = "cp", --cp： 出牌
    settlement = "settlement", --settlement： 结算
    report = "report", --report： 上报战果
    gameover="gameover",--游戏结束
    auto = "auto" ,  --玩家进入托管状态
     --抢地主
     q_dizhu = "q_dizhu",
}

local this 
local lister
local m_data
local update
local updateDt=0.1

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister={}
    lister["zijianfang_all_info"] = this.on_friendgame_all_info
    lister["zijianfang_join_msg"] = this.on_friendgame_join_msg
    lister["zijianfang_quit_msg"] = this.on_friendgame_quit_msg
    lister["zijianfang_gameover_msg"] = this.on_friendgame_gameover_msg
    lister["zijianfang_begin_game_response"] = this.on_friendgame_begin_game_response
    lister["zijianfang_net_quality"] = this.on_friendgame_net_quality
    lister["zijianfang_gamecancel_msg"] = this.on_friendgame_gamecancel_msg

    --投票
    lister["begin_vote_cancel_room_response"] = this.on_begin_vote_cancel_room_response
    lister["player_vote_cancel_room_response"] = this.on_player_vote_cancel_room_response

    lister["zijianfang_begin_vote_cancel_room_msg"] = this.on_friendgame_begin_vote_cancel_room_msg
    lister["zijianfang_over_vote_cancel_room_msg"] = this.on_friendgame_over_vote_cancel_room_msg
    lister["zijianfang_player_vote_cancel_room_msg"] = this.on_friendgame_player_vote_cancel_room_msg
    lister["zijianfang_begin_vote_alter_rule_msg"] = this.zijianfang_begin_vote_alter_rule_msg
    lister["zijianfang_player_vote_alter_rule_msg"] = this.zijianfang_player_vote_alter_rule_msg
    lister["zijianfang_over_vote_alter_rule_msg"] = this.zijianfang_over_vote_alter_rule_msg

    --这是自建房系统 玩家点击准备的消息→这是表面的玩家操作
    lister["zijianfang_ready_msg"] = this.on_zijianfang_ready_msg
    --这是游戏过程，由服务器确认玩家状态后发的准备消息→这是服务器的内部操作，和玩家行为无关
 
    lister["nor_ddz_nor_ready_msg"] = this.on_nor_ddz_nor_ready_msg
    lister["nor_ddz_nor_begin_msg"] = this.on_nor_ddz_nor_begin_msg

    lister["nor_ddz_nor_score_change_msg"] = this.on_nor_ddz_nor_score_change_msg
    lister["nor_ddz_nor_req_game_list_response"] = this.on_nor_ddz_nor_req_game_list_response
    lister["nor_ddz_nor_signup_response"] = this.on_nor_ddz_nor_signup_response
    lister["nor_ddz_nor_cancel_signup_response"] = this.on_nor_ddz_nor_cancel_signup_response

    lister["nor_ddz_nor_enter_room_msg"] = this.on_nor_ddz_nor_enter_room_msg
    lister["nor_ddz_nor_join_msg"] = this.on_nor_ddz_nor_join_msg

    lister["nor_ddz_nor_pai_msg"] = this.on_nor_ddz_nor_pai_msg
    lister["nor_ddz_nor_permit_msg"] = this.on_nor_ddz_nor_permit_msg
    lister["nor_ddz_nor_action_msg"] = this.on_nor_ddz_nor_action_msg
    lister["nor_ddz_nor_dizhu_msg"] = this.on_nor_ddz_nor_dizhu_msg
    lister["nor_ddz_nor_laizi_msg"] = this.on_nor_ddz_nor_laizi_msg
    lister["nor_ddz_nor_auto_msg"] = this.on_nor_ddz_nor_auto_msg
    lister["nor_ddz_nor_jiabeifinshani_msg"] = this.on_nor_ddz_nor_jiabeifinshani_msg

    lister["nor_ddz_nor_new_game_msg"] = this.on_nor_ddz_nor_new_game_msg
    lister["nor_ddz_nor_gameover_msg"] = this.on_nor_ddz_nor_gameover_msg
    lister["nor_ddz_nor_start_again_msg"] = this.on_nor_ddz_nor_start_again_msg
    lister["nor_ddz_nor_status_info"] = this.on_nor_ddz_nor_status_info

    lister["nor_ddz_nor_replay_game_response"] = this.on_nor_ddz_nor_replay_game_response

    lister["nor_ddz_nor_quit_game_response"] = this.on_nor_ddz_nor_quit_game_response
    
    lister["nor_ddz_nor_settlement_msg"] = this.on_nor_ddz_nor_settlement_msg
    lister["zijianfang_score_change_msg"] = this.zijianfang_score_change_msg
    -- gps
    lister["gps_info_msg"] = this.on_gps_info_msg
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
        print("<color=red>data.status_no=" .. data.status_no .. "  proto_name=" .. proto_name .. "</color>")
        if proto_name~="nor_ddz_nor_status_info" and  proto_name~="zijianfang_all_info" then
            if m_data.status_no+1 ~= data.status_no and m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no
                
                print("<color=red>proto_name = " .. proto_name .. "</color>")
                --发送状态编码错误事件
                Event.Brocast("dfgModel_nor_ddz_nor_statusNo_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no 
    end
    func(proto_name, data)

end

--注册斗地主正常逻辑的消息事件
function DdzFKModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end

--删除斗地主正常逻辑的消息事件
function DdzFKModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
end

function DdzFKModel.Update()
    if m_data then
        if m_data.countdown and m_data.countdown>0 then
            m_data.countdown=m_data.countdown-updateDt
            if m_data.countdown<0 then
                m_data.countdown=0
            end
        end
        if this.nor_ddz_nor_match_list_countdwon and this.nor_ddz_nor_match_list_countdwon>0 then
            this.nor_ddz_nor_match_list_countdwon=this.nor_ddz_nor_match_list_countdwon-updateDt
            if this.nor_ddz_nor_match_list_countdwon<=0 then
                this.nor_ddz_nor_match_list_countdwon=nil
                 this.nor_ddz_nor_match_list=nil
            end
        end
    end
end
local function InitMatchData(gameID)
    DdzFKModel.data={
                        --dfg_match_info ****
                        --游戏名
                        name=nil,
                        --0是练习场  1是自由场
                        game_model=nil,
                        --dfg_room_info****
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
                        --玩家是否已经加倍
                        jiabei=0,
                        --我的牌列表
                        my_pai_list =nil,
                        --每个人剩余的牌数量
                        remain_pai_amount=nil,
                        --我的倍数
                        my_rate =1,
                        --玩家的托管状态
                        auto_status={},
                        --当前局数
                        race =nil,
                        --我的座位号
                        seat_num =nil,
                        --地主座位号
                        dizhu =nil,
                        --地主牌
                        dz_pai =nil,
                        --赖子牌的牌类型
                        laizi=0,
                        --玩家操作列表
                        action_list ={},
                        
                        --dfg_players_info***
                        playerInfo = {}, --当前房间中玩家的信息(key=seat_num, value=玩家基础信息)

                        
                        settlement_info =nil,     
 
                        --客户端辅助数据***********
                        --当前的地主分数
                        base_rate=0,
                        --抢地主次数
                        er_qiang_dizhu_count = 0,
                        --记牌器
                        jipaiqi=nil,
                        --比赛信息
                        match_info = nil,
    }
    if gameID then
       DdzFKModel.data.hallGameID = gameID
    end
    m_data=DdzFKModel.data
end
local function InitMatchStatusData(status)

    m_data.status = status
    --倒计时
    m_data.countdown=0
    --当前的权限拥有人
    m_data.cur_p = nil 
    --玩家是否已经加倍
    m_data.jiabei=0
    --我的牌列表
    m_data.my_pai_list =nil
    --每个人剩余的牌数量
    m_data.remain_pai_amount=nil
    --我的倍数
    m_data.my_rate = 1
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
    m_data.deadwood_list = nil
    --赖子牌
    m_data.laizi = 0
        -- 抢地主次数
    m_data.er_qiang_dizhu_count = 0

    m_data.settlement_info=nil
end
local function InitMatchRoomData(status)
    InitMatchStatusData(status)
    room_id=nil
    table_num=nil
    playerInfo={}
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
function DdzFKModel.Init()
    InitMatchData()
    this=DdzFKModel
    this.nor_ddz_nor_match_list=nil
    --收到nor_ddz_nor_match_list的时间
    this.nor_ddz_nor_match_list_time=nil
    this.InitUIConfig()
    MakeLister()
    this.AddMsgListener()

    update=Timer.New(this.Update,updateDt,-1,true)
    update:Start()

    return this
end
function DdzFKModel.Exit()
    if this then
        this.RemoveMsgListener()
        update:Stop()
        update=nil
        lister=nil
        m_data=nil
        this.data=nil
        this.nor_ddz_nor_match_list=nil
        this.nor_ddz_nor_match_list_time=nil
        this = nil
    end
end
function DdzFKModel.InitUIConfig()
end


-- 根据游戏ID判断是否是练习场
function DdzFKModel.ClearMatchData(gameID)
    InitMatchData(gameID)
end
-- 解散 退出
function DdzFKModel.on_js_exit()
    DdzFKModel.InitGameData()
    MainLogic.ExitGame()
    DdzFKLogic.change_panel(DdzFKLogic.panelNameMap.hall)
end

-- 结算 下一局
function DdzFKModel.on_js_xyj()
    m_data.model_status = DdzFKModel.Model_Status.wait_join
    DdzFKModel.InitGameData()
    Event.Brocast("model_xyj_msg")
end
--
function DdzFKModel.on_nor_ddz_nor_req_game_list_response(_,data)
    print("[DDZ LaiZi] Model on_req_game_list_response")

    if data.result==0 then
        this.nor_ddz_nor_match_list=data.nor_ddz_nor_match_list
        --30秒后自动销毁
        this.nor_ddz_nor_match_list_countdwon=3600
    end
    Event.Brocast("dfgModel_nor_ddz_nor_req_game_list_response",data.result)
end

--1.比赛报名结果 countdown:手动退出倒计时
function DdzFKModel.on_nor_ddz_nor_signup_response(_, data)
    if data.result == 0 then
        m_data.countdown = data.countdown
        m_data.status = DdzFKModel.Status.wait_table
        m_data.game_model=data.game_model
        MainLogic.EnterGame()
        Event.Brocast("dfgModel_nor_ddz_nor_signup_response", data.result)
	    print("[DDZ LaiZi] Model on_nor_ddz_nor_signup_response " .. data.result)
    else
        Event.Brocast("dfgModel_nor_ddz_nor_signup_fail_response", data.result)
    end
end

function DdzFKModel.on_nor_ddz_nor_cancel_signup_response(_, data)
    if data.result==0 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        Event.Brocast("dfgModel_nor_ddz_nor_cancel_signup_response",data.result)
    else
        Event.Brocast("dfgModel_nor_ddz_nor_cancel_signup_fail_response",data.result)
    end
end

-- 解散房间
function DdzFKModel.on_nor_mj_xzdd_gamecancel_msg(proto_name, data)
    dump(data, "<color=red>解散房间</color>")
    -- HintPanel.Create(1, "房间已解散", function ()
    --     DdzFKModel.on_js_exit()
    -- end)
end
-- 解散房间
function DdzFKModel.on_friendgame_gamecancel_msg(proto_name, data)
    dump(data, "<color=red>解散房间</color>")
    HintPanel.Create(1, "房间已解散", function ()
        DdzFKModel.on_js_exit()
    end)
end

-- 准备
function DdzFKModel.on_nor_ddz_nor_ready_msg(proto_name, data)
    dump(data, "<color=red>准备</color>")
    if  DdzFKModel.data.ready then
        DdzFKModel.data.ready[data.seat_num] = 1
    end
    m_data.cur_race = data.cur_race
    Event.Brocast("model_nor_ddz_nor_ready_msg", data.seat_num)
end

-- 开始游戏
function DdzFKModel.on_nor_ddz_nor_begin_msg(proto_name, data)
    dump(data, "<color=red>开始游戏</color>")
    m_data.model_status = DdzFKModel.Model_Status.gaming
    m_data.status = DdzFKModel.Status.begin
    m_data.cur_race = data.cur_race
    m_data.ready = {0,0,0,0}
    m_data.player_ready = {}
    Event.Brocast("model_nor_ddz_nor_begin_msg")
end

-- 分数改变
function DdzFKModel.on_nor_ddz_nor_score_change_msg(proto_name, data)
    dump(data, "<color=red>分数改变</color>")
    m_data.moneyChange = data.data
    Event.Brocast("model_nor_ddz_nor_score_change_msg")
end

--发起投票response
function DdzFKModel.on_begin_vote_cancel_room_response(proto_name, data)
    if data.result == 0 then
        Event.Brocast("model_begin_vote_cancel_room_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end
--玩家投票response
function DdzFKModel.on_player_vote_cancel_room_response(proto_name, data)
    if data.result == 0 then
        Event.Brocast("model_player_vote_cancel_room_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end
--开始投票
function DdzFKModel.on_friendgame_begin_vote_cancel_room_msg(proto_name, data)
    dump(data, "<color=red>EEE on_friendgame_begin_vote_cancel_room_msg</color>")
    m_data.vote_parm = {}
    m_data.vote_parm.time = data.countdown
    m_data.vote_parm.maxnum = m_data.player_count
    m_data.vote_parm.data = {}
    -- m_data.vote_parm.data[#m_data.vote_parm.data + 1] = {id = #m_data.vote_parm.data + 1 , val = 1}
    m_data.vote_data = {agree_count = 1,disagree_count = 0,begin_player_id = data.player_id}
    Event.Brocast("model_friendgame_begin_vote_cancel_room_msg")
end
--投票结束
function DdzFKModel.on_friendgame_over_vote_cancel_room_msg(proto_name, data)
    -- 0 成功 1 失败 2 取消
    m_data.vote_result = data.vote_result
    m_data.vote_parm = nil
    m_data.vate_data = nil
    m_data.vote_cur_p_id = nil
    m_data.vote_cur_p_opt = nil
    Event.Brocast("model_friendgame_over_vote_cancel_room_msg")
end
--玩家投票msg
function DdzFKModel.on_friendgame_player_vote_cancel_room_msg(proto_name, data)
    m_data.vote_cur_p_id = data.player_id
    m_data.vote_cur_p_opt = data.opt
    Event.Brocast("model_friendgame_player_vote_cancel_room_msg", {id=m_data.vote_cur_p_id, opt=m_data.vote_cur_p_opt})
end

function DdzFKModel.on_nor_ddz_nor_enter_room_msg(proto_name, data)
    m_data.status = DdzFKModel.Status.wait_p
    InitMatchStatusData(m_data.status)
    m_data.seat_num=data.room_info.seat_num
    m_data.my_rate=m_data.init_rate
    m_data.win_count=data.win_count
    m_data.race = 1
    m_data.deadwood_list = nil
    m_data.seatNum={}
    m_data.s2cSeatNum={}
    nor_ddz_base_lib.transform_seat(m_data.seatNum, m_data.s2cSeatNum, m_data.seat_num, DdzFKModel.maxPlayerNumber)

    if data.playerInfo then
        for k, v in pairs(data.playerInfo.p_info) do
            m_data.playerInfo[v.seat_num].base = v
        end
    end

    Event.Brocast("dfgModel_nor_ddz_nor_enter_room_msg")
end

--其他玩家进入游戏
function DdzFKModel.on_nor_ddz_nor_join_msg(proto_name, data)
    print("<color=red>on_nor_ddz_nor_join_msg</color>")
end

--6.进入游戏的人数达到3人，自动发牌,游戏开始，人数满足要求，发牌开局
function DdzFKModel.on_nor_ddz_nor_pai_msg(proto_name, data)
    m_data.status=DdzFKModel.Status.fp
    m_data.my_pai_list=data.my_pai_list
    table.sort(m_data.my_pai_list)
    m_data.deadwood_list = nil
    m_data.remain_pai_amount=data.remain_pai_amount
    m_data.race=data.cur_race

    print("[DDZ LaiZi] Model on_nor_ddz_nor_pai_msg")

    Event.Brocast("dfgModel_nor_ddz_nor_pai_msg")

end

--8.权限信息轮询
function DdzFKModel.on_nor_ddz_nor_permit_msg(proto_name, data)
    m_data.status=data.status
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown=(data.countdown-0.5)
    if m_data.countdown<0 then
        m_data.countdown=0
    end
    m_data.cur_p=data.cur_p
    Event.Brocast("dfgModel_nor_ddz_nor_permit_msg")
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
function DdzFKModel.on_nor_ddz_nor_action_msg(proto_name, data)
    m_data.action_list[#m_data.action_list+1]=data.action

    local act_type = data.action.type
    --注意可能是断线重连  此时相应的数据可能还没有初始化  所以一定要判断数据是否存在
    --更新玩家手上剩余扑克牌的数量
    if  m_data.remain_pai_amount and act_type < 100 and data.action.cp_list then
        local nor_list=data.action.cp_list.nor
        local lz_list=data.action.cp_list.lz
        local len1=0
        local len2=0
        if nor_list then
            len1=#nor_list
        end
        if lz_list then
            len2=#lz_list
        end

        m_data.remain_pai_amount[data.action.p] = m_data.remain_pai_amount[data.action.p] - len1-len2
        if data.action.p ~=m_data.seat_num then 
            nor_ddz_base_lib.jipaiqi(data.action.cp_list,m_data.jipaiqi,m_data.laizi)
        end
        --剔除牌
        if data.action.p==m_data.seat_num and m_data.my_pai_list then
            local hash={}
            if nor_list then
                for _,no in ipairs(nor_list) do
                    hash[no]=true
                end
            end
            local list={}
            for _,no in ipairs(m_data.my_pai_list) do
                if nor_ddz_base_lib.pai_map[no]==m_data.laizi and len2>0 then
                    len2=len2-1
                elseif not hash[no] then
                    list[#list+1]=no
                end
            end
            m_data.my_pai_list=list
        end
    end

    if DdzFKModel.data.game_type == DdzFKModel.game_type.er then
        --记录本局地主底分
        if m_data.base_rate and act_type == 100 then
            m_data.base_rate = 0
            m_data.my_rate = data.action.rate * (m_data.init_rate or 1)
        end
        if data.action.rate and m_data.my_rate and act_type == 102  then
            m_data.base_rate = m_data.base_rate + data.action.rate
            m_data.my_rate = m_data.base_rate + m_data.init_rate
        end
    else
        --记录本局地主底分
        if m_data.base_rate and act_type == 100 and data.action.rate > m_data.base_rate then
            m_data.base_rate = data.action.rate
            m_data.my_rate = data.action.rate * (m_data.init_rate or 1)
        end
        if data.action.rate and m_data.my_rate and m_data.my_rate < data.action.rate then
            m_data.my_rate = data.action.rate * (m_data.init_rate or 1)
        end
    end

    --炸弹翻倍
    if m_data.my_rate and (act_type ==13 or act_type ==14 or act_type ==15) then
        m_data.my_rate = m_data.my_rate * 2
    end
    Event.Brocast("dfgModel_nor_ddz_nor_action_msg")
end

--加倍完成消息
function DdzFKModel.on_nor_ddz_nor_jiabeifinshani_msg(proto_name, data)
    m_data.my_rate=data.my_rate
    Event.Brocast("dfgModel_nor_ddz_nor_jiabeifinshani_msg")
end

--7.确认地主--
function DdzFKModel.on_nor_ddz_nor_dizhu_msg(proto_name, data)
    dump(data, "<color=red>EEE on_nor_ddz_nor_dizhu_msg</color>")
    m_data.status = DdzFKModel.Status.set_dz
    m_data.dizhu = data.dz_info.dizhu
    m_data.dz_pai = data.dz_info.dz_pai
    m_data.rangpai_num = data.dz_info.rangpai_num
    local seat_num = data.dz_info.dizhu
    m_data.remain_pai_amount[seat_num]=m_data.remain_pai_amount[seat_num]+#data.dz_info.dz_pai
    if seat_num==m_data.seat_num then
        for i=1,#data.dz_info.dz_pai do
            m_data.my_pai_list[#m_data.my_pai_list+1]=data.dz_info.dz_pai[i]
        end
        table.sort(m_data.my_pai_list)
        m_data.my_rate=m_data.my_rate*2
    end
    if m_data.game_type == DdzFKModel.game_type.er then
        m_data.my_rate = m_data.init_rate + DdzFKModel.data.er_qiang_dizhu_count
    end
    --初始化记牌器
    m_data.jipaiqi=nor_ddz_base_lib.getAllPaiCount()
    nor_ddz_base_lib.jipaiqi({nor=m_data.my_pai_list},m_data.jipaiqi)
    Event.Brocast("dfgModel_nor_ddz_nor_dizhu_msg")    
end

function DdzFKModel.on_nor_ddz_nor_laizi_msg(proto_name, data)
	print("[DDZ LaiZi] Model on_nor_ddz_nor_laizi_msg: " .. data.laizi)

    m_data.laizi=data.laizi
    if not data.laizi then
        print("333333333333333333")
    end
    Event.Brocast("dfgModel_nor_ddz_nor_laizi_msg",data.p)
end

--托管--
function DdzFKModel.on_nor_ddz_nor_auto_msg(proto_name, data)
    dump(data, "<color=red>on_nor_ddz_nor_auto_msg</color>")
    m_data.auto_status = m_data.auto_status or {}
    m_data.auto_status[data.p] = data.auto_status
    Event.Brocast("dfgModel_nor_ddz_nor_auto_msg",data.p)
end

--11.打完一局重新发牌
function DdzFKModel.on_nor_ddz_nor_new_game_msg(proto_name, data)
    print("<color=yellow>on_nor_ddz_nor_new_game_msg</color>")
    -- --考虑是否需要清除数据
    -- InitMatchStatusData(data.status)
    -- m_data.race =data.race
    -- m_data.curr_all_player =data.curr_all_player
    -- Event.Brocast("dfgModel_nor_ddz_nor_new_game_msg")
end

--13.比赛结束
function DdzFKModel.on_nor_ddz_nor_gameover_msg(proto_name, data)
    print("<color=red>Error on_nor_ddz_nor_gameover_msg</color>")
    -- m_data.status = DdzFKModel.Status.gameover
    -- m_data.settlement_info = data.settlement_info
    -- if  m_data.settlement_info.chuntian and m_data.settlement_info.chuntian>0 then
    --     m_data.my_rate=m_data.my_rate*2
    -- end
    -- for i=1,3 do
    --     m_data.playerInfo[i].jing_bi = m_data.playerInfo[i].jing_bi + data.settlement_info.award[i]
    -- end
    -- MainLogic.ExitGame()
    
    -- Event.Brocast("dfgModel_nor_ddz_nor_gameover_msg")
end

--14.都没有叫地主重新开始
function DdzFKModel.on_nor_ddz_nor_start_again_msg(proto_name, data)
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    Event.Brocast("dfgModel_nor_ddz_nor_start_again_msg")
end

function DdzFKModel.on_nor_ddz_nor_status_info(proto_name, data)
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
        m_data.race=s.race
        m_data.seat_num=s.seat_num
        m_data.dizhu=s.dizhu
        m_data.dz_pai=s.dz_pai
        m_data.jipaiqi=s.jipaiqi
        m_data.match_info=s.match_info
        m_data.win_count=s.win_count
        m_data.laizi=s.laizi
        if not s.laizi then
            print("111111111111111111111")
        end

        calDizhuBaserate()
    end
    Event.Brocast("dfgModel_nor_ddz_nor_status_info")
end
function DdzFKModel.InitGameData()
    if not m_data then
        print("<color=red>InitGameData m_data nil</color>")
        return
    end
    print("<color=red>InitGameData m_data 重置</color>")
    m_data.countdown = 0
    m_data.cur_p = nil
    m_data.status = DdzFKModel.Status.ready

    m_data.jiabei=0
    m_data.my_pai_list =nil
    m_data.remain_pai_amount=nil
    m_data.my_rate =1
    m_data.dizhu =nil
    m_data.dz_pai =nil
    m_data.laizi=0
    m_data.auto_status={}
    m_data.action_list ={}
    m_data.settlement_info =nil
    m_data.base_rate=0
    m_data.jipaiqi=nil
    m_data.deadwood_list = nil
    m_data.match_info = nil
    -- 抢地主次数
    m_data.er_qiang_dizhu_count = 0
end
function DdzFKModel.on_friendgame_all_info(proto_name, data)
    dump(data, "<color=red>所有的游戏数据</color>", 10)
    if data.status_no==-1 then
        DdzFKModel.on_js_exit()
    else
        m_data.model_status = data.status
        m_data.game_type = data.game_type
        m_data.friendgame_room_no = data.zijianfang_room_no
        m_data.ori_game_cfg = data.ori_game_cfg
        m_data.gameover_info = data.gameover_info
        m_data.room_owner = data.room_owner
        m_data.player_count = data.player_count
        DdzFKModel.maxPlayerNumber = data.player_count
        m_data.player_ready = {}
        m_data.password = data.password
        for k,v in pairs(data.ready) do 
            v.opt = v.status
            m_data.player_ready[v.player_id] = v
        end
        --转化成算法需要的配置数据
        m_data.translate_config= cfg_trans_nor_ddz_nor.translate(m_data.ori_game_cfg)
        dump(m_data.translate_config,"11")
        nor_ddz_base_lib.set_game_type(data.game_type)
        --初始化算法库
        m_data.ddz_algorithm=nor_ddz_algorithm_lib.New(m_data.translate_config.kaiguan, m_data.game_type)
        
        local s = data.player_info
        if s then
            m_data.playerInfo=m_data.playerInfo or {}
            for i=1,m_data.player_count do
                m_data.playerInfo[i]= {}
            end
            for k,v in pairs(s) do
                m_data.playerInfo[v.seat_num].base = v
                if v.id == MainModel.UserInfo.user_id then
                    m_data.seat_num = v.seat_num
                end
            end
        end

        m_data.seatNum={}
        m_data.s2cSeatNum={}
        nor_ddz_base_lib.transform_seat(m_data.seatNum,m_data.s2cSeatNum,m_data.seat_num ,DdzFKModel.maxPlayerNumber)


        s = data.vote_data
        if s then
            m_data.vote_data = data.vote_data
            m_data.vote_parm = {}
            m_data.vote_parm.time = data.vote_data.countdown
            m_data.vote_parm.maxnum = m_data.player_count
            m_data.vote_parm.data = {}
            for i=1,m_data.vote_data.agree_count do
                m_data.vote_parm.data[#m_data.vote_parm.data + 1] = {id = #m_data.vote_parm.data + 1 , val = 1}
            end

            for i=1,m_data.vote_data.disagree_count do
                m_data.vote_parm.data[#m_data.vote_parm.data + 1] = {id = #m_data.vote_parm.data + 1 , val = 0}
            end

            m_data.vote_cur_p_id = nil
            m_data.vote_cur_p_opt = nil
        else
            m_data.vote_cur_p_id = nil
            m_data.vote_cur_p_opt = nil
            m_data.vote_data = nil
            m_data.vote_parm = nil
        end

        s = data.room_dissolve
        if s then
            m_data.room_dissolve = data.room_dissolve
        end

        s = data.room_rent
        if s then
            m_data.room_rent = data.room_rent
        end

        -- ###_test  改变状态
        if m_data.model_status == DdzFKModel.Model_Status.gameover then
            MainLogic.ExitGame()
        end

        s = data.room_info
        if s then
            m_data.init_stake = s.init_stake
            m_data.init_rate = s.init_rate
            if m_data.base_rate == 0 then m_data.my_rate = s.init_rate end
        end

        -- 游戏数据
        s = data.nor_ddz_nor_status_info
        if m_data.seat_num and s then

            m_data.status=s.status
            m_data.countdown=s.countdown
            m_data.is_over = s.is_over
            m_data.cur_p=s.cur_p
            m_data.laizi=s.laizi or 0 
            if not s.laizi then
                print("22222222222222222222")
            end
            m_data.cur_race = s.cur_race
            m_data.race_count = s.race_count

            m_data.my_pai_list=s.my_pai_list
            if m_data.my_pai_list then
                table.sort(m_data.my_pai_list)
            end
            m_data.remain_pai_amount=s.remain_pai_amount
            m_data.my_rate=s.my_rate
            m_data.action_list=s.act_list
            if not m_data.action_list then
                m_data.action_list = {}
            end
            m_data.auto_status=s.auto_status or {}
            m_data.race=s.race
            m_data.er_qiang_dizhu_count = s.er_qiang_dizhu_count or 0
            m_data.dizhu=s.dizhu
            m_data.dz_pai=s.dz_pai
            m_data.jipaiqi=s.jipaiqi
            m_data.rangpai_num = s.rangpai_num
            m_data.win_count=s.win_count
            calDizhuBaserate()

            if m_data.status==DdzFKModel.Status.gameover then
                MainLogic.ExitGame()
            end
           
            m_data.settlement_info=s.settlement_info
            if DdzFKModel.data.game_type == DdzFKModel.game_type.er then
                if m_data.settlement_info then
                    for i = 1, #m_data.settlement_info.remain_pai do
                        if m_data.settlement_info.remain_pai[i].p == 3 then
                            m_data.deadwood_list = m_data.settlement_info.remain_pai[i]
                            table.remove(m_data.settlement_info.remain_pai, i)
                            break
                        end
                    end
                end
            end
            -- if m_data.settlement_info then
            --     for i=1,3 do
            --         if i ~= m_data.seat_num then
            --             m_data.playerInfo[i].base.score = m_data.playerInfo[i].base.score + m_data.settlement_info.award[i]
            --         end
            --     end
            -- end
            -- if  m_data.settlement_info.chuntian and m_data.settlement_info.chuntian>0 then
            --     m_data.my_rate=m_data.my_rate*2
            -- end
        end
    end
    Event.Brocast("model_xyj_msg")
    Event.Brocast("model_friendgame_all_info")
    if DdzFKModel.data and DdzFKModel.data.room_dissolve and DdzFKModel.data.room_dissolve ~= 0 then
    else
        DdzFKModel.RefreshGPS(false)
    end
end
function DdzFKModel.RefreshGPS(isCreate)
    if m_data and (m_data.model_status == DdzFKModel.Model_Status.wait_begin or isCreate) then
        GPSPanel.query_gps_info(isCreate,m_data.seat_num,m_data.playerInfo,function (isTrustDistance)
            Event.Brocast("model_query_gps_info_msg",isTrustDistance)
        end,nil,true)
    end
end

-- 玩家进入
function DdzFKModel.on_friendgame_join_msg(proto_name, data)
    dump(data, "<color=red>玩家进入</color>")
    m_data.model_status = DdzFKModel.Model_Status.wait_join
    local seatno = data.player_info.seat_num
    m_data.playerInfo = m_data.playerInfo or {}
    m_data.playerInfo[seatno] = m_data.playerInfo[seatno] or {}
    m_data.playerInfo[seatno].base = data.player_info
    Event.Brocast("model_friendgame_join_msg", seatno)
end
-- 玩家退出
function DdzFKModel.on_friendgame_quit_msg(proto_name, data)
    dump(data, "<color=red>玩家退出</color>")
    local seatno = data.seat_num
    if data.seat_num == m_data.seat_num then
        DdzFKModel.InitGameData()
        MainLogic.ExitGame()
        DdzFKLogic.change_panel(DdzFKLogic.panelNameMap.hall)
    else
        if m_data.playerInfo[seatno] then
            if DdzFKModel.data.player_ready then 
                DdzFKModel.data.player_ready[m_data.playerInfo[seatno].base.id] = nil
            end 

            m_data.playerInfo[seatno].base = nil
            if DdzFKModel.data.ready then 
                DdzFKModel.data.ready[seatno] = 0
            end 
            Event.Brocast("model_friendgame_quit_msg", seatno)
        end
    end
end
-- 总结算
function DdzFKModel.on_friendgame_gameover_msg(proto_name, data)
    dump(data, "<color=red>总结算</color>")
    m_data.model_status= DdzFKModel.Model_Status.gameover
    m_data.status= DdzFKModel.Status.gameover
    
    -- MainLogic.ExitGame()
    m_data.gameover_info = data.gameover_info
    Event.Brocast("model_friendgame_gameover_msg")
end

function DdzFKModel.on_gps_info_msg(proto_name, data)
    dump(data,"<color=yellow>on_gps_info_msg</color>")
    GPSPanel.Create(false , GPSPanel.IsMustCreate(data.data),m_data.seat_num, m_data.playerInfo, data, function (isTrustDistance)
        Event.Brocast("model_query_gps_info_msg",isTrustDistance)
        print("<color=yellow>gps callback</color>")
    end)
end

-- 开始游戏
function DdzFKModel.on_friendgame_begin_game_response(proto_name, data)
    if data.result == 0 then
    else
        HintPanel.ErrorMsg(data.result)
    end
end
-- 玩家离线状态
function DdzFKModel.on_friendgame_net_quality(proto_name, data)
    dump(data, "<color=yellow>玩家离线状态</color>")
    DdzFKModel.data.playerInfo[data.seat_num].base.net_quality = data.net_quality
    Event.Brocast("model_friendgame_net_quality", data.seat_num)
end

--再玩一把
function DdzFKModel.on_nor_ddz_nor_replay_game_response(proto_name,data)
    dump(data, "<color=red>重玩</color>")
    if data.result == 0 then
        this.on_nor_ddz_nor_signup_response(proto_name,data)
    else
        local msg = errorCode[data.result] or ("错误："..data.result)
        HintPanel.Create(1, msg, function ()
            DdzFKModel.on_js_exit()
        end)
    end
end

--退出游戏
function DdzFKModel.on_nor_ddz_nor_quit_game_response(proto_name,data)
    if data.result==0 then
        DdzFKModel.on_js_exit()
    else

    end
end
function DdzFKModel.on_nor_ddz_nor_settlement_msg(proto_name,data)
    dump(data, "<color=red>结算</color>",10)
    m_data.status= DdzFKModel.Status.settlement
    m_data.settlement_info = data.settlement_info
    m_data.is_over = data.is_over
    if DdzFKModel.data.game_type == DdzFKModel.game_type.er then
        for i = 1, #m_data.settlement_info.remain_pai do
            if m_data.settlement_info.remain_pai[i].p == 3 then
                m_data.deadwood_list = m_data.settlement_info.remain_pai[i]
                table.remove(m_data.settlement_info.remain_pai, i)
                break
            end
        end
    end
    if  m_data.settlement_info.chuntian and m_data.settlement_info.chuntian>0 then
        m_data.my_rate=m_data.my_rate*2
    end
    Event.Brocast("model_nor_ddz_nor_settlement_msg")
end

-- 玩家自己是否胜利
function DdzFKModel.IsMyWin()
    if m_data and m_data.settlement_info then 
        if m_data.settlement_info.winner==5 then
            if m_data.seat_num==m_data.dizhu then
                return true
            end
            return false
        elseif m_data.settlement_info.winner==4 then
            if m_data.seat_num==m_data.dizhu then
                return false
            end
            return true
        else
            return false
        end
    end
    return nil
end



--获得我的权限数据
--[[
    type: 
        "jdz"  (数据为 几分以上)
        "jb"   ()
        “cp”   (数据为 是否必须出，有无够大的牌power)

        {type,is_must,power,jdz_min}
--]]
function DdzFKModel.getMyPermitData()
    if m_data then
        if m_data.cur_p and m_data.cur_p==m_data.seat_num then
            if m_data.status==DdzFKModel.Status.jdz then
                return {type=DdzFKModel.Status.jdz,jdz_min=m_data.base_rate+1} 
            elseif m_data.status==DdzFKModel.Status.jiabei then
                return {type=DdzFKModel.Status.jiabei,is_jiabei=m_data.jiabei} 
            elseif m_data.status == DdzFKModel.Status.q_dizhu then
                return {type = DdzFKModel.Status.q_dizhu}
            elseif m_data.status==DdzFKModel.Status.cp then
                --判断是否为必须出牌
                local is_must=nor_ddz_base_lib.is_must_chupai(m_data.action_list)
                --判断是否有够大的牌
                local power=0
                if not is_must then
                    power=m_data.ddz_algorithm:check_cp_capacity_by_pailist(m_data.action_list,m_data.my_pai_list,m_data.laizi)
                    print("<color=green>@@@@@@@@@@@@@</color>",power)
                end
                return {type=DdzFKModel.Status.cp,is_must=is_must,power=power}
            end
        end

    end
    return nil
end

-- 练习场下一个奖励差几个胜场 以及 最近一次奖励的索引(默认索引为1)
function DdzFKModel.getNextAward(winCount)
    local currAwardIndex = 1
    for i,v in ipairs(this.UIConfig.award) do
        if v.win_count > winCount then
            return v.win_count - winCount, currAwardIndex
        end
        currAwardIndex = i
    end
    return 0, currAwardIndex
end

-- 公共倍数 就是地主叫的分数
function DdzFKModel.GetGongGongBeishu()
    if m_data and m_data.settlement_info and m_data.dizhu then
        return m_data.settlement_info.p_jdz[m_data.dizhu] or 0
    end
    return 0
end

function DdzFKModel.GetJSBeishu(seat_num)
    if m_data and m_data.settlement_info then
        if seat_num == m_data.dizhu then
            return DdzFKModel.GetDiZhuBeishu()
        else
            return DdzFKModel.GetNongMinBeishu()
        end
    end
    return 0
end

-- 地主倍数 地主加的倍数
function DdzFKModel.GetDiZhuBeishu()
    if m_data and m_data.settlement_info then
        local value = m_data.settlement_info.p_jiabei[m_data.dizhu] or 0
        if value > 0 then
            return 2
        end
    end
    return 0
end

-- 农民倍数 农民加的倍数
function DdzFKModel.GetNongMinBeishu()
    if m_data and m_data.settlement_info then
        local d = 0
        for k,v in ipairs(m_data.settlement_info.p_jiabei) do
            if k ~= m_data.dizhu then
                if v > 0 then
                    d = d + 1
                end
            end
        end
        if d > 0 then
            return math.pow(2, d)
        end
    end
    return 0
end

-- 额外倍数
function DdzFKModel.GetEWaiBeishu()
    if m_data and m_data.settlement_info then
        local d = 0
       
        if m_data.seat_num ~= m_data.dizhu then
        --自己是农民
            if m_data.settlement_info.p_jiabei[m_data.seat_num] and m_data.settlement_info.p_jiabei[m_data.seat_num] > 0 then
                d = d + 1
            end

            if m_data.settlement_info.p_jiabei[m_data.dizhu] and m_data.settlement_info.p_jiabei[m_data.dizhu] > 0 then
                d = d + 1
            end
            if d > 0 then
                return math.pow(2, d)
            end
        elseif m_data.seat_num == m_data.dizhu then
            local sum = 0
            --地主
            if m_data.settlement_info.p_jiabei[m_data.dizhu] and m_data.settlement_info.p_jiabei[m_data.dizhu] > 0 then
                d = d + 1
            end
            

            for k,v in ipairs(m_data.settlement_info.p_jiabei) do
                local nm = 0
                if k ~= m_data.dizhu and v > 0 then
                    nm = nm + 1
                end
                if k ~= m_data.dizhu then
                    sum = sum + math.pow(2, nm + d)
                end
            end
            return sum
        end
    end
    return 0
end

-- 炸弹
function DdzFKModel.GetZhadanBeishu()
    if m_data and m_data.settlement_info then
        if m_data.settlement_info.bomb_count > 0 then
            return math.pow(2, m_data.settlement_info.bomb_count)
        end
    end
    return 0
end

-- 春天
function DdzFKModel.GetCTBeishu()
    if m_data and m_data.settlement_info then
        if m_data.settlement_info.chuntian > 0 then
            return 2
        end
    end
    return 0
end

-- 总倍数
function DdzFKModel.GetZongBeishu()
    local beishu = {}
    local rr = 1
    local isB = false
    beishu[#beishu + 1] = this.GetGongGongBeishu()
    beishu[#beishu + 1] = this.GetEWaiBeishu()
    beishu[#beishu + 1] = this.GetZhadanBeishu()
    beishu[#beishu + 1] = this.GetCTBeishu()
    for _,v in ipairs(beishu) do
        if v > 0 then
            isB = true
            rr = v * rr
        end
    end
    if isB then
        return rr
    else
        return 0
    end
end

-- 判断是否能进入
function DdzFKModel.IsRoomEnter(id)
    local v = this.UIConfig.entrance[id]
    
    local dd = MainModel.UserInfo.jing_bi
    if this.UIConfig.config[id].gameModel == 1 then
        if v.enterMin >= 0 and dd < v.enterMin then
            return 1 -- 过低
        end
        if v.enterMax >= 0 and dd >= v.enterMax then
            return 2 -- 过高
        end
    end
    return 0
end


-- 判断是否能再次进入
function DdzFKModel.IsAgainRoomEnter(id)
    local v = DdzFKModel.UIConfig.entrance[id]
    
    local dd = MainModel.UserInfo.jing_bi
    if DdzFKModel.UIConfig.config[id].gameModel == 1 then
        if v.min_coin > 0 and dd < v.min_coin then
            return 1 -- 过高
        end
    end
    return 0
end

local voiceShowPos =
{
    [1] = {pos = {x=-565, y=-187, z=0}, rota= {x=0, y=0, z=0} },
    [2] = {pos = {x=580, y=322, z=0}, rota= {x=0, y=180, z=0} },
    [3] = {pos = {x=-559, y=333, z=0}, rota= {x=0, y=0, z=0} },
}
-- 根据玩家ID返回语音显示的位置与旋转参数
-- 语音聊天必须要这个方法
function DdzFKModel.GetIdToVoiceShowPos (id)
    for k,v in ipairs(DdzFKModel.data.playerInfo) do
        if v.base and tostring(v.base.id) == tostring(id) then
            local uiPos = DdzFKModel.GetSeatnoToPos (v.base.seat_num)
            return voiceShowPos[uiPos]
        end
    end
    dump(id, "<color=red>发送者ID</color>")
    dump(DdzFKModel.data.playerInfo, "<color=red>玩家列表</color>")
    return {pos = {x=0, y=0, z=0}, rota= {x=0, y=0, z=0} }
end

-- 返回自己的座位号
function DdzFKModel.GetPlayerSeat ()
    return m_data.seat_num
end
-- 返回自己的UI位置
function DdzFKModel.GetPlayerUIPos ()
    return DdzFKModel.GetSeatnoToPos (m_data.seat_num)
end
-- 根据座位号获取玩家UI位置
function DdzFKModel.GetSeatnoToPos (seatno)
    local seftSeatno = DdzFKModel.GetPlayerSeat()
    return (seatno - seftSeatno + DdzFKModel.maxPlayerNumber) % DdzFKModel.maxPlayerNumber + 1
end
-- 根据UI位置获取玩家座位号
function DdzFKModel.GetPosToSeatno (uiPos)
    local seftSeatno = DdzFKModel.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % DdzFKModel.maxPlayerNumber + 1
end

-- 根据UI位置获取玩家座位号
function DdzFKModel.GetPosToPlayer (uiPos)
    dump(uiPos,"<color=red>uipos-------</color>")
    local seatno = DdzFKModel.GetPosToSeatno (uiPos)
    return m_data.playerInfo[seatno]
end

-- 是否是自己 玩家自己的UI位置在1号位
function DdzFKModel.IsPlayerSelf (uiPos)
    return uiPos == 1
end

-- 当前进入人数
function DdzFKModel.GetCurrPlayerCount()
    local nn = 0
    for k,v in ipairs(DdzFKModel.data.playerInfo) do
        if v.base then
            nn = nn + 1
        end
    end
    return nn
end

-- 该座位号是不是房主
function DdzFKModel.IsFZ(seatno)
    if not seatno then 
        seatno = m_data.seat_num
    end
    local data = DdzFKModel.data
    if data and data.playerInfo and data.playerInfo[seatno].base and data.playerInfo[seatno].base.id == data.room_owner then
        return true
    end
end
-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function DdzFKModel.GetAnimChatShowPos (id)
    if m_data and m_data.playerInfo then
        for k,v in ipairs(m_data.playerInfo) do
            if v and v.base and v.base.id == id then
                local uiPos = DdzFKModel.GetSeatnoToPos (v.base.seat_num)
                if DdzFKModel.data.dizhu and DdzFKModel.data.dizhu > 0 then
                    return uiPos, true
                else
                    return uiPos, false
                end
            end
        end
    end
    dump(id, "<color=red>发送者ID</color>")
    dump(m_data.playerInfo, "<color=red>玩家列表</color>")
    return 1, false
end

function DdzFKModel.on_zijianfang_ready_msg(_,data)
    dump(data,"<color=red>玩家准备信息----------------</color>")
    m_data.player_ready = m_data.player_ready or {}
    m_data.player_ready[data.player_id] = data
    Event.Brocast("model_zjf_player_ready_info_change",data.player_id)
end

function DdzFKModel.GetReadyStatusBySeatNum(SeatNum)
    if SeatNum then 
        for k,v in pairs(m_data.player_ready) do 
            if v.seat_num == SeatNum then 
                return v.opt == 1
            end
        end
    end
    return false
end

function DdzFKModel.GetReadyStatusByID(ID)
    if ID then
        if m_data.player_ready and m_data.player_ready[ID] and m_data.player_ready[ID].opt == 1 then 
            return true
        end
    end
    return false
end

function DdzFKModel.IsAllReady()
    -- local m_data = DdzFKModel.data
    -- for i = 1,3 do 
    --     local dataPos = DdzFKModel.data.seatNum[i]
    --     local info = m_data.playerInfo[dataPos]
    --     if info and info.base and info.base.id ~= m_data.room_owner then 
    --         if DdzFKModel.GetReadyStatusByID(info.base.id) == false then 
    --             return false
    --         end
    --     end
    -- end
    --默认都准备了，交给服务器处理
    return true
end

function DdzFKModel.zijianfang_begin_vote_alter_rule_msg(_,data)
    dump(data, "<color=red>EEE zijianfang_begin_vote_alter_rule_msg</color>")
    m_data.player_ready = {}
    Event.Brocast("model_zjf_player_ready_info_change",MainModel.UserInfo.user_id)
    if not DdzFKModel.IsFZ() then
        DdzZJFRuleChangeNoticePrefab.Create(data,function ()
            Network.SendRequest("zijianfang_req_info_by_send", {type = "all"}, "")
        end,
        
        function ()
            Network.SendRequest(
                "zijianfang_exit_room",
                nil,
                "请求退出",
                function(data)
                    if data.result == 0 then
                        DdzFKModel.on_js_exit()
                    else
                        HintPanel.ErrorMsg(data.result)
                    end
                end
            )
        end)
    end 
end
function DdzFKModel.zijianfang_player_vote_alter_rule_msg(_,data)
   dump(data, "<color=red>EEE zijianfang_player_vote_alter_rule_msg</color>") 
end
function DdzFKModel.zijianfang_over_vote_alter_rule_msg(_,data)
   dump(data, "<color=red>EEE zijianfang_over_vote_alter_rule_msg</color>") 
end


function DdzFKModel.get_ori_game_cfg_byOption(Option)
    if DdzFKModel.data.ori_game_cfg then 
        for k ,v in pairs(DdzFKModel.data.ori_game_cfg) do
            if v.option == Option then
                return v.value
            end
        end
    end 
end
--获取当前倍数上限
function DdzFKModel.GetCurrBeiShu()
    local feng_ding_bs = GameZJFModel.fengding_bs_ddz_str
    local bs = GameZJFModel.fengding_bs_ddz_int
    for i = 1,#feng_ding_bs do
        if DdzFKModel.get_ori_game_cfg_byOption(feng_ding_bs[i]) then 
            return bs[i]
        end
    end
end

function DdzFKModel.IsFZPaY()
    if DdzFKModel.get_ori_game_cfg_byOption("fangzhu_pay") == 1 then 
        return true
    end
    return false
end

function DdzFKModel.InitReadyStatus()
    m_data.player_ready = {}
    m_data.deadwood_list = nil
end

-- 返回农民的座位号
function DdzFKModel.GetSeatNM()
    if m_data.dizhu == 1 then
        return 2
    else
        return 1
    end
end

function DdzFKModel.CheakCanReadyGame()
    --每个人
    local xishu = GameZJFModel.get_ddz_enter_xishu_by_type(DdzFKModel.data.game_type)
    if DdzFKModel.IsFZPaY() then
        if DdzFKModel.IsFZ() then
            xishu = xishu * (DdzFKModel.data.game_type == "nor_ddz_er" and 2 or 3)
        else
            xishu = 0
        end
	end
    local need = (DdzFKModel.get_ori_game_cfg_byOption("enter_limit") * DdzFKModel.GetCurrBeiShu() + xishu) * DdzFKModel.get_ori_game_cfg_byOption("init_stake") + GameZJFModel.get_ddz_enter_base_by_type(DdzFKModel.data.game_type)
    dump(need,"<color=red>当前需要多少.."..need.."..鲸币才能开始游戏</color>")
    if MainModel.UserInfo.jing_bi >= need then
        return true
    end
end

function DdzFKModel.zijianfang_score_change_msg(_,data)
    dump(data,"<color=red>zijianfang_score_change_msg</color>")
    local func = function(player_id)
        for i = 1,#m_data.playerInfo do
            if m_data.playerInfo[i].base and m_data.playerInfo[i].base.id == player_id then
                return m_data.playerInfo[i].base.seat_num
            end
        end
    end
    local change = data.score - m_data.playerInfo[func(data.player_id)].base.score
    m_data.playerInfo[func(data.player_id)].base.score = data.score
    Event.Brocast("model_score_change",{change = change,seat_num = func(data.player_id)})
end

function DdzFKModel.GetFzName()
    for i = 1, #m_data.playerInfo do
        if m_data.playerInfo[i].base.id == m_data.room_owner then
            return m_data.playerInfo[i].base.name
        end
    end
end