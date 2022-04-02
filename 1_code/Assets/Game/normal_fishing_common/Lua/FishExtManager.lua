-- 创建时间:2019-06-11
-- 鱼的功能扩展
-- 目前是对宝箱鱼有支持

local basefunc = require "Game/Common/basefunc"

FishExtManager = {}
local C = FishExtManager
local FishExtTable = {}

function C.Init()
	FishExtTable = {}
end
function C.Exit()
	FishExtTable = {}
end
function C.RefreshData(data)
    FishExtTable = data
    C.FrameUpdate()
end

function C.GetBKData(seat_num, index)
    if FishExtTable then
        for k, v in ipairs(FishExtTable) do
            if v.type == 3 and v.seat_num == seat_num and v.id == index then
                return v
            end
        end
    end
end

function C.FrameUpdate()
    if FishExtTable then
        for k, v in ipairs(FishExtTable) do
            -- 宝箱鱼
            if v.type == 1 then
                local fish = FishManager.GetFishByID(v.id)
                if fish and ( (fish.fish_base and (fish.fish_base.m_fish_state == FishBase.FishState.FS_Nor or fish.fish_base.m_fish_state == FishBase.FishState.FS_Hit) ) or
                    (fish.m_fish_state == FishBase.FishState.FS_Nor or fish.m_fish_state == FishBase.FishState.FS_Hit) ) then
                    if fish.UpdateChangeData then
                        fish:UpdateChangeData(v)
                    end
                end
            end
            -- 宝箱鱼死亡
            if v.type == 2 then
                local fish = FishManager.GetFishByID(v.id)
                if fish then
                    if fish.DeadData then
                        fish:DeadData(v)
                    end
                end
            end
            -- 贝壳活动的补充数据
            if v.type == 3 then
                dump(v)
                print("<color=red>贝壳活动的补充数据</color>")
                Event.Brocast("ui_bk_activity_refresh_data_bk_id", v.seat_num, v.data)
            end
        end
    end
end

