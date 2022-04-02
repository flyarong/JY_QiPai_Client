-- 创建时间:2018-10-15
MatchLogic = {}
local M = MatchLogic

local lister
local function AddMsgListener()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function MakeLister()
    lister = {}
    lister["shared_finish_response"] = M.shared_finish_response
    -- lister["leave_match_game_response"] = M.leave_match_game_response
    lister["query_everyday_shared_award_response"] = M.query_everyday_shared_award_response
end

local function RemoveListener()
    for proto_name,func in pairs(lister or {}) do
        Event.RemoveListener(proto_name, func)
    end
    lister = {}
end

M.State = {
    wait_show = "wait_show",--等待显示，
    wait_on = "wait_on",--等待开启，
    wait_signup = "wait_signup",--等待报名，
    signup = "signup",--报名，
    match = "match",--比赛，
    match_over = "match_over",--比赛结束
    wait_off = "wait_off",--等待关闭，
    wait_hide = "wait_hide",--等待隐藏，
    hide = "hide",--隐藏
}

local WeekTable = {
    [0] = "天",
    [1] = "一",
    [2] = "二",
    [3] = "三",
    [4] = "四",
    [5] = "五",
    [6] = "六",
}

local function set_week(time)
    local cur_w_time = os.date("%W",os.time())
    local w_time = os.date("%W",time)
    local week_day = os.date("%w",time)
    if week_day then
        if cur_w_time - w_time > 1 then
            return os.date("%m/%d %H:%M",time) .. "开赛"
        elseif cur_w_time - w_time == 1 then
            return "上周" .. WeekTable[tonumber(week_day)] .. " " .. os.date("%H:%M",time) .. "开赛"
        elseif cur_w_time == w_time then
            return "本周"  .. WeekTable[tonumber(week_day)] .. " " .. os.date("%H:%M",time) .. "开赛"
        elseif cur_w_time - w_time == -1 then
            return "下周"  .. WeekTable[tonumber(week_day)] .. " " .. os.date("%H:%M",time) .. "开赛"
        elseif cur_w_time - w_time < -1 then
            return os.date("%m/%d %H:%M",time) .. "开赛"
        end
    end
end

local WeekDayTable = {
    [0] = 7,
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
}
local function get_week_day(offset_t)
    offset_t = offset_t or 0
    local week_day = os.date("%w",os.time() + offset_t)
    return WeekDayTable[tonumber(week_day)]
end

local function get_nearest_week_day(start_week,offset_t)
    local week_day = get_week_day(offset_t)
    if not start_week then return week_day end
    for i,v in ipairs(start_week) do
        if week_day <= v then
            return v
        end
    end
    return start_week[1] + 7
end

local reback
local replay
local signup
local jing_bi_signup
local condition_signup
local prop_signup
local ad_signup
local share_signup
local start_signup
local query_rank

replay = function(cfg,watch_ad)
    if not cfg then return end
    if watch_ad == 1 then
        Network.SendRequest("get_tickets_watch_ad",{id = cfg.game_id})
    end
    local request = {id = tonumber(cfg.game_id)}
    dump({cfg,request},"<color=green>replay 报名</color>")
    local send = Network.SendRequest("nor_mg_replay_game", request, "正在报名")
    if not send then
        HintPanel.Create(1, "网络异常", function()
            GameManager.GotoUI({gotoui = "game_MatchHall"})
        end)
    end
end

signup = function (cfg,is_replay,watch_ad)
    if is_replay then
        replay(cfg,watch_ad)
        return
    end
    if watch_ad == 1 then
        Network.SendRequest("get_tickets_watch_ad",{id = cfg.game_id})
    end
    local request = {id = tonumber(cfg.game_id)}
    local parm = {
        gotoui = MatchModel.GetSceneByGameID(cfg.game_id),
        goto_scene_parm = true,
        call = function (  )
            MatchModel.SetCurrGameID(cfg.game_id)
        end,
        enter_scene_call = function(  )
            dump({cfg,request},"<color=green>报名</color>")
            local send = Network.SendRequest("nor_mg_signup", request, "正在报名",function(data)
                dump(data,"<color=green>nor_mg_signup</color>")
                if data.result == 0 then
                    dump(request.id,"<color=white>报名比赛成功：</color>")
                elseif data.result == 3601 then
                    HintPanel.Create(2,"您已经参加过该比赛了，更多福卡赛等你来，是否立刻前往福卡赛？",function()
                        MatchModel.SetCurHallType(MatchModel.HallType.fls)
                        GameManager.GotoUI({gotoui = "game_MatchHall"})
                    end)
                elseif data.result == -666 then
                    GameManager.GotoUI({gotoui = "game_MatchHall"})
                else
                    HintPanel.ErrorMsg(data.result,function()
                        GameManager.GotoUI({gotoui = "game_MatchHall"})
                    end)
                end
            end,true)
            if not send then
                HintPanel.Create(1, "网络异常", function()
                    GameManager.GotoUI({gotoui = "game_MatchHall"})
                end)
            end
        end
    }
    GameManager.GotoUI(parm)
end

