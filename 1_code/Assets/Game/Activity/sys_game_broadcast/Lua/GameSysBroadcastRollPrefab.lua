-- 创建时间:2019-01-24

local basefunc = require "Game.Common.basefunc"

GameSysBroadcastRollPrefab = basefunc.class()

local instance = nil
function GameSysBroadcastRollPrefab.Create(data, parent)
	instance = GameSysBroadcastRollPrefab.New(data, parent)
	return instance
end
function GameSysBroadcastRollPrefab:ctor(data, parent)
	ExtPanel.ExtMsg(self)

	self.data = data
    self.gameObject = newObject("GameSysBroadcastRollPrefab", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform
    tran.localPosition = Vector3.New(1024, 0, 0)
	local text = tran:Find("Image/Text"):GetComponent("Text")
	text.text = data.msg.content
	local ww = text.preferredWidth

	self.seqMove = DG.Tweening.DOTween.Sequence()

	local is_complete = false
	-- 移动速度固定 计算移动时间
	local tt1 = (2048 + ww)/2048 * 12
	-- 400是两条滚动广播的距离
	local tt2 = (400 + ww)/2048 * 12
	local pos1 = Vector3.New(-1024-ww, 0, 0)
	self.seqMove:AppendInterval(tt2)
	self.seqMove:AppendCallback(function ()
		GameBroadcastManager.PlaySysFinish(data.key)
	end)
	self.seqMove:AppendInterval(-1 * tt2)
	self.seqMove:Append(tran:DOLocalMoveX(pos1.x, tt1):SetEase(DG.Tweening.Ease.Linear))
	self.seqMove:OnComplete(function ()
		is_complete = true
		GameSysBroadcastRollPanel.PlayEnd(data.key)
	end)
	self.seqMove:OnKill(function ()
		self.seqMove = nil
		if not is_complete then
			is_complete = true
			GameSysBroadcastRollPanel.PlayEnd(data.key)
		end
	end)
end
function GameSysBroadcastRollPrefab:Destroy()
	self:MyExit()
end

function GameSysBroadcastRollPrefab:MyExit()
	if IsEquals(self.gameObject) then
		if self.seqMove then
			self.seqMove:Kill()
		end
		destroy(self.gameObject)
	end
end
