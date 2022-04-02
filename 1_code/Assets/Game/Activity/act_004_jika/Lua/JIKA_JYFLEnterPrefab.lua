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

JIKA_JYFLEnterPrefab = basefunc.class()
local C = JIKA_JYFLEnterPrefab

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
	self.title_img.sprite = GetTexture("xrfl_btn_zzjk")
	self.title_txt.text = "至尊季卡"
	self.info_txt.text = "最高90倍返利，立即领取，不划算包退！"
	self:MyRefresh()
end

function C:MyRefresh()
	if Act_004JIKAManager and Act_004JIKAManager.getIsBuy() then 
		if Act_004JIKAManager.getIsLottery() then 
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
	GameManager.GotoUI({gotoui = Act_004JIKAManager.key, goto_scene_parm="panel"})
end
function C:OnGetClick()
	GameManager.GotoUI({gotoui = Act_004JIKAManager.key, goto_scene_parm="panel"})	
end

function C:OnDestroy()
	self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == Act_004JIKAManager.key then
		self:MyRefresh()
	end
end