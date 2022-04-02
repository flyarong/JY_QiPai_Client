local basefunc = require "Game/Common/basefunc"

EliminateFXHelpPanel = basefunc.class()
local C = EliminateFXHelpPanel
C.name = "EliminateFXHelpPanel"

local instance
function C.Create()
	if not instance then
		instance = C.New()
	else
		instance:MyRefresh()
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["view_quit_game"] = basefunc.handler(self, self.Close)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:Close()
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
	instance = nil
	GameObject.Destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
	self.back_btn.onClick:AddListener(
		function ()
			self:Close()
		end
	)
	self.selet1_btn.onClick:AddListener(
		function ()
			self:OnSeletClick(1)
		end
	)
	self.selet2_btn.onClick:AddListener(
		function ()
			self:OnSeletClick(2)
		end
	)
	self.selet3_btn.onClick:AddListener(
		function ()
			self:OnSeletClick(3)
		end
	)
	self.selet4_btn.onClick:AddListener(
		function ()
			self:OnSeletClick(4)
		end
	)
	self:OnSeletClick(1)
end

function C:MyRefresh()

end

function C:OnSeletClick(index)
	for i=1,4 do
		self["selet" .. i .. "_btn"].gameObject:SetActive(index ~= i)
		self["selet" .. i .. "_img"].gameObject:SetActive(index == i)
		self["node" .. i].gameObject:SetActive(index == i)
	end
end