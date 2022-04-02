-- 创建时间:2018-09-13

local basefunc = require "Game.Common.basefunc"

GameSpeedyPrefab = basefunc.class()

local instance = nil
function GameSpeedyPrefab.Create(speedyData, uiPos, parent, isSelf, key)
	instance = GameSpeedyPrefab.New(speedyData, uiPos, parent, isSelf, key)
	return instance
end
function GameSpeedyPrefab:ctor(speedyData, uiPos, parent, isSelf, key)
    self.gameObject = newObject("GameSpeedyPrefab", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform

    tran.localPosition = uiPos.pos
	tran.localRotation = Quaternion:SetEuler(uiPos.rota.x, uiPos.rota.y, uiPos.rota.z)
	local text = tran:Find("Image/Text"):GetComponent("Text")
	text.transform.localRotation = Quaternion:SetEuler(uiPos.rota.x, uiPos.rota.y, uiPos.rota.z)
	text.text = speedyData.desc
	
	ExtendSoundManager.PlaySound(audio_config.player[speedyData.voice].audio_name, 1, function ()
		if isSelf then
			GameSpeedyModel.isCanPlay = true
		end
		GameSpeedyModel.PlayFinish(key)
		self:Destroy()
	end)
	self.out_time = Timer.New(function ()
		self:Destroy()
	end, 10, 1)
	self.out_time:Start()
end
function GameSpeedyPrefab:Destroy()
	if self.out_time then
		self.out_time:Stop()
	end
	self.out_time = nil
	GameObject.Destroy(self.gameObject)
end


