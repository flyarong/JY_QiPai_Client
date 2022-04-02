-- 创建时间:2020-11-17
-- Template_NAME 管理器

local basefunc = require "Game/Common/basefunc"
DMBJModel = {}
DMBJ_Enum = {
    Start = "第一次开奖前",
    First = "第一次开奖后",
    Sceond = "第二次开奖后",
    Free = "免费游戏"
}
local M = DMBJModel
M.dmbj_base_config = HotUpdateConfig("Game.game_DMBJ.Lua.dmbj_base_config")
M.IsTest = false
M.Status = DMBJ_Enum.Start
DMBJModel.Round = 0
--小游戏经验值
DMBJModel.Explore = 0
--当前档次选择
DMBJModel.BetIndex = 1
--当前场景ID
DMBJModel.SceneID = 1
--当前游戏奖励
DMBJModel.Award = 0
--小游戏奖励
DMBJModel.MiniAward = 0
--当前翻奖倍率
DMBJModel.Rate = 0
local this
local lister
local First_Lottery_Map = {}
local Second_Lottery_Map = {}
local function MakeLister()
    lister = {}
    lister["dmbj_free_game_kaijiang_msg"] = M.on_dmbj_free_game_kaijiang_msg
    lister["dmbj_second_kaijiang_msg"] = M.on_dmbj_second_kaijiang_msg
    lister["dmbj_all_info_response"] = M.on_dmbj_all_info_response
    lister["dmbj_first_kaijiang_response"] = M.on_dmbj_first_kaijiang_response
    lister["dmbj_second_kaijiang_response"] = M.on_dmbj_second_kaijiang_response
    lister["dmbj_free_game_kaijiang_response"] = M.on_dmbj_free_game_kaijiang_response
    lister["dmbj_enter_game_response"] = M.on_dmbj_enter_game_response
    lister["dmbj_quit_game_response"] = M.on_dmbj_quit_game_response
end

local function MsgDispatch(proto_name, data)
    local func = lister[proto_name]
    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if M.limitDealMsg and not M.limitDealMsg[proto_name] then
        return
    end
    func(proto_name, data)
end

--服务器标志
-- second_kaijiang
-- second_settle
-- free_game_kaijiang
-- free_game_settle
function M.on_dmbj_all_info_response(_,data)
    dump(data,"<color=red>盗墓笔记all_info</color>")
    if data.result == 0 then
        M.limitDealMsg = nil
        M.AllInfoRight = true
        DMBJModel.Explore = data.player_data.explore_value
        if data.res then
            DMBJModel.ReConnect = M.string2int(data.res)
        end
        DMBJModel.SceneID = data.scene_id or DMBJModel.SceneID
        DMBJModel.Rate = data.all_rate or DMBJModel.Rate
        DMBJModel.Bet = data.bet_money or DMBJModel.Bet
        DMBJModel.GetCutDownTime = os.time() 
        DMBJModel.CutDown = data.cutdown or DMBJModel.CutDown
        if data.status == "second_kaijiang" then
            DMBJModel.Award = data.award_money
            M.Status = DMBJ_Enum.First
            First_Lottery_Map = M.string2int(data.res)
        elseif data.status == "second_settle" then
            M.Status = DMBJ_Enum.Sceond
            DMBJModel.Award = data.award_money
            Second_Lottery_Map = M.string2int(data.res)
        elseif data.status == "free_game_kaijiang" then
            M.Status = DMBJ_Enum.Free
            DMBJModel.MiniAward = data.award_money
        end
        Event.Brocast("reconnect_dmbj") 
        Event.Brocast("model_dmbj_all_info")
    end
end

function M.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, MsgDispatch)
    end
end


function M.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, MsgDispatch)
    end
end

function M.GetAward()
    return DMBJModel.Award
end

function M.Init()
    First_Lottery_Map = {}
    Second_Lottery_Map = {}
    M.send_exchange = {}
    M.Status = DMBJ_Enum.Start
    MakeLister()
    M.AddMsgListener()
end

function M.SetBetIndex(BetIndex)
    M.BetIndex = BetIndex
end

function M.ReSetData()
    First_Lottery_Map = {}
    Second_Lottery_Map = {}
end

function M.CountRate(parm,link_length)
    local data = M.dmbj_base_config.base[parm]["link_"..link_length]
    return data and data or 0
end

function M.GetFirstTestData()
    math.randomseed(os.time())
    -- return {
    --     math.random(1, 10),math.random(1, 10),math.random(1, 10),math.random(1, 10),math.random(1, 10)
    -- }
    M.Status = DMBJ_Enum.First
    return {4,5,5,8,8}
end

function M.on_dmbj_first_kaijiang_response(_,data)
    dump(data,"<color=red>-------------盗墓笔记第一次开奖——————————</color>")
    if data.result == 0 then
        First_Lottery_Map = M.string2int(data.res)
        M.Status = DMBJ_Enum.First
        M.CutDown = data.cutdown
        M.GetCutDownTime = os.time()
        Event.Brocast("first_kaijiang_finsh")
    else

    end
end

