-- 创建时间:2018-08-07

local basefunc = require "Game.Common.basefunc"

RoomCardDown = basefunc.class()

RoomCardDown.name = "RoomCardDown"

local instance
function RoomCardDown.Create(scene_type, finishcall)
	-- 去掉下载提示，直接下载游戏
	if true then
		HotUpdatePanel.Create(scene_type, function(updateState)
			HotUpdatePanel.Close()
			if updateState == string.lower(scene_type) then
				if finishcall then
					finishcall()
				end
			else
				local msg = MainLogic.FormatGameStateError(updateState)
				if msg ~= nil then
					HintPanel.ErrorMsg(msg)
				end
			end
		end)
		return
	end

	instance = RoomCardDown.New(scene_type, finishcall)
	return instance
end
function RoomCardDown:ctor(scene_type, finishcall)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(RoomCardDown.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.BackButton = tran:Find("CenterRect/BackButton")
	self.DownButton = tran:Find("CenterRect/DownButton")
	EventTriggerListener.Get(self.BackButton.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.DownButton.gameObject).onClick = basefunc.handler(self, self.OnDownClick)
	self.HintText = tran:Find("CenterRect/HintText"):GetComponent("Text")

	self.id = GameConfigToSceneCfg[scene_type].ID
	self.finishcall = finishcall
	self.sceneName = scene_type
	self:InitUI(scene_type)
end
function RoomCardDown:InitUI(scene_type)
	local gamename = GameConfigToSceneCfg[scene_type].GameName

	local sceneName = GameConfigToSceneCfg[scene_type].SceneName
	local remoteGameSize = gameMgr:GetRemoteGameSize(sceneName)
	local gameSize = math.ceil(remoteGameSize * 0.000001 + 0.5)
	self.HintText.text = gamename .. "需要下载游戏（" .. gameSize .. "MB" .. "）\n" .. "是否下载"
end

-- 关闭
function RoomCardDown:OnBackClick()
    GameObject.Destroy(self.gameObject)
end
-- 下载
function RoomCardDown:OnDownClick()
	HotUpdatePanel.Create(self.sceneName, function(updateState)
		HotUpdatePanel.Close()
		if updateState == string.lower(self.sceneName) then
			if self.finishcall then
				self.finishcall()
			end
		else
			local msg = MainLogic.FormatGameStateError(updateState)
			if msg ~= nil then
				HintPanel.ErrorMsg(msg)
			end
		end
	end)
	GameObject.Destroy(self.gameObject)
end
