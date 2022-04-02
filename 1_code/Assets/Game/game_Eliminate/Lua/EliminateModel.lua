local basefunc = require "Game.Common.basefunc"
EliminateModel = {}
local M = EliminateModel
M.xiaoxiaole_defen_cfg = HotUpdateConfig("Game.game_Eliminate.Lua.xiaoxiaole_defen_cfg")
M.xiaoxiaole_base_cfg = HotUpdateConfig("Game.game_Eliminate.Lua.xiaoxiaole_base_cfg")

M.Model_Status = {
    gaming = "gaming",
    gameover = "gameover"
}

M.status_lottery = {
    wait = "wait",--等待开奖
    run = "run",--开奖中
}

M.fruit_enum={
    apple=1,
    melon=2,
    star=3,
    seven=4,
    bar=5,
    lucky=6,
    null = 0,
}

M.eliminate_enum = {
	nor = 3,--摇中3个，普通开奖
	del_type = 4,--lucky 摇中4个，消除同类
    clear_all = 5,--lucky 摇中5个及以上，消除全屏
    fix = 1,--
}

M.lottery_type ={
    nor = "nor",--普通开奖
    lucky = "lucky",--lucky开奖
}


M.save_path = AppDefine.LOCAL_DATA_PATH .. "/" .. MainModel.UserInfo.user_id
M.save_file = "eliminate_data"
M.save_table = {
    set = {--当局的设置
        auto = false,--是否托管
        speed = 1,--当前速度
        skip = false,--是否跳过
        bet = {0,0,0,0,0},--押注额
    },
}
M.yxcard_type = "prop_xxl_shuiguo_card"

local lister
local function MakeLister()
    lister = {}
    lister["xxl_all_info_response"] = M.xxl_all_info_response
    lister["xxl_enter_game_response"] = M.xxl_enter_game_response
    lister["xxl_quit_game_response"] = M.xxl_quit_game_response
    lister["xxl_kaijiang_response"] = M.xxl_kaijiang_response
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
    local lua_data = load_json2lua(M.save_file,M.save_path)
    dump(lua_data, "<color=red>lua_data</color>")
    if lua_data and next(lua_data) then
        M.save_table = lua_data
    end
end

