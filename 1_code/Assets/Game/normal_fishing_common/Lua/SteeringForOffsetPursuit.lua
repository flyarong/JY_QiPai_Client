-- 创建时间:2019-03-07

local basefunc = require "Game/Common/basefunc"

SteeringForOffsetPursuit = basefunc.class(Steering)

function SteeringForOffsetPursuit:ctor(parm)
	SteeringForOffsetPursuit.super.ctor(self,parm)

	-- 领头
	self.leader = nil
	-- 偏移
	self.offset = {x=0, y=0}
	if parm and next(parm) then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
	self.arrive = SteeringForArrive.New(parm)
end

function SteeringForOffsetPursuit:ComputeForce()
	-- 在世界空间中计算偏移的位置
	local WorldOffsetPos = PointToWorldSpace(self.offset, self.leader:Heading(), self.leader:Side(), self.leader:Pos())
	local ToOffset = Vec2DSub( WorldOffsetPos , self.m_pVehicle:Pos() )
	-- 预期的时间正比于领队与追逐者的距离
	-- 反比于两个智能体的速度之和
	local LookAheadTime = Vec2DLength(ToOffset) / (self.m_pVehicle:MaxSpeed() + self.leader:Speed())
	-- 现在到达偏移的预测位置
	self.arrive.TargetPos = Vec2DAdd(WorldOffsetPos , Vec2DMultNum(self.leader:Velocity() , LookAheadTime))	
	return self.arrive:ComputeForce()
end

