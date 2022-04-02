-- 创建时间:2019-03-11
local basefunc = require "Game/Common/basefunc"

FishingDRFishManager = {}
local C = FishingDRFishManager
FishManager = FishingDRFishManager
-- 数据
local Map = {}
-- 鱼的父节点
local FishNodeTran

function C.Init()
    Map = {}
    FishNodeTran = {}
    for i = 1, 7 do
        FishNodeTran[#FishNodeTran + 1] = GameObject.Find("FishingDR2DUI/FishNodeTran/Node" .. i).transform
    end
end

function C.Exit()
    C.RemoveAll()
    FishNodeTran = nil
    Map = nil
end

function C.FrameUpdate(d)
    if table_is_null(Map) then return end
    for k, v in pairs(Map) do
        v:FrameUpdate(d)
    end
end

function C.Add(data)
    Map[data.fish_id] = FishingDRFishPrefab.Create(FishNodeTran[data.track_id], data)
    return Map[data.fish_id]
end

-- 根据ID获取鱼
function C.Get(id)
    if Map[id] then
        return Map[id]
    end
end

-- 根据ID移除鱼
function C.Remove(id)
    if Map[id] then
        Map[id]:MyExit()
        Map[id] = nil
    end
end

-- 清除所有鱼
function C.RemoveAll()
    if table_is_null(Map) then return end
    for k, v in pairs(Map) do
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
        v:MyRefresh(k)
    end
end

--鱼受击
function C.FishSuffer(id)
	if Map[id] then
        Map[id]:Hit()
    end
end

function C.FishDead(id,dead_level,callback)
    if Map[id] then
        FishingDRModel.set_fish_process_dead(id)
        Map[id]:Dead(dead_level,callback)
    end
end

function C.FishFlee(id,dead_level)
    if Map[id] then
        Map[id]:Flee()
        FishingDRModel.set_fish_process_flee(id)
    end
end

function C.GetParentPos (id)
    if FishNodeTran and FishNodeTran[id] then
        return FishNodeTran[id].transform.position
    end
    return Vector3.zero
end