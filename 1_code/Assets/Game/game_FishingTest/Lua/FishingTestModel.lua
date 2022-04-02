-- 创建时间:2019-03-06
require "Game.game_Fishing.Lua.FishingConfig"
local fish_lib = require "Game.game_Fishing.Lua.fish_lib"

FishingTestModel = {}
local M = FishingTestModel
M.isDebug = true
M.maxPlayerNumber = 4
M.Defines = {
    FrameTime = 0.02,
    BulledSpeed = 8,
    WorldDimensionUnit={xMin=-9.6, xMax=9.6, yMin=-5.4, yMax=5.4},
}

function M.Init()
    M.InitDefines()
    M.InitUIConfig()
    return M
end

function M.Exit()
    if M then
        M = nil
    end
end

function M.InitDefines()
    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width,height = height,width
    end
    M.Defines.WorldDimensionUnit = {xMin=-width/200, xMax=width/200, yMin=-height/200, yMax=height/200}
end

function M.InitUIConfig()
    M.Config = FishingConfig.InitUIConfig()
    dump(M.Config.steer_map, "<color=blue>鱼图</color>",100)
end

function M.SetUIConfig(cfg)
    M.Config = cfg
end

function M.SetFishData(data)
    M.fish_data = data
end

-- 服务器同步帧
function M.S2CFrameMessage(data)
    dump(data, "服务器同步帧")
    for k,v in ipairs(data) do
        if v.msg_type == "fish" then
            local var = {}
            var.fish_id = v.id
            var.fish_type = v.type
            var.pathID = v.path
            var.from = v.time
            FishManager.CreateFish(var)
        else
        end
    end
end

-- 摄像机 用于坐标转化
function M.SetCamera(camera2d, camera)
    M.camera2d = camera2d
    M.camera = camera
end
-- 2D坐标转UI坐标
function M.Get2DToUIPoint(vec)
    vec = M.camera2d:WorldToScreenPoint(vec)
    vec = M.camera:ScreenToWorldPoint(vec)
    return vec
end


--[[
    鱼图编辑器
--]]

local cur_point_data
local cur_line_data
local cur_fish_data

local point_data
local line_data
local fish_data

function M.AddData(cur_data,data)
    if not cur_data then
        LittleTips.Create("请先生成数据")
        return 
    end
    data = data or {}
    table.insert(data,cur_data)
end

function M.RemoveData(index,data)
    if not index then 
        LittleTips.Create("请输入删除数据的索引")
        return 
    end
    if index < 0 then
        LittleTips.Create("索引必须大于0")
        return 
    end
    local _i = index == 0 and #data or index
    data = data or {}
    table.remove(data,#data)
end

function M.RemoveCurData(cur_data)
    cur_data = nil
end

local map_data = {}
function M.GetAllMapData()
    return map_data
end
function M.GetMapData(id)
    if not id then
        return nil
    end
    return map_data[id]
end

function M.AddMapData()
    if not next(map_data[#map_data]) then
        return nil
    end
    map_data[#map_data + 1] = {}
    return map_data[#map_data + 1]
end

function M.RemoveMapData(id)
   if not id then return end
   table.remove(map_data,id)
end

function M.SaveMapData(id,data)
    if not id then return end
    if not map_data[id] then return end
    map_data[id] = data
 end

 function M.GetAllLineData(m_id)
    if not m_id then
        return nil
    end
    if not M.GetMapData(m_id) then return nil end
    local m_d = M.GetMapData(m_id).steer
    if not m_d or not next(m_d) then
        return nil
    end
    return m_d
 end

function M.GetLineData(l_id,m_id)
    if not l_id or not m_id then
       return nil
    end
    if not M.GetMapData(m_id) then return nil end
    local m_d = M.GetMapData(m_id).steer
    if not m_d or not next(m_d) then
        return nil
    end    
    if not m_d[l_id] then return nil end
    return m_d[l_id][1]
end

function M.AddLineData(m_id)
    if not m_id then return nil end
    local m_d = M.GetMapData(m_id)
    if not m_d then return nil end
    m_d.steer = m_d.steer or {}
    m_d.steer[#m_d.steer + 1] = {}
    m_d.steer[#m_d.steer][1] = {}
    return m_d.steer[#m_d.steer][1]
end

function M.RemoveLineData(l_id,m_id)
    if not l_id or not m_id then
        return nil
    end
    if not M.GetMapData(m_id) then return nil end
    local m_d = M.GetMapData(m_id).steer
    if not m_d or not next(m_d) then
        return nil
    end    
    if not m_d[l_id] then return nil end
    table.remove(m_d,l_id)
 end

function M.GetPointData(p_id, l_id,m_id)
    if not p_id or not l_id or not m_id then
       return nil
    end   
    local l_d = M.GetLineData(l_id,m_id)
    if not l_d or not next(l_d) then
        return nil
    end
    local data = {}
    if l_d.type == 1 then
        if l_d.WayPoints and l_d.WayPoints[p_id] then
            data = l_d.WayPoints[p_id]
        else
            return nil
        end
    elseif l_d.type == 2 then
        data.angle = l_d.angle
        data.radius = l_d.radius
        data.isPerp = l_d.isPerp
        return data
    elseif l_d.type == 3 then
        data.waitTime = l_d.waitTime
        return data
    end
end

function M.AddPointData(l_type,l_id,m_id)
    if not l_id or not m_id or not l_type then
        return nil
    end
    local l_d = M.GetLineData(l_id,m_id)
    if not l_d then
        return nil
    end
    if l_type == 1 then
        l_d.WayPoints = l_d.WayPoints or {}
        l_d.WayPoints[#l_d.WayPoints + 1] = {}
        return l_d.WayPoints[#l_d.WayPoints + 1]
    else
        return nil
    end
end