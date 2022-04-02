local basefunc = require "Game/Common/basefunc"

Act_016_XYXCWKEnterPrefab = basefunc.class()
local C = Act_016_XYXCWKEnterPrefab
C.name = "Act_016_XYXCWKEnterPrefab"
local M = Act_016_XYXCWKManager
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
	local obj = newObject("Act_016_XYXCWKEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("query_gift_bag_status",{gift_bag_id = M.shop_id})
	Network.SendRequest("query_chang_wan_ka_base_info")
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
	-- self.biaoqian = self.transform:Find("xyzc/btn/biaoqian")
	if M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
		-- if PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
		-- 	self.Red.gameObject:SetActive(false)
		-- else
		-- 	self.Red.gameObject:SetActive(true)
		-- end 
	end
	local status = MainModel.GetGiftShopStatusByID(M.shop_id)
	self.biaoqian.gameObject:SetActive(status == 1)
end

function C:OnEnterClick()
	local status = MainModel.GetGiftShopStatusByID(M.shop_id)
	if status == 1 or M.GetOverTime() <= os.time() or M.IsAllGet() then
		--重来没买过
		if  M.GetOverTime() == 0 then
			Act_016_XYXCWKLBPanel.Create()
		elseif M.IsAllGet() then
			Act_016_XYXCWKHintPanel.Create(1)
		else
			Act_016_XYXCWKHintPanel.Create(2)
		end
	else
		Act_016_XYXCWKPanel.Create()
	end
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then 
		self:MyRefresh()
	end 
end