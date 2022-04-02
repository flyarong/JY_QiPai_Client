-- 创建时间:2019-03-06
local basefunc = require "Game/Common/basefunc"
require "Game.normal_fishing_common.Lua.FishingConfig"
require "Game.game_FishingMatch.Lua.FishingMatchConfig"

local fish_lib = require "Game.normal_fishing_common.Lua.fish_lib"

FishingMatchModel = {}
-- 别名
FishingModel = FishingMatchModel
FishingMatchModel.isDebug = false
FishingMatchModel.isPrintFrame = false

FishingMatchModel.maxPlayerNumber = 4
FishingMatchModel.game_type = {
    nor = "nor_fishing_nor",
}

FishingMatchModel.Model_Status = {
    --报名成功，在桌子上等待开始游戏
    wait_begin = "wait_begin",
    --等待分配桌子，疯狂匹配中
    wait_table = "wait_table",
    --游戏状态处于游戏中
    gaming = "gaming",
    --比赛状态处于结束，退回到大厅界面
    gameover = "gameover"
}

FishingMatchModel.Status = {
}

FishingMatchModel.Defines = {
    FrameTime = 0.033,
    WorldDimensionUnit={xMin=-9.6, xMax=9.6, yMin=-5.4, yMax=5.4},
    IceIndate = 7, -- 冰冻技能的持续时间
    IceCD = 0, -- CD:两次冰冻技能的间隔时间
    LockIndate = 7, -- 锁定技能的持续时间
    LockCD = 0, -- CD:两次锁定技能的间隔时间

    BulledSpeed = 20, -- 子弹运动速度
    bullet_num_limit = 10, -- 每个玩家同屏最多的子弹数
    nor_bullet_cooldown = 0.15, -- 子弹发射频率
    auto_bullet_speed = {1,1,1,1}, -- 自动开抢的子弹发射频率
}
-- Buff
FishingMatchModel.BuffType = 
{
    BT_mask = "mask", -- 屏蔽
    BT_bullet_index = "bullet_index", -- 修改枪
    BT_snap_shot = "quick_shoot", -- 快速射击
}

FishingMatchModel.TimeSkill = {
    [1] = {type="frozen", tool_type = "prop_fish_frozen"}, -- 冰冻
    [2] = {type="lock", tool_type = "prop_fish_lock"}, -- 锁定
    [3] = {type="accelerate", tool_type = "prop_fish_accelerate"}, -- 快射
    [4] = {type="wild", tool_type = "prop_fish_wild"}, -- 命中
    [5] = {type="doubled", tool_type = "prop_fish_doubled"}, -- 加倍
}
FishingMatchModel.TimeSkillMap = {
    frozen = FishingMatchModel.TimeSkill[1],
    lock = FishingMatchModel.TimeSkill[2],
    accelerate = FishingMatchModel.TimeSkill[3],
    wild = FishingMatchModel.TimeSkill[4],
    doubled = FishingMatchModel.TimeSkill[5],
}

-- 断线重连中
FishingMatchModel.IsRecoverRet = false
-- 资源加载中
FishingMatchModel.IsLoadRes = false

local this
local lister
local m_data
local update
local updateDt = 0.1
local update_frame_msg
local send_all_msg
-- 待同步的操作列表：发射子弹，碰撞
local cache_oper_list = {shoot={},boom={},skill={},fish_explode={}, activity = {}, ext_data={}}

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    lister["AssetChange"] = this.OnAssetChange

    lister["fish_out_pool"] = this.on_fish_out_pool
    lister["fish_move_finish"] = this.on_fish_move_finish


    lister["fsmg_all_info_test_response"] = this.on_fsmg_all_info_test_response

    lister["fsmg_begin_msg"] = this.on_fsmg_begin_msg
    lister["fsmg_enter_room_msg"] = this.on_fsmg_enter_room_msg
    lister["fsmg_rank_msg"] = this.on_fsmg_rank_msg
    lister["fsmg_match_discard_msg"] = this.on_fsmg_match_discard_msg
    lister["fsmg_gameover_msg"] = this.on_fsmg_gameover_msg

    lister["fsmg_barbette_info_change_msg"] = this.on_barbette_info_change_msg
    lister["fsmg_money_supply_msg"] = this.on_fsmg_money_supply_msg
    lister["fsmg_game_time_info_msg"] = this.on_fsmg_game_time_info_msg
    lister["fsmg_get_one_event"] = this.on_fsmg_get_one_event
    lister["fsmg_match_revive_msg"] = this.on_fsmg_match_revive_msg
    lister["fsmg_barrage_broadcast"] = this.on_fsmg_barrage_broadcast
end

local function MsgDispatch(proto_name, data)
    local func = lister[proto_name]
    if not func then
        error("brocast " .. proto_name .. " has no event.")
        return
    end
    if proto_name ~= "fish_out_pool" then
        --临时限制   一般在断线重连时生效  由logic控制
        if m_data.limitDealMsg and not m_data.limitDealMsg[proto_name] then
            if proto_name ~= "fish_move_finish" then
                print("<color=red>XXXXXXXXXXXXXXXXXXXXXXXXXXXX proto_name = " .. proto_name .."</color>")
                dump(data, "<color=red>MsgDispatch </color>")
            end
            return
        end
    end
    func(proto_name, data)
end

--注册斗地主正常逻辑的消息事件
function FishingMatchModel.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        if proto_name == "AssetChange" then
            Event.AddListener(proto_name, _)
        else
            Event.AddListener(proto_name, MsgDispatch)
        end
    end
end

--删除斗地主正常逻辑的消息事件
function FishingMatchModel.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        if proto_name == "AssetChange" then
            Event.RemoveListener(proto_name, _)
        else
            Event.RemoveListener(proto_name, MsgDispatch)
        end
    end
end

function FishingMatchModel.OnAssetChange(data)
end
function FishingMatchModel.Update()
end

local function InitMatchData(gameID)
    if not FishingMatchModel.baseData then
        FishingMatchModel.baseData = {}
    end
    FishingMatchModel.data = {
        --游戏名
        name = nil,
        --fg_room_info****
        --房间数据信息
        room_id = nil, --当前房间ID
        table_num = nil, --当前房间中桌子位置
        --当前游戏状态（详细说明见文件顶部注释：斗地主状态表status）
        status = nil,
        --在以上信息相同时，判定具体的细节状态；+1递增
        status_no = 0,
        --我的座位号
        seat_num = nil,

        scene_frozen_cd = 0,
        scene_frozen_state = "nor",
        use_frozen_seat_num = nil,
    }
    m_data = FishingMatchModel.data
end

local function InitMatchStatusData(status)
    m_data.status = status
