-- 创建时间:2019-05-23
-- 贝壳管理

local basefunc = require "Game/Common/basefunc"

BKManager = {}
local C = BKManager

local BKToSeatnoTable = {}
function C.GetKey(key)
	local strs = StringHelper.Split(key, "_")
    local seat_num = tonumber(strs[1])
    local index = tonumber(strs[2])
    return seat_num,index
end

-- 清除所有贝壳
function C.RemoveAll()
    for k, v in pairs(BKToSeatnoTable) do
        v:MyExit()
    end
    FishTable = {}
    cache_fish_map = {}
end


function C.AddBKByKey(prefab, key)
    local seat_num,index = C.GetKey(key)
    if not BKToSeatnoTable[seat_num] then
    	BKToSeatnoTable[seat_num] = {}
    end
    BKToSeatnoTable[seat_num][index] = prefab
end
function C.GetBKByKey(key)
    local seat_num,index = C.GetKey(key)
    if BKToSeatnoTable[seat_num] then
    	return BKToSeatnoTable[seat_num][index]
    end
end
function C.GetBKBySeatno(seat_num)
    if BKToSeatnoTable[seat_num] then
    	return BKToSeatnoTable[seat_num]
    end
end
function C.GetBKBySeatnoAndIndex(seat_num, index)
    if BKToSeatnoTable[seat_num] then
        return BKToSeatnoTable[seat_num][index]
    end
end
function C.RemoveBKByKey(key)
    local seat_num,index = C.GetKey(key)
    if BKToSeatnoTable[seat_num] and BKToSeatnoTable[seat_num][index] then
    	BKToSeatnoTable[seat_num][index]:MyExit()
    	BKToSeatnoTable[seat_num][index] = nil
    end
end
function C.RemoveBKBySeatno(seat_num)
	if seat_num and BKToSeatnoTable[seat_num] then
		for k,v in pairs(BKToSeatnoTable[seat_num]) do
			v:MyExit()
		end
    	BKToSeatnoTable[seat_num] = {}
    end
end
function C.RemoveBKBySeatnoAndIndex(seat_num, index)
    if BKToSeatnoTable[seat_num] then
        BKToSeatnoTable[seat_num][index] = nil
    end
end

