-- 创建时间:2019-03-13
-- 捕鱼配置初始化

local fish_parm_config = HotUpdateConfig("Game.game_FishingMatch.Lua.fishmatch_parm_config")
local fishmatch_cache_config = HotUpdateConfig("Game.game_FishingMatch.Lua.fishmatch_cache_config")
local fishmatch_use_config = HotUpdateConfig("Game.game_FishingMatch.Lua.fishmatch_use_config")
local fishmatch_barrage_config = HotUpdateConfig("Game.game_FishingMatch.Lua.fishmatch_barrage_config")
local fishmatch_buy_activity_config = HotUpdateConfig("Game.game_FishingMatch.Lua.fishmatch_buy_activity_config")


FishingMatchConfig = {}

local Config = {}
function FishingMatchConfig.InitUIConfig()
    Config = {}
    
    Config.fish_parm_map = {}
    for k,v in ipairs(fish_parm_config.config) do
        if v.parm_key == "box_fish_anim" or
            v.parm_key == "unlock_price_per_second" or
            v.parm_key == "buy_boom_money" then
            Config.fish_parm_map[v.parm_key] = v.parm_value
        else
            Config.fish_parm_map[v.parm_key] = tonumber(v.parm_value)
        end
    end
    -- 缓存
    Config.fish_cache_list = {}
    for k,v in ipairs(fishmatch_cache_config.config) do
        if v.isOnOff == 1 then
            Config.fish_cache_list[#Config.fish_cache_list + 1] = v
        end
    end
    Config.use_fish_map = {}
    for k,v in ipairs(fishmatch_use_config.use_fish) do
        Config.use_fish_map[v.id] = v
    end
    Config.fishmatch_barrage_config = fishmatch_barrage_config

    Config.fishmatch_buy_activity_map = {}
    for k,v in ipairs(fishmatch_buy_activity_config.config) do
        Config.fishmatch_buy_activity_map[v.line] = v
    end

    return Config
end


