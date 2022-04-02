-- 创建时间:2019-03-06
require "Game.normal_fishing_common.Lua.Vector2D"

require "Game.normal_fishing_common.Lua.Steering"
require "Game.normal_fishing_common.Lua.SteeringForArrive"
require "Game.normal_fishing_common.Lua.SteeringForFollowPath"
require "Game.normal_fishing_common.Lua.SteeringForOffsetPursuit"
require "Game.normal_fishing_common.Lua.SteeringForCircle"
require "Game.normal_fishing_common.Lua.SteeringForWave"
require "Game.normal_fishing_common.Lua.SteeringForWait"

local basefunc = require "Game/Common/basefunc"

Vehicle = basefunc.class()

local function InitBaseGameEntity()
	local data = {}
	data.ID = 0
	data.Type = 0
	data.m_vPos = {x=0,y=0}
	data.radius = 0
	data.scale = 0
	data.m_bTag=0

	return data
end

local function InitMovingEntity()
	local data = {}
	-- 当前速率
	data.m_vVelocity = {x=1, y=0}
	-- 当前速度
	data.m_vSpeed = 0
	-- 一个标准化向量，指向实体的朝向
	data.m_vHeading = {x=1, y=0}
	-- 垂直于朝向向量的向量
	data.m_vSide = {x=0, y=-1}
	-- 实体的质量
	data.m_dMass = 1
	-- 实体的最大速度
	data.m_dMaxSpeed = 1
	-- 实体产生的供以自己动力的最大力（想一下火箭和发动机推力）
	data.m_dMaxForce = 1
	-- 交通工具能旋转的最大速率（弧度每秒）
	data.m_dMaxTurnRate = 40

	return data
end

-- 智能体所在环境的所有数据和对象
local function InitGameWorld()
	local data = {}
	data.cxClient = 1
	data.cyClient = 1
	return data
end

local C = Vehicle
C.name = "Vehicle"
local Rad2Deg = 180 / math.pi

function C.Create(parent, parm)
	return C.New(parent, parm)
end

function C:ctor(parent, parm)
	local data = {}
	data = InitBaseGameEntity()
	for k,v in pairs(data) do
		self[k] = v
	end
	data = InitMovingEntity()
	for k,v in pairs(data) do
		self[k] = v
	end

	data = InitGameWorld()
	for k,v in pairs(data) do
		self[k] = v
	end

	if parm and next(parm) then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end

	-- local obj = newObject(C.name, parent)
	-- local tran = obj.transform
	-- self.transform = tran
	-- self.gameObject = obj

	self.steerings = {}
	self.m_vVelocity = Vec2DTruncateToLen(self.m_vHeading, self.m_dMaxSpeed)

	self:UpdateEntity(time_elapsed)

	self.velocity_scale = 1
	self.cur_index = 1
	self.isStart = false
	self.isFinish = false
end
function C:MyExit()
	self.isStart = false
end

function C:Start()
	self.isStart = true
end
function C:Stop()
	self.isStart = false
end
function C:SetMaxSpeed(max_speed)
	self.m_dMaxSpeed = max_speed
	self.m_vVelocity = Vec2DTruncateToLen(self.m_vHeading, self.m_dMaxSpeed)
end

function C:GetSpeed(time_elapsed)
	if self.game_entity and self.game_entity.GetSpeed then
		return self.game_entity:GetSpeed(time_elapsed)
	end
end

function C:FinishStep()
	self.cur_index = self.cur_index + 1
	if self.steerings and next(self.steerings) and self.cur_index > #self.steerings then
		-- 全部完成
		self.isFinish = true
		VehicleManager.RemoveVehicle(self.ID)

		if self.game_entity then
			FishManager.FishMoveFinish(self.game_entity.data.fish_id)
			self.game_entity = nil
		end
	end
end

