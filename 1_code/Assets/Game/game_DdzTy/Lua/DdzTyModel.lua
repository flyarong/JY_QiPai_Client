--[[
正常消息是指除断线重连以外的消息
]]
local tyDdzFunc=require "Game.normal_ddz_common.Lua.tingyong_ddz_func"
local UIConfig = require "Game.game_DdzTy.Lua.tyddz_freestyle_ui"	--ui配置
-- local AwardConfig = require "Game.game_DdzTy.Lua.ty_drivingrange_award"   --奖励配置

macth_status = {
    wait_begin = "wait_begin", --wait_begin 报名成功，收到dfg_signup_response进入状态
    wait_table = "wait_table", --wait_table:等待分配桌子，收到dfg_begin_msg进入状态
    wait_join="wait_join",
    wait_p = "wait_p", --wait_p：等待人员入座，收到dfg_join_room_respone进入状态
    fp = "fp", --fp： 发牌， 收到dfg_pai_msg进入状态
    jdz = "jdz", --jdz： 叫地主， 收到dfg_permit_msg，status进入状态，退出也是通过status判定
    jiabei = "jiabei", --jiabei： 加倍
    cp = "cp", --cp： 出牌
    settlement = "settlement", --settlement： 结算
    report = "report", --report： 上报战果
    gameover="gameover",--游戏结束
    auto = "auto"   --玩家进入托管状态
}

DdzTyModel={}


