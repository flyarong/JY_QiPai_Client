local basefunc = require "Game/Common/basefunc"

Act_017_SMSDEnterPrefab = basefunc.class()
local C = Act_017_SMSDEnterPrefab
C.name = "Act_017_SMSDEnterPrefab"
local M = Act_017_SMSDManager
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
	if self.update_timer then
		self.update_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("Act_017_SMSDEnterPrefab", parent)
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
		PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
		self:OnEnterClick()
		self:MyRefresh()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
		if PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.Red.gameObject:SetActive(false)
		else
			self.Red.gameObject:SetActive(true)
		end 
	end
	self:UpdateTime()
end

function C:OnEnterClick()
	Act_017_SMSDPanel.Create()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then 
		self:MyRefresh()
	end 
end
--倒计时
function C:UpdateTime()
	if self.update_timer then
		self.update_timer:Stop()
	end
	local t = self:GetDurTime(21 * 3600) - os.time()
	if t > 0 then
		self.time_txt.text = StringHelper.formatTimeDHMS2(t)
		self.time_node.gameObject:SetActive(true)
	else
		self.time_node.gameObject:SetActive(false)
	end
	self.update_timer = Timer.New(function ()
		t = t - 1
		if t > 0 then
			self.time_txt.text = StringHelper.formatTimeDHMS2(t)
			self.time_node.gameObject:SetActive(true)
		else
			self.time_node.gameObject:SetActive(false)
		end
	end,1,-1)
	self.update_timer:Start()
end

--返回当前某个时间的unix时间 x 指的是 秒数 当天的 8点 x = 8 * 3600
function C:GetDurTime(x)
	local t = os.time() + 8*60*60
	local f = math.floor( t / 86400)
	return f * 86400 + x - 8*60*60
end
