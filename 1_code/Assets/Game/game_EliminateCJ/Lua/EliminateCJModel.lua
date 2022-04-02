local basefunc = require "Game.Common.basefunc"
EliminateCJModel = {}
local M = EliminateCJModel
M.xiaoxiaole_defen_cfg = HotUpdateConfig("Game.game_EliminateCJ.Lua.xiaoxiaole_cj_defen_cfg")
M.xiaoxiaole_line_cfg = HotUpdateConfig("Game.game_EliminateCJ.Lua.xiaoxiaole_cj_line_cfg")
M.Curr_Data_Index = 0
local Status =  EliminateCJEnum.Status
M.Status = nil
M.IsAuto = false
M.AllInfoRight = false
M.data = {}
--连线消消乐就是超级消消乐 所以 lxxxl = cjxxl
local lister
M.yxcard_type = "prop_xxl_chaoji_card"
local function MakeLister()
    lister = {}
    lister["eliminate_cj_anim_finsh_one_roll"] = M.on_eliminate_cj_anim_finsh_one_roll
    lister["lxxxl_kaijiang_response"] = M.on_lxxxl_kaijiang_response
    lister["lxxxl_enter_game_response"] = M.on_lxxxl_enter_game_response
    lister["lxxxl_quit_game_response"] = M.on_lxxxl_quit_game_response
    lister["lxxxl_all_info_response"] = M.on_lxxxl_all_info_response
end

local function MsgDispatch(proto_name, data)
    local func = lister[proto_name]
    if not func then
        error("brocast " .. proto_name .. " has no event.")
    end
    --临时限制   一般在断线重连时生效  由logic控制
    if M.data.limitDealMsg and not M.data.limitDealMsg[proto_name] then
        return
    end
    func(proto_name, data)
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

function M.Update()
    
end

local function InitSaveData()
	
end

local function InitConfig(cfg,cfg2)

end

local function InitModelData(game_id)
    
end

function M.Init()
    MakeLister()
    M.AddMsgListener()
    M.Curr_Data_Index = -1
    M.Map_String = {}
    M.Status = Status.over
    M.IsAuto = false
    M.AllInfoRight = false
    return M
end

function M.Exit()
    M.RemoveMsgListener()
    lister = nil
    M.data = nil
    M = nil
end

function M.Str2Table(str)
    local zimu_2_num = function(input)
        local data = {
            a = 10,
            b = 11,
        }
        return data[input] or input
    end
    local str_table = basefunc.string.string_to_vec(str)
    local table = {}
    for i = 1,#str_table do
        table[#table + 1] = tonumber(zimu_2_num(str_table[i]))
    end
    return table
end

function M.GetCurrData()
    M.Curr_Main_Data = M.Str2Table(M.Map_String[M.Curr_Data_Index])
    return M.Curr_Main_Data
end

function M.on_lxxxl_enter_game_response(_,data)
    Event.Brocast("model_cjxxl_enter_game_response", data)
end

function M.on_lxxxl_all_info_response(_,data)
    dump(data,"<color>超级消消乐所有信息</color>")
    if data.result ~= 0 then
        if data.result == -1 then
            Event.Brocast("model_cjxxl_all_info_error")
            return
        end
        HintPanel.ErrorMsg(data.result,function()
            Event.Brocast("model_cjxxl_all_info_error")
        end)
        return
    end
    if data.result == 0 then
        M.data.limitDealMsg = nil
        M.AllInfoRight = true
        if data.all_money then
            if M.Status == Status.over then
                Event.Brocast("model_cjxxl_had_reconnect_data",data)    
            end
        else

        end
        Event.Brocast("model_cjxxl_all_info")
    end
end

function M.on_lxxxl_kaijiang_response(_,data)
    dump(data,"<color=red>开奖数据-----------------</color>")
    --data = M.TestData()
    if data.result == 0 then
        M.Curr_Data_Index = 1
        M.IsGot = true
        M.Curr_Rate = data.all_rate
        M.Curr_Win = data.all_money
        M.Map_String = data.map_string
    else
        if data.result == 1012 then
            --如果是[需要的数量有异常]就弹出充值面板
            Event.Brocast("model_lottery_error_amount")
        end
    end
end

function M.on_lxxxl_quit_game_response(proto_name, data)
    Event.Brocast("model_cjxxl_quit_game_response",data)
    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end

function M.IsGotData()
    return M.IsGot
end

function M.GetCurrRate()
    return M.Curr_Rate
end

function M.GetCurrWin()
    return M.Curr_Win
end

function M.GetCurrDataIndex()
    return M.Curr_Data_Index
end

function M.on_eliminate_cj_anim_finsh_one_roll()
    M.Curr_Data_Index = M.Curr_Data_Index + 1
    if M.Curr_Data_Index > #M.Map_String then
        M.Curr_Data_Index = 1
        M.Status = Status.over
        M.IsGot = false
        Event.Brocast("eliminate_cj_game_over")
    else
        Event.Brocast("eliminate_cj_go_next_roll")
    end
end

function M.SetBet(bet)
    M.bet = bet
end

function M.GetBet()
    return M.bet
end

function M.TestData()
    return {
        all_money=22000,
        map_string={
            [1]="8717237a11aa815",
            [2]="25bb175bb162bb9",
            [3]="373333673336673",
            [4]="575747557444545",
            [5]="545885458885488",
            [6]="744247242424727",
            [7]="b9bb4b9bb4b9bb4",
            [8]="bbbb2bbbb2bbbb2",
            [9]="9b3898b2197b131",
            [10]="288222282228222",
            [11]="677666677676767",
        },
        comb_id=1,
        free_num=10,
        result=0,
        all_rate=1100,
    }
end