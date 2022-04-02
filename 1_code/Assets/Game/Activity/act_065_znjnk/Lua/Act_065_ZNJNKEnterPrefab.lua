-- 创建时间:2019-12-24
-- Panel:HQYD_EnterPrefab
--[[
*      ┌─┐       ┌─┐
*   ┌──┘ ┴───────┘ ┴──┐
*   │                 │
*   │       ───       │
*   │  ─┬┘       └┬─  │
*   │                 │
*   │       ─┴─       │
*   │                 │
*   └───┐         ┌───┘
*       │         │
*       │         │
*       │         │
*       │         └──────────────┐
*       │                        │
*       │                        ├─┐
*       │                        ┌─┘
*       │                        │
*       └─┐  ┐  ┌───────┬──┐  ┌──┘
*         │ ─┤ ─┤       │ ─┤ ─┤
*         └──┴──┘       └──┴──┘
*                神兽保佑
*               代码无BUG!
--]]

local basefunc = require "Game/Common/basefunc"

Act_065_ZNJNKEnterPrefab = basefunc.class()
local C = Act_065_ZNJNKEnterPrefab
C.name = "Act_065_ZNJNKEnterPrefab"

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
	GameManager.GotoUI({gotoui = "act_065_znjnk",goto_scene_parm = "jyfl_enter"})
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject("Act_065_ZNJNKEnterPrefab", parent)
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
		PlayerPrefs.SetString(Act_065_ZNJNKManager.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
		self:OnEnterClick()
		self:MyRefresh()
	end)
	self.icon_img = self.transform:Find("Image"):GetComponent("Image")
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	if Act_065_ZNJNKManager.GetHintState({gotoui = Act_065_ZNJNKManager.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
		if PlayerPrefs.GetString(Act_065_ZNJNKManager.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.Red.gameObject:SetActive(false)
		else
			self.Red.gameObject:SetActive(true)
		end 
	end
	-- local is_buy = Act_065_ZNJNKManager.getIsBuy()
	-- if is_buy then
	-- 	local is_lottery = Act_065_ZNJNKManager.getIsLottery()
	-- 	if is_lottery then
	-- 		self.icon_img.material = nil
	-- 	else
	-- 		self.icon_img.material = GetMaterial("imageGrey")
	-- 	end
	-- end
end

function C:OnEnterClick()
	Act_065_ZNJNKPanel.Create()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == Act_065_ZNJNKManager.key then 
		self:MyRefresh()
	end 
end