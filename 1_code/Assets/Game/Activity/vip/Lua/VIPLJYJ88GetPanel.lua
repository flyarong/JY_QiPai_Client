-- 创建时间:2020-04-15
-- Panel:VIPLJYJ88GetPanel
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

VIPLJYJ88GetPanel = basefunc.class()
local C = VIPLJYJ88GetPanel
C.name = "VIPLJYJ88GetPanel"

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
	self.lister["get_task_award_response"] =  basefunc.handler(self, self.on_get_task_award_response)
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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.close_btn.gameObject:SetActive(false)
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self.get_btn.onClick:AddListener(
		function()
			Network.SendRequest("get_task_award", { id = 21244})
			self:MyExit()
		end
	)
	if self.parm then
		self.dec_txt.text = self.parm.dec
	end
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:on_get_task_award_response(_,data)
	Timer.New(function()
		Event.Brocast("VIP_CloseTHENOpen","vipyjtz")
	end,1,1):Start()
end