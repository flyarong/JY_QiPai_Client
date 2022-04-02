-- 创建时间:2019-05-29
-- 捕鱼相关系统
-- 集粽得礼、

local basefunc = require "Game/Common/basefunc"
local config = SysFishingManager.config
local fish_hall_config = SysFishingManager.fish_hall_config
local fishmatch_ui = SysFishingManager.fishmatch_ui

FishingManager = {}

local C = FishingManager
local lister
local this

local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
end

function C.Init()
	FishingManager.Exit()
	print("<color=red>初始化捕鱼相关系统</color>")
    this = FishingManager
    MakeLister()
    AddLister()
    C.InitConfig()
end
function C.Exit()
	if this then
    RemoveLister()
		this = nil
	end
end
function C.InitConfig()
    C.Config = {}
    C.Config.zz_list = {}
    C.Config.zz_map = {}
    for k,v in ipairs(config.config) do
        C.Config.zz_list[#C.Config.zz_list + 1] = v
        C.Config.zz_map[v.id] = v
    end
    C.Config.zz_parm = {}
    for k,v in ipairs(config.pram_config) do
        C.Config.zz_parm[v.key] = v.value
    end

    C.Config.fish_hall_list = {}
    C.Config.fish_hall_map = {}
    for k,v in ipairs(fish_hall_config.game) do
        C.Config.fish_hall_list[#C.Config.fish_hall_list + 1] = v
        C.Config.fish_hall_map[v.game_id] = v
    end

    C.Config.fish_match_map = {}
    C.Config.fish_match_list = {}
    C.Config.fish_match_award = {}
    local match_award = C.Config.fish_match_award

    for k,v in ipairs(fishmatch_ui.config) do
        C.Config.fish_match_list[#C.Config.fish_match_list + 1] = v
        C.Config.fish_match_map[v.game_id] = v
    end    
    for k,v in ipairs(fishmatch_ui.award) do
        if not match_award[v.award_id] then
            match_award[v.award_id] = {}
        end
        match_award[v.award_id][#match_award[v.award_id] + 1] = v
    end
end

C.ZongziState = {
	ZZ_NoActivate = "未激活",
	ZZ_Activate = "激活",
}
-- 西瓜状态
function C.GetZongziState()
    local s = FishingManager.Config.zz_parm.show_begin_time
    local e = FishingManager.Config.zz_parm.show_end_time
    local cur = os.time()
    if cur < s then
        return C.ZongziState.ZZ_NoActivate
    elseif cur > e then
        return C.ZongziState.ZZ_NoActivate
    else
        return C.ZongziState.ZZ_Activate
    end
end
-- 是否有奖励可领取
function C.IsGetAward()
    local zz = GameItemModel.GetItemCount("prop_zongzi")
    if zz >= C.Config.zz_list[1].zz_num then
        return true
    end
    return false
end

-- 快速开始的游戏配置
function C.GetRapidBeginGameConfig()
    local num = MainModel.UserInfo.jing_bi + (MainModel.UserInfo.fish_coin or 0)
    for k,v in ipairs(C.Config.fish_hall_list) do
        if (not v.recommend_min or v.recommend_min <= num) and (not v.recommend_max or num <= v.recommend_max) then
            return v
        end
    end
end

function C.CheckCanEnter(id)
    if not id then return false,1 end
    local all_score = MainModel.UserInfo.jing_bi + (MainModel.UserInfo.fish_coin or 0)
    local v = C.Config.fish_hall_map[id]
    if v then
        return C.CheckRecommend(v.enter_min,v.enter_max, all_score)
    end
    return false, 1
end

function C.CheckRecommend(gold_min,gold_max, gold)
    if gold_min and gold_max then
        if gold >= gold_min and gold <= gold_max then
            return true
        elseif gold < gold_min then
            return false, 1
        elseif gold > gold_max then
            return false, 2
        end
    elseif gold_min and not gold_max then
        if gold >= gold_min then
            return true
        else
            return false, 1
        end
    elseif not gold_min and gold_max then
        if gold <= gold_max then
            return true
        else
            return false, 2
        end
    end
    return false, 1
end

function C.SignFishing(config)
    if config.asset_type == "obj_fish_free_bullet" or
        config.asset_type == "obj_fish_power_bullet" or
        config.asset_type == "obj_fish_crit_bullet" then
        dump(config, "<color=yellow>捕鱼道具</color>")
        local g_id = tonumber(config.game_id)
        --报名
        local is_can, result = FishingManager.CheckCanEnter(g_id)
        dump(is_can, "<color=yellow>ic_canxxx..............</color>")
        dump(result, "<color=yellow>icresult_canxxx..............</color>")
        if is_can then
            GameManager.CommonGotoScence({gotoui = "game_Fishing",p_requset = {id = g_id},goto_scene_parm={game_id = g_id,open_bag = 1}})
        else        
            if result == 1 then
                LittleTips.Create("您的鲸币不足，请购买鲸币")
                PayPanel.Create(GOODS_TYPE.jing_bi)
            elseif result == 2 then
                LittleTips.Create("你的太富有了，请前往对应场")
            end
        end
    end
end

-- 捕鱼比赛相关
-- 获取最近的比赛 ID
function C.GetRecentlyGameID()
    local t = C.CalcMatchTime(C.Config.fish_match_list)
    return t.game_id
end

function C.GetFishingMatchZHGameID()
    if C.Config.fish_match_list then
        return C.Config.fish_match_list[#C.Config.fish_match_list].game_id
    end
end
-- 今天是否有捕鱼比赛
function C.IsTodayHaveMatch()
    local t = C.CalcMatchTime(C.Config.fish_match_list)

    local cur_t = os.time()
    local newtime = tonumber(os.date("%Y%m%d", cur_t))
    local oldtime = tonumber(os.date("%Y%m%d", t.start_time))

    if newtime == oldtime and cur_t <= t.over_time then
        return true
    else
        return false
    end
end

function C.GetCurDjsToConfig()
    local t = C.CalcMatchTime(C.Config.fish_match_list)
    local cc = C.Config.fish_match_map[t.game_id]
    cc = basefunc.deepcopy(cc)
    cc.start_time = t.start_time
    cc.over_time = t.over_time
    return cc
end

function C.GetLastDjsToConfig()
    local t = C.CalcLastMatchTime(C.Config.fish_match_list)
    local cc = C.Config.fish_match_map[t.game_id]
    cc = basefunc.deepcopy(cc)
    cc.start_time = t.start_time
    cc.over_time = t.over_time
    return cc
end

function C.GetGameIDToConfig(game_id)
    return C.GetCurDjsToConfig()
end

function C.GetGameIDToAward(game_id)
    local cfg = C.GetGameIDToConfig(game_id)
    return C.Config.fish_match_award[cfg.award_id]
end
-- 获取对应排名的奖励
-- 只能使用不能修改表的内容
function C.GetAwardByRank(game_id, rank)
    local cfg = C.GetGameIDToAward(game_id)
    for k,v in ipairs(cfg) do
        if (v.min_rank == -1 or rank >= v.min_rank) and (v.max_rank == -1 or rank <= v.max_rank) then
            return v.award_desc, v.award_icon
        end
    end
end
function C.GetCfgByRank(game_id, rank)
    local cfg = C.GetGameIDToAward(game_id)
    for k,v in ipairs(cfg) do
        if (v.min_rank == -1 or rank >= v.min_rank) and (v.max_rank == -1 or rank <= v.max_rank) then
            return v
        end
    end
end
-- 返回比赛消耗满足的道具
function C.GetMatchCanUseTool(game_id)
    local cfg = C.GetGameIDToConfig(game_id)
    local itemkey = cfg.enter_condi_itemkey
    local item_count = cfg.enter_condi_item_count
    for k,v in ipairs(itemkey) do
        if GameItemModel.GetItemCount(v) >= item_count[k] then
            return itemkey[k], item_count[k]
        end
    end
end
-- 是否能报名
function C.CheckIsCanSignup(game_id)
    local config = C.GetGameIDToConfig(game_id)
    local itemKeys = config.enter_condi_itemkey
    local itemCost = config.enter_condi_item_count
    for i = 1, #itemKeys do
        if GameItemModel.GetItemCount(itemKeys[i]) >= itemCost[i] then
            return true
        end
    end
    return false
end

function C.CacheRankData(data, index)
    if not this.rank_data then
        this.rank_data = {}
    end
    this.rank_data[index] = data
end
function C.GetRankData(index)
    if not this.rank_data then
        return
    end
    return this.rank_data[index]
end

function C.CalcMatchCfg(cfg,match_type)
    local _cfg
    if match_type then
        for i,v in ipairs(cfg) do
            if v.match_type == match_type then
                _cfg = v
                return _cfg
            end
        end
    end
    _cfg = cfg[1]
    return _cfg
end

-- 捕鱼比赛相关
function C.CalcMatchTime(cfg,match_type)
    -- start_time = 1599049800,  2020/9/2 20:30:0
    -- over_time = 1599051600,   2020/9/2 21:0:0
    -- show_time = 1598889600,   2020/9/1 0:0:0
    -- hide_time = 1599062399,   2020/9/2 23:59:59
    -- "300+86100#173100+258900#345900+431700#518700+604500"
    -- 2,73800,75600,4,73800,75600,6,73800,75600,
    local _cfg = C.CalcMatchCfg(cfg,match_type)

    local now = MainModel.GetCurTime()
    local onet = StringHelper.getThisWeekMonday() -- 本周周一的时间戳
    local list = _cfg.time_data -- {1,73800,75600,3,73800,75600,5,73800,75600,} {2,73800,75600,4,73800,75600,6,73800,75600,}
    local end_n = #list / 3
    local ignore_data = _cfg.ignore_data
    local fix_data = _cfg.fix_data
    local t
    for i = 1, end_n do
        local start_time = onet + (list[ (i-1)*3+1 ] - 1) * 86400 + list[ (i-1)*3+2 ]
        local over_time  = onet + (list[ (i-1)*3+1 ] - 1) * 86400 + list[ (i-1)*3+3 ]
        if now < over_time then
            t = {}
            t.start_time = start_time
            t.over_time = over_time
            break
        end
    end
    if not t then
        t = {}
        t.start_time = onet + (list[ 1 ] - 1) * 86400 + list[ 2 ] + 7*86400
        t.over_time  = onet + (list[ 1 ] - 1) * 86400 + list[ 3 ] + 7*86400
    end
    dump(t, "<color=green><size=16>|||||||||| fishing match data</size></color>")
    local fix_t
    local check_fix_data
    check_fix_data = function (  )
        if not table_is_null(fix_data) then
            local pp = os.date("%Y-%m-%d", t.start_time)
            for k,v in ipairs(fix_data or {}) do
                if pp == v then
                    t.game_id = _cfg.game_id
                    fix_t = t
                    dump(t, "<color=green><size=16>|||||||||| fishing match data 固定日期</size></color>")
                    return t
                end
            end
            local cur_pp = os.date("%Y-%m-%d", now)
            local s1 = string.split(pp,"-") 
            local s2
            for k,v in ipairs(fix_data or {}) do
                s2 = string.split(v,"-")
                if s2[1] > s1[1] or (s2[1] == s1[1] and s2[2] > s1[2]) or (s2[1] == s1[1] and s2[2] == s1[2] and s2[3] > s1[3]) then
                    --固定时间还没到，获取下一个时间段比赛
                    local week_day = os.date("%w",t.start_time)
                    week_day = tonumber(week_day)
                    if week_day == 0 then
                        week_day = 7
                    end

                    local ct = t.start_time
                    local y = os.date("%Y", ct)
                    local m = os.date("%m", ct)
                    local d = os.date("%d", ct)
                    ct = os.time({year=tostring(y), month=tostring(m), day=tostring(d), hour ="0", min = "0", sec = "0"})

                    local offset = 0
                    local wd = 1
                    for i=1, end_n do
                        wd = list[ (i-1)*3+1 ]
                        if wd > week_day then
                            offset = wd - week_day
                            t.start_time = ct + offset * 86400 + list[ (i-1)*3+2 ]
                            t.over_time = ct + offset * 86400 + list[ (i-1)*3+3 ]
                            check_fix_data()
                            return
                        end
                    end

                    local i = 1
                    wd = list[ (i-1)*3+1 ]
                    offset = wd - week_day + 7
                    t.start_time = ct + offset * 86400 + list[ (i-1)*3+2 ]
                    t.over_time = ct + offset * 86400 + list[ (i-1)*3+3 ]
                    check_fix_data()
                    return
                end
            end
            return
        end
    end

    check_fix_data()
    dump(fix_t, "<color=green><size=16>|||||||||| fishing match data 确定固定日期</size></color>")
    if not table_is_null(fix_t) then 
        return fix_t 
    end

    local check_ignore_data 
    check_ignore_data = function()
        local pp = os.date("%Y-%m-%d", t.start_time)
        --忽略日期
        if not table_is_null(ignore_data) then
            for k,v in ipairs(ignore_data or {}) do
                if pp == v then
                    dump(t, "<color=green><size=16>|||||||||| fishing match data 忽略日期</size></color>")
                    print("<color=yellow>本次比赛被忽略，计算下一场比赛</color>")
                    local week_day = os.date("%w",t.start_time)
                    week_day = tonumber(week_day)
                    if week_day == 0 then
                        week_day = 7
                    end

                    local ct = t.start_time
                    local y = os.date("%Y", ct)
                    local m = os.date("%m", ct)
                    local d = os.date("%d", ct)
                    ct = os.time({year=tostring(y), month=tostring(m), day=tostring(d), hour ="0", min = "0", sec = "0"})

                    local offset = 0
                    local wd = 1
                    for i=1, end_n do
                        wd = list[ (i-1)*3+1 ]
                        if wd > week_day then
                            offset = wd - week_day
                            t.start_time = ct + offset * 86400 + list[ (i-1)*3+2 ]
                            t.over_time = ct + offset * 86400 + list[ (i-1)*3+3 ]
                            check_ignore_data()
                            return
                        end
                    end

                    local i = 1
                    wd = list[ (i-1)*3+1 ]
                    offset = wd - week_day + 7
                    t.start_time = ct + offset * 86400 + list[ (i-1)*3+2 ]
                    t.over_time = ct + offset * 86400 + list[ (i-1)*3+3 ]
                    check_ignore_data()
                    return
                end
            end
        end
    end

    check_ignore_data()
    
    t.game_id = _cfg.game_id
    dump(t, "<color=green><size=16>|||||||||| fishing match data</size></color>")
    return t
end
function C.CalcLastMatchTime(cfg,match_type)
    -- start_time = 1599049800,  2020/9/2 20:30:0
    -- over_time = 1599051600,   2020/9/2 21:0:0
    -- show_time = 1598889600,   2020/9/1 0:0:0
    -- hide_time = 1599062399,   2020/9/2 23:59:59
    -- "300+86100#173100+258900#345900+431700#518700+604500"
    -- 2,73800,75600,4,73800,75600,6,73800,75600,
    local _cfg = C.CalcMatchCfg(cfg,match_type)
    local now = MainModel.GetCurTime()
    local onet = StringHelper.getThisWeekMonday() -- 本周周一的时间戳
    local list = _cfg.time_data -- {2,73800,75600,4,73800,75600,6,73800,75600,}
    local end_n = #list / 3
    local ignore_data = _cfg.ignore_data
    local fix_data = _cfg.fix_data
    local t
    for i = end_n, 1, -1 do
        local start_time = onet + (list[ (i-1)*3+1 ] - 1) * 86400 + list[ (i-1)*3+2 ]
        local over_time  = onet + (list[ (i-1)*3+1 ] - 1) * 86400 + list[ (i-1)*3+3 ]
        dump(os.date("!*t", over_time))
        if now >= over_time then
            t = {}
            t.start_time = start_time
            t.over_time = over_time
            break
        end
    end
    if not t then
        t = {}
        t.start_time = onet + (list[ (end_n-1)*3+1 ] - 1) * 86400 + list[ (end_n-1)*3+2 ] - 7*86400
        t.over_time  = onet + (list[ (end_n-1)*3+1 ] - 1) * 86400 + list[ (end_n-1)*3+3 ] - 7*86400
    end
    dump(t, "<color=green><size=16>|||||||||| fishing match data</size></color>")
    local fix_t
    local check_fix_data
    check_fix_data = function (  )
        if not table_is_null(fix_data) then
            local pp = os.date("%Y-%m-%d", t.start_time)
            for k,v in ipairs(fix_data or {}) do
                if pp == v then
                    t.game_id = _cfg.game_id
                    fix_t = t
                    dump(t, "<color=green><size=16>|||||||||| fishing match data 固定日期</size></color>")
                    return t
                end
            end
            local cur_pp = os.date("%Y-%m-%d", now)
            local s1 = string.split(pp,"-") 
            local s2
            for k,v in ipairs(fix_data or {}) do
                s2 = string.split(v,"-")
                if s2[1] > s1[1] or (s2[1] == s1[1] and s2[2] > s1[2]) or (s2[1] == s1[1] and s2[2] == s1[2] and s2[3] > s1[3]) then
                    --固定时间还没到，获取下一个时间段比赛
                    local week_day = os.date("%w",t.start_time)
                    week_day = tonumber(week_day)
                    if week_day == 0 then
                        week_day = 7
                    end

                    local ct = t.start_time
                    local y = os.date("%Y", ct)
                    local m = os.date("%m", ct)
                    local d = os.date("%d", ct)
                    ct = os.time({year=tostring(y), month=tostring(m), day=tostring(d), hour ="0", min = "0", sec = "0"})

                    local offset = 0
                    local wd = 1
                    for i=1, end_n do
                        wd = list[ (i-1)*3+1 ]
                        if wd > week_day then
                            offset = wd - week_day
                            t.start_time = ct + offset * 86400 + list[ (i-1)*3+2 ]
                            t.over_time = ct + offset * 86400 + list[ (i-1)*3+3 ]
                            check_fix_data()
                            return
                        end
                    end

                    local i = 1
                    wd = list[ (i-1)*3+1 ]
                    offset = wd - week_day + 7
                    t.start_time = ct + offset * 86400 + list[ (i-1)*3+2 ]
                    t.over_time = ct + offset * 86400 + list[ (i-1)*3+3 ]
                    check_fix_data()
                    return
                end
            end
            return
        end
    end

    check_fix_data()
    dump(fix_t, "<color=green><size=16>|||||||||| fishing match data 确定固定日期</size></color>")
    if not table_is_null(fix_t) then 
        return fix_t 
    end

    local check_ignore_data 
    check_ignore_data = function()
        local pp = os.date("%Y-%m-%d", t.start_time)
        --忽略日期
        if not table_is_null(ignore_data) then
            for k,v in ipairs(ignore_data or {}) do
                if pp == v then
                    dump(t, "<color=green><size=16>|||||||||| fishing match data 忽略日期</size></color>")
                    print("<color=yellow>本次比赛被忽略，计算下一场比赛</color>")
                    local week_day = os.date("%w",t.start_time)
                    if week_day == 0 then
                        week_day = 7
                    end

                    local ct = t.start_time
                    local y = os.date("%Y", ct)
                    local m = os.date("%m", ct)
                    local d = os.date("%d", ct)
                    ct = os.time({year=tostring(y), month=tostring(m), day=tostring(d), hour ="0", min = "0", sec = "0"})

                    local offset = 0
                    local wd = 1
                    for i=1,#end_n do
                        wd = list[ (i-1)*3+1 ]
                        if wd < week_day then
                            offset = wd - week_day
                            t.start_time = ct + offset * 86400 + list[ (i-1)*3+2 ]
                            t.over_time = ct + offset * 86400 + list[ (i-1)*3+3 ]
                            check_ignore_data()
                            return
                        end
                    end

                    local i = 1
                    wd = list[ (i-1)*3+1 ]
                    offset = wd - week_day - 7
                    t.start_time = ct + offset * 86400 + list[ (i-1)*3+2 ]
                    t.over_time = ct + offset * 86400 + list[ (i-1)*3+3 ]
                    check_ignore_data()
                    return
                end
            end
        end
    end

    check_ignore_data()

    t.game_id = _cfg.game_id
    dump(t, "<color=green><size=16>|||||||||| fishing match data</size></color>")
    return t
end