--[[
正常消息是指除断线重连以外的消息
]]
local normal_majiang=require "Game.normal_mj_common.Lua.normal_majiang_lib"
local nor_mj_base_lib = require "Game.normal_mj_common.Lua.nor_mj_algorithm_lib"
local FreeAwardConfig = require "Game.game_MjXl3D.Lua.mjxl_drivingrange_award3D"   --奖励配置
local NormalMaJiangEnum = require "Game.normal_mj_common.Lua.normal_majiang_enum"
package.loaded["Game.normal_mj_common.Lua.MjCard3D"] = nil
require "Game.normal_mj_common.Lua.MjCard3D"
local basefunc = require "Game.Common.basefunc"

MjXlModel = {}

local mj_algorithm
local this 
local lister
local m_data
local update
local updateDt=0.1

MjXlModel.baseShouPaiNum = 13

MjXlModel.maxPlayerNumber = 4

MjXlModel.totalCardNum = 108

function MjXlModel.setBaseShouPaiNum(gameType)
    if gameType == MjXlLogic.game_type.nor_mj_xzdd_er_7 then
        --print("setBaseShouPaiNum 1",gameType , MjXlLogic.game_type.nor_mj_xzdd_er_7)
        MjXlModel.baseShouPaiNum = 7
    else
        --print("setBaseShouPaiNum 2",gameType)
        MjXlModel.baseShouPaiNum = 13
    end
end

function MjXlModel.setMaxPlayerNumber(gameType)
    if gameType == MjXlLogic.game_type.nor_mj_xzdd_er_7 or gameType == MjXlLogic.game_type.nor_mj_xzdd_er_13 then
        MjXlModel.maxPlayerNumber = 2
    else
        MjXlModel.maxPlayerNumber = 4
    end
end

function MjXlModel.setTotalCardNum(gameType)
    if gameType == MjXlLogic.game_type.nor_mj_xzdd_er_7 or gameType == MjXlLogic.game_type.nor_mj_xzdd_er_13 then
        MjXlModel.totalCardNum = 72
    else
        MjXlModel.totalCardNum = 108
    end
end

function MjXlModel.checkIsEr()
    if MjXlModel.game_type == MjXlLogic.game_type.nor_mj_xzdd_er_7 or MjXlModel.game_type == MjXlLogic.game_type.nor_mj_xzdd_er_13 then
        return true
    end
    return false
end

function MjXlModel.checkIsEr7zhang()
    if MjXlModel.game_type == MjXlLogic.game_type.nor_mj_xzdd_er_7 then
        return true
    end
    return false
end

---- add by wss è‡ªåŠ¨è°ƒæ•´éº»å°†å¤§å°
function MjXlModel.autoAdjustMjSize()
    --- ä¸€ä¸ªå±å¹•æœ€å¤šæ˜¾ç¤ºçš„ç‰Œçš„ä¸ªæ•°
    local screenShowCardNum = 16

    --if MjXlModel.game_type == MjXlLogic.game_type.nor_mj_xzdd or MjXlModel.game_type == MjXlLogic.game_type.nor_mj_xzdd_er_13 then
        -- å¦‚æžœæ¯”ä¾‹å°äºŽ 16/9
        if Screen.width / Screen.height < 16/9 then
            local targetWidth = Screen.height * 16/9
            local everyCardWidth = targetWidth / screenShowCardNum

            local scale = (Screen.width / screenShowCardNum) / everyCardWidth
            print("<color=yellow>-------------- scale: </color>",scale)
            --MjCard3D.setScreenAutoAdjustScale(scale)

            --local myCardPos = GameObject.Find( "majiang_fj/mjz_01/handCardPos1" )
            --myCardPos.transform.localScale = Vector3.New( MjCard3D.parent_scale.x * scale , MjCard3D.parent_scale.y * scale , MjCard3D.parent_scale.z * scale )

            --- ä½ç½®è°ƒæ•´
            --myCardPos.transform.localPosition = MjMyShouPaiManger3D:setShouPaiNodePosOriginPos( Vector3.New( -7*MjCard3D.origSize.x*MjCard3D.sizeScale* scale , myCardPos.transform.localPosition.y+(MjCard3D.size.y*scale/2) , myCardPos.transform.localPosition.z ) )

            MjXlModel.cardScale = {}
            MjXlModel.cardScale.localScale = Vector3.New( MjCard3D.parent_scale.x * scale , MjCard3D.parent_scale.y * scale , MjCard3D.parent_scale.z * scale )
            MjXlModel.cardScale.localPosition = Vector3.New( -7*MjCard3D.origSize.x*MjCard3D.sizeScale * MjCard3D.parent_scale.x* scale , 
                                                                MjCard3D.parent_position.y+(MjCard3D.size.y* MjCard3D.parent_scale.y*(1-scale)/2) , 
                                                                    MjCard3D.parent_position.z )

            ----------  ä¸»æ‘„åƒæœºè°ƒæ•´ --------
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