reback = function(cfg)
    local now_match_game_id = MatchModel.GetNowMatchGameID(cfg.game_id)
    if now_match_game_id == cfg.game_id then
        local parm = {
            gotoui = MatchModel.GetSceneByGameID(cfg.game_id),
            goto_scene_parm = true,
            call = function (  )
                MatchModel.SetCurrGameID(cfg.game_id)
            end,
            enter_scene_call = function(  )
                dump(cfg,"<color=green>回到比赛</color>")
                local send = Network.SendRequest("reback_match_game", nil, "返回比赛",function(data)
                    dump(data,"<color=green>reback_match_game</color>")
                    if data.result == 0 then
                        
                    else
                        HintPanel.ErrorMsg(data.result,function()
                            GameManager.GotoUI({gotoui = "game_MatchHall"})
                        end)
                    end
                end,true)
                if not send then
                    HintPanel.Create(1, "网络异常", function()
                        GameManager.GotoUI({gotoui = "game_MatchHall"})
                    end)
                end
            end
        }
        GameManager.GotoUI(parm)
    else
        local now_cfg = MatchModel.GetGameCfg(now_match_game_id)
        if now_cfg then
            LittleTips.Create("已经报名" .. now_cfg.ui_match_name)
        else
            LittleTips.Create("已经报名其它比赛")
        end
    end
end

condition_signup = function(cfg,is_replay)
    dump({cfg,is_replay},"<color=green>优惠条件报名</color>")
    --优惠条件报名
    local discount_data = MatchModel.GetDiscountStatusByGameID(cfg.game_id)
    dump(discount_data,"<color=green>优惠条件</color>")
    if table_is_null(discount_data) then
        --没有优惠
        prop_signup(cfg,is_replay)
        return
    end

    if not table_is_null(discount_data.hash) then
        if  discount_data.hash.jing_bi then
            --鲸币优惠
            if discount_data.hash.jing_bi > MainModel.UserInfo.jing_bi then
                --鲸币不够
                --local hint_panel = HintPanel.Create(7,"当前鲸币不足，是否继续使用鲸币报名",function(  )
                    --其它优惠条件
                    --prop_signup(cfg,is_replay)
                --end,function(  )
                PayFastPanel.Create(cfg, function()
                    signup(cfg,is_replay)
                end)
                
                LittleTips.Create("鲸币不足~")
                --end)
                -- hint_panel:SetBtnTitle("鲸币报名", "报  名")
                -- hint_panel = nil
                return
            end
            signup(cfg,is_replay)
            return
        elseif discount_data.hash.vip_4 and discount_data.hash.vip_4 > 0 then
            --vip4回馈赛优惠
            signup(cfg,is_replay)
            return
        elseif discount_data.hash.free_ad and discount_data.hash.free_ad > 0 then
            --广告优惠报名
            ad_signup(cfg,is_replay)
            return
        elseif discount_data.hash.free_share and discount_data.hash.free_share > 0 then
            --分享优惠报名
            share_signup(cfg,is_replay)
            return
        else
            if not table_is_null(discount_data.list) and not table_is_null(discount_data.list[1]) then
                local condition = discount_data.list[1].discount_condition
                local count = discount_data.list[1].discount_count
                local str_arr = string.split(condition,"_")
                local s1,s2,s3 = str_arr[1],str_arr[2],str_arr[3]
                if s3 == "share" then
                    --分享优惠报名
                    M.ShareSignup(cfg,is_replay)
                    return
                elseif s3 == "ad" then
                    --广告优惠报名
                    ad_signup(cfg,is_replay)
                    return
                else
                    if s1 == "vip" then
                        if count ~= 0 then
                            signup(cfg,is_replay)
                            return
                        else
                            --鲸币优惠
                            if discount_data.hash.jing_bi > MainModel.UserInfo.jing_bi then
                                --鲸币不够
                                --local hint_panel = HintPanel.Create(7,"当前鲸币不足，是否继续使用鲸币报名",function(  )
                                    --其它优惠条件
                                    --prop_signup(cfg,is_replay)
                                --end,function(  )
                                
                                PayFastPanel.Create(cfg, function(  )
                                    signup(cfg,is_replay)
                                end)
                                LittleTips.Create("鲸币不足~")
                                --end)
                                -- hint_panel:SetBtnTitle("鲸币报名", "报  名")
                                -- hint_panel = nil
                                return
                            end
                            signup(cfg,is_replay)
                            return
                        end
                    else
                        if count == 0 then
                            signup(cfg,is_replay)
                            return
                        else
                            --鲸币优惠
                            if discount_data.hash.jing_bi > MainModel.UserInfo.jing_bi then
                                --鲸币不够
                                --local hint_panel = HintPanel.Create(7,"当前鲸币不足，是否继续使用鲸币报名",function(  )
                                    --其它优惠条件
                                    --prop_signup(cfg,is_replay)
                                --end,function(  )
                                PayFastPanel.Create(cfg, function(  )
                                    signup(cfg,is_replay)
                                end)
                                
			                    LittleTips.Create("鲸币不足~")
                                --end)
                                -- hint_panel:SetBtnTitle("鲸币报名", "报  名")
                                -- hint_panel = nil
                                return
                            end
                            signup(cfg,is_replay)
                            return
                        end
                    end
                end
            end
        end
    end
    --道具报名
    prop_signup(cfg,is_replay)
end

