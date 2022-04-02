-- 创建时间:2019-05-29
-- Panel:GameBroadcastBulletSendPanel
local basefunc = require "Game/Common/basefunc"

GameBroadcastBulletSendPanel = basefunc.class()
local C = GameBroadcastBulletSendPanel
C.name = "GameBroadcastBulletSendPanel"
local this

function C.Create(parent)
	this = C.New(parent)
	return this
end

function C.Close()
	if this then
		this:MyExit()
		this = nil
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.onExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	destroy(self.gameObject)
	self.data = nil
	self.ui = nil
	self:RemoveListener()

	 
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	self.ui = {}
	self.ui.transform = obj.transform
	self.ui.gameObject = obj
	self.gameObject = obj
	self.data = {}
	self.data.query_index = 1
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	LuaHelper.GeneratingVar(self.ui.transform, self.ui)
	self.TopButton = self.ui.top_button.transform:GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButton.gameObject).onClick = basefunc.handler(self, self.MyExit)
	self:CreateItems(GameBroadcastManager.GetFMCfg().vice)
end

function C:MyRefresh()

end

function C:OnBackClick()
	self:MyExit()
end

function C:onExitScene()
	self:MyExit()
end

function C:CreateItems(data)
	if not data or not next(data) then return end
	for i,v in ipairs(data) do
		local obj = GameObject.Instantiate(self.ui.cell,self.ui.content)
		local t = {}
		LuaHelper.GeneratingVar(obj.transform,t)
		t.dec_txt.text = v.content
		t.bg.gameObject:SetActive(i % 2 == 0)
		t.send_btn.onClick:AddListener(function ()
			Event.Brocast("multicast_msg", "multicast_msg", {type = 3,master = v.master, content=v.content})
		end)
		obj.transform:SetSiblingIndex(i)
		obj.gameObject:SetActive(true)
	end
end