local basefunc = require "Game/Common/basefunc"

Act_032_SWITCHEnterPrefab = basefunc.class()
local C = Act_032_SWITCHEnterPrefab
C.name = "Act_032_SWITCHEnterPrefab"

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
	self.lister["AssetChange"] = basefunc.handler(self,self.OnAssetChange)
	self.lister["eliminate_show_clearpanel"]=basefunc.handler(self,self.createTips)
	self.lister["view_lottery_end"] = basefunc.handler(self, self.createTips)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.update_timer then
		self.update_timer:Stop()
	end
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
	local obj = newObject("Act_032_SWITCHEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:UpdateTime()
end

function C:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		PlayerPrefs.SetString(Act_032_SWITCHManager.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
		self:OnEnterClick()
		self:MyRefresh()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	if Act_032_SWITCHManager.GetHintState({gotoui = Act_032_SWITCHManager.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
		if PlayerPrefs.GetString(Act_032_SWITCHManager.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.Red.gameObject:SetActive(false)
		else
			self.Red.gameObject:SetActive(true)
		end 
	end
end

function C:OnEnterClick()
	Act_032_SWITCHPanel.Create()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == Act_032_SWITCHManager.key then 
		self:MyRefresh()
	end 
end

function C:UpdateTime()
	if self.update_timer then
		self.update_timer:Stop()
	end
	self.update_timer = Timer.New(
		function()
			self:MyRefresh()
		end,3,-1
	)
	self.update_timer:Start()
end

local now_add_num = 0
function C:OnAssetChange(data)
	local is_care_type = function(_type)
		for i = 1,4 do
			for j = 1,#Act_032_XXLDHManager.GetTypeName(i) do
				if _type == Act_032_XXLDHManager.GetTypeName(i)[j] then
					return true
				end
			end
		end
		return false
	end
	local find_num = function(data)
		for i = 1,#data.data do
			if is_care_type(data.data[i].asset_type) then
				now_add_num = now_add_num + data.data[i].value
			end
		end
	end

	find_num(data)
end

function C:createTips()
	if now_add_num ~= 0 then
		local b = GameObject.Instantiate(self.add_item,self.transform)
		b.transform:Find("Text"):GetComponent("Text").text = "+"..now_add_num
		now_add_num = 0
		b.gameObject:SetActive(true)
		Timer.New(
			function()
				if IsEquals(b.gameObject) then
					--destroy(b.gameObject)
				end
			end,3,1
		):Start()
	end
end