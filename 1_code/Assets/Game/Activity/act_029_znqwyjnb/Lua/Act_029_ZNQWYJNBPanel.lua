local basefunc = require "Game/Common/basefunc"

Act_029_ZNQWYJNBPanel = basefunc.class()
local C = Act_029_ZNQWYJNBPanel
C.name = "Act_029_ZNQWYJNBPanel"
local Mgr = Act_029_ZNQWYJNBManager
local instance
function C.Create(parent)
    if instance then
        instance:MyExit()
    end
    instance = C.New(parent)
	return instance
end

function C.Close()
    if instance then
        instance:MyExit()
    end
    instance = nil
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
	self:RemoveListener()
    destroy(self.gameObject)
    instance = nil
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

function C:InitUI()
    self.by_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({gotoui = "game_FishingHall"})
    end)
    self.xxl_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "game_MiniGame"})
    end)
    self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnDestroy()
	self:MyExit()
end