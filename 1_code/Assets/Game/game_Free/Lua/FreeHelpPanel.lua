-- 创建时间:2018-10-18

local UIConfig = require "Game.game_Free.Lua.FreeHelp"

local basefunc = require "Game.Common.basefunc"

local GameToRule = {
    Red = "Red",
    Money = "Money",
}
FreeHelpPanel = basefunc.class()

function FreeHelpPanel.Create()
    return FreeHelpPanel.New()
end

function FreeHelpPanel:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("FreeHelpPanel", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
    self.RedHi = tran:Find("RedButton/RedHi")
    self.RedButton = tran:Find("RedButton"):GetComponent("Button")
    self.RedButton.onClick:AddListener(function ()
        self:OnRedClick()
    end)
    self.MoneyHi = tran:Find("MoneyButton/MoneyHi")
    self.MoneyButton = tran:Find("MoneyButton"):GetComponent("Button")
    self.MoneyButton.onClick:AddListener(function ()
        self:OnMoneyClick()
    end)
    self.Content = tran:Find("ScrollView/Viewport/Content")
    self.HelpText = tran:Find("ScrollView/Viewport/Content/HelpText"):GetComponent("Text")

    self:InitUI()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function FreeHelpPanel:InitUI()
    self.selectIndex = 2
    self:UpdateUI()
end
function FreeHelpPanel:UpdateUI()
    self:SetActiveTag()

    if self.selectIndex == 1 then
	    self.HelpText.text = UIConfig[GameToRule.Red]
    else
	    self.HelpText.text = UIConfig[GameToRule.Money]
    end
    self.Content.localPosition = Vector3.zero
end
function FreeHelpPanel:SetActiveTag()
    if self.selectIndex == 1 then
        self.RedHi.gameObject:SetActive(true)
        self.MoneyHi.gameObject:SetActive(false)
    else
        self.RedHi.gameObject:SetActive(false)
        self.MoneyHi.gameObject:SetActive(true)
    end
end

function FreeHelpPanel:MyExit()
    destroy(self.gameObject)
end

function FreeHelpPanel:Close()
	self:MyExit()
end

function FreeHelpPanel:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end
function FreeHelpPanel:OnRedClick()
    print("aaaaaaaaaaaaaaaaaaaaaa")
   ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    if self.selectIndex ~= 1 then
        self.selectIndex = 1
        self:UpdateUI()
    end
end
function FreeHelpPanel:OnMoneyClick()
    print("bbbbbbbbbbbbbbb")
   ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    if self.selectIndex ~= 2 then
        self.selectIndex = 2
        self:UpdateUI()
    end	
end

