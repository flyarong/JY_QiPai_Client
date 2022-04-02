local basefunc = require "Game/Common/basefunc"

SYSSTXTEnterPrefab = basefunc.class()
local M = SYSSTXTEnterPrefab
M.name = "SYSSTXTEnterPrefab"

function M.Create(parent, cfg)
	return M.New(parent, cfg)
end

function M:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function M:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function M:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function M:MyExit()
	

	self:RemoveListener()
	destroy(self.gameObject)
end

function M:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("SYSSTXTEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function M:OnDestroy(  )
	self:MyExit()
end

function M:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
		self:OnEnterClick()
	end)
	self:MyRefresh()
end

function M:MyRefresh()
	
end

function M:UpdateTime()
	
end

function M:OnEnterClick()
	TeacherAndPupilPanel.Create()
end

function M:OnDestroy()
	self:MyExit()
end

function M:on_global_hint_state_change_msg(parm)

end