MjXlModel.Model_Status = {
    --等待分配桌子，疯狂匹配中
    wait_table = "wait_table",
    --报名成功，在桌子上等待开始游戏
    wait_begin = "wait_begin",
    --游戏状态处于游戏中
    gaming = "gaming",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

MjXlModel.Status =
{
    start = "start",-- 开始游戏
    wait_table = "wait_table", -- 等待配桌
    wait_p = "wait_p", -- 等待人员入座
    fp = "fp", -- 发牌

    tou_sezi = "tou_sezi",     --- 投骰子状态
    chu_pai = "cp",--出牌
    ding_que = "ding_que", -- 定缺
    da_piao = "da_piao",   -- 打漂
    da_piao_finish = "da_piao_finish",   -- 打漂完成
    mo_pai = "mo_pai", -- 摸牌
    peng_gang_hu = "peng_gang_hu", -- 碰、杠、胡
    huan_san_zhang = "huan_san_zhang",     -- 换三张
    huan_san_zhang_finish = "huan_san_zhang_finish",     -- 换三张

    settlement="settlement",
    gameover="gameover",
}

MjXlModel.PaiType =
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
MjXlModel.HuPaiPosCfg = {
    [1] = { splitNum = 5 , splitOffset = Vector3.New( 0,0,MjCard3D.size.z ) },
    [2] = { splitNum = 3 , splitOffset = Vector3.New( 0,MjCard3D.size.y,0 ) },
    [3] = { splitNum = 5 , splitOffset = Vector3.New( 0,0,MjCard3D.size.z ) },
    [4] = { splitNum = 3 , splitOffset = Vector3.New( 0,MjCard3D.size.y,0 ) },
}

MjXlModel.piaoIconVec = {
    --[0] = "mj_game_icon_p0",
    --[1] = "mj_game_icon_p1",
    --[3] = "mj_game_icon_p3",
    --[5] = "mj_game_icon_p5",

    [0] = "mj_game_imgf_bupiao",
    [1] = "mj_game_imgf_jiapiao",
    [3] = "mj_game_imgf_jiapiao",
    [5] = "mj_game_imgf_jiapiao",

}

---- 转换座位号，非1即3
function MjXlModel.translateSeatNo( seteno )
    return seteno == 1 and 1 or 3
end

--[[
花色：1=万、2=筒、3=条

麻将的表示：
    11 ~ 19  : 筒
    21 ~ 29  : 条
    31 ~ 39  : 万
--]]


--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister={}

    ------------------------------------------------------------------------- new
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
    lister["nor_mj_xzdd_game_bankrupt_msg"] = this.on_nor_mj_xzdd_game_bankrupt_msg

    --response
    lister["fg_signup_response"] = this.on_fg_signup_response
    lister["fg_switch_game_response"] = this.on_fg_switch_game_response
    lister["fg_cancel_signup_response"] = this.on_fg_cancel_signup_response
    lister["fg_replay_game_response"] = this.on_fg_replay_game_response
    lister["fg_quit_game_response"] = this.on_fg_quit_game_response
    lister["fg_huanzhuo_response"] = this.on_fg_huanzhuo_response
    lister["fg_ready_response"] = this.on_fg_ready_response

    lister["kaiguan_multi_change_msg"] = this.on_kaiguan_multi_change_msg
    

    --玩法
    lister["nor_mj_xzdd_ready_msg"] = this.on_nor_mj_xzdd_ready_msg
    lister["nor_mj_xzdd_begin_msg"] = this.on_nor_mj_xzdd_begin_msg
    lister["nor_mj_xzdd_action_msg"] = this.on_nor_mj_xzdd_action_msg
    lister["nor_mj_xzdd_tou_sezi_msg"] = this.on_nor_mj_xzdd_tou_sezi_msg
    lister["nor_mj_xzdd_pai_msg"] = this.on_nor_mj_xzdd_pai_msg
    lister["nor_mj_xzdd_permit_msg"] = this.on_nor_mj_xzdd_permit_msg
    lister["nor_mj_xzdd_score_change_msg"] = this.on_nor_mj_xzdd_grades_change_msg
    lister["nor_mj_xzdd_dingque_result_msg"] = this.on_nor_mj_xzdd_dingque_result_msg
    lister["nor_mj_xzdd_auto_msg"] = this.on_nor_mj_xzdd_auto_msg
    lister["nor_mj_xzdd_settlement_msg"] = this.on_nor_mj_xzdd_settlement_msg
    lister["nor_mj_xzdd_next_game_msg"] = this.on_nor_mj_xzdd_next_game_msg

    lister["nor_mj_xzdd_da_piao_msg"] = this.on_nor_mj_xzdd_da_piao_msg
    lister["nor_mj_xzdd_da_piao_finish_msg"] = this.on_nor_mj_xzdd_da_piao_finish_msg
    
    lister["nor_mj_xzdd_huansanzhang_msg"] = this.on_nor_mj_xzdd_huansanzhang_msg
    lister["nor_mj_xzdd_huan_pai_finish_msg"] = this.on_nor_mj_xzdd_huan_pai_finish_msg

    --资产改变
    lister["logic_AssetChange"] = this.AssetChange
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
        if proto_name~="fg_all_info" then
            if m_data.status_no+1 ~= data.status_no and  m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no

                --发送状态编码错误事件
                print("<color=red>proto_name = " .. proto_name .. "</color>")
                Event.Brocast("model_fg_statusNo_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no 
    end
    func(proto_name, data)
end
--注册正常逻辑的消息事件
function MjXlModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        if proto_name == "logic_AssetChange" then
            Event.AddListener(proto_name, _)
        else
            Event.AddListener(proto_name, MsgDispatch)
        end
    end
end


--删除正常逻辑的消息事件
function MjXlModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        if proto_name == "logic_AssetChange" then
            Event.RemoveListener(proto_name, _)
        else
            Event.RemoveListener(proto_name, MsgDispatch)
        end
    end
end
function MjXlModel.Update()
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
local function InitMatchData(gameID)
    if not MjXlModel.baseData then
        MjXlModel.baseData = {}
    end

    MjXlModel.data = {
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
        sumRace = nil,
        --我的座位号
        seat_num = nil,
        --庄家座位号
        zjSeatno = nil,
        -- 玩家的操作
        actionList = {},
        -- 底分
        init_stake=nil,

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
        remain_card = MjXlModel.totalCardNum,
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

        isHuanPai = false,
        -- 是否可以换牌
        isCanOpPai = true,

        ---- 发牌动画时间间隔
        faPaiDelayTime = 0.07,

        score_change_list = {},
        activity_data = nil,
        ls_count = 1,
        game_bankrupt = nil,
        yingfengding = nil,
    }    
    m_data = MjXlModel.data
end
local function InitMatchStatusData(status)
    m_data.status = status
    m_data.countdown = 0
    m_data.cur_p = nil 
    m_data.cur_mopai = nil
    m_data.zjSeatno = nil
    m_data.ting_data=nil
    m_data.cur_pgh_card = nil
    m_data.cur_chupai = {p=0,pai=nil}
    m_data.hu_data={}
    m_data.hu_data_map={}
    m_data.my_pg_map={}
    m_data.actionList = {}
    for i=1,4 do
        m_data.playerInfo=m_data.playerInfo or {}
        m_data.playerInfo[i]=m_data.playerInfo[i] or {}
        m_data.playerInfo[i].spList = {}
        m_data.playerInfo[i].pgList = {}
        m_data.playerInfo[i].cpList = {}
        m_data.playerInfo[i].auto = {}
        m_data.playerInfo[i].lackColor = -2
        m_data.playerInfo[i].piaoNum = -1
    end
    m_data.jipaiqi=nil
    m_data.my_pai_map ={}
    m_data.remain_card = MjXlModel.totalCardNum
    m_data.sezi_value1 = 0
    m_data.sezi_value2 = 0
    m_data.pgh_data =nil
    m_data.chupai_ting_data = nil
    m_data.is_guo=nil
    m_data.isHuanPai = false
    m_data.isCanOpPai = true
    m_data.score_change_list = {}
    m_data.game_bankrupt = nil
    m_data.yingfengding = nil
end
local function InitMatchRoomData(status)
    InitMatchStatusData(status)
    m_data.roomId = nil
    m_data.playerInfo = {}
    m_data.seat_num=nil
end

function MjXlModel.InitGameData()
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
    for k,v in ipairs(m_data.playerInfo) do
        v.spList = {}
        v.cpList = {}
        v.pgList = {}
        v.auto = 0
        v.lackColor = -2
        v.piaoNum = -1
    end
    m_data.ting_data = nil
    m_data.zj_seat = nil
    m_data.actionList = {}
    m_data.jipaiqi=nil
    m_data.my_pai_list = {}
    m_data.my_pai_map = normal_majiang.get_pai_map_by_list(m_data.my_pai_list)
    m_data.my_pg_map = normal_majiang.get_pg_map_by_pplist({})
    m_data.remain_card = MjXlModel.totalCardNum
    m_data.sezi_value1 = 0
    m_data.sezi_value2 = 0
    m_data.pgh_data=nil
    m_data.chupai_ting_data=nil
    m_data.is_guo=nil
    m_data.settlement_info=nil
    m_data.gameover_info=nil
    m_data.glory_score_count = nil
    m_data.glory_score_change = nil
    m_data.isCanOpPai = true
    m_data.ls_count = 1
end

function MjXlModel.Init()
    InitMatchData()
    InitMatchStatusData(nil)
    this = MjXlModel
    this.gameList = nil
    --收到gameList的时间
    this.gameList_time=nil
    this.InitUIConfig()
    MakeLister()
    this.AddMsgListener()

    update = Timer.New(MjXlModel.Update, updateDt, -1,true)
    update:Start()
    MjXlModel.autoAdjustMjSize()

    return this
end
function MjXlModel.Exit()
    MjXlModel.RemoveMsgListener()
    update:Stop()
    update=nil
    this=nil
    lister=nil
    m_data=nil
    MjXlModel.data=nil
    MjXlModel.gameList=nil
    MjXlModel.gameList_time=nil
end
-- 初始化游戏配置Config
function MjXlModel.InitUIConfig()
    this.UIConfig={
        award = {},    }
    local award = this.UIConfig.award
    for _,v in ipairs(FreeAwardConfig.award_cfg) do
        award[v.id] = v
    end

end


-- 清除数据
function MjXlModel.ClearMatchData(gameID)
    InitMatchData(gameID)
end

--[[*************************************

网络数据

*************************************--]]





--[[******************************
Model的方法

玩家UI位置图
    3
4       2
    1
******************************--]]

--- 获得真实的座位号
function MjXlModel.GetRealPlayerSeat()
    return m_data.seat_num
end 

---检查是否是自己的权限人
function MjXlModel.isMyPermit()
    if m_data.cur_p and m_data.seat_num and m_data.cur_p == m_data.seat_num then
        return true
    end
    return false
end

-- 返回自己的座位号
function MjXlModel.GetPlayerSeat ()
    if m_data.seat_num then
        if MjXlModel.checkIsEr() then
            return MjXlModel.translateSeatNo( m_data.seat_num )
        else
            return m_data.seat_num
        end
    else
        return 1
    end
end
-- 返回自己的UI位置
function MjXlModel.GetPlayerUIPos ()
    return MjXlModel.GetSeatnoToPos (m_data.seat_num)
end
-- 根据座位号获取玩家UI位置
function MjXlModel.GetSeatnoToPos (seatno)
    if seatno then
        local seNo = seatno
        if MjXlModel.checkIsEr() then
            seNo = MjXlModel.translateSeatNo( seatno )
        end
        local seftSeatno = MjXlModel.GetPlayerSeat()
        return (seNo - seftSeatno + 4) % 4 + 1
    else
        return m_data.seat_num
    end
end
-- 根据UI位置获取玩家座位号
function MjXlModel.GetPosToSeatno (uiPos)
    local seftSeatno = MjXlModel.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % 4 + 1
end

-- 根据UI位置获取玩家座位号
function MjXlModel.GetPosToPlayer (uiPos)
    local seatno = MjXlModel.GetPosToSeatno (uiPos)

    local playerInfoPtr = m_data.playerInfo and m_data.playerInfo[seatno]

    if MjXlModel.checkIsEr() then
        playerInfoPtr = MjXlModel.GetTranslatePlayerInfoPtr(seatno)
    end

    return playerInfoPtr
end

function MjXlModel.GetTranslatePlayerInfoPtr(seatno)
    if seatno == 1 then
        return m_data.playerInfo[1]
    elseif seatno == 3 then
        return m_data.playerInfo[2]
    end
    return nil
end

function MjXlModel.GetHuPaiInfo()
    if MjXlModel.checkIsEr() then
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
function MjXlModel.IsPlayerSelf (uiPos)
    return uiPos == 1
end

---- 判断自己是否为庄家
function MjXlModel.isZj()
    return m_data.zjSeatno == m_data.seat_num
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function MjXlModel.GetAnimChatShowPos (id)
    if MjXlModel.data and MjXlModel.data.playerInfo then
        for k,v in ipairs(MjXlModel.data.playerInfo) do
            if v.base and tostring(v.base.id) == tostring(id) then
                local uiPos = MjXlModel.GetSeatnoToPos (v.base.seat_num)
                return uiPos, false, true
            end
        end             
    end
    dump(id, "<color=red>发送者ID</color>")
    dump(MjXlModel.data.playerInfo, "<color=red>玩家列表</color>")
    return 1, false, true
end

-- 剩余牌数
function MjXlModel.GetRemainCard ()
    return m_data.remain_card
end

function MjXlModel.GetDaPiaoPlayerNum()
    local num = 0

    if m_data.playerInfo and type(m_data.playerInfo) == "table" then
        for k,data in pairs(m_data.playerInfo) do
            local piaoNum = data.piaoNum
            if piaoNum == 1 then
                num = num + 1
            end
        end
    end

    return num
end

-- 定缺Icon
function MjXlModel.GetDQIcon(dqColor)
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
function MjXlModel.GetTJDQ()
    return 1
end
-- 杠的类型 1-暗杠 2-直杠 3-弯杠 todo nmg
function MjXlModel.GetGangType()
    return 1
end

-- 麻将UI显示
--麻将的表示：
--11 ~ 19  : 筒
--21 ~ 29  : 条
--31 ~ 39  : 万
function MjXlModel.GetCardName(val)
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
function MjXlModel.IsTongSe(val1, val2)
    if val1 >= 11 and val1 <= 19 and val2 >= 11 and val2 <= 19 then
        return true
    elseif val1 >= 21 and val1 <= 29 and val2 >= 21 and val2 <= 29 then
        return true
    elseif val1 >= 31 and val1 <= 39 and val2 >= 31 and val2 <= 39 then
        return true
    end
end
-- 色
function MjXlModel.GetSe(val)
    if val >= 11 and val <= 19 then
        return 1
    elseif val >= 21 and val <= 29 then
        return 2
    elseif val >= 31 and val <= 39 then
        return 3
    end
    --print("<color=red>val = " .. val .. "</color>")
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


function MjXlModel.getMyPghgData(pghPermit)
    local function get_ag_list(map,dingque_pai)
        local list
        if map then
            for id,v in pairs(map) do
                if v==4 and MjXlModel.GetSe(id)~=dingque_pai then
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
            if status == MjXlModel.Status.mo_pai or status == MjXlModel.Status.start then
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
            elseif status==MjXlModel.Status.chu_pai then
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

function MjXlModel.getDefaultHuanSanZhangPai()
    local ret = {}

    if not m_data or not m_data.my_pai_map then
        return ret
    end

    if mj_algorithm then
        ret = mj_algorithm:get_default_huansanzhang_pai(m_data.my_pai_map)
    end
    return ret
end


function MjXlModel.getChupaiTingData()
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



function MjXlModel.sort_by_dingque_color()
    -- body
    local myS=m_data.seat_num
    local qp = {}
    local sp = {}
    for i,v in ipairs(m_data.playerInfo[myS].spList) do
        if MjXlModel.GetSe(v) == m_data.playerInfo[myS].lackColor then
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
function MjXlModel.KickCurrChuCard()
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
function MjXlModel.GetTingPai()
    if  m_data  then
        local myS=m_data.seat_num
        dump(m_data.my_pg_map,"<color=yellow>--------------m_data.my_pg_map:</color>")
        print("<color=red>--------------m_data.my_pg_map:</color>",m_data.my_pg_map)
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
    Event.Brocast("model_nmjxzfg_ting_data_change_msg")
end
function MjXlModel.clearTingPaiData()
    if m_data then
        m_data.ting_data=nil
    end
    Event.Brocast("model_nmjxzfg_ting_data_change_msg")
end

function MjXlModel.RefreshTingPaiRemain()
    if m_data and m_data.ting_data then
        for _, v in pairs(m_data.ting_data) do
            v.remain = m_data.jipaiqi[v.ting_pai] or 0
        end
    end
end


----------------------------------------------------------------------------------------- new
--所有数据
function MjXlModel.on_fg_all_info(proto_name, data)
    dump(data, "<color=yellow>on_fg_all_info</color>")
    if data.status_no == -1 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        MjXlLogic.change_panel( MjXlLogic.panelNameMap.hall )
    else
        local kaiguan = nil
        local multi = nil

        local s = data
        if s then
            m_data.model_status = s.status            
            MjXlModel.game_type = s.game_type
            --MjXlModel.buf_game_type = s.game_type
            m_data.countdown = s.countdown
            MjXlModel.baseData.room_rent = s.room_rent

            print("<color=yellow>---------------------------- m_data.game_type:</color>",MjXlModel.game_type)
            MjXlModel.setBaseShouPaiNum(MjXlModel.game_type)
            MjXlModel.setMaxPlayerNumber(MjXlModel.game_type)
            MjXlModel.setTotalCardNum(MjXlModel.game_type)

            if s.game_kaiguan then
                kaiguan = basefunc.decode_kaiguan(s.game_type , s.game_kaiguan)
            end
            if s.game_multi then
                multi = basefunc.decode_multi(s.game_type , s.game_multi)
            end

            dump(kaiguan , "<color=yellow>all_info , kaiguan --------- </color>")
            dump(multi , "<color=yellow>all_info , multi --------- </color>")
            
        end

        

        --[[if MjXlModel.checkIsEr() then
            kaiguan = er_kaiguan
            multi = er_multi
        end--]]

        mj_algorithm = nor_mj_base_lib.New( kaiguan , multi , MjXlModel.game_type)

        local kaiguan = mj_algorithm:getSelfKaiguan()
        if kaiguan.da_piao then
            MjXlModel.daPiao = true
        else
            MjXlModel.daPiao = false
        end

        mj_algorithm.baseShouPaiNum = MjXlModel.baseShouPaiNum
        mj_algorithm.maxShouPaiNum = mj_algorithm.baseShouPaiNum + 1

        m_data.playerInfo=m_data.playerInfo or {}
        for i=1,4 do
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

        
        s = data.nor_mj_xzdd_status_info
        if m_data.seat_num and s then   -- 
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
            m_data.init_stake =s.init_stake
            m_data.init_rate =s.init_rate
            m_data.race_count =s.race_count

            if s.sezi_data then
                m_data.zjSeatno = s.sezi_data.zj_seat
                m_data.sezi_value1= s.sezi_data.sezi_value1
                m_data.sezi_value2 =s.sezi_data.sezi_value2
            end

            if s.settlement_info then
                m_data.settlement_info=s.settlement_info.settlement_items
                if s.settlement_info.yingfengding then
                    m_data.yingfengding = s.settlement_info.yingfengding
                end
            end

            if s.game_players_info then
                m_data.game_players_info = s.game_players_info
            end
            
            if s.my_pai_list then
                m_data.playerInfo[m_data.seat_num] = m_data.playerInfo[m_data.seat_num] or {}
                m_data.playerInfo[m_data.seat_num].spList = basefunc.deepcopy(s.my_pai_list)
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
                MjXlModel.getMyPghgData(m_data.cur_pgh_allow_opt)
                if m_data.status == MjXlModel.Status.mo_pai or m_data.status == MjXlModel.Status.chu_pai then
                    MjXlModel.getChupaiTingData()
                end
            end
            if s.my_pai_list then 
                MjXlModel.GetTingPai()
            end

            if s.da_piao_nums then
                for i,v in ipairs(s.da_piao_nums) do
                    m_data.playerInfo[i].piaoNum=s.da_piao_nums[i]
                end
            end

            ---- 换三张
            if m_data.status == MjXlModel.Status.huan_san_zhang then
                m_data.huanSanZhangVec = normal_majiang.getStringVec( normal_majiang.getSelectHuanSanZhangePai() , "|")
                dump(m_data.huanSanZhangVec,"<color=yellow>--------------- all Data . m_data.huanSanZhangVec -----------</color>")
                --- 第一个等于0表示操作过
                if m_data.huanSanZhangVec[1] == 0 then
                    table.remove(m_data.huanSanZhangVec , 1)

                    ---- 判断手牌中是否有要换的牌，没有的话，就选默认的
                    if not normal_majiang.check_shoupai_can_huanpai(m_data.my_pai_map , m_data.huanSanZhangVec)  then
                        m_data.huanSanZhangVec = MjXlModel.getDefaultHuanSanZhangPai()
                        -- 把数据保存到本地
                        normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(m_data.huanSanZhangVec,"|") )
                    end
                
                else
                    m_data.huanSanZhangVec = MjXlModel.getDefaultHuanSanZhangPai()

                    -- 把数据保存到本地
                    normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(m_data.huanSanZhangVec,"|") )
                end

            end

            if s.game_bankrupt then
                m_data.game_bankrupt = s.game_bankrupt
            end

            m_data.isCanOpPai = true

            m_data.isHuanPai = s.is_huan_pai == 1
            m_data.score_change_list = s.score_change_list

            if s.zhuan_yu_data then
                local zyData = {}
                for i, d in ipairs(s.zhuan_yu_data) do
                    zyData[#zyData + 1] = {p = d.hu_seat, pai = d.pai, other = tostring(d.gang_seat)}
                end
                m_data.zhuan_yu_data = zyData
            end
        end

        s = data.room_info
        if s then
            m_data.init_stake = s.init_stake
            m_data.init_rate = s.init_rate
            MjXlModel.baseData.game_id = s.game_id
        end

        m_data.glory_score_count = data.glory_score_count
        m_data.glory_score_change = data.glory_score_change

        if data.activity_data then
            m_data.activity_data = data.activity_data
            MjXlModel.GetLSCount(data.activity_data)
        else
            m_data.activity_data = nil
            m_data.ls_count = 1
        end

        -- if m_data.model_status == MjXlModel.Model_Status.gameover then
        --     MainLogic.ExitGame()
        -- end

        --测试代码
        -- m_data.activity_data = {
        --     {key= "activity_id",value = 3},
        --     {key= "cs_seat",value = 1},
        --     {key= "jing_bi",value = 10000},
        --     {key= "cs_is_win",value = 0},
        --     {key= "seat_1",value = 0},
        --     {key= "seat_2",value = 1},
        --     {key= "seat_3",value = 1},
        --     {key= "seat_4",value = 1},
        -- }
    end

    if m_data then
        dump(nil, "<color=green>发送活动消息</color>")
        Event.Brocast("activity_fg_all_info",{activity_data = m_data.activity_data,game_type = MjXlModel.game_type,game_id = MjXlModel.baseData.game_id,model_status = m_data.model_status,status = m_data.status})
    end
    Event.Brocast("model_fg_all_info")
end


--进入房间
function MjXlModel.on_fg_enter_room_msg(proto_name, data)
    dump(data, "<color=yellow>on_fg_enter_room_msg</color>")
    m_data.model_status = MjXlModel.Model_Status.gaming
    m_data.status = MjXlModel.Status.wait_join
    InitMatchStatusData(m_data.status)

    for k, v in pairs(data.players_info) do
        m_data.playerInfo[v.seat_num].base = v
        if v.id == MainModel.UserInfo.user_id then
            m_data.seat_num = v.seat_num
        end
    end

    ---- 二人麻將，服務器的编号都是1,2,3递增的，这里是1就是1，是2就是3    

    m_data.deadwood_list = nil

    m_data.race = 1

    Event.Brocast("model_fg_enter_room_msg")
    Event.Brocast("activity_fg_enter_room_msg")
end

--其他玩家进入游戏
function MjXlModel.on_fg_join_msg(proto_name, data)
    dump(data, "<color=yellow>on_fg_join_msg</color>")

    local seatno = data.player_info.seat_num
    m_data.playerInfo[seatno]= m_data.playerInfo[seatno] or {}
    m_data.playerInfo[seatno].base = data.player_info

    Event.Brocast("model_fg_join_msg",  data.player_info.seat_num )
    Event.Brocast("activity_fg_join_msg", data.player_info.seat_num)
end

--其他玩家离开游戏
function MjXlModel.on_fg_leave_msg(proto_name, data)
    dump(data, "<color=yellow>on_fg_leave_msg</color>")
    m_data.playerInfo[data.seat_num].base = nil
    m_data.playerInfo[data.seat_num].spList = {}
    m_data.playerInfo[data.seat_num].pgList = {}
    m_data.playerInfo[data.seat_num].cpList = {}
    m_data.playerInfo[data.seat_num].auto = {}
    m_data.playerInfo[data.seat_num].lackColor = -2

    Event.Brocast("model_fg_leave_msg", data.seat_num)
    Event.Brocast("activity_fg_leave_msg", data.seat_num)
end

--比赛结束
function MjXlModel.on_fg_gameover_msg(proto_name, data)
    dump(data, "<color=red>比赛结束</color>")
    m_data.model_status = MjXlModel.Model_Status.gameover
    for k, v in pairs(m_data.playerInfo) do
        if v.base then
            v.base.ready = 0
        end
    end

    m_data.glory_score_count = data.glory_score_count
    m_data.glory_score_change = data.glory_score_change
    MjXlModel.showChallenge = false

    Event.Brocast("model_fg_gameover_msg")
    Event.Brocast("activity_fg_gameover_msg")
end


--分数改变
function MjXlModel.on_fg_score_change_msg(proto_name, data)
    --[[dump(data, "<color=yellow>分数改变</color>")
    if m_data.playerInfo[m_data.seat_num] and m_data.playerInfo[m_data.seat_num].base then
        m_data.playerInfo[m_data.seat_num].base.score = data.score
    end
    Event.Brocast("model_nor_mg_score_change_msg")--]]
end

---- 自动取消报名
function MjXlModel.on_fg_auto_cancel_signup_msg(proto_name, data)
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_cancel_signup_msg")
end

---- 自动退出游戏报名
function MjXlModel.on_fg_auto_quit_game_msg(proto_name, data)
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_quit_game_msg")
end

---- 准备
function MjXlModel.on_fg_ready_msg(proto_name, data)
    local seatno = data.seat_num
    if m_data.playerInfo[seatno] and m_data.playerInfo[seatno].base then
        m_data.playerInfo[seatno].base.ready = 1
        Event.Brocast("model_fg_ready_msg", seatno)
        Event.Brocast("activity_fg_ready_msg", seatno)
    end
end

-------------------------------------------------------------------response
--比赛报名结果
function MjXlModel.on_fg_signup_response(_, data)
    dump(data, "<color=yellow>on_fg_signup_response</color>")
    if data.result == 0 then
        MjXlModel.InitGameData()
        m_data.model_status = MjXlModel.Model_Status.wait_table
        m_data.status = nil
        for k, v in pairs(m_data.playerInfo) do
            v.base = nil
        end
        --0-不可以取消  1-可以取消
        m_data.is_cancel_signup = data.is_cancel_signup
        m_data.countdown = data.cancel_signup_cd

        MjXlModel.game_type = data.game_type

        -- m_data.match_model = data.match_info.match_model
        MainLogic.EnterGame()
        Event.Brocast("model_fg_signup_response", data.result)
        Event.Brocast("activity_fg_signup_msg")
    else
        Event.Brocast("model_fg_signup_fail_response", data.result)
    end
end
function MjXlModel.on_fg_switch_game_response(proto_name, data)
    MjXlModel.on_fg_signup_response(proto_name, data)
end

function MjXlModel.on_fg_cancel_signup_response(_, data)
    if data.result == 0 then
        m_data.model_status = nil
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        Event.Brocast("model_fg_cancel_signup_response", data.result)
        print("---------------- on_fg_cancel_signup_response 1")
    else
        print("---------------- on_fg_cancel_signup_response 2")
        Event.Brocast("model_nor_mg_cancel_signup_fail_response", data.result)
    end
end


--再玩一把
function MjXlModel.on_fg_replay_game_response(proto_name, data)
    dump(data, "<color=red>再玩一把</color>")
    if data.result == 0 then
        MjXlModel.on_fg_signup_response(proto_name, data)
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
                    MjXlLogic.change_panel( MjXlLogic.panelNameMap.hall )
                end
            )
        end
    end
