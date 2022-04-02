-- 创建时间:2018-08-29

local basefunc = require "Game.Common.basefunc"

SmallLodingPanel = basefunc.class()

SmallLodingPanel.name = "SmallLodingPanel"

local Rate
local RateNode
local RateWidth = 1000
local Title
local bufferStateType = LodingModel.BufferStateType.BST_Null
local loadResType = LodingModel.LoadResType.LRT_Null
local totallLoadCount = 0
local currLoadCount = 0
local assetShare = 80
local sceneShare = 20
local timerUpdate

local instance
function SmallLodingPanel.Create(tex)
	instance=SmallLodingPanel.New(tex)
	return instance
end
function SmallLodingPanel:ctor(tex)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(SmallLodingPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	--print("-------------------cccccccccccccccccccc---------------------------ddddddddddddddddd------------", tex)
	--
	if tex then
		self.screenshot = self.transform:Find("Screenshot"):GetComponent("RawImage")
		self.screenshot.texture = tex
		self.screenshot.gameObject:SetActive(true)
	end

	Rate = self.transform:Find("Rate"):GetComponent("Image")
	Title = self.transform:Find("Title"):GetComponent("Text")
	bufferStateType = LodingModel.BufferStateType.BST_Begin
    loadResType = LodingModel.LoadResType.LRT_Asset
    Title.text = "资源加载中：0%"
    Rate.fillAmount = 0
    totallLoadCount = 0
    currLoadCount = 0

    RateNode = tran:Find("Rate/RateNode")
    RateNode.localPosition = Vector3.New(-RateWidth/2, 0, 0)

    self:InitRect()
end
function SmallLodingPanel:InitRect()
	local Update = function ( )
        	self:UpdateAsset()
    end
    timerUpdate = Timer.New(Update, -1, -1, true)
    timerUpdate:Start()
end
function SmallLodingPanel:LoadAssetAsync()
    -- 卸载
    for k,v in pairs(LodingModel.unLoadList) do
    	resMgr:DestroyAssetObject(v)
        currLoadCount = currLoadCount + 1
    end
    Util.ClearMemory()
    -- 加载
    for k,v in pairs(LodingModel.preloadList) do
        local str = StringHelper.Split(v, ".")
        if str[#str] == "png" then
            GetTexture(v)
	elseif str[#str] == "mp3" then
	    GetAudio(v)
        else
            GetPrefab(v)
        end
        Yield(0)
        currLoadCount = currLoadCount + 1
    end
end
function SmallLodingPanel:UpdateAsset( )
--	print("<color=red>SmallLodingPanel UpdateAsset</color>")
    if not IsEquals(self.gameObject) then return end
	if bufferStateType == LodingModel.BufferStateType.BST_Null then

    elseif bufferStateType == LodingModel.BufferStateType.BST_Begin then
        bufferTime = 0
        LodingModel.LoadAsset()
        totallLoadCount = #LodingModel.preloadList + #LodingModel.unLoadList
        currLoadCount = 0
        if totallLoadCount > 0 then
            bufferStateType = LodingModel.BufferStateType.BST_Loading
            coroutine.start(function ( )
			self:LoadAssetAsync()
			end)
        else
            bufferStateType = LodingModel.BufferStateType.BST_Finish
        end
    elseif bufferStateType == LodingModel.BufferStateType.BST_Loading then
        bufferTime = 0
        local nn = (assetShare * (currLoadCount / totallLoadCount)) / (assetShare + sceneShare)
        local str = "资源加载中：" .. string.format("%.2f", nn * 100) .. "%"
        Title.text = str
        Rate.fillAmount = nn
        if currLoadCount >= totallLoadCount then
            bufferTime = 0
            bufferStateType = LodingModel.BufferStateType.BST_Finish
        end
        RateNode.localPosition = Vector3.New(-RateWidth/2 + RateWidth * nn, 0, 0)
    elseif bufferStateType == LodingModel.BufferStateType.BST_Finish then
        self:LoadFinish()
    else
    end
end

function SmallLodingPanel:LoadFinish()
	loadResType = LodingModel.LoadResType.LRT_Null
    bufferStateType = LodingModel.BufferStateType.BST_Null

	LodingLogic.LoadSceneFinish()
	timerUpdate:Stop()
    destroy(self.gameObject)
end
function SmallLodingPanel:OnDestroy()
	if self.screenshot then
		self.screenshot.gameObject:SetActive(false)
		self.screenshot.texture = nil
		self.screenshot = nil
	end

	timerUpdate:Stop()
end
