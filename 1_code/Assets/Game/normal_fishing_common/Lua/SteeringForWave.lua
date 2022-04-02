-- 创建时间:2019-03-08
-- 运动方式：仿正弦波

local basefunc = require "Game/Common/basefunc"

SteeringForWave = basefunc.class(Steering)

function SteeringForWave:ctor(parm)
	SteeringForWave.super.ctor(self,parm)

	-- 波的高度
	self.waveH = 100
	-- 半波的长度
	self.waveLen = 200
	-- 启动方向是否向上
	self.isUp = true
	for k,v in pairs(parm) do
		self[k] = v
	end

	self.isInitBegin = false
	self.beginHead ={x=1, y=0}
	self.beginSide ={x=0, y=1}
	self.runA = 0
	self.xiangxian = 0
end

function SteeringForWave:ComputeForce()
	if true then
		local a = 180 * Vec2DLength(self.m_pVehicle:Velocity()) * self.m_pVehicle.time_elapsed / (math.pi * self.radius)

		self.runA = self.runA + a

		local rr = math.floor(self.runA/90) % 4
		if self.xiangxian and ((self.xiangxian == 0 and rr == 1) or (self.xiangxian == 2 and rr == 3)) then
			self.isUp = not self.isUp
		end
		if self.isUp then
			a = -a
		end
		self.xiangxian = rr

		local ToTarget = Vec2DRotate(self.m_pVehicle:Velocity(), a)
		return Vec2DMultNum(Vec2DSub(ToTarget , self.m_pVehicle:Velocity()), 1/self.m_pVehicle.time_elapsed) 
	end

	if false then
		if not self.isInitBegin then
			self.isInitBegin = true
			self.beginHead = self.m_pVehicle:Heading()
			self.beginSide = self.m_pVehicle:Side()
			self.beginSideno = {x=-self.beginSide.x, y=-self.beginSide.y}
			self.beginPos = self.m_pVehicle:Pos()
		end

		local Pt = Vec2DSub(self.m_pVehicle:Pos() , self.beginPos)
		local P1 = Vec2DTruncateToLen(self.beginHead, Vec2DDotMult(Pt, self.beginHead))
		local P2 = Vec2DSub(Pt , P1)
		local p2len = Vec2DLength(P2)
		local cha = self.waveH - p2len
		local fang
		fang = Vec2DTruncateToLen(self.beginSide , cha)

		return fang
	end
end