local this 
local lister
local m_data
local update
local updateDt=0.1

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister={}
    --response
    lister["tydfg_req_game_list_response"] = this.on_tydfg_req_game_list_response
    lister["tydfg_signup_response"] = this.on_tydfg_signup_response
    lister["tydfg_cancel_signup_response"] = this.on_tydfg_cancel_signup_response

    lister["tydfg_enter_room_msg"] = this.on_tydfg_enter_room_msg
    lister["tydfg_join_msg"] = this.on_tydfg_join_msg

    lister["tydfg_pai_msg"] = this.on_tydfg_pai_msg
    lister["tydfg_kan_my_pai_msg"] = this.on_tydfg_kan_my_pai_msg
    lister["tydfg_permit_msg"] = this.on_tydfg_permit_msg
    lister["tydfg_action_msg"] = this.on_tydfg_action_msg
    lister["tydfg_dizhu_msg"] = this.on_tydfg_dizhu_msg
    lister["tydfg_dizhu_pai_msg"] = this.on_tydfg_dizhu_pai_msg
    lister["tydfg_auto_msg"] = this.on_tydfg_auto_msg
    lister["tydfg_auto_cancel_signup_msg"] = this.on_tydfg_auto_cancel_signup_msg

    lister["tydfg_new_game_msg"] = this.on_tydfg_new_game_msg
    lister["tydfg_gameover_msg"] = this.on_tydfg_gameover_msg
    lister["tydfg_start_again_msg"] = this.on_tydfg_start_again_msg
    lister["tydfg_status_info"] = this.on_tydfg_status_info
    lister["tydfg_all_info"] = this.on_tydfg_all_info

    lister["tydfg_replay_game_response"] = this.on_tydfg_replay_game_response

    lister["tydfg_quit_game_response"] = this.on_tydfg_quit_game_response

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
        if proto_name~="tydfg_status_info" and  proto_name~="tydfg_all_info" then
            if m_data.status_no+1 ~= data.status_no and m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no

                --发送状态编码错误事件
                print("<color=red>proto_name = " .. proto_name .. "</color>")
                Event.Brocast("tydfgModel_tydfg_statusNo_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no 
    end
    func(proto_name, data)
end

--注册斗地主正常逻辑的消息事件
function DdzTyModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end

--删除斗地主正常逻辑的消息事件
function DdzTyModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
end

function DdzTyModel.Update()
    if m_data then
        if m_data.countdown and m_data.countdown>0 then
            m_data.countdown=m_data.countdown-updateDt
            if m_data.countdown<0 then
                m_data.countdown=0
            end
        end
        if this.tydfg_match_list_countdwon and this.tydfg_match_list_countdwon>0 then
            this.tydfg_match_list_countdwon=this.tydfg_match_list_countdwon-updateDt
            if this.tydfg_match_list_countdwon<=0 then
                this.tydfg_match_list_countdwon=nil
                 this.tydfg_match_list=nil
            end
        end
    end
end
local function InitMatchData(gameID)
    DdzTyModel.data={
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
                        --玩家操作列表
                        action_list ={},
                        
                        --dfg_players_info***
                        players_info = {}, --当前房间中玩家的信息(key=seat_num, value=玩家基础信息)

                        
                        settlement_info =nil,     
 
                        --客户端辅助数据***********
                        --当前的地主分数
                        base_rate=0,
                        --记牌器
                        jipaiqi=nil,
                        --比赛信息
                        match_info = nil,
                        -- -1 还没开始  0没有倒拉 1倒或拉了
                        p_dao_la = nil,

                        --*******************
                         --0未操作过  1-不操作  2-是操作
                        men_data=nil,
                        zhua_data=nil,
                        --******************
    }
    if gameID then
        DdzTyModel.data.hallGameID = gameID
    end
    m_data=DdzTyModel.data
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
    local init_rate=1
    if m_data.init_rate then
        init_rate=m_data.init_rate
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

    m_data.settlement_info=nil


    m_data.men_data={0,0,0}
    m_data.zhua_data={0,0,0}
    m_data.p_dao_la = {-1,-1,-1}
    --[[
    {   kan=true,
        men=true,
        zhua=true,
        buzhua=true, 
    }  
    --]]
    m_data.jdz_permit_data=nil
     --[[
    {   
        dao=true,
        budao=true,
        la=true,
        bula=true, 
    }  
    --]]
    m_data.jb_permit_data=nil
end
local function InitMatchRoomData(status)
    InitMatchStatusData(status)
    room_id=nil
    table_num=nil
    players_info={}
end
local function calDizhuBaserate()
    --记录本局地主底分
    -- if m_data then
    --      m_data.base_rate=0
    --     if m_data.action_list then
    --         for _,v in pairs(m_data.action_list) do
    --             if  v.type == 100 and v.rate > m_data.base_rate then
    --                 m_data.base_rate = v.rate
    --             end
    --         end
    --     end
    -- end
end
--获得除我之外另外一个农民的座位号
local function get_other_nm_seat_num()
    if m_data then
        if m_data.dizhu and m_data.dizhu~=m_data.seat_num then
            for i=1,3 do
                if m_data.dizhu~=i and m_data.seat_num~=i then
                    return i
                end
            end
        end
    end
    return nil
end
local function get_my_jdz_permit_data()

    if m_data then
        if m_data.status=="jdz" and m_data.cur_p==m_data.seat_num then
            --看自己是否已经看牌
            --未看牌
            if m_data.men_data[m_data.seat_num]==0 then
                --已看牌
                m_data.jdz_permit_data={kan=true,men=true}    
            else
                m_data.jdz_permit_data={zhua=true}
                --检查我是否必抓
                if not tyDdzFunc.is_must_zhua( m_data.my_pai_list) then
                    m_data.jdz_permit_data.buzhua=true
                end
            end
        else
            m_data.jdz_permit_data=nil
        end
    end
end
local function get_my_jb_permit_data()
    if m_data then
        if m_data.status=="jiabei" and (m_data.cur_p==m_data.seat_num or (m_data.cur_p==4 and m_data.dizhu~=m_data.seat_num )) then
            --看自己是否是地主
            if m_data.dizhu==m_data.seat_num then
                m_data.jb_permit_data={la=true,bula=true}  
            else
                local nm1=nil
                local nm2=nil
                --查看自己能不能 倒
                --没有做出过不抓操作就能 倒
                if m_data.zhua_data[m_data.seat_num]==0 then
                    m_data.jb_permit_data={dao=true}
                     --检查我是否必倒  或者 地主是闷
                    if m_data.men_data[m_data.dizhu]==2 or not tyDdzFunc.is_must_dao(m_data.my_pai_list) then
                        m_data.jb_permit_data.budao=true
                    end
                    nm1=m_data.seat_num
                end

                --查看另外一个农民能否 倒
                local nm=get_other_nm_seat_num()
                if m_data.zhua_data[m_data.seat_num]==0 then
                    nm2=nm
                end
                if not nm1 or not nm2 then
                    m_data.cur_p=nm1 or nm2
                end
            end
        else
            m_data.jb_permit_data=nil
        end
    end
end

function DdzTyModel.Init()
    InitMatchData()
    this=DdzTyModel
    this.tydfg_match_list=nil
    --收到tydfg_match_list的时间
    this.tydfg_match_list_time=nil
    this.InitUIConfig()
    MakeLister()
    this.AddMsgListener()

    update=Timer.New(this.Update,updateDt,-1,true)
    update:Start()

    return this
end
function DdzTyModel.Exit()
    if this then
        this.RemoveMsgListener()
        update:Stop()
        update=nil
        lister=nil
        m_data=nil
        this.data=nil
        this.tydfg_match_list=nil
        this.tydfg_match_list_time=nil
        this = nil
    end
end
function DdzTyModel.InitUIConfig()
    this.UIConfig={
        config = {},
        entrance = {},
    }
    local config = this.UIConfig.config
    local entrance = this.UIConfig.entrance

    for _,v in ipairs(UIConfig.config) do
        config[v.gameID] = config[v.gameID] or {}
        config[v.gameID]["gameModel"] = v.gameModel
    end
    for _,v in ipairs(UIConfig.entrance) do
        entrance[v.gameID] = entrance[v.gameID] or {}
        entrance[v.gameID][v.name] = v.value
    end
end


-- 根据游戏ID判断是否是练习场
function DdzTyModel.ClearMatchData(gameID)
    InitMatchData(gameID)
end

--
function DdzTyModel.on_tydfg_req_game_list_response(_,data)
    if data.result==0 then
        this.tydfg_match_list=data.tydfg_match_list
        --30秒后自动销毁
        this.tydfg_match_list_countdwon=3600
    end
    Event.Brocast("tydfgModel_tydfg_req_game_list_response",data.result)
end

--1.比赛报名结果 countdown:手动退出倒计时
function DdzTyModel.on_tydfg_signup_response(_, data)
    if data.result == 0 then
        m_data.countdown = data.countdown
        m_data.status = macth_status.wait_table
        m_data.game_model=data.game_model
        MainLogic.EnterGame()
        Event.Brocast("tydfgModel_tydfg_signup_response", data.result)
    else
        Event.Brocast("tydfgModel_tydfg_signup_fail_response", data.result)
    end
end

function DdzTyModel.on_tydfg_cancel_signup_response(_, data)
    if data.result==0 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        Event.Brocast("tydfgModel_tydfg_cancel_signup_response",data.result)
    else
        Event.Brocast("tydfgModel_tydfg_cancel_signup_fail_response",data.result)
    end
end

function DdzTyModel.on_tydfg_enter_room_msg(proto_name, data)
    m_data.status = macth_status.wait_p
    InitMatchStatusData(m_data.status)
    m_data.init_stake=data.room_info.init_stake
    m_data.init_rate=data.room_info.init_rate
    m_data.seat_num=data.room_info.seat_num

    m_data.seatNum={}
    m_data.s2cSeatNum={}
    tyDdzFunc.transform_seat(m_data.seatNum,m_data.s2cSeatNum,m_data.seat_num)

    m_data.my_rate=m_data.init_rate or 1
    m_data.win_count=data.win_count
    m_data.race = 1
    
    if data.players_info then
        for k, v in pairs(data.players_info.p_info) do
            m_data.players_info[v.seat_num] = v
        end
    end

    -- m_data.players_info[m_data.seat_num] = MainModel.UserInfo
    -- for k,v in pairs(MainModel.UserInfo) do
    --     if m_data.players_info[m_data.seat_num] then
    --         m_data.players_info[m_data.seat_num][k] = v
    --     end
    -- end
    Event.Brocast("tydfgModel_tydfg_enter_room_msg")
end

--其他玩家进入游戏
function DdzTyModel.on_tydfg_join_msg(proto_name, data)
    m_data.players_info[data.player_info.seat_num]=data.player_info
    Event.Brocast("tydfgModel_tydfg_join_msg",data.player_info.seat_num)
end

--6.进入游戏的人数达到3人，自动发牌,游戏开始，人数满足要求，发牌开局
function DdzTyModel.on_tydfg_pai_msg(proto_name, data)
    table.print("<color=green>发牌</color>",data)
    m_data.status=macth_status.fp
    m_data.remain_pai_amount=data.remain_pai_amount
    m_data.race=data.race
    local pai_list = {}
    for i=1,17 do
        pai_list[i] = -i
    end
    m_data.my_pai_list = pai_list
    Event.Brocast("tydfgModel_tydfg_pai_msg")
end

function DdzTyModel.on_tydfg_kan_my_pai_msg(proto_name, data)
    dump(data, "<color=yellow>看牌</color>")
    m_data.my_pai_list=data.my_pai_list
    table.sort(m_data.my_pai_list)
    m_data.race=data.race

    Event.Brocast("tydfgModel_tydfg_kan_my_pai_msg")

end
--8.权限信息轮询
function DdzTyModel.on_tydfg_permit_msg(proto_name, data)
    m_data.status=data.status
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown=(data.countdown-1)
    if m_data.countdown<0 then
        m_data.countdown=0
    end
    m_data.cur_p=data.cur_p
    
    get_my_jdz_permit_data()
    get_my_jb_permit_data()

    Event.Brocast("tydfgModel_tydfg_permit_msg")
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
    102：闷
    103：看牌
    104：抓牌
    105：不抓
    106：倒
    107：不倒
    108：拉
    109：不拉
]]
function DdzTyModel.on_tydfg_action_msg(proto_name, data)
    m_data.action_list[#m_data.action_list+1]=data.action

    local act_type = data.action.type
    --注意可能是断线重连  此时相应的数据可能还没有初始化  所以一定要判断数据是否存在
    --更新玩家手上剩余扑克牌的数量
    if  m_data.remain_pai_amount and act_type < 100 and data.action.cp_list then
        local nor_list=data.action.cp_list.nor
        local ty_list=data.action.cp_list.lz
        local len1=0
        local len2=0
        if nor_list then
            len1=#nor_list
        end
        if ty_list then
            len2=#ty_list
        end
        m_data.remain_pai_amount[data.action.p] = m_data.remain_pai_amount[data.action.p] - len1-len2
        if data.action.p ~=m_data.seat_num then 
            tyDdzFunc.jipaiqi(data.action.cp_list,m_data.jipaiqi)
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
                if tyDdzFunc.pai_map[no]==18 and len2>0 then
                    len2=len2-1
                elseif not hash[no] then
                    list[#list+1]=no
                end
            end
            m_data.my_pai_list=list
        end
    end
    if data.action.rate then
        m_data.my_rate = data.action.rate
    end

    --闷抓
    if act_type == 102 then
        m_data.men_data[data.action.p] = 2
    elseif act_type == 103 then
        m_data.men_data[data.action.p] = 1
    end

    if act_type == 104 then
        m_data.zhua_data[data.action.p] = 2
    elseif act_type == 105 then
        m_data.zhua_data[data.action.p] = 1
    end

    --倒,拉
    if act_type == 106 or act_type == 108 then
        m_data.p_dao_la[data.action.p] = 1
    elseif act_type == 107 or act_type == 109 then
        m_data.p_dao_la[data.action.p] = 0
    end

    --炸弹翻倍
    if m_data.my_rate and act_type>12 and act_type < 100  then
        local rate=2
        if (act_type ==17 or act_type == 18) then
            rate=4
        end
        m_data.my_rate = m_data.my_rate * rate
    end
    Event.Brocast("tydfgModel_tydfg_action_msg")
end

--7.确认地主位置
function DdzTyModel.on_tydfg_dizhu_msg(proto_name, data)
    m_data.status = macth_status.set_dz
    m_data.dizhu = data.dizhu
    Event.Brocast("tydfgModel_tydfg_dizhu_msg")
    
end
--确认地主牌
function DdzTyModel.on_tydfg_dizhu_pai_msg(proto_name, data)
    m_data.status = macth_status.set_dz
    m_data.dz_pai = data.dz_pai
    local seat_num = m_data.dizhu
    m_data.remain_pai_amount[seat_num]=m_data.remain_pai_amount[seat_num]+ #data.dz_pai
    if seat_num==m_data.seat_num then
        for i=1,#data.dz_pai do
            m_data.my_pai_list[#m_data.my_pai_list+1]=data.dz_pai[i]
        end
        table.sort(m_data.my_pai_list)
    end

    --初始化记牌器
    m_data.jipaiqi=tyDdzFunc.getAllPaiCount()
    tyDdzFunc.jipaiqi({nor=m_data.my_pai_list},m_data.jipaiqi)
    Event.Brocast("tydfgModel_tydfg_dizhu_pai_msg")
end

--托管--
function DdzTyModel.on_tydfg_auto_msg(proto_name, data)
    m_data.auto_status[data.p] = data.auto_status
    Event.Brocast("tydfgModel_tydfg_auto_msg",data.p)
end

--自动踢出--
function DdzTyModel.on_tydfg_auto_cancel_signup_msg(proto_name, data)
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("tydfgModel_tydfg_auto_cancel_signup_msg",data.result)
end

--11.打完一局重新发牌
function DdzTyModel.on_tydfg_new_game_msg(proto_name, data)
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    m_data.race =data.race
    m_data.curr_all_player =data.curr_all_player
    Event.Brocast("tydfgModel_tydfg_new_game_msg")
end

--13.比赛结束
function DdzTyModel.on_tydfg_gameover_msg(proto_name, data)
    m_data.status = macth_status.gameover
    m_data.settlement_info = data.settlement_info
    if  m_data.settlement_info.chuntian and m_data.settlement_info.chuntian>0 then
        m_data.my_rate=m_data.my_rate*2
    end
    for i=1,3 do
        m_data.players_info[i].jing_bi = m_data.players_info[i].jing_bi + data.settlement_info.award[i]
    end
    -- MainLogic.ExitGame()
    Event.Brocast("tydfgModel_tydfg_gameover_msg")
end

--14.都没有叫地主重新开始
function DdzTyModel.on_tydfg_start_again_msg(proto_name, data)
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    Event.Brocast("tydfgModel_tydfg_start_again_msg")
end

function DdzTyModel.on_tydfg_status_info(proto_name, data)
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
        m_data.men_data=s.men_data
        m_data.zhua_data=s.zhua_data
        m_data.p_dao_la = s.p_dao_la
        calDizhuBaserate()
    end
    Event.Brocast("tydfgModel_tydfg_status_info")
end

function DdzTyModel.on_tydfg_all_info(proto_name, data)
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
            m_data.race=s.race
            m_data.seat_num=s.seat_num

            m_data.seatNum={}
            m_data.s2cSeatNum={}
            tyDdzFunc.transform_seat(m_data.seatNum,m_data.s2cSeatNum,m_data.seat_num)

            m_data.dizhu=s.dizhu
            m_data.dz_pai=s.dz_pai
            m_data.jipaiqi=s.jipaiqi
            m_data.win_count=s.win_count
            m_data.men_data=s.men_data
            m_data.zhua_data=s.zhua_data
            calDizhuBaserate()

            m_data.men_data=s.men_data
            m_data.zhua_data=s.zhua_data
            m_data.p_dao_la = s.p_dao_la
            get_my_jdz_permit_data()
            get_my_jb_permit_data()

            if m_data.status==macth_status.gameover then 
                MainLogic.ExitGame() 
            end
            
        end
        s=data.match_info
        if s then
            m_data.name=s.name
            m_data.game_model=s.game_model
        end

        s=data.room_info
        if s then
            m_data.init_stake=s.init_stake
            m_data.init_rate=s.init_rate
            m_data.hallGameID = s.game_id
        end

        s=data.players_info
        if s then
            s=s.p_info
            for k,v in pairs(s) do
                m_data.players_info[v.seat_num]=v
            end
        end

        -- for k,v in pairs(MainModel.UserInfo) do
        --     if m_data.players_info[m_data.seat_num] then
        --         m_data.players_info[m_data.seat_num][k] = v
        --     end
        -- end

        m_data.settlement_info=data.settlement_info
        if m_data.settlement_info then
            this.GetSettlementRateShowData()
            for i=1,3 do
                if i ~= m_data.seat_num then
                    m_data.players_info[i].jing_bi = m_data.players_info[i].jing_bi + m_data.settlement_info.award[i]
                end
            end
        end
    end
    Event.Brocast("tydfgModel_tydfg_all_info")
end

--再玩一把
function DdzTyModel.on_tydfg_replay_game_response(proto_name,data)
    if data.result == 0 then
        this.on_tydfg_signup_response(proto_name,data)
    else
        local msg = errorCode[data.result] or ("错误："..data.result)
        HintPanel.Create(1, msg, function ()
            --清除数据
            InitMatchData()
            MainLogic.ExitGame()
            DdzTyLogic.change_panel("DdzTyHallPanel")
        end)
    end
end

--退出游戏
function DdzTyModel.on_tydfg_quit_game_response(proto_name,data)
    if data.result==0 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        DdzTyLogic.change_panel("DdzTyHallPanel")
    else

    end
end

-- 玩家自己是否胜利
function DdzTyModel.IsMyWin()
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
        mz = "mz", -- 闷抓阶段
        zp = "zp", -- 抓牌
        dao = "dao", -- 倒
        la = "la", -- 拉
        cp = "cp", --cp： 出牌
        “cp”   (数据为 是否必须出，有无够大的牌power)

        {type,is_must,power,jdz_min}
--]]
function DdzTyModel.getMyPermitData()
    if m_data then
        if m_data.cur_p and m_data.cur_p==m_data.seat_num then
            if m_data.status==macth_status.jdz then
                return {type=macth_status.jdz} 
            elseif m_data.status==macth_status.jiabei then
                return {type=macth_status.jiabei}
            elseif m_data.status==macth_status.cp then
                --判断是否为必须出牌
                local is_must=tyDdzFunc.is_must_chupai(m_data.action_list)
                --判断是否有够大的牌
                local power=0
                if not is_must then
                    power=tyDdzFunc.check_cp_capacity_by_pailist(m_data.action_list,m_data.my_pai_list,m_data.remain_pai_amount[m_data.seat_num])
                end
                return {type=macth_status.cp,is_must=is_must,power=power}
            end
        end

    end
    return nil
end

-- 练习场下一个奖励差几个胜场 以及 最近一次奖励的索引(默认索引为1)
function DdzTyModel.getNextAward(winCount)
    local currAwardIndex = 1
    for i,v in ipairs(this.UIConfig.award) do
        if v.win_count > winCount then
            return v.win_count - winCount, currAwardIndex
        end
        currAwardIndex = i
    end
    return 0, currAwardIndex
end

--闷抓倍数
function DdzTyModel.GetMenZhuaRate()
    if m_data and m_data.men_data then
       return m_data.men_data[m_data.dizhu] == 2 and 2 or 1
    end
end

-- 炸弹
function DdzTyModel.GetZhadanBeishu()
    if m_data and m_data.settlement_info then
        if m_data.settlement_info.bomb_count > 0 then
            return math.pow(2, m_data.settlement_info.bomb_count)
        end
    end
    return 0
end

-- 春天
function DdzTyModel.GetCTBeishu()
    if m_data and m_data.settlement_info then
        if m_data.settlement_info.chuntian > 0 then
            return 2
        end
    end
    return 0
end

--地主是否是闷抓
function DdzTyModel.IsMenZhua()
    if m_data and m_data.men_data then
        return m_data.men_data[m_data.dizhu] == 2
    end
end

--我自己是否倒
function DdzTyModel.IsDao()
    if m_data and m_data.p_dao_la then
        return m_data.p_dao_la[m_data.seat_num] == 1
    end
end

--地主是否拉
function DdzTyModel.IsLa()
    if m_data and m_data.p_dao_la then
        return m_data.p_dao_la[m_data.dizhu] == 1
    end
end

--倒的人数
function DdzTyModel.GetDaoNum()
    local num = 0
    for i,v in ipairs(m_data.p_dao_la) do
        if i ~= m_data.dizhu and m_data.p_dao_la[i] == 1 then
            num = num + 1
        end
    end
    return num
end

function DdzTyModel.GetSettlementRateShowData()
    local base_rate=1
    DdzTyModel.settlementRateShowData={}
    local data=DdzTyModel.settlementRateShowData
    --[[
    zhua_pai --抓牌的倍率
    dao=
    la=
    zhadan=
    chuntian=
    all=
    --]]

    --zhadan
    data.zhadan = this.GetZhadanBeishu()
    --chuntian
    data.chuntian = this.GetCTBeishu()
    print("<color=green>结算时的位置:</color>",m_data.dizhu,m_data.seat_num)
    if m_data.dizhu ~= m_data.seat_num  then
        --men   
        if this.IsMenZhua() then
            data.men_pai= 2
        else
            data.men_pai = 1
        end
        if this.IsDao() then
            data.dao = 2
            if this.IsLa() then
                data.la = 2
            end
        end

        data.all = data.men_pai * (data.dao or 1) * (data.la or 1)
        if data.zhadan ~= 0 then
            data.all = data.all * data.zhadan
        end
        if data.chuntian ~= 0 then
            data.all = data.all * data.chuntian

        end
    else --地主
        --men 
        if this.IsMenZhua() then
            data.men_pai= 4 
        else
            data.men_pai= 2
        end
        local daoNum = this.GetDaoNum()
        if daoNum > 0 then
            if data.men_pai==4 then
                data.dao = daoNum *2
            else
                data.dao = daoNum
            end
            if this.IsLa() then
                data.la = data.dao * 2
            end
        end

        --all
        data.all = data.men_pai + (data.dao or 0) + (data.la or 0)
        if data.zhadan ~= 0 then
            data.all = data.all * data.zhadan
        end
        if data.chuntian ~= 0 then
            data.all = data.all * data.chuntian

        end
    end

    return data
end

-- 判断是否能进入
function DdzTyModel.IsRoomEnter(id)
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
function DdzTyModel.IsAgainRoomEnter(id)
    local v = DdzTyModel.UIConfig.entrance[id]
    
    local dd = MainModel.UserInfo.jing_bi
    if DdzTyModel.UIConfig.config[id] and DdzTyModel.UIConfig.config[id].gameModel == 1 then
        if v.min_coin > 0 and dd < v.min_coin then
            return 1 -- 过高
        end
    else
        dump(id, "<color=red>DdzTyModel id</color>")        
        dump(DdzTyModel.UIConfig.config, "<color=red>DdzTyModel config</color>")
    end
    return 0
end

local maxPlayerNumber = 3
-- 返回自己的座位号
function DdzTyModel.GetPlayerSeat ()
    return m_data.seat_num
end
-- 返回自己的UI位置
function DdzTyModel.GetPlayerUIPos ()
    return DdzTyModel.GetSeatnoToPos (m_data.seat_num)
end
-- 根据座位号获取玩家UI位置
function DdzTyModel.GetSeatnoToPos (seatno)
    local seftSeatno = DdzTyModel.GetPlayerSeat()
    return (seatno - seftSeatno + maxPlayerNumber) % maxPlayerNumber + 1
end
-- 根据UI位置获取玩家座位号
function DdzTyModel.GetPosToSeatno (uiPos)
    local seftSeatno = DdzTyModel.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % maxPlayerNumber + 1
end

-- 根据UI位置获取玩家座位号
function DdzTyModel.GetPosToPlayer (uiPos)
    local seatno = DdzTyModel.GetPosToSeatno (uiPos)
    return m_data.players_info[seatno]
end

-- 是否是自己 玩家自己的UI位置在1号位
function DdzTyModel.IsPlayerSelf (uiPos)
    return uiPos == 1
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function DdzTyModel.GetAnimChatShowPos (id)
    if m_data and m_data.players_info then
        for k,v in ipairs(m_data.players_info) do
            if v.id == id then
                local uiPos = DdzTyModel.GetSeatnoToPos (v.seat_num)
                if DdzTyModel.data.dizhu and DdzTyModel.data.dizhu > 0 then
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