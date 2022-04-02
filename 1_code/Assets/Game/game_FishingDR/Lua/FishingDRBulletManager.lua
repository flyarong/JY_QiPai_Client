-- 创建时间:2019-03-11

FishingDRBulletManager = {}
local C = FishingDRBulletManager
local NextBulletID
-- 子弹列表
local Map = {}
local BulletNodeTran

function C.Init()
    Map = {}
    BulletNodeTran = {}
    NextBulletID = 0
    for i = 1, 8 do
        BulletNodeTran[#BulletNodeTran + 1] = GameObject.Find("FishingDR2DUI/BulletNodeTran/Node" .. i).transform
    end
end

function C.Exit()
    C.RemoveAll()
    BulletNodeTran = nil
    Map = nil
    NextBulletID = nil
end

function C.FrameUpdate(time_elapsed)
    if table_is_null(Map) then return end
    for k, v in pairs(Map) do
        v:FrameUpdate(time_elapsed)
    end
end

-- 管理自己子弹ID
function C.GetNextBulletID()
    NextBulletID = NextBulletID + 1
    return NextBulletID
end

-- 添加子弹
function C.Add(data)
    if not data then return end
    if not data.id then
		data.id = C.GetNextBulletID()
	end
    Map[data.id] = FishingDRBulletPrefab.Create(BulletNodeTran[data.gun_id], data)
    return Map[data.id]
end

-- 删除子弹
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
    NextBulletID = 0
    if table_is_null(Map) then return end
    for k,v in pairs(Map) do
        v:MyExit()
    end
    Map = {}
end

-- 移除某个座位号的子弹数据
function C.RemoveByGunID(gun_id)
    if table_is_null(Map) then return end
    for k,v in pairs(Map) do
        if v.data.gun_id == gun_id then
            v:MyExit()
            Map[k] = nil
        end
    end
end

-- 获取对应座位号的子弹数量
function C.GetBulletNumberByGunID(gun_id)
    local nn = 0
    if table_is_null(Map) then return 0 end
    for k, v in pairs(Map) do
        if v.data.gun_id == gun_id then
            nn = nn + 1
        end
    end
    return nn
end