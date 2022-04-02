-- 创建时间:2018-10-15

local free_hall_config = SysFreeManager.free_hall_config
local freestyle_ui = SysFreeManager.freestyle_ui
local fish_game_config 
if SysFishingManager then
    fish_game_config = SysFishingManager.fish_hall_config
end

GameFreeModel = {}
local DefaultGameID = GLC.free_moren_gameid or 1
local this
local m_data
local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    for msg,cbk in pairs(lister) do
        Event.RemoveListener(msg, cbk)
    end
    lister=nil
end
local function MakeLister()
    lister={}
    lister["update_player_area_id"] = this.update_player_area_id

    lister["fg_signup_response"] = this.on_fg_signup_response
    lister["fg_get_hongbao_award_response"] = this.on_fg_get_hongbao_award_response
    lister["fg_get_week_cash_response"] = this.on_fg_get_week_cash_response
end

-- 初始化Data
local function InitMatchData()
    GameFreeModel.data={
    }
    m_data = GameFreeModel.data
end

function GameFreeModel.Init()
    this = GameFreeModel
    InitMatchData()
    MakeLister()
    AddLister()
    this.InitUIConfig()
    HandleLoadChannelLua("GameFreeModel",GameFreeModel)
    return this
end
function GameFreeModel.Exit()
    if this then
        RemoveLister()
        lister=nil
        this=nil
    end
end
function GameFreeModel.update_player_area_id()
	local areaid = MainModel.GetAreaID()
    this.UIConfig.gamelist = this.UIConfig.areagame[areaid].gamelist
    this.UIConfig.closegamelist = this.UIConfig.areagame[areaid].closegamelist
