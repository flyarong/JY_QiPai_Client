-- 创建时间:2018-07-04

local basefunc = require "Game.Common.basefunc"

HotUpdatePanel = basefunc.class()
HotUpdatePanel.name = "HotUpdatePanel"

local RateWidth = 1330

HotUpdatePanel.instance = nil
function HotUpdatePanel.Create(gameName, stateCallback, down_style)
	if HotUpdatePanel.instance then
		HotUpdatePanel.instance:OnBackClick()
	end
	if down_style then
		HotUpdatePanel.instance = HotUpdateSmallPanel.New(gameName, stateCallback, down_style)
		return HotUpdatePanel.instance
	else
		HotUpdatePanel.instance = HotUpdatePanel.New(gameName, stateCallback)
		return HotUpdatePanel.instance
	end
end
function HotUpdatePanel.Close()
	if HotUpdatePanel.instance then
		HotUpdatePanel.instance:OnBackClick()
	end
end
function HotUpdatePanel:ctor(gameName, stateCallback)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(HotUpdatePanel.name, parent)
	local tran = obj.transform
	self.gameName = gameName
	self.stateCallback = stateCallback
	self.transform = tran
	self.gameObject = obj
	self.gameScene = GameConfigToSceneCfg[gameName].SceneName
	self.gameTitle = GameConfigToSceneCfg[gameName].GameTitle

	self.Title = tran:Find("Title"):GetComponent("Text")
	self.Progress = tran:Find("Progress"):GetComponent("Image")
	self.RateNode = tran:Find("Progress/RateNode")
	
	self:InitRect()
end
function HotUpdatePanel:InitRect()
	self.Title.text = string.format("%s 正在更新中 (0 / 100)...", self.gameTitle)
	self.Progress.fillAmount = 0
	self.RateNode.localPosition = Vector3.New(0, 0, 0)
	
	self:UpdateAssetAsync()
end

function HotUpdatePanel:UpdateAssetAsync()
	gameMgr:DownloadUpdate(self.gameScene,
		function (state)
			self:DownloadState(state)
		end,
		function (val)
			self:DownloadProgress(val)
		end)
end
function HotUpdatePanel:DownloadState(state)
	print("<color=red>state = " .. state .. "</color>")
	if self.stateCallback then
		self.stateCallback(state)
	end
end
function HotUpdatePanel:DownloadProgress(val)
	if not IsEquals(self.Progress) then return end

	self.Progress.fillAmount = val
	self.RateNode.localPosition = Vector3.New(RateWidth * val, 0, 0)

	self.Title.text = string.format("%s 正在更新中 (%d / 100)...", self.gameTitle, math.floor(val * 100))
end

-- 关闭
function HotUpdatePanel:MyExit()
	if IsEquals(self.Progress) then
		self.Progress.sprite = nil
	end
	destroy(self.gameObject)
end
function HotUpdatePanel:OnBackClick()
	print("<color=red>关闭界面 HotUpdatePanel</color>")
	self:MyExit()
	HotUpdatePanel.instance = nil
end