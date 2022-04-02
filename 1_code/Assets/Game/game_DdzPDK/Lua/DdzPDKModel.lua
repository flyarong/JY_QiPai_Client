--[[
正常消息是指除断线重连以外的消息
]]
local nor_ddz_base_lib = require "Game.normal_ddz_common.Lua.nor_pdk_base_lib"
local nor_ddz_algorithm_lib = require "Game.normal_ddz_common.Lua.nor_pdk_algorithm_lib"

local FreeAwardConfig = require "Game.game_DdzPDK.Lua.ddz_pdk_drivingrange_award" --奖励配置

DdzPDKModel = {}
DdzPDKModel.maxPlayerNumber = 3
DdzPDKModel.game_type = {
    nor = "nor_ddz_nor",
    lz = "nor_ddz_lz",
    er = "nor_ddz_er",
    pdk = "nor_pdk_nor",
}

DdzPDKModel.jdz_type = {
    nor = "nor",
    mld = "mld"
}

DdzPDKModel.Model_Status = {
    --等待分配桌子，疯狂匹配中
    wait_table = "wait_table",
    --报名成功，在桌子上等待开始游戏
    wait_begin = "wait_begin",
    --游戏状态处于游戏中
    gaming = "gaming",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

DdzPDKModel.Status = {
    ready="ready", -- 准备状态
    --等待人员入座
    wait_join = "wait_join",
    --发牌
    fp = "fp",
    --叫地主
    jdz = "jdz",
    --设置地主，
    set_dz = "set_dz",
    --加倍
    jiabei = "jiabei",
    --出牌
    cp = "cp",
    --结算
    settlement = "settlement",
    --结束
    gameover = "gameover",
    --玩家进入托管状态
    auto = "auto",
    --抢地主
    q_dizhu = "q_dizhu",
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
    
    --response
    lister["fg_signup_response"] = this.on_fg_signup_response
    lister["fg_switch_game_response"] = this.on_fg_switch_game_response
    lister["fg_cancel_signup_response"] = this.on_fg_cancel_signup_response
    lister["fg_replay_game_response"] = this.on_fg_replay_game_response
    lister["fg_quit_game_response"] = this.on_fg_quit_game_response
    lister["fg_huanzhuo_response"] = this.on_fg_huanzhuo_response
    lister["fg_ready_response"] = this.on_fg_ready_response

    --玩法
    lister["nor_pdk_nor_status_info"] = this.on_nor_pdk_nor_status_info
    lister["nor_pdk_nor_ready_msg"] = this.on_nor_pdk_nor_ready_msg
    lister["nor_pdk_nor_begin_msg"] = this.on_nor_pdk_nor_begin_msg
    lister["nor_pdk_nor_pai_msg"] = this.on_nor_pdk_nor_pai_msg
    lister["nor_pdk_nor_permit_msg"] = this.on_nor_pdk_nor_permit_msg
    lister["nor_pdk_nor_action_msg"] = this.on_nor_pdk_nor_action_msg
    lister["nor_pdk_nor_dizhu_msg"] = this.on_nor_pdk_nor_dizhu_msg
    lister["nor_pdk_nor_show_pai_msg"] = this.on_nor_pdk_nor_show_pai_msg
    lister["nor_pdk_nor_laizi_msg"] = this.on_nor_pdk_nor_laizi_msg
    lister["nor_pdk_nor_auto_msg"] = this.on_nor_pdk_nor_auto_msg
    lister["nor_pdk_nor_new_game_msg"] = this.on_nor_pdk_nor_new_game_msg
    lister["nor_pdk_nor_start_again_msg"] = this.on_nor_pdk_nor_start_again_msg
    lister["nor_pdk_nor_settlement_msg"] = this.on_nor_pdk_nor_settlement_msg
    lister["nor_ddz_mld_kan_my_pai_msg"] = this.on_nor_ddz_mld_kan_my_pai_msg
    lister["nor_ddz_mld_dizhu_pai_msg"] = this.on_nor_ddz_mld_dizhu_pai_msg
    lister["nor_pdk_nor_bomb_settlement_msg"] = this.on_nor_pdk_nor_bomb_settlement_msg

    --资产改变
    lister["AssetChange"] = this.AssetChange
end

local function MsgDispatch(proto_name, data)
    -- dump(data, "<color=red>proto_name:</color>" .. proto_name)
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

--注册斗地主正常逻辑的消息事件
function DdzPDKModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        if proto_name == "AssetChange" then
            Event.AddListener(proto_name, _)
        else
            Event.AddListener(proto_name, MsgDispatch)
        end
    end
end

--删除斗地主正常逻辑的消息事件
function DdzPDKModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        if proto_name == "AssetChange" then
            Event.RemoveListener(proto_name, _)
        else
            Event.RemoveListener(proto_name, MsgDispatch)
        end
    end
end

function DdzPDKModel.Update()
    if m_data then
        if m_data.countdown and m_data.countdown > 0 then
            m_data.countdown = m_data.countdown - updateDt
            if m_data.countdown < 0 then
                m_data.countdown = 0
            end
        end
    end
end

local function InitMatchData(gameID)
    if not DdzPDKModel.baseData then
        DdzPDKModel.baseData = {}
    end
    DdzPDKModel.data = {
        --游戏名
        name = nil,
        --0是练习场  1是跑得快
        game_model = nil,
        --fg_room_info****
        --房间数据信息
        room_id = nil, --当前房间ID
        table_num = nil, --当前房间中桌子位置
        --当前游戏状态（详细说明见文件顶部注释：斗地主状态表status）
        status = nil,
        --在以上信息相同时，判定具体的细节状态；+1递增
        status_no = 0,
        --倒计时
        countdown = 0,
        --当前的权限拥有人
        cur_p = nil,
        --玩家是否已经加倍
        jiabei = 0,
        --我的牌列表
        my_pai_list = nil,
        --每个人剩余的牌数量
        remain_pai_amount = nil,
        --我的倍数
        my_rate = 1,
        --玩家的托管状态
        auto_status = {},
        --当前局数
        race = nil,
        --我的座位号
        seat_num = nil,
        --地主座位号
        dizhu = nil,
        --地主牌
        dz_pai = nil,
        --玩家操作列表
        action_list = {},
        --fg_players_info***
        players_info = {}, --当前房间中玩家的信息(key=seat_num, value=玩家基础信息)
        settlement_info = nil,
        settlement_players_info=nil,
        --客户端辅助数据***********
        --当前的地主分数
        base_rate = 0,
        --记牌器
        jipaiqi = nil,
        --赖子牌
        laizi = 0,
        -- 抢地主次数
        er_qiang_dizhu_count = 0,

        -- -1 还没开始  0没有倒拉 1倒或拉了
        dao_la_data = nil,
        --0未操作过  1-不操作  2-是操作
        men_data=nil,
        zhua_data=nil,
        ls_count = 1,
    }
    m_data = DdzPDKModel.data
end

local function InitMatchStatusData(status)
    m_data.status = status
    --倒计时
    m_data.countdown = 0
    --当前的权限拥有人
    m_data.cur_p = nil
    --玩家是否已经加倍
    m_data.jiabei = 0
    --我的牌列表
    m_data.my_pai_list = nil
    --每个人剩余的牌数量
    m_data.remain_pai_amount = nil
    --我的倍数
    local init_rate = 1
    if m_data.init_rate then
        init_rate = m_data.init_rate
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
    --结算数据
    m_data.settlement_info = nil
    m_data.settlement_players_info = nil
    --记牌器
    m_data.jipaiqi = nil
    --赖子
    m_data.laizi = 0
    -- 抢地主次数
    m_data.er_qiang_dizhu_count = 0
    -- 废牌
    m_data.deadwood_list = nil

    --闷拉倒
    m_data.men_data={0,0,0}
    m_data.zhua_data={0,0,0}
    m_data.dao_la_data = {-1,-1,-1}
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
   m_data.is_must_mld_opt = nil
end

local function InitMatchRoomData(status)
    InitMatchStatusData(status)
    room_id = nil
    table_num = nil
    players_info = {}
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

--闷拉倒
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
    if m_data and DdzPDKModel.baseData.jdz_type == DdzPDKModel.jdz_type.mld then
        if m_data.status== DdzPDKModel.Status.jdz and m_data.cur_p==m_data.seat_num then
            
            --未看牌
            if m_data.men_data[m_data.seat_num]==0 then
                m_data.jdz_permit_data = {kan = true, men = true}
                if m_data.is_must_mld_opt and m_data.is_must_mld_opt == 1 then
                    m_data.jdz_permit_data.kan = false
                end
            else
                --已看牌
                m_data.jdz_permit_data={zhua=true}
                --检查我是否必抓
                dump(m_data.is_must_mld_opt, "<color=red>proto == m_data.is_must_mld_opt</color>")
                if not m_data.is_must_mld_opt or (m_data.is_must_mld_opt and m_data.is_must_mld_opt == 0)then
                    m_data.jdz_permit_data.buzhua=true
                end
                -- m_data.jdz_permit_data.buzhua = true
            end
        else
            m_data.jdz_permit_data=nil
        end
    end
end
local function get_my_jb_permit_data()
    if m_data and DdzPDKModel.baseData.jdz_type == DdzPDKModel.jdz_type.mld then
        if m_data.status== DdzPDKModel.Status.jiabei and (m_data.cur_p==m_data.seat_num or (m_data.cur_p==4 and m_data.dizhu~=m_data.seat_num )) then
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
                    if m_data.men_data[m_data.dizhu]==2 or not m_data.is_must_mld_opt or (m_data.is_must_mld_opt and m_data.is_must_mld_opt == 0) then
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
--闷拉倒end

function DdzPDKModel.InitGameData()
    if not m_data then
        print("<color=red>InitGameData m_data nil</color>")
        return
    end
    print("<color=red>InitGameData m_data 重置</color>")
    m_data.countdown = 0
    m_data.cur_p = nil
    m_data.jiabei=0
    m_data.my_pai_list =nil
    m_data.remain_pai_amount=nil
    m_data.my_rate =1
    m_data.auto_status = nil
    m_data.dizhu =nil
    m_data.dz_pai =nil
    m_data.laizi=0
    m_data.action_list ={}
    m_data.settlement_info =nil
    m_data.settlement_players_info = nil
    m_data.base_rate=0
    m_data.jipaiqi=nil
    -- 抢地主次数
    m_data.er_qiang_dizhu_count = 0
    -- 废牌
    m_data.deadwood_list = nil
    m_data.glory_score_count = nil
    m_data.glory_score_change = nil
    --闷拉倒
    m_data.men_data={0,0,0}
    m_data.zhua_data={0,0,0}
    m_data.dao_la_data = {-1,-1,-1}
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
   m_data.is_must_mld_opt = nil
   m_data.ls_count = 1
end

function DdzPDKModel.Init()
    InitMatchData()
    this = DdzPDKModel
    this.InitUIConfig()
    MakeLister()
    this.AddMsgListener()
    update = Timer.New(DdzPDKModel.Update, updateDt, -1, true)
    update:Start()
    return this
end

function DdzPDKModel.Exit()
    if this then
        DdzPDKModel.RemoveMsgListener()
        update:Stop()
        update = nil
        this = nil
        lister = nil
        m_data = nil
        DdzPDKModel.data = nil
    end
end

function DdzPDKModel.InitUIConfig()
    this.UIConfig = {
        award = {},
    }
    local award = this.UIConfig.award
    for _, v in ipairs(FreeAwardConfig.award_cfg) do
        award[v.id] = v
    end
end

--********************response
--1.比赛报名结果
function DdzPDKModel.on_fg_signup_response(_, data)
    dump(data, "<color=red>proto == on_fg_signup_response</color>")
    if data.result == 0 then
        DdzPDKModel.InitGameData()
        m_data.model_status = DdzPDKModel.Model_Status.wait_table
        m_data.status = nil
        m_data.players_info = {}

        m_data.countdown = data.cancel_signup_cd
        m_data.game_model = data.game_model
        DdzPDKModel.baseData.game_type = data.game_type
        MainLogic.EnterGame()
        Event.Brocast("model_fg_signup_response", data.result)
        Event.Brocast("activity_fg_signup_msg")
    end
end
function DdzPDKModel.on_fg_switch_game_response(proto_name, data)
    DdzPDKModel.on_fg_signup_response(proto_name, data)
end

function DdzPDKModel.on_fg_cancel_signup_response(_, data)
    dump(data, "<color=red>proto == on_fg_cancel_signup_response</color>")
    if data.result == 0 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        Event.Brocast("model_fg_cancel_signup_response", data.result)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--退出游戏
function DdzPDKModel.on_fg_quit_game_response(proto_name, data)
    dump(data, "<color=red>proto == on_fg_quit_game_response</color>")
    if data.result == 0 then
        --清除数据
        local game_id = DdzPDKModel.baseData.game_id

        InitMatchData()
        MainLogic.ExitGame()

        local ui_config = GameFreeModel.GetGameIDToConfig(game_id)
        if ui_config then
            DdzPDKLogic.change_panel(DdzPDKLogic.panelNameMap.hall)
        else
            dump(game_id, "<color=red>DdzPDKModel config</color>")
        end
    else
        HintPanel.ErrorMsg(data.result)
    end

    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end

--换桌
function DdzPDKModel.on_fg_huanzhuo_response(proto_name, data)
    dump(data, "<color=red>proto == on_fg_huanzhuo_response</color>")
    Event.Brocast("fg_huanzhuo_response_code", data.result)
    if data.result == 0 then
        DdzPDKModel.InitGameData()
        m_data.model_status = DdzPDKModel.Model_Status.wait_table
        m_data.status = nil
        m_data.players_info = {}
        Event.Brocast("model_fg_huanzhuo_response")
    end
end

-- 准备
function DdzPDKModel.on_fg_ready_response(_, data)
    dump(data, "<color=red>proto == on_fg_ready_response</color>")
    Event.Brocast("fg_ready_response_code", data.result)
    if data.result == 0 then
        DdzPDKModel.InitGameData()
        m_data.model_status = DdzPDKModel.Model_Status.wait_begin
        m_data.status = nil
        if m_data.players_info[m_data.seat_num] then
            m_data.players_info[m_data.seat_num].ready = 1
        end
        Event.Brocast("model_fg_ready_response")
    end
end

--再玩一把
function DdzPDKModel.on_fg_replay_game_response(proto_name, data)
    dump(data, "<color=red>on_fg_replay_game_response</color>")
    if data.result == 0 then
        DdzPDKModel.on_fg_signup_response(proto_name, data)
    else
        local msg = errorCode[data.result] or ("错误：" .. data.result)
        HintPanel.Create(
            1,
            msg,
            function()
                --清除数据
                InitMatchData()
                MainLogic.ExitGame()
                DdzPDKLogic.change_panel(DdzPDKLogic.panelNameMap.hall)
            end
        )
    end
end

--***********************DdzPDK
--所有数据
function DdzPDKModel.on_fg_all_info(proto_name, data)
    dump(data, "<color=red>proto == on_fg_all_info</color>")
    if data.status_no == -1 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        DdzPDKLogic.change_panel(DdzPDKLogic.panelNameMap.hall)
    else
        local s = data
        if s then
            m_data.model_status = s.status
            DdzPDKModel.baseData.game_type = s.game_type
            DdzPDKModel.baseData.jdz_type = s.jdz_type
            m_data.countdown = s.countdown

            DdzPDKModel.data = DdzPDKModel.data and DdzPDKModel.data or {}
            --转化成算法需要的配置数据
            DdzPDKModel.translate_config = {kaiguan = nor_ddz_base_lib.KAIGUAN, multi = {}}
            nor_ddz_base_lib.set_game_type(DdzPDKModel.baseData.game_type)
            --初始化算法库
            DdzPDKModel.ddz_algorithm = nor_ddz_algorithm_lib.New(DdzPDKModel.translate_config.kaiguan, DdzPDKModel.baseData.game_type)
            
            DdzPDKModel.SetMaxPlayerNum(DdzPDKModel.baseData.game_type)
        end

        s = data.room_info
        if s then
            m_data.init_stake = s.init_stake
            m_data.init_rate = s.init_rate
            if m_data.base_rate == 0 then m_data.my_rate = s.init_rate end
            DdzPDKModel.baseData.game_id = s.game_id
        end

        s = data.players_info
        if s then
            for k, v in pairs(s) do
                m_data.players_info[v.seat_num] = v
                if v.id == MainModel.UserInfo.user_id then
                    m_data.seat_num = v.seat_num
                end
            end
        end
        -- 结算界面的player
        m_data.settlement_players_info = data.settlement_players_info

        m_data.seatNum = {}
        m_data.s2cSeatNum = {}
        nor_ddz_base_lib.transform_seat(
            m_data.seatNum,
            m_data.s2cSeatNum,
            m_data.seat_num,
            DdzPDKModel.maxPlayerNumber
        )

        DdzPDKModel.baseData.room_rent = data.room_rent

        s = data.nor_pdk_nor_status_info
        if m_data.seat_num and s then
            m_data.status = s.status
            m_data.countdown = s.countdown
            m_data.cur_p = s.cur_p
            m_data.er_qiang_dizhu_count = s.er_qiang_dizhu_count or 0
            m_data.rangpai_num = s.rangpai_num
            m_data.my_pai_list = s.my_pai_list
            if m_data.my_pai_list then
                table.sort(m_data.my_pai_list)
            end
            m_data.remain_pai_amount = s.remain_pai_amount
            m_data.my_rate = s.my_rate
            m_data.action_list = s.act_list
            m_data.auto_status = s.auto_status
            m_data.race = s.cur_race

            m_data.dizhu = s.dizhu
            m_data.dz_pai = s.dz_pai
            m_data.jipaiqi = s.jipaiqi
            m_data.win_count = s.win_count
            m_data.laizi = s.laizi or 0
            calDizhuBaserate()
            m_data.settlement_info = s.settlement_info
            if DdzPDKModel.baseData.game_type == DdzPDKModel.game_type.er then
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
            --闷拉倒
            if DdzPDKModel.baseData.jdz_type == DdzPDKModel.jdz_type.mld then
                m_data.men_data=s.men_data
                m_data.zhua_data=s.zhua_data
                m_data.dao_la_data = s.dao_la_data
                m_data.is_must_mld_opt = s.is_must_mld_opt
                get_my_jdz_permit_data()
                get_my_jb_permit_data()
            end
        end
        m_data.glory_score_count = data.glory_score_count
        m_data.glory_score_change = data.glory_score_change
        m_data.exchange_hongbao = data.exchange_hongbao
        Event.Brocast("model_sjjbjl_msg", data.random_jingbi_box)
        Event.Brocast("model_act_028_djms_msg", {ad_award = data.ad_award, count=data.avoid_lose_ad_award})
        Event.Brocast("model_act_028_djhs_msg", {ad_award = data.ad_award, count=data.game_win_ad_award})
        if data.activity_data then
            m_data.activity_data = data.activity_data
            DdzPDKModel.GetLSCount(data.activity_data)
        else
            m_data.activity_data = nil
            m_data.ls_count = 1
        end
        --测试代码
        -- m_data.activity_data = {
        --     {key= "activity_id",value = 3},
        --     {key= "cs_seat",value = 1},
        --     {key= "jing_bi",value = 10000},
        --     {key= "cs_is_win",value = 0},
        --     {key= "seat_1",value = 0},
        -- }
    end

    if m_data then
        Event.Brocast("activity_fg_all_info",{activity_data = m_data.activity_data,game_type = DdzPDKModel.baseData.game_type, game_id = DdzPDKModel.baseData.game_id,model_status = m_data.model_status,status = m_data.status})
        local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = DdzPDKModel.baseData.game_id,activity_type = ActivityType.Consecutive_Win}, "CheckIsActivated")
        local is_true = a and b
        if is_true and m_data.model_status == DdzPDKModel.Model_Status.gameover then
            Event.Brocast("activity_fg_gameover_msg")
        end
    end
    Event.Brocast("model_fg_all_info")
