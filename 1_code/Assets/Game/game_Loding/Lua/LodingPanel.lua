-- 创建时间:2018-05-28

local basefunc = require "Game.Common.basefunc"

LodingPanel = basefunc.class()

LodingPanel.name = "LodingPanel"


local instance
function LodingPanel.Create()
	instance = LodingPanel.New()
	return createPanel(instance, LodingPanel.name)
end
function LodingPanel.Bind()
	local _in = instance
	instance = nil
	return _in
end

local Rate
local Title
local bufferStateType = LodingModel.BufferStateType.BST_Null
local loadResType = LodingModel.LoadResType.LRT_Null
local totallLoadCount = 0
local currLoadCount = 0
local assetShare = 80
local sceneShare = 20
local timerUpdate

--启动事件--
function LodingPanel:Awake()
	Rate = self.transform:Find("Rate"):GetComponent("Image")
	Title = self.transform:Find("Title"):GetComponent("Text")
    self.versionNode = self.transform:Find("VersionNode")
	bufferStateType = LodingModel.BufferStateType.BST_Begin
    loadResType = LodingModel.LoadResType.LRT_Asset
    Title.text = "资源加载中：0%"
    Rate.fillAmount = 0
    totallLoadCount = 0
    currLoadCount = 0
end

function LodingPanel:Start()
	local Update = function ( )
		if loadResType == LodingModel.LoadResType.LRT_Asset then
        	self:UpdateAsset()
	    elseif loadResType == LodingModel.LoadResType.LRT_Scene then
	        self:UpdateScene()
	    else
	    end
	end
    timerUpdate = Timer.New(Update, -1, -1, true)
    timerUpdate:Start()
    self:OnOff()
end
function LodingPanel:OnOff()
    if GameGlobalOnOff.Version then
        self.versionNode.gameObject:SetActive(true)
    else
        self.versionNode.gameObject:SetActive(false)
    end
end
function LodingPanel:LoadAssetAsync()
    -- 卸载
    for k,v in pairs(LodingModel.unLoadList) do
    	resMgr:DestroyAssetObject(v)
        currLoadCount = currLoadCount + 1
    end
     
    -- 加载
    for k,v in pairs(LodingModel.preloadList) do
        print("<color=red>预加载资源 " .. k .. "：" .. v .. "</color>")
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
function LodingPanel:UpdateAsset( )
	if bufferStateType == LodingModel.BufferStateType.BST_Null then
    elseif bufferStateType == LodingModel.BufferStateType.BST_Begin then
        bufferTime = 0
        LodingModel.LoadAsset()
        totallLoadCount = #LodingModel.preloadList + #LodingModel.unLoadList
        currLoadCount = 0
        print("<color=red> totallLoadCount = " .. totallLoadCount .. "</color>")
        if totallLoadCount > 0 then
            bufferStateType = LodingModel.BufferStateType.BST_Loading
            coroutine.start(function ( )
			self:LoadAssetAsync()
			end)
        else
            loadResType = LodingModel.LoadResType.LRT_Scene
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
    elseif bufferStateType == LodingModel.BufferStateType.BST_Finish then
        bufferTime = 0
        loadResType = LodingModel.LoadResType.LRT_Scene
        bufferStateType = LodingModel.BufferStateType.BST_Begin
    else
    end
end
function LodingPanel:UpdateScene( )
	if bufferStateType == LodingModel.BufferStateType.BST_Null then
    elseif bufferStateType == LodingModel.BufferStateType.BST_Begin then
        bufferTime = 0
        bufferStateType = LodingModel.BufferStateType.BST_Loading
        SceneManager.LoadScene(resMgr:FormatSceneName(MainModel.myLocation))
        bufferStateType = LodingModel.BufferStateType.BST_Finish
        Title.text = "资源加载完成..."
        Rate.fillAmount = 1
        self:LoadFinish()
    elseif bufferStateType == LodingModel.BufferStateType.BST_Loading then
    elseif (bufferStateType == LodingModel.BufferStateType.BST_Finish) then
        
    else
	end
end
function LodingPanel:LoadFinish()

	loadResType = LodingModel.LoadResType.LRT_Null
    bufferStateType = LodingModel.BufferStateType.BST_Null

	LodingLogic.LoadSceneFinish()
end
function LodingPanel:OnDestroy()
	print("LodingPanel OnDestroy")
	timerUpdate:Stop()
end

