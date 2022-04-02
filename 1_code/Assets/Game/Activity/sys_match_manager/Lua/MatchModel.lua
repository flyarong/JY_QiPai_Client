MatchModel = {}
local M = MatchModel
local match_hall_config = SysMatchManager.match_hall_config
local match_game_config = SysMatchManager.match_game_config
local match_type_config = SysMatchManager.match_type_config
local match_award_config = SysMatchManager.match_award_config
local this
M.MatchType = {}
M.GameType = {}

local lister
local function AddMsgListener()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function MakeLister()
    lister = {}
    lister["get_match_discount_status_response"] = M.get_match_discount_status_response
    lister["nor_mg_req_specified_signup_num_response"] = M.nor_mg_req_specified_signup_num_response
    lister["query_now_match_is_over_response"] = M.query_now_match_is_over_response
    lister["ExitScene"] = M.OnExitScene
    lister["EnterScene"] = M.OnEnterScene
end

local function RemoveListener()
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
    lister = {}
end

function M.OnExitScene()
    M.ClearSignupData()
end

function M.OnEnterScene()
    
end

local is_query_signup
function M.QuerySignupData(cfg)
    if not cfg then return end
    is_query_signup = true
    local msg_list = {}
    msg_list[#msg_list + 1] = {msg="nor_mg_req_specified_signup_num", data = {id = cfg.game_id}}
    msg_list[#msg_list + 1] = {msg="get_match_discount_status", data = {id = cfg.game_id}}
    if cfg.start_type == 2 then
        msg_list[#msg_list + 1] = {msg="query_now_match_is_over", data = {id = cfg.game_id}}
    end
    GameManager.SendMsgList("match_model_" .. cfg.game_id , msg_list)
end

function M.RandomReqSignupNum(game_id)
    if not is_query_signup then return end
    local t = 1 --math.random(200, 400) * 0.01
    local timerSignup = Timer.New(function ()
        Network.SendRequest("nor_mg_req_specified_signup_num", {id = game_id})
    end, t, 1, true)
    timerSignup:Start()
end

function M.get_match_discount_status_response(_,data)
    dump(data,"<color=yellow>get_match_discount_status_response</color>")
    if data.result ~= 0 then return end
    if not data.id then return end
    data.game_id = data.id
    this.data = this.data or {}
    this.data.discount_data = this.data.discount_data or {}
    this.data.discount_data[data.game_id] = {
        list = {},
        hash = {},
    }
    this.data.discount_data[data.game_id].list = data.discount_data
    for i,v in ipairs(data.discount_data) do
        this.data.discount_data[data.game_id].hash[v.discount_condition] = v.discount_count
    end
    Event.Brocast("model_get_match_discount_status",data)
end

function M.nor_mg_req_specified_signup_num_response(_,data)
    -- dump(data,"<color=green>nor_mg_req_specified_signup_num_response</color>")
    local cfg = M.GetGameCfg(data.id)
    if data.result == 0 then
        this.data.signup_num = this.data.signup_num or {}
        if data.signup_num then
            if cfg.max_people and data.signup_num > cfg.max_people then
                data.signup_num = cfg.max_people
            end
            this.data.signup_num[data.id] = data.signup_num
        else
            --没有报名人数 1不在报名时间内，2在报名时间内已经报满了
            local state = MatchLogic.GetMatchState(cfg)
            if state.state == MatchLogic.State.signup then
                local max_people = cfg.max_people
                if not cfg.max_people then max_people = 0 end
                data.signup_num = max_people
                this.data.signup_num[data.id] = max_people
            else
                data.signup_num = 0
                this.data.signup_num[data.id] = 0
            end
        end
    end
    Event.Brocast("model_nor_mg_req_specified_signup_num",data)
end

function M.query_now_match_is_over_response(_,data)
    dump(data,"<color=green>query_now_match_is_over_response</color>")
    if data.result == 0 then
        this.data.is_over = this.data.is_over or {}
        this.data.is_over[data.id] = data.status
    end
end

function M.GetMatchIsOver(game_id)
    if not game_id or not this or not this.data or not this.data.is_over or not this.data.is_over[game_id] then return end
    return this.data.is_over[game_id]
end

function M.GetSignupNumByGameID(game_id)
    if not game_id or not this or not this.data or not this.data.signup_num or not this.data.signup_num[game_id] then return end
    return this.data.signup_num[game_id]
end

function M.SetSignupNumByGameID(game_id,c)
    if not game_id or not this or not this.data or not this.data.signup_num or not this.data.signup_num[game_id] then return end
    c = c or 0
    this.data.signup_num[game_id] = c
end

function M.GetDiscountStatusByGameID(game_id)
    if not game_id or not this or not this.data or not this.data.discount_data or table_is_null(this.data.discount_data[game_id]) then return end
    return this.data.discount_data[game_id]
end

function M.GetShareCountByGameID(game_id)
    if not game_id or not this or not this.data or not this.data.discount_data or not this.data.discount_data[game_id] or not this.data.discount_data[game_id].hash or not this.data.discount_data[game_id].hash.free_share then return 0 end
    return this.data.discount_data[game_id].hash.free_share
end

function M.GetADCountByGameID(game_id)
    if not game_id or not this or not this.data or not this.data.discount_data or not this.data.discount_data[game_id] or not this.data.discount_data[game_id].hash or not this.data.discount_data[game_id].hash.free_ad then return 0 end
    return this.data.discount_data[game_id].hash.free_ad
end

function M.ClearSignupData()
    is_query_signup = nil
    if this then
        this.data.discount_data = {}
        this.data.signup_num = {}
    end
end

function M.Init()
    this = M
    this.data = {}
    MakeLister()
    AddMsgListener()
    this.InitConfig()
    return this
end

function M.Exit()
    if this then
        this = nil
    end
end

function M.InitConfig()
    this.cfg = {}
    M.MatchType = {}
    M.HallType = {}
    this.cfg.hall = {}
    this.cfg.hall_type = {}
    if match_hall_config.game then
        for i,v in pairs(match_hall_config.game or {}) do
            if v.is_on_off == 1 then
                --大厅配置
                this.cfg.hall[v.id] = v
                this.cfg.hall_type[v.hall_type] = v

                if not M.HallType[v.hall_type] then
                    M.HallType[v.hall_type] = v.hall_type
                end
            end
        end
    end

    this.cfg.game = {}
    this.cfg.match_type = {}
    this.cfg.match_hall_type = {}
    for match_type,v1 in pairs(match_game_config) do
        if not M.MatchType[match_type] then
            M.MatchType[match_type] = match_type
        end

        for k2,match_game in pairs(v1) do
            if match_game.is_on_off == 1 then
                this.cfg.game[match_game.game_id] = match_game

                this.cfg.match_type[match_type] = this.cfg.match_type[match_type] or {}
                this.cfg.match_type[match_type][match_game.game_id] = match_game

                this.cfg.match_hall_type[match_game.hall_type] = this.cfg.match_hall_type[match_game.hall_type] or {}
                this.cfg.match_hall_type[match_game.hall_type][match_game.game_id] = match_game

                if match_type_config[match_type] then
                    for k,v in pairs(match_type_config[match_type]) do
                        if v.type_id == match_game.type_id then
                            for _k,_v in pairs(v) do
                                if not this.cfg.game[match_game.game_id][_k] then
                                    this.cfg.game[match_game.game_id][_k] = _v
                                end
                                if not this.cfg.match_type[match_type][match_game.game_id][_k] then
                                    this.cfg.match_type[match_type][match_game.game_id][_k] = _v
                                end
                                if not this.cfg.match_hall_type[match_game.hall_type][match_game.game_id][_k] then
                                    this.cfg.match_hall_type[match_game.hall_type][match_game.game_id][_k] = _v
                                end
                            end
                            break
                        end
                    end
                end

                if match_award_config[match_type] then
                    local award = {}
                    for i,v in ipairs(match_award_config[match_type]) do
                        if match_game.award_id == v.award_id then
                            table.insert(award,v)
                        end
                    end
                    if not table_is_null(award) then
                        this.cfg.game[match_game.game_id].award = award
                        this.cfg.match_type[match_type][match_game.game_id].award = award
                        this.cfg.match_hall_type[match_game.hall_type][match_game.game_id].award = award
                    end
                end
            end
        end
    end
    -- for k,v in pairs(this.cfg) do
    --     -- dump(v, "<color=yellow>比赛场配置》》》》》》》》》》》》》》》》》》》》</color>" .. k)
    --     -- for k1,v1 in pairs(v) do
    --     --     dump(v1, "<color=yellow>比赛场配置》》》》》》》》》》》》》》》》》》》》</color>" .. k1)
    --     -- end
    -- end
end

function M.GetHall()
    return this.cfg.hall
end

function M.GetHallTypeCfg()
    return this.cfg.hall_type
end

function M.SetCurHallType(mt)
    this.data.hall_type = mt
end

function M.GetCurHallType()
    if this.data.hall_type then
        return this.data.hall_type
    end
    return M.HallType.fls
end

--比赛场
function M.SetCurrGameID(game_id)
    this.data.game_id = game_id
end

function M.GetCurrGameID()
    return this.data.game_id
end

function M.GetGameCfg(game_id)
    if not this then return end
    if game_id then
        return this.cfg.game[game_id]
    end
    return this.cfg.game
end

function M.GetMatchHallTypeCfg(hall_type)
    if not this then return end
    if hall_type then
        return this.cfg.match_hall_type[hall_type]
    end
    return this.cfg.match_hall_type
end

function M.GetCurStartType()
    if not this.data.game_id then return 1 end
    return this.cfg.game[this.data.game_id].start_type
end

--比赛类型是否是人满即开
function M.CheckStartTypeIsRMJK()
    local st = M.GetCurStartType()
    if st == 1 or st == 5 then
        --人满即开赛
        return true
    end
    return false
end

-- 获取对应排名的奖励
function M.GetAwardByRank(game_id, rank)
    if not game_id or not rank then return end
    if not this.cfg.game[game_id] then return end
    for k,v in ipairs(this.cfg.game[game_id].award) do
        if (v.min_rank == -1 or rank >= v.min_rank) and (v.max_rank == -1 or rank <= v.max_rank) then
            return v.award_desc, v.award_icon
        end
    end
end

function M.GetSceneByGameID(game_id)
    local sn = "game_DdzMatch"
    if not game_id or not this.cfg.game[game_id] then return end
    local game_type = this.cfg.game[game_id].game_type
    local gttable = {
        ddz = "game_DdzMatch",
        mj = "game_MjXzMatch3D",
        pdk = "game_DdzPDKMatch",
    }
    sn = gttable[game_type]
    if not sn then
        sn = "game_DdzMatch"
    end
    return GameConfigToSceneCfg[sn].SceneName
end

-- 是否能报名
function M.CheckSignup(game_id)
    if not game_id or not this.cfg.game[game_id] then return end
    local signup_item = this.cfg.game[game_id].signup_item
    local signup_item_count = this.cfg.game[game_id].signup_item_count
    if table_is_null(signup_item) or table_is_null(signup_item_count) or #signup_item ~= #signup_item_count then return end
    for i = 1, #signup_item do
        if signup_item[i] == "jing_bi" then
            --有鲸币就可以报名
            return true
        end
        if GameItemModel.GetItemCount(signup_item[i]) >= signup_item_count[i] then
            return true
        end
    end
    return false
end

--报名道具使用优先级从1开始
function M.GetSignupItem(game_id,oney)
    if not M.CheckSignup(game_id) then return end
    local _signup_item = {}
    local _signup_item_count = {}

    local signup_item = this.cfg.game[game_id].signup_item
    local signup_item_count = this.cfg.game[game_id].signup_item_count
    if table_is_null(signup_item) or table_is_null(signup_item_count) or #signup_item ~= #signup_item_count then return end
    for i = 1, #signup_item do
        if signup_item[i] == "jing_bi" then
            --鲸币不够可以购买
            table.insert(_signup_item,signup_item[i])
            table.insert(_signup_item_count,signup_item_count[i])
        elseif GameItemModel.GetItemCount(signup_item[i]) >= signup_item_count[i] then
            table.insert(_signup_item,signup_item[i])
            table.insert(_signup_item_count,signup_item_count[i])
        end
    end
    return _signup_item,_signup_item_count
end

--获取指定类型最近的比赛配置 仅对start_type == 2 千元赛类型的比赛
function M.GetRecentlyCFGByType(t)
    local now = os.time()
    if this.cfg.match_type[t] then
        local cfg_list = {}
        for i,v in pairs(this.cfg.match_type[t]) do
            table.insert( cfg_list,v)

        end
        table.sort( cfg_list,function(a, b)
            return a.game_id < b.game_id
        end )
        
        for i,v in ipairs(cfg_list) do
            if v.start_type == 2 then
                --定时开
                if now >= v.show_time and now <= v.start_time then
                    return v
                elseif now < v.show_time then
                    return v
                end
            elseif v.start_type == 6 then
                local week = GetWeekDay()
                if v.start_week then
                    for i1,v1 in ipairs(v.start_week) do
                        if v1 == week then
                            return v
                        end 
                    end
                else
                    return v
                end
            end
        end
    end
    print("<color=red>EEEEEEEEEEE M  GetRecentlyGameID </color>")
end

--今天是否有指定类型的比赛 仅对start_type == 2 千元赛类型的比赛
function M.IsTodayHaveMatchByType(t)
    local game_cfg = M.GetRecentlyCFGByType(t)
    if game_cfg then
        if game_cfg.start_type == 2 then
            local cur_t = os.time()
            local newtime = tonumber(os.date("%Y%m%d", cur_t))
            local oldtime = tonumber(os.date("%Y%m%d", game_cfg.start_time))
            if newtime == oldtime and cur_t <= game_cfg.start_time then
                return true
            else
                return false
            end
        elseif game_cfg.start_type == 6 then
            if not table_is_null(game_cfg.ignore_data) then
                local curTime = string.split(os.date("%Y-%m-%d", check_t),"-") 
                local curTimeTab = {[1] = tonumber(curTime[1]), [2] = tonumber(curTime[2]), [3] = tonumber(curTime[3])}
                for i = 1, #game_cfg.ignore_data do
                    local ignoreTime = string.split(game_cfg.ignore_data[i], "-")  
                    local ignoreTimeTab = {[1] = tonumber(ignoreTime[1]), [2] = tonumber(ignoreTime[2]), [3] = tonumber(ignoreTime[3])}
                    if curTimeTab[1] == ignoreTimeTab[1] and curTimeTab[2] == ignoreTimeTab[2] and curTimeTab[3] == ignoreTimeTab[3] then
                        return false
                    end
                end
            end
            return true
        end
    else
        return false
    end
end

function M.QueryNowMatchStatus(pram)
    Network.SendRequest("query_now_match_status", nil, "查询请求", function (data)
        dump(data,"<color=green>query_now_match_status</color>")
        if data.result == 0 then
            M.data.now_match_game_id = data.id
            if pram and pram.hint and not table_is_null(data.id) then
                local cfg = M.GetGameCfg(data.id[1])
                local match_name = cfg.ui_match_name or ""
                local pre = HintPanel.Create(2,"您报名的" .. match_name .."即将开赛，请进行比赛！",function ()
                    GameManager.GotoUI({gotoui = GameConfigToSceneCfg.game_MatchHall.SceneName})
                end)
                pre:SetButtonText(nil, "前往比赛")
            end
        end
    end)
end

function M.GetNowMatchGameID(game_id)
    if not game_id then
        if not table_is_null(M.data.now_match_game_id) then 
            return M.data.now_match_game_id
        end
    else
        for i,v in ipairs(M.data.now_match_game_id or {}) do
            if v == game_id then
                return v
            end
        end
    end
end

--是否有预赛
function M.CheckIsTryouts(game_id)
    if not game_id then return end
    local gc = M.GetGameCfg(game_id)
    if gc.tryouts and gc.tryouts == 1 then
        return true
    end
    return false
end

function M.GetMatchToShow(hall_type)
    local cfg = {}
    local t = os.time()
    local game_cfg = MatchModel.GetMatchHallTypeCfg(hall_type)
    for k,v in pairs(game_cfg or {}) do
        if v.start_type == 2 then
            --固定时间开赛 (提前10分钟的比赛放入比赛列表中用于稍后显示)
            if v.show_time - 3600 < t and v.hide_time > t then
                cfg[#cfg + 1] = v
            end
        else
            cfg[#cfg + 1] = v
        end
    end
    return cfg
end