local function InitConfig(cfg,cfg2)
    M.cfg = {}
    M.cfg.size = cfg.size.size
    M.cfg.time = cfg.time.time
    M.cfg.kaijiang_maps = cfg.kaijiang_maps.kaijiang_maps.kaijiang_maps
    M.cfg.rate = {}
    for i,v in ipairs(cfg2.defenbiao) do
        M.cfg.rate[v.ys] = M.cfg.rate[v.ys] or {}
        M.cfg.rate[v.ys][v.lj] = v.bl
    end
    M.cfg.double_hit = {}
    for i,v in ipairs(cfg2.defenbiao) do
        M.cfg.double_hit[v.ys] = M.cfg.double_hit[v.ys] or 0
        if v.lj > M.cfg.double_hit[v.ys] then
            M.cfg.double_hit[v.ys] = v.lj
        end
    end
    M.cfg.bet = {}
    for i,v in ipairs(cfg2.yazhu) do
        M.cfg.bet[v.dw] = v.jb
    end
    M.cfg.level = {}
    for i,v in ipairs(cfg2.dangci) do
        M.cfg.level[v.dw] = {level = v.dw, min = v.min, max = v.max}
    end
    -- M.cfg = {
    --     size = {max_x = 8,max_y = 8,size_x = 115,size_y = 115, spac_x = 2,spac_y = 2},
    --     time = {
    --         speed_up_d = 0.2,--滚动加速间隔
    --         speed_uni_d = 3,--匀速滚动时长
    --         speed_down_d = 0.2,--滚动减速间隔
    --         speed_up_t = 0.2,--加速滚动时间
    --         speed_uni_t = 0.02,--每一次匀速滚动时间
    --         speed_down_t = 0.6,--减速滚动时间

    --         change_up_d = 0.2,--滚动加速间隔
    --         change_uni_d = 3,--匀速滚动时长
    --         change_down_d = 0.2,--滚动减速间隔
    --         change_up_t = 0.2,--加速滚动时间
    --         change_uni_t = 0.02,--每一次匀速滚动时间
    --         change_down_t = 0.6,--减速滚动时间

    --         fruit_move_t = 0.2,--水果移动时间
            
    --         eliminate_next_arr_d = 0.2,--消除同屏中的下一组待消除的时间间隔
    --         eliminate_next_scr_d = 0.4,--消除下一屏时间间隔
    --         change_lucky_t = 0.02,--改变一个lucky的时间
    --         spring_t = 0.2,--水果抖动持续时间

    --         auto_lotter_d = 3,--自动托管开奖时间间隔

    --         play_fruit_part_d = 1,--播放消除特效后的延时
    --         win_lucky_right_t = 1,--lucky提示特效
    --         win_lucky_ll_t = 2,--lucky来临特效
    --         del_all_type_right_t = 2,--同类消除中其它同类的闪光时间
    --         del_all_type_blow_t = 2,--同类消除中所有同类的闪光时间
    --         del_clear_blow_t = 2,--全屏爆炸时长
    --         del_clear_lucky_change_fruit_t = 0.1,--消除全屏lucky变为水果的
    --         del_clear_lucky_change_fruit_d = 0.02,--消除全屏lucky变为水果后的延时
    --         del_clear_right_t = 0.2,--清除全屏格子闪光特效时间
    --         del_clear_pz_d = 1.5,--全屏消除飘字后间隔
    --         fruit_shake_t = 4,--消除全屏的水果时，水果的抖动时间
    --         camer_shake_t = 1.5,--相机抖动时间
            
    --         eliminate_clear_dis_time=6, --结算面板自动消失的时间
    --         eliminate_clear_anim_time=4, --结算面板动画结束的时间
    --         eliminate_clear_wait_time=1.7, --3档或以上奖励and4个lucky以上的延迟事件
            
    --         eliminate_despfb_into_time=0.6 --奖励物体飞入的时间
    --     },
    --     kaijiang_maps = "6666666661112226611122266115522663355446633344466333444666666666",--默认的kaijiang_maps
    -- }
end

local function InitModelData(game_id)
    M.data = {
        auto = M.save_table.set.auto,
        speed = M.save_table.set.speed,
        skip = M.save_table.set.skip,
        bet = M.save_table.set.bet,
        --s2c
        award_money = 0,--奖励的钱
        award_rate = 0,--倍率
        status_lottery = M.status_lottery.wait,--开奖状态
        all_award_data = {},--所有奖励
    }
end

function M.Init()
    InitConfig(M.xiaoxiaole_base_cfg,M.xiaoxiaole_defen_cfg)
    InitSaveData()
    InitModelData()
    MakeLister()
    M.AddMsgListener()
    return M
end

function M.Exit()
    M.RemoveMsgListener()
    lister = nil
    M.data = nil
    M = nil
end

--***********************all
function M.xxl_all_info_response(p_n, data)
    dump(data, "<color=yellow>xxl_all_info_response</color>")
    -- data.result = 1002
    if data.result ~= 0 then
        if data.result == -1 then
            Event.Brocast("model_xxl_all_info_error")
            return
        end
        HintPanel.ErrorMsg(data.result,function()
            Event.Brocast("model_xxl_all_info_error")
        end)
        return
    end
    InitModelData()
    M.data.model_status = M.Model_Status.gaming
    --恢复数据
    M.data.award_money = data.last_award_money
    M.data.award_rate = data.last_award_rate / 10
    M.data.fix_xiaochu_str = data.fix_xiaochu_str

    if data.fix_xiaochu_str then
        M.data.fix_xiaochu_map = eliminate_algorithm.compute_fix_xiaochu_result(data.fix_xiaochu_str,M.cfg)
        dump(M.data.fix_xiaochu_map, "<color=white>固定消除</color>")
    end

    if not data.kaijiang_maps then
        data.kaijiang_maps = M.cfg.kaijiang_maps
        M.data.eliminate_data = eliminate_algorithm.compute_eliminate_result(data.kaijiang_maps,data.lucky_maps,M.cfg)
        M.data.eliminate_data.result = nil
        M.data.eliminate_data.bureau_type = M.lottery_type.nor
    else
        --优化后的方法
        M.data.eliminate_data = eliminate_algorithm.compute_eliminate_result(data.kaijiang_maps,data.lucky_maps,M.cfg)
    end
    --结果打印
    dump(M.data.eliminate_data, "<color=red>eliminate_data</color>")
    if M.data.eliminate_data.result then
        for k,v in pairs( M.data.eliminate_data.result) do
            dump(v, "<color=red>result:</color>" .. k)
        end
    end
    
    M.SetAuto(false)
    M.SetDataLotteryEnd()

    if M.save_table then
        M.SetSkip(M.save_table.set.skip or false)
        M.SetSpeed(M.save_table.set.speed or 1)
        M.SetBet(M.save_table.set.bet or {0,0,0,0,0})
    else
        M.SetSkip(false)
        M.SetSpeed(1)
        M.SetBet({0,0,0,0,0})
    end

    dump(M.data, "<color=yellow>数据</color>")
    Event.Brocast("model_xxl_all_info")
