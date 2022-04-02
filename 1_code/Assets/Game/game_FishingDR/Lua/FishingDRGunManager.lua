-- 创建时间:2019-03-11
-- 抢

local basefunc = require "Game.Common.basefunc"

FishingDRGunManager = basefunc.class()
local C = FishingDRGunManager
C.name = "FishingDRGunManager"

local Map = {}
function C.Init()

end

function C.Exit()
    C.RemoveAll()
end

function C.FrameUpdate(time_elapsed)
    if table_is_null(Map) then return end
    for k, v in pairs(Map) do
        v:FrameUpdate(time_elapsed)
    end
end

function C.Add(data)
	Map[data.id] = FishingDRGun.Create(data)
end

function C.Remove(id)
	if Map[id] then
        Map[id]:MyExit()
        Map[id] = nil
	end
end

function C.Get(id)
	if Map[id] then
		return Map[id]
	end
end

function C.RemoveAll()
    if table_is_null(Map) then return end
    for k,v in pairs(Map) do
        v:MyExit()
    end
    Map = {}
end

function C.ManualShoot(id,vec)
    if Map[id] then
		Map[id]:ManualShoot(vec)
	end
end

function C.SetAuto(id,b)
    if Map[id] then
	    Map[id]:SetAuto(b)
	end
end

function C.CheckIsAutoShoot(id)
    if Map[id] then
		return Map[id]:CheckIsAutoShoot()
	end
end

function C.SetUse(id,b)
    if Map[id] then
	    Map[id]:SetUse(b)
	end
end

function C.GetFirstGunId()
    if not table_is_null(Map) then
        for k,v in pairs(Map) do
            if not FishingDRModel.check_is_dead_or_flee(k) then
                return k
            end
        end
    end
end