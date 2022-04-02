local basefunc = require "Game/Common/basefunc"

GobangPanel = basefunc.class()

GobangPanel.name = "GobangPanel"

local lister = {}
function GobangPanel:MakeLister()
	lister = {}
	lister["view_wzq_game_open"] = basefunc.handler(self, self.handle_wzq_game_open)

end

local instance
function GobangPanel.Create()
	if not instance then
		instance = GobangPanel.New()
	end
	return instance
end

function GobangPanel:ctor()
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local obj = newObject(GobangPanel.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	GobangLogic.setViewMsgRegister(lister, GobangPanel.name)

	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function GobangPanel:Awake()
end

function GobangPanel.Close()
	if instance then
		GobangLogic.clearViewMsgRegister(GobangPanel.name)
		--instance:ClearAll()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function GobangPanel:InitRect()
	local transform = self.transform

	self.enter_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		GobangGamePanel.Create()
	end)
end

function GobangPanel:Refresh()
end

function GobangPanel:MyRefresh()
	self:Refresh()
end

function GobangPanel:MyClose()
	GobangPanel.Close()
end

function GobangPanel:handle_wzq_game_open()
	GobangPanel.Close()
end