end

--********************response
--进入游戏
function M.xxl_enter_game_response(_, data)
    dump(data, "<color=yellow>xxl_enter_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_enter_game_response", data)
end

--退出游戏
function M.xxl_quit_game_response(proto_name, data)
    dump(data, "<color=yellow>xxl_quit_game_response</color>")
    InitModelData()
    Event.Brocast("model_xxl_quit_game_response", data)
    if data.result == 0 then
        Event.Brocast("quit_game_success")
    end
end

local tem = 0
--开奖
function M.xxl_kaijiang_response(proto_name, data)
    dump(data, "<color=yellow>xxl_kaijiang_response</color>")
    -- tem = tem + 1
    -- if tem == 3 then
    --     data.result = 1008
    -- end
    if data.result == 0 then
        M.SetDataLotteryStart()
        if data.award_money then
            M.data.award_money = data.award_money
        end
        if data.award_rate then
            M.data.award_rate = data.award_rate / 10
        end
        M.data.fix_xiaochu_map = nil
        if data.fix_xiaochu_str then
            M.data.fix_xiaochu_map = eliminate_algorithm.compute_fix_xiaochu_result(data.fix_xiaochu_str,M.cfg)
            dump(M.data.fix_xiaochu_map, "<color=white>固定消除</color>")
        end

        M.data.eliminate_data = eliminate_algorithm.compute_eliminate_result(data.kaijiang_maps,data.lucky_maps,M.cfg)
        --结果打印
        dump( M.data.eliminate_data, "<color=red>eliminate_data</color>")
        if M.data.eliminate_data.result then
            for k,cur_result in pairs( M.data.eliminate_data.result) do
                dump(cur_result, "<color=red>result：</color>" .. k)
            end
        end
        M.data.all_award_data = M.GetLotteryAwardData(M.data.eliminate_data)

        EliminateInfoPanel.SetAllAwardData(M.data.eliminate_data)

        Event.Brocast("model_lottery_success")
    else
        if data.result == 1012 then
            --如果是[需要的数量有异常]就弹出充值面板
            Event.Brocast("model_lottery_error_amount")
        else
            HintPanel.ErrorMsg(data.result)
        end
        EliminateGamePanel.ExitTimer()
        EliminateObjManager.ExitTimer()
        EliminateAnimManager.ExitTimer()
        M.SetAuto(false)
        M.SetDataLotteryEnd()
        Event.Brocast("model_lottery_error")
    end
end

