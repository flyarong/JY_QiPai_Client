-- 创建时间:2018-08-16

local basefunc = require "Game.Common.basefunc"
local UIConfig = require "Game.normal_mj_common.Lua.GameMjHelp"

local GameToRule = {
    XZ = "XZ",
    XL = "XL",
    ER = "ER",
}

MjHelpPanel = basefunc.class()

function MjHelpPanel.Create(parm)
    return MjHelpPanel.New(parm)
end

function MjHelpPanel:ctor(parm)

	ExtPanel.ExtMsg(self)

    self.parm = parm
	local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("MjHelpPanel", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
    -- self.cell = tran:Find("Cell")
    self.RuleHi = tran:Find("RuleButton/RuleHi")
    self.RuleButton = tran:Find("RuleButton"):GetComponent("Button")
    self.RuleButton.onClick:AddListener(function ()
        self:OnRuleClick()
    end)
    self.BrandTypeHi = tran:Find("BrandTypeButton/BrandTypeHi")
    self.BrandTypeButton = tran:Find("BrandTypeButton"):GetComponent("Button")
    self.BrandTypeButton.onClick:AddListener(function ()
        self:OnBrandTypeClick()
    end)
    self.Rule_ScrollView = tran:Find("Rule_ScrollView")
    self.BrandType_ScrollView = tran:Find("BrandType_ScrollView")
    self.Rule_Content = tran:Find("Rule_ScrollView/Viewport/Content")
    self.BrandType_Content = tran:Find("BrandType_ScrollView/Viewport/Content")
    self.TitleText = tran:Find("Rule_ScrollView/Viewport/Content/TitleText"):GetComponent("Text")
    self.HelpText = tran:Find("Rule_ScrollView/Viewport/Content/HelpText"):GetComponent("Text")
    self.XZRuleImg = tran:Find("BrandType_ScrollView/Viewport/Content/XZRuleImg")
    self.XLRuleImg = tran:Find("BrandType_ScrollView/Viewport/Content/XLRuleImg")
    self.ERRuleImg = tran:Find("BrandType_ScrollView/Viewport/Content/ERRuleImg")

    self.SVSwitch = tran:Find("SVSwitch")
    self.XZTge = tran:Find("SVSwitch/Viewport/@switch_content/@XZ_tge"):GetComponent("Toggle")
    self.XZTge.onValueChanged:AddListener(function (val)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if val then
            self:SwitchGroup(GameToRule.XZ)
            self.BrandType_Content.transform.localPosition = Vector3.New(0,0,0)
        end
    end)
    self.XLTge = tran:Find("SVSwitch/Viewport/@switch_content/@XL_tge"):GetComponent("Toggle")
    self.XLTge.onValueChanged:AddListener(function (val)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if val then
            self:SwitchGroup(GameToRule.XL)
            self.BrandType_Content.transform.localPosition = Vector3.New(0,0,0)
        end
    end)
    self.ERTge = tran:Find("SVSwitch/Viewport/@switch_content/@ER_tge"):GetComponent("Toggle")
    self.ERTge.onValueChanged:AddListener(function (val)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if val then
            self:SwitchGroup(GameToRule.ER)
            self.BrandType_Content.transform.localPosition = Vector3.New(0,0,0)
        end
    end)

    self:InitUI()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end
function MjHelpPanel:InitUI()
    self.selectIndex = 1
    self:UpdateUI()
end

function MjHelpPanel:SwitchGroup(group_name)
    self.XZRuleImg.gameObject:SetActive(group_name == GameToRule.XZ)
    self.XLRuleImg.gameObject:SetActive(group_name == GameToRule.XL)
    self.ERRuleImg.gameObject:SetActive(group_name == GameToRule.ER)

    self.Rule_Content.localPosition = Vector3.zero
    self.HelpText.text = UIConfig[group_name]
end

function MjHelpPanel:MJTgeIsOn(group_name)
    self.XZTge.isOn = group_name == GameToRule.XZ
    self.XLTge.isOn = group_name == GameToRule.XL
    self.ERTge.isOn = group_name == GameToRule.ER
end

function MjHelpPanel:UpdateUI()
    self:ClearCellList()
    self:SetActiveTag()

    if self.selectIndex == 1 then
        self.Rule_ScrollView.gameObject:SetActive(true)
        self.BrandType_ScrollView.gameObject:SetActive(false)
        self.SVSwitch.gameObject:SetActive(true)
        self:MJTgeIsOn(self.parm)
    else
        self.BrandType_Content.localPosition = Vector3.zero
        self.Rule_ScrollView.gameObject:SetActive(false)
        self.BrandType_ScrollView.gameObject:SetActive(true)
        self.SVSwitch.gameObject:SetActive(true)
        self:SwitchGroup(self.parm)
        self:MJTgeIsOn(self.parm)
    end
end

function MjHelpPanel:SetActiveTag()
    if self.selectIndex == 1 then
        self.RuleHi.gameObject:SetActive(true)
        self.BrandTypeHi.gameObject:SetActive(false)
    elseif self.selectIndex == 2 then
        self.RuleHi.gameObject:SetActive(false)
        self.BrandTypeHi.gameObject:SetActive(true)
    else
        self.RuleHi.gameObject:SetActive(true)
        self.BrandTypeHi.gameObject:SetActive(false)
    end
end

function MjHelpPanel:ClearCellList()
    if self.CellList then
        for k,v in ipairs(self.CellList) do
            GameObject.Destroy(v.gameObject)
        end
    end
    self.CellList = {}
end

function MjHelpPanel:MyExit()
    destroy(self.gameObject)
end

function MjHelpPanel:Close()
	self:MyExit()
end

function MjHelpPanel:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end
function MjHelpPanel:OnRuleClick()
   ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    if self.selectIndex ~= 1 then
        self.selectIndex = 1
        self:UpdateUI()
    end
end
function MjHelpPanel:OnBrandTypeClick()
   ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    if self.selectIndex ~= 2 then
        self.selectIndex = 2
        self:UpdateUI()
    end	
end

