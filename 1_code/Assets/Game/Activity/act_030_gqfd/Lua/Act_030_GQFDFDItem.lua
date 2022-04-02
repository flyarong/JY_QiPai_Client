Act_030_GQFDFDItem = basefunc.class()
local M = Act_030_GQFDFDItem
M.name = "Act_030_GQFDFDItem"
local Mgr = Act_030_GQFDManager
function M.Create(gift_id,parent)
	return M.New(gift_id,parent)
end

function M:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function M:MakeLister()
	self.lister = {}
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
    instance = nil
end

function M:ctor(gift_id,parent)
    ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gift_id = gift_id
	self.gift_data = MainModel.GetGiftDataByID(self.gift_id)
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
    self:MyRefresh()
end

function M:MyRefresh()
	
end

function M:OnDestroy()
	self:MyExit()
end