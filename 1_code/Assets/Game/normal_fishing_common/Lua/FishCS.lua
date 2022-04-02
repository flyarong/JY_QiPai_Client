-- 创建时间:2019-12-25
-- 财神鱼

local basefunc = require "Game/Common/basefunc"
FishCS = basefunc.class()
local C = FishCS
C.name = "FishCS"

FishCS.FishState = 
{
	FS_Nor="正常",
	FS_Flee="逃离",
	FS_Hit="受击",
	FS_Dead="死亡",
	FS_FeignDead="假装死亡",
}

function C:FrameUpdate()
	if not self.isInPool then
		-- 初始化
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
			if self.m_fish_state == FishCS.FishState.FS_Flee or
				self.m_fish_state == FishCS.FishState.FS_Dead or
				self.m_fish_state == FishCS.FishState.FS_FeignDead then
				return
			end

			if self.data.fish_id then
				Event.Brocast("fish_out_pool", "fish_out_pool", self.data.fish_id)
			end
		end
	end
end
function C.Create(parent, data)
	return C.New(parent, data)
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
	self.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
	-- if not (self.fish_cfg and self.fish_cfg.close_rota and self.fish_cfg.close_rota == 1) then
	-- 	self.transform.rotation = Quaternion.Euler(0, 0, r)
	-- end
end

function C:MyExit()
	if self.anim_time then
		self.anim_time:Stop()
		self.anim_time = nil
	end
	self:RemoveListener()
	FishManager.RemoveFishByID(self.data.fish_id)

	if self.fish then
		for i = 1, #self.fish do
			self.fish[i].color = Color.New(1, 1, 1, 1)
			self.fish[i].transform.localScale = Vector3.one
		end
	end
	self.transform.localScale = Vector3.New(1, 1, 1)

	CachePrefabManager.Back(self.prefab)
end

