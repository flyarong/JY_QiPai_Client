local basefunc = require "Game/Common/basefunc"

Act_052_JBZKEnterPrefab = basefunc.class()
local C = Act_052_JBZKEnterPrefab
C.name = "Act_052_JBZKEnterPrefab"

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
	self.lister["AssetChange"] = basefunc.handler(self, self.MyRefresh)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
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

function C:OnDestroy()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("Act_052_JBZKEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		PlayerPrefs.SetString(Act_052_JBZKManager.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
		self:OnEnterClick()
		self:MyRefresh()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	if Act_052_JBZKManager.GetHintState({gotoui = Act_052_JBZKManager.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
		if PlayerPrefs.GetString(Act_052_JBZKManager.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.Red.gameObject:SetActive(false)
		else
			self.Red.gameObject:SetActive(true)
		end 
	end
end

function C:OnEnterClick()
	Act_052_JBZKPanel.Create()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == Act_052_JBZKManager.key then 
		self:MyRefresh()
	end 
end