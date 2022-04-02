-- 创建时间:2019-03-11
-- 玩家自己
-- 这个是玩家自己

local basefunc = require "Game.Common.basefunc"
FishingDRPlayerManager = basefunc.class()
local C = FishingDRPlayerManager
C.name = "FishingDRPlayerManager"

local Map = {}
function C.Init()

end

function C.Exit()
    C.RemoveAll()
end

function C.FrameUpdate(time_elapsed)
    for k, v in pairs(Map) do
        if v ~= nil then
            v:FrameUpdate(time_elapsed)
        end
    end
end

-- 添加
function C.Add(data)
	Map[data.id] = FishingDRPlayer.Create(data)
end

-- 删除
function C.Remove(id)
	if Map[id] then
		Map[id]:MyExit()
	end
end

function C.GetIDToPlayer(id)
	if Map[id] then
		return Map[id]
	end
end

function C.RemoveAll()
    for k,v in pairs(Map) do
        v:MyExit()
    end
    Map = {}
end

function C.Refresh(id)
    if Map[id] then
		Map[id]:MyRefresh()
	end
end

function C.RefreshAll()
    if table_is_null(Map) then return end
    for k,v in pairs(Map) do
    v:MyRefresh()
    end
end