function C:ctor(parent, data)
	self.data = data

	self.panelSelf = FishingLogic.GetPanel()

	self.use_fish_cfg = FishingModel.Config.use_fish_map[data.fish_type]
	self.fish_cfg = FishingModel.Config.fish_map[self.use_fish_cfg.fish_id]

	self.prefab = CachePrefabManager.Take("FishCS")
    self.prefab.prefab:SetParent(parent)
	local tran = self.prefab.prefab.prefabObj.transform
	self.transform = tran
	self.gameObject = tran.gameObject
	tran.localRotation = Quaternion.Euler(0, 0, 0)
	if data then
		self.gameObject.name = data.fish_id
	end
	self.sizeDelta = {x=self.fish_cfg.size_w, y=self.fish_cfg.size_h}

	self.m_fish_state = FishCS.FishState.FS_Nor

	self.box2d = tran:GetComponent("BoxCollider2D")
	self.lock_node = tran:Find("lock_node")
	self.hang_node = tran:Find("hang_node")

	self.fish = {}
	self.fish[#self.fish + 1] = tran:Find("cs_sheng"):GetComponent("SpriteRenderer")
	self.fish[#self.fish + 1] = tran:Find("tou/cs_zuo/cs_mz1"):GetComponent("SpriteRenderer")
	self.fish[#self.fish + 1] = tran:Find("tou/cs_you/cs_mz2"):GetComponent("SpriteRenderer")
	self.fish[#self.fish + 1] = tran:Find("tou/cs_tou"):GetComponent("SpriteRenderer")
	self.fish_tran = tran:Find("box_size"):GetComponent("Transform")

	self.anim_pay = tran:GetComponent("Animator")
	if self.anim_pay then
		self.anim_pay:Play("FishCS", -1, 0)
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:SetBox2D(true)
	self.gameObject:SetActive(true)
end

function C:MyRefresh()
end

function C:Print()
end

-- 是否在鱼池中
function C:CheckIsInPool()
	if self.m_fish_state == FishCS.FishState.FS_Flee or
		self.m_fish_state == FishCS.FishState.FS_Dead or
		self.m_fish_state == FishCS.FishState.FS_FeignDead then
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
	if self.m_fish_state == FishCS.FishState.FS_Flee or
		self.m_fish_state == FishCS.FishState.FS_Dead or
		self.m_fish_state == FishCS.FishState.FS_FeignDead then
		return false
	end
    if (math.abs(self.transform.position.x) + 0.5) < FishingModel.Defines.WorldDimensionUnit.xMax and 
    	(math.abs(self.transform.position.y) + 0.5) < FishingModel.Defines.WorldDimensionUnit.yMax then
        return true
    else
        return false
    end
end
-- 是否完全在鱼池外
function C:CheckIsOutPool_Whole()
	local pp = {}
    pp[1] = PointToWorldSpace({x=-1 * self.sizeDelta.x/2, y=self.sizeDelta.y/2}, self.fish_tran.right, self.fish_tran.up, self.fish_tran.position)
    pp[2] = PointToWorldSpace({x=1 * self.sizeDelta.x/2, y=self.sizeDelta.y/2}, self.fish_tran.right, self.fish_tran.up, self.fish_tran.position)
    pp[3] = PointToWorldSpace({x=-1 * self.sizeDelta.x/2, y=-1 * self.sizeDelta.y/2}, self.fish_tran.right, self.fish_tran.up, self.fish_tran.position)
    pp[4] = PointToWorldSpace({x=1 * self.sizeDelta.x/2, y=-1 * self.sizeDelta.y/2}, self.fish_tran.right, self.fish_tran.up, self.fish_tran.position)
    pp[5] = {x=pp[1].x, y=pp[1].y}
    local xMax = FishingModel.Defines.WorldDimensionUnit.xMax
    local yMax = FishingModel.Defines.WorldDimensionUnit.yMax
    local ww = {}
	ww[1] = {x = -1 * xMax, y = yMax}
	ww[2] = {x = 1 * xMax, y = yMax}
	ww[3] = {x = -1 * xMax, y = -1 * yMax}
	ww[4] = {x = 1 * xMax, y = -1 * yMax}
	ww[5] = {x = -1 * xMax, y = yMax}
    for i = 1, 4 do
    	local a = pp[i]
    	local b = pp[i+1]
    	for j = 1, 4 do
    		local c = ww[j]
    		local d = ww[j+1]
	    	if (math.min(a.x,b.x) <= math.max(c.x,d.x) and math.min(c.y,d.y) <= math.max(a.y,b.y)
	    		and math.min(c.x,d.x) <= math.max(a.x,b.x) and  math.min(a.y,b.y) <= math.max(c.y,d.y)) then	    		
	    		return false
	    	end
    	end
    end
    return true
end
-- 设置冰冻状态
function C:SetIceState(isIce)
end
-- 冰冻解封
function C:SetIceDeblocking()
end

function C:SetBox2D(b)
	self.box2d.enabled = b
end

-- 标记鱼假死
function C:SetFeignDead(b)
	if self.m_fish_state == FishCS.FishState.FS_Dead or self.m_fish_state == FishCS.FishState.FS_Flee then
		return
	end
	if b then
		self.m_fish_state = FishCS.FishState.FS_FeignDead
		self:SetBox2D(false)
	else
		self.m_fish_state = FishCS.FishState.FS_Nor
		self:SetBox2D(true)
	end
end

function C:Flee()
	if self.m_fish_state ~= FishCS.FishState.FS_Dead and self.m_fish_state ~= FishCS.FishState.FS_Flee and
		self.m_fish_state ~= FishCS.FishState.FS_FeignDead then

		self.m_fish_state = FishCS.FishState.FS_Flee
		self:SetBox2D(false)
		if self.anim_time then
			self.anim_time:Stop()
		end
		local a = 1
		local sa = 0.05
		self.anim_time = Timer.New(function ()
			for i = 1, #self.fish do
				self.fish[i].color = Color.New(1, 1, 1, a)
			end
			a = a - sa
		end, 0.1, 20)
		self.anim_time:Start()
	end
end

function C:Hit()
	if self.m_fish_state ~= FishCS.FishState.FS_Dead and self.m_fish_state ~= FishCS.FishState.FS_Flee then
		self.m_fish_state = FishCS.FishState.FS_Hit
		if self.anim_time then
			self.anim_time:Stop()
		end
		for i = 1, #self.fish do
			self.fish[i].color = Color.New(1, 0.1, 0.2, 1)
		end
		self.anim_time = Timer.New(function ()
			for i = 1, #self.fish do
				self.fish[i].color = Color.New(1, 1, 1, 1)
			end
			self.anim_time = nil
			self.m_fish_state = FishCS.FishState.FS_Nor
		end, 0.1, 1)
		self.anim_time:Start()
	end
end

function C:Dead(_dead_index)
	self:ShowDead(_dead_index)
end

-- 死亡表现
function C:ShowDead(_dead_index)
	ExtendSoundManager.PlaySound(audio_config.by.bgm_by_beikejiangli.audio_name)
	self:SetBox2D(false)
	self.m_fish_state = FishCS.FishState.FS_Dead
	if self.anim_time then
		self.anim_time:Stop()
	end

	if self.data.fish_id then
		VehicleManager.RemoveVehicle(self.data.fish_id)
	end
	for i = 1, #self.fish do
		self.fish[i].color = Color.New(1, 1, 1, 1)
	end
	local dead_index = 1
	if _dead_index then
		dead_index = _dead_index
	end
	if self.anim_pay then
		self.anim_pay:Play("FishCS_siwang", -1, 0)
	end

	local dead_cfg = FishingModel.Config.fish_dead_map[dead_index] or FishingModel.Config.fish_dead_map[1]

	self.anim_time = Timer.New(function ()
		self.anim_time:Stop()
		self.anim_time = nil
		self:MyExit()
	end, 1, 1)
	self.anim_time:Start()

	if self.data.fish_id then
		Event.Brocast("fish_out_pool", "fish_out_pool", self.data.fish_id)
	end
end

--鱼的类型
function C:GetFishType()
	return "cs"
end

--鱼的特殊奖励？？？
function C:GetFishAward()
	return nil
end
-- 鱼的组别
function C:GetFishGroup()
	return self.data.group_id
end

-- 鱼的额外属性
function C:GetFishAttr()
	return self.use_fish_cfg.attr_id
end
-- 鱼是否是敢死队
function C:GetFishTeam()
	return self.data.isTeam
end

-- 鱼的倍率
function C:GetFishRate()
	return self.fish_cfg.rate
end
-- 锁定点
function C:GetLockPos()
	return self.lock_node.transform.position
end
-- 鱼的名字 图片
function C:GetFishNameToSprite()
	return self.fish_cfg.name_image
end

-- 爆炸表现 pos是爆炸鱼的坐标
function C:BoomHit(pos)
end
function C:GetPos()
	local tpos = self.transform.position
	return Vector3.New(tpos.x, tpos.y, 0)
end