end

--退出游戏
function MjXlModel.on_fg_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>on_fg_quit_game_response</color>")
    if data.result == 0 then
        InitMatchData()
        MainLogic.ExitGame()
        MjXlLogic.change_panel( MjXlLogic.panelNameMap.hall )
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--换桌
function MjXlModel.on_fg_huanzhuo_response(proto_name, data)
    dump(data, "<color=yellow>on_fg_huanzhuo_response</color>")
    Event.Brocast("fg_huanzhuo_response_code", data.result)
    if data.result == 0 then
        MjXlModel.InitGameData()
        m_data.model_status = MjXlModel.Model_Status.wait_table
        m_data.status = nil

        for k, v in pairs(m_data.playerInfo) do
            v.base = nil
        end
        Event.Brocast("model_fg_huanzhuo_response")
    end
end

-- 准备
function MjXlModel.on_fg_ready_response(_, data)
    dump(data, "<color=yellow>on_fg_ready_response</color>")
    Event.Brocast("fg_ready_response_code", data.result)
    if data.result == 0 then
        MjXlModel.InitGameData()
        m_data.model_status = MjXlModel.Model_Status.wait_begin
        m_data.status = nil
        m_data.playerInfo[m_data.seat_num].base.ready = 1
        Event.Brocast("model_fg_ready_response")
    end
