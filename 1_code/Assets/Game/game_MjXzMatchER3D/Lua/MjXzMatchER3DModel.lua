--[[
正常消息是指除断线重连以外的消息
]]
local normal_majiang=require "Game.normal_mj_common.Lua.normal_majiang_lib"
local nor_mj_base_lib = require "Game.normal_mj_common.Lua.nor_mj_algorithm_lib"
local FreeUIConfig = require "Game.game_MjXzMatchER3D.Lua.mjxzMatchER_freestyle_ui3D"	--ui配置
local FreeAwardConfig = require "Game.game_MjXzMatchER3D.Lua.mjxzMatchER_drivingrange_award3D"   --奖励配置
local NormalMaJiangEnum = require "Game.normal_mj_common.Lua.normal_majiang_enum"
package.loaded["Game.normal_mj_common.Lua.MjCard3D"] = nil
require "Game.normal_mj_common.Lua.MjCard3D"
local basefunc = require "Game.Common.basefunc"

local mj_algorithm

MjXzModel = {}

---- 玩家的基础手牌数量
MjXzModel.baseShouPaiNum = 13

---- 最大的玩家数量
MjXzModel.maxPlayerNumber = 4

MjXzModel.totalCardNum = 108

function MjXzModel.setBaseShouPaiNum(gameType)
    if gameType == MjXzLogic.game_type.nor_mj_xzdd_er_7 then
        print("setBaseShouPaiNum 1",gameType , MjXzLogic.game_type.nor_mj_xzdd_er_7)
        MjXzModel.baseShouPaiNum = 7
    else
        print("setBaseShouPaiNum 2",gameType)
        MjXzModel.baseShouPaiNum = 13
    end
end

function MjXzModel.setMaxPlayerNumber(gameType)
    if gameType == MjXzLogic.game_type.nor_mj_xzdd_er_7 or gameType == MjXzLogic.game_type.nor_mj_xzdd_er_13 then
        MjXzModel.maxPlayerNumber = 2
    else
        MjXzModel.maxPlayerNumber = 4
    end
end

function MjXzModel.setTotalCardNum(gameType)
    if gameType == MjXzLogic.game_type.nor_mj_xzdd_er_7 or gameType == MjXzLogic.game_type.nor_mj_xzdd_er_13 then
        MjXzModel.totalCardNum = 72
    else
        MjXzModel.totalCardNum = 108
    end
end

function MjXzModel.checkIsEr()
    if MjXzModel.game_type == MjXzLogic.game_type.nor_mj_xzdd_er_7 or MjXzModel.game_type == MjXzLogic.game_type.nor_mj_xzdd_er_13 then
        return true
    end
    return false
end

function MjXzModel.checkIsEr7zhang()
    if MjXzModel.game_type == MjXzLogic.game_type.nor_mj_xzdd_er_7 then
        return true
    end
    return false
end

