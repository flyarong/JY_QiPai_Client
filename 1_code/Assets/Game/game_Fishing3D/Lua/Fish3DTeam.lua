-- 创建时间:2019-04-09
-- 敢死队

local basefunc = require "Game/Common/basefunc"

FishTeam = basefunc.class()
local C = FishTeam
C.name = "FishTeam"

FishTeam.FishState = 
{
	FS_Nor="正常",
	FS_Flee="逃离",
	FS_Hit="受击",
	FS_Dead="死亡",
	FS_FeignDead="假装死亡",
}

function C.Create(parent, data)
	return C.New(parent, data)
end

function C:FrameUpdate()
	if not self.isInPool then
		if self:CheckIsInPool_Whole() then
			self.isInPool = 1
		else
			self.isInPool = -1
		end
	else
		if self.isInPool == -1 and self:CheckIsInPool_Whole() then
			self.isInPool = 1
		elseif self.isInPool == 1 and not self:CheckIsInPool_Whole() then
			self.isInPool = -1
			-- 从池子游出去
			if self.m_fish_state == FishTeam.FishState.FS_Flee or
				self.m_fish_state == FishTeam.FishState.FS_Dead or
				self.m_fish_state == FishTeam.FishState.FS_FeignDead then
				return
			end

			Event.Brocast("fish_out_pool", "fish_out_pool", self.data.fish_id)
		end
	end
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

function C:UpdateTransform(pos, r)
	self.transform.localPosition = Vector3.New(pos.x, pos.y, self.cur_z_val)
	self.transform.rotation = Quaternion.Euler(0, 0, r)
end

function C:MyExit()
	if self.anim_time then
		self.anim_time:Stop()
	end
	FishManager.RemoveFishByID(self.data.fish_id)
	self:RemoveListener()

	for k,v in ipairs(self.fish_list) do
		v:MyExit()
	end
	self.fish_list = nil

	CachePrefabManager.Back(self.prefab)
end

function C:ctor(parent, data)
	self.data = data
	self.data.fish_type = 888
	self.m_fish_name = "FishTeam"
	self.prefab = CachePrefabManager.Take(self.m_fish_name)
    self.prefab.prefab:SetParent(parent)
	local tran = self.prefab.prefab.prefabObj.transform
	self.transform = tran
	self.gameObject = tran.gameObject
	self.gameObject.name = data.fish_id
	self.isInPool = nil
	self.m_fish_state = FishTeam.FishState.FS_Nor

	self.box2d = tran:GetComponent("BoxCollider2D")
	self.lock_node = tran:Find("lock_node")
	self.hang_node = tran:Find("hang_node")

	self.cur_z_val = 500

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end
-- 刷新数据改变
function C:UpdateChangeData(data)
	
end

