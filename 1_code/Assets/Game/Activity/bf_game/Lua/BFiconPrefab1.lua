-- 创建时间:2020-06-16

local basefunc = require "Game/Common/basefunc"

BFiconPrefab1 = basefunc.class()
local C = BFiconPrefab1
C.name = "BFiconPrefab1"

function C.Create(parent)
	return C.New(parent)
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

function C:ctor(parent)
	
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

	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
		self:OnEnterClick()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnEnterClick() 
	local url = "https://xyx.yulebuyu.com/html/phone.html?type=wap&cps=1292"
	UnityEngine.Application.OpenURL(url)
end