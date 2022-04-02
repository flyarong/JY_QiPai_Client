-- 创建时间:2018-05-28

LodingModel = {}
local this

function LodingModel.Init()
    this = HallModel

    return this
end
function LodingModel.Exit()
	if this then
	    this = nil
    end    
end
-- 加载的状态
LodingModel.BufferStateType =
{
    BST_Null = 0,    --空状态
    BST_Begin = 1,   --开始加载
    BST_Loading = 2, --加载中
    BST_Finish = 3,  --加载完成
    BST_Exit = 4,  --加载完成退出
}
-- 加载的资源类型
LodingModel.LoadResType =
{
    LRT_Null = 0,   --空
    LRT_Asset = 1,  --预加载资源
    LRT_Scene = 2,  --加载场景
}
LodingModel.BufferSceneConstName = "Game/LodingScene/LodingScene"
-- 预加载表
LodingModel.preloadList = {}
-- 卸载表
LodingModel.unLoadList = {}
-- 资源表
LodingModel.resDict = {}

local LoadAsset = function ( )
	-- 需要预加载的资源
    local list = {}
    LodingModel.resDict = {}
    LodingModel.preloadList = {}
    LodingModel.unLoadList = {}

    local csList = resMgr:GetAssetTableList()
    local count = csList.Length
    for i = 0, count - 1, 1 do
    	list["" .. csList[i]] = 1
    end
    local dict = resMgr:GetAssetTableDict()

    local iter = dict:GetEnumerator()
    while iter:MoveNext() do  
        local v = iter.Current.Value
        local lifeType = resMgr:GetAssetTableDictLifeType(v)
        local pp = {}
        pp["lifeType"] = lifeType
        LodingModel.resDict["" .. iter.Current.Key] = pp
    end
    for k,v in pairs(list) do
        if not LodingModel.resDict[v] then
            LodingModel.preloadList[#LodingModel.preloadList + 1] = k
        end
    end

    for k,v in pairs(LodingModel.resDict) do
        -- 不在预加载列表，并且不是永驻就加入到卸载列表
        if not list[k] and v.lifeType ~= 1 then
        	LodingModel.unLoadList[#LodingModel.unLoadList + 1] = k
        end
    end
end
LodingModel.LoadAsset = LoadAsset