function C:InitUI()
	self:SetBox2D(true)
	self.fish_list = {}

	local isUp = true
	local offset_list = {{x=0, y=0}}
	local one_use_fish_cfg = FishingModel.Config.use_fish_map[self.data.types[1]]
	local one_fish_cfg = FishingModel.Config.fish_map[one_use_fish_cfg.fish_id]
	local size = {x=one_fish_cfg.size_w, y=one_fish_cfg.size_h}
	local rr = Vec2DLength(size) / 2

	local two_use_fish_cfg = FishingModel.Config.use_fish_map[self.data.types[2]]
	local two_fish_cfg = FishingModel.Config.fish_map[one_use_fish_cfg.fish_id]

	if #self.data.types == 5 then
		local py = rr * 0.707
		isUp = false
		offset_list[#offset_list + 1] = {x=py, y=py}
		offset_list[#offset_list + 1] = {x=py, y=-py}
		offset_list[#offset_list + 1] = {x=-py, y=py}
		offset_list[#offset_list + 1] = {x=-py, y=-py}

		self.box2d.size = Vector2.New(2*rr, 2*rr)
	elseif #self.data.types == 3 then
		local py = (size.x + two_fish_cfg.size_w) / 2
		isUp = true
		offset_list[#offset_list + 1] = {x=py, y=0}
		offset_list[#offset_list + 1] = {x=-py, y=0}

		self.box2d.size = Vector2.New(size.x + two_fish_cfg.size_w, one_fish_cfg.size_h*0.9)
	else
		print("<color=red>敢死队 个数异常 count = " .. #self.data.types .. " </color>")
		return
	end

	for k,v in ipairs(self.data.types) do
		local tt = 1
		if k == 1 then
			tt = 2
		else
			tt = 1
		end
		local fish = Fish.Create(self.transform, {fish_type=v, isTeam=true})
		self.fish_list[#self.fish_list + 1] = fish
		fish.transform.localScale = Vector3.one
		fish:SetBox2D(false)
		if isUp then
			if k == 1 then
				fish.transform.localPosition = Vector3.New(offset_list[k].x, offset_list[k].y, 10)
			else
				fish.transform.localPosition = Vector3.New(offset_list[k].x, offset_list[k].y, 0)
			end
		else
			if k == 1 then
				fish.transform.localPosition = Vector3.New(offset_list[k].x, offset_list[k].y, 0)
			else
				fish.transform.localPosition = Vector3.New(offset_list[k].x, offset_list[k].y, 10)
			end
		end
	end
end

function C:MyRefresh()
end

function C:Print()
	if self.data.fish_id then
		print("Fish = " .. self.data.fish_id)
		for k,v in ipairs(self.fish_list) do
			v:Print()
		end
	end
end

-- 是否在鱼池中
function C:CheckIsInPool()
	if self.m_fish_state == FishTeam.FishState.FS_Flee or
		self.m_fish_state == FishTeam.FishState.FS_Dead or
		self.m_fish_state == FishTeam.FishState.FS_FeignDead then
		return false
	end
    if math.abs(self.transform.position.x) < FishingModel.Defines.WorldDimensionUnit.xMax and 
    	math.abs(self.transform.position.y) < FishingModel.Defines.WorldDimensionUnit.yMax then
        return true
    else
        return false
    end
end
-- 是否完全在鱼池中
function C:CheckIsInPool_Whole()
	if self.m_fish_state == FishTeam.FishState.FS_Flee or
		self.m_fish_state == FishTeam.FishState.FS_Dead or
		self.m_fish_state == FishTeam.FishState.FS_FeignDead then
		return false
	end
    if (math.abs(self.transform.position.x) - 0.5) < FishingModel.Defines.WorldDimensionUnit.xMax and 
    	(math.abs(self.transform.position.y) - 0.5) < FishingModel.Defines.WorldDimensionUnit.yMax then
        return true
    else
        return false
    end
end
-- 是否完全在鱼池外
function C:CheckIsOutPool_Whole()
	for k,v in ipairs(self.fish_list) do
		if not v:CheckIsOutPool_Whole() then
			return false
		end
	end
	return true
end

-- 设置冰冻状态
function C:SetIceState(isIce)
	if self.m_fish_state == FishTeam.FishState.FS_Dead or self.m_fish_state == FishTeam.FishState.FS_Flee then
		return
	end
	self.isIce = isIce
	for k,v in ipairs(self.fish_list) do
		v:SetIceState(isIce)
	end
end
-- 冰冻解封
function C:SetIceDeblocking()
	for k,v in ipairs(self.fish_list) do
		v:SetIceDeblocking()
	end
end

function C:SetBox2D(b)
	self.box2d.enabled = b
end

-- 标记鱼假死
function C:SetFeignDead(b)
	if self.m_fish_state == FishTeam.FishState.FS_Dead or self.m_fish_state == FishTeam.FishState.FS_Flee then
		return
	end
	if b then
		self.m_fish_state = FishTeam.FishState.FS_FeignDead
		self:SetBox2D(false)
	else
		self.m_fish_state = FishTeam.FishState.FS_Nor
		self:SetBox2D(true)
	end
end

function C:Flee()
	if self.m_fish_state ~= FishTeam.FishState.FS_Dead and self.m_fish_state ~= FishTeam.FishState.FS_Flee and
		self.m_fish_state ~= FishTeam.FishState.FS_FeignDead then
		self.m_fish_state = FishTeam.FishState.FS_Flee
		self:SetBox2D(false)
		for k,v in ipairs(self.fish_list) do
			v:Flee()
		end
		if self.anim_time then
			self.anim_time:Stop()
			self.anim_time = nil
		end
	end
end

function C:Hit()
	if self.m_fish_state ~= FishTeam.FishState.FS_Dead and self.m_fish_state ~= FishTeam.FishState.FS_Flee then
		self.m_fish_state = FishTeam.FishState.FS_Hit
		if self.anim_time then
			self.anim_time:Stop()
			self.anim_time = nil
		end
		for k,v in ipairs(self.fish_list) do
			v:Hit()
		end
		self.anim_time = Timer.New(function ()
			self.anim_time = nil
			self.m_fish_state = FishTeam.FishState.FS_Nor
		end, 0.3, 1)
		self.anim_time:Start()
	end
end

function C:Dead()
	VehicleManager.RemoveVehicle(self.data.fish_id)
	self:SetBox2D(false)
	self.m_fish_state = FishTeam.FishState.FS_Dead
	if self.anim_time then
		self.anim_time:Stop()
	end
	for k,v in ipairs(self.fish_list) do
		v:Dead(2)
	end
	self.anim_time = Timer.New(function ()
		self:MyExit()
		self.anim_time:Stop()
	end, 2, 1)
	self.anim_time:Start()
	Event.Brocast("fish_out_pool", "fish_out_pool", self.data.fish_id)
end
function C:Tag()
	self:SetBox2D(false)
	VehicleManager.RemoveVehicle(self.data.fish_id)
	FishManager.RemoveFishByID(self.data.fish_id)
end

--鱼的类型
function C:GetFishType()
	return self.data.fish_type
end
--鱼的特殊奖励？？？
function C:GetFishAward()
	return nil
end
-- 鱼的组别
function C:GetFishGroup()
	return nil
end
-- 鱼的额外属性
function C:GetFishAttr()
	return self.data.data
end
-- 鱼是否是敢死队
function C:GetFishTeam()
	return self.data.isTeam
end
-- 鱼的倍率
function C:GetFishRate()
	local rate = 0
	for k,v in ipairs(self.fish_list) do
		rate = rate + v:GetFishRate()
	end
	return rate
end
-- 锁定点
function C:GetLockPos()
	return self.lock_node.transform.position
end
-- 鱼的名字 图片
-- 目前只有大三元
function C:GetFishNameToSprite()
	return "by_imgf_dsy"
end

-- 爆炸表现 pos是爆炸鱼的坐标
function C:BoomHit(pos)
	VehicleManager.Stop(self.data.fish_id)
	local tpos = self.transform.position
	local cha = tpos - pos
	local len = Vec2DLength({x=cha.x, y=cha.y})
	if len > 4 then
		len = 4
	end
	local mass = 2
	if mass == 0 then
		mass = 1
	end
	local scale = (4-len) / 4 * (1/mass)
	local epos = Vector3.Normalize(cha) * 3 * scale + tpos

	local seq = DoTweenSequence.Create()
	seq:Append(self.transform:DOMove(epos, 0.5):SetEase(DG.Tweening.Ease.OutQuint))
	seq:OnKill(function ()
		VehicleManager.Recover(self.data.fish_id, self.transform.position)
	end)
end

function C:GetPos()
	local tpos = self.transform.position
	return Vector3.New(tpos.x, tpos.y, 0)
end