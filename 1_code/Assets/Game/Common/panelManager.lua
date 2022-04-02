panelManager = {}

--当前已加载的panel
--key=panel_name value=panel_prefab
local panel_loaded = {}
--当前已加载的group
local current_group = nil

--panel的分组
--key=group_name value=group_table    group_table{key=panel_name value=ab_path}
local panel_group = {}

local panel_info = {
    Loading = "",
    LoginPanel = "hall/hall_prefab",
    HallPanel = "hall/hall_prefab",
    MatchDetailPanel = "match/match_prefab",
    MatchPanel = "match/match_prefab",
    MatchRankPanel = "match/match_prefab",
    MatchWaitPanel = "match/match_prefab",
    MatchRulePanel = "match/match_prefab"
}

panel_group.common = {
    
}

panel_group.login = {
    "LoginPanel"
}

panel_group.hall = {
    "HallPanel"
}

panel_group.match = {
    "MatchDetailPanel",
    "MatchPanel",
    "MatchRankPanel",
    "MatchWaitPanel",
    "MatchRulePanel"
}

function panelManager.show(panel_name)
    if panel_loaded[panel_name] then
        --资源已加载，直接打开界面
        print("panelManager.show return")
        local ab_path  = panel_info[panel_name]
        createPanel(panel_name, ab_path)
        return
    end

    --获取到界面所在的组
    local group = panelManager._get_panel_group_by_name(panel_name)
    local params = {
        asset_names = group,
        target_panel = panel_name,
        target_ab  = panel_info[panel_name]
    }
    --把资源列表发送给loading进行加载
    LoadingPanel.Show(params)
end

function panelManager.close(panel_name)
end

--[[根据界面名称获取整组的信息]]
function panelManager._get_panel_group_by_name(panel_name)
    for _, group in pairs(panel_group) do
        for _, p_name in pairs(group) do
            if p_name == panel_name then
                return group
            end
        end
    end
    return nil
end

--[[根据组界面组的信息，加载这一组中的所有资源]]
function panelManager._load_group_res(group, progress_callback)
    panel_loaded = {}
    local index = 0
    local count = #group
    for _, p_name in pairs(group) do
        local p_ab = panel_info[p_name]
        print("load res:", p_name, p_ab)
        resMgr:LoadPrefab(
            {p_name},
            function(objs)
                panel_loaded[p_name] = objs[0]
                if progress_callback then
                    index = index + 1
                    progress_callback(index / count)
                end
            end
        )
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--ui layer
local basefunc = require "Game/Common/basefunc"

local function GetUIFullHierarchy(uiTransform)
	local value = uiTransform.name
	local parent = uiTransform.parent
	while parent do
		value = parent.name + "/" + value
		parent = uiTransform.parent
	end
	return value
end

local function GetUIRootLayer(uiTransform)
	local layerOrder = 0
	local canvas = uiTransform:GetComponent("Canvas")
	if canvas then
		layerOrder = canvas.sortingOrder
	end
	return layerOrder
end

local function GetUILayerNodes(uiTransform)
	local nodes = {}

	local renders = uiTransform:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
	for i = 0, renders.Length - 1 do
		table.insert(nodes, renders[i])
	end

	local canvases = uiTransform:GetComponentsInChildren(typeof(UnityEngine.Canvas), true)
	local rootCanvas = uiTransform:GetComponent("Canvas")
	for i = 0, canvases.Length - 1 do
		if canvases[i] ~= rootCanvas then
			table.insert(nodes, canvases[i])
		end
	end

	return nodes
end


UILayerGroup = basefunc.class()

function UILayerGroup:ctor(baseLayer)
	self.baseLayer = baseLayer
	self.uiQueue = {}
	self.uiCount = 0
	self.currentLayer = 0
end

function UILayerGroup:SetRootNode(transform)
	self.rootNode = transform
end

