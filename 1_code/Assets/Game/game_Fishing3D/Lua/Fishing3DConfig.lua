-- 创建时间:2020-02-10
-- 捕鱼配置初始化

local fish_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_config")
local fish_use_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_use_config")
local fish_cache_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_cache_config")
local fish_path_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_path_config")
local fish3d_gunfashion_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_gunfashion_config")
local fish_gun_config = HotUpdateConfig("Game.game_Fishing3D.Lua.fish3d_gun_config")

Fishing3DConfig = {}

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
            local ii = 1
            for i=1, #strs, 2 do
                local x = tonumber(strs[i])
                local y = tonumber(strs[i+1])
                local pos = {x=x, y=y}
                if buf.WayPoints_Z then
                    pos.z = buf.WayPoints_Z[ii]
                end
                ii = ii + 1
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
function Fishing3DConfig.InitUIConfig()
    Config = {}
    
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

    -- 缓存
    Config.fish_cache_list = {}
    for k,v in ipairs(fish_cache_config.config) do
        if v.isOnOff == 1 then
            Config.fish_cache_list[#Config.fish_cache_list + 1] = v
        end
    end

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


    -- 鱼的动作配置
    Config.fish_anim_map = {}
    Config.fish_anim_map[25] = {zhu_swim = {"swim"}, gl=30, fu_swim=true}
    Config.fish_anim_map[24] = {zhu_swim = {"swim"}, gl=30, fu_swim=true}

    -- 鱼枪
    Config.fish_gun_map = {}
    for k,v in ipairs(fish_gun_config.config) do
        Config.fish_gun_map[v.index] = v
    end
    -- 鱼枪皮肤
    Config.gun_style_map = {}
    for k,v in ipairs(fish3d_gunfashion_config.config) do
        Config.gun_style_map[v.skin_id] = Config.gun_style_map[v.skin_id] or {}
        for i=v.gun_index[1], v.gun_index[2] do
            Config.gun_style_map[v.skin_id][i] = v
        end
    end

    return Config
end
