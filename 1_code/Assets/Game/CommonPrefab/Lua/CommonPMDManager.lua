-- 创建时间:2020-06-22
-- Panel:CommonPMDManager
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

CommonPMDManager = basefunc.class()
local C = CommonPMDManager
C.name = "CommonPMDManager"
--actvity_mode :1 左滑动,2向上滑动，居中时停止一会
local anim_funcs = {
"Anim1",
"Anim2",
}
local dotweenLayerKey = "CommonPMDManager"

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

function C:MyExit()
	DOTweenManager.KillLayerKeyTween(dotweenLayerKey)

	if self.Loop_Timer then
		self.Loop_Timer:Stop()
	end
	self:RemoveListener()
	
end

function C:ctor(parm)
	self:MakeLister()
	self:AddMsgListener()
	self.objs = self.objs or {}
	self.parent = parm.parent
	self.space_time = parm.space_time or 3
	self.life_time = parm.life_time or 20
	self.speed = parm.speed or 10
	self.actvity_mode = parm.actvity_mode or 1
	self.start_pos = parm.start_pos  or (self.actvity_mode == 1 and 1200 or -200)
	self.end_pos = parm.end_pos or (self.actvity_mode == 1 and -1200 or 200)
	self:DoAnim()
	self.Loop_Timer = Timer.New(function ()
		self:DoAnim()
	end, self.space_time, -1)
	self.Loop_Timer:Start()
end

--当展示区域没有任何一个物体的时,某个物体出现
function C:SetOnStartCall(backcall)
	self.onStartCall = backcall
end

--当展示区域只剩下一个物体,这个物体即将消失时
function C:SetOnEndCall(backcall)
	self.onEndCall = backcall
end

function C:DoAnim(obj)
	obj = self.objs[1]
	table.remove(self.objs,1)
	if not obj or not IsEquals(obj) then return end
	C[anim_funcs[self.actvity_mode]](self, obj)
end

function C:AddObj(obj)
	if #self.objs >= 20 then
		destroy(obj.gameObject)
		return
	end
	obj.transform.parent = self.parent
	obj.transform.localPosition = self.actvity_mode == 1 and Vector2.New(self.start_pos,0) or Vector2.New(0,self.start_pos)
	self.objs[#self.objs + 1] = obj	
	if #self.objs == 1 then
		if self.onStartCall then
			self.onStartCall()
		end
	end
end

--横着走
function C.Anim1(Self,obj)
	local tran = obj.transform
	tran.localPosition = Vector3.New(Self.start_pos, 0, 0)
	local seq = DoTweenSequence.Create({dotweenLayerKey=dotweenLayerKey})
	seq:Append(tran:DOLocalMoveX(Self.end_pos, Self.speed))
	seq:OnKill(function ()
		if IsEquals(obj) then
			destroy(obj.gameObject)
		end
		if #Self.objs == 0 then
			if Self.onEndCall then
				Self.onEndCall()
			end
		end
	end)
	seq:OnForceKill(function ()
        if IsEquals(obj) then
			destroy(obj.gameObject)
		end
    end)
end

--竖着走
function C.Anim2(Self,obj)
	local tran = obj.transform
	tran.localPosition = Vector3.New(0, Self.start_pos, 0)
	local seq = DoTweenSequence.Create({dotweenLayerKey=dotweenLayerKey})
	seq:Append(tran:DOLocalMoveY(0, 1.5))
	seq:AppendInterval(1)
	seq:Append(tran:DOLocalMoveY(100, 1.5))
	seq:OnKill(function ()
		if IsEquals(obj) then
			destroy(obj.gameObject)
		end
		if #Self.objs == 0 then
			if Self.onEndCall then
				Self.onEndCall()
			end
		end
	end)
end

function C:Demo()
	local b =CommonPMDManager.Create({
		parent =  self.parent.transform,
		actvity_mode = 2
	})
	b:SetOnStartCall(function ()
		print("<color=red>正在开始</color>")
	end)
	b:SetOnEndCall(function ()
		print("<color=red>正在结束</color>")
	end)
	for i = 1,3 do
		b:AddObj(GameObject.Instantiate(self.obj.gameObject,self.parent.transform))
	end
end