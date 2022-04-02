-- 创建时间:2019-04-02
package.loaded["Game.game_FishingTest.Lua.FishMapEditerPanel"] = nil
require "Game.game_FishingTest.Lua.FishMapEditerPanel"

FishMapEditerModel = {}
local M = FishMapEditerModel

--数据结构
--[[
    鱼： "dead_index"    = 1
-         "fx_scale"      = 0.266667
-         "icon"          = "fish_01_01"
-         "id"            = 1
-         "mass"          = 1
-         "max_ratespeed" = 30
-         "max_speed"     = 1
-         "rate"          = 1
]]
local fish
--[[
    图：   "headX" = 1
-         "headY" = 0
-         "id"    = 1
-         "posX"  = -12
-         "posY"  = 0
-         "steer" = {
-             1 = {
-                 1 = {
-                     "WayPoints" = {
-                         1 = {
-                             "x" = 0
-                             "y" = 0
-                         }
-                     }
-                     "type"      = 1
-                 }
-             }
-             2 = {
-                 1 = {
-                     "angle"  = 360
-                     "isPerp" = true
-                     "radius" = 1
-                     "type"   = 2
-                 }
-             }
-             3 = {
-                 1 = {
-                     "WayPoints" = {
-                         1 = {
-                             "x" = 15
-                             "y" = 0
-                         }
-                     }
-                     "type"      = 1
-                 }
-             }
-         }
]]
local map
--[[
    鱼生成时间：{time = 123456}
]]
local fm_time

--[[
    鱼图 {fish_list = {1,2,3},fm_time_list = 1,map_list = 1}
        k：表名，v：id
--]]
local fish_map

local fish_list --鱼集合 {[1] = fish, [2] = fish}
local map_list --图集合 {[1] = map,[2] = map}
local fm_time_list --时间集合{[1] = fm_time,[2] = fm_time}
local fish_map_list --鱼图集合 {[1] = fish_map,[2] = fish_map}

local fish_map_cur --当前操作的鱼图
-- local fish_cur  --当前操作的鱼
local map_cur  --当前操作的图
local fm_time_cur  --当前操作的时间

function M.Init()
    M.ImporFishMap()
    return M
end

function M.Exit()
    if M then
        M = nil
    end
end

function M.ImportFishMap(  )
    package.loaded["Game.game_FishingTest.Lua.fish_map_config"] = nil
    fish_map_list = require "Game.game_FishingTest.Lua.fish_map_config"
end

function M.ExportFishMap(  )
    
end