end
function FishingMatchModel.ClearMatchData(game_id)
    InitMatchData(game_id)
end

function FishingMatchModel.Init()
    InitMatchData()
    this = FishingMatchModel
    this.InitUIConfig()


    MakeLister()
    this.AddMsgListener()

    FishingActivityManager.Init()

    update = Timer.New(FishingMatchModel.Update, 1, -1, true)
    update:Start()

    FishingMatchModel.InitGameData()
    FishingMatchModel.InitLocalFrameID()

    update_frame_msg = Timer.New(FishingMatchModel.SendFrameMsgToServer, 0.1, -1, false, true)

    return this
end

local function GetInitPlayer()
    local D = {}
    D.base = nil
    D.wait_add_score = 0
    D.last_wait_add_score_time = 0
    D.lock_cd = 0
    D.lock_max_cd = 1
    D.lock_state = "nor" -- nor 可使用 inuse使用中 cooling CD中
    D.lock_fish_id = -1-- 锁定鱼的ID
    D.frozen_cd = 0
    D.frozen_max_cd = 1
    D.frozen_state = "nor" -- nor 可使用 inuse使用中 cooling CD中
    D.use_laser_state = "nor"
    D.laser_rate = 0
    D.use_missile_state = "nor"
    D.missile_list = {0, 0, 0, 0}
    D.missile_index = 0
    D.prop_fish_lock = 0
    D.prop_fish_frozen = 0
    D.is_auto = false
    D.auto_index = 1
    D.bullet_index = 1
    D.show_bullet_index = 1
    D.index = 1

    -- 比赛场新增
    D.is_unlock = true -- 是否解锁 true-解锁 false-未解锁
    D.is_ass = false -- 是否解锁 true-解锁 false-未解锁

    return D
end
function FishingMatchModel.InitGameData()
    m_data.players_info = {}
    for i=1, 4 do
        m_data.players_info[i] = GetInitPlayer()
    end
    m_data.scene_frozen_state = "nor"
end

function FishingMatchModel.Exit()
    if this then
        FishingActivityManager.Exit()
        FishingMatchModel.RemoveMsgListener()
        update:Stop()
        update = nil
        if update_frame_msg then
            update_frame_msg:Stop()
        end
        update_frame_msg = nil
        if send_all_msg then
            send_all_msg:Stop()
        end
        send_all_msg = nil

        this = nil
        lister = nil
        m_data = nil
        FishingMatchModel.data = nil
        FishingMatchModel.SaveMoneyLog()
        FishingMatchModel.SaveFrameLog()
    end
end

function FishingMatchModel.InitUIConfig()
    this.Config = FishingConfig.InitUIConfig()
    local cc = FishingMatchConfig.InitUIConfig()
    for k,v in pairs(cc) do
        this.Config[k] = v
    end
end

-- 跳转的捕鱼场ID
-- 这里不需要场景切换
function FishingMatchModel.GotoFishingByID(id)
    FishingMatchLogic.is_quit = true
    FishingMatchModel.IsRecoverRet = true
    DOTweenManager.KillAllStopTween()
    InitMatchData()
    if update_frame_msg then
        update_frame_msg:Stop()
    end
    FishingMatchLogic.GetPanel():ResetUI()
    FishingActivityManager.fish_activity_exit_all()

    Network.SendRequest("fsg_force_change_fishery", {target_fishery = id}, "发送请求", function (data)
        if data.result == 0 then
            FishingMatchModel.SendAllInfo()
        else
            FishingMatchModel.IsRecoverRet = false
            HintPanel.ErrorMsg(data.result)
        end
    end)
end
-- 掉帧重连
function FishingMatchModel.Reconnection()
    FishingMatchModel.InitLocalFrameID()
    FishingMatchLogic.is_quit = true
    FishingMatchModel.IsRecoverRet = true
    DOTweenManager.KillAllStopTween()
    InitMatchData()
    if update_frame_msg then
        update_frame_msg:Stop()
    end
    FishingMatchLogic.GetPanel():ResetUI()
    FishingActivityManager.fish_activity_exit_all()

    FishingMatchModel.SendAllInfo()
end

function FishingMatchModel.StopUpdateFrame()
    if update_frame_msg then
        update_frame_msg:Stop()
    end
    update_frame_msg = nil

end

-- 返回自己的座位号
function FishingMatchModel.GetPlayerSeat()
    if m_data.seat_num then
        return m_data.seat_num
    else
        return 1
    end
end

-- 返回自己的数据
function FishingMatchModel.GetPlayerData()
    return m_data.players_info[m_data.seat_num]
end

-- 返回自己的UI位置
function FishingMatchModel.GetPlayerUIPos()
    return FishingMatchModel.GetSeatnoToPos(m_data.seat_num)
end

-- 根据座位号获取玩家UI位置
function FishingMatchModel.GetSeatnoToPos(seatno)
    if FishingMatchModel.IsRotationPlayer() then
        return FishingMatchModel.maxPlayerNumber - seatno + 1
    end
    return seatno
end

-- 根据UI位置获取玩家座位号
function FishingMatchModel.GetPosToSeatno(uiPos)
    if FishingMatchModel.IsRotationPlayer() then
        return FishingMatchModel.maxPlayerNumber - uiPos + 1
    end
    return uiPos
end

-- 根据UI位置获取玩家数据
function FishingMatchModel.GetPosToPlayer(uiPos)
    local seatno = FishingMatchModel.GetPosToSeatno(uiPos)
    return m_data.players_info[seatno]
end
-- 根据座位号获取玩家数据
function FishingMatchModel.GetSeatnoToUser(seatno)
    return m_data.players_info[seatno]
end
-- 根据ID获取玩家数据
function FishingMatchModel.GetIDToUser(id)
    for k,v in ipairs(m_data.players_info) do
        if v.base and v.base.id == id then
            return v
        end
    end
end

-- 根据ID获取玩家座位
function FishingMatchModel.GetIDToSeatno(id)
    for k,v in ipairs(m_data.players_info) do
        if v.base and v.base.id == id then
            return k
        end
    end
end

-- 是否旋转玩家 为以后联机准备
function FishingMatchModel.IsRotationPlayer()
    if FishingMatchModel.GetPlayerSeat() >= 2 then
        return true
    end
    return false
end

-- 根据玩家ID返回动画显示的位置
-- 交互动画必须要这个方法
function FishingMatchModel.GetAnimChatShowPos(id)
    if m_data and m_data.players_info then
        for k, v in ipairs(m_data.players_info) do
            if v.id == id then
                local uiPos = FishingMatchModel.GetSeatnoToPos(v.seat_num)
                if FishingMatchModel.data.dizhu and FishingMatchModel.data.dizhu > 0 then
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

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-- 服务器消息 
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
function FishingMatchModel.on_fsmg_begin_msg(_, data)
    dump(data, "<color=purple>on_fsmg_begin_msg >>>>>>>>>>>>>>>>>>>> </color>")
    m_data.model_status = FishingMatchModel.Model_Status.wait_table
    Event.Brocast("model_status_msg", m_data.model_status)