---- add by wss 自动调整麻将大小
function MjXzModel.autoAdjustMjSize()
    --- 一个屏幕最多显示的牌的个数
    local screenShowCardNum = 16

    --if MjXzModel.game_type == MjXzLogic.game_type.nor_mj_xzdd or MjXzModel.game_type == MjXzLogic.game_type.nor_mj_xzdd_er_13 then
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

            MjXzModel.cardScale = {}
            MjXzModel.cardScale.localScale = Vector3.New( MjCard3D.parent_scale.x * scale , MjCard3D.parent_scale.y * scale , MjCard3D.parent_scale.z * scale )
            MjXzModel.cardScale.localPosition = Vector3.New( -7*MjCard3D.origSize.x*MjCard3D.sizeScale * MjCard3D.parent_scale.x* scale , 
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

MjXzModel.Model_Status = {
    --报名成功，收到nor_mg_signup_response进入状态,此时在等待界面
    wait_begin = "wait_begin",
    --等待分配桌子，收到nor_mg_begin_msg进入状态，进入游戏界面
    wait_table = "wait_table",
    --游戏状态处于游戏中
    gaming = "gaming",
    --玩家进入晋级
    promoted = "promoted",
    -- 等待复活
    wait_revive = "wait_revive",
    --等待晋级
    wait_result = "wait_result",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

MjXzModel.Status =
{
    start = "start",-- 开始游戏
    wait_table = "wait_table", -- 等待配桌
    wait_p = "wait_p", -- 等待人员入座
    fp = "fp", -- 发牌
    tou_sezi = "tou_sezi",
    chu_pai = "cp",--出牌
    ding_que = "ding_que", -- 定缺
    da_piao = "da_piao",   -- 打漂
    da_piao_finish = "da_piao_finish",   -- 打漂完成
    mo_pai = "mo_pai", -- 摸牌
    peng_gang_hu = "peng_gang_hu", -- 碰、杠、胡
    huan_san_zhang = "huan_san_zhang",     -- 换三张
    huan_san_zhang_finish = "huan_san_zhang_finish",     -- 换三张
    settlement="settlement",
}

MjXzModel.PaiType =
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
MjXzModel.HuPaiPosCfg = {
    [1] = { splitNum = 5 , splitOffset = Vector3.New( 0,0,MjCard3D.size.z ) },
    [2] = { splitNum = 3 , splitOffset = Vector3.New( 0,MjCard3D.size.y,0 ) },
    [3] = { splitNum = 5 , splitOffset = Vector3.New( 0,0,MjCard3D.size.z ) },
    [4] = { splitNum = 3 , splitOffset = Vector3.New( 0,MjCard3D.size.y,0 ) },
}

MjXzModel.piaoIconVec = {
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
function MjXzModel.translateSeatNo( seteno )
    return seteno == 1 and 1 or 3
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


local totalCardNum = 72

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister={}

    ----------------------------------------------------------------------------------------- new
    --模式
    lister["nor_mg_all_info"] = this.on_nor_mg_all_info
    lister["nor_mg_begin_msg"] = this.on_nor_mg_begin_msg
    lister["nor_mg_enter_room_msg"] = this.on_nor_mg_enter_room_msg
    lister["nor_mg_join_msg"] = this.on_nor_mg_join_msg
    lister["nor_mg_gameover_msg"] = this.on_nor_mg_gameover_msg
    lister["nor_mg_score_change_msg"] = this.on_nor_mg_score_change_msg
    lister["nor_mg_rank_msg"] = this.on_nor_mg_rank_msg
    lister["nor_mg_wait_result_msg"] = this.on_nor_mg_wait_result_msg
    lister["nor_mg_promoted_msg"] = this.on_nor_mg_promoted_msg
    lister["nm_mg_gameover_msg"] = this.on_nor_mg_gameover_msg
    lister["nor_mg_match_discard_msg"] = this.on_nor_mg_match_discard_msg

    --response
    lister["nor_mg_signup_response"] = this.on_nor_mg_signup_response
    lister["nor_mg_cancel_signup_response"] = this.on_nor_mg_cancel_signup_response
    lister["nor_mg_req_cur_signup_num_response"] = this.on_nor_mg_req_cur_signup_num_response
    lister["nor_mg_replay_game_response"] = this.on_nor_mg_replay_game_response
    lister["nor_mg_quit_game_response"] = this.on_nor_mg_quit_game_response
    lister["nor_mg_auto_cancel_signup_msg"] = this.on_nor_mg_auto_cancel_signup_msg
    lister["nor_mg_get_match_status_response"] = this.on_nor_mg_get_match_status_response
    lister["nor_mg_req_cur_player_num_response"] = this.on_nor_mg_req_cur_player_num

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

    --复活
    lister["nor_mg_wait_revive_msg"] = this.nor_mg_wait_revive_msg
    lister["nor_mg_free_revive_msg"] = this.nor_mg_free_revive_msg
    lister["nor_mg_revive_response"] = this.nor_mg_revive_response
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
        if proto_name~="nor_mg_all_info" then
            if m_data.status_no+1 ~= data.status_no and  m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no

                --发送状态编码错误事件
                print("<color=red>proto_name = " .. proto_name .. "</color>")
                Event.Brocast("model_nor_mg_statusNo_error_msg")
                return
            end
        end
        m_data.status_no = data.status_no 
    end
    func(proto_name, data)
end
--注册正常逻辑的消息事件
function MjXzModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end


--删除正常逻辑的消息事件
function MjXzModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
end
function MjXzModel.Update()
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
    MjXzModel.data = {
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
        race = nil,
        -- 总局数
        sumRace = nil,
        --我的座位号
        mySeatno = nil,
        --庄家座位号
        zjSeatno = nil,
        -- 玩家的操作
        actionList = {},
        -- 底分
        init_stake=nil,
        --次数
        detail_rank_num=nil;
        jipaiqi=nil,
        --[[ key=seatno 
        --base=基础信息 
            -- cpList=出牌列表 
            -- pgList=杠、碰牌列表
            -- spList=手牌列表 
            -- lackColor=定缺的花色(-2还未开始,-1=未定，0=已定缺、1=万、2=筒、3=条) 
            -- auto 
        --]]
        playerInfo ={},

        players_info = {}, --当前房间中玩家的信息(key=seat_num, value=玩家基础信息)

        --我的牌map
        my_pai_map={},
        --我的碰杠 map
        my_pg_map={},


        -- 剩余牌张数
        remain_card = MjXzModel.totalCardNum,
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

        isCanOpPai = true,

        ---- 发牌动画时间间隔
        faPaiDelayTime = 0.07,
        is_weed_out = 0,

    }    
    if gameID then
        MjXzModel.data.game_id = gameID
    end
    m_data = MjXzModel.data
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
        m_data.playerInfo[i].auto = 0
        m_data.playerInfo[i].lackColor = -2
        m_data.playerInfo[i].piaoNum = -1
    end
    m_data.jipaiqi=nil
    m_data.my_pai_map ={}
    m_data.remain_card =MjXzModel.totalCardNum
    m_data.sezi_value1 = 0
    m_data.sezi_value2 = 0
    m_data.pgh_data =nil
    m_data.chupai_ting_data = nil
    m_data.is_guo=nil
    m_data.isHuanPai = false
    m_data.isCanOpPai = true
    m_data.is_weed_out = 0
end
local function InitMatchRoomData(status)
    InitMatchStatusData(status)
    m_data.roomId = nil
    m_data.playerInfo = {}
    m_data.seat_num=nil
end
function MjXzModel.Init()
    InitMatchData()
    InitMatchStatusData(nil)
    this = MjXzModel
    this.gameList = nil
    --收到gameList的时间
    this.gameList_time=nil
    MakeLister()
    this.AddMsgListener()

    update = Timer.New(MjXzModel.Update, updateDt, -1,true)
    update:Start()

    MjXzModel.autoAdjustMjSize()

    return this
end
function MjXzModel.Exit()
    MjXzModel.RemoveMsgListener()
    update:Stop()
    update=nil
    this=nil
    lister=nil
    m_data=nil
    MjXzModel.data=nil
    MjXzModel.gameList=nil
    MjXzModel.gameList_time=nil
end

-- 清除数据
function MjXzModel.ClearMatchData(gameID)
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
-- 判断是否能进入
function MjXzModel.IsRoomEnter(id)
    dump(MjXzModel.macthUIConfig, "<color=red>判断是否能进入</color>")
    print(id, "<color=red>判断是否能进入</color>")
    local v = MjXzModel.macthUIConfig.entrance[id]

    local dd = MainModel.UserInfo.jing_bi
    if MjXzModel.macthUIConfig.config[id].gameModel == 1 then
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
function MjXzModel.IsAgainRoomEnter(id)
    local v = MjXzModel.UIConfig.entrance[id]
    
    local dd = MainModel.UserInfo.jing_bi
    if MjXzModel.UIConfig.config[id].gameModel == 1 then
        if v.min_coin > 0 and dd < v.min_coin then
            return 1 -- 过高
        end
    end
    return 0
end

--- 获得真实的座位号
function MjXzModel.GetRealPlayerSeat()
    return m_data.seat_num
end 

-- 返回自己的座位号
function MjXzModel.GetPlayerSeat ()
    if m_data.seat_num then
        if MjXzModel.checkIsEr() then
            return MjXzModel.translateSeatNo( m_data.seat_num )
        else
            return m_data.seat_num
        end
    else
        return 1
    end
end
-- 返回自己的UI位置
function MjXzModel.GetPlayerUIPos ()
    return MjXzModel.GetSeatnoToPos (m_data.seat_num)
end
-- 根据座位号获取玩家UI位置,seatno是传过来的1,2
function MjXzModel.GetSeatnoToPos (seatno)
    if seatno then
        local seNo = seatno
        if MjXzModel.checkIsEr() then
            seNo = MjXzModel.translateSeatNo( seatno )
        end
        local seftSeatno = MjXzModel.GetPlayerSeat()
        return (seNo - seftSeatno + 4) % 4 + 1
    else
        return m_data.seat_num
    end

end
-- 根据UI位置获取玩家座位号
function MjXzModel.GetPosToSeatno (uiPos)
    local seftSeatno = MjXzModel.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % 4 + 1    --- 这里一定用 % 4
end

-- 根据UI位置获取玩家 数据
function MjXzModel.GetPosToPlayer (uiPos)
    local seatno = MjXzModel.GetPosToSeatno (uiPos)

    local playerInfoPtr = m_data.playerInfo and m_data.playerInfo[seatno]

    if MjXzModel.checkIsEr() then
        playerInfoPtr = MjXzModel.GetTranslatePlayerInfoPtr(seatno)
    end

    --local realPlayerInfo = MjXzModel.GetTranslatePlayerInfo()
    --[[if MjXzModel.checkIsEr() then
        playerInfoPtr.base = m_data.players_info[seatno == 1 and 1 or 2]
    else
        playerInfoPtr.base = m_data.players_info[seatno]
    end--]]

    return playerInfoPtr
end

function MjXzModel.GetHuPaiInfo()
    if MjXzModel.checkIsEr() then
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

----- 转换到相应的座位上去，服务器的座位数据永远是1,2 ； 二人要转到1,3上去
function MjXzModel.GetTranslatePlayerInfo()
    local ret = { {},{},{},{} }
    ret[1] = basefunc.deepcopy(m_data.playerInfo[1]) 
    ret[2] = nil
    ret[3] = basefunc.deepcopy(m_data.playerInfo[2]) 
    ret[4] = nil
    return ret
end


function MjXzModel.GetTranslatePlayerInfoPtr(seatno)
    if seatno == 1 then
        return m_data.playerInfo[1]
    elseif seatno == 3 then
        return m_data.playerInfo[2]
    end
    return nil
end

-- 是否是自己 玩家自己的UI位置在1号位
function MjXzModel.IsPlayerSelf (uiPos)
    return uiPos == 1
end

---- 判断自己是否为庄家
function MjXzModel.isZj()
    return m_data.zjSeatno == m_data.seat_num
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function MjXzModel.GetAnimChatShowPos (id)
    if MjXzModel.data and MjXzModel.data.playerInfo then
        for k,v in ipairs(MjXzModel.data.playerInfo) do
            if v.base and tostring(v.base.id) == tostring(id) then
                local uiPos = MjXzModel.GetSeatnoToPos (v.base.seat_num)
                print(uiPos .. " vddddddddddddddd")
                return uiPos, false
            end
        end
    end
    dump(id, "<color=red>发送者ID</color>")
    dump(MjXzModel.data.playerInfo, "<color=red>玩家列表</color>")
    return 1, false
end

-- 剩余牌数
function MjXzModel.GetRemainCard ()
    return m_data.remain_card
end

function MjXzModel.GetDaPiaoPlayerNum()
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

---检查是否是自己的权限人
function MjXzModel.isMyPermit()
    if m_data.cur_p and m_data.seat_num and m_data.cur_p == m_data.seat_num then
        return true
    end
    return false
end

-- 定缺Icon
function MjXzModel.GetDQIcon(dqColor)
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
function MjXzModel.GetTJDQ()
    return 1
end
-- 杠的类型 1-暗杠 2-直杠 3-弯杠 todo nmg
function MjXzModel.GetGangType()
    return 1
end

-- 麻将UI显示
--麻将的表示：
--11 ~ 19  : 筒
--21 ~ 29  : 条
--31 ~ 39  : 万
function MjXzModel.GetCardName(val)
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
function MjXzModel.IsTongSe(val1, val2)
    if val1 >= 11 and val1 <= 19 and val2 >= 11 and val2 <= 19 then
        return true
    elseif val1 >= 21 and val1 <= 29 and val2 >= 21 and val2 <= 29 then
        return true
    elseif val1 >= 31 and val1 <= 39 and val2 >= 31 and val2 <= 39 then
        return true
    end
end
-- 色
function MjXzModel.GetSe(val)
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


function MjXzModel.getMyPghgData(pghPermit)
    local function get_ag_list(map,dingque_pai)
        local list
        if map then
            for id,v in pairs(map) do
                if v==4 and MjXzModel.GetSe(id)~=dingque_pai then
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
            if status == MjXzModel.Status.mo_pai or status == MjXzModel.Status.start then
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
                if gang and type(gang) == "table" and #gang > 0 then
                    dump(m_data.my_pai_map , "<color=yellow>--------------getMyPghgData 1.1 </color>")
                    dump(m_data.my_pg_map , "<color=yellow>--------------getMyPghgData 1.2 </color>")
                    print("<color=yellow>--------------getMyPghgData 1.3 </color>",m_data.playerInfo[m_data.seat_num].lackColor )

                    print("<color=yellow>--------------------- getMyPghgData 1: </color>", gang[1].pai )
                end
            elseif status==MjXzModel.Status.chu_pai then
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
                if ag and type(ag) == "table" and #ag > 0 then
                    print("<color=yellow>--------------------- getMyPghgData 2: </color>", ag[1].pai )
                end
            end
        end
        
    end
end

function MjXzModel.getChupaiTingData()
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



function MjXzModel.sort_by_dingque_color()
    -- body
    local myS=m_data.seat_num
    local qp = {}
    local sp = {}
    for i,v in ipairs(m_data.playerInfo[myS].spList) do
        if MjXzModel.GetSe(v) == m_data.playerInfo[myS].lackColor then
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
function MjXzModel.KickCurrChuCard()
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

function MjXzModel.getDefaultHuanSanZhangPai()
    local ret = {}

    if not m_data or not m_data.my_pai_map then
        return ret
    end
    if mj_algorithm then
        ret = mj_algorithm:get_default_huansanzhang_pai(m_data.my_pai_map)
    end
    return ret
end


function MjXzModel.GetTingPai()

    dump(m_data.jipaiqi , "<color=yellow>--------------- GetTingPai , m_data.jipaiqi </color>")

    if  m_data  then
        local myS=m_data.seat_num
        print("<color=yellow>---------------MjXzModel.GetTingPai , " .. myS .. " </color>")
        m_data.ting_data = mj_algorithm:get_ting_info(m_data.my_pai_map, m_data.my_pg_map, m_data.playerInfo[myS].lackColor)
        m_data.ting_data_map=nil
        dump(m_data.ting_data , "<color=yellow>--------------- GetTingPai , m_data.ting_data </color>")
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
function MjXzModel.clearTingPaiData()
    if m_data then
        m_data.ting_data=nil
    end
    Event.Brocast("model_nmjxzfg_ting_data_change_msg")
end

function MjXzModel.RefreshTingPaiRemain()
    dump(m_data.ting_data , "<color=yellow>--------------- RefreshTingPaiRemain , m_data.ting_data </color>")
    dump(m_data.jipaiqi , "<color=yellow>--------------- RefreshTingPaiRemain , m_data.jipaiqi </color>")

    if m_data and m_data.ting_data then
        for _, v in pairs(m_data.ting_data) do
            v.remain = m_data.jipaiqi[v.ting_pai] or 0
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------- new
function MjXzModel.on_nor_mg_all_info(proto_name, data)
    dump(data, "<color=yellow>所有数据</color>")
    if data.status_no == -1 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        MjXzLogic.change_panel(MjXzLogic.panelNameMap.hall)
    else
        local kaiguan = nil
        local multi = nil

        local s = data
        if s then
            m_data.model_status = s.status
            MjXzModel.game_type = s.game_type

            MjXzModel.setBaseShouPaiNum(MjXzModel.game_type)
            MjXzModel.setMaxPlayerNumber(MjXzModel.game_type)

            if s.game_kaiguan then
                kaiguan = basefunc.decode_kaiguan(s.game_type , s.game_kaiguan)
            end
            if s.game_multi then
                multi = basefunc.decode_multi(s.game_type , s.game_multi)
            end
        end

        m_data.revive_num = data.revive_num
        m_data.revive_assets = data.revive_assets
        m_data.revive_round = data.revive_round
        if m_data.revive_num and m_data.revive_assets then
            m_data.revive_time = m_data.countdown
        end

        --转化成算法需要的配置数据
        --m_data.translate_config= cfg_trans_nor_mj_xzdd.translate(m_data.ori_game_cfg)
        --初始化算法库
        mj_algorithm= nor_mj_base_lib.New( kaiguan , multi , MjXzModel.game_type) --nor_mj_base_lib.New(m_data.translate_config.kaiguan,m_data.translate_config.multi)

        local kaiguan = mj_algorithm:getSelfKaiguan()
        if kaiguan.da_piao then
            MjXzModel.daPiao = true
        else
            MjXzModel.daPiao = false
        end

        mj_algorithm.baseShouPaiNum = MjXzModel.baseShouPaiNum
        mj_algorithm.maxShouPaiNum = mj_algorithm.baseShouPaiNum + 1

        m_data.playerInfo=m_data.playerInfo or {}
        for i=1,4 do
            m_data.playerInfo[i] = m_data.playerInfo[i] or {}
            m_data.playerInfo[i].base = nil
        end

        s = data.players_info
        if s then
            for k, v in pairs(s) do
                -- m_data.players_info[ MjXzModel.translateSeatNo(v.seat_num) ] = v
                m_data.players_info[ v.seat_num ] = v
                m_data.playerInfo[v.seat_num].base=v
                if v.id == MainModel.UserInfo.user_id then
                    m_data.seat_num = v.seat_num
                end
            end
        end

        s = data.nor_mj_xzdd_status_info
        if m_data.seat_num and s then
            m_data.status=s.status

            m_data.countdown=s.countdown
            print("----------------- MjXzMatchER3DModel , m_data.countdown:",m_data.countdown)
            if not m_data.countdown then
                m_data.countdown = 0
            end
            m_data.is_over = s.is_over
            m_data.cur_p= s.cur_p --MjXzModel.translateSeatNo(s.cur_p) 
            m_data.cur_pai=s.cur_pai
            m_data.remain_card=s.remain_card
            m_data.race=s.cur_race
            m_data.ready=s.ready
            if not m_data.ready then
                m_data.ready = {0,0,0,0}
            end
            m_data.is_guo=s.is_guo

            m_data.seat_num = s.seat_num  --MjXzModel.translateSeatNo(s.seat_num)
            m_data.init_stake =s.init_stake
            m_data.init_rate =s.init_rate
            m_data.race_count =s.race_count

            if s.sezi_data then
                m_data.zjSeatno = s.sezi_data.zj_seat --MjXzModel.translateSeatNo( s.sezi_data.zj_seat )
                m_data.sezi_value1= s.sezi_data.sezi_value1
                m_data.sezi_value2 =s.sezi_data.sezi_value2
            end

            if s.settlement_info then
                m_data.settlement_info=s.settlement_info.settlement_items
            end

            if s.player_remain_card then
                m_data.playerInfo = m_data.playerInfo or {}
                for i=1,4 do
                    m_data.playerInfo[i] = m_data.playerInfo[i] or {}
                    if i~=m_data.seat_num then
                        m_data.playerInfo[i].spList={}
                        local list=m_data.playerInfo[i].spList
                        for j=1,s.player_remain_card[i] do
                            list[#list + 1] = 0
                        end
                    end
                end
            end

            if s.my_pai_list then
                m_data.playerInfo[ s.seat_num ].spList=s.my_pai_list
                m_data.my_pai_map=normal_majiang.get_pai_map_by_list(s.my_pai_list)
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
                m_data.cur_chupai.p = s.cur_chupai.seat_num -- MjXzModel.translateSeatNo( s.cur_chupai.seat_num )
                m_data.cur_chupai.pai = s.cur_chupai.pai
            end


            m_data.cur_pgh_card=s.cur_pgh_card
            m_data.cur_pgh_allow_opt=s.cur_pgh_allow_opt
            --刷新我的碰杠胡权限
            if m_data.seat_num and m_data.seat_num==s.cur_p then
                MjXzModel.getMyPghgData(m_data.cur_pgh_allow_opt)
                if m_data.status == MjXzModel.Status.mo_pai or m_data.status == MjXzModel.Status.chu_pai then
                    MjXzModel.getChupaiTingData()
                end
            end
            if s.my_pai_list then 
                MjXzModel.GetTingPai()
            end

             if s.da_piao_nums then
                for i,v in ipairs(s.da_piao_nums) do
                    m_data.playerInfo[i].piaoNum=s.da_piao_nums[i]
                end
            end

            ---- 换三张
            if m_data.status == MjXzModel.Status.huan_san_zhang then
                m_data.huanSanZhangVec = normal_majiang.getStringVec( normal_majiang.getSelectHuanSanZhangePai() , "|")
                dump(m_data.huanSanZhangVec,"<color=yellow>--------------- all Data . m_data.huanSanZhangVec -----------</color>")
                --- 第一个等于0表示操作过
                if m_data.huanSanZhangVec[1] == 0 then
                    table.remove(m_data.huanSanZhangVec , 1)

                    ---- 判断手牌中是否有要换的牌，没有的话，就选默认的
                    if not normal_majiang.check_shoupai_can_huanpai(m_data.my_pai_map , m_data.huanSanZhangVec)  then
                        m_data.huanSanZhangVec = MjXzModel.getDefaultHuanSanZhangPai()
                        -- 把数据保存到本地
                        normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(m_data.huanSanZhangVec,"|") )
                    end
                else
                    m_data.huanSanZhangVec = MjXzModel.getDefaultHuanSanZhangPai()

                    -- 把数据保存到本地
                    normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(m_data.huanSanZhangVec,"|") )
                end
            end

            m_data.isCanOpPai = true

            m_data.isHuanPai = s.is_huan_pai == 1

        end

        s = data.match_info
        if s then
            m_data.name = s.name
            m_data.total_players = s.total_players
            m_data.match_model = s.match_model
            m_data.is_cancel_signup = s.is_cancel_signup
            m_data.total_round = s.total_round
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
            m_data.nor_mg_final_result = data.gameover_info
        end

        s = data.room_info
        if s then
            m_data.game_id = s.game_id
            MatchModel.SetCurrGameID(s.game_id)
        end

        s = data.countdown
        if s then
            m_data.cancel_signup_cd = s
        end

        if m_data.model_status == MjXzModel.Model_Status.gameover or m_data.status == MjXzModel.Status.settlement then
            MainLogic.ExitGame()
        end
    end
    Event.Brocast("model_nor_mg_all_info")
end

--比赛开始
function MjXzModel.on_nor_mg_begin_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_mg_begin_msg</color>")
    m_data.model_status = MjXzModel.Model_Status.wait_table
    m_data.rank = data.rank
    m_data.score = data.score
    m_data.total_players = data.total_players
    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    Event.Brocast("model_nor_mg_begin_msg")
end

--进入房间
function MjXzModel.on_nor_mg_enter_room_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_mg_enter_room_msg</color>")
    m_data.model_status = MjXzModel.Model_Status.gaming
    m_data.status = MjXzModel.Status.wait_join
    InitMatchStatusData(m_data.status)
    --m_data.seat_num = data.seat_num

    ---- 二人麻將，服務器的编号都是1,2,3递增的，这里是1就是1，是2就是3
    m_data.seat_num = data.seat_num  -- MjXzModel.translateSeatNo( data.seat_num )

    m_data.game_id = data.room_info.game_id
    m_data.deadwood_list = nil

    m_data.seatNum = {}
    m_data.s2cSeatNum = {}
    nor_mj_base_lib.transform_seat(m_data.seatNum, m_data.s2cSeatNum, m_data.seat_num, MjXzModel.maxPlayerNumber)
    m_data.round_info = data.round_info
    m_data.my_rate = m_data.round_info.init_rate or 1
    m_data.init_stake = m_data.round_info.init_stake or 1

    m_data.race = 1

    if data.players_info then
        for k, v in pairs(data.players_info) do
            --m_data.players_info[ MjXzModel.translateSeatNo(v.seat_num) ] = 
            m_data.players_info[ v.seat_num ] = v

            m_data.playerInfo[v.seat_num].base = v
        end
    end

    Event.Brocast("model_nor_mg_enter_room_msg")
end

--其他玩家进入游戏
function MjXzModel.on_nor_mg_join_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_mg_join_msg</color>")
    --local realSeatNum = MjXzModel.translateSeatNo( data.player_info.seat_num )

    m_data.players_info[data.player_info.seat_num] = data.player_info
    m_data.playerInfo[data.player_info.seat_num].base = data.player_info
    Event.Brocast("model_nor_mg_join_msg",  data.player_info.seat_num )
end

--比赛结束
function MjXzModel.on_nor_mg_gameover_msg(proto_name, data)
    dump(data, "<color=red>比赛结束</color>")
    m_data.model_status = MjXzModel.Model_Status.gameover
    m_data.nor_mg_final_result = data.final_result
    
    if not data.is_weed_out then
        m_data.is_weed_out = (data.final_result.rank == 1 and 0 or 1)
    else
        m_data.is_weed_out = data.is_weed_out
    end
    
    if data.round_info then
        m_data.round_info = data.round_info
        if data.final_result.rank == 1 and m_data.round_info.round == m_data.total_round then
            m_data.round_info.round = m_data.round_info.round + 1
        end
    end

    if data.detail_rank_num then
        m_data.detail_rank_num = data.detail_rank_num
    end
    

    -- MainLogic.ExitGame()
    Event.Brocast("model_nor_mg_gameover_msg")
end

function MjXzModel.on_nor_mg_out_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_mg_out_msg</color>")
    Event.Brocast("model_nor_mg_out_msg")
end

--分数改变
function MjXzModel.on_nor_mg_score_change_msg(proto_name, data)
    dump(data, "<color=yellow>分数改变</color>")
    --m_data.grades = data.grades
    --if m_data.players_info[m_data.seat_num] then
    --    m_data.players_info[m_data.seat_num].score = data.score
    --end
    -- Event.Brocast("model_nor_mg_score_change_msg")
end

--玩家排名有变化,更新玩家排名
function MjXzModel.on_nor_mg_rank_msg(proto_name, data)
    m_data.rank = data.rank
    Event.Brocast("model_nor_mg_rank_msg")
end

--等待结果
function MjXzModel.on_nor_mg_wait_result_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_mg_wait_result_msg</color>")
    m_data.model_status = data.status
    m_data.status = MjXzModel.Status.wait_join
    
    if data.round_info then
        m_data.round_info = data.round_info
    end

    InitMatchRoomData(data.status)
    Event.Brocast("model_nor_mg_wait_result_msg")
end

--晋级
function MjXzModel.on_nor_mg_promoted_msg(proto_name, data)
    dump(data, "<color=yellow>on_nor_mg_promoted_msg</color>")
    m_data.countdown = data.countdown
    m_data.promoted_type = data.promoted_type
    m_data.model_status = data.status
    m_data.status = MjXzModel.Status.wait_join
    
    if data.round_info then
        m_data.round_info = data.round_info
    end

    Event.Brocast("model_nor_mg_promoted_msg")
    m_data.promoted_type = nil
    InitMatchRoomData(data.status)
end

--********************response
--比赛报名结果
function MjXzModel.on_nor_mg_signup_response(_, data)
    dump(data, "<color=yellow>on_nor_mg_signup_response</color>")
    if data.result == 0 then
        m_data.model_status = MjXzModel.Model_Status.wait_begin
        --0-不可以取消  1-可以取消
        m_data.is_cancel_signup = data.is_cancel_signup
        m_data.cancel_signup_cd = data.cancel_signup_cd
        m_data.signup_num = data.signup_num
        m_data.total_players = data.total_players
        MainLogic.EnterGame()
    end
    Event.Brocast("model_nor_mg_signup_response", data.result)
end

function MjXzModel.on_nor_mg_cancel_signup_response(_, data)
    if data.result == 0 then
        m_data.model_status = nil
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        Event.Brocast("model_nor_mg_cancel_signup_response", data.result)
    else
        Event.Brocast("model_nor_mg_cancel_signup_fail_response", data.result)
    end
end

function MjXzModel.on_nor_mg_req_cur_signup_num_response(_, data)
    if data.result == 0 then
        m_data.signup_num = data.signup_num
    end
    Event.Brocast("model_nor_mg_req_cur_signup_num_response", data.result)
end

--再玩一把
function MjXzModel.on_nor_mg_replay_game_response(proto_name, data)
    dump(data, "<color=red>再玩一把</color>")
    if data.result == 0 then
        InitMatchData(m_data.game_id)
        MjXzModel.on_nor_mg_signup_response(proto_name, data)
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
                    GameManager.GotoUI({gotoui = "game_MatchHall"})
                end
            )
        end
    end
end

--退出游戏
function MjXzModel.on_nor_mg_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>on_nor_mg_quit_game_response</color>")
    if data.result == 0 then
        MainLogic.ExitGame()
        GameManager.GotoUI({gotoui = "game_MatchHall"})
    else
        HintPanel.ErrorMsg(data.result)
    end
end

---- 自动取消报名
function MjXzModel.on_nor_mg_auto_cancel_signup_msg(proto_name, data)
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_nor_mg_auto_cancel_signup_msg")
end

function MjXzModel.on_nor_mg_get_match_status_response(_, data)
    dump(data, "<color=yellow>on_nor_mg_get_match_status_response</color>")
    if data.result == 0 then
        m_data.start_time = data.start_time
    end
    Event.Brocast("model_nor_mg_get_match_status_response", data.result)
end

function MjXzModel.on_nor_mg_req_cur_player_num(_, data)
    dump(data, "<color=yellow>on_nor_mg_req_cur_player_num</color>")
    dump(data, "<color=yellow>on_nor_mg_req_cur_player_num</color>")
    if data.result == 0 then
        m_data.match_player_num = data.match_player_num
        Event.Brocast("model_nor_mg_req_cur_player_num_response")
    end
end

-------------------------------------------------------------------- new  玩法
-- 准备
function MjXzModel.on_nor_mj_xzdd_ready_msg(proto_name, data)
    dump(data, "<color=red>准备</color>")
    if not MjXzModel.data.ready then
        MjXzModel.data.ready = {0,0,0,0}
    end

    MjXzModel.data.ready[data.seat_num] = 1
    
    m_data.race = data.cur_race

    Event.Brocast("model_nor_mj_xzdd_ready_msg", data.seat_num )
end

-- 开始游戏
function MjXzModel.on_nor_mj_xzdd_begin_msg(proto_name, data)
    dump(data, "<color=red>开始游戏</color>")
    m_data.model_status = MjXzModel.Model_Status.gaming
    m_data.status = MjXzModel.Status.begin
    m_data.race = data.cur_race
    m_data.ready = {0,0,0,0}
    Event.Brocast("model_nor_mj_xzdd_begin_msg")
end

function MjXzModel.on_nor_mj_xzdd_action_msg(proto_name, data)
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

            MjXzModel.GetTingPai()
        else
            --记牌器  我自己的已经减去过了
            normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi)
            MjXzModel.RefreshTingPaiRemain()
        end

    elseif caozuo == "peng" then
        --加入pgmap
        if data.action.p==m_data.seat_num then
            m_data.my_pg_map[data.action.pai]="peng"
            m_data.my_pai_map[data.action.pai]= m_data.my_pai_map[data.action.pai]-2
            print("xxxxxxxxxxxx222")
            dump(m_data.my_pai_map)
            MjXzModel.getChupaiTingData()
            MjXzModel.clearTingPaiData()
        else
            --记牌器  我自己的已经减去过了
            normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,2)
            MjXzModel.RefreshTingPaiRemain()
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

            MjXzModel.GetTingPai()
        else
            --记牌器  我自己的已经减去过了
            if data.action.other=="zg" then
                normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,3)
            elseif data.action.other=="ag" then
                normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,4)
            elseif data.action.other=="wg" then
                normal_majiang.jipaiqi_kick_pai(data.action.pai,m_data.jipaiqi,1)
            end
            MjXzModel.RefreshTingPaiRemain()
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
            MjXzModel.RefreshTingPaiRemain()
        end

    end
    Event.Brocast("model_nor_mj_xzdd_action_msg", data.action)
