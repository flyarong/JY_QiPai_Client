local basefunc = require "Game/Common/basefunc"

SDQQLEnterPrefab = basefunc.class()
local C = SDQQLEnterPrefab
C.name = "SDQQLEnterPrefab"
C.lottery_type = "christmas_break"
local config = SDQQLManager.config
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
	local obj = newObject("sdqql_btn", parent)
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
	end)
	self:MyRefresh()
end

function C:OnEnterClick()
	ActivitySDQQLPanel.Create()
	PlayerPrefs.SetString(SDQQLManager.key .. MainModel.UserInfo.user_id, os.time())
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.Red) then
		return
	end
	self.Red.gameObject:SetActive(false)
	self.LFL.gameObject:SetActive(false)
	local data = SDQQLManager.GetData()
	if not data then return end

	local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(SDQQLManager.key .. MainModel.UserInfo.user_id, 0))))

	if data.at_status == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	elseif data.at_status == ACTIVITY_HINT_STATUS_ENUM.AT_Nor	 then 
		if 	oldtime ~= newtime then 
			self.Red.gameObject:SetActive(true)
		end 
	end 
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == SDQQLManager.key then
		self:MyRefresh()
	end
end