-- 创建时间:2019-03-12
-- 原地等待

local basefunc = require "Game/Common/basefunc"

SteeringForWait = basefunc.class(Steering)

function SteeringForWait:ctor(parm)
	SteeringForWait.super.ctor(self,parm)

	-- 停留时间
	self.waitTime = parm.waitTime
	self.runTime = 0
end

function SteeringForWait:ComputeForce()
	self.runTime = self.runTime + self.m_pVehicle.time_elapsed
	if self.runTime >= self.waitTime then
		self.m_pVehicle:FinishStep()
	end
	return
end