function C:AddSteerings(steerings)
	self.steerings[#self.steerings+1] = steerings
end
function C:UpdateEntity(time_elapsed)
    local r = Vec2DAngle(self.m_vHeading)
	if self.gameObject and IsEquals(self.gameObject) then
		self.transform.localPosition = Vector3.New(self.m_vPos.x, self.m_vPos.y, 0)
		self.transform.rotation = Quaternion.Euler(0, 0, r)
	end

	-- 实体存在
	if self.game_entity then
		if FishingModel.IsRecoverRet then
			time_elapsed = nil
		end
		self.game_entity:UpdateTransform(self.m_vPos, r, time_elapsed)
	end	
end

function C:FrameUpdate(time_elapsed)
	if not self.isStart then
		return
	end

	if self.isFinish then
		return
	end

	local ct = time_elapsed
	while (true) do
        if ct >= FishingModel.Defines.FrameTime then
            out = self:RunCalc(FishingModel.Defines.FrameTime)
            ct = ct - FishingModel.Defines.FrameTime
            if out then
                break
            end
        else
            out = self:RunCalc(ct)
            break
        end
    end
	self:UpdateEntity(time_elapsed)

	return out
end
 function C:RunCalc(time_elapsed)
 	-- 计算操控行为的合力
	self.time_elapsed = time_elapsed
	local SteeringForce = {x=0, y=0}
	if self.steerings and next(self.steerings) then
		if not self.old_SteeringForce then -- 优化：减少一半的计算
			local list = self.steerings[self.cur_index]
			for k,v in ipairs(list) do
				local force
				force = v:ComputeForce()
				if force then
					SteeringForce = Vec2DAdd(SteeringForce, force)
				else
					SteeringForce = nil
					break
				end
			end
			self.old_SteeringForce = SteeringForce
		else
			SteeringForce = self.old_SteeringForce
			self.old_SteeringForce = nil
		end

		if SteeringForce then
			-- 加速度=力/质量
			local acceleration = Vec2DDivNum(SteeringForce, self.m_dMass)
			-- 更新速度
			self.m_vVelocity = Vec2DAdd( self.m_vVelocity , Vec2DMultNum(acceleration , time_elapsed) )
			local ss = self:GetSpeed(time_elapsed)
			if ss then
				self.m_vVelocity = Vec2DMultNum(Vec2DNormalize(self.m_vVelocity), ss)
			else
				-- 确保交通工具不超过最大速度
				self.m_vVelocity = Vec2DTruncate(self.m_vVelocity, self.m_dMaxSpeed)
			end

			local vec = Vec2DMultNum(self.m_vVelocity, self.velocity_scale)
			--更新位置
			self.m_vPos = Vec2DAdd(self.m_vPos, Vec2DMultNum(vec , time_elapsed))
			-- 如果速度远大于一个很小值，那么更新朝向
			if (Vec2DLength(self.m_vVelocity) > 0.1) then
				self.m_vHeading = Vec2DNormalize(self.m_vVelocity)
				self.m_vSide = Vec2DPerp(self.m_vHeading)
			end

			-- self:UpdateEntity(time_elapsed)
		end
	end
	return self.isFinish
 end

-- 播放逃离
function C:PlayFlee(_velocity_scale)
	if not _velocity_scale then
		_velocity_scale = 15
	end
	self.velocity_scale = _velocity_scale
end

-- 设置实体
function C:SetInstantiate(entity)
	self.game_entity = entity
	if self.game_entity then
	    local r = Vec2DAngle(self.m_vHeading)
		self.game_entity:UpdateTransform(self.m_vPos, r)
	end
end

function C:SetSeekTargetPos(TargetPos)
	self.SeekTargetPos = TargetPos
end
function C:SetFleeTargetPos(TargetPos)
	self.FleeTargetPos = TargetPos
end

function C:Heading()
	return self.m_vHeading
end

function C:Side()
	return self.m_vSide
end
function C:SetPos(pos)
	self.m_vPos = pos
end
function C:Pos()
	return self.m_vPos
end
function C:Speed()
	return Vec2DLength(self.m_vVelocity)
end
function C:MaxSpeed()
	return self.m_dMaxSpeed
end
function C:MaxForce()
	return self.m_dMaxForce
end
function C:Velocity()
	return self.m_vVelocity
end


