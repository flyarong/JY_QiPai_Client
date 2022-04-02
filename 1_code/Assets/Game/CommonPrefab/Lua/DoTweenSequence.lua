-- 创建时间:2019-05-06
-- 对 DoTween 的封装

local basefunc = require "Game/Common/basefunc"
local isDebug = false
DoTweenSequence = basefunc.class()

local C = DoTweenSequence

C.name = "DoTweenSequence"


function C.Create(parm)
	return C.New(parm)
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

function C:ctor(parm)
	self:MakeLister()
    self:AddMsgListener()

    if isDebug then
    	self.traceback = debug.traceback()
    end

    self.seq = DG.Tweening.DOTween.Sequence()
    DOTweenManager.total_create_count = DOTweenManager.total_create_count + 1

    local nn = 0
    -- 尝试3次
    while( DOTweenManager.IsHaveHashCode( self.seq:GetHashCode() ) and nn < 3 ) do
    	DOTweenManager.total_error_count = DOTweenManager.total_error_count + 1
    	self.seq = DG.Tweening.DOTween.Sequence()
	    DOTweenManager.total_create_count = DOTweenManager.total_create_count + 1
    	nn = nn + 1
    end
    if AppDefine.IsEDITOR() then
	    if nn > 0 then
	    	local pp = DOTweenManager.total_error_count / DOTweenManager.total_create_count
	    	HintPanel.Create(1, "创建Sequence 尝试" .. nn .. "次(只在编辑器下提示,截图发给客户端程序)\n错误率:"..pp)
	    end
    end

    DOTweenManager.AddSequenceHashCode(self.seq:GetHashCode())

    if parm and parm.dotweenLayerKey then
    	self.dotweenLayerKey = parm.dotweenLayerKey
    	self.tweenKey = DOTweenManager.AddTweenToLayer(self, self.dotweenLayerKey)
    else
	    self.tweenKey = DOTweenManager.AddTweenToStop(self)
    end

	self.seq:OnComplete(function ()
		self:selfComplete()
	end)
	self.seq:OnKill(function ()
		self:selfKill()
	end)
end
function C:selfComplete()
	self.run_comp = true
	if self.call_complete then
		self.call_complete()
	end
end
function C:selfKill()
	if self.dotweenLayerKey then
		DOTweenManager.RemoveLayerTween(self.tweenKey)
	else
		DOTweenManager.RemoveStopTween(self.tweenKey)
	end
	if not self.run_comp and not self.force_kill then
		if isDebug and self.call_complete then
			print("<color=red>DoTween Complete 没有执行 但是设置了complete的回调，请查看</color>")
	    	print(self.traceback)
	    end
	end
	if self.call_kill then
		self.call_kill()
	end
	if self.call_force_kill then
		self.call_force_kill(self.force_kill)
	end
	DOTweenManager.DelSequenceHashCode(self.seq:GetHashCode())
	self.seq = nil
end
function C:Kill()
	if self.seq then
		self.call_kill = nil
		self.force_kill = true
		self.seq:Kill()
	end
end
function C:AppendInterval(t)
	self.seq:AppendInterval(t)
	return self
end
function C:Append(tween)
	self.seq:Append(tween)
	return self
end
function C:Join(tween)
	self.seq:Join(tween)
	return self
end
function C:Insert(t,tween)
	self.seq:Insert(t,tween)
	return self
end
function C:OnComplete(call)
	self.call_complete = call
	return self
end
function C:OnKill(call)
	self.call_kill = call
	return self
end
-- 一定会执行的Kill
-- 比如 回收缓存对象的操作
function C:OnForceKill(call)
	self.call_force_kill = call
	return self
end
function C:OnUpdate(call)
	self.seq:OnUpdate(call)
	return self	
end
function C:AppendCallback(call)
	self.seq:AppendCallback(call)
	return self		
end
function C:SetEase(call)
	self.seq:SetEase(call)
	return self		
end
function C:SetLoops(loops,loop_type)
	self.seq:SetLoops(loops, loop_type)
	return self
end

function C:OnStart(call)
	self.seq:OnStart(call)
	return self	
end