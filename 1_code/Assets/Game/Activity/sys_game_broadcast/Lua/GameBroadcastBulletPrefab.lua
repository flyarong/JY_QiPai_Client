-- 创建时间:2018-11-28

local basefunc = require "Game.Common.basefunc"

GameBroadcastBulletPrefab = basefunc.class()

local C = GameBroadcastBulletPrefab

local instance = nil
function C.Create(data, parent, pos)
	instance = C.New(data, parent, pos)
	return instance
end
function C:ctor(data, parent, pos)
	ExtPanel.ExtMsg(self)

	self.data = data
    self.gameObject = newObject("GameBroadcastBulletPrefab", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform

    local yy = pos.y
    tran.localPosition = Vector3.New(pos.x, yy, 0)
	local text = tran:Find("Text"):GetComponent("Text")
	if not data.msg.broadcast_content or data.msg.broadcast_content == "" then
		print(debug.traceback())
		print("<color=red>EEEEEEE 弹幕信息为空</color>")
	end
	text.text = data.msg.broadcast_content
	local ww = text.preferredWidth
	local hh = text.preferredHeight
	self.textW = ww
	self.textH = hh

	if self.data.msg.type == 3 then
		--捕鱼比赛广播
		local speed = 240
		local size = GameBroadcastBulletPanel.GetCanvasSize()
		local target_x = -(size.x / 2 + ww)
		local s = pos.x - target_x
		local move_t = 1
		if self.data.msg.broadcast_level == 1 then
			--主广播 
			move_t = s / speed
			GameBroadcastBulletPanel.AddMasterBro(self)
		else
			--辅助广播
			move_t = s / speed
		end
		self.seqMove = DG.Tweening.DOTween.Sequence()
		local tweenKey = DOTweenManager.AddTweenToExit(self.seqMove)
		self.seqMove:Append(tran:DOLocalMoveX(target_x, move_t):SetEase(DG.Tweening.Ease.Linear))
		self.seqMove:OnComplete(function ()
			GameBroadcastBulletPanel.PlayEnd(data.key)
		end)	
		self.seqMove:InsertCallback(move_t / 2,function ()
			GameBroadcastManager.PlayBulletFinish(data.key)
			GameBroadcastBulletPanel.RemMasterBro(self)
		end)
		self.seqMove:InsertCallback(10,function ()
			-- if self.data.msg.broadcast_level == 1 then
			-- 	-- GameBroadcastManager.CreateRandomViceBroadcast()
			-- end
		end)
		self.seqMove:OnKill(function ()
			DOTweenManager.RemoveExitTween(tweenKey)
			GameBroadcastBulletPanel.DelCell(data.key)
		end)
		return
	end

	self.seqMove = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToExit(self.seqMove)

	-- 移动速度固定 计算移动时间
	local tt1 = (1000 + yy + ww)/2000 * 16
	local tt2 = (1000 + yy + ww)/2000 * 16 / 2
	local pos1 = Vector3.New(-1000-ww, yy, 0)
	self.seqMove:AppendInterval(tt2)
	self.seqMove:AppendCallback(function ()
		GameBroadcastManager.PlayBulletFinish(data.key)
	end)
	self.seqMove:AppendInterval(-1 * tt2)
	self.seqMove:Append(tran:DOLocalMoveX(pos1.x, tt1):SetEase(DG.Tweening.Ease.Linear))
	self.seqMove:OnComplete(function ()
		GameBroadcastBulletPanel.PlayEnd(data.key)
	end)	
	self.seqMove:OnKill(function ()
		DOTweenManager.RemoveExitTween(tweenKey)
		GameBroadcastBulletPanel.DelCell(data.key)
	end)
end

-- 返回广播的区域大小
function C:GetRect()
	if not IsEquals(self.transform) then
		return {x=0, y=0, w=10,h=30}
	end
	local rect = {x=self.transform.localPosition.x, y=self.transform.localPosition.y, w=self.textW, h=70}
	return rect
end
function C:Destroy()
	self:MyExit()
end

function C:MyExit()
	destroy(self.gameObject)
end


