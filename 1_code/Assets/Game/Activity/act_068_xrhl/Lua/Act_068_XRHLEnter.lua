-- 创建时间:2021-09-18
-- Panel:Act_068_XRHLEnter
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_068_XRHLEnter = basefunc.class()
local C = Act_068_XRHLEnter
C.name = "Act_068_XRHLEnter"
local M = Act_068_XRHLManager

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
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
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
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	if DdzFreeClearing and DdzFreeModel and DdzFreeModel.data and (DdzFreeModel.data.status == DdzFreeModel.Status.settlement or DdzFreeModel.data.status == DdzFreeModel.Status.gameover) then
		self.gameObject.name = "Act_068_XRHLEnter_1"
	end
	
	if MjXzClearing and MjXzModel and MjXzModel.data and (MjXzModel.data.status == MjXzModel.Status.settlement or MjXzModel.data.status == MjXzModel.Status.gameover) then
		self.gameObject.name = "Act_068_XRHLEnter_1"
	end
end

function C:InitUI()
	self.btn = self.transform:GetComponent("Button")
	self.btn.onClick:AddListener(function()
		self:OnClickEnter()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshLFL()
end

function C:RefreshLFL()
	if M.IsHint() then
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
	end
end

function C:OnClickEnter()
	Act_068_XRHLPanel.Create()
end

function C:on_global_hint_state_change_msg()
	self:MyRefresh()
end
