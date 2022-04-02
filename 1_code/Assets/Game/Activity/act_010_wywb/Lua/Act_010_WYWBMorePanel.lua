
local basefunc = require "Game/Common/basefunc"

Act_010_WYWBMorePanel = basefunc.class()
local C = Act_010_WYWBMorePanel
C.name = "Act_010_WYWBMorePanel"

function C.Create()
	return C.New()
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
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
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.confirm_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end
