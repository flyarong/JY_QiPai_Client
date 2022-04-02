-- 创建时间:2019-11-18

LHDModel = {}
local M = LHDModel

M.maxPlayerNumber = 4

M.Model_Status = {
    --等待分配桌子，疯狂匹配中
    wait_table = "wait_table",
    --报名成功，在桌子上等待开始游戏
    wait_begin = "wait_begin",
    --游戏状态处于游戏中
    gaming = "gaming",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

M.Status = 
{
    begin = "begin", -- 开始
    fp = "fp",-- 发牌
    dz = "dz", -- 定庄
    mopai = "mopai", -- 摸牌
    buqi = "buqi", -- 补齐
    equip = "equip", -- 出战
    settlement = "settlement", -- 结算
    gameover="gameover",
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
    lister["fg_lhd_all_info"] = this.on_fg_all_info
    lister["fg_lhd_join_msg"] = this.on_fg_join_msg
    lister["fg_lhd_leave_msg"] = this.on_fg_leave_msg
    lister["fg_lhd_gameover_msg"] = this.on_fg_gameover_msg
    lister["fg_lhd_score_change_msg"] = this.on_fg_score_change_msg
    lister["fg_auto_cancel_signup_msg"] = this.on_fg_auto_cancel_signup_msg
    lister["fg_lhd_auto_quit_game_msg"] = this.on_fg_auto_quit_game_msg
    lister["fg_lhd_ready_msg"] = this.on_fg_ready_msg
    lister["fg_lhd_activity_data_msg"] = this.on_fg_activity_data_msg

    --response
    lister["fg_lhd_signup_response"] = this.on_fg_lhd_signup_response
    lister["fg_lhd_ready_response"] = this.on_fg_ready_response
    lister["fg_lhd_huanzhuo_response"] = this.on_fg_lhd_huanzhuo_response
    lister["fg_lhd_quit_game_response"] = this.on_fg_quit_game_response
    lister["nor_lhd_nor_mopai_response"] = this.on_nor_lhd_nor_mopai_response
    lister["nor_lhd_nor_equip_response"] = this.on_nor_lhd_nor_equip_response
    lister["nor_lhd_nor_surrender_response"] = this.on_nor_lhd_nor_surrender_response
    lister["nor_lhd_nor_auto_response"] = this.on_nor_lhd_nor_auto_response
    lister["nor_lhd_nor_quit_game_response"] = this.on_nor_lhd_nor_quit_game_response
    lister["fg_lhd_switch_game_response"] = this.on_fg_lhd_switch_game_response
    --玩法
    lister["nor_lhd_nor_begin_msg"] = this.on_nor_lhd_nor_begin_msg
    lister["nor_lhd_nor_pai_msg"] = this.on_nor_lhd_nor_pai_msg
    lister["nor_lhd_nor_ding_zhuang_msg"] = this.on_nor_lhd_nor_ding_zhuang_msg
    lister["nor_lhd_nor_change_zhuang_msg"] = this.on_nor_lhd_nor_change_zhuang_msg
    lister["nor_lhd_nor_mopai_msg"] = this.on_nor_lhd_nor_mopai_msg
    lister["nor_lhd_nor_show_pai_msg"] = this.on_nor_lhd_nor_show_pai_msg
    lister["nor_lhd_nor_equip_msg"] = this.on_nor_lhd_nor_equip_msg
    lister["nor_lhd_nor_surrender_msg"] = this.on_nor_lhd_nor_surrender_msg
    lister["nor_lhd_nor_permit_msg"] = this.on_nor_lhd_nor_permit_msg
    lister["nor_lhd_nor_auto_msg"] = this.on_nor_lhd_nor_auto_msg
    lister["nor_lhd_nor_new_game_msg"] = this.on_nor_lhd_nor_new_game_msg
    lister["nor_lhd_nor_settlement_msg"] = this.on_nor_lhd_nor_settlement_msg

    lister["nor_lhd_nor_buqi_msg"] = this.on_nor_lhd_nor_buqi_msg
    lister["nor_lhd_nor_new_round_begin_msg"] = this.on_nor_lhd_nor_new_round_begin_msg
    lister["nor_lhd_nor_wait_pay_msg"] = this.on_nor_lhd_nor_wait_pay_msg
    
    --资产改变
    lister["AssetChange"] = this.OnAssetChange
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

    if data.status_no and proto_name ~= "fg_lhd_auto_quit_game_msg" then
        if proto_name ~= "fg_status_info" and proto_name ~= "fg_lhd_all_info" then
            if m_data.status_no + 1 ~= data.status_no and m_data.status_no ~= data.status_no then
                m_data.status_no = data.status_no

                print("<color=red>proto_name = " .. proto_name .. "</color>")
                dump(data)
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
function M.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        if proto_name == "AssetChange" then
            Event.AddListener(proto_name, _)
        else
            Event.AddListener(proto_name, MsgDispatch)
        end
    end
end

--删除斗地主正常逻辑的消息事件
function M.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        if proto_name == "AssetChange" then
            Event.RemoveListener(proto_name, _)
        else
            Event.RemoveListener(proto_name, MsgDispatch)
        end
    end
end

function M.Update()
    if m_data then
        if m_data.countdown and m_data.countdown > 0 then
            m_data.countdown = m_data.countdown - updateDt
            if m_data.countdown < 0 then
                m_data.countdown = 0
            end
        end
    end
end
local function InitMatchData(status)
    if not M.baseData then
        M.baseData = {}
    end
    if not m_data then
        M.data = {}
        m_data = M.data
        m_data.status_no = 0
    end
    m_data.status = status
    m_data.countdown = 0
    m_data.playerInfo = m_data.playerInfo or {}
    for i=1, M.maxPlayerNumber do
        m_data.playerInfo[i] = m_data.playerInfo[i] or {}
    end
    m_data.player_state = {0,0,0,0} -- 玩家状态 0-没玩 | 1-在玩 | 2-投降
    m_data.auto_status = nil -- 玩家的托管状态
    m_data.is_over = nil -- 是否结束(是否还有下一局) 0-no   1-yes
    m_data.stake_rate_data = nil -- 倍率数据
    m_data.super_rate = nil -- 特殊倍率值 不是索引(透视蛋或砸透明蛋都用这个值) 目前取stake_rate_data最后一个
    m_data.stake_rate = nil -- 当前摸牌倍率
    m_data.player_equip_rate = nil -- 所有玩家的出战底分
    m_data.player_rate = nil --所有玩家的下注底分
    m_data.player_pai = {} -- 所有人牌列表
    m_data.zhuang_seat_num = nil -- 庄家位置
    m_data.cur_p = nil -- 当前权限拥有人
    m_data.cur_race = nil -- 当前局数
    m_data.race_count = nil 
    m_data.settlement_info = nil -- 结算数据
    m_data.select_pai_data = nil -- 选牌数据

    -- 辅助数据 用于动画表现
    m_data.buf = {
        is_ts_oper = false, -- 是否处于透视操作状态下
        is_ts_anim = false, -- 是否执行透视操作动画
    }
end

function M.Init()
    InitMatchData()

    this = M
    this.InitUIConfig()
    MakeLister()
    this.AddMsgListener()

    return this
end

function M.Exit()
    if this then
        M.RemoveMsgListener()
        this = nil
        lister = nil
        m_data = nil
        M.data = nil
    end
end

function M.InitUIConfig()
    this.UIConfig = {
    }
end

--********************response

-- 判断是否能进入
function M.IsRoomEnter(id)
    local ui_config = LHDManager.GetGameIdByConfig(id)

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
function M.GetPlayerSeat()
    if m_data.seat_num then
        return m_data.seat_num
    else
        return 1
    end
end

-- 返回自己的UI位置
function M.GetPlayerUIPos()
    return M.GetSeatnoToPos(m_data.seat_num)
end

-- 根据座位号获取玩家UI位置
function M.GetSeatnoToPos(seatno)
    local seftSeatno = M.GetPlayerSeat()
    return (seatno - seftSeatno + M.maxPlayerNumber) % M.maxPlayerNumber + 1
end

-- 根据UI位置获取玩家座位号
function M.GetPosToSeatno(uiPos)
    local seftSeatno = M.GetPlayerSeat()
    return (uiPos - 1 + seftSeatno - 1) % M.maxPlayerNumber + 1
end

-- 根据UI位置获取玩家座位号
function M.GetPosToPlayer(uiPos)
    local seatno = M.GetPosToSeatno(uiPos)
    return m_data.playerInfo[seatno]
end
function M.GetSeatnoToPlayer(seatno)
    return m_data.playerInfo[seatno]
end

-- 是否是自己 玩家自己的UI位置在1号位
function M.IsPlayerSelf(uiPos)
    return uiPos == 1
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function M.GetAnimChatShowPos (id)
    if M.data and M.data.playerInfo then
        for k,v in ipairs(M.data.playerInfo) do
            if v.base and tostring(v.base.id) == tostring(id) then
                local uiPos = M.GetSeatnoToPos (v.base.seat_num)
                return uiPos, false, true
            end
        end             
    end
    dump(id, "<color=red>发送者ID</color>")
    dump(M.data.playerInfo, "<color=red>玩家列表</color>")
    return 1, false, true
end


function M.hz_call()
    Network.SendRequest("fg_lhd_huanzhuo", nil, "请求换桌")
end
function M.zb_call()
    Network.SendRequest("fg_lhd_ready", {ready=1}, "请求准备")
end
function M.hintCondition(call)
    local game_id = M.baseData.game_id
    local ui_config = LHDManager.GetGameIdByConfig(game_id)
    PayFastFreePanel.Create(ui_config, call)
end
function M.checkCondition(call)
    local game_id = M.baseData.game_id
    local ss = LHDManager.IsAgainRoomEnter(game_id)
    if ss == 1 then
        M.hintCondition(call)
        return false
    elseif ss == 2 then
        local data = LHDManager.GetRapidBeginGameID ()
        local pre = HintPanel.Create(2, "您太富有了，更高级的场次才适合您！", function ()
            Network.SendRequest("fg_lhd_switch_game", {game_id = data.cfg.game_id}, "正在报名")
        end, function ()
            Network.SendRequest("fg_lhd_quit_game", nil, "请求退出")
        end)
        pre:SetButtonText("取消", "前往高级场")
        return false
    end
    return true
end

-- 换桌检查
function M.HZCheck()
    if M.checkCondition(M.hz_call) then
        M.hz_call()
    end
end
-- 准备检查
function M.ZBCheck()
    if M.checkCondition(M.zb_call) then
        M.zb_call()
    end
end


-- 消息
-- 模式
function M.on_fg_all_info(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_all_info</color>")
    if data.status_no == -1 then
        --清除数据
        InitMatchData()
        MainLogic.ExitGame()
        LHDLogic.change_panel( LHDLogic.panelNameMap.hall )
    else
        InitMatchData()
        -- 模式数据
        local s = data
        m_data.xsyd = s.xsyd
        m_data.model_status = s.status
        if s.settlement_players_info then
            m_data.settlement_base = {}
            for k, v in pairs(s.settlement_players_info) do
                m_data.settlement_base[v.seat_num] = v
            end
        end
        m_data.countdown = s.countdown
        M.baseData.room_rent = s.room_rent
        if not M.baseData then
            M.baseData = {}
        end
        M.baseData.game_type = s.game_type
        M.baseData.jdz_type = s.jdz_type
        if s.room_info then
            M.baseData.game_id = s.room_info.game_id
        end
        m_data.room_info = s.room_info
        m_data.room_info.init_stake = m_data.room_info.init_stake
        if s.players_info then
            if not m_data.playerInfo then
                m_data.playerInfo = {}
            end
            for k, v in pairs(s.players_info) do
                m_data.playerInfo[v.seat_num] = m_data.playerInfo[v.seat_num] or {}
                v.ready = v.ready or 0
                m_data.playerInfo[v.seat_num].base = v
                if v.id == MainModel.UserInfo.user_id then
                    m_data.seat_num = v.seat_num
                end
            end
        end
        -- 游戏数据
        s = data.nor_lhd_nor_status_info
        if s then
            for k,v in pairs(s) do
                m_data[k] = v
            end
            if m_data.player_pai then
                local buf = m_data.player_pai
                m_data.player_pai = {}
                for k,v in ipairs(buf) do
                    m_data.player_pai[k] = v.pai
                end
            end
            m_data.select_pai_data = M.SetSelectPaiData(m_data.select_pai_data)
            m_data.super_rate = #m_data.stake_rate_data
            local buqi_seats = m_data.buqi_seats
            if buqi_seats then
                for k,v in ipairs(buqi_seats) do
                    m_data.buqi_seats[v] = 1
                end
            end
            if m_data.player_mopai_rate then
                local vv = {}
                for i = 1, #m_data.player_mopai_rate do
                    if m_data.player_mopai_rate[i] and m_data.player_mopai_rate[i] > 0 then
                        vv[i] = m_data.player_mopai_rate[i]
                    end
                end
                m_data.player_mopai_rate = {}
                for k,v in pairs(vv) do
                    m_data.player_mopai_rate[k] = v
                end
            end
            -- m_data.player_state = s.player_state -- 玩家状态 0-没玩 | 1-在玩 | 2-投降
            -- m_data.auto_status = s.auto_status -- 玩家的托管状态
            -- m_data.seat_num = s.seat_num -- 我的座位号
            -- m_data.is_over = s.is_over -- 是否结束(是否还有下一局) 0-no   1-yes
            -- m_data.stake_rate_data = s.stake_rate_data -- 倍率数据
            -- m_data.stake_rate = s.stake_rate -- 当前摸牌倍率
            -- m_data.player_equip_rate = s.player_equip_rate -- 所有玩家的出战底分
            -- m_data.player_rate = s.player_rate --所有玩家的下注底分
            -- m_data.player_pai = s.player_pai -- 所有人牌列表
            -- m_data.zhuang_seat_num = s.zhuang_seat_num -- 庄家位置
            -- m_data.cur_p = s.cur_p -- 当前权限拥有人
            -- m_data.cur_race = s.cur_race -- 当前局数
            -- m_data.race_count = s.race_count
            -- m_data.player_mopai_rate = s.player_mopai_rate -- 玩家当前轮摸牌的底分
            -- m_data.show_pai_count = s.show_pai_count -- 透视次数
            -- m_data.buqi_seats = s.buqi_seats -- 待补齐的玩家座位号列表
            -- m_data.settlement_info = s.settlement_info -- 结算数据
        end
        -- 活动数据
        m_data.activity_data = data.activity_data
    end

    if m_data then
        Event.Brocast("activity_fg_all_info",{activity_data = m_data.activity_data,game_type = M.baseData.game_type,game_id = M.baseData.game_id,model_status = m_data.model_status,status = m_data.status})
    end
    Event.Brocast("model_fg_all_info")

    Event.Brocast("lhd_guide_check")
end
function M.on_fg_join_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_join_msg</color>")
    M.CheckGameBeginState(m_data.playerInfo, data.player_info.ready, data.player_info.ready)
    local seatno = data.player_info.seat_num
    m_data.playerInfo[seatno] = m_data.playerInfo[seatno] or {}
    m_data.playerInfo[seatno].base = data.player_info

    -- all info数据没有发玩家自己，join需要找一下自己的座位号
    if data.player_info.id == MainModel.UserInfo.user_id then
        m_data.seat_num = seatno
    end
    m_data.player_state[seatno] = data.player_info.ready or 0

    Event.Brocast("model_fg_join_msg",  seatno)
    Event.Brocast("activity_fg_join_msg", seatno)
end
function M.on_fg_leave_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_leave_msg</color>")
    if m_data.playerInfo[data.seat_num] then
        M.CheckGameBeginState(m_data.playerInfo, 0, m_data.playerInfo[data.seat_num].base.ready)
        m_data.playerInfo[data.seat_num].base = nil

        Event.Brocast("model_fg_leave_msg", data.seat_num)
        Event.Brocast("activity_fg_leave_msg", data.seat_num)
    end
end
function M.on_fg_gameover_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_gameover_msg</color>")
    dump(m_data.model_status)
    if m_data.model_status == M.Model_Status.gaming or m_data.model_status == M.Status.settlement then
        m_data.model_status = M.Model_Status.gameover
        m_data.status = M.Status.gameover
    end
    for k,v in pairs(m_data.player_state) do
        m_data.player_state[k] = 0
    end

    m_data.glory_score_count = data.glory_score_count
    m_data.glory_score_change = data.glory_score_change
    m_data.exchange_hongbao = data.exchange_hongbao
    m_data.detail_rank_num  = data.detail_rank_num     
    
    if m_data.exchange_hongbao and m_data.exchange_hongbao.is_exchanged == 0 then
        ExtendSoundManager.PlaySound(audio_config.game.bgm_jinbizhuanhongbao.audio_name)
    end

    M.showChallenge = false

    Event.Brocast("model_fg_gameover_msg")
    Event.Brocast("activity_fg_gameover_msg")
end
function M.on_fg_score_change_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_score_change_msg</color>")
end
function M.on_fg_auto_cancel_signup_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_auto_cancel_signup_msg</color>")
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_cancel_signup_msg")
end
function M.on_fg_auto_quit_game_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_auto_quit_game_msg</color>")
    InitMatchData()
    MainLogic.ExitGame()
    Event.Brocast("model_fg_auto_quit_game_msg")
end
function M.on_fg_ready_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_ready_msg</color>")
    local seatno = data.seat_num
    if m_data.playerInfo[seatno] and m_data.playerInfo[seatno].base then
        M.CheckGameBeginState(m_data.playerInfo, data.ready)
        if (m_data.model_status == M.Model_Status.gameover or m_data.model_status == M.Model_Status.settlement) and m_data.seat_num == data.seat_num and data.ready == 1 then
            M.data.model_status = M.Model_Status.wait_begin
            if not M.IsLDC() then
                m_data.countdown = 15
            end
        end
        m_data.playerInfo[seatno].base.ready = data.ready
        m_data.player_state[seatno] = 0

        Event.Brocast("model_fg_ready_msg", seatno)
        Event.Brocast("activity_fg_ready_msg", seatno)
    end
end
function M.on_fg_activity_data_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_activity_data_msg</color>")
    if data.activity_data then
        m_data.activity_data = data.activity_data
        M.GetLSCount(data.activity_data)
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
                Event.Brocast("activity_fg_all_info",{activity_data = m_data.activity_data,game_type = M.baseData.game_type,game_id = M.baseData.game_id,model_status = m_data.model_status,status = m_data.status})
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

-- response
-- 摸牌 rate 用哪个锤子,index 砸哪个蛋
function M.on_nor_lhd_nor_mopai_response(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_mopai_response</color>")
    if data.result == 0 then
    else
        HintPanel.ErrorMsg(data.result)
    end
end
-- 出战 rate 用哪个锤子
function M.on_nor_lhd_nor_equip_response(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_equip_response</color>")
    if data.result == 0 then
    else
        HintPanel.ErrorMsg(data.result)
    end
end
-- 投降(放弃)
function M.on_nor_lhd_nor_surrender_response(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_surrender_response</color>")
    if data.result == 0 then
    else
        HintPanel.ErrorMsg(data.result)
    end
end
-- 托管 operate 1 开启 , 0 关闭
function M.on_nor_lhd_nor_auto_response(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_auto_response</color>")
    if data.result == 0 then
    else
        HintPanel.ErrorMsg(data.result)
    end
end
-- 退出
function M.on_nor_lhd_nor_quit_game_response(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_quit_game_response</color>")
    if data.result == 0 then
        InitMatchData()
        MainLogic.ExitGame()
        LHDLogic.change_panel( LHDLogic.panelNameMap.hall )
    else
        HintPanel.ErrorMsg(data.result)
    end

    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end
-- 准备
function M.on_fg_ready_response(_, data)
    Event.Brocast("fg_ready_response_code", data.result)
    dump(data, "<color=red> <<game_LHD>> on_fg_ready_response</color>")
    -- if data.result == 0 then
    --     InitMatchData()
    --     m_data.model_status = M.Model_Status.wait_begin
    --     m_data.status = nil
    --     if m_data.playerInfo[m_data.seat_num] then
    --         m_data.playerInfo[m_data.seat_num].ready = 1
    --     end
    --     Event.Brocast("model_fg_ready_response")
    -- else
    --     HintPanel.ErrorMsg(data.result)
    -- end
end
-- 换桌
function M.on_fg_lhd_huanzhuo_response(_, data)
    Event.Brocast("fg_lhd_huanzhuo_response_code", data.result)
    dump(data, "<color=red> <<game_LHD>> on_fg_lhd_huanzhuo_response</color>")
    if data.result == 0 then
        InitMatchData()
        m_data.model_status = M.Model_Status.wait_table
        m_data.status = nil
        m_data.playerInfo = {}
        Event.Brocast("model_fg_huanzhuo_response")
        Event.Brocast("model_begin_game_djs", false)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

-- 退出
function M.on_fg_quit_game_response(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_quit_game_response</color>")
    if data.result == 0 then
        --清除数据
        local game_id = M.baseData.game_id

        InitMatchData()
        MainLogic.ExitGame()

        local ui_config = LHDManager.GetGameIdByConfig(game_id)
        if ui_config then
            LHDLogic.change_panel(LHDLogic.panelNameMap.hall)
        else
            dump(game_id, "<color=red> config</color>")
        end
    else
        HintPanel.ErrorMsg(data.result)
    end

    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end
function M.on_fg_lhd_signup_response(_, data)
    dump(data, "<color=red> <<game_LHD>> on_fg_lhd_signup_response</color>")
    if data.result == 0 then
        InitMatchData()
        m_data.model_status = M.Model_Status.wait_table
        m_data.status = nil
        m_data.playerInfo = {}
        m_data.xsyd = data.xsyd

        m_data.countdown = data.cancel_signup_cd or 0
        M.baseData.game_type = data.game_type
        M.baseData.game_id = data.game_id
        M.baseData.name = data.name
        MainLogic.EnterGame()
        Event.Brocast("model_fg_signup_response", data.result)
        Event.Brocast("activity_fg_signup_msg")
    else
        HintPanel.ErrorMsg(data.result, function()
            GameManager.GotoUI({gotoui = "game_LHDHall"})
        end)
    end
end
function M.on_fg_lhd_switch_game_response(_, data)
    M.on_fg_lhd_signup_response(_, data)
end

-- 玩法
-- 开始游戏
function M.on_nor_lhd_nor_begin_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_begin_msg</color>")
    
    InitMatchData()
    
    m_data.model_status = M.Model_Status.gaming
    m_data.status = M.Status.begin
    Event.Brocast("model_begin_game_djs", false)
    
    m_data.cur_race = data.cur_race
    for k,v in pairs(m_data.player_pai) do
        m_data.player_pai[k] = nil
    end
    m_data.show_pai_count = data.show_pai_count
    m_data.player_state = data.player_state
    m_data.stake_rate_data = data.stake_rate_data
    m_data.super_rate = #m_data.stake_rate_data
    m_data.show_pai_rate = data.show_pai_rate
    -- 每轮的倍率选项
    m_data.stake_round_1_rate_ids = data.stake_round_1_rate_ids
    m_data.stake_round_2_rate_ids = data.stake_round_2_rate_ids
    m_data.stake_round_3_rate_ids = data.stake_round_3_rate_ids
    m_data.stake_round_4_rate_ids = data.stake_round_4_rate_ids
    m_data.stake_round_5_rate_ids = data.stake_round_5_rate_ids
    m_data.equip_round_rate_ids = data.equip_round_rate_ids

    -- 扣房费
    if m_data.player_state[m_data.seat_num] == 1 then
        m_data.playerInfo[m_data.seat_num].base.score = m_data.playerInfo[m_data.seat_num].base.score - M.baseData.room_rent.asset_count
        Event.Brocast("model_update_player_score_msg", {score=M.baseData.room_rent.asset_count, type="ff"})
    end
    m_data.stake_rate = m_data.stake_round_3_rate_ids[1]
    Event.Brocast("model_nor_lhd_nor_begin_msg")
end
-- 发牌消息
function M.on_nor_lhd_nor_pai_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_pai_msg</color>")
    m_data.status = M.Status.fp
    m_data.player_pai = {}
    for k,v in ipairs(data.pai_data) do
        m_data.player_pai[k] = v.pai
    end
    -- 底注 1倍底注
    m_data.player_rate = {}
    local all_dz = 0
    local dz = 0
    for i = 1, M.maxPlayerNumber do
        if m_data.player_state[i] == 1 then
            m_data.player_rate[i] = M.GetCurRate()
            dz = m_data.room_info.init_stake * M.GetCurRate()
            all_dz = all_dz + dz
            -- 扣底分
            m_data.playerInfo[i].base.score = m_data.playerInfo[i].base.score - dz
        else
            m_data.player_rate[i] = 0
        end
    end
    m_data.select_pai_data = M.SetSelectPaiData(data.select_pai_data)
    m_data.cur_race = data.cur_race

    Event.Brocast("model_update_player_score_msg", {score=dz, type="xd"})
    Event.Brocast("model_nor_lhd_nor_pai_msg", data)
end
-- 补齐
function M.on_nor_lhd_nor_buqi_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_buqi_msg</color>")
    -- m_data.buqi_seats[data.seat_num] = nil
    if data.buqi == 0 then
        if not m_data.player_state then
            m_data.player_state = {}
        end
        m_data.player_state[data.seat_num] = 2
        Event.Brocast("model_nor_lhd_nor_surrender_msg", data.seat_num)
        Event.Brocast("model_nor_lhd_nor_buqi_msg", data)
    else
        local cur_max_rate = 0
        for k,v in pairs(m_data.player_mopai_rate) do
            if cur_max_rate < v then
                cur_max_rate = v
            end
        end
        print(cur_max_rate)
        print(m_data.player_mopai_rate[data.seat_num])
        local r1 = m_data.stake_rate_data[ cur_max_rate ]
        local r2 = m_data.stake_rate_data[ m_data.player_mopai_rate[data.seat_num] ]
        local dz = m_data.room_info.init_stake * (r1 - r2)
        m_data.playerInfo[data.seat_num].base.score = m_data.playerInfo[data.seat_num].base.score - dz
        m_data.player_mopai_rate[data.seat_num] = cur_max_rate
        m_data.player_rate[data.seat_num] = m_data.player_rate[data.seat_num] + (r1 - r2)
        if data.seat_num == m_data.seat_num then
            m_data.cur_p = 0
        end
        Event.Brocast("model_update_player_score_msg", {seat_num = data.seat_num, score=dz, type="bq"})
        Event.Brocast("model_nor_lhd_nor_buqi_msg", data)
    end
end
-- 看牌
function M.on_nor_lhd_nor_show_pai_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_show_pai_msg</color>")
    m_data.select_pai_data = M.SetSelectPaiData(data.select_pai_data)
    local dz = m_data.room_info.init_stake * m_data.stake_rate_data[m_data.super_rate]
    m_data.player_rate[data.seat_num] = m_data.player_rate[data.seat_num] + m_data.stake_rate_data[m_data.super_rate]
    -- 扣看牌分
    m_data.playerInfo[data.seat_num].base.score = m_data.playerInfo[data.seat_num].base.score - dz
    m_data.show_pai_count = m_data.show_pai_count - 1

    Event.Brocast("model_update_player_score_msg", {seat_num=data.seat_num, score=dz, type="ts"})
    Event.Brocast("model_nor_lhd_nor_show_pai_msg", data)
end
function M.on_nor_lhd_nor_new_round_begin_msg(_, data)
    Event.Brocast("model_new_yilun_zadan_msg", data)
end
function M.on_nor_lhd_nor_wait_pay_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_wait_pay_msg</color>")
    m_data.countdown = data.wait_pay_time
    Event.Brocast("model_nor_lhd_nor_wait_pay_msg", data)
end
-- 摸牌
function M.on_nor_lhd_nor_mopai_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_mopai_msg</color>")
    if not m_data.player_pai or not m_data.player_pai[data.seat_num] then
        dump(m_data.player_pai, "<color=yellow> EEE <<game_LHD>> </color>")
    end
    m_data.countdown = 0
    m_data.cur_p = 0

    -- 上家座位号
    local cur_c = M.data["stake_round_" .. M.GetCurRound() .. "_rate_ids"]
    local sj = M.GetSJSeatno(data.seat_num)
    dump(m_data.player_mopai_rate)
    if ((not m_data.player_mopai_rate[sj] or m_data.player_mopai_rate[sj] == 0) and cur_c[1] ~= data.rate)
        or (m_data.player_mopai_rate[sj] and m_data.player_mopai_rate[sj] ~= data.rate ) then -- (首家加倍 非首家加倍)
        data.is_change_rate = true
        if (not m_data.player_mopai_rate[sj] and cur_c[1] ~= data.rate) then
            data.change_rate_val = m_data.stake_rate_data[ data.rate ] - m_data.stake_rate_data[ cur_c[1] ]
            data.change_rate_val = data.change_rate_val * m_data.room_info.init_stake
        else
            data.change_rate_val = m_data.stake_rate_data[ data.rate ] - m_data.stake_rate_data[ m_data.player_mopai_rate[sj] ]
            data.change_rate_val = data.change_rate_val * m_data.room_info.init_stake
        end
    end

    -- 操作位置
    m_data.player_pai[data.seat_num][#m_data.player_pai[data.seat_num] + 1] = data.pai
    local dz = 0
    local rate_val = 0
    local egg = M.GetEggByIndex(data.index)
    if egg.card_num == 0 then
        rate_val = m_data.stake_rate_data[data.rate]
        dz = m_data.room_info.init_stake * rate_val
    elseif egg.card_num > 0 then
        rate_val = m_data.stake_rate_data[data.rate] + m_data.stake_rate_data[m_data.super_rate]
        dz = m_data.room_info.init_stake * rate_val
    else
        print("<color=red>EEE 打开了一个本身就破碎的蛋</color>")
    end
    m_data.player_rate[data.seat_num] = m_data.player_rate[data.seat_num] + rate_val
    m_data.select_pai_data = M.SetSelectPaiData(data.select_pai_data)

    m_data.stake_rate = data.rate
    m_data.player_mopai_rate = m_data.player_mopai_rate or {}
    m_data.player_mopai_rate[data.seat_num] = data.rate
    -- 扣摸牌分
    m_data.playerInfo[data.seat_num].base.score = m_data.playerInfo[data.seat_num].base.score - dz

    Event.Brocast("model_update_player_score_msg", {seat_num=data.seat_num, score=dz, type="mp"})
    Event.Brocast("model_nor_lhd_nor_mopai_msg", data)
end
-- 庄家
function M.on_nor_lhd_nor_ding_zhuang_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_ding_zhuang_msg</color>")
    m_data.zhuang_seat_num = data.zhuang_seat_num
    Event.Brocast("model_nor_lhd_nor_ding_zhuang_msg", data)
end
-- 换庄家
function M.on_nor_lhd_nor_change_zhuang_msg(_, data)
    -- dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_change_zhuang_msg</color>")
    -- m_data.zhuang_seat_num = data.zhuang_seat_num
    -- Event.Brocast("model_nor_lhd_nor_change_zhuang_msg", data)
end
-- 出战
function M.on_nor_lhd_nor_equip_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_equip_msg</color>")
    if not m_data.player_equip_rate then
        m_data.player_equip_rate = {}
    end
    if M.GetCurCombatRateIndex() == data.rate then
        data.is_gen = true
    end
    local sl = 0
    if m_data.player_equip_rate[data.seat_num] and m_data.player_equip_rate[data.seat_num] > 0 then
        sl = m_data.stake_rate_data[ m_data.player_equip_rate[data.seat_num] ]
    end
    local dz = m_data.room_info.init_stake * (m_data.stake_rate_data[data.rate]-sl) -- 出战差值
    m_data.player_rate[data.seat_num] = m_data.player_rate[data.seat_num] + m_data.stake_rate_data[data.rate]-sl
    if sl > 0 then
        data.change_rate_val = dz
    end

    -- 扣出战分
    m_data.playerInfo[data.seat_num].base.score = m_data.playerInfo[data.seat_num].base.score - dz
    m_data.player_equip_rate[data.seat_num] = data.rate
    m_data.cur_p = 0
    Event.Brocast("model_update_player_score_msg", {seat_num=data.seat_num, score=dz, type="cz"})
    Event.Brocast("model_nor_lhd_nor_equip_msg", data)
end
-- 投降(放弃)
function M.on_nor_lhd_nor_surrender_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_surrender_msg</color>")
    if not m_data.player_state then
        m_data.player_state = {}
    end
    m_data.cur_p = 0
    m_data.player_state[data.seat_num] = 2
    Event.Brocast("model_nor_lhd_nor_surrender_msg", data.seat_num)
end
-- 权限
function M.on_nor_lhd_nor_permit_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_permit_msg</color>")
    m_data.countdown = data.countdown
    if m_data.countdown < 0 then
        m_data.countdown = 0
    end
    m_data.cur_p = data.cur_p
    m_data.status = data.status
    if m_data.status == M.Status.buqi then
        if data.data then
            m_data.buqi_seats = {}
            for k,v in ipairs(data.data) do
                m_data.buqi_seats[v] = 1
            end
        end
    end

    if m_data.player_pai then
        local ps
        local b = true
        for k,v in pairs(m_data.player_pai) do
            if m_data.player_state[k] == 1 then
                if not ps then
                    ps = #v
                else
                    if ps ~= #v then
                        b = false
                        break
                    end
                end
            end
        end
        -- 新的一轮权限
        if b then
            print("<color=red>EEE 新的一轮权限</color>")
            if m_data.status == M.Status.equip then
                m_data.stake_rate = M.data.equip_round_rate_ids[1]
            else
                if m_data.status == M.Status.mopai then
                    local cur_c = M.data["stake_round_" .. M.GetCurRound() .. "_rate_ids"]
                    m_data.stake_rate = cur_c[1]
                    m_data.player_mopai_rate = {}
                end
            end
        end
    end
    Event.Brocast("model_nor_lhd_nor_permit_msg", data)
end
-- 托管
function M.on_nor_lhd_nor_auto_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_auto_msg</color>")
    if not m_data.auto_status then
        m_data.auto_status = {}
    end
    m_data.auto_status[data.p] = data.auto_status

    Event.Brocast("model_nor_lhd_nor_auto_msg", data)
end
-- 下一局
function M.on_nor_lhd_nor_new_game_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_new_game_msg</color>")
    m_data.status = data.status
    m_data.cur_race = data.cur_race

    Event.Brocast("model_nor_lhd_nor_new_game_msg", data)
end
-- 结算
function M.on_nor_lhd_nor_settlement_msg(_, data)
    dump(data, "<color=red> <<game_LHD>> on_nor_lhd_nor_settlement_msg</color>")
    m_data.status = M.Status.settlement
    for k, v in pairs(m_data.playerInfo) do
        if v.base then
            v.base.ready = 0
        end
    end

    if data.settlement_info.winner == m_data.seat_num then
        local js = data.settlement_info.award - M.GetPlayerXZ(m_data.seat_num)
        dump(js, "<color=red>胜利 获得金币数</color>")
        m_data.playerInfo[m_data.seat_num].base.score = m_data.playerInfo[m_data.seat_num].base.score + data.settlement_info.award
        -- Event.Brocast("model_update_player_score_msg", {seat_num=m_data.seat_num, score=js, type="js"})
    end
    -- 是否结束(是否还有下一局) 0-no   1-yes
    m_data.is_over = data.is_over
    m_data.settlement_info = data.settlement_info
    Event.Brocast("model_nor_lhd_nor_settlement_msg", data)
end

--资产改变
function M.OnAssetChange(data)
    dump(data, "<color=red> <<game_LHD>> OnAssetChange</color>")
    -- data = {score = MainModel.UserInfo.jing_bi}
    -- m_data.score = data.score
    -- if m_data.playerInfo[m_data.seat_num] and m_data.playerInfo[m_data.seat_num].base then
    --     m_data.playerInfo[m_data.seat_num].base.score = data.score
    -- end
    -- Event.Brocast("model_AssetChange")
    if not data.change_type or table_is_null(data.data) then
        return
    end
    if string.len(data.change_type) >= 13 and string.sub(data.change_type,1,13) == "freestyle_lhd" then
    else
        for k,v in ipairs(data.data) do
            if v.asset_type == "jing_bi" then
                m_data.playerInfo[m_data.seat_num].base.score = m_data.playerInfo[m_data.seat_num].base.score + v.value
                Event.Brocast("model_update_player_score_msg", {score=v.value, type="chongzi"})
                return
            end
        end
    end
end


-- FUN
function M.GetLSCount(activity_data)
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
function M.SetSelectPaiData(select_pai_data)
    local pai_data = {}
    if not select_pai_data then
        return nil
    end
    for k,v in ipairs(select_pai_data.pai_data) do
        pai_data[k] = {card_num = v}
    end
    if select_pai_data.system_showed_id and select_pai_data.system_showed_id > 0 then
        pai_data[select_pai_data.system_showed_id].seat_num = 0--0标识系统赠送
    end
    for k,v in ipairs(select_pai_data.player_showed_id) do
        if v.pai_index and next(v.pai_index) then
            for _,pai_index in ipairs(v.pai_index) do
                pai_data[pai_index].seat_num = k
            end
        end
    end
    return pai_data
end
-- 系统透明蛋索引
function M.GetSysTMdan()
    if m_data.select_pai_data then
        for k,v in ipairs(m_data.select_pai_data) do
            if v.seat_num == 0 and v.card_num > 0 then
                return k
            end
        end
    end
end
-- 某个蛋数据
function M.GetEggByIndex(index)
    if M.data and M.data.select_pai_data then
        return M.data.select_pai_data[index]
    end
end
-- 随机选蛋
function M.RandEggIndex()
    local an_egg = {}
    local tm_egg = {}
    if M.data and M.data.select_pai_data then
        for i,v in ipairs(M.data.select_pai_data) do
            if v.card_num == 0 then
                an_egg[#an_egg + 1] = i
            end
            if v.card_num > 0 then
                tm_egg[#tm_egg + 1] = i
            end
        end
    end
    if #an_egg > 0 then
        return an_egg[math.random( 1, #an_egg )]
    end
    if #tm_egg > 0 then
        return tm_egg[math.random( 1, #tm_egg )]
    end
    return -1
end
-- 能否透明操作
function M.IsCanOperTM()
    if M.data and M.data.select_pai_data then
        if m_data.show_pai_count <= 0 then
            return false
        end
        for i,v in ipairs(M.data.select_pai_data) do
            if v.card_num == 0 then
                return true
            end
        end
    end    
end

-- 总下注(下注和出战)
function M.GetTotalXZ()
    local xz = 0
    for i = 1, M.maxPlayerNumber do
        xz = xz + M.GetPlayerXZ(i)
    end
    return xz
end
-- 一个玩家的下注额(下注和出战)
function M.GetPlayerXZ(seat_num)
    local xz = 0
    if m_data.player_rate and m_data.player_rate[seat_num] then
        xz = xz + m_data.room_info.init_stake * m_data.player_rate[seat_num]
    end
    return xz
end
-- 玩家手牌最多的数量
function M.GetCurPlayerMaxPaiNum()
    if m_data.player_pai then
        local ps
        local b = true
        for k,v in pairs(m_data.player_pai) do
            if m_data.player_state[k] == 1 then
                if not ps or (ps < #v) then
                    ps = #v
                end
            end
        end
        return ps
    end
    return 0
end
-- 是否是新的一轮
function M.IsNewRound()
    if m_data.player_pai then
        local ps
        local b = true
        for k,v in pairs(m_data.player_pai) do
            if m_data.player_state[k] == 1 then
                if not ps then
                    ps = #v
                else
                    if ps ~= #v then
                        b = false
                        break
                    end
                end
            end
        end
        return b
    end
end
-- 获取当前轮数
function M.GetCurRound()
    if m_data.player_pai then
        local ps
        for k,v in pairs(m_data.player_pai) do
            if m_data.player_state[k] == 1 then
                if not ps then
                    ps = #v
                else
                    if ps < #v then
                        ps = #v
                    end
                end
            end
        end
        if M.IsNewRound() and m_data.status == M.Status.mopai then
            print("<color=red>当前轮数 = " .. (ps + 1) .. "</color>")
            return ps + 1
        else
            print("<color=red>当前轮数 = " .. ps .. "</color>")
            return ps
        end
    else
        return 1
    end
end
-- 获取当前出战倍率
function M.GetCurCombatRate()
    return m_data.stake_rate_data[M.GetCurCombatRateIndex()]
end
-- 获取当前出战倍率索引
function M.GetCurCombatRateIndex()
    local cur_cz_rate = m_data.equip_round_rate_ids[1]
    if m_data.player_equip_rate then
        for k,v in pairs(m_data.player_equip_rate) do
            if v > 0 and cur_cz_rate < v then
                cur_cz_rate = v
            end
        end
    end
    return cur_cz_rate
end

-- 获取当前砸蛋倍率
function M.GetCurRate()
    return m_data.stake_rate_data[m_data.stake_rate]
end
-- 获取当前砸蛋倍率
function M.GetCurPlayerMDRate(seat_num)
    return m_data.stake_rate_data[m_data.player_mopai_rate[seat_num]]
end
-- 是否是首次出战
function M.IsFirstCZ(seat_num)
    if seat_num then
        if m_data.player_equip_rate and m_data.player_equip_rate[seat_num] <= 0 then
            return true
        end
    else
        if m_data.player_equip_rate then
            for k,v in pairs(m_data.player_equip_rate) do
                if v > 0 then
                    return false
                end
            end
            return true
        end
    end
end

function M.GetReadyPlayerNum(pinfo)
    local rd = 0
    if pinfo then
        for k,v in pairs(pinfo) do
            if v.base and v.base.ready == 1 then
                rd = rd + 1
            end
        end
    end
    print("<color=red>EEE zb_num=" .. rd .. "</color>")
    return rd
end
function M.CheckGameBeginState(pinfo, ready, old_ready)
    if M.data.model_status ~= M.Model_Status.gaming then
        ready = ready or 0
        old_ready = old_ready or 0
        local rd = M.GetReadyPlayerNum(pinfo)
        if rd == 1 and ready == 1 then
            Event.Brocast("model_begin_game_djs", true)
            return
        end
        if rd < 2 or (rd == 2 and ready == 0 and (not old_ready or old_ready == 1)) then
            Event.Brocast("model_begin_game_djs", false)
        end
    end
end

function M.IsPlayerReady(seat_num)
    local v = m_data.playerInfo[seat_num]
    if v and v.base and v.base.ready == 1 then
        return true
    end
end
-- 第一个加倍的玩家座位号
function M.GetOnePlayerJBSeatno()
    local one_no = 0
    local cur_rate = 0
    for i = 1, M.maxPlayerNumber do
        local no = i + m_data.zhuang_seat_num - 1
        if no > M.maxPlayerNumber then
            no = no - M.maxPlayerNumber
        end
        if m_data.player_mopai_rate[no] then
            if one_no == 0 then
                one_no = no
                cur_rate = m_data.stake_rate_data[ m_data.player_mopai_rate[no] ]
            else
                if cur_rate ~= m_data.stake_rate_data[ m_data.player_mopai_rate[no] ] then
                    one_no = no
                    cur_rate = m_data.stake_rate_data[ m_data.player_mopai_rate[no] ]
                end
            end
        end
    end
    dump(one_no, "<color=red>EEE one_no</color>")
    return one_no
end
-- 当前轮 摸牌的最大倍率
function M.GetCurRoundMPRate()
    local cur_max_rate = 0
    for k,v in pairs(m_data.player_mopai_rate) do
        if cur_max_rate < v then
            cur_max_rate = v
        end
    end
    return cur_max_rate
end
-- 是否需要补齐
function M.IsCanBQ(seat_num)
    if m_data.status == M.Status.buqi and m_data.player_state[seat_num] == 1 and m_data.cur_p == m_data.seat_num then
        local cur_max_rate = M.GetCurRoundMPRate()
        if m_data.buqi_seats and m_data.buqi_seats[seat_num] and cur_max_rate ~= m_data.player_mopai_rate[seat_num] then
            return true
        end
    end
end
-- 获取游戏中的上家座位号
function M.GetSJSeatno(seat_num)
    print("<color=red>seat_num = " .. seat_num .. "</color>")
    for i = 1, M.maxPlayerNumber do
        local no = seat_num - i
        if no < 1 then
            no = M.maxPlayerNumber + no
        end
        if m_data.player_state[no] == 1 then
            print("no = " .. no)
            return no
        end
    end
end
-- 获取游戏中的下家座位号
function M.GetXJSeatno(seat_num)
    print("<color=red>seat_num = " .. seat_num .. "</color>")
    for i = 1, M.maxPlayerNumber do
        local no = seat_num + i
        if no > M.maxPlayerNumber then
            no = no - M.maxPlayerNumber
        end
        if m_data.player_state[no] == 1 then
            print("no = " .. no)
            return no
        end
    end
end
-- 是否是乱斗场
function M.IsLDC()
    -- 优化修改
    if true then
        return true
    end
    -- 安全模式 使用乱斗场规则
    if LHDManager.is_use_aq_style then
        return true
    end
    if m_data.room_info.game_id == 4 then
        return true
    end
end