end

-- 确认庄家
function MjXzModel.on_nor_mj_xzdd_tou_sezi_msg(proto_name, data)
    dump(data, "确认庄家")
    m_data.status = MjXzModel.Status.ding_que
    ---- 二人麻将的庄家也是非1即3
    m_data.zjSeatno = data.zj_seat  --  data.zj_seat == 1 and 1 or 3
    m_data.sezi_value1 = data.sezi_value1
    m_data.sezi_value2 = data.sezi_value2
    Event.Brocast("model_nor_mj_xzdd_tou_sezi_msg")
end

-- 进入游戏的人数达到 n 人，自动发牌,游戏开始，人数满足要求，发牌开局
function MjXzModel.on_nor_mj_xzdd_pai_msg(proto_name, data)
    dump(data, "<color=red>开始发牌</color>")

    m_data.status = MjXzModel.Status.fp
    m_data.remain_card = data.remain_card --totalCardNum - 14 - (MjXzModel.maxPlayerNumber-1)*13  ---   55 -- 14+13+13+13

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
                for j=1,MjXzModel.baseShouPaiNum + 1 do
                    v.spList[#v.spList + 1] = 0
                end
            else
                for j=1,MjXzModel.baseShouPaiNum do
                    v.spList[#v.spList + 1] = 0
                end
            end
        end
    end

    Event.Brocast("model_nor_mj_xzdd_pai_msg")
end

-- 权限信息
function MjXzModel.on_nor_mj_xzdd_permit_msg(proto_name, data)
    dump(data, "<color=red>权限信息</color>")
    m_data.status = data.status
    --让客户端比服务器稍慢一点防止出现出牌失败
    m_data.countdown = (data.countdown - 1)
    if m_data.countdown < 0 then
        m_data.countdown = 0
    end
    m_data.cur_p = data.cur_p --MjXzModel.translateSeatNo(data.cur_p) 
    m_data.other = data.other

    m_data.is_guo=nil

    -- 摸牌，剩余牌数减1
    if m_data.status == MjXzModel.Status.mo_pai then
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
            MjXzModel.getMyPghgData()
            MjXzModel.getChupaiTingData()
            MjXzModel.clearTingPaiData()
        end
    elseif m_data.status == MjXzModel.Status.peng_gang_hu then
        --当前碰杠胡牌
        m_data.cur_pgh_card = data.pai
        MjXzModel.getMyPghgData(data.allow_opt)
    elseif m_data.status == MjXzModel.Status.ding_que then
        for i,v in ipairs(m_data.playerInfo) do
            v.lackColor=-1
        end
    elseif m_data.status == MjXzModel.Status.chu_pai then
        if m_data.seat_num==data.cur_p then
            -- MjXzModel.getMyPghgData()
            m_data.pgh_data=nil
            MjXzModel.getChupaiTingData()
        end
    elseif m_data.status == MjXzModel.Status.start then
        if m_data.seat_num==data.cur_p then
            MjXzModel.getMyPghgData()
            MjXzModel.getChupaiTingData()
        end
    elseif m_data.status == MjXzModel.Status.da_piao then
        -- 先把数据还原一下
        for i,v in ipairs(m_data.playerInfo) do
            v.piaoNum = -1
        end
    elseif m_data.status == MjXzModel.Status.huan_san_zhang then
        m_data.isHuanPai = false 
        -- 本地计算默认选中的三张牌
        local paiVec = MjXzModel.getDefaultHuanSanZhangPai()
        m_data.huanSanZhangVec = paiVec

        -- 把数据保存到本地
        normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(paiVec,"|") )

        Event.Brocast("model_huanSanZhang_num_change_msg")

    end
    Event.Brocast("model_nor_mj_xzdd_permit_msg")
end

--- 
function MjXzModel.addHuanSanZhangPai(pai)
    m_data.huanSanZhangVec[#m_data.huanSanZhangVec + 1] = pai
    
    print("<color=yellow>------- MjXzModel.addHuanSanZhangPai: </color>",pai)

    Event.Brocast("model_huanSanZhang_num_change_msg")
end

function MjXzModel.delHuanSanZhangPai(pai)
    for k,value in ipairs(m_data.huanSanZhangVec) do
        if value == pai then
            table.remove(m_data.huanSanZhangVec , k)
            print("<color=yellow>------- MjXzModel.delHuanSanZhangPai: </color>",pai)
            
            break
        end
    end
    Event.Brocast("model_huanSanZhang_num_change_msg")
end

function MjXzModel.saveHuanSanZhangData()
    normal_majiang.saveSelectHuanSanZhangePai( normal_majiang.getVecString(m_data.huanSanZhangVec,"|") )
end

function MjXzModel.clearHuanSanZhangData()
    normal_majiang.saveSelectHuanSanZhangePai("")
end

-- 分数改变
function MjXzModel.on_nor_mj_xzdd_grades_change_msg(proto_name, data)
    dump(data, "<color=red>分数改变</color>")
    m_data.moneyChange = data.data
    Event.Brocast("model_nor_mj_xzdd_grades_change_msg")
end

function MjXzModel.on_nor_mj_xzdd_dingque_result_msg(proto_name, data)
    dump(m_data.player_info, "<color=green>麻将</color>")
    local result=data.result
    for i=1,4 do 
        m_data.playerInfo[i].lackColor = result[i]
    end
    Event.Brocast("model_nor_mj_xzdd_dingque_result_msg")
end

function MjXzModel.on_nor_mj_xzdd_auto_msg(proto_name, data)
    m_data.playerInfo=m_data.playerInfo or {}
    m_data.playerInfo[data.p] = m_data.playerInfo[data.p] or {}
    m_data.playerInfo[data.p].auto = data.auto_status
    Event.Brocast("model_nor_mj_xzdd_auto_msg",data.p)
end

-- 结算
function MjXzModel.on_nor_mj_xzdd_settlement_msg(proto_name, data)
    dump(data, "<color=red>结算</color>",10)
    m_data.status= MjXzModel.Status.settlement
    m_data.settlement_info = data.settlement_info.settlement_items
    m_data.is_over = data.is_over
    Event.Brocast("model_nor_mj_xzdd_settlement_msg")
end

--- 下一局,--打完一局重新发牌
function MjXzModel.on_nor_mj_xzdd_next_game_msg(proto_name, data)
    dump(data, "<color=red>on_nor_ddz_nor_new_game_msg</color>")
    --考虑是否需要清除数据
    InitMatchStatusData(data.status)
    m_data.race = data.cur_race
    Event.Brocast("model_nor_mj_xzdd_next_game_msg")
end

--- 某人打漂
function MjXzModel.on_nor_mj_xzdd_da_piao_msg(proto_name, data)
    dump(data,"<color=yellow>------------- MjXzModel.on_nor_mj_xzdd_da_piao_msg </color>")
    m_data.playerInfo[data.seat_num] = m_data.playerInfo[data.seat_num] or {}
    m_data.playerInfo[data.seat_num].piaoNum = data.piao_num

    Event.Brocast("model_nor_mj_xzdd_da_piao_msg" , data.seat_num)
end

function MjXzModel.on_nor_mj_xzdd_da_piao_finish_msg(proto_name, data)
    m_data.status= MjXzModel.Status.da_piao_finish

    Event.Brocast("model_nor_mj_xzdd_da_piao_finish_msg" )
end


function MjXzModel.on_nor_mj_xzdd_huansanzhang_msg(proto_name, data)
    dump(data , "<color=yellow>-------------- on_nor_mj_xzdd_huansanzhang_msg  data.pai_vec </color>")
    m_data.huanSanZhangNewVec = data.pai_vec
    m_data.isHuanPai = true
    m_data.isCanOpPai = true
    
    m_data.jipaiqi = normal_majiang.jipaiqi_server_to_client(data.jipaiqi) 

    --- 新的手牌
    m_data.playerInfo[m_data.seat_num].spList = data.pai_list
    m_data.my_pai_map=normal_majiang.get_pai_map_by_list(data.pai_list)

    Event.Brocast("model_nor_mj_xzdd_huansanzhang_msg",data.is_time_out == 1)
end

function MjXzModel.on_nor_mj_xzdd_huan_pai_finish_msg(proto_name, data)
    m_data.status = MjXzModel.Status.huan_san_zhang_finish

    Event.Brocast("model_nor_mj_xzdd_huan_pai_finish_msg",data)
end

function MjXzModel.GetCurRoundId()
    local curRound = 1
    if m_data and m_data.round_info and m_data.round_info.round_type == 1 then
        if m_data.round_info.final_round then
            curRound = m_data.round_info.round - m_data.round_info.final_round + (m_data.round_info.final_round > 1 and 1 or 0)
        else
            curRound = m_data.round_info.round - 1
        end
    end
    return curRound
end

function MjXzModel.nor_mg_wait_revive_msg(pName, data)
    m_data.model_status = MjXzModel.Model_Status.wait_revive
    m_data.revive_num = data.num
    m_data.revive_time = data.time
    m_data.revive_assets = data.assets
    m_data.revive_round = data.round
    Event.Brocast("model_nor_mg_wait_revive_msg", data)
end

function MjXzModel.nor_mg_free_revive_msg(pName, data)
    m_data.revive_num = nil
    m_data.revive_time = nil
    m_data.revive_assets = nil
    m_data.revive_round = nil
    Event.Brocast("model_nor_mg_free_revive_msg", data)
end

function MjXzModel.nor_mg_revive_response(pName, data)
    m_data.revive_num = nil
    m_data.revive_time = nil
    m_data.revive_assets = nil
    m_data.revive_round = nil
    Event.Brocast("model_nor_mg_revive_response", data)
end

function MjXzModel.on_nor_mg_match_discard_msg(pName, data)
    dump(data, "<color=yellow>on_nor_mg_match_discard_msg</color>")
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_nor_mg_match_discard_msg",data)
end
