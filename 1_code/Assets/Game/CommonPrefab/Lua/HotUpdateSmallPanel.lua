-- 创建时间:2020-06-15
local basefunc = require "Game.Common.basefunc"

HotUpdateSmallPanel = basefunc.class()
local C = HotUpdateSmallPanel
C.name = "HotUpdateSmallPanel"

C.instance = nil
function C.Create(gameName, stateCallback, down_style)
	if C.instance then
		C.instance:OnBackClick()
	end
	C.instance = C.New(gameName, stateCallback, down_style)
	return C.instance
end
function C.Close()
	if C.instance then
		C.instance:OnBackClick()
	end
end
function C:ctor(gameName, stateCallback, down_style)
	ExtPanel.ExtMsg(self)
	if not down_style.panel or not IsEquals(down_style.panel) then return end
	local images = down_style.panel.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Image))
	local value = 0.528
	for i = 0, images.Length - 1 do
		images[i].color = Color.New(value, value, value, images[i].color.a)
	end

	local obj 
	if not down_style.parent then
		obj = newObject(C.name, down_style.panel.parent)
	else
		obj = newObject(C.name, down_style.parent)
	end
	local tran = obj.transform
	self.gameName = gameName
	self.stateCallback = stateCallback
	self.transform = tran
	self.gameObject = obj
	self.gameScene = GameConfigToSceneCfg[gameName].SceneName
	self.gameTitle = GameConfigToSceneCfg[gameName].GameTitle
	tran.position = down_style.panel.position
	LuaHelper.GeneratingVar(self.transform, self)

	self.RateWidth = 500
    self.TopRect = down_style.panel:GetComponent("RectTransform")
	self.ProgressImg = self.Progress:GetComponent("Image")
	self.canvas = self.transform:GetComponent("Canvas")
	self.canvas.sortingOrder = 2

    self.scale = 1
    self.scale = self.TopRect.sizeDelta.x / 880
    
    self.center.localScale = Vector3(self.scale, self.scale, 1)
    self:SetScale(self.center, self.scale)

	change_renderer(self.transform, 2, true)

    local bb = self.transform:GetComponent("RectTransform")
    bb.sizeDelta = self.TopRect.sizeDelta

	self:InitRect()
end

function C:SetScale(obj, scale)
	local meshs = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.SpriteRenderer))
	local ps = obj.gameObject:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
	for i = 0, ps.Length - 1 do
		local _s = ps[i].transform.localScale
		ps[i].transform.localScale = Vector3.New(_s.x * scale, _s.y * scale, _s.z * scale)
	end
	for i = 0, meshs.Length - 1 do
		local _s = meshs[i].transform.localScale
		meshs[i].transform.localScale = Vector3.New(_s.x / scale, _s.y / scale, _s.z / scale)
	end
end

function C:InitRect()
	self.title_txt.text = string.format("%s 正在更新中 (0 / 100)...", self.gameTitle)
	self.ProgressImg.fillAmount = 0
	self.RateNode.localPosition = Vector3.New(0, 0, 0)
	
	self:UpdateAssetAsync()
end

function C:UpdateAssetAsync()
	gameMgr:DownloadUpdate(self.gameScene,
		function (state)
			self:DownloadState(state)
		end,
		function (val)
			self:DownloadProgress(val)
		end)
end
function C:DownloadState(state)
	print("<color=red>state = " .. state .. "</color>")
	if self.stateCallback then
		self.stateCallback(state)
	end
end
function C:DownloadProgress(val)
	if not IsEquals(self.ProgressImg) then return end

	self.ProgressImg.fillAmount = val
	self.RateNode.localPosition = Vector3.New(self.RateWidth * val, 0, 0)

	self.title_txt.text = string.format("%s 正在更新中 (%d / 100)...", self.gameTitle, math.floor(val * 100))
end

-- 关闭
function C:MyExit()
	if IsEquals(self.ProgressImg) then
		self.ProgressImg.sprite = nil
	end
	destroy(self.gameObject)
end

function C:OnBackClick()
	print("<color=red>关闭界面 C</color>")
	self:MyExit()
	C.instance = nil
end