end
function FishingMatchModel.on_fsmg_enter_room_msg(_, data)
    dump(data, "<color=purple>on_fsmg_enter_room_msg >>>>>>>>>>>>>>>>>>>> </color>")
    m_data.model_status = FishingMatchModel.Model_Status.gaming
    m_data.is_begin_game = true
    FishingMatchModel.SendAllInfo()
end
function FishingMatchModel.on_fsmg_rank_msg(_, data)
    dump(data, "<color=purple>on_fsmg_rank_msg >>>>>>>>>>>>>>>>>>>> </color>")
    m_data.rank = data.rank
    Event.Brocast("model_change_rank_msg")
end
function FishingMatchModel.on_fsmg_match_discard_msg(_, data)
    dump(data, "<color=purple>on_fsmg_match_discard_msg >>>>>>>>>>>>>>>>>>>> </color>")
    HintPanel.Create(1, "由于人数不足，比赛被放弃", function ()
        MainLogic.ExitGame()
        MainLogic.GotoScene("game_Hall")
    end)
end
function FishingMatchModel.on_fsmg_gameover_msg(_, data)
    dump(data, "<color=purple>on_fsmg_gameover_msg >>>>>>>>>>>>>>>>>>>> </color>")
    m_data.model_status = FishingMatchModel.Model_Status.gameover
    
    BulletManager.RemoveAll()
    FishingMatchModel.BrocastActivityExitAll()

    local parm = {}
    parm.game_name = "捕鱼千元赛"
    parm.game_id = data.final_result.game_id
    parm.fianlResult = data.final_result
    parm.grades = data.grades
    Event.Brocast("model_fsmg_gameover_msg", parm)
end
function FishingMatchModel.on_barbette_info_change_msg(_, data)
    dump(data, "<color=purple>on_barbette_info_change_msg >>>>>>>>>>>>>>>>>>>> </color>")
    if data.barbette_info then
        if data.type == "main_barbette_upgrade" then
            m_data.buf_barbette_info = data.barbette_info
            m_data.buf_gunup_give_money = data.money
            m_data.wait_add_score = m_data.wait_add_score + data.money
            local chg = {}
            for k, v in ipairs(data.barbette_info) do
                v.bullet_index = v.bullet_index[1]
                if v.bullet_index ~= m_data.players_info[k].gun_info.bullet_index then
                    chg[#chg + 1] = k
                end
            end
            Event.Brocast("model_gunup_msg", chg, data.barbette_info[1].bullet_index)
        else
            for k,v in ipairs(data.barbette_info) do
                v.lock_time = v.lock_time or 0
                v.bullet_index = v.bullet_index[1]
                for k1,v1 in pairs(v) do
                    m_data.players_info[k].gun_info[k1] = v1
                end
            end
            FishingMatchModel.update_barbette_info()
            -- 主炮还在升级动画中，又有一次枪炮信息变化
            if m_data.buf_barbette_info then
                print("<color=red>主炮还在升级动画中，又有一次枪炮信息变化</color>")
                for k, v in ipairs(m_data.buf_barbette_info) do
                    m_data.buf_barbette_info[k] = m_data.players_info[k].gun_info
                end
            end
            -- 忽略buff
            if not data.type or data.type ~= "add_buff" then
                Event.Brocast("model_barbette_info_change_msg", data.type)
            end
        end
    end
end
-- 更新显示的枪炮赔率
function FishingMatchModel.update_barbette_info()
    for i = 1, FishingMatchModel.maxPlayerNumber do
        local userdata = FishingMatchModel.GetPosToPlayer(i)
        if not userdata.gun_info.act_bullet_index then
            userdata.gun_info.show_bullet_index = userdata.gun_info.bullet_index
        end
    end
end
function FishingMatchModel.on_fsmg_money_supply_msg(_, data)
    dump(data, "<color=purple>on_fsmg_money_supply_msg >>>>>>>>>>>>>>>>>>>> </color>")
end
function FishingMatchModel.on_fsmg_game_time_info_msg(_, data)
    dump(data, "<color=purple>on_fsmg_game_time_info_msg >>>>>>>>>>>>>>>>>>>> </color>")
    if data.type == "luck" then
        m_data.luck_time = data.time
        m_data.luck_type = data.tag
        Event.Brocast("model_change_luck_time_msg", data.data)
    elseif data.type == "barbette" then
        m_data.main_barbette_time = data.time
        Event.Brocast("model_change_barbette_time_msg")
    end
end
-- 事件通知
function FishingMatchModel.on_fsmg_get_one_event(_, data)
    dump(data, "<color=purple>on_fsmg_get_one_event >>>>>>>>>>>>>>>>>>>> </color>")
    Event.Brocast("model_fsmg_get_one_event", data)
end
-- 复活
function FishingMatchModel.on_fsmg_match_revive_msg(_, data)
    dump(data, "<color=purple>nor_mg_wait_revive_msg</color>")
    m_data.revive_data = data.data
    if m_data.revive_data.count and m_data.revive_data.count > 0 then
        m_data.revive_data.time = m_data.revive_data.time + os.time()
        m_data.revive_data.quit_time = m_data.revive_data.quit_time + os.time()
    end
    Event.Brocast("model_fsmg_match_revive_msg")
end

local c_end = "</color>"
local color_st = "<color=#FEFBD1FF>"-- 灰
local color_st_rand=
{"<color=#ABFEF7FF>",-- 蓝
"<color=#F6F317FF>",-- 黄
"<color=#17D800FF>",-- 绿
}
local color_st_index = 1
-- 弹幕内容拼接
function FishingMatchModel.GetDMDesc(data)
    local barrage_config = FishingMatchModel.Config.fishmatch_barrage_config
    local desc
    local b = data.broadcast_content
    local len = #color_st_rand
    if barrage_config[data.broadcast_key] then
        -- for i=1, #b do
        --     b[i] = color_st_rand[math.random(1,len)] .. b[i] .. c_end
        -- end
        data.broadcast_level = barrage_config[data.broadcast_key].lvl
        local dd = barrage_config[data.broadcast_key].desc
        dd = color_st_rand[color_st_index] .. dd .. c_end
        color_st_index = color_st_index + 1
        if color_st_index > #color_st_rand then
            color_st_index = 1
        end
        desc = string.format(dd, b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8])
    else
        dump(data, "<color=red>弹幕内容拼接 没有模板</color>")
    end
    data.broadcast_content = desc