end
function GameFreeModel.InitUIConfig()
	local areaid = MainModel.GetAreaID()

    this.UIConfig={}
    this.UIConfig.areagame = free_hall_config.areagame
    this.UIConfig.global = free_hall_config.global
    this.UIConfig.game = free_hall_config.game
    this.UIConfig.gamelist = this.UIConfig.areagame[areaid].gamelist
    this.UIConfig.closegamelist = this.UIConfig.areagame[areaid].closegamelist

    local map = {}
    for k,v in ipairs(freestyle_ui.config) do
        if v.isOnOff and v.isOnOff == 1 then
            if not map[v.game_type] then
                map[v.game_type] = {}
            end
            map[v.game_type][#map[v.game_type] + 1] = v
        end
    end
    this.UIConfig.gameConfigMap = map
end

-- 获取游戏配置 游戏id
function GameFreeModel.GetGameConfig(configname)
	return this.UIConfig.gameConfigMap[configname]
end
function GameFreeModel.SetCurrGameConfig(data)
	this.UIConfig.config = data
    this.UIConfig.configmap = {}
    if this.UIConfig.config then
        for k,v in ipairs(this.UIConfig.config) do
            this.UIConfig.configmap[v.game_id] = v
        end
    end
end
function GameFreeModel.SetCurrGameID(gameid)
	this.data.gameid = gameid
end

function GameFreeModel.GetCurrGameID()
    if this and this.data then
        return this.data.gameid
    end
end

function GameFreeModel.SetCurrSceneID(sceneID)
    this.data.sceneID = sceneID
end

-- 根据游戏ID获取
function GameFreeModel.GetGameIDToConfig(gameid)
    if not this then this = GameFreeModel end
    if not this.UIConfig then return end
    local map = this.UIConfig.gameConfigMap
    for k,v in pairs(map) do
        for k1,v1 in ipairs(v) do
            if v1.game_id == gameid then
                return v1
            end
        end
    end
    dump(gameid, "<color=red>GetGameCfg gameid </color>")
end

-- 根据游戏类型返回free_hall_config game
function GameFreeModel.GetGameTypeToConfig(game_type)
    local map = this.UIConfig.game
    for k,v in pairs(map) do
        if v.game_type == game_type then
            return v
        end
    end
    dump(game_type, "<color=red>GetGameCfg game_type </color>")
end
-- 判断是否能进入
function GameFreeModel.IsRoomEnter(id)
    local ui_config = GameFreeModel.GetGameIDToConfig(id)
    local dd = MainModel.UserInfo.jing_bi
    if ui_config.enterMin >= 0 and dd < ui_config.enterMin then
        return 1 -- 过低
    end
    if ui_config.enterMax >= 0 and dd > ui_config.enterMax then
        return 2 -- 过高
    end
    return 0
end
-- 判断是否能再次进入
function GameFreeModel.IsAgainRoomEnter(id)
    local ui_config = GameFreeModel.GetGameIDToConfig(id)

    local jing_bi = MainModel.UserInfo.jing_bi
    if ui_config then
        if ui_config.min_coin > 0 and jing_bi < ui_config.min_coin then
            return 1 -- 过低
        end
        if ui_config.max_coin > 0 and jing_bi > ui_config.max_coin then
            return 2 -- 过高
        end
    else
        dump(id, "<color=red>DdzFreeModel id</color>")
    end
    return 0
end


--[[
--天奖金
today_game_race $ : *integer #当前今天已累计的积分  key=game_id value=times
today_hb_award $ : *integer #奖金  key=game_id value=award
today_hb_condition $ : *integer #获得条件  key=game_id value=times

today_award $ : integer #今天已经转换的奖金
today_max_award $ : integer #一天最多能获得的奖金
store_award $ : integer #当前已经储存的奖励（不一定只是今天的）

--周奖金
week_race $ : integer #当前已累计的积分
week_next_target $ : integer #下一个瓜分奖池机会目标
cur_week_award  $ : integer #当前本周奖金
get_note $ : integer #当前获得本周奖金的机会

last_week_award $ : integer #上周（或上N周）奖金
last_week_my_award $ : integer #
last_week_my_note  $ : integer #上周（或上N周）获得奖金的机会
--]]
function GameFreeModel.on_fg_req_hongbao_data_response(_, data)
    dump(data, "<color=red>fg_req_hongbao_data</color>")
    m_data.all_info = data
    --测试数据
    -- m_data.all_info.last_week_award = 1000
    -- m_data.all_info.last_week_my_award = 1000
    -- m_data.all_info.last_week_my_award = 1000

    Event.Brocast("model_fg_req_hongbao_data_response")
end

function GameFreeModel.on_fg_signup_response(_, data)
    dump(data,"<color=yellow>-------------------  GameFreeModel.on_fg_signup_response ---------------- </color>")
    if data.result == 0 then
        -- result=0在游戏Logic里面处理
        PlayerPrefs.SetInt(MainModel.FreeRapidBeginKey, data.game_id)
    else
        HintPanel.ErrorMsg(data.result,function(  )
            GameFreeModel.GotoGameFree()
        end)
    end
end

function GameFreeModel.GotoGameFree()
    GameManager.GotoUI({gotoui = "game_Free"})
end

function GameFreeModel.SendRedAward()
    if m_data.all_info.store_award == 0 and m_data.all_info.today_award >= m_data.all_info.today_max_award then
        local mm = StringHelper.ToCash(m_data.all_info.today_max_award/100)
        LittleTips.Create("今日对局福卡已领满" .. mm .. "，请明日再来")
    elseif m_data.all_info.store_award > 0 then
        Network.SendRequest("fg_get_hongbao_award", nil, "领取奖励")
    else
        LittleTips.Create("对局进度不足，任意匹配场打满5局可领取对局福卡！")
    end
end
-- 对局奖励
function GameFreeModel.on_fg_get_hongbao_award_response(_, data)
    dump(data, "<color=red>on_fg_get_hongbao_award_response</color>")
    if data.result == 0 then
        m_data.all_info.store_award = 0
        Event.Brocast("model_fg_get_hongbao_award_response", data.award)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

-- 周奖励
function GameFreeModel.on_fg_get_week_cash_response(_, data)
    dump(data, "<color=red>on_fg_get_week_cash_response</color>")
    if data.result == 0 then
        local p = {note=data.last_week_my_note, award=data.last_week_my_award}
        m_data.all_info.last_week_award = nil
        m_data.all_info.last_week_my_award = nil
        m_data.all_info.last_week_my_note = nil
        p.random_award = GameFreeModel:GenerateRandomAward(data)
        Event.Brocast("model_fg_get_week_cash_response", p)        
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--生成随机奖励
function GameFreeModel:GenerateRandomAward(data)
    local random_one_note_award = {}
    local all_award = data.last_week_my_award
    local one_random_award = 0
    local average_award = all_award / data.last_week_my_note
    --每次的保底奖励 1分
    local min_award = 1
    --当前可以产生的最大奖励
    local max_award = all_award
    local is_cirt = false
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    for i= data.last_week_my_note,2,-1 do
        max_award = (all_award - min_award * (i - 1)) / (i - 1)
        -- print("<color=yellow>>>>>>>></color>",min_award,max_award,all_award)
        one_random_award = math.random(min_award * 100,max_award * 100) / 100
        one_random_award = math.ceil(one_random_award)
        is_cirt = one_random_award / average_award >= 2
        random_one_note_award[#random_one_note_award + 1] = {award = one_random_award, is_crit = is_cirt}
        all_award = all_award - one_random_award
        -- print(i,one_random_award,all_award,max_award)
    end
    is_cirt = all_award / average_award >= 2
    random_one_note_award[#random_one_note_award + 1] = {award = all_award, is_crit = is_cirt}
    -- dump(random_one_note_award, "<color=yellow>>>>>>>>>>>>>随机奖励表 </color>")
    return random_one_note_award
end


-- 快速开始游戏的数据
function GameFreeModel.GetRapidBeginGameID (gametype)
    local gamedata = GameFreeModel.GetGameConfig(gametype)
    local dd = MainModel.UserInfo.jing_bi
    if gamedata and dd then
        -- 选最高的可以进入的场次
        for i=#gamedata, 1, -1 do
            local v = gamedata[i]
            if (v.isOnOff == 1 and (not v.isLock or v.isLock == 0)) and dd >= v.enterMin then
                return true,v
            end
        end
        return false,gamedata[1]
    end
end
-- 快速开始游戏的数据 大厅使用
function GameFreeModel.CheckRapidBeginGameID ()
    local gametypeid = PlayerPrefs.GetInt(MainModel.FreeRapidBeginKey, DefaultGameID)
    local gameCfg = GameFreeModel.GetGameIDToConfig(gametypeid)
    if not gameCfg or (gameCfg and gameCfg.isOnOff and gameCfg.isOnOff == 0) then
        PlayerPrefs.SetInt(MainModel.FreeRapidBeginKey, DefaultGameID)
        gameCfg = GameFreeModel.GetGameIDToConfig(DefaultGameID)
    end
    return GameFreeModel.GetRapidBeginGameID(gameCfg.game_type)
end
-- 快速开始游戏
function GameFreeModel.RapidBeginGame()
    if MainModel.Location then
        GameManager.CheckCurrGameScene()
        return
    end

    local xsyd_signup = function ()
        GameManager.CommonGotoScence({gotoui=GameSceneCfg[GameFreeModel.data.sceneID].SceneName, p_requset={id = this.data.gameid, xsyd = 1}})
    end
    local signup = function()
        GameManager.CommonGotoScence({gotoui=GameSceneCfg[GameFreeModel.data.sceneID].SceneName, p_requset={id = this.data.gameid}})
    end
    local check
    check = function ()
        local isOk,gamedata = GameFreeModel.CheckRapidBeginGameID()
        local gametypeid = PlayerPrefs.GetInt(MainModel.FreeRapidBeginKey, DefaultGameID)
        if gamedata then
            local gameCfg = GameFreeModel.GetGameIDToConfig(gametypeid)
            local v = GameFreeModel.GetGameTypeToConfig(gameCfg.game_type)
            local sceneID = v.sceneID
            GameFreeModel.SetCurrSceneID(sceneID)
            GameFreeModel.SetCurrGameID(gamedata.game_id)
            if isOk then
                if GuideLogic and GuideLogic.IsFreeBattle() then
                    xsyd_signup()
                else
                    signup()
                end
            else
                PayFastFreePanel.Create(gamedata, check)
            end
        else
            dump(gametypeid, "<color=red>Error GetRapidBeginData</color>")
        end
    end
    check()
end

function GameFreeModel.SetInitRapidID (id)
    PlayerPrefs.SetInt(MainModel.FreeRapidBeginKey, id)
    Event.Brocast("model_update_init_rapid_id")
end

-- 快速开始指定等级游戏的数据
function GameFreeModel.GetRapidBeginGameIDLevel (gametype, level)
    local gamedata = GameFreeModel.GetGameConfig(gametype)
    local dd = MainModel.UserInfo.jing_bi
    local check = function(v)
        if not v then
            return false
        end
        if (v.isOnOff == 1 and (not v.isLock or v.isLock == 0)) and dd >= v.enterMin and (v.enterMax == -1 or dd <= v.enterMax) then
            return true
        end
        return false
    end
    if gamedata then
        --优先选择指定登记
        local v_level = gamedata[level]
        dump(v_level, "<color=green>v_level</color>")
        if not v_level then
            if level > #gamedata then
                level = #gamedata
                v_level = gamedata[level]
            end
        end
        if check(v_level) then
            return true,v_level
        end
        -- 选最高的可以进入的场次
        for i=#gamedata, level, -1 do
            local v = gamedata[i]
            dump(v, "<color=green>v</color>")
            if check(v) then
                return true,v
            end
        end
        return false,gamedata[level]
    end
end

function GameFreeModel.CheckRapidBeginGameIDLevel(level)
    local gametypeid = PlayerPrefs.GetInt(MainModel.FreeRapidBeginKey, DefaultGameID +1)
    local gameCfg = GameFreeModel.GetGameIDToConfig(gametypeid)
    if not gameCfg or gameCfg.isOnOff == 0 then
        PlayerPrefs.SetInt(MainModel.FreeRapidBeginKey, DefaultGameID +1)
        gameCfg = GameFreeModel.GetGameIDToConfig(DefaultGameID +1)
    end
    return GameFreeModel.GetRapidBeginGameIDLevel(gameCfg.game_type,level)
end

-- 快速开始游戏
function GameFreeModel.RapidBeginGameLevel(t_level, transform)
    GameFreeModel.SetInitRapidID (t_level)
    if not t_level then t_level = 2 end
    if MainModel.Location then
        GameManager.CheckCurrGameScene()
        return
    end
    local check
    check = function ()
        local isOk,gamedata = GameFreeModel.CheckRapidBeginGameIDLevel(t_level)
        dump(gamedata, "<color=yellow>gamedata:</color>")
        dump(isOk, "<color=yellow>isOk:</color>")
        local gametypeid = PlayerPrefs.GetInt(MainModel.FreeRapidBeginKey, DefaultGameID +1)
        if gamedata then
            local gameCfg = GameFreeModel.GetGameIDToConfig(gametypeid)
            local v = GameFreeModel.GetGameTypeToConfig(gameCfg.game_type)
            if IsEquals(transform) then
                GameManager.GotoUI({gotoui="free_hall", goto_scene_parm={game_type = gameCfg.game_type ,game_id = gameCfg.game_id, down_style={panel=transform}}})
            else
                GameManager.GotoUI({gotoui="free_hall", goto_scene_parm={game_type = gameCfg.game_type ,game_id = gameCfg.game_id}})
            end
        else
            dump(gametypeid, "<color=red>Error GetRapidBeginData</color>")
        end
    end
    check()
end

-- 快速开始游戏的类型 财富中心使用
function GameFreeModel.GetRapidBeginGameType ()
    local gametypeid = PlayerPrefs.GetInt(MainModel.FreeRapidBeginKey, DefaultGameID)
    local gameCfg = GameFreeModel.GetGameIDToConfig(gametypeid)
    if not gameCfg or gameCfg.isOnOff == 0 then
        PlayerPrefs.SetInt(MainModel.FreeRapidBeginKey, DefaultGameID)
        gameCfg = GameFreeModel.GetGameIDToConfig(DefaultGameID)
    end
    return MainModel.ClientToServerScene[gameCfg.game_type]
end

function GameFreeModel.GetFishGameConfig(gameId)
    if not gameId then
        return fish_game_config.game
    else
        for _, game in ipairs(fish_game_config.game) do
            if game.game_id == gameId then
                return game
            end
        end
    end
end