end

--进入房间
function DdzPDKModel.on_fg_enter_room_msg(proto_name, data)
    dump(data, "<color=red>proto == on_fg_enter_room_msg</color>")
    m_data.model_status = DdzPDKModel.Model_Status.gaming
    m_data.status = DdzPDKModel.Status.wait_join
    InitMatchStatusData(m_data.status)
    m_data.deadwood_list = nil
    for k, v in pairs(data.players_info) do
        m_data.players_info[v.seat_num] = v
        if v.id == MainModel.UserInfo.user_id then
            m_data.seat_num = v.seat_num
        end
    end
    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    nor_ddz_base_lib.transform_seat(m_data.seatNum, m_data.s2cSeatNum, m_data.seat_num, DdzPDKModel.maxPlayerNumber)
    m_data.my_rate = m_data.init_rate or 1
    m_data.race = 1
    if m_data.seat_num then
        Event.Brocast("model_fg_enter_room_msg")
        Event.Brocast("activity_fg_enter_room_msg")
    end
end

--其他玩家进入游戏
function DdzPDKModel.on_fg_join_msg(proto_name, data)
    dump(data, "<color=red>proto == on_fg_join_msg</color>")
    m_data.players_info[data.player_info.seat_num] = data.player_info
    Event.Brocast("model_fg_join_msg", data.player_info.seat_num)
    Event.Brocast("activity_fg_join_msg", data.player_info.seat_num)
