-- 创建时间:2018-12-20

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterTGEWMPanel = basefunc.class()

local C = GameMoneyCenterTGEWMPanel

C.name = "GameMoneyCenterTGEWMPanel"

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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
	self:MyExit()
end

function C:MyExit()
    destroy(self.gameObject)
	self:RemoveListener()
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

    self.HYButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:WeChatShareImage(false)
    end)
    self.PYQButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:WeChatShareImage(true)
    end)

	self.shareType = "moneycenter"
    self:InitUI()
end

function C:InitUI()
    URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.head_img)
end

function C:UpdateUI()

end

function C:MyRefresh()

end

function C:WeChatShareImage(isCircleOfFriends)
    
end

