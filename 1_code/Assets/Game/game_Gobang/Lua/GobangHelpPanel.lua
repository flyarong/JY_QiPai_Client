-- 创建时间:2018-08-20

local basefunc = require "Game.Common.basefunc"

GobangHelpPanel = basefunc.class()
GobangHelpPanel.name = "GobangHelpPanel"

local instance = nil

local lister = {}
function GobangHelpPanel:MakeLister()
	lister = {}

	lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function GobangHelpPanel.Create(parent)
	if not instance then
		instance = GobangHelpPanel.New(parent)
	end
	return instance
end

function GobangHelpPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	if not parent then
		parent = GameObject.Find("Canvas/LayerLv4").transform
	end

	local obj = newObject(GobangHelpPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	GobangLogic.setViewMsgRegister(lister, GobangHelpPanel.name)

	self:InitRect()
end

function GobangHelpPanel:MyExit()
	GobangLogic.clearViewMsgRegister(GobangHelpPanel.name)
	destroy(self.gameObject)
end
function GobangHelpPanel.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function GobangHelpPanel:InitRect()
	local transform = self.transform

	self.close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GobangHelpPanel.Close()
	end)

	self:Refresh()
end

function GobangHelpPanel:Refresh()
end

function GobangHelpPanel:OnExitScene()
	GobangHelpPanel.Close()
end
