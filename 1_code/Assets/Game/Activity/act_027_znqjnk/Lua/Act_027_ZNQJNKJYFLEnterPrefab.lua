-- 创建时间:2019-10-23
-- Panel:SYSYK_JYFLEnterPrefab
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

Act_027_ZNQJNKJYFLEnterPrefab = basefunc.class()
local C = Act_027_ZNQJNKJYFLEnterPrefab

function C.CheckIsShow(cfg)
	if not cfg.is_on_off or cfg.is_on_off == 0 then
		return
	end

	return true
end

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
	self.lister["ui_button_data_change_msg"] = basefunc.handler(self, self.MyRefresh)
	
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

function C:ctor(parent, parm)
	self.parm = parm
	ExtPanel.ExtMsg(self)
	local obj = newObject("JYFLCellPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.get_img = self.get_btn.transform:GetComponent("Image")

	self:MakeLister()
	self:AddMsgListener()

	self:InitUI()
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self.get_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGetClick()
	end)
	self.title_img.sprite = GetTexture("ad_2znjnk_btn_jnk")
	self.title_img:SetNativeSize()
	self.title_img.transform.localScale = Vector3.one * 0.6
	self.title_txt.text = "2周年纪念卡"
	self.info_txt.text = "每日登录都可领取巨额奖励！"
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	if Act_027_ZNQJNKManager.getIsBuy() then 
		if not Act_027_ZNQJNKManager.getIsLottery() then 
			self.get_txt.text = "已 领 取"
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("com_btn_8")
		else
			self.get_txt.text = "领  取"
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
		end 
	else 
		self.get_txt.text = "去 购 买"
		self.get_btn.transform:GetComponent("Image").sprite = GetTexture("com_btn_5")
	end
end

function C:OnEnterClick()
	GameManager.GotoUI({gotoui = Act_027_ZNQJNKManager.key, goto_scene_parm="panel"})
end
function C:OnGetClick()
	GameManager.GotoUI({gotoui = Act_027_ZNQJNKManager.key, goto_scene_parm="panel"})	
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == Act_027_ZNQJNKManager.key then
		self:MyRefresh()
	end
end