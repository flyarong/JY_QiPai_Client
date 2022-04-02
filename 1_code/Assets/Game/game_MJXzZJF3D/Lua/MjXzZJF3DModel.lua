--[[
正常消息是指除断线重连以外的消息
]]
local normal_majiang=require "Game.normal_mj_common.Lua.normal_majiang_lib"
local FreeUIConfig = require "Game.game_MjXzZJF3D.Lua.mjxzfk_freestyle_ui3D"	--ui配置
local FreeAwardConfig = require "Game.game_MjXzZJF3D.Lua.mjxzfk_drivingrange_award3D"   --奖励配置
local NormalMaJiangEnum = require "Game.normal_mj_common.Lua.normal_majiang_enum"
local nor_mj_base_lib = require "Game.normal_mj_common.Lua.nor_mj_algorithm_lib"
local cfg_trans_nor_mj_xzdd=require "Game.normal_mj_common.Lua.cfg_trans_nor_mj_xzdd"

package.loaded["Game.normal_mj_common.Lua.MjCard3D"] = nil
require "Game.normal_mj_common.Lua.MjCard3D"

local mj_algorithm
MjXzFKModel = {}
MjXzFKModel.Model_Status =
{
    wait_join = "wait_join",--等待准备
    wait_begin = "wait_begin",--房间状态处于等待启动
    gaming = "gaming",--房间状态处于游戏中
    gameover = "gameover",--房间状态处于结束
}
MjXzFKModel.Status =
{
    ready="ready", -- 准备状态
    begin = "begin",-- 开始游戏 举手处理
    start = "start",-- 第一次出牌

    tou_sezi = "tou_sezi",
    fp = "fp", -- 发牌
    chu_pai = "cp",--出牌
    ding_que = "ding_que", -- 定缺
    da_piao = "da_piao",   -- 打漂
    da_piao_finish = "da_piao_finish",   -- 打漂完成
    mo_pai = "mo_pai", -- 摸牌
    peng_gang_hu = "peng_gang_hu", -- 碰、杠、胡
    huan_san_zhang = "huan_san_zhang",     -- 换三张
    huan_san_zhang_finish = "huan_san_zhang_finish",     -- 换三张

    settlement = "settlement",  --每一局结算
    gameover = "gameover",  --结束
}

MjXzFKModel.PaiType =
{
    sp = "sp", -- 手牌
    cp = "cp", -- 出牌
    pp = "peng", -- 碰牌
    hp = "hp", -- 胡牌
    ag = "ag", -- 暗杠
    zg = "zg", -- 直杠
    wg = "wg", -- 弯杠
    zp = "zp", -- 抓牌
}


----- 胡牌的分割配置
MjXzFKModel.HuPaiPosCfg = {
    [1] = { splitNum = 5 , splitOffset = Vector3.New( 0,0,MjCard3D.size.z ) },
    [2] = { splitNum = 3 , splitOffset = Vector3.New( 0,MjCard3D.size.y,0 ) },
    [3] = { splitNum = 5 , splitOffset = Vector3.New( 0,0,MjCard3D.size.z ) },
    [4] = { splitNum = 3 , splitOffset = Vector3.New( 0,MjCard3D.size.y,0 ) },
}


function MjXzFKModel.setBaseShouPaiNum(gameType)
    if gameType == MjXzFKLogic.game_type.nor_mj_xzdd_er_7 then
        print("setBaseShouPaiNum 1",gameType , MjXzFKLogic.game_type.nor_mj_xzdd_er_7)
        MjXzFKModel.baseShouPaiNum = 7
    else
        print("setBaseShouPaiNum 2",gameType)
        MjXzFKModel.baseShouPaiNum = 13
    end
end

function MjXzFKModel.setMaxPlayerNumber(gameType)
    if gameType == MjXzFKLogic.game_type.nor_mj_xzdd_er_7 or gameType == MjXzFKLogic.game_type.nor_mj_xzdd_er_13 then
        MjXzFKModel.maxPlayerNumber = 2
    else
        MjXzFKModel.maxPlayerNumber = 4
    end
end

function MjXzFKModel.setTotalCardNum(gameType)
    if gameType == MjXzFKLogic.game_type.nor_mj_xzdd_er_7 or gameType == MjXzFKLogic.game_type.nor_mj_xzdd_er_13 then
        MjXzFKModel.totalCardNum = 72
    else
        MjXzFKModel.totalCardNum = 108
    end
end

function MjXzFKModel.checkIsEr()
    if MjXzFKModel.game_type == MjXzFKLogic.game_type.nor_mj_xzdd_er_7 or MjXzFKModel.game_type == MjXzFKLogic.game_type.nor_mj_xzdd_er_13 then
        return true
    end
    return false
end

function MjXzFKModel.checkIsEr7zhang()
    if MjXzFKModel.game_type == MjXzFKLogic.game_type.nor_mj_xzdd_er_7 then
        return true
    end
    return false
end

---- add by wss 自动调整麻将大小
function MjXzFKModel.autoAdjustMjSize()
    --- 一个屏幕最多显示的牌的个数
    local screenShowCardNum = 16

    --if MjXzFKModel.game_type == MjXzLogic.game_type.nor_mj_xzdd or MjXzFKModel.game_type == MjXzLogic.game_type.nor_mj_xzdd_er_13 then
        -- 如果比例小于 16/9
        if Screen.width / Screen.height < 16/9 then
            local targetWidth = Screen.height * 16/9
            local everyCardWidth = targetWidth / screenShowCardNum

            local scale = (Screen.width / screenShowCardNum) / everyCardWidth
            print("<color=yellow>-------------- scale: </color>",scale)
            --MjCard3D.setScreenAutoAdjustScale(scale)

            --local myCardPos = GameObject.Find( "majiang_fj/mjz_01/handCardPos1" )
            --myCardPos.transform.localScale = Vector3.New( MjCard3D.parent_scale.x * scale , MjCard3D.parent_scale.y * scale , MjCard3D.parent_scale.z * scale )

            --- 位置调整
            --myCardPos.transform.localPosition = MjMyShouPaiManger3D:setShouPaiNodePosOriginPos( Vector3.New( -7*MjCard3D.origSize.x*MjCard3D.sizeScale* scale , myCardPos.transform.localPosition.y+(MjCard3D.size.y*scale/2) , myCardPos.transform.localPosition.z ) )

            MjXzFKModel.cardScale = {}
            MjXzFKModel.cardScale.localScale = Vector3.New( MjCard3D.parent_scale.x * scale , MjCard3D.parent_scale.y * scale , MjCard3D.parent_scale.z * scale )
            MjXzFKModel.cardScale.localPosition = Vector3.New( -7*MjCard3D.origSize.x*MjCard3D.sizeScale * MjCard3D.parent_scale.x* scale , 
                                                                MjCard3D.parent_position.y+(MjCard3D.size.y* MjCard3D.parent_scale.y*(1-scale)/2) , 
                                                                    MjCard3D.parent_position.z )

            ----------  主摄像机调整 --------
            local mainCamera = GameObject.Find("MainCamera"):GetComponent("Camera")

            local targetWidth = 1600
            local targetHeight = 900

            local nowHeight = 0
            if Screen.height / Screen.width > targetHeight / targetWidth then
                nowHeight = targetWidth / Screen.width * Screen.height
            else
                nowHeight = targetHeight
            end

            local scale = nowHeight / targetHeight

            local orgFieldOfView = 30
            mainCamera.fieldOfView = orgFieldOfView * (scale>1 and (1+(scale-1)/2) or scale)
            --mainCamera.transform.position = Vector3.New(mainCamera.transform.position.x , mainCamera.transform.position.y - scale , mainCamera.transform.position.z - scale)

        end
    --end
end