prop_signup = function(cfg,is_replay)
    dump({cfg,is_replay},"<color=green>门票报名</color>")
    --门票报名
    local signup_item,signup_item_count = MatchModel.GetSignupItem(cfg.game_id)
    dump({signup_item,signup_item_count},"<color=green>可用道具</color>")

    local is_jb = false
    for i,v in ipairs(cfg.signup_item or {}) do
        if v == "jing_bi" then
            is_jb = true
        end
    end

    if not is_jb then
        --只能用门票报名
        if table_is_null(signup_item) or table_is_null(signup_item_count) or (#signup_item ~= #signup_item_count) then
            --门票不满足，打开5折购门票
            LittleTips.Create("门票不足，请购买门票")
            GameManager.GotoUI({gotoui = "sys_014_ffyd",goto_scene_parm = "panel"})
            return
        end
    end
    
    if table_is_null(signup_item) or table_is_null(signup_item_count) or (#signup_item ~= #signup_item_count) then
        --道具不满足，其它方式报名
        ad_signup(cfg,is_replay)
        return
    end
    local item_key = signup_item[#signup_item]
    local item_count = signup_item_count[#signup_item_count]
    if #signup_item == 1 and item_key == "jing_bi" then
        --可以报名的道具只有鲸币
        ad_signup(cfg,is_replay)
    else
        --使用道具报名
        signup(cfg,is_replay)
    end
end

jing_bi_signup = function(cfg,is_replay)
    dump({cfg,is_replay},"<color=green>鲸币报名</color>")
    --鲸币报名
    local signup_item,signup_item_count = MatchModel.GetSignupItem(cfg.game_id)
    dump({signup_item,signup_item_count},"<color=green>鲸币报名</color>")
    local signup_jb
    local signup_jb_c
    for i,v in ipairs(signup_item or {}) do
        if v == "jing_bi" then
            signup_jb = v
            signup_jb_c = signup_item_count[i]
        end
    end

    if not signup_jb or not signup_jb_c then
        --不能使用金币报名
        LittleTips.Create("今日比赛已经结束，请明日再来")
        return
    end
    
    if signup_jb_c > MainModel.UserInfo.jing_bi then
        --只能使用鲸币报名，且鲸币不够
        PayFastPanel.Create(cfg, function(  )
            signup(cfg,is_replay)
        end)
    else
        signup(cfg,is_replay)
    end
end

ad_signup = function(cfg,is_replay)
    dump({cfg,is_replay},"<color=green>广告报名</color>")
    --ios 没有广告报名
    if gameRuntimePlatform ~= "Ios" and cfg.is_ad and cfg.is_ad == 1 then
        --广告参赛
        local ad_count = MatchModel.GetADCountByGameID(cfg.game_id)
        if ad_count > 0 then
            --看广告报名
            if AdvertisingManager.IsCloseAD() then
                local watch_ad = 1
                signup(cfg,is_replay,watch_ad)
            else
                local ad_tag = "match_signup" .. "_" .. cfg.game_id
                AdvertisingManager.RandPlay(ad_tag, function (data)
                    if data.result == 0 and data.isVerify then
                        local watch_ad = 1
                        signup(cfg,is_replay,watch_ad)
                    else
                        share_signup(cfg,is_replay)
                    end
                end)
            end
        else
            share_signup(cfg,is_replay)
        end
    else
        share_signup(cfg,is_replay)
    end
end

share_signup = function(cfg,is_replay)
    dump({cfg,is_replay},"<color=green>分享报名</color>")
    if cfg.is_share and cfg.is_share == 1 then
        --分享参赛
        local share_count = MatchModel.GetShareCountByGameID(cfg.game_id)
        if share_count > 0 then
            --分享报名
            M.ShareSignup(cfg,is_replay)
        else
            --道具报名
            jing_bi_signup(cfg,is_replay)
        end
    else
        jing_bi_signup(cfg,is_replay)
    end
end

start_signup = function(cfg,is_replay)
    dump({cfg = cfg,is_replay = is_replay},"<color=white>开始报名</color>")
    local now_match_game_id = MatchModel.GetNowMatchGameID(cfg.game_id)
    if now_match_game_id == cfg.game_id  then
        --已经报名，回到比赛
        reback(cfg)
        return
    end

    local signup_num = MatchModel.GetSignupNumByGameID(cfg.game_id)
    if not signup_num then
        LittleTips.Create("正在确定报名人数")
        return
    end
    if cfg.max_people and signup_num == cfg.max_people then
        LittleTips.Create("报名人数已满，请参加下一场比赛")
        return
    end
    --优先使用优惠条件报名
    condition_signup(cfg,is_replay)
end

query_rank = function(cfg)
    -- 排行榜分步请求
    local cur_index = 1
    local rank_list = {}
    local call
    call = function ()
        Network.SendRequest("nor_mg_query_all_rank",{id = cfg.game_id, index = cur_index},"正在请求排名",
            function(data)
                cur_index = cur_index + 1
                dump(data, "<color=yellow>nor_mg_query_all_rank_response</color>")
                if data.result == 0 then
                    for k,v in ipairs(data.rank_list) do  
                        rank_list[#rank_list + 1] = v
                    end
                    if #data.rank_list < 100 then
                        -- 排行榜请求完成
                        MatchHallRankPanel.Create(cfg, rank_list)
                    else
                        call()
                    end
                elseif data.result == 1004 then
                    MatchHallRankPanel.Create(cfg)
                else
                    HintPanel.ErrorMsg(data.result)
                end
        end)
    end
    call()
end

function M.Init()
    M.Exit()
    MatchModel.Init()
    MakeLister()
    AddMsgListener()
end

function M.Exit()
    RemoveListener()
    MatchModel.Exit()
end

function M.SignupMatch(cfg,is_replay)
    dump({cfg = cfg,is_replay = is_replay},"<color=white>报名</color>")
    if table_is_null(cfg) then 
        LittleTips.Create("配置出错")
        return
    end

    --权限验证
    local _permission_key = cfg.permission
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = false}, "CheckCondition")
        dump({a,b},"<color=white>报名权限</color>")
        if not a or not b then
            return
        end
    end

    --状态验证
    local state = MatchLogic.GetMatchState(cfg)
    if state.state ~= M.State.signup then
        print("<color=white>当前不在报名状态</color>")
        LittleTips.Create("当前不在报名状态")
        MatchHallDetailPanel.Create(cfg)
        return
    end

    --报名特殊需求
    if cfg.match_type == MatchModel.MatchType.qydjs and cfg.signup_item[1] == "obj_qianyuansai_ticket" then
        --千元大奖赛有特殊逻辑
        local signup_item,signup_item_count = MatchModel.GetSignupItem(cfg.game_id)
        if #signup_item == 1 and signup_item[1] == "jing_bi" then
            --只能用金币报名
            M.share_cfg_img_qys_share = basefunc.deepcopy(share_link_config.img_qys_share)
            local status = ShareModel.GetQueryEverydaySharedAward(M.share_cfg_img_qys_share.finish_type)
            if not status then
                ShareModel.ReqQueryEverydaySharedAward(M.share_cfg_img_qys_share.finish_type,{cfg = cfg})
            else
                if status >= 1 then
                    MatchHallHintQYSPanel.Create(cfg)
                else
                    ComMatchReviveBuyPanel.CheckBuyTicket(cfg, start_signup, start_signup)
                end 
            end
            return
        end
    end

    start_signup(cfg,is_replay)
end

function M.ReplayMatch(cfg)
    M.SignupMatch(cfg,true)
end

function M.ShareSignup(cfg,is_replay)
    local share_time = os.time()
    local share_cfg = basefunc.deepcopy(share_link_config.img_match_ddz_signup)
    share_cfg.isCircleOfFriends = false
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "image",share_cfg = share_cfg, finish_parm = {cfg = cfg,is_replay = is_replay}})
end

function M.shared_finish_response(data)
    if table_is_null(data) or data.result ~= 0 or table_is_null(data.share_cfg) then return end
    if data.share_cfg.key ~= "img_match_ddz_signup" then return end
    if table_is_null(data.finish_parm) then return end
    local cfg = data.finish_parm.cfg
    local is_replay = data.finish_parm.is_replay
    signup(cfg,is_replay)
end

function M.leave_match_game_response(data)
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
        return
    end
    GameManager.GotoUI({gotoui = "hall"})
end

function M.QueryRank(cfg)
    query_rank(cfg)
end

function M.GetMatchState(cfg)
    local os_t = os.time()
    local td_t = GetTodayTimeStamp()
    local td_os_t = os_t - td_t
    local week_day = get_week_day()
    local nearest_week_day = get_nearest_week_day(cfg.start_week)
    local signup_num = MatchModel.GetSignupNumByGameID(cfg.game_id)
    local now_match_game_id = MatchModel.GetNowMatchGameID()
    local discount_data = MatchModel.GetDiscountStatusByGameID(cfg.game_id)
    local share_count = MatchModel.GetShareCountByGameID(cfg.game_id)
    local ad_count = MatchModel.GetADCountByGameID(cfg.game_id)
    local data = {
        os_t = os_t,
        td_t = td_t,
        td_os_t = td_os_t,
        state = nil,
        show_cd = nil,
        show_t = nil,
        on_cd = nil,
        on_t = nil,
        signup_cd = nil,
        signup_t = nil,
        start_cd = nil,
        start_t = nil,
        off_cd = nil,
        off_t = nil,
        hide_cd = nil,
        hide_t = nil,
        other_match = nil,
        now_match = nil,
        max_people = nil,
        discount_data = nil,
        share_count = nil,
        ad_count = nil,
    }
    if now_match_game_id then
        for i,v in ipairs(now_match_game_id) do
            if v == cfg.game_id then
                data.now_match = true
                break
            end
        end
        if not data.now_match then
            data.other_match = true
        end
    end

    data.signup_num = signup_num
    if signup_num and cfg.max_people and signup_num == cfg.max_people then
        data.max_people = true
    end
    data.discount_data = discount_data
    data.share_count = share_count
    data.ad_count = ad_count

    local t
    local offset_t
    if cfg.start_type == 1 then
        --固定人数开赛
        data.state = M.State.signup
        data.signup_cd = 0
        data.signup_t = os_t
        data.start_cd = 0
        data.start_t = os_t
        return data
    elseif cfg.start_type == 2 then
        t = os_t
        data.signup_cd = cfg.signup_time - t
        data.signup_t = cfg.signup_time
        data.start_cd = cfg.start_time - t
        data.start_t = cfg.start_time
        --定时开赛
        if cfg.show_time and t < cfg.show_time then
            data.state = M.State.wait_show
            data.show_cd = cfg.show_time - t
            data.show_t = cfg.show_time
            return data
        end
        if cfg.signup_time and t <= cfg.signup_time then
            data.state = M.State.wait_signup
            data.signup_cd = cfg.signup_time - t
            data.signup_t = cfg.signup_time
            return data
        end
        if cfg.start_time and t <= cfg.start_time then
            data.state = M.State.signup
            data.start_cd = cfg.start_time - t
            data.start_t = cfg.start_time
            return data
        end
        if cfg.hide_time and t <= cfg.hide_time then
            --不知道比赛什么时候结束，所以比赛开始后都在比赛状态
            data.state = M.State.match
            local is_over = MatchModel.GetMatchIsOver(cfg.game_id)
            if is_over and is_over == 1 then
                --比赛结束
                data.state = M.State.match_over
            end
            data.hide_cd = cfg.hide_time - t
            data.hide_t = cfg.hide_time
            return data
        end
        data.state = M.State.hide
        return data
    elseif cfg.start_type == 3 then
        --定时（循环)开
        t = td_os_t
        offset_t = 86400 * (nearest_week_day - week_day)

        data.signup_cd = cfg.signup_time - t + offset_t
        data.signup_t = cfg.signup_time + td_t + offset_t
        data.start_cd = cfg.start_time - t
        data.start_t = cfg.start_time + td_t

        if nearest_week_day > week_day then
            data.state = M.State.wait_on
            data.on_cd = cfg.on_time - t + offset_t
            data.on_t = cfg.on_time + td_t + offset_t
            return data
        elseif nearest_week_day < week_day then
            data.state = M.State.wait_off
            data.off_cd = cfg.off_time - t + offset_t
            data.off_t = cfg.off_time + td_t + offset_t
            return data
        end

        if cfg.show_time and t < cfg.show_time then
            data.state = M.State.wait_show
            data.show_cd = cfg.show_time - t
            data.show_t = cfg.show_time + td_t
            return data
        end
        if cfg.on_time and t <= cfg.on_time then
            data.state = M.State.wait_on
            data.on_cd = cfg.on_time - t
            data.on_t = cfg.on_time + td_t
            return data
        end
        if cfg.signup_time and t <= cfg.signup_time then
            data.state = M.State.wait_signup
            data.signup_cd = cfg.signup_time - t
            data.signup_t = cfg.signup_time + td_t
            return data
        end
        if cfg.start_time and t <= cfg.start_time then
            data.state = M.State.signup
            data.start_cd = cfg.start_time - t
            data.start_t = cfg.start_time + td_t
            return data
        end
        if cfg.off_time and t <= cfg.off_time then
            --不知道比赛什么时候结束，所以比赛开始后都在比赛状态
            --报名人数 满了等待开赛，没满报名
            local function set_time()
                for i=1,86400 / cfg.start_cd do
                    data.signup_cd = cfg.signup_time - t +  cfg.start_cd * i
                    data.signup_t = cfg.signup_time + td_t +  cfg.start_cd * i
                    data.start_cd = cfg.start_time + cfg.start_cd * i - td_os_t
                    data.start_t = cfg.start_time + cfg.start_cd * i + td_t
                    data.off_cd = cfg.off_time - t
                    data.off_t = cfg.off_time + td_t
                    if data.start_cd >= 0 then
                        break
                    end
                end
            end
            set_time()
            if data.signup_cd > 0 then
                data.state = M.State.wait_signup
            else
                data.state = M.State.signup
            end
            return data
        end
        if cfg.hide_time and t <= cfg.hide_time then
            --不知道比赛什么时候结束，所以比赛开始后都在比赛状态
            local function set_time()
                local week_day = get_week_day(86400)
                local nearest_week_day = get_nearest_week_day(cfg.start_week,86400)
                data.signup_cd = cfg.signup_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.signup_t = cfg.signup_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)

                data.start_cd = cfg.start_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.start_t = cfg.start_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)
            end
            set_time()

            data.state = M.State.wait_hide
            data.hide_cd = cfg.hide_time - t
            data.hide_t = cfg.hide_time + td_t
            return data
        end
        data.state = M.State.hide
        return data
    elseif cfg.start_type == 4 then
        --定时(固定时间循环)开
        t = td_os_t
        offset_t = 86400 * (nearest_week_day - week_day)

        local signup_time
        local start_time
        if type(cfg.signup_time) == "table" then
            for i=1,#cfg.signup_time do
                signup_time = cfg.signup_time[i]
                start_time = cfg.start_time[i]
                if t < signup_time or t < start_time then
                    break
                end
            end
        else
            signup_time = cfg.signup_time
            start_time = cfg.start_time
        end
        data.signup_cd = signup_time - t + offset_t
        data.signup_t = signup_time + td_t + offset_t
        data.start_cd = start_time - t + offset_t
        data.start_t = start_time + td_t + offset_t

        if nearest_week_day > week_day then
            data.state = M.State.wait_on
            data.on_cd = cfg.on_time - t + offset_t
            data.on_t = cfg.on_time + td_t + offset_t
            return data
        elseif nearest_week_day < week_day then
            data.state = M.State.wait_off
            data.off_cd = cfg.off_time - t + offset_t
            data.off_t = cfg.off_time + td_t + offset_t
            return data
        end

        if cfg.show_time and t < cfg.show_time then
            data.state = M.State.wait_show
            data.show_cd = cfg.show_time - t
            data.show_t = cfg.show_time + td_t
            return data
        end
        if cfg.on_time and t <= cfg.on_time then
            data.state = M.State.wait_on
            data.on_cd = cfg.on_time - t
            data.on_t = cfg.on_time + td_t
            return data
        end
        if cfg.signup_time and cfg.start_time then
            local signup_time
            local start_time
            if type(cfg.signup_time) == "table" then
                for i=1,#cfg.signup_time do
                    signup_time = cfg.signup_time[i]
                    start_time = cfg.start_time[i]
                    if t < signup_time or t < start_time then
                        break
                    end
                end
            else
                signup_time = cfg.signup_time
                start_time = cfg.start_time
            end
            if t <= signup_time then
                data.state = M.State.wait_signup
                data.signup_cd = signup_time - t
                data.signup_t = signup_time + td_t
                return data
            end
            if t <= start_time then
                data.state = M.State.signup
                data.start_cd = start_time - t
                data.start_t = start_time + td_t
                return data
            end
        end
        if cfg.off_time and t <= cfg.off_time then
            local function set_time()
                local signup_time
                local start_time
                if type(cfg.signup_time) == "table" then
                    for i=1,#cfg.signup_time do
                        signup_time = cfg.signup_time[i]
                        start_time = cfg.start_time[i]
                        if 0 < signup_time or 0 < start_time then
                            break
                        end
                    end
                else
                    signup_time = cfg.signup_time
                    start_time = cfg.start_time
                end

                local week_day = get_week_day(86400)
                local nearest_week_day = get_nearest_week_day(cfg.start_week,86400)
                data.signup_cd = signup_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.signup_t = signup_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)

                data.start_cd = start_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.start_t = start_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)
            end
            set_time()
            data.state = M.State.match
            local is_over = MatchModel.GetMatchIsOver(cfg.game_id)
            if is_over and is_over == 1 then
                --比赛结束
                data.state = M.State.match_over
            end
            data.off_cd = cfg.off_time - t
            data.off_t = cfg.off_time + td_t
            return data
        end
        if cfg.hide_time and t <= cfg.hide_time then
            local function set_time()
                local signup_time
                local start_time
                if type(cfg.signup_time) == "table" then
                    for i=1,#cfg.signup_time do
                        signup_time = cfg.signup_time[i]
                        start_time = cfg.start_time[i]
                        if 0 < signup_time or 0 < start_time then
                            break
                        end
                    end
                else
                    signup_time = cfg.signup_time
                    start_time = cfg.start_time
                end

                local week_day = get_week_day(86400)
                local nearest_week_day = get_nearest_week_day(cfg.start_week,86400)
                data.signup_cd = signup_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.signup_t = signup_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)

                data.start_cd = start_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.start_t = start_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)
            end
            set_time()
            data.state = M.State.wait_hide
            data.hide_cd = cfg.hide_time - t
            data.hide_t = cfg.hide_time + td_t
            return data
        end
        data.state = M.State.hide
        return data
    elseif cfg.start_type == 5 then
        t = td_os_t
        offset_t = 86400 * (nearest_week_day - week_day)
        data.signup_cd = cfg.signup_time - t + offset_t
        data.signup_t = cfg.signup_time + td_t + offset_t
        data.start_cd = cfg.start_time - t + offset_t
        data.start_t = cfg.start_time + td_t + offset_t

        if nearest_week_day > week_day then
            data.state = M.State.wait_on
            data.on_cd = cfg.on_time - t + offset_t
            data.on_t = cfg.on_time + td_t + offset_t
            return data
        elseif nearest_week_day < week_day then
            data.state = M.State.wait_off
            data.off_cd = cfg.off_time - t + offset_t
            data.off_t = cfg.off_time + td_t + offset_t
            return data
        end

        if cfg.show_time and t < cfg.show_time then
            data.state = M.State.wait_show
            data.show_cd = cfg.show_time - t
            data.show_t = cfg.show_time + td_t
            return data
        end
        if cfg.on_time and t <= cfg.on_time then
            data.state = M.State.wait_on
            data.on_cd = cfg.on_time - t
            data.on_t = cfg.on_time + td_t
            return data
        end
        if cfg.signup_time and t <= cfg.signup_time then
            data.state = M.State.wait_signup
            data.signup_cd = cfg.signup_time - t
            data.signup_t = cfg.signup_time + td_t
            return data
        end
        if cfg.start_time and t <= cfg.start_time then
            data.state = M.State.signup
            data.start_cd = cfg.start_time - t
            data.start_t = cfg.start_time + td_t
            return data
        end
        if cfg.off_time and t <= cfg.off_time then
            --不知道比赛什么时候结束，所以比赛开始后都在比赛状态
            --报名人数 满了等待开赛，没满报名
            local function set_time()
                for i=1,86400 / cfg.start_cd do
                    data.signup_cd = cfg.signup_time - t +  cfg.start_cd * i
                    data.signup_t = cfg.signup_time + td_t +  cfg.start_cd * i
                    data.start_cd = cfg.start_time + cfg.start_cd * i - td_os_t
                    data.start_t = cfg.start_time + cfg.start_cd * i + td_t
                    data.off_cd = cfg.off_time - t
                    data.off_t = cfg.off_time + td_t
                    if data.start_cd >= 0 then
                        break
                    end
                end
            end
            set_time()
            if data.signup_cd > 0 then
                data.state = M.State.wait_signup
            else
                data.state = M.State.signup
            end
            return data
        end
        if cfg.hide_time and t <= cfg.hide_time then
            --不知道比赛什么时候结束，所以比赛开始后都在比赛状态
            local function set_time()
                local week_day = get_week_day(86400)
                local nearest_week_day = get_nearest_week_day(cfg.start_week,86400)
                data.signup_cd = cfg.signup_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.signup_t = cfg.signup_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)

                data.start_cd = cfg.start_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.start_t = cfg.start_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)
            end
            set_time()
            data.state = M.State.wait_hide
            data.hide_cd = cfg.hide_time - t
            data.hide_t = cfg.hide_time + td_t
            return data
        end
        data.state = M.State.hide
        return data
    elseif cfg.start_type == 6 then
        --定时(固定时间循环)开
        t = td_os_t
        offset_t = 86400 * (nearest_week_day - week_day)
        local signup_time
        local start_time
        if type(cfg.signup_time) == "table" then
            for i=1,#cfg.signup_time do
                signup_time = cfg.signup_time[i]
                start_time = cfg.start_time[i]
                if t < signup_time or t < start_time then
                    break
                end
            end
        else
            signup_time = cfg.signup_time
            start_time = cfg.start_time
        end
        data.signup_cd = signup_time - t + offset_t
        data.signup_t = signup_time + td_t + offset_t
        data.start_cd = start_time - t + offset_t
        data.start_t = start_time + td_t + offset_t

        if not table_is_null(cfg.fix_data) then
            local day_state,offset_day_t = M.GetFixData(cfg)
            if day_state == 0 then
                --以前
                data.state = M.State.hide
                return data
            elseif day_state == 1 then
                --今天要开赛
            elseif day_state == 2 then
                --以后要开赛
                data.state = M.State.wait_on
                data.on_cd = cfg.on_time - t + offset_day_t
                data.on_t = cfg.on_time + td_t + offset_day_t
                data.signup_cd = signup_time - t + offset_day_t
                data.signup_t = signup_time + td_t + offset_day_t
                data.start_cd = start_time - t + offset_day_t
                data.start_t = start_time + td_t + offset_day_t
                return data
            end
        end
    
        if not table_is_null(cfg.ignore_data) then
            local day_state,offset_day_t = M.GetIgnoreData(cfg)
            if day_state == 0 then
                --以前
            elseif day_state == 1 then
                --今天忽略开赛
                data.state = M.State.wait_on
                data.on_cd = cfg.on_time - t + offset_day_t
                data.on_t = cfg.on_time + td_t + offset_day_t
                data.signup_cd = signup_time - t + offset_day_t
                data.signup_t = signup_time + td_t + offset_day_t
                data.start_cd = start_time - t + offset_day_t
                data.start_t = start_time + td_t + offset_day_t
                return data
            elseif day_state == 2 then
                --以后忽略开赛
            end
        end

        if nearest_week_day > week_day then
            data.state = M.State.wait_on
            data.on_cd = cfg.on_time - t + offset_t
            data.on_t = cfg.on_time + td_t + offset_t
            return data
        elseif nearest_week_day < week_day then
            data.state = M.State.wait_off
            data.off_cd = cfg.off_time - t + offset_t
            data.off_t = cfg.off_time + td_t + offset_t
            return data
        end

        if cfg.show_time and t < cfg.show_time then
            data.state = M.State.wait_show
            data.show_cd = cfg.show_time - t
            data.show_t = cfg.show_time + td_t
            return data
        end
        if cfg.on_time and t <= cfg.on_time then
            data.state = M.State.wait_on
            data.on_cd = cfg.on_time - t
            data.on_t = cfg.on_time + td_t
            return data
        end
        if cfg.signup_time and cfg.start_time then
            local signup_time
            local start_time
            if type(cfg.signup_time) == "table" then
                for i=1,#cfg.signup_time do
                    signup_time = cfg.signup_time[i]
                    start_time = cfg.start_time[i]
                    if t < signup_time or t < start_time then
                        break
                    end
                end
            else
                signup_time = cfg.signup_time
                start_time = cfg.start_time
            end
            if t <= signup_time then
                data.state = M.State.wait_signup
                data.signup_cd = signup_time - t
                data.signup_t = signup_time + td_t
                return data
            end
            if t <= start_time then
                data.state = M.State.signup
                data.start_cd = start_time - t
                data.start_t = start_time + td_t
                return data
            end
        end
        if cfg.off_time and t <= cfg.off_time then
            local function set_time()
                local signup_time
                local start_time
                if type(cfg.signup_time) == "table" then
                    for i=1,#cfg.signup_time do
                        signup_time = cfg.signup_time[i]
                        start_time = cfg.start_time[i]
                        if 0 < signup_time or 0 < start_time then
                            break
                        end
                    end
                else
                    signup_time = cfg.signup_time
                    start_time = cfg.start_time
                end

                local week_day = get_week_day(86400)
                local nearest_week_day = get_nearest_week_day(cfg.start_week,86400)
                data.signup_cd = signup_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.signup_t = signup_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)

                data.start_cd = start_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.start_t = start_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)
            end
            set_time()
            data.state = M.State.match
            local is_over = MatchModel.GetMatchIsOver(cfg.game_id)
            if is_over and is_over == 1 then
                --比赛结束
                data.state = M.State.match_over
            end
            data.off_cd = cfg.off_time - t
            data.off_t = cfg.off_time + td_t
            return data
        end
        if cfg.hide_time and t <= cfg.hide_time then
            local function set_time()
                local signup_time
                local start_time
                if type(cfg.signup_time) == "table" then
                    for i=1,#cfg.signup_time do
                        signup_time = cfg.signup_time[i]
                        start_time = cfg.start_time[i]
                        if 0 < signup_time or 0 < start_time then
                            break
                        end
                    end
                else
                    signup_time = cfg.signup_time
                    start_time = cfg.start_time
                end

                local week_day = get_week_day(86400)
                local nearest_week_day = get_nearest_week_day(cfg.start_week,86400)
                data.signup_cd = signup_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.signup_t = signup_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)

                data.start_cd = start_time - t + 86400 + 86400 * (nearest_week_day - week_day)
                data.start_t = start_time + td_t + 86400 + 86400 * (nearest_week_day - week_day)
            end
            set_time()
            data.state = M.State.wait_hide
            data.hide_cd = cfg.hide_time - t
            data.hide_t = cfg.hide_time + td_t
            return data
        end
        data.state = M.State.hide
        return data
    end
