
ZPGModel = {}
local M = ZPGModel
local zpg_config = require "Game.game_ZPG.Lua.zpg_config"

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
    bet = "bet",
    game = "game",
    settle = "settle"
}

local this
local lister
local m_data
local update
local updateDt = 0.1

local CheckUpdateTimer
local BetFrameData = {
    bet_1 = {},
    bet_2 = {},
    bet_3 = {}
}
local is_recovered = false
--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --模式
    lister["guess_apple_all_info_response"] = this.on_fg_all_info
    lister["guess_apple_game_status_change"] = this.on_guess_apple_game_status_change
    lister["guess_apple_total_bet_tb"] = this.guess_apple_total_bet_tb
    lister["guess_apple_add_kaijiang_log"] = this.on_guess_apple_add_kaijiang_log
    lister["guess_apple_player_num_change"] = this.on_guess_apple_player_num_change
    lister["guess_apple_cancel_bet_response"] = this.on_guess_apple_cancel_bet_response
    lister["guess_apple_bet_response"] = this.on_guess_apple_bet_response
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
        if proto_name ~= "fg_status_info" and proto_name ~= "guess_apple_all_info" then
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


-- -- **************
-- #
-- # 协议：客户端 服务端 共用
-- #

-- .guess_apple_status_data {
--   status $ : string       # 游戏状态 bet,game,settle
--   time_out $ : integer    # 游戏倒计时
--   player_num $ : integer  # 游戏总人数
-- }

-- .guess_apple_bet_data {
--   total_bet_data $ : * integer     # 总下注
--   my_bet_data $ : * integer        # 我的下注
--   my_auto_bet_reamin $ : integer   # 我的自动下注剩余次数
-- }
-- .guess_apple_game_data {
--     left_apple $ : integer     # 左边显示的苹果个数
--     right_apple $ : integer    # 右边显示的苹果个数
--     is_gold_coin $ : integer   # 是否是金元宝 1 是 0 不是
--   }
-- .guess_apple_settle_data {
--   award_value $ : value      # 奖励值
-- }
-- 世顺
-- -- ----------------------------------------C2S
-- # 猜苹果 进入房间
-- guess_apple_enter_room @ {
--   request {
--   }
--   response {
--     result $ : integer                # 0 成功

--   }
-- }

-- # 猜苹果 退出房间
-- guess_apple_quit_room @ {
--   request {
--   }
--   response {
--     result $ : integer                # 0 成功

--   }
-- }


-- # 猜苹果下注
-- guess_apple_bet @ {
--   request {
--     bet_index $ : integer    # 下注的投入索引，如果有替代资产，就不会扣鲸币
--     bet_pos $ : integer      # 下注的位置 ，1 左赢，2平，3右赢
--   }
--   response {
--     result $ : integer                # 0 成功

--   }
-- }


-- # 猜苹果 所有信息
-- guess_apple_all_info @ {
--   request {
--   }
--   response {
--     result $ : integer                         # 0 成功
--     status_data $ : guess_apple_status_data
--     bet_data $ : guess_apple_bet_data
--     game_data $ : guess_apple_game_data
--     settle_data $ : guess_apple_settle_data
--     history_data $ : *integer
--   }
-- }

-- #
-- # 协议：服务端 => 客户端
-- #

-- # 猜苹果的状态改变
-- guess_apple_game_status_change @ {
--   request {
--     status_data $ : guess_apple_status_data
--     bet_data $ : guess_apple_bet_data
--     game_data $ : guess_apple_game_data
--     settle_data $ : guess_apple_settle_data
--   }
-- }

