-- 创建时间:2019-11-21
-- Panel:SJJLPanel
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

SJJLPanel = basefunc.class()
local C = SJJLPanel
C.name = "SJJLPanel"

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
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	self.parm = parm
	local parent = parm.parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.get_award_btn.onClick:AddListener(
		function ()
			Network.SendRequest("get_task_award", {id = SJJLManager.taskid})
		end
	)
	self:MyRefresh()
end

function C:MyRefresh() 
	if SJJLManager.GetStatus() == 2 then 
		self.get_award_mask.gameObject:SetActive(true)
	else
		self.get_award_mask.gameObject:SetActive(false)
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_model_task_change_msg(data)
	if data.id ~= SJJLManager.taskid then return end
	self:MyRefresh() 
	Event.Brocast("global_hint_state_change_msg", {gotoui = SJJLManager.key})
end