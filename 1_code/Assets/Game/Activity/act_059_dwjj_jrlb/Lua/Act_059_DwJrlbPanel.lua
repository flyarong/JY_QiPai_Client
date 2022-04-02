-- 创建时间:2021-05-25
-- Panel:Act_059_DwJrlbPanel
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

Act_059_DwJrlbPanel = basefunc.class()
local C = Act_059_DwJrlbPanel
C.name = "Act_059_DwJrlbPanel"
local M = Act_059_DwJrlbManager

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
end

local function GotoPanel(key)
    GameManager.GotoUI({gotoui = key, goto_scene_parm = "panel"})
end

function C:InitUI()
    CommonTimeManager.GetCutDownTimer(M.endTime, self.cut_timer_txt)
	self.fkfl_btn.onClick:AddListener(function()
		GotoPanel("act_007_fkfl")
	end)
	self.fkqjd_btn.onClick:AddListener(function()
		GotoPanel("act_033_fkzjd")
	end)
	self.fkfl_img_btn.onClick:AddListener(function()
		GotoPanel("act_007_fkfl")
	end)
	self.fkqjd_img_btn.onClick:AddListener(function()
		GotoPanel("act_033_fkzjd")
	end)
	self:MyRefresh()
end

function C:MyRefresh()

	if M.IsHintQJD() then
		self.qjd_get.gameObject:SetActive(true)
	else
		self.qjd_get.gameObject:SetActive(false)
	end

	if M.IsHintFL() then
		self.fl_get.gameObject:SetActive(true)
	else
		self.fl_get.gameObject:SetActive(false)
	end
end

function C:on_global_hint_state_change_msg(key)
	self:MyRefresh()
end