end
-- 弹幕
function FishingMatchModel.on_fsmg_barrage_broadcast(_, data)
    data.type = 3
    FishingMatchModel.GetDMDesc(data)
    if data.broadcast_content and data.broadcast_content ~= "" then
        Event.Brocast("multicast_msg", "multicast_msg", data)
    end
end

function FishingMatchModel.SetLockFishID(seat_num, fish_id)
    m_data.players_info[seat_num].lock_fish_id = fish_id
end
function FishingMatchModel.RemoveLockFishID(seat_num)
    m_data.players_info[seat_num].lock_fish_id = -1
end

local fish_out_pool = {}
-- 鱼游动完成
function FishingMatchModel.on_fish_move_finish(_, fish_id)
    fish_out_pool[fish_id] = fish_id
    for i=1, 4 do
        if m_data.players_info[i].lock_fish_id and m_data.players_info[i].lock_fish_id == fish_id then
            m_data.players_info[i].lock_fish_id = -1
        end
    end
end
function FishingMatchModel.on_fish_out_pool(_, fish_id)
    for i=1, 4 do
        if m_data.players_info[i].lock_fish_id and m_data.players_info[i].lock_fish_id == fish_id then
            m_data.players_info[i].lock_fish_id = -1
        end
    end
end

-- 获取游出去的鱼
-- 最多20条 防止数据过大
function FishingMatchModel.GetOutPoolFish()
    local list = {}
    for k,v in pairs(fish_out_pool) do
        list[#list + 1] = v
        fish_out_pool[k] = nil
        -- if #list > 20 then
        --     break
        -- end
    end
    return list
end

function FishingMatchModel.SetUpdateFrame(b)
    if update_frame_msg then
    if b then
        update_frame_msg:Start()
    else
        update_frame_msg:Stop()
        end
    end
end
function FishingMatchModel.SendAllInfo()
    print("<color=red>FishingMatchModel.SendAllInfo()</color>")
    FishingMatchLogic.is_quit = false
    FishingMatchModel.IsRecoverRet = true
    if update_frame_msg then
        update_frame_msg:Stop()
    end
    Network.SendRequest("fsmg_all_info_test", nil, "")
end
-- 断线重连数据 all_info
function FishingMatchModel.on_fsmg_all_info_test_response(_, data)
    cache_oper_list = {shoot={},boom={},skill={},fish_explode={}, activity = {}, ext_data={}}
    
    VehicleManager.RemoveAll()
    FishManager.RemoveAll()
    BulletManager.RemoveAll()
    FishingMatchModel.BrocastActivityExitAll()

    dump(data, "<color=purple>all_info</color>",1000000)
    if data.result ~= 0 then
        if data.result == -1 then
            MainLogic.GotoScene("game_Hall")
            return
        end
        HintPanel.ErrorMsg(data.result, function ()
            MainLogic.GotoScene("game_Hall")
        end)
        return
    end
    m_data.match_info = data.match_info
    m_data.model_status = data.status
    --FishingMatchModel.Model_Status.wait_begin

    m_data.countdown = data.countdown
    m_data.game_id = data.room_info.game_id
    m_data.t_num = data.room_info.t_num
    m_data.seat_num = data.room_info.seat_num
    m_data.rank = data.rank
    m_data.total_players = data.total_players
    m_data.score = data.score
    m_data.grades = data.grades

    m_data.game_time = data.game_time
    m_data.main_barbette_time = data.barbette_time
    m_data.luck_time = data.luck_time
    m_data.luck_type = data.luck_type

    m_data.revive_data = data.revive_info
    if m_data.revive_data and m_data.revive_data.count > 0 then
        m_data.revive_data.time = m_data.revive_data.time + os.time()
        m_data.revive_data.quit_time = m_data.revive_data.quit_time + os.time()
    end

    m_data.players_info = {}
    for i = 1, 4 do
        m_data.players_info[i] = GetInitPlayer()
        m_data.players_info[i].seat_num = i
        if i ~= 1 then
            m_data.players_info[i].is_ass = true
        end
    end

    if data.players_info then
        m_data.players_info[1].base = data.players_info
        m_data.players_info[1].prop_fish_lock = MainModel.UserInfo.prop_fish_lock or 0
        m_data.players_info[1].prop_fish_frozen = MainModel.UserInfo.prop_fish_frozen or 0

        m_data.wait_add_score = 0
        m_data.wait_add_grades = 0
        m_data.wait_dec_score = 0
    end
    if data.barbette_info then
        for k,v in ipairs(data.barbette_info) do
            v.lock_time = v.lock_time or 0
            v.bullet_index = v.bullet_index[1]
            v.show_bullet_index = v.bullet_index
            m_data.players_info[k].gun_info = v
        end
    end

    if data.nor_fishing_status_info then
        local s = data.nor_fishing_status_info
        m_data.begin_time = tonumber(s.begin_time)
        m_data.system_time = tonumber(s.fishery_data.time)
        m_data.first_system_time = s.fishery_data.first_time
        if s.barbette_id then
            m_data.barbette_id = {}
            local s = s.barbette_id
            for k = s[1], s[2] do
                m_data.barbette_id[#m_data.barbette_id + 1] = k
            end
        end

        for k,v in pairs(s.skill_cfg) do
            if v.skill == "lock" then
                FishingMatchModel.Defines.LockCD = v.cd_time
                FishingMatchModel.Defines.LockIndate = v.time
            elseif v.skill == "frozen" then   
                FishingMatchModel.Defines.IceCD = v.cd_time
                FishingMatchModel.Defines.IceIndate = v.time
            end
        end

        m_data.fish_map_id = s.fish_map_id
        -- if s.fishery_data.activity and next(s.fishery_data.activity) then
        --     for k,v in ipairs(s.fishery_data.activity) do
        --         if v.seat_num and v.bullet_index then
        --             m_data.players_info[v.seat_num].gun_info.bullet_index = v.bullet_index
        --         end
        --     end
        -- end
        m_data.scene_frozen_cd = 0
        m_data.scene_frozen_state = "nor"
        m_data.use_frozen_seat_num = nil
        if s.skill_status then
            for k,v in ipairs(s.skill_status) do
                if v.skill == "frozen" then
                    if v.time then
                        if v.time > FishingModel.Defines.IceCD then
                            m_data.players_info[v.seat_num].frozen_cd = v.time - FishingModel.Defines.IceCD
                            m_data.players_info[v.seat_num].frozen_max_cd = FishingModel.Defines.IceIndate
                            m_data.players_info[v.seat_num].frozen_state = "inuse"
                            m_data.scene_frozen_state = "inuse"
                            m_data.use_frozen_seat_num = v.seat_num
                            m_data.scene_frozen_cd = m_data.players_info[v.seat_num].frozen_cd
                        else
                            m_data.players_info[v.seat_num].frozen_cd = v.time
                            m_data.players_info[v.seat_num].frozen_max_cd = FishingModel.Defines.IceCD
                            m_data.players_info[v.seat_num].frozen_state = "cooling"
                            m_data.scene_frozen_cd = 0
                        end
                    else
                        dump(v, "<color=red>冰冻技能</color>")
                    end
                elseif v.skill == "lock" then
                    if v.time > FishingModel.Defines.LockCD then
                        m_data.players_info[v.seat_num].lock_cd = v.time - FishingModel.Defines.LockCD
                        m_data.players_info[v.seat_num].lock_max_cd = FishingModel.Defines.LockIndate
                        m_data.players_info[v.seat_num].lock_state = "inuse"
                    else
                        m_data.players_info[v.seat_num].lock_cd = v.time
                        m_data.players_info[v.seat_num].lock_max_cd = FishingModel.Defines.LockCD
                        m_data.players_info[v.seat_num].lock_state = "cooling"
                    end
                elseif v.skill == "summon" then
                elseif v.skill == "laser" then
                    m_data.players_info[v.seat_num].laser_rate = v.time or 0
                elseif v.skill == "missile" then
                    local num = v.time or 0
                    for i=1, 4 do
                        m_data.players_info[v.seat_num].missile_list[i] = num % 10
                        num = math.floor(num / 10)
                        if m_data.players_info[v.seat_num].missile_list[i] > 0 then
                            m_data.players_info[v.seat_num].missile_index = i
                        end
                    end
                end
            end
        end


        -- 冰冻
        m_data.frozen_time_data = s.frozen_time_data
    end
    
    -- 游戏gameover
    local parm = {}
    if m_data.model_status and m_data.model_status == FishingMatchModel.Model_Status.gameover then
        parm.game_name = "捕鱼千元赛"
        parm.game_id = data.gameover_info.game_id
        parm.fianlResult = data.gameover_info
        parm.grades = m_data.grades
    end
    Event.Brocast("model_fsmg_all_info_test", parm)
    if m_data.model_status and m_data.model_status == FishingMatchModel.Model_Status.gaming then
        FishingMatchModel.lock_frame = nil
        if data.nor_fishing_status_info then
            print("<color=red>fish_group num = " .. #data.nor_fishing_status_info.fishery_data.fish_group .. "</color>")
            dump(data.nor_fishing_status_info.fishery_data.skill, "<color=red>data.skilldata.skill </color>")
            FishingMatchModel.S2CFrameMessage(data.nor_fishing_status_info.fishery_data)
        end
        Event.Brocast("model_ready_finish_msg")
        update_frame_msg:Start()
    end
    FishingMatchModel.IsRecoverRet = false

    Event.Brocast("model_recover_finish")

    --取消限制消息
    m_data.limitDealMsg = nil

    Event.Brocast("model_status_msg", m_data.model_status)
end

function FishingMatchModel.InitLocalFrameID()
    FishingMatchModel.local_frame_id_left = 1
    FishingMatchModel.local_frame_id_right = 1
end
function FishingMatchModel.GetLocalFrameID()
    local frame_id = FishingMatchModel.local_frame_id_right
    FishingMatchModel.local_frame_id_right = FishingMatchModel.local_frame_id_right + 1
    if FishingMatchModel.local_frame_id_right > 1000000000 then
        FishingMatchModel.local_frame_id_right = 1
    end
    return frame_id
end
function FishingMatchModel.AddLocalFrameID()
    FishingMatchModel.local_frame_id_left = FishingMatchModel.local_frame_id_left + 1
    if FishingMatchModel.local_frame_id_left > 1000000000 then
        FishingMatchModel.local_frame_id_left = 1
    end
end

-- 发送帧数据到服务器
function FishingMatchModel.SendFrameMsgToServer()
    if not FishingMatchModel.IsRecoverRet then
        if FishingMatchModel.lock_frame then
            dump(FishingMatchModel.local_frame_id_left, "<color=red>EEEE 当前帧数据返回延迟</color>")
            return
        end
        if cache_oper_list then     
            -- local msg = fish_lib.frame_data_pack({data=cache_oper_list,time=0,activity={}})
            cache_oper_list.time = 0
            -- -- 快速射击子弹数
            -- if m_data.kssj_num then
            --     cache_oper_list.ext_data = cache_oper_list.ext_data or {}
            --     for k,v in pairs(m_data.kssj_num) do
            --         cache_oper_list.ext_data[#cache_oper_list.ext_data + 1] = {type = 4, value = v, seat_num=k}
            --     end
            -- end
            -- m_data.kssj_num = {}

            cache_oper_list.fish_out_pool = FishingMatchModel.GetOutPoolFish()
            cache_oper_list.frame_id = FishingMatchModel.GetLocalFrameID()
            local msg = cache_oper_list
            cache_oper_list = {shoot={},boom={},skill={},fish_explode={},activity = {}}
            FishingMatchModel.lock_frame = true
            FishingMatchModel.data.wait_dec_score = 0
            -- 发送消息到服务器
            Network.SendRequest("nor_fishing_nor_frame_data_test", {data=msg}, function (data)
                FishingMatchModel.lock_frame = false
                FishingMatchModel.AddFrameLog(data)
                if m_data and m_data.seat_num then
                    if data.result == 0 then
                        -- local unmsg = fish_lib.frame_data_unpack(data.data)
                        -- m_data.system_time = unmsg.time
                        -- FishingMatchModel.S2CFrameMessage(unmsg)
                        m_data.system_time = tonumber(data.data.time)
                        FishingMatchModel.S2CFrameMessage(data.data)
                    else
                    end
                end
            end)

        end
    end
end
function FishingMatchModel.C2SFrameMessage(data)
    local _data
    local list
    if data.Shoot then
        list = cache_oper_list.shoot or {}
        _data = {}
        _data.seat_num = data.Shoot.seat_num
        _data.index = data.Shoot.index
        _data.id = data.Shoot.id
        _data.x = data.Shoot.x
        _data.y = data.Shoot.y
        _data.rate = data.Shoot.rate
        _data.type = data.Shoot.type
        _data.time = 0
    end

    if data.Boom then
        list = cache_oper_list.boom or {}
        -- 随机打死鱼
        _data = {}
        _data.id = data.Boom.id
        _data.fish_ids  = data.Boom.fish_list
    end

    if data.Skill then
        list = cache_oper_list.skill or {}
        _data = {}
        _data = data.Skill
    end

    if data.BoomHarm then
        list = cache_oper_list.fish_explode or {}
        _data = {}
        _data.id = data.BoomHarm.id
        _data.fish_ids = data.BoomHarm.fish_ids
    end

    if data.Activity then
        list = cache_oper_list.activity or {}
        _data = {}
        _data.activity_id = data.Activity.activity_id
        _data.status = 1
    end
    if data.ExtData then
        list = cache_oper_list.ext_data or {}
        _data = {}
        _data.type = data.ExtData.type
        _data.value = data.ExtData.value
    end

    if _data and next(_data) then
        list[#list + 1] = _data
    end
end

-- 服务器同步帧
function FishingMatchModel.S2CFrameMessage(data)
    if not m_data or not m_data.seat_num then
        return
    end
    if data.frame_id then
        if FishingMatchModel.local_frame_id_left ~= data.frame_id then
            print("<color=red>同步帧 掉帧错误 EEEEEEEEEEEEE </color>")
            dump(FishingMatchModel.local_frame_id_left, "<color=red>FishingMatchModel.local_frame_id_left</color>")
            dump(FishingMatchModel.local_frame_id_right, "<color=red>FishingMatchModel.local_frame_id_right</color>")
            dump(data.frame_id, "<color=red>data.frame_id</color>")
            FishingMatchModel.Reconnection()
            return
        end
        FishingMatchModel.AddLocalFrameID()
    end
    if data.frame_id then
        -- print("<color=red>同步帧 data.frame_id " .. data.frame_id .. " </color>")
    end
    -- dump(data, "<color=green>S2CFrameMessage</color>")

    if data.assets then
        for k1, v1 in ipairs(data.assets) do
            if v1.asset_type == "score" then
                m_data.cache_score = v1.value
            elseif v1.value == "sub_score" then
                m_data.cache_grades = v1.value
            end
        end
    end

    if data.shoot and #data.shoot > 0 then
        -- dump(data.shoot, "<color=red>开抢</color>")
        for k,v in ipairs(data.shoot) do
            if v.id == -998 and v.seat_num == 1 then
                print("<color=red>玩家子弹发射失败</color>")
                dump(m_data.score, "<color=red>score</color>")
                dump(m_data.wait_add_score, "<color=red>wait_add_score</color>")

                if m_data.cache_score and m_data.cache_grades then
                    m_data.score = m_data.cache_score
                    m_data.grades = m_data.cache_grades
                    Event.Brocast("ui_refresh_player_money")
                end
            end
            v.x = v.x / 100
            v.y = v.y / 100
            BulletManager.UpdateBulledID(v)
        end
    end
    if data.boom and #data.boom > 0 then
        -- dump(data.boom, "<color=red>鱼碰撞导致死亡</color>")
        for k,v in ipairs(data.boom) do
            Event.Brocast("model_fish_dead", v)
        end
    end
    m_data.frame_new_fish_num = 0
    if data.fish_group and #data.fish_group > 0 then
        -- dump(data.fish_group, "<color=red>产生一组鱼</color>")
        for k,v in ipairs(data.fish_group) do
            m_data.frame_new_fish_num = m_data.frame_new_fish_num + #v.types
            FishManager.AddFishGroup(v)
        end
    end
    if data.fish_team and #data.fish_team > 0 then
        -- dump(data.fish_team, "<color=red>产生敢死队鱼</color>")
        for k,v in ipairs(data.fish_team) do
            FishManager.AddFishTeam(v)
        end
    end
    if data.fish_explode and #data.fish_explode > 0 then
        -- dump(data.fish_explode, "<color=red>特殊鱼死亡效果</color>")
        for k,v in ipairs(data.fish_explode) do
            Event.Brocast("model_fish_explode_dead", v)
        end
    end
    if data.event and #data.event > 0 then
        dump(data.event, "<color=red>渔场事件</color>")
        for k,v in ipairs(data.event) do
            if v.msg_type == "fish_boom" then
                m_data.fish_map_id = v.value
                m_data.fish_map_type = v.type
                m_data.clear_level = v.clear_level
                m_data.begin_time = tonumber(m_data.system_time)
                Event.Brocast("model_fish_wave")
                fish_out_pool = {}
            elseif v.msg_type == "box_fish" then
                Event.Brocast("model_box_fish")
            end
        end
    end
    if data.skill and #data.skill > 0 then
        if not FishingMatchModel.IsRecoverRet then
            Event.Brocast("model_receive_skill_data_msg", data.skill)
        end
    end

    if m_data.cache_score ~= (m_data.wait_add_score + m_data.score + m_data.wait_dec_score) then
        dump(data, "<color=red>EEE S2CFrameMessage</color>")
        dump(m_data.cache_score, "<color=red>EEE cache_score</color>")
        dump(m_data.wait_add_score, "<color=red>EEE wait_add_score</color>")
        dump(m_data.score, "<color=red>EEE score</color>")
        local ss = m_data.cache_score - m_data.wait_add_score - m_data.wait_dec_score
        m_data.score = ss
        Event.Brocast("ui_refresh_player_money")
    end

    -- 额外数据 FishingMatchModel.BrocastActivity  FishExtManager.RefreshData  顺序不能修改
    FishExtManager.RefreshData(data.ext_data)
    FishingMatchModel.BrocastActivity(data)
end

function FishingMatchModel.BrocastActivity(data)
    if data.activity and next(data.activity) then
        for k,v in ipairs(data.activity) do
            if true then
                if FishingMatchModel.IsRecoverRet then
                    Event.Brocast("fish_activity_recover", v)
                else
                    Event.Brocast("fish_activity", v)
                end
            end
        end
    end
end

function FishingMatchModel.BrocastActivityExitAll()
    Event.Brocast("fish_activity_exit_all")
end

-- 发送开枪消息
function FishingMatchModel.SendShoot(vec, isPC)
    local userdata = FishingMatchModel.GetSeatnoToUser(vec.seat_num)

    local x = vec.x
    local y = vec.y
    if not vec.id then
        vec.id = BulletManager.GetNextBulletID()
    end

    local sendData = { }
    sendData.Shoot = {}
    sendData.Shoot.id = vec.id
    sendData.Shoot.rate = vec.id
    sendData.Shoot.x = x * 100
    sendData.Shoot.y = y * 100
    sendData.Shoot.type = vec.act_type
    sendData.Shoot.seat_num = vec.seat_num
    sendData.Shoot.index = userdata.gun_info.show_bullet_index
    -- 破产了不创建子弹
    if not isPC then
        -- 自己和机器人发射子弹不用等服务器
        -- 模仿服务器的消息
        local shootData = { }
        shootData.x = x
        shootData.y = y
        shootData.id = vec.id
        shootData.seat_num = vec.seat_num
        shootData.index = userdata.gun_info.show_bullet_index
        if vec.lock_fish_id then
            shootData.lock_fish_id = vec.lock_fish_id
        end
        shootData.index = userdata.gun_info.show_bullet_index
        shootData.type = vec.act_type
        Event.Brocast("model_shoot", shootData)
        Event.Brocast("activity_shoot", shootData)
    end
    -- 发送消息给服务器
    FishingMatchModel.C2SFrameMessage(sendData)
end

function FishingMatchModel.SendBulletBoom(data)
    local _data = {}
    _data.Boom = data
    Event.Brocast("model_bullet_boom", data)
    if data.id > 0 then
        FishingMatchModel.C2SFrameMessage(_data)
    else
        BulletManager.AddSendTriggerFishMap(_data)
    end
end

-- 爆炸鱼的爆炸范围内选几条炸死
-- 发送给服务器验证死亡是否生效
function FishingMatchModel.SendBoomFishHarm(data)
    local _data = {}
    _data.BoomHarm = data
    FishingMatchModel.C2SFrameMessage(_data)
end
-- 更新技能CD
function FishingMatchModel.UpdateSkillCD(time_elapsed)
    for i=1, 4 do
        if m_data.players_info[i].frozen_cd and m_data.players_info[i].frozen_cd > 0 then
            local oldcd = m_data.players_info[i].frozen_cd
            m_data.players_info[i].frozen_cd = m_data.players_info[i].frozen_cd - time_elapsed

            if m_data.players_info[i].frozen_cd < 0 then
                m_data.players_info[i].frozen_cd = 0
                if m_data.players_info[i].frozen_state == "inuse" then
                    if FishingMatchModel.Defines.IceCD <= 0 then
                        m_data.players_info[i].frozen_state = "nor"
                    else
                        m_data.players_info[i].frozen_state = "cooling"
                        m_data.players_info[i].frozen_cd = FishingMatchModel.Defines.IceCD
                        m_data.players_info[i].frozen_max_cd = FishingMatchModel.Defines.IceCD
                    end
                else
                    m_data.players_info[i].frozen_state = "nor"
                end
            end
        end
        if m_data.players_info[i].lock_cd and m_data.players_info[i].lock_cd > 0 then
            m_data.players_info[i].lock_cd = m_data.players_info[i].lock_cd - time_elapsed
            if m_data.players_info[i].lock_cd < 0 then
                if m_data.players_info[i].lock_state == "inuse" then
                    if FishingMatchModel.Defines.LockCD <= 0 then
                        m_data.players_info[i].lock_state = "nor"
                    else
                        m_data.players_info[i].lock_cd = FishingMatchModel.Defines.LockCD
                        m_data.players_info[i].lock_max_cd = FishingMatchModel.Defines.LockCD
                        m_data.players_info[i].lock_state = "cooling"
                    end

                else
                    m_data.players_info[i].lock_state = "nor"
                end
                Event.Brocast("model_lock_skill_change_msg", i)
            end
        end
    end
    if m_data.scene_frozen_state == "inuse" then
        local oldcd = m_data.scene_frozen_cd
        m_data.scene_frozen_cd = m_data.scene_frozen_cd - time_elapsed
        if oldcd > 3 and m_data.scene_frozen_cd < 3 then
            Event.Brocast("model_ice_skill_deblocking_msg")
        end
        if m_data.scene_frozen_cd <= 0 then
            m_data.scene_frozen_cd = 0
            m_data.scene_frozen_state = "nor"
            Event.Brocast("model_ice_skill_change_msg", m_data.use_frozen_seat_num)
            m_data.use_frozen_seat_num = nil
        end
    end
end

function FishingMatchModel.GetLockState(seat_num)
    return m_data.players_info[seat_num].lock_state
end

function FishingMatchModel.GetSceneIceState()
    return m_data.scene_frozen_state
end
-- 激光状态
function FishingMatchModel.SetPlayerLaserState(seat_num, state)
    if m_data.players_info[seat_num] then
        m_data.players_info[seat_num].use_laser_state = state
    end
end
function FishingMatchModel.GetPlayerLaserState(seat_num)
    if m_data.players_info[seat_num] then
        return m_data.players_info[seat_num].use_laser_state
    end
end

-- 核弹状态
function FishingMatchModel.SetPlayerMissileState(seat_num, state)
    if m_data.players_info[seat_num] then
        m_data.players_info[seat_num].use_missile_state = state
    end
end
function FishingMatchModel.GetPlayerMissileState(seat_num)
    if m_data.players_info[seat_num] then
        return m_data.players_info[seat_num].use_missile_state
    end
end
-- 能否开炮
function FishingMatchModel.IsCanUseGun(seat_num)
    local user = m_data.players_info[seat_num]
    if user and user.gun_info and user.gun_info.show == 1 and user.gun_info.lock_time <= 0 then
        local gun_info = user.gun_info
        if gun_info.block_time and gun_info.block_time > 0 then
            return false
        end
        return true
    end
end

function FishingMatchModel.GetSceneIceTime()
    return m_data.scene_frozen_cd
end

-- 发送技能消息
function FishingMatchModel.SendSkill(data)
    if data.msg_type == "frozen" and m_data.scene_frozen_state == "inuse" then
        print("<color=red>冰冻状态中，无法再次使用冰冻</color>")
        return
    end
    local sendData = {}
    sendData.Skill = {}
    sendData.Skill = data

    -- 发送消息给服务器
    FishingMatchModel.C2SFrameMessage(sendData)        
end

-- 技能能否使用
function FishingMatchModel.CheckIsCanUseSkill(type)
    local userdata = FishingMatchModel.GetPlayerData()
    if type == "prop_fish_lock" then
        if userdata.lock_state == "nor" then
            if userdata.prop_fish_lock > 0 then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    if type == "prop_fish_frozen" then
        if FishingMatchModel.data.scene_frozen_state == "inuse" then
            return false
        end
        if userdata.frozen_state == "nor" then
            if userdata.prop_fish_frozen > 0 then
                return true
            else
                return false
            end
        else
            return false
        end
    end

    return false
end
-- 发送技能消息
function FishingMatchModel.UseSkill(type, id)
    local userdata = FishingMatchModel.GetPlayerData()
    if type == "buy_activity" then
        FishingMatchModel.SendSkill({seat_num = FishingMatchModel.GetPlayerSeat(), msg_type = type, id = id})
        return true
    end
end

-- 发送活动消息
function FishingMatchModel.SendActivity(data)
    local sendData = {}
    sendData.Activity = {}
    sendData.Activity = data
    dump(data, "<color=green>SendActivity</color>")
    -- 发送消息给服务器
    FishingMatchModel.C2SFrameMessage(sendData)        
end


-- 修改抢倍率
function FishingMatchModel.GetChangeRate(val, cg)
    local ss = {41,42,43,44}
    for k,v in ipairs(ss) do
            if val == v then
                local cgk = v + cg
            if cgk < ss[1] then
                return ss[#ss]
            elseif cgk > ss[#ss] then
                return ss[1]
                else
                    return cgk
                end
            end
        end
    -- if m_data.barbette_id then
    --     for k,v in ipairs(m_data.barbette_id) do
    --         if val == v then
    --             local cgk = v + cg
    --             if cgk < m_data.barbette_id[1] then
    --                 return m_data.barbette_id[#m_data.barbette_id]
    --             elseif cgk > m_data.barbette_id[#m_data.barbette_id] then
    --                 return m_data.barbette_id[1]
    --             else
    --                 return cgk
    --             end
    --         end
    --     end
    -- end
end

-- 摄像机 用于坐标转化
function FishingMatchModel.SetCamera(camera2d, camera)
    FishingMatchModel.camera2d = camera2d
    FishingMatchModel.camera = camera
end
-- 2D坐标转UI坐标
function FishingMatchModel.Get2DToUIPoint(vec)
    vec = FishingMatchModel.camera2d:WorldToScreenPoint(vec)
    vec = FishingMatchModel.camera:ScreenToWorldPoint(vec)
    return vec
end
-- UI坐标转2D坐标
function FishingMatchModel.GetUITo2DPoint(vec)
    vec = FishingMatchModel.camera:WorldToScreenPoint(vec)
    vec = FishingMatchModel.camera2d:ScreenToWorldPoint(vec)
    return vec
end
function FishingMatchModel.GetFirstSystemTime()
    return m_data.first_system_time
end
function FishingMatchModel.GetBeginTime()
    return m_data.begin_time
end

function FishingMatchModel.GetSystemTime()
    return m_data.system_time
end
-- 枪的皮肤
function FishingModel.GetGunSkinCfg(seat_num, index)
    local user = m_data.players_info[seat_num]
    return FishingMatchModel.GetGunCfgByPlayer(user)
end
function FishingMatchModel.GetGunCfg(index, seat_num)
    if FishingMatchModel.Config.fish_gun_map[index] then
        return FishingMatchModel.Config.fish_gun_map[index]
    else
        return FishingMatchModel.Config.fish_gun_map[1]
    end
end
-- 枪的阶段
function FishingMatchModel.GetGunStageIndex(seat_num)
    local user = m_data.players_info[seat_num]
    if user and user.gun_info then
        local gun_info = user.gun_info
        local cfg = FishingMatchModel.GetGunCfg(gun_info.show_bullet_index) 
        return cfg.gun_level
    end
    return 1
end
function FishingMatchModel.GetGunCfgByPlayer(user)
    return FishingMatchModel.GetGunCfg(user.gun_info.show_bullet_index) 
end
function FishingMatchModel.GetMinGunCfg()
    if m_data.barbette_id and #m_data.barbette_id > 0 then
        return FishingMatchModel.Config.fish_gun_map[m_data.barbette_id[1]]
    else
        return FishingMatchModel.Config.fish_gun_map[41]
    end
end
function FishingMatchModel.GetGunIdToIndex(id)
    if m_data.barbette_id then
        for k,v in ipairs(m_data.barbette_id) do
            if v == id then
                return k
            end
        end
    end
    return 1

end

local debug_log = false
FishingMatchModel.money_log = ""
FishingMatchModel.frame_log_list = {}
function FishingMatchModel.AddMoneyLog(seat_num, log)
    if debug_log then
        FishingMatchModel.money_log = FishingMatchModel.money_log .. "\n" .. "seat_num=" .. seat_num .. " " ..log
    end
end
-- 钱不同步
function FishingMatchModel.SaveMoneyLog()
    if debug_log then
        local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id .. "/fish_money_log.txt"
        print("<color=red>钱同步路径 path = " .. path .. "</color>")
        File.WriteAllText(path, FishingMatchModel.money_log)
    end
end

function FishingMatchModel.AddFrameLog(data)
    if debug_log then
        FishingMatchModel.frame_log_list[#FishingMatchModel.frame_log_list + 1] = basefunc.safe_serialize(data)
    end
end
-- 钱不同步
function FishingMatchModel.SaveFrameLog()
    if debug_log then
        local path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id .. "/fish_frame_log.txt"
        print("<color=red>钱同步路径 path = " .. path .. "</color>")
        File.WriteAllText(path, basefunc.safe_serialize(FishingMatchModel.frame_log_list))
    end
end

--使用活动道具
function FishingMatchModel.UseObjProp(id, callback)
    Network.SendRequest("use_obj_prop",{obj_id = tostring(id)}, "正在使用道具",function(data)
        dump(data, "<color=white>使用道具</color>")
        if data.result == 0 then
            Event.Brocast("model_use_obj_prop", data)
            if callback and type(callback) == "function" then
                callback()
            end
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end
--使用活动道具
function FishingMatchModel.UseItem(item,callback)
    Network.SendRequest("use_item",{item = tostring(item)}, "使用道具",function(data)
        dump(data, "<color=white>使用道具</color>")
        data.item = data.item or item
        Event.Brocast("model_use_obj_prop", data)
        if data.result == 0 then
            if callback and type(callback) == "function" then
                callback()
            end
        end
    end)
end


function FishingMatchModel.CacheRankData(data, index)
    if not m_data.rank_data then
        m_data.rank_data = {}
    end
    m_data.rank_data[index] = data
end
function FishingMatchModel.GetRankData(index)
    if not m_data.rank_data then
        return
    end
    return m_data.rank_data[index]
end
function FishingMatchModel.CacheMyRankData(data)
    if not m_data.my_rank_data then
        m_data.my_rank_data = {}
    end
    m_data.my_rank_data = data
end
function FishingMatchModel.GetMyRankData()
    return m_data.my_rank_data
end
-- 获取道具购买的钱
function FishingMatchModel.GetBuySkillToMoney(key)
    if FishingMatchModel.Config.fishmatch_buy_activity_map[key] then
        local cfg = FishingMatchModel.Config.fishmatch_buy_activity_map[key]

        local user = FishingMatchModel.GetPlayerData()
        local gun_config = FishingMatchModel.GetGunCfg(user.gun_info.bullet_index)
        return cfg.price[gun_config.gun_level]
    else
        return 0
    end
end
-- 获取可购买道具列表
function FishingMatchModel.GetBuySkillToList()
    local cfg = FishingManager.GetGameIDToConfig(m_data.game_id)
    return cfg.buy_act_cfg
end

