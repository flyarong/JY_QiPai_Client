-- 创建时间:2018-07-31

local basefunc = require "Game.Common.basefunc"

BannerWidget1 = basefunc.class()

local instance
function BannerWidget1.Create(parent, backcall, parm)
	instance = BannerWidget1.New(parent, backcall, parm)
    return instance
end

function BannerWidget1:ctor(parent, backcall, parm)
	self.config = parm.config
	self.backcall = backcall
	self.gotocall = parm.gotocall
    self.gameObject = newObject("BannerWidget1", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BannerButton = tran:Find("BannerButton"):GetComponent("Button")
    self.BannerImage = tran:Find("BannerButton"):GetComponent("Image")
    EventTriggerListener.Get(self.BackButton.gameObject).onClick = basefunc.handler(self, self.OnBackClick)

    self:InitRect()
end
function BannerWidget1:InitRect()
	self.BannerImage.sprite = GetTexture(self.config.image)
	if self.config.gotoUI and self.config.gotoUI ~= "" then
	    EventTriggerListener.Get(self.BannerButton.gameObject).onClick = basefunc.handler(self, self.OnClick)
		self.BannerButton.enabled = true
	else
		self.BannerButton.enabled = false
	end
end
function BannerWidget1:OnClick(obj)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	GameObject.Destroy(self.gameObject)
	if self.gotocall then
		self.gotocall(self.config.gotoUI)
	end
end
function BannerWidget1:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	GameObject.Destroy(self.gameObject)
	if self.backcall then
		self.backcall()
	end
end