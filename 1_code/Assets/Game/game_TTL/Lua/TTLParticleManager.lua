-- 创建时间:2020-03-27
-- Panel:TTLParticleManager
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

TTLParticleManager = basefunc.class()
local C = TTLParticleManager
C.name = "TTLParticleManager"

function C.Create(pre_name,parent,pos,score,end_point,type)
	return C.New(pre_name,parent,pos,score,end_point,type)
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
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(pre_name,parent,pos,score,end_point,type)
	local parent =parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(pre_name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	if pos then
		self.transform.localPosition = pos
	end
	if score then
		self.score_txt.transform:GetComponent("Text").text="+"..score
		self.seq = DoTweenSequence.Create()
		local t
		if	type~="normal" then
			self.transform.localScale=Vector3.New(2,2,2)
			t=1.5
		else
			t=0.5
		end
		self.seq:Append(self.transform:DOLocalMove(self.transform.localPosition+Vector3.New(0,50,0),t))
		self.seq:OnKill(function ()
		self:MyExit()
		-- body
		end)
	end

	if end_point then
		local line_read=self.transform:GetComponent("LineRenderer")
		line_read.positionCount = 2
		line_read:SetPosition(0, Vector3.New(pos.x,pos.y-540,0) )
		line_read:SetPosition(1, Vector3.New(end_point.x,end_point.y-540,0))
	end


	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self:AutoDie()

end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end


--自動死亡
function C:AutoDie()
		self.timer = Timer.New(function ()
			            	self:MyExit()
						end,10,1,false)
		self.timer:Start()
		-- body
end