end

--其他玩家离开游戏
function DdzPDKModel.on_fg_leave_msg(proto_name, data)
    dump(data, "<color=red>proto == on_fg_leave_msg</color>")
    m_data.players_info[data.seat_num] = nil
    Event.Brocast("model_fg_leave_msg", data.seat_num)
    Event.Brocast("activity_fg_leave_msg", data.seat_num)
end

--分数改变
function DdzPDKModel.on_fg_score_change_msg(proto_name, data)
    dump(data, "<color=red>proto == 分数改变</color>")
    m_data.score = data.score
    if m_data.players_info[m_data.seat_num] then
        m_data.players_info[m_data.seat_num].score = data.score
    end
    Event.Brocast("model_fg_score_change_msg")
end

--比赛结束
function DdzPDKModel.on_fg_gameover_msg(proto_name, data)
    dump(data, "<color=red>比赛结束</color>")
    m_data.model_status = DdzPDKModel.Model_Status.gameover
    m_data.status = DdzPDKModel.Status.gameover    
    for k, v in pairs(m_data.players_info) do
        v.ready = 0
    end
    
    m_data.glory_score_count = data.glory_score_count
    m_data.glory_score_change = data.glory_score_change
    m_data.exchange_hongbao = data.exchange_hongbao

    if m_data.exchange_hongbao and m_data.exchange_hongbao.is_exchanged == 0 then
        ExtendSoundManager.PlaySound(audio_config.game.bgm_jinbizhuanhongbao.audio_name)
    end

    Event.Brocast("model_fg_gameover_msg")
    Event.Brocast("activity_fg_gameover_msg")
    Event.Brocast("model_sjjbjl_msg", data.random_jingbi_box)
    Event.Brocast("model_act_028_djms_msg", {ad_award = data.ad_award, count=data.avoid_lose_ad_award})
    Event.Brocast("model_act_028_djhs_msg", {ad_award = data.ad_award, count=data.game_win_ad_award})
    -- MainLogic.ExitGame()