-- # 猜苹果同步 所有下注信息
-- guess_apple_total_bet_tb @ {
--   request {
--     bet_data $ : guess_apple_bet_data
--   }
-- }
-- # 猜苹果 增加开奖记录
-- guess_apple_add_kaijiang_log @ {
--   request {
--     kaijiang_type $ : integer   # 开奖类型
--   }
-- }
-- # 猜苹果 人数改变
-- guess_apple_player_num_change @ {
--   request {
--     player_num $ : integer      # 人数
--   }
-- }
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

    --all_info数据
    m_data.game_status = nil --游戏状态 bet game settle
    m_data.time_out = 0 --剩余开奖时间
    m_data.player_num = 0 --游戏总人数
    m_data.total_bet_list = {} --总下注列表
    m_data.my_bet_list = {[1] = 0,[2] = 0,[3] = 0} --玩家下注列表
    m_data.my_auto_bet_reamin = 0 --我的自动下注剩余次数
    m_data.apple_data = {} --开奖数据
    m_data.apple_data.left_apple = 0 --左侧苹果数量
    m_data.apple_data.right_apple = 0 --右侧苹果数量
    m_data.apple_data.is_gold_coin = 0 --金元宝判断
    m_data.winner = 0 --上局赢家
    m_data.award_value = 0 --奖励金额
    m_data.history_data= {} --历史数据
    m_data.liansheng_number = 0 --连胜数据

    --前端数据 可能是配置好的
    m_data.current_bet_index = m_data.current_bet_index or 1 --当前下注额度
    m_data.current_bet_pos = 0 --当前下注位置

    m_data.add_bet_value = {} 

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
        M.data = nil
        
        if CheckUpdateTimer then
            CheckUpdateTimer:Stop()
            CheckUpdateTimer = nil
        end
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
    this.UIConfig.bet_config = {}
    this.UIConfig.bet_item_limit = {}
    this.UIConfig.bet_item_limit_reconnect = {}
    for k,v in pairs(zpg_config.bet_item_config) do 
        this.UIConfig.bet_config[v.id] = v.gold
        this.UIConfig.bet_item_limit[v.id] = v.bet_item_limit
        this.UIConfig.bet_item_limit_reconnect[v.id] = v.bet_item_limit_reconnect
    end
    this.UIConfig.apple_config = {}
    for k,v in pairs(zpg_config.apple_position_config) do 
        this.UIConfig.apple_config[v.apple_count] = v.apple_position
    end
    this.UIConfig.total_bet_config = {}
    this.UIConfig.total_bet_permisition_config = {}
    for k,v in pairs(zpg_config.total_bet_config) do 
        --vip限制总押注
        this.UIConfig.total_bet_config[v.id -1] = v.limit_total
        this.UIConfig.total_bet_permisition_config[v.id] = {}
        this.UIConfig.total_bet_permisition_config[v.id].id = v.id
        this.UIConfig.total_bet_permisition_config[v.id].limit_1 = v.limit_1
        this.UIConfig.total_bet_permisition_config[v.id].limit_2 = v.limit_2
        this.UIConfig.total_bet_permisition_config[v.id].limit_3 = v.limit_3
        this.UIConfig.total_bet_permisition_config[v.id].limit_total = v.limit_total
        this.UIConfig.total_bet_permisition_config[v.id].permission_key = v.permission_key
    end
end

function M.on_fg_all_info(_,data)
    dump(data,"all_info_data")
    if data.result ~= 0 then
        dump(data.result)
        InitMatchData()
        MainLogic.ExitGame()
        ZPGLogic.change_panel(ZPGLogic.panelNameMap.hall)
    else
        InitMatchData()
        local s = data
        m_data.model_status = s.status
        s = data.status_data
        if s then
            m_data.game_status = data.status_data.status --游戏状态
            m_data.time_out = data.status_data.time_out --剩余时间
            if m_data.game_status == "bet" then
                -- M.StartUpdateTimer()
                is_recovered = true
            end
            m_data.player_num = data.status_data.player_num --总人数
        end
        s = data.bet_data
        if s then
            m_data.total_bet_list = data.bet_data.total_bet_data --总下注列表
            m_data.my_bet_list = data.bet_data.my_bet_data --玩家下注列表
            m_data.add_bet_value = m_data.total_bet_list
        end

        s = data.game_data
        if s then
            m_data.apple_data = data.game_data --苹果数据
            m_data.winner = this.CaculateWinner(m_data.apple_data.left_apple,m_data.apple_data.right_apple)
        end

        s = data.settle_data
        if s then
            m_data.award_value = data.settle_data.award_value --奖励数据
        end

        s = data.history_data
        if s then
            --历史数据倒置
            m_data.history_data = {}
            local j = 1
            for i = #s,1,-1 do
                m_data.history_data[j] = s[i]
                j = j + 1
            end
            m_data.liansheng_number = ZPGModel.CheckLianShen()
             --历史数据
        end
        Event.Brocast("model_fg_all_info")
    end
