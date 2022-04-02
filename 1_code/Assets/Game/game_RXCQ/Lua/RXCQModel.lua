-- 创建时间:2021-02-03

RXCQModel = {}
local M = RXCQModel

local this
local lister
local m_data
local Timers = {}
local exit_funcs = {}
local register_obj = {}
local audio_limit_timer
local audio_limit_index = 0
local audio_limit_map = {}
M.BetIndex = 1
M.Is_Auto = false
--角色传送效果只有在切换押注，和进入切出小游戏才会播放，所以需要这个值用来特殊处理
M.player_chuansong_type = false
RXCQModel.BetRateList = {0,0,0,0}
RXCQModel.LastBetRateList = {0,0,0,0}
RXCQModel.HistoryData = {}
M.prefab_map = {
	[1] = "RXCQItem_JueZhanShaCheng",
	[2] = "RXCQItem_CiShaJianShu",
	[3] = "RXCQItem_BanYueWanDao",
	[4] = "RXCQItem_GongShaJianShu",
	[5] = "RXCQItem_LieHuoJianFa",
	[6] = "RXCQItem_ShenBinTianJiang",
	[7] = "RXCQItem_TianRenHeYi",
	[8] = "RXCQItem_BanYueWanDao_Ex",
	[9] = "RXCQItem_CiShaJianShu_Ex",
	[10] = "RXCQItem_GongShaJianShu_Ex",
	[11] = "RXCQItem_LieHuoJianFa_Ex",
}
M.qipan = {
	1,4,10,2,3,8,6,4,10,4,2,11,5,4,9,2,8,3,7,4,9,4,2,5
}


function M.MakeLister()
    lister = {}
    lister["rxcq_query_game_history_response"] = M.on_rxcq_query_game_history_response
    lister["rxcq_all_info_response"] = M.on_rxcq_all_info_response
    lister["rxcq_kaijiang_response"] = M.on_rxcq_kaijiang_response
    lister["EnterForeGround"] = M.on_EnterForeGround
end
--注册斗地主正常逻辑的消息事件
function M.AddMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.AddListener(proto_name, _)
    end
end

--删除斗地主正常逻辑的消息事件
function M.RemoveMsgListener()
    for proto_name, _ in pairs(lister) do
        Event.RemoveListener(proto_name, _)
    end
end

function M.Init()
    this = M
    M.MakeLister()
    M.AddMsgListener()
    audio_limit_timer = nil
    audio_limit_index = 0
    audio_limit_map = {}
    RXCQModel.BetRateList = {0,0,0,0}
    RXCQModel.LastBetRateList = {0,0,0,0}
    return this
end

function M.Exit()
    if this then
        for i = 1,#Timers do
            Timers[i]:Stop()
        end
        for i = 1,#exit_funcs do
            if type(exit_funcs[i]) == "function" then
                exit_funcs[i]()
            end
        end
        Timers = {}
        register_obj = {}
        M.RemoveMsgListener()
        this = nil
        lister = nil
    end
end

function M.on_EnterForeGround()
    if RXCQModel.IsDuringMiniGame == true then
        for k,v in pairs(Timers) do
            if v then
                v:Stop()
            end
        end
    end
end

