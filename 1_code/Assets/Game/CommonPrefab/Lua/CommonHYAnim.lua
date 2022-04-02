--适用于左右滑动的，并且适应性居中的需求
--类似VIP特权
local basefunc = require "Game/Common/basefunc"

CommonHYAnim = basefunc.class()
local C = CommonHYAnim
C.name = "CommonHYAnim"
--一个已经带有子物体的容器
function C.Create(ContentWithChild,SelectIndex,IsSafeGo)
	return C.New(ContentWithChild,SelectIndex,IsSafeGo)
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
	if self.MainTimer then
		self.MainTimer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(ContentWithChild,SelectIndex,IsSafeGo)
	self.IsSafeGo = IsSafeGo
	self.index = SelectIndex or 1
	coroutine.start(function ( )
		Yield(0)
		self.BigContent = ContentWithChild
		self:PresePrefab(ContentWithChild)
		EventTriggerListener.Get(self.BigContent.parent.parent.gameObject).onDown = basefunc.handler(self, self.OnBeginDrag)
		EventTriggerListener.Get(self.BigContent.parent.parent.gameObject).onUp = basefunc.handler(self, self.OnEndDrag)
		self.canMoveByAct = true
		self:InitAreaConfig()
		self:MakeLister()
		self:AddMsgListener()
		self:InitMainTimer()
	end)
	
end
--分析处理预制体
function C:PresePrefab(prefab)
	self.clear_config = {}
	self.area_config = {}
	
	self.child_count = prefab.childCount
	local child_count = self.child_count
	self.child_list = {}
	for i = 0,child_count -1 do
		local B = prefab:GetChild(i)
		self.child_list[#self.child_list + 1] = B
	end
	if next(self.child_list) then
		self.child_space = self.child_list[1].transform.localPosition.x - self.child_list[2].transform.localPosition.x
		self.child_space = math.abs(self.child_space)
	end
	if self.child_space * child_count > prefab.transform.sizeDelta.x then
		print("<color=red>WARN ! 容器得宽度不足，可能导致动画异常,增加Rifht或Left控制宽度使之大于"..self.child_space * child_count.."</color>")	
	end
	self.item_width = self.child_space
	self.ADS = self.item_width * 2 / 35
	self.SPACE = self.item_width / 35
	local val = (self.index - 1) * self.item_width * -1
	local v = Vector2.New(val,self.BigContent.transform.localPosition.y)
	self.BigContent.transform.localPosition  = v
end

--是否接近正确位置
function C:IsClearRightPos()
	for i = 1,#self.clear_config do
		if math.abs(self.BigContent.transform.localPosition.x) <= self.clear_config[i].max and math.abs(self.BigContent.transform.localPosition.x) >= self.clear_config[i].min then
			return true
		end
	end
	return false
end

function C:InitClearConfig()
	self.clear_config = {}
	for i = 1,self.child_count do
		local data = {}
		data.min = (i - 1) * self.item_width - 10
		data.max = (i - 1) * self.item_width + 10
		self.clear_config[#self.clear_config + 1] = data
	end
end

function C:InitAreaConfig()
	local data = {}
	data.min = 0
	data.max = self.item_width/2
	self.area_config[#self.area_config + 1] = data
	for i = 2,self.child_count do
		local data = {}
		data.min = self.area_config[i - 1].max
		data.max = data.min + self.item_width
		self.area_config[#self.area_config + 1] = data
	end
end

function C:GoNext()
	if self.MoveByBtn == false then
		if self.index < self.child_count then
			self.index = self.index + 1
			self.MoveByBtn = true
		end
		return self.index
	end
end

function C:GoLast()
	if self.MoveByBtn == false then
		self.MoveByBtn = true
		if self.index > 1 then
			self.index = self.index - 1
			self.MoveByBtn = true
		end
		return self.index
	end
end

function C:InitMainTimer()
	self.MainTimer = Timer.New(
		function ()
			if self.BigContent and IsEquals(self.BigContent) then
				self:GoRightPos()
			end
		end
	,0.016,-1)
	self.MainTimer:Start()
end

--去到正确位置
function C:GoRightPos()
	if self.canMoveByAct then
		if self.MoveByBtn then
			self:MoveAnim()
		elseif not self:IsClearRightPos() then
			local index = self:GetClearIndex()
			if index then				
				self:MoveAnim(index)
			end			
		end
	end
end

function C:GetClearIndex()
	for i = 1,#self.area_config do
		if math.abs(self.BigContent.transform.localPosition.x) <= self.area_config[i].max and math.abs(self.BigContent.transform.localPosition.x ) >= self.area_config[i].min then
			return i
		end
	end
end

function C:MoveAnim(index)
	local index = index or self.index
	local val = (index - 1) * self.item_width * -1
	if math.abs(self.BigContent.transform.localPosition.x - val) <= self.ADS then
		self.index = index
		if self.IndexCall then
			self.IndexCall(index)
		end
		local v = Vector2.New(val,self.BigContent.transform.localPosition.y)
		self.BigContent.transform.localPosition  = v
		self.MoveByBtn = false
	else
		local x 
		if val > self.BigContent.transform.localPosition.x  then
			x = self.BigContent.transform.localPosition.x + self.SPACE
		elseif val < self.BigContent.transform.localPosition.x  then
			x = self.BigContent.transform.localPosition.x - self.SPACE
		end
		local v = Vector2.New(x,self.BigContent.transform.localPosition.y)
		self.BigContent.transform.localPosition  = v
	end
end

function C:OnBeginDrag()
	self.canMoveByAct=false
	self.downX = UnityEngine.Input.mousePosition.x
end
function C:OnEndDrag()
	self.canMoveByAct=true
	self.upX = UnityEngine.Input.mousePosition.x
	if self.IsSafeGo then
		self:SafeGo()
	end
end
--向某方向滑动一部分距离就可以出发动画的模式
function C:SafeGo()
	if self.upX and self.downX then
		if math.abs(self.upX - self.downX) >= 60 then
			if self.upX > self.downX then
				self:GoLast()
			else
				self:GoNext()
			end
		end
	end
end

function C:OnIndexCall(call)
	self.IndexCall = call
end