end

function MjXlModel.on_kaiguan_multi_change_msg(proto_name, data)
    dump( data , "<color=yellow> ---- 开关，番数改变 </color>" )

    mj_algorithm:set_kaiguan( basefunc.decode_kaiguan( MjXlModel.game_type , data.game_kaiguan) )
    mj_algorithm:set_multi( basefunc.decode_multi( MjXlModel.game_type , data.game_multi) )

    local kaiguan = mj_algorithm:getSelfKaiguan()
    if kaiguan.da_piao then
        MjXlModel.daPiao = true
    else
        MjXlModel.daPiao = false
    end

end

-------------------------------------------------------------------- new  玩法
-- 准备
function MjXlModel.on_nor_mj_xzdd_ready_msg(proto_name, data)
    dump(data, "<color=red>准备</color>")
    if not MjXlModel.data.ready then
        MjXlModel.data.ready = {0,0,0,0}
    end

    MjXlModel.data.ready[data.seat_num] = 1
    
    m_data.race = data.cur_race

    Event.Brocast("model_nor_mj_xzdd_ready_msg", data.seat_num )
end

-- 开始游戏
function MjXlModel.on_nor_mj_xzdd_begin_msg(proto_name, data)
    dump(data, "<color=red>开始游戏</color>")
    m_data.model_status = MjXlModel.Model_Status.gaming
    m_data.status = MjXlModel.Status.begin
    m_data.race = data.cur_race
    m_data.ready = {0,0,0,0}
    Event.Brocast("model_nor_mj_xzdd_begin_msg")

    --测试代码
    -- m_data.activity_data = {
    --     {key= "activity_id",value = 3},
    --     {key= "cs_seat",value = 1},
    -- }
    -- Event.Brocast("fg_activity_data_msg","fg_activity_data_msg",m_data)