end

function M.query_everyday_shared_award_response(data)
    if not data or not M.share_cfg_img_qys_share or M.share_cfg_img_qys_share.finish_type ~= data.type then return end
    if data.parm then
        if data.status and data.status >= 1 then
            MatchHallHintQYSPanel.Create(data.parm.cfg)
        else
            ComMatchReviveBuyPanel.CheckBuyTicket(data.parm.cfg, start_signup, start_signup)
        end
    end
    Event.Brocast("UpdateQYSShareRedHint")
end

function M.GetFixData(cfg)
    local os_t = os.time()
    local td_t = GetTodayTimeStamp()
    local check_t = os.time()
    local s1 = string.split(os.date("%Y-%m-%d", check_t),"-") 
    local s2
    local day_state
    local offset_t = 0
    for i,v in ipairs(cfg.fix_data) do
        s2 = string.split(v,"-")
        if s2[1] > s1[1] or (s2[1] == s1[1] and s2[2] > s1[2]) or (s2[1] == s1[1] and s2[2] == s1[2] and s2[3] > s1[3]) then
            --固定时间还没到，获取下一个时间段比赛
            day_state = 2
        elseif s2[1] == s1[1] and s2[2] == s1[2] and s2[3] == s1[3] then
            --在固定时间
            day_state = 1
        else
            --固定时间已过
            day_state = 0
        end
    end
    if day_state == 0 then
        --以前
    elseif day_state == 1 then
        --今天要开赛
    elseif day_state == 2 then
        --以后要开赛
        local check_day_data 
        check_day_data = function (  )
            local s1 = string.split(os.date("%Y-%m-%d", check_t),"-") 
            local s2
            for i,v in ipairs(cfg.fix_data) do
                s2 = string.split(v,"-")
                if s2[1] > s1[1] or (s2[1] == s1[1] and s2[2] > s1[2]) or (s2[1] == s1[1] and s2[2] == s1[2] and s2[3] > s1[3]) then
                    --固定时间还没到，获取下一个时间段比赛
                    while true do
                        check_t = check_t + 86400
                        local week_day = os.date("%w",check_t)
                        week_day = WeekDayTable[tonumber(week_day)]
                        if table_is_null(cfg.start_week) then
                            break
                        else
                            local b = false
                            for i,v in ipairs(cfg.start_week) do
                                if week_day == v then
                                    b = true
                                end
                            end
                            if b then
                                break
                            end
                        end  
                    end
                    check_day_data()
                    return
                end
            end
        end
        check_day_data()
        local ct = check_t
        local y = os.date("%Y", check_t)
        local m = os.date("%m", check_t)
        local d = os.date("%d", check_t)
        check_t = os.time({year=tostring(y), month=tostring(m), day=tostring(d), hour ="0", min = "0", sec = "0"})
        offset_t = check_t - td_t
    end
    return day_state,offset_t
