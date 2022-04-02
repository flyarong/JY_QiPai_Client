-- 创建时间:2019-03-07

local basefunc = require "Game/Common/basefunc"

SteeringForArrive = basefunc.class(Steering)

function SteeringForArrive:ctor(parm)
	SteeringForArrive.super.ctor(self,parm)

	-- 到达区半径
	self.arriveRadius = 0.1
	-- 减速区半径
	self.decelerateRadius = 1
	for k,v in pairs(parm) do
		self[k] = v
	end
end

function SteeringForArrive:ComputeForce()
	deceleration = deceleration or 1
	local ToTarget = Vec2DSub(self.TargetPos , self.m_pVehicle:Pos())
	-- 计算到目标位置的距离
	local dist = Vec2DLength(ToTarget)
	local tempDistance = dist - self.arriveRadius

	if tempDistance <= 0 then
		return {x=0, y=0}
	end
	local realSpeed = Vec2DLength(self.m_pVehicle:Velocity())
    -- 在减速区
    if (tempDistance < self.decelerateRadius) then

        realSpeed = realSpeed * tempDistance / self.decelerateRadius
        if realSpeed < 1 then
        	realSpeed = 1
        end
    else--减速区外
		--确保这个速度不超过最大值
		realSpeed = math.min(dist, self.m_pVehicle:MaxSpeed())
    end
	-- 这边的处理和Seek一样，除了不需要标准化ToTarget向量
	--因为我们已经费力地计算了它的长度：dist
	realSpeed = Vec2DMultNum(ToTarget , realSpeed / dist)

	return Vec2DSub(realSpeed , self.m_pVehicle:Velocity())
end