--[[
花色：1=万、2=筒、3=条

麻将的表示：
    11 ~ 19  : 筒
    21 ~ 29  : 条
    31 ~ 39  : 万
--]]
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
    --这是自建房系统 玩家点击准备的消息→这是表面的玩家操作
    lister["zijianfang_ready_msg"] = this.on_zijianfang_ready_msg
    lister["nor_mj_xzdd_ready_msg"] = this.on_nor_mj_xzdd_ready_msg
    lister["nor_mj_xzdd_begin_msg"] = this.on_nor_mj_xzdd_begin_msg

    lister["nor_mj_xzdd_action_msg"] = this.on_nor_mj_xzdd_action_msg
    lister["nor_mj_xzdd_tou_sezi_msg"] = this.on_nor_mj_xzdd_tou_sezi_msg
    lister["nor_mj_xzdd_pai_msg"] = this.on_nor_mj_xzdd_pai_msg
    lister["nor_mj_xzdd_permit_msg"] = this.on_nor_mj_xzdd_permit_msg
    lister["nor_mj_xzdd_score_change_msg"] = this.on_nor_mj_xzdd_grades_change_msg
    lister["nor_mj_xzdd_dingque_result_msg"] = this.on_nor_mj_xzdd_dingque_result_msg
    lister["nor_mj_xzdd_auto_msg"] = this.on_nor_mj_xzdd_auto_msg
    lister["nor_mj_xzdd_auto_cancel_signup_msg"] = this.on_nor_mj_xzdd_auto_cancel_signup_msg

    lister["nor_mj_xzdd_huansanzhang_msg"] = this.on_nor_mj_xzdd_huansanzhang_msg
    lister["nor_mj_xzdd_huan_pai_finish_msg"] = this.on_nor_mj_xzdd_huan_pai_finish_msg

    lister["nor_mj_xzdd_da_piao_msg"] = this.on_nor_mj_xzdd_da_piao_msg
    lister["nor_mj_xzdd_da_piao_finish_msg"] = this.on_nor_mj_xzdd_da_piao_finish_msg
    lister["kaiguan_multi_change_msg"] = this.on_kaiguan_multi_change_msg


    --投票
    lister["begin_vote_cancel_room_response"] = this.on_begin_vote_cancel_room_response
    lister["player_vote_cancel_room_response"] = this.on_player_vote_cancel_room_response

    lister["zijianfang_begin_vote_cancel_room_msg"] = this.on_friendgame_begin_vote_cancel_room_msg
    lister["zijianfang_over_vote_cancel_room_msg"] = this.on_friendgame_over_vote_cancel_room_msg
    lister["zijianfang_player_vote_cancel_room_msg"] = this.on_friendgame_player_vote_cancel_room_msg


    --response
    lister["nor_mj_xzdd_req_game_list_response"] = this.on_nor_mj_xzdd_req_game_list_response
    lister["nor_mj_xzdd_signup_response"] = this.on_nor_mj_xzdd_signup_response
    lister["nor_mj_xzdd_cancel_signup_response"] = this.on_nor_mj_xzdd_cancel_signup_response
    lister["nor_mj_xzdd_replay_game_response"] = this.on_nor_mj_xzdd_replay_game_response
    lister["nor_mj_xzdd_quit_game_response"] = this.on_nor_mj_xzdd_quit_game_response
    lister["nor_mj_xzdd_nor_mj_xzdd_dingque_response"] = this.on_nor_mj_xzdd_dingque_response
    lister["nor_mj_xzdd_operator_response"] = this.on_nor_mj_xzdd_operator_response
    lister["nor_mj_xzdd_settlement_msg"] = this.on_nor_mj_xzdd_settlement_msg
    lister["nor_mj_xzdd_next_game_msg"] = this.on_nor_mj_xzdd_next_game_msg

    --gps
    lister["zijiangfang_gps_info_msg"] = this.on_gps_info_msg
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
        print("<color=red>data.status_no=" .. data.status_no .. " ;m_data.status_no:" .. m_data.status_no .."  proto_name=" .. proto_name .. "</color>")
        if proto_name~="friendgame_all_info" then
            if m_data.status_no+1 ~= data.status_no and  m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no

                --发送状态编码错误事件
                print("<color=red>proto_name = " .. proto_name .. "</color>")
                Event.Brocast("model_nor_mj_xzdd_statusNo_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no 
    end
    func(proto_name, data)
end
--注册正常逻辑的消息事件
function MjXzFKModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end


--删除正常逻辑的消息事件
function MjXzFKModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
end
function MjXzFKModel.Update()
    if m_data then
        if m_data.countdown and m_data.countdown>0 then
            m_data.countdown=m_data.countdown-updateDt
            if m_data.countdown<0 then
                m_data.countdown=0
            end
        end
        if this.countdown and this.countdown > 0 then
            this.countdown = this.countdown - updateDt
            if this.countdown <= 0 then
                this.countdown = nil
                 this.gameList = nil
            end
        end
    end
end
local function InitMatchData()
    MjXzFKModel.data = {
        model_status=nil,
        game_type =nil,
        friendgame_room_no =nil,
        game_config =nil,
        room_owner=nil,
        --投票相关
        vate_data = nil,
        vote_parm = nil,
        vote_result = nil,
        vote_cur_p_id = nil,
        vote_cur_p_opt = nil,
        room_dissolve = nil,
        --当前游戏状态（详细说明见文件顶部注释：状态表status）
        status = nil,
        --在以上信息相同时，判定具体的细节状态；+1递增
        status_no = 0, 
        --倒计时
        countdown = 0,
        --当前的权限拥有人
        cur_p = nil, 
        --当前摸的牌  0 表示背面 
        cur_mopai = nil,
        --最新出的牌 p 出牌人  牌
        cur_chupai ={p=0,pai=nil},
        --当前PGH的牌
        cur_pgh_card=nil,
        cur_pgh_allow_opt=nil,
        --[[
        玩家胡牌数据  key 为胡牌顺序 v={ 
                    type  -- zm 自摸 h 普通胡
                    pai --胡的牌
                    seat_num -- 胡牌人座位
          }
        --]]
        hu_data={},
        hu_data_map={},
        --当前局数
        cur_race = nil,
        -- 总局数
        race_count = nil,
        --我的座位号
        mySeatno = nil,
        --庄家座位号
        zjSeatno = nil,
        -- 玩家的操作
        actionList = {},

        init_stake=nil,
        init_rate=nil,

        jipaiqi=nil,
        --[[ key=seatno 
        --base=基础信息 
            -- cpList=出牌列表 
            -- pgList=杠、碰牌列表
            -- spList=手牌列表 
            -- lackColor=定缺的花色(-2还未开始,-1=未定，0=已定缺、1=万、2=筒、3=条) 
            -- auto 
        --]]
        playerInfo =nil,


        --我的牌map
        my_pai_map={},
        --我的碰杠 map
        my_pg_map={},


        -- 剩余牌张数
        remain_card = 108,
        -- 骰子点数
        sezi_value1 = 0,
        sezi_value2 = 0,
        --碰 杠 胡 权限数据
        --[[
            {
                gang={ {type,pai}} --list
                peng={type,pai}
                hu=true OR false
                guo=true OR false
            }
        --]]
        pgh_data=nil,
        --[[出牌听数据  当前牌出牌之后可能胡的数据   map  key=paiID value={  {
                                                                            ting_pai
                                                                            hu_type_info nil 表示不糊  其他表示胡牌类型
                                                                            mul 番数
                                                                            geng 根的数量
                                                                            剩下的张数
                                                                            remain 
                                                                          } }
          --]]
        chupai_ting_data=nil,
        --有出牌权限时的过记录 用于过掉胡牌  弯杠等
        is_guo=nil,

        ready={0,0,0,0},

        settlement_info=nil,

        gameover_info=nil,

        isHuanPai = false,

        -- 是否可以操作牌
        isCanOpPai = true,

        ---- 发牌动画时间间隔
        faPaiDelayTime = 0.07
    }    
    m_data = MjXzFKModel.data
end
local function InitMatchStatusData(status)
    m_data.status = status
    m_data.countdown = 0
    m_data.cur_p = nil 
    m_data.cur_mopai = nil
    m_data.zjSeatno = nil
    m_data.cur_pgh_card = nil
    m_data.cur_chupai = {p=0,pai=nil}
    m_data.hu_data={}
    m_data.hu_data_map={}
    m_data.actionList = {}
    for i=1,4 do
        m_data.playerInfo=m_data.playerInfo or {}
        m_data.playerInfo[i]=m_data.playerInfo[i] or {}
        m_data.playerInfo[i].spList = {}
        m_data.playerInfo[i].pgList = {}
        m_data.playerInfo[i].cpList = {}
        m_data.playerInfo[i].lackColor = -2
    end
    m_data.jipaiqi=nil
    m_data.my_pai_map ={}
    m_data.remain_card =108
    m_data.sezi_value1 = 0
    m_data.sezi_value2 = 0
    m_data.pgh_data =nil
    m_data.chupai_ting_data = nil
    m_data.is_guo=nil
    m_data.isHuanPai = false
    m_data.isCanOpPai = true
end
local function InitMatchRoomData(status)
    InitMatchStatusData(status)
    m_data.roomId = nil
    m_data.playerInfo = {}
    m_data.seat_num=nil
end
function MjXzFKModel.Init()
    InitMatchData()
    this = MjXzFKModel
    this.gameList = nil
    --收到gameList的时间
    this.gameList_time=nil
    this.InitUIConfig()
    MakeLister()
    this.AddMsgListener()

    update = Timer.New(MjXzFKModel.Update, updateDt, -1,true)
    update:Start()

    MjXzFKModel.autoAdjustMjSize()

    return this
end
function MjXzFKModel.Exit()
    MjXzFKModel.RemoveMsgListener()
    update:Stop()
    update=nil
    this=nil
    lister=nil
    m_data=nil
    MjXzFKModel.data=nil
    MjXzFKModel.gameList=nil
    MjXzFKModel.gameList_time=nil
end
-- 初始化游戏配置Config
function MjXzFKModel.InitUIConfig()
    this.UIConfig={
        award = {},
        config = {},
        entrance = {},
    }
    local award = this.UIConfig.award
    local config = this.UIConfig.config
    local entrance = this.UIConfig.entrance
    for _,v in ipairs(FreeAwardConfig.award_cfg) do
        award[v.id] = v
    end
    for _,v in ipairs(FreeUIConfig.config) do
        config[v.gameID] = config[v.gameID] or {}
        config[v.gameID]["gameModel"] = v.gameModel
    end
    for _,v in ipairs(FreeUIConfig.entrance) do
        entrance[v.gameID] = entrance[v.gameID] or {}
        entrance[v.gameID][v.name] = v.value
    end
end


-- 清除数据
function MjXzFKModel.ClearMatchData()
    InitMatchData()
end

--[[*************************************

网络数据

*************************************--]]
-- 游戏列表
function MjXzFKModel.on_nor_mj_xzdd_req_game_list_response(_,data)
    if data.result == 0 then
        this.gameList = data.nor_mj_xzdd_match_list
        this.countdown = 30
        Event.Brocast("model_nor_mj_xzdd_req_game_list_response", data.result)
    else
        HintPanel.ErrorMsg(data.result)
    end
end
-- 比赛报名结果 countdown:倒计时
function MjXzFKModel.on_nor_mj_xzdd_signup_response(_, data)
    if data.result == 0 then
        m_data.countdown = data.countdown
        m_data.gameModel = data.game_model
        MainLogic.EnterGame()
        Event.Brocast("model_nor_mj_xzdd_signup_response", data.result)

    else
        Event.Brocast("model_nor_mj_xzdd_signup_fail_response", data.result)        
    end
end

-- 取消报名
function MjXzFKModel.on_nor_mj_xzdd_cancel_signup_response(_, data)
    if data.result == 0 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        Event.Brocast("model_nor_mj_xzdd_cancel_signup_response",data.result)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--退出游戏
function MjXzFKModel.on_nor_mj_xzdd_quit_game_response(proto_name,data)
    if data.result == 0 then
        InitMatchData()
        MainLogic.ExitGame()
        --去到房卡场大厅
        MainLogic.GotoScene("game_Hall")
        RoomCardHallPopPrefab.Show()
        -- MjXzFKLogic.change_panel("MjXzFKHallPanel")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

-- 重玩(消息和报名消息一样)
function MjXzFKModel.on_nor_mj_xzdd_replay_game_response(proto_name,data)
    if data.result == 0 then
        MjXzFKModel.on_nor_mj_xzdd_signup_response(proto_name,data)
    else
        HintPanel.ErrorMsg(data.result,function (  )
            --清除数据
            InitMatchData()
            MainLogic.ExitGame()
            MjXzFKLogic.change_panel("MjXzFKHallPanel")
        end)
    end
end

-- 定缺
function MjXzFKModel.on_nor_mj_xzdd_dingque_response(proto_name,data)
    if data.result == 0 then
        playerInfo[data.id].lackColor = data.huase
        Event.Brocast("model_nor_mj_xzdd_dingque_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

-- 操作返回值
function MjXzFKModel.on_nor_mj_xzdd_operator_response(proto_name,data)
    if data.result == 0 then
    else
        print("<color=red>操作返回值 result = " .. data.result .. "</color>")
    end
end

-- 玩家进入
function MjXzFKModel.on_friendgame_join_msg(proto_name, data)
    dump(data, "<color=red>玩家进入</color>")
    local seatno = data.player_info.seat_num
    InitMatchStatusData(data.status)
    m_data.playerInfo = m_data.playerInfo or {}
    m_data.playerInfo[seatno] = m_data.playerInfo[seatno] or {}
    m_data.playerInfo[seatno].base = data.player_info
    Event.Brocast("model_nor_mj_xzdd_join_msg", seatno)
end
-- 玩家退出
function MjXzFKModel.on_friendgame_quit_msg(proto_name, data)
    dump(data, "<color=red>玩家退出</color>")
    local seatno = data.seat_num
    if MjXzFKModel.data.player_ready then 
        MjXzFKModel.data.player_ready[m_data.playerInfo[seatno].base.id] = nil
    end 
    m_data.playerInfo[seatno].base = nil
    m_data.playerInfo[seatno].spList = {}
    m_data.playerInfo[seatno].pgList = {}
    m_data.playerInfo[seatno].cpList = {}
    m_data.playerInfo[seatno].lackColor = -2

    MjXzFKModel.data.ready[seatno] = 0
    if data.seat_num == m_data.seat_num then
        MjXzFKModel.InitGameData()
        MainLogic.ExitGame()
        MjXzFKLogic.change_panel(MjXzFKLogic.panelNameMap.game)
    end
    if MjXzFKModel.data.ready then 
        MjXzFKModel.data.ready[seatno] = 0
    end 
    Event.Brocast("model_nor_mj_xzdd_exit_msg", seatno)
end

--[[玩家的操作
type =  "cp" 出牌; "peng" 碰; "gang" 杠; "hu" 胡; "guo" 过
other =  type=gang（zg 直杠,ag 暗杠,wg 弯杠）
--]]

function MjXzFKModel.on_nor_mj_xzdd_action_msg(proto_name, data)
    dump(data, "玩家的操作")
    m_data.actionList[#m_data.actionList + 1] = data.action
    local caozuo = data.action.type
    if caozuo == "zg" or caozuo == "wg" or caozuo == "ag"then
        data.action.other=caozuo
        data.action.type="gang"
        caozuo="gang"
    end

    if caozuo == "cp" then
        m_data.cur_chupai.p = data.action.p
        m_data.cur_chupai.pai = data.action.pai
        if data.action.p==m_data.seat_num then
            m_data.my_pai_map[data.action.pai]= m_data.my_pai_map[data.action.pai]-1
            print("xxxxxxxxxxxx111")
            dump(m_data.my_pai_map)

            MjXzFKModel.GetTingPai()
        else
            --记牌器  我自己的已经减去过了
            normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi)
            MjXzFKModel.RefreshTingPaiRemain()
        end

    elseif caozuo == "peng" then
        --加入pgmap
        if data.action.p==m_data.seat_num then
            m_data.my_pg_map[data.action.pai]="peng"
            m_data.my_pai_map[data.action.pai]= m_data.my_pai_map[data.action.pai]-2
            print("xxxxxxxxxxxx222")
            dump(m_data.my_pai_map)
	    MjXzFKModel.getChupaiTingData()
            MjXzFKModel.clearTingPaiData()
        else
            --记牌器  我自己的已经减去过了
            normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,2)
            MjXzFKModel.RefreshTingPaiRemain()
        end
    elseif caozuo == "gang" then
        --加入pgmap
        if data.action.p==m_data.seat_num then
            m_data.my_pg_map[data.action.pai]=data.action.other
            if data.action.other=="zg" then
                m_data.my_pai_map[data.action.pai]= m_data.my_pai_map[data.action.pai]-3
            elseif data.action.other=="ag" then
                m_data.my_pai_map[data.action.pai]= m_data.my_pai_map[data.action.pai]-4
            elseif data.action.other=="wg" then
                m_data.my_pai_map[data.action.pai]= m_data.my_pai_map[data.action.pai]-1
            end

            MjXzFKModel.GetTingPai()
        else
            --记牌器  我自己的已经减去过了
            if data.action.other=="zg" then
                normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,3)
            elseif data.action.other=="ag" then
                normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,4)
            elseif data.action.other=="wg" then
                normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,1)
            end
            MjXzFKModel.RefreshTingPaiRemain()
        end
    elseif caozuo == "hu" then
        m_data.hu_data[#m_data.hu_data+1]=data.action.hu_data
        data.action.hu_data.shunxu=#m_data.hu_data
        m_data.hu_data_map[data.action.hu_data.seat_num]=data.action.hu_data
        --将弯杠改为peng
        if data.action.hu_data.hu_type=="qghu" and data.action.hu_data.dianpao_p==m_data.seat_num then
            m_data.my_pg_map[data.action.hu_data.pai]="peng"
        end 

        --不是我的胡 且是自摸 记牌器需要减去
        if data.action.p~=m_data.seat_num and  data.action.hu_data.hu_type=="zimo" then
            --记牌器
            normal_majiang.jipaiqi_kick_pai(data.action.hu_data.pai,m_data.jipaiqi)
            MjXzFKModel.RefreshTingPaiRemain()
        end

    end
    Event.Brocast("model_nor_mj_xzdd_action_msg", data.action)
end

-- 进入游戏的人数达到4人，自动发牌,游戏开始，人数满足要求，发牌开局
function MjXzFKModel.on_nor_mj_xzdd_pai_msg(proto_name, data)
    dump(data, "<color=red>开始发牌</color>")

    --- 清一下换三张的本地记录
    MjXzFKModel.clearHuanSanZhangData()

    m_data.status = MjXzFKModel.Status.fp
    m_data.remain_card = 55 -- 14+13+13+13

    m_data.jipaiqi=normal_majiang.get_init_jipaiqi()

    for i,v in ipairs(m_data.playerInfo) do
        if m_data.seat_num == i then
            v.spList = data.my_pai_list
            m_data.my_pai_map=normal_majiang.get_pai_map_by_list(data.my_pai_list)
            print("xxxxxxxxxxxx000")
            dump(m_data.my_pai_map)
            --记牌器
            for _,v in ipairs(data.my_pai_list) do
                normal_majiang.jipaiqi_kick_pai(v,m_data.jipaiqi)
            end
        else
            if m_data.zjSeatno == i then
                for j=1,14 do
                    v.spList[#v.spList + 1] = 0
                end
            else
                for j=1,13 do
                    v.spList[#v.spList + 1] = 0
                end
            end
        end
    end

    Event.Brocast("model_nor_mj_xzdd_pai_msg")
end
-- 确认庄家
function MjXzFKModel.on_nor_mj_xzdd_tou_sezi_msg(proto_name, data)
    dump(data, "确认庄家")
    m_data.status = MjXzFKModel.Status.ding_que
    m_data.zjSeatno = data.zj_seat
    m_data.sezi_value1 = data.sezi_value1
    m_data.sezi_value2 = data.sezi_value2
    Event.Brocast("model_nor_mj_xzdd_tou_sezi_msg")
end
function MjXzFKModel.on_nor_mj_xzdd_dingque_result_msg(proto_name, data)
    dump(m_data.playerInfo, "<color=green>麻将</color>")
    local result=data.result
    for i=1,4 do 
        m_data.playerInfo[i].lackColor = result[i]
    end
    Event.Brocast("model_nor_mj_xzdd_dingque_result_msg")
end

function MjXzFKModel.on_nor_mj_xzdd_auto_msg(proto_name, data)
    m_data.playerInfo=m_data.playerInfo or {}
    m_data.playerInfo[data.p] = m_data.playerInfo[data.p] or {}
    m_data.playerInfo[data.p].auto = data.auto_status
    Event.Brocast("model_nor_mj_xzdd_auto_msg",data.p)
end

function MjXzFKModel.on_nor_mj_xzdd_auto_cancel_signup_msg(proto_name, data)
     --清除数据
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_nor_mj_xzdd_auto_cancel_signup_msg",data.result)
end


function MjXzFKModel.on_nor_mj_xzdd_huansanzhang_msg(proto_name, data)
    dump(data.pai_vec , "<color=yellow>-------------- on_nor_mj_xzdd_huansanzhang_msg  data.pai_vec </color>")
    m_data.huanSanZhangNewVec = data.pai_vec
    m_data.isHuanPai = true
    m_data.isCanOpPai = true

    m_data.jipaiqi = normal_majiang.jipaiqi_server_to_client(data.jipaiqi) 

    --- 新的手牌
    m_data.playerInfo[m_data.seat_num].spList = data.pai_list
    m_data.my_pai_map=normal_majiang.get_pai_map_by_list(data.pai_list)

    Event.Brocast("model_nor_mj_xzdd_huansanzhang_msg",data.is_time_out == 1)
end

function MjXzFKModel.on_nor_mj_xzdd_huan_pai_finish_msg(proto_name, data)
    m_data.status = MjXzFKModel.Status.huan_san_zhang_finish

    Event.Brocast("model_nor_mj_xzdd_huan_pai_finish_msg",data)
end

-- 解散房间
function MjXzFKModel.on_friendgame_gamecancel_msg(proto_name, data)
    dump(data, "<color=red>解散房间</color>")
    HintPanel.Create(1, "房间已解散", function ()
        --清除数据
        MjXzFKModel.ClearMatchData()
        MainLogic.ExitGame()
        MainLogic.GotoScene("game_Hall")
    end)
end

-- 准备
function MjXzFKModel.on_nor_mj_xzdd_ready_msg(proto_name, data)
    dump(data, "<color=red>准备</color>")
    if not MjXzFKModel.data.ready then
        MjXzFKModel.data.ready = {0,0,0,0}
    end
    m_data.model_status = MjXzFKModel.Model_Status.wait_begin
    MjXzFKModel.data.ready[data.seat_num] = 1
    m_data.cur_race = data.cur_race
    Event.Brocast("model_nor_mj_xzdd_ready_msg", data.seat_num)
end

-- 开始游戏
function MjXzFKModel.on_nor_mj_xzdd_begin_msg(proto_name, data)
    dump(data, "<color=red>开始游戏</color>")
    m_data.model_status = MjXzFKModel.Model_Status.gaming
    m_data.status = MjXzFKModel.Status.begin
    m_data.cur_race = data.cur_race
    m_data.ready = {0,0,0,0}
    m_data.player_ready = {}
    Event.Brocast("model_nor_mj_xzdd_begin_msg")
end

--发起投票response
function MjXzFKModel.on_begin_vote_cancel_room_response(proto_name, data)
    if data.result == 0 then
        Event.Brocast("model_begin_vote_cancel_room_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end
--玩家投票response
function MjXzFKModel.on_player_vote_cancel_room_response(proto_name, data)
    if data.result == 0 then
        Event.Brocast("model_player_vote_cancel_room_response")
    else
        HintPanel.ErrorMsg(data.result)
    end
end
--开始投票
function MjXzFKModel.on_friendgame_begin_vote_cancel_room_msg(proto_name, data)
    m_data.vote_parm = {}
    m_data.vote_parm.time = data.countdown
    m_data.vote_parm.maxnum = m_data.player_count
    m_data.vote_parm.data = {}
    -- m_data.vote_parm.data[#m_data.vote_parm.data + 1] = {id = #m_data.vote_parm.data + 1 , val = 1}
    m_data.vote_data = {agree_count = 1,disagree_count = 0,begin_player_id = data.player_id}
    Event.Brocast("model_friendgame_begin_vote_cancel_room_msg")
end
--投票结束
function MjXzFKModel.on_friendgame_over_vote_cancel_room_msg(proto_name, data)
    -- 0 成功 1 失败 2 取消
    m_data.vote_result = data.vote_result
    m_data.vote_parm = nil
    m_data.vate_data = nil
    m_data.vote_cur_p_id = nil
    m_data.vote_cur_p_opt = nil
    Event.Brocast("model_friendgame_over_vote_cancel_room_msg")
end
--玩家投票msg
function MjXzFKModel.on_friendgame_player_vote_cancel_room_msg(proto_name, data)
    m_data.vote_cur_p_id = data.player_id
    m_data.vote_cur_p_opt = data.opt
    Event.Brocast("model_friendgame_player_vote_cancel_room_msg", {id=m_data.vote_cur_p_id, opt=m_data.vote_cur_p_opt})
end

-- 结算
function MjXzFKModel.on_nor_mj_xzdd_settlement_msg(proto_name, data)
    dump(data, "<color=red>结算</color>",10)
    m_data.status= MjXzFKModel.Status.settlement
    m_data.settlement_info = data.settlement_info.settlement_items
    m_data.game_players_info = data.game_players_info
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
    
    Event.Brocast("model_nor_mj_xzdd_settlement_msg")
end

--- 下一局,--打完一局重新发牌
function MjXzFKModel.on_nor_mj_xzdd_next_game_msg(proto_name, data)
    dump(data, "<color=red>on_nor_mj_xzdd_next_game_msg</color>")
    --考虑是否需要清除数据
    --InitMatchStatusData(data.status)
    --m_data.race = data.cur_race
    --Event.Brocast("model_nor_mj_xzdd_next_game_msg")
end

-- 总结算
function MjXzFKModel.on_friendgame_gameover_msg(proto_name, data)
    dump(data, "<color=red>总结算</color>")
    local b = false
    if m_data.status == MjXzFKModel.Status.ready then
        b = true
    end
    m_data.model_status= MjXzFKModel.Model_Status.gameover
    m_data.status= MjXzFKModel.Status.gameover

    -- MainLogic.ExitGame()
    m_data.gameover_info = data.gameover_info
    if b then
        Event.Brocast("model_friendgame_gameover_msg")
    end
    Event.Brocast("model_friendgame_gameover_msg_com")
end

function MjXzFKModel.on_gps_info_msg(proto_name, data)
    dump(data,"<color=yellow>on_gps_info_msg</color>")
    GPSPanel.Create(false , GPSPanel.IsMustCreate(data.data),m_data.seat_num, m_data.playerInfo, data, function (isTrustDistance)
        Event.Brocast("model_query_gps_info_msg",isTrustDistance)
    end,function ()
        
    end)
end

-- 玩家离线状态
function MjXzFKModel.on_friendgame_net_quality(proto_name, data)
    dump(data, "<color=yellow>玩家离线状态</color>")
    MjXzFKModel.data.playerInfo[data.seat_num].base.net_quality = data.net_quality
    Event.Brocast("model_friendgame_net_quality", data.seat_num)
end

-- 开始游戏
function MjXzFKModel.on_friendgame_begin_game_response(proto_name, data)
    if data.result == 0 then
    else
        HintPanel.ErrorMsg(data.result)
    end
end

-- 权限信息
function MjXzFKModel.on_nor_mj_xzdd_permit_msg(proto_name, data)
    dump(data, "<color=red>权限信息</color>")
    m_data.status = data.status
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown = (data.countdown - 1)
    if m_data.countdown < 0 then
        m_data.countdown = 0
    end
    m_data.cur_p = data.cur_p
    m_data.other = data.other

    m_data.is_guo=nil
    --m_data.status = MjXzFKModel.Status.da_piao -- 测试
    -- 摸牌，剩余牌数减1
    if m_data.status == MjXzFKModel.Status.mo_pai then
        m_data.remain_card = m_data.remain_card - 1
        m_data.cur_mopai = data.pai

        --记牌器
        normal_majiang.jipaiqi_kick_pai(data.pai,m_data.jipaiqi)

        --加入map
        if m_data.seat_num==data.cur_p then
            m_data.my_pai_map[data.pai]=m_data.my_pai_map[data.pai] or 0
            m_data.my_pai_map[data.pai]=m_data.my_pai_map[data.pai]+1
            print("xxxxxxxxxxxx333")
            dump(m_data.my_pai_map)
            MjXzFKModel.getMyPghgData()
            MjXzFKModel.getChupaiTingData()
            MjXzFKModel.clearTingPaiData()
        end
    elseif m_data.status == MjXzFKModel.Status.peng_gang_hu then
        --当前碰杠胡牌
        m_data.cur_pgh_card = data.pai
        MjXzFKModel.getMyPghgData(data.allow_opt)
    elseif m_data.status == MjXzFKModel.Status.ding_que then
        for i,v in ipairs(m_data.playerInfo) do
            v.lackColor=-1
        end
    elseif m_data.status == MjXzFKModel.Status.chu_pai then
        if m_data.seat_num==data.cur_p then
            -- MjXzFKModel.getMyPghgData()
            m_data.pgh_data=nil
            MjXzFKModel.getChupaiTingData()
        end
    elseif m_data.status == MjXzFKModel.Status.start then
        if m_data.seat_num==data.cur_p then
            MjXzFKModel.getMyPghgData()
            MjXzFKModel.getChupaiTingData()
        end
    elseif m_data.status == MjXzFKModel.Status.da_piao then
        -- 先把数据还原一下
        for i,v in ipairs(m_data.playerInfo) do
            v.piaoNum = -1
        end
    elseif m_data.status == MjXzFKModel.Status.huan_san_zhang then
        m_data.isHuanPai = false 
        -- 本地计算默认选中的三张牌
        local paiVec = MjXzFKModel.getDefaultHuanSanZhangPai()
        m_data.huanSanZhangVec = paiVec

        -- 把数据保存到本地
        normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(paiVec,"|") )

        Event.Brocast("model_huanSanZhang_num_change_msg")
    end
    Event.Brocast("model_nor_mj_xzdd_permit_msg")
end

--- 
function MjXzFKModel.addHuanSanZhangPai(pai)
    m_data.huanSanZhangVec[#m_data.huanSanZhangVec + 1] = pai
    
    print("<color=yellow>------- MjXzFKModel.addHuanSanZhangPai: </color>",pai)

    Event.Brocast("model_huanSanZhang_num_change_msg")
end

function MjXzFKModel.delHuanSanZhangPai(pai)
    for k,value in ipairs(m_data.huanSanZhangVec) do
        if value == pai then
            table.remove(m_data.huanSanZhangVec , k)
            print("<color=yellow>------- MjXzFKModel.delHuanSanZhangPai: </color>",pai)
            
            break
        end
    end
    Event.Brocast("model_huanSanZhang_num_change_msg")
end

function MjXzFKModel.saveHuanSanZhangData()
    normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(m_data.huanSanZhangVec,"|") )
end

function MjXzFKModel.clearHuanSanZhangData()
    normal_majiang.saveSelectHuanSanZhangePai("")
end

-- 分数改变
function MjXzFKModel.on_nor_mj_xzdd_grades_change_msg(proto_name, data)
    dump(data, "<color=red>分数改变</color>")
    m_data.moneyChange = data.data
    Event.Brocast("model_nor_mj_xzdd_grades_change_msg")
end

-- 游戏状态
function MjXzFKModel.on_nor_mj_xzdd_status_info(proto_name, data)
    local s = data.status_info
    if s then
        m_data.status = s.status
        m_data.countdown = s.countdown
        m_data.cur_p = s.cur_p
    end
    Event.Brocast("model_nor_mj_xzdd_status_info")
end
function MjXzFKModel.InitGameData()
    if not m_data then
        print("<color=red>InitGameData m_data nil</color>")
        return
    end
    print("<color=red>InitGameData m_data 重置</color>")
    m_data.countdown = 0
    m_data.cur_p = nil
    m_data.cur_mopai = nil
    m_data.cur_chupai ={p=0,pai=nil}
    m_data.cur_pgh_card=nil
    m_data.cur_pgh_allow_opt=nil
    m_data.hu_data={}
    m_data.hu_data_map={}
    m_data.status = MjXzFKModel.Status.ready
    m_data.playerInfo = {}
    for k,v in ipairs(m_data.playerInfo) do
        v.spList = {}
        v.cpList = {}
        v.pgList = {}
        v.auto = 0
        v.lackColor = -2
    end
    m_data.ting_data = nil
    m_data.zjSeatno = nil
    m_data.actionList = {}
    m_data.jipaiqi=nil
    m_data.my_pai_list = {}
    m_data.my_pai_map = normal_majiang.get_pai_map_by_list(m_data.my_pai_list)
    m_data.my_pg_map = normal_majiang.get_pg_map_by_pplist({})
    m_data.remain_card = 108
    m_data.sezi_value1 = 0
    m_data.sezi_value2 = 0
    m_data.pgh_data=nil
    m_data.chupai_ting_data=nil
    m_data.is_guo=nil
    m_data.settlement_info=nil
    m_data.gameover_info=nil
end

MjXzFKModel.piaoIconVec = {
    --[0] = "mj_game_icon_p0",
    --[1] = "mj_game_icon_p1",
    --[3] = "mj_game_icon_p3",
    --[5] = "mj_game_icon_p5",

    [0] = "mj_game_imgf_bupiao",
    [1] = "mj_game_imgf_jiapiao",
    [3] = "mj_game_imgf_jiapiao",
    [5] = "mj_game_imgf_jiapiao",

}


-- 所有的游戏数据
function MjXzFKModel.on_friendgame_all_info(proto_name, data)
    dump(data, "<color=red>所有的游戏数据</color>", 10)
    if data.status_no==-1 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        MainLogic.GotoScene("game_Hall")
    else
        MjXzFKModel.InitGameData()
        m_data.model_status = data.status
        m_data.game_type = data.game_type
        MjXzFKModel.game_type = data.game_type
        m_data.friendgame_room_no = data.zijianfang_room_no
        m_data.ori_game_cfg = data.ori_game_cfg
        m_data.init_stake = data.init_stake or MjXzFKModel.get_ori_game_cfg_byOption("init_stake")
        --###_test  转化成显示数据
        print("<color=yellow>---------------------------- m_data.game_type:</color>",MjXzFKModel.game_type)
        MjXzFKModel.setBaseShouPaiNum(MjXzFKModel.game_type)
        MjXzFKModel.setMaxPlayerNumber(MjXzFKModel.game_type)
        MjXzFKModel.setTotalCardNum(MjXzFKModel.game_type)
        --转化成算法需要的配置数据
        m_data.translate_config= cfg_trans_nor_mj_xzdd.translate(m_data.ori_game_cfg)
        --初始化算法库

        local kaiguan = nil
        local multi = nil

        local s = data
        if s then
            --MjXzFKModel.buf_game_type = s.game_type
            m_data.countdown = s.countdown

            print("<color=yellow>---------------------------- m_data.game_type:</color>",MjXzFKModel.game_type)
            MjXzFKModel.setBaseShouPaiNum(MjXzFKModel.game_type)
            MjXzFKModel.setMaxPlayerNumber(MjXzFKModel.game_type)
            MjXzFKModel.setTotalCardNum(MjXzFKModel.game_type)

            if s.game_kaiguan then
                kaiguan = basefunc.decode_kaiguan(s.game_type , s.game_kaiguan)
            end
            if s.game_multi then
                multi = basefunc.decode_multi(s.game_type , s.game_multi)
            end

            dump(kaiguan , "<color=yellow>all_info , kaiguan --------- </color>")
            dump(multi , "<color=yellow>all_info , multi --------- </color>")
            
        end

        mj_algorithm = nor_mj_base_lib.New( kaiguan , multi , MjXzFKModel.game_type)

        local kaiguan = mj_algorithm:getSelfKaiguan()
        if kaiguan.da_piao then
            MjXzFKModel.daPiao = true
        else
            MjXzFKModel.daPiao = false
        end


        m_data.gameover_info = data.gameover_info

        m_data.room_owner = data.room_owner
        m_data.password = data.password
        m_data.player_ready = {}
        for k,v in pairs(data.ready) do 
            v.opt = v.status
            m_data.player_ready[v.player_id] = v
        end
        m_data.player_count = data.player_count

        local s = data.player_info
        if s then
            m_data.playerInfo=m_data.playerInfo or {}
            for i=1,4 do
                m_data.playerInfo[i]= {}
            end
            for _,v in pairs(s) do
                m_data.playerInfo[v.seat_num].base=v
                if v.id == MainModel.UserInfo.user_id then
                    m_data.seat_num = v.seat_num
                end
            end
        end

        s = data.vote_data
        dump(data.vote_data, "<color=yellow>断线重连投票数据</color>")
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
        if m_data.model_status==  MjXzFKModel.Model_Status.gameover then
            MainLogic.ExitGame()
        end

        s = data.nor_mj_xzdd_status_info
        if m_data.seat_num and s then
            m_data.status=s.status
            m_data.countdown=s.countdown
            if not m_data.countdown then
                m_data.countdown = 0
            end
            m_data.is_over = s.is_over
            m_data.cur_p=s.cur_p
            m_data.cur_pai=s.cur_pai
            m_data.remain_card=s.remain_card
            m_data.cur_race=s.cur_race
            m_data.ready=s.ready
            if not m_data.ready then
                m_data.ready = {0,0,0,0}
            end
            m_data.is_guo=s.is_guo

            --m_data.seat_num =s.seat_num
            m_data.init_rate =s.init_rate
            m_data.race_count =s.race_count

            if s.sezi_data then
                m_data.zjSeatno = s.sezi_data.zj_seat
                m_data.sezi_value1= s.sezi_data.sezi_value1
                m_data.sezi_value2 =s.sezi_data.sezi_value2
            end

            if s.settlement_info then
                m_data.settlement_info=s.settlement_info.settlement_items
            end

            if s.my_pai_list then
                m_data.playerInfo[m_data.seat_num].spList=s.my_pai_list
                dump( m_data.playerInfo[m_data.seat_num].spList,"1111")
                m_data.my_pai_map=normal_majiang.get_pai_map_by_list(s.my_pai_list)
            end
            if s.player_remain_card then
                for i=1,4 do
                    if i~=m_data.seat_num then
                        m_data.playerInfo[i].spList={}
                        local list=m_data.playerInfo[i].spList
                        for j=1,s.player_remain_card[i] do
                            list[#list + 1] = 0
                        end
                        dump( m_data.playerInfo[i],"222")
                    end
                end
            end

            if s.pg_pai then
                for i=1,4 do
                    m_data.playerInfo[i].pgList=s.pg_pai[i].pg_pai_list
                    if i==m_data.seat_num then
                        m_data.my_pg_map=normal_majiang.get_pg_map_by_pplist(s.pg_pai[i].pg_pai_list)
                    end
                end
            end
            if s.chu_pai then
                for i=1,4 do
                    m_data.playerInfo[i].cpList=s.chu_pai[i].pai_list
                end
            end
            --记牌器
            m_data.jipaiqi=normal_majiang.jipaiqi_server_to_client(s.jipaiqi)

            if s.auto_status then
                for i=1,4 do
                    m_data.playerInfo[i].auto=s.auto_status[i]
                end
            end
            if s.dingque_pai then
                for i=1,4 do
                    m_data.playerInfo[i].lackColor=s.dingque_pai[i]
                end
            end
            m_data.action_list={}
            if s.action then
                m_data.action_list[#m_data.action_list+1]=s.action
            end

            m_data.hu_data=s.hu_data
            m_data.hu_data_map={}
            if m_data.hu_data then
                for i,v in ipairs(m_data.hu_data) do
                    v.shunxu=i
                    m_data.hu_data_map[v.seat_num]=v
                end
            end
            table.print("<color=red>hupaidata:</color>",m_data.hu_data_map)

            m_data.cur_mopai=s.cur_mopai
            m_data.cur_chupai={}
            if s.cur_chupai then
                m_data.cur_chupai.p = s.cur_chupai.seat_num
                m_data.cur_chupai.pai = s.cur_chupai.pai
            end


            m_data.cur_pgh_card=s.cur_pgh_card
            m_data.cur_pgh_allow_opt=s.cur_pgh_allow_opt
            --刷新我的碰杠胡权限
            if m_data.seat_num and m_data.seat_num==s.cur_p then
                MjXzFKModel.getMyPghgData(m_data.cur_pgh_allow_opt)
                if m_data.status == MjXzFKModel.Status.mo_pai or m_data.status == MjXzFKModel.Status.chu_pai then
                    MjXzFKModel.getChupaiTingData()
                end
            end
            if s.my_pai_list then 
                MjXzFKModel.GetTingPai()
            end

            if s.da_piao_nums then
                for i,v in ipairs(s.da_piao_nums) do
                    m_data.playerInfo[i].piaoNum=s.da_piao_nums[i]
                end
            end
            ---- 换三张
            if m_data.status == MjXzFKModel.Status.huan_san_zhang then
                m_data.huanSanZhangVec = normal_majiang.getStringVec( normal_majiang.getSelectHuanSanZhangePai() , "|")
                dump(m_data.huanSanZhangVec,"<color=yellow>--------------- all Data . m_data.huanSanZhangVec -----------</color>")
                --- 第一个等于0表示操作过
                if m_data.huanSanZhangVec[1] == 0 then
                    table.remove(m_data.huanSanZhangVec , 1)

                    ---- 判断手牌中是否有要换的牌，没有的话，就选默认的
                    if not normal_majiang.check_shoupai_can_huanpai(m_data.my_pai_map , m_data.huanSanZhangVec)  then
                        m_data.huanSanZhangVec = MjXzFKModel.getDefaultHuanSanZhangPai()
                        -- 把数据保存到本地
                        normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(m_data.huanSanZhangVec,"|") )
                    end
                else
                    m_data.huanSanZhangVec = MjXzFKModel.getDefaultHuanSanZhangPai()

                    -- 把数据保存到本地
                    normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(m_data.huanSanZhangVec,"|") )
                end

            end

            m_data.isCanOpPai = true

            m_data.isHuanPai = s.is_huan_pai == 1
        end
    end
    Event.Brocast("model_friendgame_all_info")

    if MjXzFKModel.data and MjXzFKModel.data.room_dissolve and MjXzFKModel.data.room_dissolve ~= 0 then
    else
        MjXzFKModel.RefreshGPS(false)
    end
end

function MjXzFKModel.RefreshGPS(isCreate)
    if m_data and (m_data.model_status == MjXzFKModel.Model_Status.wait_begin or isCreate) then
        GPSPanel.query_gps_info(isCreate,m_data.seat_num,m_data.playerInfo,function (isTrustDistance)
            Event.Brocast("model_query_gps_info_msg",isTrustDistance)
        end)
    end
end


--[[******************************
Model的方法

玩家UI位置图
    3
4       2
    1
******************************--]]
-- 判断是否能进入
function MjXzFKModel.IsRoomEnter(id)
    local v = MjXzFKModel.UIConfig.entrance[id]
    
    local dd = MainModel.UserInfo.jing_bi
    if MjXzFKModel.UIConfig.config[id].gameModel == 1 then
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
function MjXzFKModel.IsAgainRoomEnter(id)
    local v = MjXzFKModel.UIConfig.entrance[id]
    
    local dd = MainModel.UserInfo.jing_bi
    if MjXzFKModel.UIConfig.config[id].gameModel == 1 then
        if v.min_coin > 0 and dd < v.min_coin then
            return 1 -- 过高
        end
    end
    return 0
end

function MjXzFKModel.on_kaiguan_multi_change_msg(proto_name, data)
    dump( data , "<color=yellow> ---- 开关，番数改变 </color>" )

    mj_algorithm:set_kaiguan( basefunc.decode_kaiguan( MjXzFKModel.game_type , data.game_kaiguan) )
    mj_algorithm:set_multi( basefunc.decode_multi( MjXzFKModel.game_type , data.game_multi) )

    local kaiguan = mj_algorithm:getSelfKaiguan()
    if kaiguan.da_piao then
        MjXzFKModel.daPiao = true
    else
        MjXzFKModel.daPiao = false
    end

end

local voiceShowPos =
{
    [1] = {pos = {x=-712, y=-200, z=0}, rota= {x=0, y=0, z=0} },
    [2] = {pos = {x=686, y=268, z=0}, rota= {x=0, y=180, z=0} },
    [3] = {pos = {x=230, y=448, z=0}, rota= {x=0, y=0, z=180} },
    [4] = {pos = {x=-712, y=280, z=0}, rota= {x=0, y=0, z=0} },   
}
-- 根据玩家ID返回语音显示的位置与旋转参数
-- 语音聊天必须要这个方法
function MjXzFKModel.GetIdToVoiceShowPos (id)
    for k,v in ipairs(MjXzFKModel.data.playerInfo) do
        if v.base and tostring(v.base.id) == tostring(id) then
            local uiPos = MjXzFKModel.GetSeatnoToPos (v.base.seat_num)
            return voiceShowPos[uiPos]
        end
    end
    dump(id, "<color=red>发送者ID</color>")
    dump(MjXzFKModel.data.playerInfo, "<color=red>玩家列表</color>")
    return {pos = {x=0, y=0, z=0}, rota= {x=0, y=0, z=0} }
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function MjXzFKModel.GetAnimChatShowPos (id)
    if m_data and m_data.playerInfo then
        for k,v in ipairs(MjXzFKModel.data.playerInfo) do
            if v.base and tostring(v.base.id) == tostring(id) then
                local uiPos = MjXzFKModel.GetSeatnoToPos (v.base.seat_num)
                return uiPos, false
            end
        end
    end
    dump(id, "<color=red>发送者ID</color>")
    dump(MjXzFKModel.data.playerInfo, "<color=red>玩家列表</color>")
    return 1, false
end

-- 返回自己真实的座位号
function MjXzFKModel.GetRealPlayerSeat ()
    return m_data.seat_num
end

-- 返回自己的座位号
function MjXzFKModel.GetPlayerSeat ()
    if m_data.seat_num then
        if MjXzFKModel.checkIsEr() then
            return MjXzFKModel.translateSeatNo( m_data.seat_num )
        else
            return m_data.seat_num
        end
    else
        return 1
    end
end
---- 转换座位号，非1即3
function MjXzFKModel.translateSeatNo( seteno )
    return seteno == 1 and 1 or 3
end


-- 返回自己的UI位置
function MjXzFKModel.GetPlayerUIPos ()
    return MjXzFKModel.GetSeatnoToPos (m_data.seat_num)
end
-- 根据座位号获取玩家UI位置
function MjXzFKModel.GetSeatnoToPos (seatno)
    if seatno then
        local seNo = seatno
        if MjXzFKModel.checkIsEr() then
            seNo = MjXzFKModel.translateSeatNo( seatno )
        end
        local seftSeatno = MjXzFKModel.GetPlayerSeat()
        return (seNo - seftSeatno + 4) % 4 + 1
    else
        return m_data.seat_num
    end
end
-- 根据UI位置获取玩家座位号
function MjXzFKModel.GetPosToSeatno (uiPos)
    local seftSeatno = MjXzFKModel.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % 4 + 1
end

-- 根据UI位置获取玩家座位号
function MjXzFKModel.GetPosToPlayer (uiPos)
    local seatno = MjXzFKModel.GetPosToSeatno (uiPos)

    local playerInfoPtr = m_data.playerInfo and m_data.playerInfo[seatno]

    if MjXzFKModel.checkIsEr() then
        playerInfoPtr = MjXzFKModel.GetTranslatePlayerInfoPtr(seatno)
    end

    return playerInfoPtr
end

function MjXzFKModel.GetTranslatePlayerInfoPtr(seatno)
    if seatno == 1 then
        return m_data.playerInfo[1]
    elseif seatno == 3 then
        return m_data.playerInfo[2]
    end
    return nil
end
function MjXzFKModel.GetHuPaiInfo()
    if MjXzFKModel.checkIsEr() then
        local ret = { {},{},{},{} }
        ret[1] = basefunc.deepcopy(m_data.hu_data_map[1]) 
        ret[2] = nil
        ret[3] = basefunc.deepcopy(m_data.hu_data_map[2]) 
        ret[4] = nil
        return ret
    else
        return m_data.hu_data_map
    end
end

-- 是否是自己 玩家自己的UI位置在1号位
function MjXzFKModel.IsPlayerSelf (uiPos)
    return uiPos == 1
end

---检查是否是自己的权限人
function MjXzFKModel.isMyPermit()
    if m_data.cur_p and m_data.seat_num and m_data.cur_p == m_data.seat_num then
        return true
    end
    return false
end

-- 当前进入人数
function MjXzFKModel.GetCurrPlayerCount()
    local nn = 0
    for k,v in ipairs(MjXzFKModel.data.playerInfo) do
        if v.base then
            nn = nn + 1
        end
    end
    return nn
end

-- 该座位号是不是房主
function MjXzFKModel.IsFZ(seatno)
    if not seatno then 
        seatno = m_data.seat_num
    end
    local data = MjXzFKModel.data
    dump(data)
    if data and data.playerInfo and data.playerInfo[seatno].base and data.playerInfo[seatno].base.id == data.room_owner then
        return true
    end
end

---- 判断自己是否为庄家
function MjXzFKModel.isZj()
    return m_data.zjSeatno == m_data.seat_num
end

-- 剩余牌数
function MjXzFKModel.GetRemainCard ()
    return m_data.remain_card
end

-- 定缺Icon
function MjXzFKModel.GetDQIcon(dqColor)
    if dqColor == 1 then
        return "mj_que_tong"
    elseif dqColor == 2 then
        return "mj_que_tiao"
    elseif dqColor == 3 then
        return "mj_que_wan"
    else
        return "mj_que_wan"
    end
end

-- 推荐定缺 todo nmg
function MjXzFKModel.GetTJDQ()
    return 1
end
-- 杠的类型 1-暗杠 2-直杠 3-弯杠 todo nmg
function MjXzFKModel.GetGangType()
    return 1
end

-- 麻将UI显示
--麻将的表示：
--11 ~ 19  : 筒
--21 ~ 29  : 条
--31 ~ 39  : 万
function MjXzFKModel.GetCardName(val)
    if val >= 11 and val <= 19 then
        return (val - 10) .. "筒"
    elseif val >= 21 and val <= 29 then
        return (val - 20) .. "条"
    elseif val >= 31 and val <= 39 then
        return (val - 30) .. "万"
    else
        return "发财"
    end
end
-- 是否同色
function MjXzFKModel.IsTongSe(val1, val2)
    if val1 >= 11 and val1 <= 19 and val2 >= 11 and val2 <= 19 then
        return true
    elseif val1 >= 21 and val1 <= 29 and val2 >= 21 and val2 <= 29 then
        return true
    elseif val1 >= 31 and val1 <= 39 and val2 >= 31 and val2 <= 39 then
        return true
    end
end
-- 色
function MjXzFKModel.GetSe(val)
    if val >= 11 and val <= 19 then
        return 1
    elseif val >= 21 and val <= 29 then
        return 2
    elseif val >= 31 and val <= 39 then
        return 3
    end
    print("<color=red>val = " .. val .. "</color>")
end
--获得碰杠胡过 数据
--[[
    {
        gang={
                {
                        type  --杠的类型  
                        pai  --牌
                }
        }，
        peng=pai,  --牌
        hu={
                
        }
        guo= ture OR false
    }

--]]


function MjXzFKModel.getMyPghgData(pghPermit)
    local function get_ag_list(map,dingque_pai)
        local list
        if map then
            for id,v in pairs(map) do
                if v==4 and MjXzFKModel.GetSe(id)~=dingque_pai then
                    list=list or {}
                    list[#list+1]={type="ag",pai=id}
                end
            end
        end
        return list
    end
    local function get_wg(pg_map,paimap)
        if pg_map and paimap then
            local list
            for  pai,pgtype in pairs(pg_map) do
                if pgtype=="peng" and paimap[pai] and paimap[pai]==1  then
                    list=list or {}
                    list[#list+1]={type="wg",pai=pai}
                end
            end
            return list
        end
        return nil
    end
    local function get_zg(map,pai)
        if map then
            if map[pai]==3 then
                return {type="zg",pai=pai}
            end
        end
        return nil
    end
    local function get_peng(map,pai)
        if map then
            if map[pai] and map[pai]>1 then
                return {type="peng",pai=pai}
            end
        end
        return nil
    end
    if m_data then
        m_data.pgh_data=nil
        if pghPermit then
            local gang,peng
            if pghPermit.gang then
                gang={{type="zg",pai=m_data.cur_pgh_card}}
            end
            if pghPermit.peng then
                peng={type="peng",pai=m_data.cur_pgh_card}
            end

            m_data.pgh_data={hu=pghPermit.hu,gang=gang,peng=peng,guo=true}
        else
            if m_data.is_guo==1 then
                return 
            end
            local status= m_data.status
            if status == MjXzFKModel.Status.mo_pai or status == MjXzFKModel.Status.start then
                --计算 hu 杠 弯杠(只能在摸牌时才能弯杠，并且只能是摸的那张牌)
                local ag=get_ag_list(m_data.my_pai_map,m_data.playerInfo[m_data.seat_num].lackColor)
                local wg=get_wg(m_data.my_pg_map,m_data.my_pai_map)
                local is_hu=mj_algorithm:check_is_hupai(m_data.my_pai_map,m_data.my_pg_map,m_data.playerInfo[m_data.seat_num].lackColor)
                local gang
                if ag then
                    gang=ag
                end
                if wg then
                    gang=gang or {}
                    for k,v in ipairs(wg) do
                        gang[#gang+1]=v
                    end
                end
                --最后一张牌不能杠
                if m_data.remain_card==0 then
                    gang=nil
                end

                if gang or is_hu then
                    m_data.pgh_data={hu=is_hu,gang=gang,guo=true}
                end
            elseif status==MjXzFKModel.Status.chu_pai then
                --最后一张牌不能杠
                if m_data.remain_card==0 then
                    return  
                end
                --计算 杠
                local ag=get_ag_list(m_data.my_pai_map,m_data.playerInfo[m_data.seat_num].lackColor)
                local wg=get_wg(m_data.my_pg_map,m_data.my_pai_map)
                if wg then
                    gang=gang or {}
                    for k,v in ipairs(wg) do
                        gang[#gang+1]=v
                    end
                end

                if ag  then
                    m_data.pgh_data={gang=ag,guo=true}
                end
            end
        end
        
    end
end

function MjXzFKModel.getDefaultHuanSanZhangPai()
    local ret = {}

    if not m_data or not m_data.my_pai_map then
        return ret
    end

    ret = mj_algorithm:get_default_huansanzhang_pai(m_data.my_pai_map)

    return ret
end

function MjXzFKModel.getChupaiTingData()
    if m_data then
        dump(m_data.my_pai_map)
        dump(m_data.my_pg_map)
        m_data.chupai_ting_data=mj_algorithm:get_chupai_ting_info(m_data.my_pai_map,m_data.my_pg_map,m_data.playerInfo[m_data.seat_num].lackColor)
        dump(m_data.chupai_ting_data)
        if m_data.chupai_ting_data then
            for id,v in pairs(m_data.chupai_ting_data) do
                for idx,data in ipairs(v) do
                    m_data.chupai_ting_data[id][idx].remain=m_data.jipaiqi[data.ting_pai]
                end
            end
        end
    end
end

function MjXzFKModel.on_zijianfang_ready_msg(_,data)
    dump(data,"<color=red>玩家准备信息----------------</color>")
    m_data.player_ready = m_data.player_ready or {}
    m_data.player_ready[data.player_id] = data
    Event.Brocast("model_zjf_player_ready_info_change",data.player_id)
end

function MjXzFKModel.GetReadyStatusBySeatNum(SeatNum)
    if SeatNum then 
        for k,v in pairs(m_data.player_ready) do 
            if v.seat_num == SeatNum then 
                return v.opt == 1
            end
        end
    end
    return false
end

function MjXzFKModel.GetReadyStatusByID(ID)
    if ID then
        if m_data.player_ready and m_data.player_ready[ID] and m_data.player_ready[ID].opt == 1 then 
            return true
        end
    end
    return false
end

function MjXzFKModel.sort_by_dingque_color()
    -- body
    local myS=m_data.seat_num
    local qp = {}
    local sp = {}
    for i,v in ipairs(m_data.playerInfo[myS].spList) do
        if MjXzFKModel.GetSe(v) == m_data.playerInfo[myS].lackColor then
            qp[#qp + 1] = v
        else
            sp[#sp+1]=v
        end
    end
    --排个序
    if #qp > 1 then table.sort(qp) end
    if #sp > 1 then table.sort(sp) end
    for _,v in ipairs(qp) do
        sp[#sp+1]=v
    end    
    m_data.playerInfo[myS].qpList = qp
    m_data.playerInfo[myS].spList = sp
end

--去除最近出牌
function MjXzFKModel.KickCurrChuCard()
    if m_data.cur_chupai then
        local p=m_data.cur_chupai.p
        if p>0 then
            local cplist = m_data.playerInfo[p].cpList
            cplist[#cplist]=nil
            m_data.cur_chupai.p=0
            m_data.cur_chupai.pai=nil
        end
    end
end
function MjXzFKModel.GetTingPai()
    if  m_data  then
        local myS=m_data.seat_num
        m_data.ting_data = mj_algorithm:get_ting_info(m_data.my_pai_map, m_data.my_pg_map, m_data.playerInfo[myS].lackColor)
        m_data.ting_data_map=nil
        if m_data.ting_data then
            for _idx, v in pairs(m_data.ting_data) do
                v.remain = m_data.jipaiqi[v.ting_pai] or 0
            end
        end
    else
        m_data.ting_data=nil
    end
    Event.Brocast("model_nMjXzFKfg_ting_data_change_msg")
end
function MjXzFKModel.clearTingPaiData()
    if m_data then
        m_data.ting_data=nil
    end
    Event.Brocast("model_nMjXzFKfg_ting_data_change_msg")
end

function MjXzFKModel.RefreshTingPaiRemain()
    if m_data and m_data.ting_data then
        for _, v in pairs(m_data.ting_data) do
            v.remain = m_data.jipaiqi[v.ting_pai] or 0
        end
    end
end

local juTable = {
    [1] = "第一局",
    [2] = "第二局",
    [3] = "第三局",
    [4] = "第四局",
    [5] = "第五局",
    [6] = "第六局",
    [7] = "第七局",
    [8] = "第八局",
    [9] =  "第九局",
    [10] = "第十局",
    [11] = "第十一局",
    [12] = "第十二局",
    [13] = "第十三局",
    [14] = "第十四局",
    [15] = "第十五局",
    [16] = "第十六局",
}

function MjXzFKModel.JUCountNumToChar(num)
    return juTable[num]
end

function MjXzFKModel.InitReadyStatus()
    m_data.player_ready = {}
end

function MjXzFKModel.get_ori_game_cfg_byOption(Option)
    if MjXzFKModel.data.ori_game_cfg then 
        for k ,v in pairs(MjXzFKModel.data.ori_game_cfg) do 
            if v.option == Option then 
                return v.value
            end
        end
    end 
end

function MjXzFKModel.CheakCanReadyGame()
    --每个人
    local xishu = GameZJFModel.get_ddz_enter_xishu_by_type(MjXzFKModel.data.game_type)
    if MjXzFKModel.IsFZPaY() then
        if MjXzFKModel.IsFZ() then
            xishu = xishu * (MjXzFKModel.data.game_type == "nor_ddz_er" and 2 or 3)
        else
            xishu = 0
        end
	end
    local need = (MjXzFKModel.get_ori_game_cfg_byOption("enter_limit") * MjXzFKModel.GetCurrBeiShu() + xishu) * MjXzFKModel.get_ori_game_cfg_byOption("init_stake") + GameZJFModel.get_ddz_enter_base_by_type(MjXzFKModel.data.game_type)
    dump(need,"<color=red>当前需要多少.."..need.."..鲸币才能开始游戏</color>")
    if MainModel.UserInfo.jing_bi >= need then
        return true
    end
end

function MjXzFKModel.GetCurrBeiShu()
    local feng_ding_bs = GameZJFModel.fengding_bs_ddz_str
    local bs = GameZJFModel.fengding_bs_ddz_int
    for i = 1,#feng_ding_bs do
        if MjXzFKModel.get_ori_game_cfg_byOption(feng_ding_bs[i]) then 
            return bs[i]
        end
    end
end

function MjXzFKModel.IsFZPaY()
    if MjXzFKModel.get_ori_game_cfg_byOption("fangzhu_pay") == 1 then 
        return true
    end
    return false
end


--- 某人打漂
function MjXzFKModel.on_nor_mj_xzdd_da_piao_msg(proto_name, data)
    dump(data,"<color=yellow>------------- MjXzFKModel.on_nor_mj_xzdd_da_piao_msg </color>")
    m_data.playerInfo[data.seat_num] = m_data.playerInfo[data.seat_num] or {}
    m_data.playerInfo[data.seat_num].piaoNum = data.piao_num

    Event.Brocast("model_nor_mj_xzdd_da_piao_msg" , data.seat_num)
    Event.Brocast("activity_nor_da_piao_msg")
end

function MjXzFKModel.on_nor_mj_xzdd_da_piao_finish_msg(proto_name, data)
    m_data.status= MjXzFKModel.Status.da_piao_finish    

    Event.Brocast("model_nor_mj_xzdd_da_piao_finish_msg" )
end