local basefunc = require "Game/Common/basefunc"
SYSCFZXQFLB_JYFLEnterPrefab = basefunc.class()
local C = SYSCFZXQFLB_JYFLEnterPrefab
local TOTAL_NUM = 2
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
    -- self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.down then
		self.down:Stop()
		self.down = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local obj = newObject("SYSCFZXQFLB_JYFLEnterPrefab", parent)
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
	self:MyRefresh()
end

function C:MyRefresh()
	self.gameObject:SetActive(true)
end

function C:OnEnterClick()
	self:goto_qflb()
end
function C:OnGetClick()
	self:goto_qflb()
end

function C:OnDestroy()
	self:MyExit()
end

function C:goto_qflb()
	GameManager.GotoUI({gotoui = MoneyCenterQFLBManager.key,goto_scene_parm = "panel"})
end