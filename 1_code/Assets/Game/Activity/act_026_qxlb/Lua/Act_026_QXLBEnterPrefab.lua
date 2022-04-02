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

Act_026_QXLBEnterPrefab = basefunc.class()
local C = Act_026_QXLBEnterPrefab
C.name = "Act_026_QXLBEnterPrefab"
local M = Act_026_QXLBManager

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
	local obj = newObject("Act_026_QXLBEnterPrefab", parent)
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
	if not IsEquals(self.gameObject) then return end
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
end

function C:OnEnterClick()
	local b = GameComGiftT4Panel.Create(nil, nil, M.config[M.level],nil,"Act_026_QXLBPanel")
	--Act_018_MFCDJPanel.Create()
	local str = {
		"周年庆期间开启，最高可得5万金币或5元话费或5元福卡！",
		"周年庆期间开启，最高可得10万金币或10元话费或10元福卡！",
		"周年庆期间开启，最高可得20万金币或20元话费或20元福卡！",
	}
	for i = 1, 3 do
		local ui = {}
		LuaHelper.GeneratingVar(b["gift_rect"..i], ui)
		PointerEventListener.Get(ui.icon3_img.gameObject).onDown = function ()
			GameTipsPrefab.ShowDesc(str[i], UnityEngine.Input.mousePosition)
		end
		PointerEventListener.Get(ui.icon3_img.gameObject).onUp = function ()
			GameTipsPrefab.Hide()
		end
		ui.icon3_img.transform.localScale = Vector3.New(0.6,0.6,0.6)
	end
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then 
		self:MyRefresh()
	end 
end