end

function DdzPDKModel.on_fg_auto_cancel_signup_msg(proto_name, data)
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_cancel_signup_msg")
end

---- 自动退出游戏报名
function DdzPDKModel.on_fg_auto_quit_game_msg(proto_name, data)
    dump(data, "<color=>on_fg_auto_quit_game_msg</color>")
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_quit_game_msg")
end

---- 准备
function DdzPDKModel.on_fg_ready_msg(proto_name, data)
    local seatno = data.seat_num
    if m_data.players_info[seatno] then
        m_data.players_info[seatno].ready = 1
    end

    Event.Brocast("model_fg_ready_msg", seatno)
    Event.Brocast("activity_fg_ready_msg", seatno)
end

---- 活动数据更新
function DdzPDKModel.on_fg_activity_data_msg(proto_name, data)
    dump(data, "<color=red>proto == ------------on_fg_activity_data_msg--------------</color>")
    if data.activity_data then
        m_data.activity_data = data.activity_data
        DdzPDKModel.GetLSCount(data.activity_data)
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
                Event.Brocast("activity_fg_all_info",{activity_data = m_data.activity_data,game_type = DdzPDKModel.baseData.game_type, game_id = DdzPDKModel.baseData.game_id,model_status = m_data.model_status,status = m_data.status})
                if not m_ad.cs_is_win then
                    --游戏开始时的数据更新
                    Event.Brocast("activity_nor_begin_msg")
                else
                    --游戏结算时的数据更新
                    Event.Brocast("activity_nor_settlement_msg")
                end    
            end
        else
            Event.Brocast("activity_fg_activity_data_msg", {activity_data = m_data.activity_data,game_type = DdzPDKModel.baseData.game_type, game_id = DdzPDKModel.baseData.game_id})
        end
    end