end


function M.on_guess_apple_game_status_change(_,data)
    local s
    s = data.status_data
    if s then
        this.on_guess_apple_status_data(data)
    end
    if m_data.game_status == "bet" then
        s = data.bet_data
        -- M.StartUpdateTimer()
        is_recovered = true
        if s then
            this.on_guess_apple_bet_data(data)
        end
    elseif m_data.game_status == "game" then
        s = data.game_data
        if s then
            this.on_guess_apple_game_data(data)
        end
    elseif m_data.game_status == "settle" then
        s = data.settle_data
        if s then
            this.on_guess_apple_settle_data(data)
        end
    end
end

function M.guess_apple_total_bet_tb(_,data)
    dump(data,"guess_apple_total_bet_tb")
    for i = 1,3 do
        m_data.add_bet_value[i] = data.total_bet_data[i] - (m_data.total_bet_list[i] or 0)
    end
    m_data.total_bet_list = data.total_bet_data
    Event.Brocast("model_guess_apple_bet_data")
end

function M.on_guess_apple_add_kaijiang_log(_,data)
    local history_data = data.kaijiang_type
    m_data.history_data[#m_data.history_data + 1] = history_data
    m_data.liansheng_number = ZPGModel.CheckLianShen()
    Event.Brocast("model_guess_apple_add_kaijiang_log",history_data)
end

function M.CheckLianShen()
    local winner = m_data.history_data[#m_data.history_data]
    if winner == 2 then return 0 end
    local ret = 0
    for i = #m_data.history_data,1,-1 do
        if m_data.history_data[i] == winner then 
            ret = ret + 1
        else break end
    end
    return ret
end

function M.on_guess_apple_player_num_change(_,data)
    m_data.player_num = data.player_num
    Event.Brocast("model_guess_apple_player_num_change")
end

function M.on_guess_apple_cancel_bet_response(_,data)
    if data.result == 0 then
        for i = 1,3 do
            m_data.my_bet_list[i] = 0
        end
        Event.Brocast("model_guess_apple_cancel_bet_response")
    else 
        HintPanel.ErrorMsg(data.result)
    end
end

function M.on_guess_apple_status_data(data)
    dump(data,"on_guess_apple_status_data")
    if not data.status_data then return end
    m_data.game_status = data.status_data.status
    m_data.time_out = data.status_data.time_out
    m_data.player_num = data.status_data.player_num
    if m_data.game_status == "bet" then
        --清空下注数据和苹果数据
        this.ClearGameData()
    end
    Event.Brocast("model_guess_apple_status_data")
end

function M.ClearGameData()
    m_data.total_bet_list = {} --总下注列表
    m_data.my_bet_list = {[1] = 0,[2] = 0,[3] = 0} --玩家下注列表
    m_data.apple_data.left_apple = 0
    m_data.apple_data.right_apple = 0
    m_data.apple_data.is_gold_coin = 0
end


function M.on_guess_apple_bet_data(data)
    dump(data,"on_guess_apple_bet_data")
    if not data.bet_data then return end
    --计算本次刷新增加的下注
    for i = 1,3 do
        m_data.add_bet_value[i] = data.bet_data.total_bet_data[i] - (m_data.total_bet_list[i] or 0)
    end
    m_data.total_bet_list = data.bet_data.total_bet_data
    m_data.my_bet_list = data.bet_data.my_bet_data or m_data.my_bet_list
    Event.Brocast("model_guess_apple_bet_data")
end

function M.on_guess_apple_game_data(data)
    dump(data,"<color=red>on_guess_apple_game_data</color>")
    if not data.game_data then return end
    m_data.apple_data = data.game_data
    local apple_data = m_data.apple_data
    m_data.total_bet_list = data.bet_data.total_bet_data
    m_data.my_bet_list = data.bet_data.my_bet_data or m_data.my_bet_list
    if apple_data.left_apple > apple_data.right_apple then m_data.winner = 1
    elseif apple_data.left_apple == apple_data.right_apple then m_data.winner = 2
    elseif apple_data.left_apple < apple_data.right_apple then m_data.winner = 3 end
    Event.Brocast("model_guess_apple_game_data")
end

function M.on_guess_apple_settle_data(data)
    dump(data,"on_guess_apple_settle_data")
    if not data.settle_data then return end
    m_data.award_value = data.settle_data.award_value
    Event.Brocast("model_guess_apple_settle_data")
end

function M.on_guess_apple_bet_response(_,data)
    dump(data,"on_guess_apple_bet_response")
    if data.result == 0 then
        BetFrameData.bet_1 = {}
        BetFrameData.bet_2 = {}
        BetFrameData.bet_3 = {}
        is_recovered = true
        m_data.my_bet_list[m_data.current_bet_pos] = m_data.my_bet_list[m_data.current_bet_pos] + ZPGModel.UIConfig.bet_config[m_data.current_bet_index]
        Event.Brocast("model_guess_apple_bet_response",{pos = m_data.current_bet_pos , index = m_data.current_bet_index})
    elseif data.result == 5304 then
        HintPanel.ErrorMsg(data.result)
        is_recovered = true
    else
        HintPanel.ErrorMsg(data.result)
    end
end

function M.SendBet()
    -- return Network.SendRequest("guess_apple_bet",{bet_index =  m_data.current_bet_index,bet_pos =  m_data.current_bet_pos},"请求种树")
    if is_recovered == true then
        BetFrameData["bet_" .. m_data.current_bet_pos] = BetFrameData["bet_" .. m_data.current_bet_pos] or {}
        BetFrameData["bet_" .. m_data.current_bet_pos][#BetFrameData["bet_" .. m_data.current_bet_pos] + 1] = m_data.current_bet_index
        return M.CheckAllBetAndSend()
    else
        
    end
end

function M.OnAssetChange(data) 
    dump(data,"<color=red>onAssetChange</color>")
    local b = false
    if data.change_type == "guess_apple_award" or data.change_type == "guess_bet_spend" then return end
    for k,v in ipairs(data.data) do
        if v.asset_type == "jing_bi" then
            b = true
        end
    end
    if b then Event.Brocast("model_player_money_change") end
end

function M.CheckLimitByPermission()
    local limit
    local desc = "培养已达到上限，提升VIP等级可提高培养数量"
    for k,v in pairs(M.UIConfig.total_bet_permisition_config) do
        local _permission_key = v.permission_key
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                _permission_key = nil
            else
                limit = v
            end
        end
    end
    if limit and limit.id >= 8 then 
        desc = "培养已达到上限"
    end
    return limit,desc
end

function M.CaculateWinner(left,right)
    if left > right then return 1
    elseif left == right then return 2
    elseif left < right then return 3 end
end

function M.CheckAllBetAndSend()
    if (next(BetFrameData.bet_1) or next(BetFrameData.bet_2) or next(BetFrameData.bet_3)) then
        is_recovered = false
        return Network.SendRequest("guess_apple_bet",BetFrameData,"下注")
    end
end

function M.StartUpdateTimer()
    BetFrameData = {
        bet_1 = {},
        bet_2 = {},
        bet_3 = {},
    }
    --每秒上传一次
    if CheckUpdateTimer then
        CheckUpdateTimer:Stop()
        CheckUpdateTimer = nil
    end
    is_recovered = true
    CheckUpdateTimer = Timer.New(function()
    end,1,-1,true)
    CheckUpdateTimer:Start()
end

function M.CloseUpdateTimer(callback)
    if CheckUpdateTimer then
        CheckUpdateTimer:Stop()
        CheckUpdateTimer = nil
    end
end