end

function M.GetIgnoreData(cfg)
    local os_t = os.time()
    local td_t = GetTodayTimeStamp()
    local check_t = os.time()
    local offset_t = 0
    local s1 = string.split(os.date("%Y-%m-%d", check_t),"-") 
    local s2
    local day_state

    local setDayState = function (value)
       if day_state == 1 then
            return
       end
       if day_state == 2 and value ~= 1 then
            return
       end
       day_state = value
    end

    for i,v in ipairs(cfg.ignore_data) do
        s2 = string.split(v,"-")
        s1[1] = tonumber(s1[1])
        s1[2] = tonumber(s1[2])
        s1[3] = tonumber(s1[3])

        s2[1] = tonumber(s2[1])
        s2[2] = tonumber(s2[2])
        s2[3] = tonumber(s2[3])

        if s2[1] > s1[1] or (s2[1] == s1[1] and s2[2] > s1[2]) or (s2[1] == s1[1] and s2[2] == s1[2] and s2[3] > s1[3]) then
            --忽略时间还没到，获取下一个时间段比赛
            setDayState(2)
        elseif s2[1] == s1[1] and s2[2] == s1[2] and s2[3] == s1[3] then
            --在忽略时间
            setDayState(1)
        else
            --忽略时间已过
            setDayState(0)
        end
    end

    if day_state == 0 then
        --以前
    elseif day_state == 1 then
        --今天忽略开赛 以后忽略开赛
        local check_day_data 
        check_day_data = function (  )
            local s1 = string.split(os.date("%Y-%m-%d", check_t),"-") 
            local s2
            for i,v in ipairs(cfg.ignore_data) do
                s2 = string.split(v,"-")
                s1[1] = tonumber(s1[1])
                s1[2] = tonumber(s1[2])
                s1[3] = tonumber(s1[3])

                s2[1] = tonumber(s2[1])
                s2[2] = tonumber(s2[2])
                s2[3] = tonumber(s2[3])

                if s2[1] == s1[1] and s2[2] == s1[2] and s2[3] == s1[3] then
                    --固定时间还没到，获取下一个时间段比赛
                    while true do
                        check_t = check_t + 86400
                        local week_day = os.date("%w",check_t)
                        week_day = WeekDayTable[tonumber(week_day)]
                        if table_is_null(cfg.start_week) then
                            break
                        else
                            local b = false
                            for i,v in ipairs(cfg.start_week) do
                                if week_day == v then
                                    b = true
                                end
                            end
                            if b then
                                break
                            end
                        end  
                    end
                    check_day_data()
                    return
                end
            end
        end
        check_day_data()
        local y = os.date("%Y", check_t)
        local m = os.date("%m", check_t)
        local d = os.date("%d", check_t)
        check_t = os.time({year=tostring(y), month=tostring(m), day=tostring(d), hour ="0", min = "0", sec = "0"})
        offset_t = check_t - td_t
    elseif day_state == 2 then

    end
    return day_state,offset_t
end

return M