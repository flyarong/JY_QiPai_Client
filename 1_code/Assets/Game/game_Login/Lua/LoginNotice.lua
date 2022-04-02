
local basefunc = require "Game.Common.basefunc"

LoginNotice = basefunc.class()

function LoginNotice.Create(desc)
    if true then return end
    return LoginNotice.New(desc)
end

function LoginNotice:ctor(desc)
    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.UIEntity = newObject("LoginNotice", self.parent.transform)

    local BtnEntity = self.UIEntity.transform:Find("ImgPopupPanel/confirm_btn")
    self.btnOK = BtnEntity:GetComponent("Button")
    local HelpText = self.UIEntity.transform:Find("ScrollView/Viewport/Content/HelpText"):GetComponent("Text")
    HelpText.text = desc

    self.btnOK.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        if self.handleClickOK then
            self.handleClickOK()
        end
        GameObject.Destroy(self.UIEntity)
    end)

end

function LoginNotice.handleClickOK()
	print("LoginNotice.handleClickOK")
end
