-- 创建时间:2019-08-06
-- Panel:GameSmallHintPrefab
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

GameSmallHintPrefab = basefunc.class()
local C = GameSmallHintPrefab
C.name = "GameSmallHintPrefab"

function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.seqMove then
		self.seqMove:Kill()
		self.seqMove = nil
	end

	self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
	destroy(self.gameObject)
end

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.pp = 1900
    tran.localPosition = Vector3.New(self.pp/2, 0, 0)

	LuaHelper.GeneratingVar(self.transform, self)

	self.desc_txt.text = self.config.desc

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	local ww = self.desc_txt.preferredWidth

	self.seqMove = DoTweenSequence.Create()

	-- 移动速度固定 计算移动时间
	local tt1 = (self.pp + ww)/self.pp * 20
	-- 400是两条滚动广播的距离
	local tt2 = (400 + ww)/self.pp * 20
	local pos1 = Vector3.New(-self.pp/2-ww, 0, 0)
	self.seqMove:AppendInterval(tt2)
	self.seqMove:AppendCallback(function ()
		if self.call then
			self.call(self.panelSelf, self.config, GameSmallHintPanel.SmallHintStart.SHS_zhong)
		end
	end)
	self.seqMove:AppendInterval(-1 * tt2)
	self.seqMove:Append(self.transform:DOLocalMoveX(pos1.x, tt1):SetEase(DG.Tweening.Ease.Linear))
	self.seqMove:OnKill(function ()
		self.seqMove = nil
		if self.call then
			self.call(self.panelSelf, self.config, GameSmallHintPanel.SmallHintStart.SHS_jieshu)
		end
	end)
end