--*******************************方法
function M.ConvertAllDelList(eliminate_data)
    local all_del_list = {}
    for i,cur_result in ipairs(eliminate_data.result) do
        if cur_result.del_list then
            for j,cur_del_list in ipairs(cur_result.del_list) do
                local eliminate_type = M.eliminate_enum.nor
                local change_id = 0
                --消除同类
                if cur_result.win_lucky and cur_result.win_lucky.over then
                    if cur_result.win_lucky.max_win_count == M.eliminate_enum.del_type then
                        if cur_result.del_type_list then
                            for i,v in ipairs(cur_del_list) do
                                if cur_result.del_type_list[1].id == v.id and cur_result.del_type_list[1].x == v.x and cur_result.del_type_list[1].y == v.y then
                                    eliminate_type = M.eliminate_enum.del_type
                                    change_id = v.id
                                end
                            end
                        end
                    elseif cur_result.win_lucky.max_win_count == M.eliminate_enum.clear_all then
                        eliminate_type = M.eliminate_enum.clear_all
                        change_id = cur_result.win_lucky.win_list[1][1].id
                        for i,v in ipairs(cur_del_list) do
                            v.id = change_id
                        end
                    end
                end
                table.insert( all_del_list, {cur_del_list = cur_del_list , type = eliminate_type,id = change_id})
            end
        end
    end
    dump(all_del_list, "<color=green>all_del_list</color>")
    return all_del_list
end

function M.GetLotteryAwardData(eliminate_data)
    return eliminate_algorithm.get_lottery_award_data(M.data.award_rate,M.data.award_money,M.GetBet(),M.ConvertAllDelList(eliminate_data),M.cfg.rate,M.cfg.double_hit)
end

function M.GetLotteryLevel()
    local cur_rate = M.GetAwardRate()
    for level,v in ipairs(M.cfg.level) do
        if v.min <= cur_rate and cur_rate < v.max then
            return level
        end
    end
    return 1
end

function M.SetDataLotteryEnd()
    M.data.status_lottery = M.status_lottery.wait
    M.SetSkip(false)
end

function M.SetDataLotteryStart()
    M.data.status_lottery = M.status_lottery.run
end


function M.SetAuto(v)
    if not v and type(v) ~= "boolean" then return end
    M.data = M.data or {}
    M.data.auto = v
    if v then
        M.SetSpeed(2)
    else
        M.SetSpeed(1)
    end
    -- M.save_table.set.auto = M.data.auto
    -- M.SaveData()
end

function M.GetAuto()
    if not M then return false end
    if M.data and M.data.auto then
        return M.data.auto
    end  
end

function M.SetSpeed(v)
    if not v and type(v) ~= "number" then return end
    M.data = M.data or {}
    M.data.speed = v
    -- M.save_table.set.speed = M.data.speed
    -- M.SaveData()
end

function M.GetSpeed()
    if M.data and M.data.speed then
        return M.data.speed
    end  
    return 1
end

function M.SetSkip(v)
    if not v and type(v) ~= "boolean" then return end
    M.data = M.data or {}
    M.data.skip = v
    -- M.save_table.set.skip = M.data.skip
    -- M.SaveData()
end

function M.GetSkip()
    if M.data and M.data.skip then
        return M.data.skip
    end  
end

function M.SetBet(v)
    if not v and type(v) ~= "tabel" then return end
    M.data = M.data or {}
    M.data.bet = v
    M.save_table.set.bet = M.data.bet
    M.SaveData()
    Event.Brocast("eliminate_bet_change",M.data.bet)
end

function M.GetBet()
    if M and M.data and M.data.bet then
        return M.data.bet
    end  
end

function M.SaveData()
    M.save_table.set.speed = 1
    save_lua2json(M.save_table,M.save_file,M.save_path)
end

function M.GetTime(t)
    t = t or 1
    if M and M.data and M.data.speed then
        M.data.speed = M.data.speed or 1
        return t / M.data.speed / 2
    else
        return 0.02
    end
end


function M.GetAwardMoney(  )
    if not M or not M.data or not M.data.award_money then return 0 end
    return M.data.award_money or 0
end

function M.GetAwardRate(  )
    return M.data.award_rate
end

function M.ConvertAndAddFixDelList(all_del_list)
    if table_is_null(M.data.fix_xiaochu_map) or table_is_null(M.data.fix_xiaochu_map.del_list) then return end
    local cur_del_list = M.data.fix_xiaochu_map.del_list[1]
    local eliminate_type = M.eliminate_enum.nor
    local change_id = cur_del_list[1].id
    table.insert(all_del_list,1, {cur_del_list = cur_del_list , type = eliminate_type,id = change_id})
    dump(all_del_list, "<color=green>all_del_list fix</color>")
end