end

function MjXlModel.on_nor_mj_xzdd_action_msg(proto_name, data)
    dump(data, "玩家的操作")
    m_data.actionList[#m_data.actionList + 1] = data.action
    local caozuo = data.action.type
    if caozuo == "zhuan_yu" then
        Event.Brocast("model_zhuan_yu_msg", {[1] = data.action})
    end

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

            MjXlModel.GetTingPai()
        else
            --记牌器  我自己的已经减去过了
            normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi)
            MjXlModel.RefreshTingPaiRemain()
        end

    elseif caozuo == "peng" then
        --加入pgmap
        if data.action.p==m_data.seat_num then
            m_data.my_pg_map[data.action.pai]="peng"
            m_data.my_pai_map[data.action.pai]= m_data.my_pai_map[data.action.pai]-2
            print("xxxxxxxxxxxx222")
            dump(m_data.my_pai_map)
            MjXlModel.getChupaiTingData()
            MjXlModel.clearTingPaiData()
        else
            --记牌器  我自己的已经减去过了
            normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,2)
            MjXlModel.RefreshTingPaiRemain()
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

            MjXlModel.GetTingPai()
        else
            --记牌器  我自己的已经减去过了
            if data.action.other=="zg" then
                normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,3)
            elseif data.action.other=="ag" then
                normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,4)
            elseif data.action.other=="wg" then
                normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,1)
            end
            MjXlModel.RefreshTingPaiRemain()
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
            MjXlModel.RefreshTingPaiRemain()
        end

        if data.action.p == m_data.seat_num then
            if data.action.hu_data.hu_type == "zimo" and m_data.my_pai_map[data.action.hu_data.pai] > 0 then
                m_data.my_pai_map[data.action.hu_data.pai] = m_data.my_pai_map[data.action.hu_data.pai] - 1
            end
            MjXlModel.GetTingPai()
        end
        dump(m_data.my_pai_map, "<color=green>--->>>my_pai_map:</color>")
    end

    Event.Brocast("model_nor_mj_xzdd_action_msg", data.action)
