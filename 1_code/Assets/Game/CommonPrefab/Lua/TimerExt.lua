-- 创建时间:2020-04-09

local basefunc = require "Game/Common/basefunc"
local isDebug = true
TimerExt = basefunc.class()
local C = TimerExt

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

function C:ctor(func, duration, loop, scale, fixdur)
	self:MakeLister()
    self:AddMsgListener()

    if isDebug then
    	self.traceback = debug.traceback()
    end

	self._timer = Timer.New(func, duration, loop, scale, fixdur)
    self._timerKey = TimerManager.AddTimer(self)
end

function C:ShowDebug()
    if isDebug then
		print(self.traceback)
	end
end

function C:Start()
	self._timer:Start()
	return self
end
function C:Stop()
	self._timer:Stop()
	return self
end
function C:Reset(func, duration, loop, scale, fixdur)
	self._timer:Reset(func, duration, loop, scale)
	return self
end
function C:SetStopCallBack(stopfunc)
	self._timer:SetStopCallBack(stopfunc)
	return self
end



-- 停止且关闭
function TimerExt.StopAndClose(_timer)
	if _timer then
		TimerManager.RemoveTimer(_timer._timerKey)
	end
	_timer = nil
end
