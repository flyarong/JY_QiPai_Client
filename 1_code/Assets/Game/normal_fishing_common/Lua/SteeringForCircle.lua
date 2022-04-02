-- 创建时间:2019-03-07
-- 运动方式：绕圆圈

local basefunc = require "Game/Common/basefunc"

SteeringForCircle = basefunc.class(Steering)

function SteeringForCircle:ctor(parm)
	SteeringForCircle.super.ctor(self,parm)

	-- 到达区半径
	self.radius = 200
	-- 旋转方向
	self.isPerp = true
	-- 旋转总角度
	self.angle = 360
	for k,v in pairs(parm) do
		self[k] = v
	end

	self.runA = 0
end

function SteeringForCircle:ComputeForce()
	local a = 180 * Vec2DLength(self.m_pVehicle:Velocity()) * self.m_pVehicle.time_elapsed / (math.pi * self.radius)
	self.runA = self.runA + a
	if self.runA >= self.angle then
		self.m_pVehicle:FinishStep()
	end

	if self.isPerp then
		a = -a
	end
	local ToTarget = Vec2DRotate(self.m_pVehicle:Velocity(), a)
	return Vec2DMultNum(Vec2DSub(ToTarget , self.m_pVehicle:Velocity()), 1/self.m_pVehicle.time_elapsed) 
end
