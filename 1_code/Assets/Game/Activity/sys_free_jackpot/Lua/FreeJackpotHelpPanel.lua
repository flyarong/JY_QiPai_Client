-- 创建时间:2018-10-18

-- package.loaded["Game.CommonPrefab.Lua.FreeHelp"] = nil
-- local UIConfig = require "Game.CommonPrefab.Lua.FreeHelp"

local basefunc = require "Game.Common.basefunc"

local GameToRule = {
    Red = "Red",
    Money = "Money",
}
FreeJackpotHelpPanel = basefunc.class()

function FreeJackpotHelpPanel.Create()
    return FreeJackpotHelpPanel.New()
end

function FreeJackpotHelpPanel:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("FreeJackpotHelpPanel", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
    self.HelpText = tran:Find("ScrollView/Viewport/Content/HelpText"):GetComponent("Text")
    
    self:InitUI()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function FreeJackpotHelpPanel:InitUI()
    self.HelpText.text = UIConfig[GameToRule.Money]
end

function FreeJackpotHelpPanel:MyExit()
    destroy(self.gameObject)
end

function FreeJackpotHelpPanel:Close()
	self:MyExit()
end

function FreeJackpotHelpPanel:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end

