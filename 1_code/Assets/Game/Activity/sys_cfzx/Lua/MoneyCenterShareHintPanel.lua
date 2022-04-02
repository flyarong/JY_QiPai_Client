-- 创建时间:2018-12-21

local basefunc = require "Game.Common.basefunc"

MoneyCenterShareHintPanel = basefunc.class()

local C = MoneyCenterShareHintPanel

C.name = "MoneyCenterShareHintPanel"

function C.Create(shareType, parm, finishcall,parm1)
	return C.New(shareType, parm, finishcall,parm1)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
    destroy(self.gameObject)
end

function C:ctor(shareType, parm, finishcall,parm1)

	ExtPanel.ExtMsg(self)

    self.parm = parm
    self.shareType = shareType
    self.finishcall = finishcall
    self.parm1 = parm1

    local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

    self.close_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)
    self.HYButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:WeChatShareImage(false)
    end)
    self.PYQButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:WeChatShareImage(true)
    end)

    self:InitUI()
end

function C:InitUI()
	self.hint_info_txt.text = GameMoneyCenterModel.GetTgjjData()[1].hint_desc
end

function C:OnBackClick()
	self:OnDestroy()
end

function C:WeChatShareImage(isCircleOfFriends)
end