end


-- 确认庄家
function MjXlModel.on_nor_mj_xzdd_tou_sezi_msg(proto_name, data)
    dump(data, "确认庄家")
    m_data.status = MjXlModel.Status.ding_que
    ---- 二人麻将的庄家也是非1即3
    m_data.zjSeatno = data.zj_seat  --  data.zj_seat == 1 and 1 or 3
    m_data.sezi_value1 = data.sezi_value1
    m_data.sezi_value2 = data.sezi_value2
    Event.Brocast("model_nor_mj_xzdd_tou_sezi_msg")
end

-- 进入游戏的人数达到 n 人，自动发牌,游戏开始，人数满足要求，发牌开局
function MjXlModel.on_nor_mj_xzdd_pai_msg(proto_name, data)
    dump(data, "<color=red>开始发牌</color>")

    --- 清一下换三张的本地记录
    MjXlModel.clearHuanSanZhangData()

    m_data.status = MjXlModel.Status.fp
    m_data.remain_card = data.remain_card --totalCardNum - 14 - (MjXlModel.maxPlayerNumber-1)*13  ---   55 -- 14+13+13+13

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
                for j=1,MjXlModel.baseShouPaiNum + 1 do
                    v.spList[#v.spList + 1] = 0
                end
            else
                for j=1,MjXlModel.baseShouPaiNum do
                    v.spList[#v.spList + 1] = 0
                end
            end
        end
    end

    Event.Brocast("model_nor_mj_xzdd_pai_msg")
    Event.Brocast("activity_nor_fa_pai_msg")
end

-- 权限信息
function MjXlModel.on_nor_mj_xzdd_permit_msg(proto_name, data)
    dump(data, "<color=red>权限信息</color>")
    m_data.status = data.status
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown = (data.countdown - 1)
    if m_data.countdown < 0 then
        m_data.countdown = 0
    end
    m_data.cur_p = data.cur_p --MjXlModel.translateSeatNo(data.cur_p) 
    m_data.other = data.other

    m_data.is_guo=nil

    -- 摸牌，剩余牌数减1
    if m_data.status == MjXlModel.Status.mo_pai then
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
            MjXlModel.getMyPghgData()
            MjXlModel.getChupaiTingData()
            MjXlModel.clearTingPaiData()
        end
    elseif m_data.status == MjXlModel.Status.peng_gang_hu then
        --当前碰杠胡牌
        m_data.cur_pgh_card = data.pai
        MjXlModel.getMyPghgData(data.allow_opt)
    elseif m_data.status == MjXlModel.Status.ding_que then
        for i,v in ipairs(m_data.playerInfo) do
            v.lackColor=-1
        end
    elseif m_data.status == MjXlModel.Status.chu_pai then
        if m_data.seat_num==data.cur_p then
            -- MjXlModel.getMyPghgData()
            m_data.pgh_data=nil
            MjXlModel.getChupaiTingData()
        end
    elseif m_data.status == MjXlModel.Status.start then
        if m_data.seat_num==data.cur_p then
            MjXlModel.getMyPghgData()
            MjXlModel.getChupaiTingData()
        end
    elseif m_data.status == MjXlModel.Status.da_piao then
        -- 先把数据还原一下
        for i,v in ipairs(m_data.playerInfo) do
            v.piaoNum = -1
        end
    elseif m_data.status == MjXlModel.Status.huan_san_zhang then
        m_data.isHuanPai = false 
        -- 本地计算默认选中的三张牌
        local paiVec = MjXlModel.getDefaultHuanSanZhangPai()
        m_data.huanSanZhangVec = paiVec

        -- 把数据保存到本地
        normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(paiVec,"|") )

        Event.Brocast("model_huanSanZhang_num_change_msg")

    end
    Event.Brocast("model_nor_mj_xzdd_permit_msg")
end

--- 
function MjXlModel.addHuanSanZhangPai(pai)
    m_data.huanSanZhangVec[#m_data.huanSanZhangVec + 1] = pai
    
    print("<color=yellow>------- MjXlModel.addHuanSanZhangPai: </color>",pai)

    Event.Brocast("model_huanSanZhang_num_change_msg")
end

function MjXlModel.delHuanSanZhangPai(pai)
    for k,value in ipairs(m_data.huanSanZhangVec) do
        if value == pai then
            table.remove(m_data.huanSanZhangVec , k)
            print("<color=yellow>------- MjXlModel.delHuanSanZhangPai: </color>",pai)
            
            break
        end
    end
    Event.Brocast("model_huanSanZhang_num_change_msg")
end

function MjXlModel.saveHuanSanZhangData()
    normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(m_data.huanSanZhangVec,"|") )
end

function MjXlModel.clearHuanSanZhangData()
    normal_majiang.saveSelectHuanSanZhangePai("")
end

-- 分数改变
function MjXlModel.on_nor_mj_xzdd_grades_change_msg(proto_name, data)
    dump(data, "<color=red>分数改变</color>")
    m_data.moneyChange = data.data
    Event.Brocast("model_nor_mj_xzdd_grades_change_msg")
end

function MjXlModel.on_nor_mj_xzdd_dingque_result_msg(proto_name, data)
    dump(data.result, "<color=green>麻将 , dingque result</color>")
    print("<color=yellow>----------------- m_data.seat_num: </color>",m_data.seat_num)
    local result=data.result
    for i=1,4 do 
        m_data.playerInfo[i].lackColor = result[i]
    end
    Event.Brocast("model_nor_mj_xzdd_dingque_result_msg")
    Event.Brocast("activity_nor_dingque_result_msg")
end

function MjXlModel.on_nor_mj_xzdd_auto_msg(proto_name, data)
    m_data.playerInfo=m_data.playerInfo or {}
    m_data.playerInfo[data.p] = m_data.playerInfo[data.p] or {}
    m_data.playerInfo[data.p].auto = data.auto_status
    Event.Brocast("model_nor_mj_xzdd_auto_msg",data.p)
end

-- 结算
function MjXlModel.on_nor_mj_xzdd_settlement_msg(proto_name, data)
    dump(data, "<color=red>结算</color>",10)
    m_data.status= MjXlModel.Status.settlement
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
    
    --测试代码
    -- m_data.activity_data = {
    --     {key= "activity_id",value = 3},
    --     {key= "cs_seat",value = 1},
    --     {key= "jing_bi",value = 10000},
    --     {key= "cs_is_win",value = 0},
    --     {key= "seat_1",value = 0},
    --     {key= "seat_2",value = 1},
    --     {key= "seat_3",value = 1},
    --     {key= "seat_4",value = 1},
    -- }
    -- Event.Brocast("fg_activity_data_msg","fg_activity_data_msg",m_data)
    MjXlModel.grand_total_settlement(  )
end

--- 下一局,--打完一局重新发牌
function MjXlModel.on_nor_mj_xzdd_next_game_msg(proto_name, data)
    dump(data, "<color=red>on_nor_mj_xzdd_next_game_msg</color>")
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    m_data.race = data.cur_race
    Event.Brocast("model_nor_mj_xzdd_next_game_msg")
end

--- 某人打漂
function MjXlModel.on_nor_mj_xzdd_da_piao_msg(proto_name, data)
    dump(data,"<color=yellow>------------- MjXlModel.on_nor_mj_xzdd_da_piao_msg </color>")
    m_data.playerInfo[data.seat_num] = m_data.playerInfo[data.seat_num] or {}
    m_data.playerInfo[data.seat_num].piaoNum = data.piao_num

    Event.Brocast("model_nor_mj_xzdd_da_piao_msg" , data.seat_num)
    Event.Brocast("activity_nor_da_piao_msg")
end

function MjXlModel.on_nor_mj_xzdd_da_piao_finish_msg(proto_name, data)
    m_data.status= MjXlModel.Status.da_piao_finish    

    Event.Brocast("model_nor_mj_xzdd_da_piao_finish_msg" )
end

function MjXlModel.on_nor_mj_xzdd_huansanzhang_msg(proto_name, data)
    dump(data , "<color=yellow>-------------- on_nor_mj_xzdd_huansanzhang_msg  data.pai_vec </color>")
    m_data.huanSanZhangNewVec = data.pai_vec
    m_data.isHuanPai = true
    m_data.isCanOpPai = true

    m_data.jipaiqi = normal_majiang.jipaiqi_server_to_client(data.jipaiqi) 

    --- 新的手牌
    m_data.playerInfo[m_data.seat_num].spList = data.pai_list
    m_data.my_pai_map=normal_majiang.get_pai_map_by_list(data.pai_list)

    dump(m_data , "-------------------------------------->>>>>> huan san zhang end, m_data:")

    Event.Brocast("model_nor_mj_xzdd_huansanzhang_msg",data.is_time_out == 1)
end

function MjXlModel.on_nor_mj_xzdd_huan_pai_finish_msg(proto_name, data)
    m_data.status = MjXlModel.Status.huan_san_zhang_finish

    Event.Brocast("model_nor_mj_xzdd_huan_pai_finish_msg",data)
end

function MjXlModel.hz_call()
    Network.SendRequest("fg_huanzhuo", nil, "请求换桌")
end
function MjXlModel.zb_call()
    Network.SendRequest("fg_ready", nil, "请求准备")
end
function MjXlModel.hintCondition(call)
    local game_id = MjXlModel.baseData.game_id
    local ui_config = GameFreeModel.GetGameIDToConfig(game_id)
    PayFastFreePanel.Create(ui_config, call)
end
function MjXlModel.checkCondition(call)
    local game_id = MjXlModel.baseData.game_id
    local ss = GameFreeModel.IsAgainRoomEnter(game_id)
    if ss == 1 then
        LittleTips.Create("当前鲸币不足")
        MjXlModel.hintCondition(call)
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
function MjXlModel.HZCheck()
    if MjXlModel.checkCondition(MjXlModel.hz_call) then
        MjXlModel.hz_call()
    end
end
-- 准备检查
function MjXlModel.ZBCheck()
    if MjXlModel.checkCondition(MjXlModel.zb_call) then
        MjXlModel.zb_call()
    end
end

function MjXlModel.on_fg_activity_data_msg(proto_name, data)
    dump(data, "<color=yellow>-------------------on_fg_activity_data_msg->"..proto_name.."</color>")
    if data.activity_data then
        m_data.activity_data = data.activity_data
        MjXlModel.GetLSCount(data.activity_data)
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
                Event.Brocast("activity_fg_all_info",{activity_data = m_data.activity_data,game_type = MjXlModel.game_type,game_id = MjXlModel.baseData.game_id,model_status = m_data.model_status,status = m_data.status})
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

function MjXlModel.IsWin()
    local isWin = false
    for _, data in ipairs(m_data.settlement_info) do
        if data.seat_num == m_data.seat_num then
            isWin = (data.settle_data.score >= 0)
            break
        end
    end
    return isWin
end

--获取结算时所有玩家数据
function MjXlModel.GetPlayersData()
    if m_data and m_data.settlement_players_info then
        return m_data.settlement_players_info
    end
    return false
end

function MjXlModel.GetLSCount(activity_data)
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

function MjXlModel.on_nor_mj_xzdd_game_bankrupt_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_mj_xzdd_game_bankrupt_msg:</color>")
    if data.game_bankrupt then
        m_data.game_bankrupt = data.game_bankrupt
        Event.Brocast("model_nor_mj_xzdd_game_bankrupt_msg")
    end
end

--资产改变
function MjXlModel.AssetChange(proto_name, data)
    data = {score = MainModel.UserInfo.jing_bi}
    dump(data, "<color=yellow>AssetChange</color>")
    m_data.score = data.score
    if m_data.playerInfo[m_data.seat_num] and  m_data.playerInfo[m_data.seat_num].base then
        m_data.playerInfo[m_data.seat_num].base.score = data.score
    end
    Event.Brocast("model_AssetChange")
end

--[[累计胜负统计]]
function MjXlModel.grand_total_settlement()
    if MjXlModel.IsMyWin()then
        PlayerPrefs.SetInt("grand_total_free_lose_num" .. MainModel.UserInfo.user_id, 0)
    else
        local cur_lose_num = PlayerPrefs.GetInt("grand_total_free_lose_num" .. MainModel.UserInfo.user_id, 0)
        cur_lose_num = cur_lose_num + 1
        PlayerPrefs.SetInt("grand_total_free_lose_num" .. MainModel.UserInfo.user_id, cur_lose_num)
    end
end

function MjXlModel.IsMyWin()
    local isWin = false
    if m_data and m_data.settlement_info then
        for _, data in ipairs(m_data.settlement_info) do
            local i = MjXlModel.GetSeatnoToPos (data.seat_num)
            if i == 1 then
                local score = 0
                if data.settle_data.score then
                    score = data.settle_data.score
                end
                isWin = (score > 0 or (score == 0 and data.settle_data.settle_type == "hu"))
            end
        end
    end
    return isWin
end