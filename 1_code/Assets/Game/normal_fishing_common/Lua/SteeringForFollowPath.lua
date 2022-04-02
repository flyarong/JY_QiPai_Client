-- 创建时间:2019-03-07

local basefunc = require "Game/Common/basefunc"

SteeringForFollowPath = basefunc.class(Steering)

function SteeringForFollowPath:ctor(parm)
	SteeringForFollowPath.super.ctor(self,parm)

	-- 当前巡逻点
	self.currentWPIndex = 1
	-- 是否结束巡逻
	self.isPatrolComplete = false
	-- 停止巡逻距离
	self.patrolArrivalDistance = 0.15
	-- 巡逻方式1一次 2循环 3往返
	self.patroMode = 1
	-- 巡逻点
	self.WayPoints = {}
	if parm and next(parm) then
		for k,v in pairs(parm) do
			self[k] = v
		end
	end
end

function SteeringForFollowPath:ComputeForce()
	local ToTarget = Vec2DSub(self.WayPoints[self.currentWPIndex] , self.m_pVehicle:Pos())

	local len = Vec2DLength(ToTarget)
    local ss = self:GetDepth(len)

    if len < self.patrolArrivalDistance then
        if self.currentWPIndex == #self.WayPoints then
            if self.patroMode == 1 then
                    self.isPatrolComplete = true
                    self.m_pVehicle:FinishStep()
                    return {x=0,y=0}
            elseif self.patroMode == 3 then
            	local data = {}
            	for i=#self.WayPoints, 1, -1 do
            		data[#data + 1] = self.WayPoints[i]
            	end
            	self.WayPoints = data
            end
        end
        self.currentWPIndex = self.currentWPIndex + 1
        if self.currentWPIndex > #self.WayPoints then
        	self.currentWPIndex = 1
        end
    end
    self.expectForce = Vec2DMultNum(Vec2DNormalize(ToTarget) , self.m_pVehicle:MaxSpeed())
    return Vec2DSub(self.expectForce , self.m_pVehicle:Velocity()),ss

end

-- 扩展 3D增加深度表现
function SteeringForFollowPath:GetDepth(len)
    local ss
    local mm1
    local cha
    if self.WayPoints[self.currentWPIndex].z then
        if self.currentWPIndex == 1 then
            ss = self.WayPoints[self.currentWPIndex].z
        elseif self.WayPoints[self.currentWPIndex - 1] and self.WayPoints[self.currentWPIndex - 1].z then
            mm1 = Vec2DLength(Vec2DSub(self.WayPoints[self.currentWPIndex] , self.WayPoints[self.currentWPIndex-1]))
            len = mm1 - len
            cha = self.WayPoints[self.currentWPIndex].z - self.WayPoints[self.currentWPIndex-1].z
            ss = len / mm1
            if ss > 1 then
                ss = 1
            end
            ss = cha * ss + self.WayPoints[self.currentWPIndex-1].z
        elseif self.WayPoints[self.currentWPIndex + 1] and self.WayPoints[self.currentWPIndex + 1].z then
            mm1 = Vec2DLength(Vec2DSub(self.WayPoints[self.currentWPIndex] , self.WayPoints[self.currentWPIndex+1]))
            len = mm1 - len
            cha = self.WayPoints[self.currentWPIndex+1].z - self.WayPoints[self.currentWPIndex].z
            ss = len / mm1
            if ss > 1 then
                ss = 1
            end
            ss = cha * ss + self.WayPoints[self.currentWPIndex].z
        else
            ss = 0
        end 
    end
    if ss then
        if ss < 0 then
            ss = 0
        end
        if ss > 100 then
            ss = 100
        end
        ss = ss / 100
        -- if self.currentWPIndex == 1 or self.currentWPIndex == 2 then
        --     print(ss .. "  <color=red>ddddd</color>")
        --     dump(len)
        --     dump(self.currentWPIndex)
        --     dump(cha)
        -- end
    end
    return ss
end
