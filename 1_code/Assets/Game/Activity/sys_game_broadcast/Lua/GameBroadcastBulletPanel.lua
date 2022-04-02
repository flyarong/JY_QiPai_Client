-- 创建时间:2018-11-28

local basefunc = require "Game.Common.basefunc"

GameBroadcastBulletPanel = basefunc.class()

GameBroadcastBulletPanel.name = "GameBroadcastBulletPanel"

local C = GameBroadcastBulletPanel
local instance
local RollState =
{
	RS_Null = "RS_Null",-- 空闲
	RS_Begin = "RS_Begin",-- 运行开始
	RS_Finish = "RS_Finish",-- 运行完成
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
		instance.rollState = RollState.RS_Null
		instance:RunBroadcast()
	end
end

function C.PlayEnd(key)
	if instance then
		instance:RemoveRollCellList(key)
	end
end
function C.DelCell(key)
	if instance then
		if instance.RollCellList and instance.RollCellList[key] then
			instance.RollCellList[key]:Destroy()
			instance.RollCellList[key] = nil
			instance.cellNum = instance.cellNum - 1
		end
	end
end
function C.Close()
	if instance then
		instance:CloseRollCellList()
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

    self.lister["exit_bullet_broadcast"] = basefunc.handler(self, self.exit_bullet_broadcast)
end
function C:exit_bullet_broadcast()
	self:OnExitScene()
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true 

	local parent = GameObject.Find("LayerLv50")
	if not IsEquals(parent) then
		return
	end
	parent = parent.transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.rollState = RollState.RS_Null
	self.RollCellList = {}
	self.cellNum = 0
	self.Node = tran:Find("Node").transform
	self:InitUI()
end

function C:InitUI()
end

function C:on_backgroundReturn_msg()
	self:RunBroadcast()
end

function C:on_background_msg()
	self:CloseRollCellList()
end

function C:OnExitScene()
	instance = nil
	self:MyExit()
	self:CloseRollCellList()
end

function C:RemoveRollCellList(key)
	if self.RollCellList and self.RollCellList[key] then
		self.RollCellList[key]:Destroy()
		self.RollCellList[key] = nil
		self.cellNum = self.cellNum - 1
	end
	self:RunBroadcast()
end
function C:CloseRollCellList()
	if self.RollCellList then
		for k,v in pairs(self.RollCellList) do
			v:Destroy()
		end
	end
	self.cellNum = 0
	self.RollCellList = {}
end

function C:RunBroadcast()
	if self.cellNum and self.cellNum < 30 then
		local data = GameBroadcastManager.GetBulletFront()
		if data then
			self:PlayBroadcast(data)
		else
			self.rollState = RollState.RS_Null
		end
	end
end

function C:PlayBroadcast(data)
	self.rollState = RollState.RS_Begin
	local rect = {}
	if self.RollCellList then
		for k,v in pairs(self.RollCellList) do
			rect[#rect + 1] = v:GetRect()
		end
	end

	local XX = nil
	local YY = nil
	YY = math.random(0, 400) - 200
	local master_rect = {}
	if self.master_bro and next(self.master_bro) then
		for k,v in pairs(self.master_bro) do
			master_rect[#master_rect + 1] = v:GetRect()
		end
	end
	local check_posy 
	check_posy = function(  )
		for i,v in ipairs(master_rect) do
			local a = v.y - v.h/2 - 4
			local b = v.y + v.h/2 + 4
			if a <= YY and YY <= b then
				YY = YY - v.h
				check_posy()
			end
		end
	end
	check_posy()
	
	for k,v in ipairs(rect) do
		local a = v.y - v.h/2
		local b = v.y + v.h/2
		if a <= YY and YY <= b then
			if not XX or XX < (v.x + v.w) then
				XX = v.x + v.w
			end
		end
	end
	if not XX or XX < 1080 then
		XX = 1080
	end
	XX = XX + math.random(50, 200)

	
	local pos = {x=XX, y=YY, z=0}
    local obj = GameBroadcastBulletPrefab.Create(data, self.Node, pos)
    self.RollCellList[data.key] = obj
    self.cellNum = self.cellNum + 1
end

function C.GetCanvasSize()
	if instance and instance.canvas_size then
		return instance.canvas_size
	end
	instance.canvas_size = GameObject.Find("Canvas"):GetComponent("RectTransform").sizeDelta
	return instance.canvas_size
end

function C.AddMasterBro(obj)
	if instance then
		instance.master_bro = instance.master_bro or {}
		instance.master_bro[obj] = obj
	end
end

function C.RemMasterBro(obj)
    if instance and instance.master_bro then
        instance.master_bro[obj] = nil    
    end
end