function M.on_dmbj_second_kaijiang_response(_,data)
    dump(data,"<color=red>-------------盗墓笔记第二次开奖——————————</color>")
    if data.result == 0 then
        Second_Lottery_Map = M.string2int(data.res)
        M.Status = DMBJ_Enum.Sceond
        M.Explore = data.player_data.explore_value
        M.Award = data.award_money
        M.Rate = data.all_rate
        Event.Brocast("second_kaijiang_finsh")
    else

    end
end

function M.on_dmbj_second_kaijiang_msg(_,data)
    dump(data,"<color=red>自动完成第一阶段</color>")
    Second_Lottery_Map = M.string2int(data.res)
    M.Status = DMBJ_Enum.Sceond
    M.Explore = data.player_data.explore_value
    M.Award = data.award_money
    M.Rate = data.all_rate
    Event.Brocast("second_kaijiang_finsh_by_system")
end

function M.on_dmbj_free_game_kaijiang_msg(_,data)
    dump(data,"<color=red>自动完成抽奖~</color>")
    DMBJModel.Explore = data.player_data.explore_value
    DMBJModel.MiniAward = data.award_money
    DMBJModel.IsEnd = data.is_end
    DMBJModel.Status = DMBJModel.IsEnd == 1 and DMBJ_Enum.Start or DMBJ_Enum.Free
    DMBJModel.Round = data.round
    DMBJModel.Status = DMBJ_Enum.Free
    Event.Brocast("dmbj_free_game_changed")
end

function M.on_dmbj_free_game_kaijiang_response(_,data)
    dump(data,"<color=red>小游戏开奖返回</color>")
    if data.result == 0 then
        DMBJModel.IsEnd = data.is_end
        DMBJModel.MiniAward = data.award_money
        DMBJModel.CutDown = data.cutdown
        DMBJModel.Status = DMBJModel.IsEnd == 1 and DMBJ_Enum.Start or DMBJ_Enum.Free
        DMBJModel.Round = data.round
        M.GetCutDownTime = os.time()
        Event.Brocast("dmbj_free_game_changed")
    end
end

function M.SetExchangeID(tabel)
    M.send_exchange = tabel
end

function M.GetFirstLotteryMap()
    if M.IsTest and table_is_null(First_Lottery_Map) then 
        First_Lottery_Map = M.GetFirstTestData()
    end
    return First_Lottery_Map
end

function M.SetSceneID(SceneID)
    M.SceneID = SceneID
end

function M.SetBet(Bet)
    M.Bet = Bet
end

function M.GetSecondLotteryMap()
    if M and M.IsTest and table_is_null(Second_Lottery_Map) then 
        Second_Lottery_Map =  M.GetSecondTestData()
    end
    return Second_Lottery_Map
end

function M.GetSecondTestData()
    local data = M.GetFirstLotteryMap()
    local re = {}
    for i = 1,#data do
        local is_keep = true
        for j = 1,#M.send_exchange do
            if i == M.send_exchange[j] then
                is_keep = false
            end
        end
        if is_keep then
            re[#re + 1] = math.random(1, 10)
        else
            re[#re + 1] = data[i]
        end
    end
    --return re
    return {4,4,8,8,10}
end


function M.GetCurrCutDown()
    return  M.GetCutDownTime + M.CutDown - os.time()
end

function M.GetDifferentAtMap()
    local re = {}
    local keep_item = {}
    local data = M.GetFirstLotteryMap()
    for i = 1,#data do
        local is_keep = true
        for j = 1,#M.send_exchange do
            if i == M.send_exchange[j] then
                is_keep = false
            end
        end
        if is_keep then
            keep_item[#keep_item + 1] = data[i]
        end
    end
    local usedmap = M.SetTagWithList(keep_item)
    local secondmap = M.SetTagWithList(M.GetSecondLotteryMap())
    for i = 1,#usedmap do
        for j = 1,#secondmap do
            if secondmap[j].parm == usedmap[i].parm and secondmap[j].tag and usedmap[i].tag then
                secondmap[j].tag = false
                usedmap[i].tag = false
            end
        end
    end
    for i = 1,#secondmap do
        if secondmap[i].tag then
            re[#re + 1] = secondmap[i].parm
        end
    end
    return re
end

function M.SetTagWithList(list)
    local re = {}
    for i = 1,#list do
        local data = {parm = list[i],tag = true}
        re[#re + 1] = data
    end
    return re
end


function M.on_dmbj_enter_game_response(_,data)
    dump(data,"<color=red>进入场景</color>")
    Event.Brocast("model_dmbj_enter_game_response", data)
end

function M.on_dmbj_quit_game_response(_,data)
    dump(data,"<color=red>退出消息++++++++++</color>")
    Event.Brocast("model_dmbj_quit_game_response",data)
    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end

local turnMap = {
    A = 10
}
function M.string2int(str_table)
    local re = {}
    for i = 1,#str_table do 
        re[#re + 1] = turnMap[str_table[i]] and turnMap[str_table[i]] or tonumber(str_table[i])
    end
    return re
end

function M.Exit()
    M.RemoveMsgListener()
    lister = nil
    M.data = nil
    M = nil
end