-- 创建时间:2019-03-13
-- 捕鱼配置初始化
local fishing_dr_cache_config = HotUpdateConfig("Game.game_FishingDR.Lua.fishing_dr_cache_config")
local fish_dead_config = HotUpdateConfig("Game.game_FishingDR.Lua.fishing_dr_dead_config")

FishingDRConfig = {}

local Config = {}
function FishingDRConfig.InitUIConfig()
    Config = {}
    Config.fish_dead_map = {}
    for k,v in ipairs(fish_dead_config.config) do
        Config.fish_dead_map[v.id] = v
    end
    -- 缓存
    Config.fish_cache_list = {}
    for k,v in ipairs(fishing_dr_cache_config.config) do
        if v.isOnOff == 1 then
            Config.fish_cache_list[#Config.fish_cache_list + 1] = v
        end
    end
    return Config
end


