local basefunc = require "Game/Common/basefunc"

LTQF_EnterPrefab = basefunc.class()
local C = LTQF_EnterPrefab
C.name = "LTQF_EnterPrefab"
C.lottery_type = "gratitude_propriety"
local config = LTQFManager.config
local LOTTERY_TYPE = C.lottery_type

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end


function C:ctor(parent)
	local obj = newObject("ltqf_btn", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self) 
	self.transform.localPosition = Vector3.zero
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
		PlayerPrefs.SetString(LTQFManager.key .. MainModel.UserInfo.user_id, os.time())
		self:MyRefresh()
	end)
	self:MyRefresh()
end

function C:OnEnterClick()
	ActivityLTQFPanel.Create()
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.Red) then
		return
	end
	self.Red.gameObject:SetActive(false)
	self.LFL.gameObject:SetActive(false)
	local data = LTQFManager.GetData()
	if not data then return end
	if data.at_status == ACTIVITY_HINT_STATUS_ENUM.AT_Nor then

	elseif data.at_status == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
		self.Red.gameObject:SetActive(true)
	elseif data.at_status == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		self.LFL.gameObject:SetActive(true)
	end
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == LTQFManager.key then
		self:MyRefresh()
	end
end