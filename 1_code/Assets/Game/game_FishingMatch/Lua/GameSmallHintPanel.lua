-- 创建时间:2019-08-05
-- Panel:GameComSmallHintPanel
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

GameSmallHintPanel = basefunc.class()
local C = GameSmallHintPanel
C.name = "GameSmallHintPanel"

GameSmallHintPanel.SmallHintStart = 
{
	SHS_zhong = "移动到中间",
	SHS_jieshu = "结束",
}

-- config 格式 id,desc
function C.Create(config, parent, hh)
	if not config or #config == 0 then
		return
	end
	return C.New(config, parent, hh)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene )
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.update_time then
		self.update_time:Stop()
	end
	self:RemoveListener()

	destroy(self.gameObject)
end
function C:MyClose()
	self:MyExit()
end


function C:ctor(config, parent, hh)

	ExtPanel.ExtMsg(self)

	self.config = config
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	if hh then
		self.fishing_node.localPosition = Vector3.New(0, hh, 0)
	else
		self.fishing_node.localPosition = Vector3.zero
	end

	self:MakeLister()
	self:AddMsgListener()

    self.time_call_map = {}
	self.time_call_map["time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.RunHint)}
    
    self.update_time = Timer.New(function ()
    	self:Update()
    end, 1, -1, nil, true)
    self.update_time:Start()

	self:InitUI()
end
function C:GetCall(t)
	local tt = t
	local cur = 0
	return function (st)
		cur = cur + st
		if cur >= tt then
			cur = cur - tt
			return true
		end
		return false
	end
end
function C:Update()
	for k,v in pairs(self.time_call_map) do
		if v.time_call(1) then
			v.run_call()
		end
	end
end
function C:RunHint()
	if next(self.CellMap) then
		return
	end
	local ii = math.random(1, #self.config)
	if not self.CellMap[ii] then
		local dd = {}
		local pre = GameSmallHintPrefab.Create(self.fishing_node, self.config[ii], C.HintPrefabCall, self)
		dd.pre = pre
		dd.start = "nor"
		self.CellMap[ii] = dd
	end
end

function C:HintPrefabCall(cfg, start)
	if start == GameSmallHintPanel.SmallHintStart.SHS_jieshu then
		if self.CellMap and self.CellMap[cfg.id] then
			self.CellMap[cfg.id].pre:OnDestroy()
			self.CellMap[cfg.id] = nil
		end
	end
end

function C:InitUI()
	self:ClearCellList()
	self:RunHint()
end

function C:ClearCellList()
	if self.CellMap then
		for k,v in pairs(self.CellMap) do
			v.pre:OnDestroy()
		end
	end
	self.CellMap = {}
end

function C:onExitScene()
	self:MyExit()
end
