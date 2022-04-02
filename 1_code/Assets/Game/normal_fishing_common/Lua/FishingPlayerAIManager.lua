-- 创建时间:2019-03-11
--[[
    座位
    4   3
    1   2
--]]
FishingPlayerAIManager = {}
local M = FishingPlayerAIManager
local fish_ai_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_ai_config")
package.loaded["Game.normal_fishing_common.Lua.FishingPlayerAI"] = nil
require "Game.normal_fishing_common.Lua.FishingPlayerAI"
local ai_config
--机器人
local players_map = {}
local lister = {}
local begin_timer = {}

function M.Init()
    M.AddListener()
    ai_config = M.InitConfig(fish_ai_config)
    players_map = {}
    begin_timer = {}
end

function M.InitAI()
    for k,v in pairs(players_map) do
        v:Exit()
    end
    for k,v in pairs(begin_timer) do
        v:Stop()
    end
    players_map = {}
    begin_timer = {}
end

function M.Exit()
    M.RemoveListener()
    for k,v in pairs(players_map) do
        v:Exit()
    end
    players_map = {}
    for k,v in pairs(begin_timer) do
        v:Stop()
    end
    begin_timer = {}
end

function M.AddListener()
	M.MakeLister()
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function M.MakeLister()
	lister = {}
	lister["ExitScene"] = M.Exit
	lister["OnLoginResponse"] = M.Exit
	lister["will_kick_reason"] = M.Exit
	lister["DisconnectServerConnect"] = M.Exit
    lister["ui_fsg_quit_game"] = M.Exit
end

function M.RemoveListener()
    for proto_name,func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function M.InitConfig(cfg)
    local _cfg = {}
    _cfg.player_config = {}
    local m_cfg = _cfg.player_config
    for i,_v in ipairs(cfg.player_config) do
        m_cfg[i] = {}
        m_cfg[i].status = _v.status
        m_cfg[i].probability = _v.probability
    end
    _cfg.player_speed = {}
    m_cfg = _cfg.player_speed
    for i,_v in ipairs(cfg.player_speed) do
        m_cfg[i] = {}
        for k,v in pairs(_v) do
            if type(v) == "table" then
                m_cfg[i][k] = {}
                for j=1,#v - 1,2 do
                    table.insert( m_cfg[i][k], {duration = v[j],probability = v[j + 1]} )
                end
            end
        end
    end
    _cfg.player_status = {}
    m_cfg = _cfg.player_status
    for i,_v in ipairs(cfg.player_status) do
        m_cfg[i] = {}
        for k,v in pairs(_v) do
            if type(v) == "table" then
                m_cfg[i][k] = {}
                for j=1,#v - 1,2 do
                    if v[j] == "other" then
                        m_cfg[i][k][#m_cfg[i][k]].other = cfg.other[v[j + 1]]
                    else
                        table.insert( m_cfg[i][k], {key = v[j],probability = v[j + 1]} )
                    end
                end
            end
        end
    end
    _cfg.player_switch = {}
    m_cfg = _cfg.player_switch
    for i,_v in ipairs(cfg.player_switch) do
        m_cfg[i] = {}
        for k,v in pairs(_v) do
            if type(v) == "table" then
                m_cfg[i][k] = {}
                if k == "fish" then
                    for j=1,#v - 2,3 do
                        local t = {}
                        t[v[j]] = v[j + 1]
                        t.status = v[j + 2]
                        table.insert( m_cfg[i][k], t)
                    end
                else
                    local _k = ""
                    if k == "event" then
                        _k = "event"
                    elseif k == "gold" then
                        _k = "num"
                    end
                    for j = 1 ,#v - 1 ,2 do
                        local t = {}
                        t[_k] = v[j]
                        t.status = v[j + 1]
                        table.insert( m_cfg[i][k], t )
                    end
                end
            end
        end
    end
    return _cfg
end

function M.SetUpdateRunning(seat_num, running)
    if players_map[seat_num] then
        players_map[seat_num]:SetUpdateRunning(running)
    end
end

-- 添加玩家
function M.AddPlayer(seat_num,player_instance)
    local player = FishingModel.GetSeatnoToUser(seat_num)
    dump(player, "<color=yellow>添加玩家</color>")
    local config = M.CreateAIConfig()
    M.RemovePlayer(seat_num)
    players_map[seat_num] = FishingPlayerAI.Create(player,config,player_instance)

    begin_timer[seat_num] = Timer.New(function(  )
        if players_map[seat_num] then
            players_map[seat_num]:StartUpdate()
        end
    end,0.6,1,false,false)
    begin_timer[seat_num]:Start()
end

-- 删除玩家
function M.RemovePlayer(seat_num)
    if players_map[seat_num] then
        players_map[seat_num]:Exit()
        players_map[seat_num] = nil
    end

    if begin_timer[seat_num] then
        begin_timer[seat_num]:Stop()
        begin_timer[seat_num] = nil
    end
end

function M.CreateAIConfig()
    local config = {}
    local p_cfg = M.GetRandomData(ai_config.player_config)
    dump(p_cfg, "<color=yellow>player_config</color>")
    if not p_cfg then return end
    config = M.CreateAIConfigByStatus(p_cfg.status)
    return config
end

function M.CreateAIConfigByStatus(st_id)
    local config = {}
    local cfg = ai_config.player_status[st_id]
    if not cfg then return nil end --没有这个状态
    config.player_status = cfg
    if config.player_status.player_speed then
        cfg = M.GetRandomData(config.player_status.player_speed)
        if cfg then
            config.player_speed = ai_config.player_speed[cfg.key]
        end
    end
    if config.player_status.player_switch then
        cfg = M.GetRandomData(config.player_status.player_switch)
        if cfg then
            config.player_switch = ai_config.player_switch[cfg.key]
        end
    end
    return config
end

function M.GetRandomData(t)
    if not t then return nil end
    local data
    local r = math.random()
    local all_pro = 0
    for i,v in ipairs(t) do
        all_pro = all_pro + v.probability
        if r <= all_pro then
            return v
        end
    end
    return nil
end

function M.GetSpeedConifg(speed)
    if not speed then return end
    local cfg = {}
    cfg.shoot = M.GetRandomData(speed.shoot)
    cfg.change_gun_level = M.GetRandomData(speed.change_gun_level)
    cfg.freed_skill = M.GetRandomData(speed.freed_skill)
    cfg.see_fish = M.GetRandomData(speed.see_fish)
    cfg.check_event = M.GetRandomData(speed.check_event)
    cfg.switch = M.GetRandomData(speed.switch)
    return cfg
end

function M.GetStatusConifg(status)
    if not status then return end
    local cfg = {}
    cfg.player_speed = M.GetRandomData(status.player_speed)
    cfg.player_switch = M.GetRandomData(status.player_switch)
    cfg.shoot = M.GetRandomData(status.shoot)
    cfg.shoot_num = M.GetRandomData(status.shoot_num)
    cfg.shoot_fish_type = M.GetRandomData(status.shoot_fish_type)
    cfg.shoot_fish_rate = M.GetRandomData(status.shoot_fish_rate)
    cfg.shoot_fish_dis = M.GetRandomData(status.shoot_fish_dis)
    cfg.change_gun_level = M.GetRandomData(status.change_gun_level)
    cfg.freed_skill = M.GetRandomData(status.freed_skill)
    return cfg
end