function M.AddTimers(timer)
    Timers[#Timers + 1] = timer
end

--设置当前的押注档次
function M.SetBetIndex(bet_index)
    M.BetIndex = bet_index
end
 
function M.on_rxcq_kaijiang_response(_,data)
    dump(data,"<color=red>开奖数据</color>")
    data.data3 = {
        [1] = {
             award   = "966666",
             cid     = 19,
             monster = {
                5,6,7,1,3,2,4,0,1,2,5,6,7,
             },
             rate    = "16",
         },
        --  [2] = {
        --      award   = "200",
        --      cid     = 20,
        --      monster = {
        --          5,
        --          6,
        --      },
        --      rate    = "0.4"
        --  }
     }
    if data.result == 0 then
        M._all_game_data = data.data
        M.game_data = data.data[1]
        Event.Brocast("model_rxcq_kaijiang")
        RXCQModel.LastBetRateList = data.bet_rate_list
        RXCQModel.all_award = 0
        for i = 1,#data.data do
            RXCQModel.all_award = RXCQModel.all_award + data.data[i].award
        end
    end
end

function M.GetBaoJiRate()
    local config = {
        "GongShaJianShu",
        "CiShaJianShu",
        "BanYueWanDao",
        "LieHuoJianFa",
    }    
    for i = 1,#RXCQModel.BetRateList do
        if RXCQModel.BetRateList[i] > 0 then
            if M.GetSkillNameByCid(RXCQModel.game_data.cid) == config[i] then
                return RXCQModel.BetRateList[i]
            end
        end
    end
    return 0
end

function M.SetNextData(index)
    M.game_data = M._all_game_data[index]
    M.AddHistory({
        award_jinbi = M.game_data.award,
        bet_id = M.BetIndex,
        cid = M.game_data.cid,
        monster = M.game_data.monster,
        time = os.time(),
    })
    dump(M._all_game_data,"<color=red> M._all_game_data </color>")
    dump(index,"<color=red> index </color>")
    dump(M.game_data,"<color=red>当前数据+++++++</color>")
end

function M.GetCurrSkill()
    if M.game_data then
        dump(M.game_data,"M.game_data")
        return M.GetSkillNameByCid(M.game_data.cid)
    end
end

function M.GetSkillNameByCid(cid)
    local key_word = {
        [1] = "BanYueWanDao",
        [2] = "CiShaJianShu",
        [3] = "GongShaJianShu",
        [4] = "LieHuoJianFa",
        [5] = "JueZhanShaCheng",
        [6] = "TianRenHeYi",
        [7] = "ShenBinTianJiang",
    }
    for i = 1,#key_word do
        if string.match(M.prefab_map[M.qipan[cid]],key_word[i]) == key_word[i] then
            return key_word[i]
        end
    end
end

function M.IsMiniGame(cid)
    local config = {
		BanYueWanDao = "normal",
        CiShaJianShu = "normal",
        GongShaJianShu = "normal",
        LieHuoJianFa = "normal",
        JueZhanShaCheng = "mini_game",
        TianRenHeYi = "mini_game",
        ShenBinTianJiang = "mini_game",
	}
    skill_name = M.GetSkillNameByCid(cid)
	local _type = config[skill_name]
	if _type == "normal" then
        return false
	elseif _type == "mini_game" then
        return true
	end
end


function M.GetGuaiWuConfig(Bet,Index)
    local guaiwu_id = rxcq_main_config.base[Bet].GuaiWu_Map[Index]
    return rxcq_main_config.guaiwu[guaiwu_id]
end

function M.on_rxcq_all_info_response(_,data)
    dump(data,"<color=red>断线重连数据</color>")
    Event.Brocast("model_rxcq_all_info_response")
end

function M.on_rxcq_query_game_history_response(_,data)
    if data.result == 0 then
		RXCQModel.HistoryData = data.data
    end
end

function M.AddBetRateList(skill_index)
    RXCQModel.BetRateList[skill_index] = RXCQModel.BetRateList[skill_index] + 1
    Event.Brocast("bet_rate_list_change")
end

function M.ReSetBetRateList()
    RXCQModel.BetRateList = RXCQModel.LastBetRateList
    Event.Brocast("bet_rate_list_change")
end

function M.ClearBetRateList()
    RXCQModel.BetRateList = {0,0,0,0}
    Event.Brocast("bet_rate_list_change")
end

function M.GetHistory()
    return RXCQModel.HistoryData
end

function M.GetAutoSpeed()
    M.Auto_Speed = M.Is_Auto and 1.3 or 1
    return M.Auto_Speed
end

function M.AddHistory(data)
    if RXCQModel.HistoryData then
        table.insert(RXCQModel.HistoryData,1,data)
        dump(RXCQModel.HistoryData,"插入的历史数据++++")
    end
end

function M.DelayCall(call,time)
    local timer = Timer.New(
        function()
            if call then
                call()
            end
        end
    ,time,1)
    timer:Start()
    Timers[#Timers + 1] = timer
end

function M.RegisterExitFunc(func)
    exit_funcs[#exit_funcs + 1] = func
end

function M.SetRegisterObj (key,obj)
    if not register_obj[key] then
        register_obj[key] = obj
    else
        dump(register_obj[key],"<color=red>现在已经有这个key</color>")
    end
end

function M.GetRegisterObj(key)
    return register_obj[key]
end

--一定时间内不重复播放音效
function M.PlayAudioLimit(audio_name,limit_time)
    limit_time = limit_time or 0.02
    if audio_limit_timer == nil then
        audio_limit_timer = Timer.New(
            function()
                audio_limit_index = audio_limit_index + 0.02
            end
        ,0.02,-1,nil,true)
        audio_limit_timer:Start()
        Timers[#Timer + 1] = audio_limit_timer
    end
    if audio_limit_map[audio_name] then
        if audio_limit_index - audio_limit_map[audio_name].last_play_timer > audio_limit_map[audio_name].limit_time then
            ExtendSoundManager.PlaySound(audio_config.rxcq[audio_name].audio_name)
            audio_limit_map[audio_name].limit_time = limit_time
            audio_limit_map[audio_name].last_play_timer = audio_limit_index
        else
        end
    else
        audio_limit_map[audio_name] = {}
        ExtendSoundManager.PlaySound(audio_config.rxcq[audio_name].audio_name)
        audio_limit_map[audio_name].limit_time = limit_time
        audio_limit_map[audio_name].last_play_timer = audio_limit_index
    end
end