local basefunc = require "Game/Common/basefunc"

Act_042_MPDHEnterPrefab = basefunc.class()
local M = Act_042_MPDHEnterPrefab
M.name = "Act_042_MPDHEnterPrefab"
local Mgr = Act_042_MPDHManager

function M.Create(parent)
	return M.New(parent)
end

function M:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function M:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
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

function M:OnDestroy()
	self:RemoveListener()
	destroy(self.gameObject)
end

function M:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("Act_042_MPDHEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
		self:MyRefresh()
	end)
	-- self.icon_img = self.transform:Find("Image"):GetComponent("Image")
	self:MyRefresh()
end

function M:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	local state = Mgr.GetHintState({gotoui = Mgr.key})
	self.LFL.gameObject:SetActive(state == ACTIVITY_HINT_STATUS_ENUM.AT_Get)
	self.Red.gameObject:SetActive(state == ACTIVITY_HINT_STATUS_ENUM.AT_Red)
end

function M:OnEnterClick()
	Event.Brocast("global_hint_state_set_msg",{gotoui = Mgr.key})
	Act_042_MPDHPanel.Create()
end

function M:on_global_hint_state_change_msg(parm)
	if parm.gotoui == Mgr.key then 
		self:MyRefresh()
	end 
end