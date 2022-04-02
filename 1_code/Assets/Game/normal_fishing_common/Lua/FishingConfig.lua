-- 创建时间:2019-03-13
-- 捕鱼配置初始化

local fish_hall_config = SysFishingManager.fish_hall_config
local fish_debug_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_debug_config")
local fish_path_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_path_config")
local fish_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_config")
local fish_gun_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_gun_config")
local fish_attr_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_attr_config")
local fish_cache_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_cache_config")
local fish_use_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_use_config")
local fish_shaixuan = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_shaixuan")
local fish_goldfx_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_goldfx_config")
local fish_dead_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_dead_config")
local fish_parm_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_parm_config")
local fish_task_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_task_config")
local fish_face_config = HotUpdateConfig("Game.normal_fishing_common.Lua.fish_face_config")

FishingConfig = {}

local Config = {}

local function parse_path(iid)
    local data = {}
    data.type = 1
    local buf = Config.path_map[iid]
    if not buf then
        print("<color=red>路径 path id 为空=" .. iid .. "</color>")
        return
    end
    for k,v in pairs(buf) do
        if k == "WayPoints" then
            data.WayPoints = {}
            local strs = StringHelper.Split(v, "#")
            for i=1, #strs, 2 do
                local x = tonumber(strs[i])
                local y = tonumber(strs[i+1])
                local pos = {x=x, y=y}
                data.WayPoints[#data.WayPoints + 1] = pos
            end
        else
            data[k] = v
        end
    end
    return data
end
local function parse_circle(iid)
    local data = {}
    data.type = 2
    local buf = Config.circle_map[iid]
    if not buf then
        print("<color=red>路径 circle id 为空=" .. iid .. "</color>")
        return
    end
    for k,v in pairs(buf) do
        if k == "isPerp" then
            if v == 1 then
                data[k] = true
            else
                data[k] = false
            end
        else
            data[k] = v
        end
    end
    return data
end
local function parse_wait(iid)
    local data = {}
    data.type = 3
    local buf = Config.wait_map[iid]
    if not buf then
        print("<color=red>路径 wait id 为空=" .. iid .. "</color>")
        return
    end
    for k,v in pairs(buf) do
        data[k] = v
    end
    return data
end
function FishingConfig.InitUIConfig()
    Config = {}

    Config.fish_hall_list = fish_hall_config.game
    Config.fish_hall_map = {}
    for k,v in pairs(fish_hall_config.game) do
        if v.is_on and v.is_on == 1 then
            Config.fish_hall_map[v.game_id] = v
        end
    end

    if fish_debug_config then
        Config.fish_debug_map = {}
        for k,v in ipairs(fish_debug_config.config) do
            Config.fish_debug_map[v.key] = v.value
        end
        if not Config.fish_debug_map.is_debug_onoff or Config.fish_debug_map.is_debug_onoff == 0 then
            Config.fish_debug_map = {}
        end
    end

    Config.fish_parm_map = {}
    for k,v in ipairs(fish_parm_config.config) do
        if v.parm_key == "auto_bullet_speed" then
            Config.fish_parm_map[v.parm_key] = v.parm_value
        elseif v.parm_key == "box_fish_anim" then
            Config.fish_parm_map[v.parm_key] = v.parm_value
        else
            Config.fish_parm_map[v.parm_key] = tonumber(v.parm_value)
        end
    end

    Config.fish_task_map = {}
    for k,v in ipairs(fish_task_config.config) do
        Config.fish_task_map[v.id] = v
    end

    Config.fish_face_map = {}
    for k,v in ipairs(fish_face_config.config) do
        Config.fish_face_map[v.id] = v
    end

    Config.fish_dead_map = {}
    for k,v in ipairs(fish_dead_config.config) do
        Config.fish_dead_map[v.id] = v
    end

    -- 缓存
    Config.fish_cache_list = {}
    for k,v in ipairs(fish_cache_config.config) do
        if v.isOnOff == 1 then
            Config.fish_cache_list[#Config.fish_cache_list + 1] = v
        end
    end

    for k,v in ipairs(fish_config.config) do
        if v.blood_pos then
            v.blood_pos = Vector3.New(v.blood_pos[1], v.blood_pos[2], 0)
            v.blood_scale = Vector3.New(v.blood_scale[1], v.blood_scale[2], 1)
        end
    end    
    -- 鱼
    Config.fish_list = {}
    for k,v in ipairs(fish_config.config) do
    	Config.fish_list[#Config.fish_list + 1] = v
    end
    Config.fish_map = {}
    for k,v in ipairs(fish_config.config) do
    	Config.fish_map[v.id] = v
    end

    Config.use_fish_map = {}
    for k,v in ipairs(fish_use_config.use_fish) do
        Config.use_fish_map[v.id] = v
    end

    -- 鱼属性
    Config.fish_attr_list = {}
    for k,v in ipairs(fish_attr_config.config) do
        Config.fish_attr_list[#Config.fish_list + 1] = v
    end
    Config.fish_attr_map = {}
    for k,v in ipairs(fish_attr_config.config) do
        Config.fish_attr_map[v.id] = v
    end

    -- 鱼枪
    Config.fish_gun_list = {}
    for k,v in ipairs(fish_gun_config.config) do
    	Config.fish_gun_list[#Config.fish_gun_list + 1] = v
    end
    Config.fish_gun_map = {}
    for k,v in ipairs(fish_gun_config.config) do
    	Config.fish_gun_map[v.index] = v
    end

    -- 筛选规则
    Config.fish_shaixuan_map = {}
    for k,v in ipairs(fish_shaixuan.Sheet1) do
        Config.fish_shaixuan_map[v.type] = v
        v.multi_list = {}
        for i = 1, #v.multi, 2 do
            local buf = {}
            buf.min = v.multi[i]
            buf.max = v.multi[i+1]
            buf.num = v.num[(i+1)/2]
            v.multi_list[#v.multi_list + 1] = buf
        end
    end

    -- 鱼的金币表现等级
    Config.fish_goldfx_list = fish_goldfx_config.config
    Config.fish_zzfx_list = fish_goldfx_config.zz_config


    -- 鱼的轨迹
    Config.path_map = {}
    Config.circle_map = {}
    Config.wait_map = {}
    for k,v in ipairs(fish_path_config.path) do
        Config.path_map[v.id] = v
    end
    for k,v in ipairs(fish_path_config.circle) do
        Config.circle_map[v.id] = v
    end
    for k,v in ipairs(fish_path_config.wait) do
        Config.wait_map[v.id] = v
    end

    local path = {}
    for k,v in ipairs(fish_path_config.config) do
        local buf = {}
        path[v.id] = buf
        buf.id = v.id
        buf.posX = v.posX
        buf.posY = v.posY
        buf.headX = v.headX
        buf.headY = v.headY
        
        buf.steer = {}
        local strs = StringHelper.Split(v.steer, "#")
        for k1,v1 in ipairs(strs) do
            local str2 = StringHelper.Split(v1, "+")
            local stelist = {}
            buf.steer[#buf.steer + 1] = stelist
            for i=1, #str2, 2 do
                local type = tonumber(str2[i])
                local iid = tonumber(str2[i+1])
                if type == 1 then
                    stelist[#stelist + 1] = parse_path(iid)
                    if not buf.posX then
                        buf.posX = stelist[#stelist].WayPoints[1].x
                        buf.posY = stelist[#stelist].WayPoints[1].y
                        local vv = Vec2DSub(stelist[#stelist].WayPoints[2], stelist[#stelist].WayPoints[1])
                        local vv1 = Vec2DNormalize(vv)
                        buf.headX = vv1.x
                        buf.headY = vv1.y
                    end
                elseif type == 2 then
                    stelist[#stelist + 1] = parse_circle(iid)
                elseif type == 3 then
                    stelist[#stelist + 1] = parse_wait(iid)
                else
                    print("类型不存在 type = " .. type)
                end
            end
        end
    end
    Config.steer_map = path

    Config.skill_money = {}
    Config.skill_money[#Config.skill_money + 1] = {prop_fish_frozen=500, prop_fish_lock=500, prop_fish_summon_fish=10000, 
                                                    prop_fish_accelerate=1000, prop_fish_wild=1000, prop_fish_doubled=1000}
    Config.skill_money[#Config.skill_money + 1] = {prop_fish_frozen=500, prop_fish_lock=500, prop_fish_summon_fish=10000, 
                                                    prop_fish_accelerate=1000, prop_fish_wild=1000, prop_fish_doubled=1000}
    Config.skill_money[#Config.skill_money + 1] = {prop_fish_frozen=500, prop_fish_lock=500, prop_fish_summon_fish=10000, 
                                                    prop_fish_accelerate=1000, prop_fish_wild=1000, prop_fish_doubled=1000}
    Config.skill_money[#Config.skill_money + 1] = {prop_fish_frozen=500, prop_fish_lock=500, prop_fish_summon_fish=10000, 
                                                    prop_fish_accelerate=1000, prop_fish_wild=1000, prop_fish_doubled=1000}
    Config.skill_money[#Config.skill_money + 1] = {prop_fish_frozen=500, prop_fish_lock=500, prop_fish_summon_fish=10000, 
                                                    prop_fish_accelerate=1000, prop_fish_wild=1000, prop_fish_doubled=1000}

    return Config
end

function FishingConfig.GetGoldFX(cfg, rate)
    if rate then
        for k,v in ipairs(cfg) do
            if v.min_rate <= rate and rate <= v.max_rate then
                return v
            end
        end
    end
    return cfg[1]
end
function FishingConfig.GetZZFX(cfg, lvl)
    if lvl then
        for k,v in ipairs(cfg) do
            if v.min_lvl <= lvl and lvl <= v.max_lvl then
                return v.level
            end
        end
    end
    return cfg[1].level
end
