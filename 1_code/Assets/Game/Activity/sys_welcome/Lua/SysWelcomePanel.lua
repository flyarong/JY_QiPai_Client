-- 创建时间:2021-07-19
-- Panel:SysWelcomePanel
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

SysWelcomePanel = basefunc.class()
local C = SysWelcomePanel
C.name = "SysWelcomePanel"
local M = SysWelcomeManager

function C.Create(lv)
	return C.New(lv)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(lv)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	if lv >= 2 then
		self.lv = lv - 1
	else
		self.lv = lv
	end
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self["lv" .. self.lv].gameObject:SetActive(true)
	local showName = MainModel.UserInfo.name
	if #showName > 12 then
		showName = string.sub(showName,1,12) .. "*"
	end
	self["lv" .. self.lv .. "_name_txt"].text = showName
	self.tiemr = Timer.New(function()
		if self.gameObject then
			self:MyExit()
		end
	end, 5, 1)
	self.tiemr:Start()
	self:MyRefresh()
	showName = nil
end

function C:MyRefresh()
end
