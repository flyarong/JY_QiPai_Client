-- 创建时间:2018-11-27

GameBroadcastRollPanel = {}

local basefunc = require "Game.Common.basefunc"

GameBroadcastRollPanel = basefunc.class()

GameBroadcastRollPanel.name = "GameBroadcastRollPanel"

local C = GameBroadcastRollPanel
local instance
local Opacity = 0.01

local RollState =
{
	RS_Null = "RS_Null",-- 空闲
	RS_Begin = "RS_Begin",-- 运行开始
	RS_End = "RS_End",-- 运行结束
}

-- isfront 重要广播，插入到队列最前面
-- 万一都是重要广播，怎么办 nmg todo
function C.PlayRoll()
	if not instance then
		C.Create()
	end
	instance:RunBroadcast()
end
function C.PlayFinish()
	if instance then
		instance.isRecentlyFinish = true
		instance:RunBroadcast()
	end
end

function C.PlayEnd(key)
	if instance then
		instance:RemoveRollCellList(key)
	end
end

function C.Create()
	instance = C.New()
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
    self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
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
	end
	self.seqMove = nil
	self:RemoveListener()
	self:CloseRollCellList()
	self.tmpl = nil
	destroy(self.gameObject)
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("LayerLv50")
	if not IsEquals(parent) then return end
	parent = parent.transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.rollState = RollState.RS_Null
	self.RollCellList = {}
	self.broadcast_count = 0
	
	self.Node = tran:Find("UINode/Node").transform
	self.NodeCanvasGroup = tran:Find("UINode"):GetComponent("CanvasGroup")
	self.NodeCanvasGroup.alpha = Opacity
	-- 最近的是否完成
	self.isRecentlyFinish = true
	if MainModel.GetLocalType() == "mj" then
		self.NodeCanvasGroup.transform.localPosition = Vector3.New(0, 362, 0)
	elseif MainModel.GetLocalType() == "ddz" then
		self.NodeCanvasGroup.transform.localPosition = Vector3.New(0, 396, 0)
	else
		self.NodeCanvasGroup.transform.localPosition = Vector3.New(0, 362, 0)
	end

	self:InitUI()
end

function C:InitUI()
	self.tmpl = GetPrefab("GameBroadcastRollPrefab")
end

function C:on_backgroundReturn_msg()
	self:RunBroadcast()
end

function C:on_background_msg()
	self.isRecentlyFinish = true
	if self.seqMove then
		self.seqMove:Kill()
	end
	self.seqMove = nil
	self.rollState = RollState.RS_Null
	if IsEquals(self.NodeCanvasGroup) then
		self.NodeCanvasGroup.alpha = Opacity
	end
	self:CloseRollCellList()
end

function C:OnExitScene()
	self:MyExit()
	instance = nil
end

function C:RemoveRollCellList(key)
	if self.RollCellList and self.RollCellList[key] then
		self.RollCellList[key]:Destroy()
		self.RollCellList[key] = nil
		self.broadcast_count = self.broadcast_count - 1
	end
	if self.broadcast_count <= 0 then
		if self.seqMove then
			self.seqMove:Kill()
		end
		self.rollState = RollState.RS_End
		self.seqMove = nil
		self.seqMove = DoTweenSequence.Create()
		self.seqMove:Append(self.NodeCanvasGroup:DOFade(Opacity, 0.5))
		self.seqMove:OnKill(function ()
			self.rollState = RollState.RS_Null
			if IsEquals(self.NodeCanvasGroup) then
				self.NodeCanvasGroup.alpha =Opacity
			end
		end)
	end
end
function C:CloseRollCellList()
	if self.RollCellList then
		for k,v in pairs(self.RollCellList) do
			v:Destroy()
		end
	end
	self.RollCellList = {}
	self.broadcast_count = 0
end

function C:RunBroadcast()
	if IsEquals(self.NodeCanvasGroup) and self.isRecentlyFinish then
		local data = GameBroadcastManager.GetRollFront()
		if data then
			self:PlayBroadcast(data)
		end
	end
end

function C:PlayBroadcast(data)
	if self.rollState == RollState.RS_End then
		if self.seqMove then
			self.seqMove:Kill()
		end		
	end
	self.NodeCanvasGroup.alpha = 1
	if self.rollState == RollState.RS_Null then
		if not IsEquals(self.NodeCanvasGroup) then
			self.NodeCanvasGroup = tran:Find("UINode"):GetComponent("CanvasGroup")
		end
		if not IsEquals(self.NodeCanvasGroup) then
			return
		end
		self.seqMove = DoTweenSequence.Create()
		local tt = 0.5 * (1 - self.NodeCanvasGroup.alpha)
		self.seqMove:Append(self.NodeCanvasGroup:DOFade(1, tt))
		self.seqMove:OnKill(function ()
			if IsEquals(self.NodeCanvasGroup) then
				self.NodeCanvasGroup.alpha = 1
			end
		end)
	end
	self.isRecentlyFinish = false
	self.rollState = RollState.RS_Begin
    local obj = GameBroadcastRollPrefab.Create(data, self.Node, self.tmpl)
    self.RollCellList[data.key] = obj
    self.broadcast_count = self.broadcast_count + 1
end

