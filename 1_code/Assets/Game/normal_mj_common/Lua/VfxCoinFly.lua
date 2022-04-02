-- 创建时间:2019-03-22
-- Panel:VfxCoinFly
local basefunc = require "Game/Common/basefunc"

VfxCoinFly = basefunc.class()
local C = VfxCoinFly
C.name = "VfxCoinFly"
C.instanceList = {}
C.instanceId = 1

function C.Create(parent, startPos, tarPos)
	local instance = C.New(parent, startPos, tarPos)
	C.AddToList(instance)
	return instance
end

function C:Close()
	self:MyExit()
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
	if self.delayKill then
		self.delayKill:Stop()
		self.delayKill = nil
	end

	C.RemoveFromList(self)
	self:StopFly()
	self:RemoveListener()

	if self and self.gameObject then
		GameObject.Destroy(self.gameObject)
	end
end

function C:ctor(parent, startPos, tarPos)
	local p = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, p)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI(startPos, tarPos)
end

function C:InitUI(startPos, tarPos)
	local dir = tarPos - startPos
	self.speed = Vector3.Magnitude(dir)
	self.transform.position = startPos
	self.transform.right = Vector3.Normalize(dir)
	self.targetPosition = tarPos
	self.updater = Timer.New(basefunc.handler(self, self.Fly), 0.02, -1, false)
	self.updater:Start()
end

function C:MyRefresh()
end

function C:Fly()
	local dis = Vector3.Magnitude(self.transform.position - self.targetPosition)
	local off = self.speed * Time.fixedDeltaTime
	if off >= dis then
		self.transform.position = self.targetPosition
		self.delayKill = Timer.New(basefunc.handler(self, self.Close), 0.5, 1, false)
		self.delayKill:Start()
	else
		self.transform.position = self.transform.position + self.transform.right * off
	end
end

function C:StopFly()
	if self.updater then
		self.updater:Stop()
		self.updater = nil
	end
end

function C.AddToList(ins)
	if ins then
		C.instanceList[C.instanceId] = ins
		ins.Id = C.instanceId
		C.instanceId = C.instanceId + 1
	end
end

function C.RemoveFromList(ins)
	if C.instanceList then
		for i, v in ipairs(C.instanceList) do
			if v.Id == ins.Id then
				table.remove(C.instanceList, i)
			end
		end
	end
end

function C.ClearAll()
	if C.instanceList then
		for i, v in ipairs(C.instanceList) do
			if v then
				v:Close()
			end
		end
		C.instanceList = nil
	end
end