-- 创建时间:2019-03-11
-- 玩家自己
-- 这个是玩家自己

local basefunc = require "Game.Common.basefunc"
FishingDRItemManager = basefunc.class()
local C = FishingDRItemManager
C.name = "FishingDRItemManager"

local Map = {}
local TrackMap = {}
local IndexMap = {}
local ItemNodeTran

function C.Init()
    ItemNodeTran = {}
    for i = 1, 7 do
        ItemNodeTran[#ItemNodeTran + 1] = GameObject.Find("FishingDR2DUI/ItemNodeTran/Node" .. i).transform
	TrackMap[i] = {}
    end
    IndexMap = {}
end

function C.Exit()
    C.RemoveAll()
    ItemNodeTran = nil
end

function C.Refresh(index)
    if Map[index] then
		Map[index]:MyRefresh()
	end
end

function C.RefreshAll()
    if table_is_null(Map) then return end
    for k,v in pairs(Map) do
        v:MyRefresh(k)
    end
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
	local index = data.index
	local track_id = data.track_id
	table.insert(TrackMap[track_id], index)
    IndexMap[index] = track_id
    Map[index] = FishingDRItemPrefab.Create(ItemNodeTran[data.track_id],data)
    return Map[index]
end

-- 删除
function C.Remove(idx)
    local track_id = IndexMap[idx]
    if not table_is_null(TrackMap[track_id]) then
        for k, v in ipairs(TrackMap[track_id]) do
            if v == idx then
                table.remove(TrackMap[track_id], k)
                IndexMap[idx] = nil
                break
            end
        end
    end

	if Map[idx] then
		Map[idx]:MyExit()
        Map[idx] = nil
        FishingDRModel.set_event_process_trigger(idx)
	end
end
function C.RemoveByTrackID(track_id)
	for _, idx in ipairs(TrackMap[track_id]) do
		IndexMap[idx] = nil
		if Map[idx] then
			Map[idx]:MyExit()
			Map[idx] = nil
		end
	end
	TrackMap[track_id] = {}
end

function C.Get(id)
	if Map[id] then
		return Map[id]
	end
end

function C.RemoveAll()
    IndexMap = {}
    for i = 1, 7 do
        TrackMap[i] = {}
    end
    if table_is_null(Map) then return end
    for k,v in pairs(Map) do
        v:MyExit()
    end
    Map = {}
end

function C.GetParentPos (id)
    if ItemNodeTran and ItemNodeTran[id] then
        return ItemNodeTran[id].transform.position
    end
    return Vector3.zero
end