end

--***************************nor
--状态信息
function DdzPDKModel.on_nor_pdk_nor_status_info(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_status_info</color>")
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
        m_data.jipaiqi = s.jipaiqi
        m_data.win_count = s.win_count
        m_data.men_data=s.men_data
        m_data.zhua_data=s.zhua_data
        m_data.dao_la_data = s.dao_la_data
        calDizhuBaserate()
    end
    Event.Brocast("model_nor_pdk_nor_status_info")
end

function DdzPDKModel.on_nor_pdk_nor_ready_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_ready_msg</color>")
end

function DdzPDKModel.on_nor_pdk_nor_begin_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_begin_msg</color>")
    -- Event.Brocast("model_nor_pdk_nor_begin_msg")

    --测试代码
    -- m_data.activity_data = {
    --     {key= "activity_id",value = 3},
    --     {key= "cs_seat",value = 1},
    -- }
    -- Event.Brocast("fg_activity_data_msg","fg_activity_data_msg",m_data)
end

--发牌
function DdzPDKModel.on_nor_pdk_nor_pai_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_pai_msg</color>")
    m_data.status = DdzPDKModel.Status.fp
    m_data.remain_pai_amount = data.remain_pai_amount
    m_data.race = data.cur_race
    m_data.first_cp = data.first_cp

    if DdzPDKModel.baseData.jdz_type == DdzPDKModel.jdz_type.nor then
        m_data.deadwood_list = nil
        m_data.my_pai_list = data.my_pai_list
        table.sort(m_data.my_pai_list)
    elseif DdzPDKModel.baseData.jdz_type == DdzPDKModel.jdz_type.mld then
        local pai_list = {}
        for i=1,17 do
            pai_list[i] = -i
        end
        m_data.my_pai_list = pai_list
    end
    --初始化记牌器
    m_data.jipaiqi = nor_ddz_base_lib.getAllPaiCount()
    nor_ddz_base_lib.jipaiqi({nor = m_data.my_pai_list}, m_data.jipaiqi)

    Event.Brocast("model_nor_pdk_nor_pai_msg")
    Event.Brocast("activity_nor_fa_pai_msg")
end

function DdzPDKModel.on_nor_ddz_mld_kan_my_pai_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_ddz_mld_kan_my_pai_msg</color>")
    m_data.my_pai_list=data.my_pai_list
    table.sort(m_data.my_pai_list)
    m_data.race=data.race
    Event.Brocast("model_nor_ddz_mld_kan_my_pai_msg")
end

--确认地主
function DdzPDKModel.on_nor_pdk_nor_dizhu_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_dizhu_msg</color>")
    m_data.status = DdzPDKModel.Status.set_dz
    m_data.dizhu = data.dz_info.dizhu
    --普通玩法
    if DdzPDKModel.baseData.jdz_type == DdzPDKModel.jdz_type.nor then
        m_data.dz_pai = data.dz_info.dz_pai
        local seat_num = data.dz_info.dizhu
        m_data.rangpai_num = data.dz_info.rangpai_num
        if m_data.remain_pai_amount then
            m_data.remain_pai_amount[seat_num] = m_data.remain_pai_amount[seat_num] + #data.dz_info.dz_pai
        end
        if seat_num == m_data.seat_num then
            for i = 1, #data.dz_info.dz_pai do
                m_data.my_pai_list[#m_data.my_pai_list + 1] = data.dz_info.dz_pai[i]
            end
            table.sort(m_data.my_pai_list)
            m_data.my_rate = m_data.my_rate * 2
        end
    
        if DdzPDKModel.baseData.game_type == DdzPDKModel.game_type.er then
            m_data.my_rate = m_data.init_rate + DdzPDKModel.data.er_qiang_dizhu_count
        end
        -- --初始化记牌器
        -- m_data.jipaiqi = nor_ddz_base_lib.getAllPaiCount()
        -- nor_ddz_base_lib.jipaiqi({nor = m_data.my_pai_list}, m_data.jipaiqi)
    end
    Event.Brocast("model_nor_pdk_nor_dizhu_msg")
    Event.Brocast("activity_nor_dizhu_msg")
end
function DdzPDKModel.on_nor_pdk_nor_bomb_settlement_msg(_, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_bomb_settlement_msg</color>")
    for seat_num, p_scores in ipairs(data.bomb_award) do
        local player_info = m_data.players_info[seat_num]
        if player_info then
            local score = m_data.players_info[seat_num].score
            m_data.players_info[seat_num].score = score + p_scores.award
        end
    end
    Event.Brocast("model_nor_pdk_nor_bomb_settlement_msg", data.bomb_award)
end
-- 第一个出牌人座位号亮牌
function DdzPDKModel.on_nor_pdk_nor_show_pai_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_dizhu_msg</color>")
    m_data.status = DdzPDKModel.Status.set_dz
    m_data.dizhu = data.first_cp_table_num
    m_data.first_cp_type = data.type or "first_cp" -- first_cp:黑桃3 last_win:上一把

    Event.Brocast("model_nor_pdk_nor_dizhu_msg")
    Event.Brocast("activity_nor_dizhu_msg")
end

--确认地主牌 闷拉倒
function DdzPDKModel.on_nor_ddz_mld_dizhu_pai_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_ddz_mld_dizhu_pai_msg</color>")
    m_data.status = DdzPDKModel.Status.set_dz
    m_data.dz_pai = data.dz_pai
    local seat_num = m_data.dizhu
    m_data.remain_pai_amount[seat_num]=m_data.remain_pai_amount[seat_num]+ #data.dz_pai
    if seat_num == m_data.seat_num then
        for i = 1, #m_data.dz_pai do
            m_data.my_pai_list[#m_data.my_pai_list + 1] = m_data.dz_pai[i]
        end
        table.sort(m_data.my_pai_list)
    end
    --初始化记牌器
    m_data.jipaiqi = nor_ddz_base_lib.getAllPaiCount()
    nor_ddz_base_lib.jipaiqi({nor = m_data.my_pai_list}, m_data.jipaiqi)
    Event.Brocast("model_nor_ddz_mld_dizhu_pai_msg")
    Event.Brocast("activity_nor_dizhu_pai_msg")
end

--赖子
function DdzPDKModel.on_nor_pdk_nor_laizi_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_laizi_msg</color>")
    m_data.laizi = data.laizi
    Event.Brocast("model_nor_pdk_nor_laizi_msg", data.p)
end

--权限信息轮询
function DdzPDKModel.on_nor_pdk_nor_permit_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_permit_msg</color>")
    m_data.status = data.status
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown = (data.countdown - 1)
    if m_data.countdown < 0 then
        m_data.countdown = 0
    end
    m_data.cur_p = data.cur_p

    Event.Brocast("model_nor_pdk_nor_permit_msg")
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

    jdz = 100,
    jiabei = 101,
    er_qdz=102,
    mld_kp = 103, --：看牌
    mld_zhua = 104, --：抓牌
    mld_bz = 105, --：不抓
    mld_dao = 106, --：倒
    mld_bd = 107, --：不倒
    mld_la = 108, --：拉
    mld_bl = 109, --：不拉
    mld_men = 110, --：闷
]]
function DdzPDKModel.on_nor_pdk_nor_action_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_action_msg</color>")
    m_data.action_list[#m_data.action_list + 1] = data.action

    local act_type = data.action.type
    --注意可能是断线重连  此时相应的数据可能还没有初始化  所以一定要判断数据是否存在
    --更新玩家手上剩余扑克牌的数量
    if  m_data.remain_pai_amount and act_type < 100 and data.action.cp_list then
        local nor_list = data.action.cp_list.nor
        local lz_list = data.action.cp_list.lz
        local len1 = 0
        local len2 = 0
        if nor_list then
            len1 = #nor_list
        end
        if lz_list then
            len2 = #lz_list
        end

        m_data.remain_pai_amount[data.action.p] = m_data.remain_pai_amount[data.action.p] - len1 - len2
        if data.action.p ~= m_data.seat_num and m_data.jipaiqi then
            nor_ddz_base_lib.jipaiqi(data.action.cp_list, m_data.jipaiqi, m_data.laizi)
        end
        --剔除牌
        if data.action.p == m_data.seat_num and m_data.my_pai_list then
            local hash = {}
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

    if DdzPDKModel.baseData.game_type == DdzPDKModel.game_type.er then
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

    --闷抓
    if act_type == 110 then
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
        m_data.dao_la_data[data.action.p] = 1
    elseif act_type == 107 or act_type == 109 then
        m_data.dao_la_data[data.action.p] = 0
    end

    --炸弹翻倍
    if m_data.my_rate and (act_type == 13 or act_type == 14 or act_type ==15) then
        m_data.my_rate = m_data.my_rate * 2
    end
    Event.Brocast("model_nor_pdk_nor_action_msg")
end

--托管
function DdzPDKModel.on_nor_pdk_nor_auto_msg(proto_name, data)
    dump(data, "<color=red>on_nor_pdk_nor_auto_msg</color>")
    m_data.auto_status = m_data.auto_status or {}
    m_data.auto_status[data.p] = data.auto_status
    Event.Brocast("model_nor_pdk_nor_auto_msg", data.p)
end

--结算 
-- type
-- 0,失败 
-- 1,胜利
-- 2,被关   
-- 3,反关   
-- 4,单关   
-- 5,双关  
-- 6,包赔  
-- 7,被包赔 
function DdzPDKModel.on_nor_pdk_nor_settlement_msg(proto_name, data)
    dump(data, "<color=red>proto == on_nor_pdk_nor_settlement_msg</color>")
    m_data.status = DdzPDKModel.Status.settlement
    m_data.settlement_info = data.settlement_info

    --更新除自己外的其他玩家分数
    for seat_num, p_scores in pairs(data.settlement_info.score_data) do
        if seat_num ~= m_data.seat_num then
            local player_info = m_data.players_info[seat_num]
            if player_info then
                local score = m_data.players_info[seat_num].score
                m_data.players_info[seat_num].score = score + p_scores.score
            end
        end
    end

    Event.Brocast("model_nor_pdk_nor_settlement_msg")
    DdzPDKModel.grand_total_settlement()
end

--打完一局重新发牌
function DdzPDKModel.on_nor_pdk_nor_new_game_msg(proto_name, data)
    dump(data, "<color=red>on_nor_pdk_nor_new_game_msg</color>")
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    m_data.race = data.cur_race
    m_data.curr_all_player = data.curr_all_player
    Event.Brocast("model_nor_pdk_nor_new_game_msg")
end

--都没有叫地主重新开始
function DdzPDKModel.on_nor_pdk_nor_start_again_msg(proto_name, data)
    dump(data, "<color=red>on_nor_pdk_nor_start_again_msg</color>")
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    Event.Brocast("model_nor_pdk_nor_start_again_msg")
end

--资产改变
function DdzPDKModel.AssetChange(proto_name, data)
    data = {score = MainModel.UserInfo.jing_bi}
    dump(data, "<color=red>proto == AssetChange</color>")
    m_data.score = data.score
    if m_data.players_info[m_data.seat_num] then
        m_data.players_info[m_data.seat_num].score = data.score
    end
    Event.Brocast("model_AssetChange")
end

--*******************************方法
--判断玩家是否胜利
function DdzPDKModel.PlayerIsWin(seat_num)
    if m_data and m_data.settlement_info and m_data.settlement_info.score_data then
        for k,v in ipairs(m_data.settlement_info.score_data) do
            if seat_num == v.seat_num then
                if v.score > 0 then
                    return true
                else
                    return false
                end
            end
        end
    end
    return nil
end

-- 玩家自己是否胜利
function DdzPDKModel.IsMyWin()
    return DdzPDKModel.PlayerIsWin(m_data.seat_num)
end

--获得我的权限数据
--[[
    type: 
        "jdz"  (数据为 几分以上)
        "jb"   ()
        “cp”   (数据为 是否必须出，有无够大的牌power)

        {type,is_must,power,jdz_min}
--]]
function DdzPDKModel.getMyPermitData()
    if m_data then
        if m_data.cur_p and m_data.cur_p == m_data.seat_num then
            if m_data.status == DdzPDKModel.Status.jdz then
                return {type = DdzPDKModel.Status.jdz, jdz_min = m_data.base_rate + 1}
            elseif m_data.status == DdzPDKModel.Status.jiabei then
                return {type = DdzPDKModel.Status.jiabei, is_jiabei = m_data.jiabei}
            elseif m_data.status == DdzPDKModel.Status.q_dizhu then
                return {type = DdzPDKModel.Status.q_dizhu}
            elseif m_data.status == DdzPDKModel.Status.cp then
                --判断是否为必须出牌
                local is_must = nor_ddz_base_lib.is_must_chupai(m_data.action_list)
                --判断是否有够大的牌
                local power = 0
                if not is_must then
                    power =
                        DdzPDKModel.ddz_algorithm:check_cp_capacity_by_pailist(
                        m_data.action_list,
                        m_data.my_pai_list,
                        m_data.laizi
                    )
                end
                return {type = DdzPDKModel.Status.cp, is_must = is_must, power = power}
            end
        end
    end
    return nil
end

-- 练习场下一个奖励差几个胜场 以及 最近一次奖励的索引(默认索引为1)
function DdzPDKModel.getNextAward(winCount)
    local currAwardIndex = 1
    for i, v in ipairs(this.UIConfig.award) do
        if v.win_count > winCount then
            return v.win_count - winCount, currAwardIndex
        end
        currAwardIndex = i
    end
    return 0, currAwardIndex
end

-- 公共倍数 就是地主叫的分数
function DdzPDKModel.GetGongGongBeishu()
    if m_data and m_data.settlement_info then
        return m_data.settlement_info.p_jdz[m_data.dizhu] or 0
    end
    return 0
end

-- 地主倍数 地主加的倍数
function DdzPDKModel.GetDiZhuBeishu()
    if m_data and m_data.settlement_info then
        local value = m_data.settlement_info.p_jiabei[m_data.dizhu] or 0
        if value > 0 then
            return 2
        end
    end
    return 0
end

-- 农民倍数 农民加的倍数
function DdzPDKModel.GetNongMinBeishu()
    if m_data and m_data.settlement_info then
        local d = 0
        for k, v in ipairs(m_data.settlement_info.p_jiabei) do
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
function DdzPDKModel.GetEWaiBeishu()
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

            for k, v in ipairs(m_data.settlement_info.p_jiabei) do
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
function DdzPDKModel.GetZhadanBeishu()
    if m_data and m_data.settlement_info then
        if m_data.settlement_info.bomb_count > 0 then
            return math.pow(2, m_data.settlement_info.bomb_count)
        end
    end
    return 0
end

-- 春天
function DdzPDKModel.GetCTBeishu()
    if m_data and m_data.settlement_info then
        if m_data.settlement_info.chuntian > 0 then
            return 2
        end
    end
    return 0
end

-- 总倍数
function DdzPDKModel.GetZongBeishu()
    local beishu = {}
    local rr = 1
    local isB = false
    beishu[#beishu + 1] = DdzPDKModel.GetGongGongBeishu()
    beishu[#beishu + 1] = DdzPDKModel.GetEWaiBeishu()
    beishu[#beishu + 1] = DdzPDKModel.GetZhadanBeishu()
    beishu[#beishu + 1] = DdzPDKModel.GetCTBeishu()
    for _, v in ipairs(beishu) do
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
function DdzPDKModel.IsRoomEnter(id)
    local ui_config = GameFreeModel.GetGameIDToConfig(id)

    local jing_bi = MainModel.UserInfo.jing_bi
    if ui_config.gameModel == 1 then
        if ui_config.enterMin >= 0 and jing_bi < ui_config.enterMin then
            return 1 -- 过低
        end
        if ui_config.enterMax >= 0 and jing_bi >= ui_config.enterMax then
            return 2 -- 过高
        end
    end
    return 0
end

-- 返回自己的座位号
function DdzPDKModel.GetPlayerSeat()
    if m_data.seat_num then
        return m_data.seat_num
    else
        return 1
    end
end

-- 返回自己的UI位置
function DdzPDKModel.GetPlayerUIPos()
    return DdzPDKModel.GetSeatnoToPos(m_data.seat_num)
end

-- 根据座位号获取玩家UI位置
function DdzPDKModel.GetSeatnoToPos(seatno)
    local seftSeatno = DdzPDKModel.GetPlayerSeat()
    return (seatno - seftSeatno + DdzPDKModel.maxPlayerNumber) % DdzPDKModel.maxPlayerNumber + 1
end

-- 根据UI位置获取玩家座位号
function DdzPDKModel.GetPosToSeatno(uiPos)
    local seftSeatno = DdzPDKModel.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % DdzPDKModel.maxPlayerNumber + 1
end

-- 根据UI位置获取玩家座位号
function DdzPDKModel.GetPosToPlayer(uiPos)
    local seatno = DdzPDKModel.GetPosToSeatno(uiPos)
    return m_data.players_info[seatno]
end

-- 是否是自己 玩家自己的UI位置在1号位
function DdzPDKModel.IsPlayerSelf(uiPos)
    return uiPos == 1
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function DdzPDKModel.GetAnimChatShowPos(id)
    if m_data and m_data.players_info then
        for k, v in ipairs(m_data.players_info) do
            if v.id == id then
                local uiPos = DdzPDKModel.GetSeatnoToPos(v.seat_num)
                if DdzPDKModel.data.dizhu and DdzPDKModel.data.dizhu > 0 then
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

function DdzPDKModel.ClearMatchData(gameID)
    InitMatchData(gameID)
end

function DdzPDKModel.SetMaxPlayerNum(game_type)
    if game_type == DdzPDKModel.game_type.er then
        DdzPDKModel.maxPlayerNumber = 2
    else
        DdzPDKModel.maxPlayerNumber = 3
    end
end

-- 返回农民的座位号
function DdzPDKModel.GetSeatNM()
    if m_data.dizhu == 1 then
        return 2
    else
        return 1
    end
end

--闷拉倒---------------------------------------
--地主是否是闷抓
function DdzPDKModel.IsMenZhua()
    if m_data and m_data.men_data then
        return m_data.men_data[m_data.dizhu] == 2
    end
end

--我自己是否倒
function DdzPDKModel.IsDao()
    if m_data and m_data.dao_la_data then
        return m_data.dao_la_data[m_data.seat_num] == 1
    end
end

--地主是否拉
function DdzPDKModel.IsLa()
    if m_data and m_data.dao_la_data then
        return m_data.dao_la_data[m_data.dizhu] == 1
    end
end

--倒的人数
function DdzPDKModel.GetDaoNum()
    local num = 0
    for i,v in ipairs(m_data.dao_la_data) do
        if i ~= m_data.dizhu and m_data.dao_la_data[i] == 1 then
            num = num + 1
        end
    end
    return num
end

function DdzPDKModel.GetSettlementRateShowData()
    local base_rate=1
    DdzPDKModel.settlementRateShowData={}
    local data=DdzPDKModel.settlementRateShowData
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
--闷拉倒---------------------------------------end

function DdzPDKModel.CalcBetMultipliers()
    local data = {}
    local farmerNum = 2
    local menMul = (this.IsMenZhua() and 4 or 2)
    local bombMul = math.max(1, this.GetZhadanBeishu())
    local springMul = math.max(1, this.GetCTBeishu())
    if DdzPDKModel.baseData.game_type == DdzPDKModel.game_type.er then
        menMul = (this.IsMenZhua() and 2 or 1)
        farmerNum = 1
    end
    
    local seed = menMul/farmerNum * bombMul * springMul
    local index = 1
    for i, d in ipairs(m_data.dao_la_data) do
        if i ~= m_data.dizhu then
            data[index] = {}
            
            if d == 1 then
                data[index].daoMul = 2
                data[index].betTimes = seed * 2
                data[index].laMul = (this.IsLa() and 2 or 1)
                data[index].betTimes = data[index].betTimes * data[index].laMul
            else
                data[index].daoMul = 1
                data[index].laMul = 1
                data[index].betTimes = seed
            end
            
            data[index].menMul = menMul/farmerNum
            data[index].bombMul = bombMul
            data[index].springMul = springMul
            data[index].seat = i
            index = index + 1
        end
    end

    return data
end


function DdzPDKModel.hz_call()
    Network.SendRequest("fg_huanzhuo", nil, "请求换桌")
end
function DdzPDKModel.zb_call()
    Network.SendRequest("fg_ready", nil, "请求准备")
end
function DdzPDKModel.hintCondition(call)
    local game_id = DdzPDKModel.baseData.game_id
    local ui_config = GameFreeModel.GetGameIDToConfig(game_id)
    PayFastFreePanel.Create(ui_config, call)
end
function DdzPDKModel.checkCondition(call)
    local game_id = DdzPDKModel.baseData.game_id
    local ss = GameFreeModel.IsAgainRoomEnter(game_id)
    if ss == 1 then
        LittleTips.Create("当前鲸币不足")
        DdzPDKModel.hintCondition(call)
        return false
    elseif ss == 2 then
        --local _,data = GameFreeModel.CheckRapidBeginGameID ()
        local config = GameFreeModel.GetGameIDToConfig(game_id)
        local _,data = GameFreeModel.GetRapidBeginGameID (config.game_type)
        local pre = HintPanel.Create(2, "您太富有了，更高级的场次才适合您！", function ()
            Network.SendRequest("fg_switch_game", {id = data.game_id}, "正在报名")
        end)
        pre:SetButtonText("取消", "前往高级场")
        return false
    end
    return true
end

-- 换桌检查
function DdzPDKModel.HZCheck()
    if DdzPDKModel.checkCondition(DdzPDKModel.hz_call) then
        DdzPDKModel.hz_call()
    end
end
-- 准备检查
function DdzPDKModel.ZBCheck()
    if DdzPDKModel.checkCondition(DdzPDKModel.zb_call) then
        DdzPDKModel.zb_call()
    end
end

-- 检查一个玩家是否是地主
function DdzPDKModel.CheckDZ(seat)
    if m_data and m_data.dizhu then
        return seat == m_data.dizhu
    end
    return false
end

--获取结算时所有玩家数据
function DdzPDKModel.GetPlayersData()
    if m_data and m_data.settlement_players_info then
        return m_data.settlement_players_info
    end
    return false
end

function DdzPDKModel.GetLSCount(activity_data)
    local aid = 0
    local lsc = 1
    for _, item in ipairs(activity_data) do
        if item.key == "cur_process" then
            lsc = item.value
        elseif item.key == "activity_id" then
            aid = item.value
        end
    end

    if aid == ActivityType.Consecutive_Win then
        m_data.ls_count = lsc
    else
        m_data.ls_count = 1
    end
end

--[[累计胜负统计]]
function DdzPDKModel.grand_total_settlement(  )
    if DdzPDKModel.IsMyWin()then
        PlayerPrefs.SetInt("grand_total_free_lose_num" .. MainModel.UserInfo.user_id, 0)
    else
        local cur_lose_num = PlayerPrefs.GetInt("grand_total_free_lose_num" .. MainModel.UserInfo.user_id, 0)
        cur_lose_num = cur_lose_num + 1
        PlayerPrefs.SetInt("grand_total_free_lose_num" .. MainModel.UserInfo.user_id, cur_lose_num)
    end
end