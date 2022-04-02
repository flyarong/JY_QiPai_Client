local basefunc = require "Game.Common.basefunc"
FishingDRFishNetManager = basefunc.class()
local C = FishingDRFishNetManager
C.name = "FishingDRFishNetManager"

local NextID
local NetNodeTran
local Map
function C.Init()
    Map = {}
    NextID = 0
end

function C.Exit()
    C.RemoveAll()
    Map = nil
    NetNodeTran = nil
    NextID = nil
end

function C.Add(data)
    if not NetNodeTran then
        NetNodeTran = GameObject.Find("Canvas/GUIRoot/FishingDRGamePanel/UINode/FishNetNode").transform
    end
    if not data.id then data.id = C.GetNextID() end
	Map[data.id] = FishingDRFishNetPrefab.Create(NetNodeTran,data)
end

function C.Remove(id)
	if Map[id] then
		Map[id]:MyExit()
	end
end

function C.RemoveAll()
    NextID = 0
    if table_is_null(Map) then return end
    for k,v in pairs(Map) do
        v:MyExit()
    end
    Map = {}
end

-- 管理自己子弹ID
function C.GetNextID()
    NextID = NextID + 1
    return NextID
end