function UILayerGroup:PushUI(uiTransform)
	if not self.rootNode then
		self.rootNode = GameObject.Find("Canvas").transform
	end

	self:PopUI(uiTransform)

	local layerOrders = {}
	for _, v in pairs(GetUILayerNodes(uiTransform)) do
		table.insert(layerOrders, {v, v.sortingOrder})
	end

	local maxOffset = 0
	local currOffset = 0

	local baseLayer = GetUIRootLayer(uiTransform)
	local offsetLayer = (self.baseLayer + self.currentLayer) - baseLayer
	for _, v in pairs(layerOrders) do
		currOffset = v[1].sortingOrder - baseLayer
		if currOffset > maxOffset then maxOffset = currOffset end

		v[1].sortingOrder = v[1].sortingOrder + offsetLayer

		print(string.format("\t%s -- %d, %d\n", v[1].name, baseLayer, currOffset))
	end

	local canvas = uiTransform:GetComponent("Canvas")
	if canvas then
		canvas.overrideSorting = true
		canvas.sortingOrder = self.currentLayer
	else
		print("Not found Canvas. Maybe layer error")
	end

	self.currentLayer = self.currentLayer + maxOffset + 1

	self.uiCount = self.uiCount + 1
	self.uiQueue[self.uiCount] = {
		transform = uiTransform,
		rawlayerOrders = layerOrders,
		rawMaxOffset = maxOffset
	}

	uiTransform:SetParent(self.rootNode)

	print("PushUI: ", uiTransform.name, self.uiCount, self.currentLayer, maxOffset)
end

function UILayerGroup:PopUI(uiTransform)
	local index = 0
	for idx = 1, self.uiCount do
		if self.uiQueue[idx].transform == uiTransform then
			index = idx
			break
		end
	end
	if index == 0 then return end

	for _, v in pairs(self.uiQueue[index].rawlayerOrders) do
		if IsEquals(v[1]) then
			v[1].sortingOrder = v[2]
		end
	end
	if index == self.uiCount then
		self.currentLayer = self.currentLayer - self.uiQueue[index].rawMaxOffset - 1
	end

	for idx = index, self.uiCount - 1 do
		self.uiQueue[idx] = self.uiQueue[idx + 1]
	end
	self.uiQueue[self.uiCount] = nil
	self.uiCount = self.uiCount - 1

	if self.uiCount <= 0 then
		self.uiCount = 0
		self.currentLayer = 0

		print("clear all")
	end

	print("PopUI: ", uiTransform.name, self.uiCount, self.currentLayer)

	uiTransform:SetParent(nil)
end

function UILayerGroup:PopAll()
	for idx = 1, self.uiCount do
		for _, v in pairs(self.uiQueue[idx].rawlayerOrders) do
			if IsEquals(v[1]) then
				v[1].sortingOrder = v[2]
			end
		end
	end

	self.uiQueue = {}
	self.uiCount = 0
	self.currentLayer = 0
end

local TOP_PANEL = {
	["ActivityBanner"] = 1
}

local baseUILayerGroup = nil
local topUILayerGroup = nil

function panelManager.Setup()
	if GameGlobalOnOff.LayerGroup then
		print("LayerGroup is Enable")	
	end

	baseUILayerGroup = UILayerGroup.New(0)
	topUILayerGroup = UILayerGroup.New(100)
end

function panelManager.SetRootNode(transform)
	baseUILayerGroup:SetRootNode(transform)
	topUILayerGroup:SetRootNode(transform)
end

function panelManager.PushUI(uiTransform)
	if not GameGlobalOnOff.LayerGroup then return end

	print("PushUI:" .. uiTransform.name)

	if TOP_PANEL[uiTransform.name] then
		topUILayerGroup:PushUI(uiTransform)
	else
		baseUILayerGroup:PushUI(uiTransform)
	end
end

function panelManager.PopUI(uiTransform)
	if not GameGlobalOnOff.LayerGroup then return end

	print("PopUI:" .. uiTransform.name)

	if TOP_PANEL[uiTransform.name] then
		topUILayerGroup:PopUI(uiTransform)
	else
		baseUILayerGroup:PopUI(uiTransform)
	end
end

function panelManager.PopAll()
	if not GameGlobalOnOff.LayerGroup then return end

	topUILayerGroup:PopAll()
	baseUILayerGroup:PopAll()
end
