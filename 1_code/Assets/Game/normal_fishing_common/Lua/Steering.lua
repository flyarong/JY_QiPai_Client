-- 创建时间:2019-03-07

local basefunc = require "Game/Common/basefunc"

Steering = basefunc.class()

function Steering:ctor(parm)
	-- 操控速度
    self.speed = 1

    -- 目标
    self.TargetPos = {x=0,y=0}

    -- 权重
    self.weight = 1

    -- 实际操控力 = 期望操控力 - 当前操控力
    -- 运动体
    self.m_pVehicle = nil

    -- 期望操控力
    self.expectForce = 3

    if parm and next(parm) then
	    for k,v in pairs(parm) do
	    	self[k] = v
	    end
    end
end



