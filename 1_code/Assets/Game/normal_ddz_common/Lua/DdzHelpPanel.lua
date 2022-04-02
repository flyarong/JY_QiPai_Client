-- 创建时间:2018-08-20

package.loaded["Game.normal_ddz_common.Lua.GameDdzHelp"] = nil
local UIConfig = require "Game.normal_ddz_common.Lua.GameDdzHelp"

local basefunc = require "Game.Common.basefunc"

local GameToRule = {
    JD = "JD",
    TY = "TY",
    LZ = "LZ",
    TF = "TF",
    ER = "ER",
    PDK = "PDK",
}
DdzHelpPanel = basefunc.class()

function DdzHelpPanel.Create(parm)
    return DdzHelpPanel.New(parm)
end

function DdzHelpPanel:ctor(parm)

	ExtPanel.ExtMsg(self)

    self.parm = parm
	local parent = GameObject.Find("Canvas/LayerLv4")
    self.gameObject = newObject("DdzHelpPanel", parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
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
    self.HelpText = tran:Find("Rule_ScrollView/Viewport/Content/HelpText"):GetComponent("Text")
    self.JDRuleImg = tran:Find("BrandType_ScrollView/Viewport/Content/JDRuleImg")
    self.TYRuleImg = tran:Find("BrandType_ScrollView/Viewport/Content/TYRuleImg")
    self.LZRuleImg = tran:Find("BrandType_ScrollView/Viewport/Content/LZRuleImg")
    self.TFRuleImg = tran:Find("BrandType_ScrollView/Viewport/Content/TFRuleImg")
    self.ERRuleImg = tran:Find("BrandType_ScrollView/Viewport/Content/ERRuleImg")
    self.PDKRuleImg = tran:Find("BrandType_ScrollView/Viewport/Content/PDKRuleImg")

    self.SVSwitch = tran:Find("SVSwitch")
    self.JDTge = tran:Find("SVSwitch/Viewport/@switch_content/@JD_tge"):GetComponent("Toggle")
    self.JDTge.onValueChanged:AddListener(function (val)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if val then
            self:SwitchGroup(GameToRule.JD)
            self.BrandType_Content.transform.localPosition = Vector3.New(0,0,0)
        end
    end)
    self.TYTge = tran:Find("SVSwitch/Viewport/@switch_content/@TY_tge"):GetComponent("Toggle")
    self.TYTge.onValueChanged:AddListener(function (val)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if val then
            self:SwitchGroup(GameToRule.TY)
            self.BrandType_Content.transform.localPosition = Vector3.New(0,0,0)
        end
    end)
    self.LZTge = tran:Find("SVSwitch/Viewport/@switch_content/@LZ_tge"):GetComponent("Toggle")
    self.LZTge.onValueChanged:AddListener(function (val)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=yellow>val</color>",val)
        if val then
            self:SwitchGroup(GameToRule.LZ)

            self.BrandType_Content.transform.localPosition = Vector3.New(0,0,0)
        end
    end)

    self.TFTge = tran:Find("SVSwitch/Viewport/@switch_content/@TF_tge"):GetComponent("Toggle")
    self.TFTge.onValueChanged:AddListener(function (val)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=yellow>val</color>",val)
        if val then
            self:SwitchGroup(GameToRule.TF)

            self.BrandType_Content.transform.localPosition = Vector3.New(0,0,0)
        end
    end)

    self.ERTge = tran:Find("SVSwitch/Viewport/@switch_content/@ER_tge"):GetComponent("Toggle")
    self.ERTge.onValueChanged:AddListener(function (val)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=yellow>val</color>",val)
        if val then
            self:SwitchGroup(GameToRule.ER)

            self.BrandType_Content.transform.localPosition = Vector3.New(0,0,0)
        end
    end)

    self.PDKTge = tran:Find("SVSwitch/Viewport/@switch_content/@PDK_tge"):GetComponent("Toggle")
    self.PDKTge.onValueChanged:AddListener(function (val)
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=yellow>val</color>",val)
        if val then
            self:SwitchGroup(GameToRule.PDK)

            self.BrandType_Content.transform.localPosition = Vector3.New(0,0,0)
        end
    end)

    self:InitUI()
    DOTweenManager.OpenPopupUIAnim(self.transform)
end

function DdzHelpPanel:SwitchGroup(group_name)
    self.JDRuleImg.gameObject:SetActive(group_name == GameToRule.JD)
    self.TYRuleImg.gameObject:SetActive(group_name == GameToRule.TY)
    self.LZRuleImg.gameObject:SetActive(group_name == GameToRule.LZ)
    self.TFRuleImg.gameObject:SetActive(group_name == GameToRule.TF)
    self.ERRuleImg.gameObject:SetActive(group_name == GameToRule.ER)
    self.PDKRuleImg.gameObject:SetActive(group_name == GameToRule.PDK)

    self.HelpText.text = UIConfig[group_name]
    self.Rule_Content.localPosition = Vector3.zero
end

function DdzHelpPanel:DDZTgeIsOn(group_name)
    self.JDTge.isOn = group_name == GameToRule.JD
    self.TYTge.isOn = group_name == GameToRule.TY
    self.LZTge.isOn = group_name == GameToRule.LZ
    self.TFTge.isOn = group_name == GameToRule.TF
    self.ERTge.isOn = group_name == GameToRule.ER
    self.PDKTge.isOn = group_name == GameToRule.PDK
end

function DdzHelpPanel:InitUI()
    self.selectIndex = 1
    self:UpdateUI()
end
function DdzHelpPanel:UpdateUI()
    self:ClearCellList()
    self:SetActiveTag()

    if self.selectIndex == 1 then
        self.Rule_ScrollView.gameObject:SetActive(true)
        self.BrandType_ScrollView.gameObject:SetActive(false)
        -- self.SVSwitch.gameObject:SetActive(true)
        
        self:DDZTgeIsOn(self.parm)
    else
        self.BrandType_Content.localPosition = Vector3.zero
        self.Rule_ScrollView.gameObject:SetActive(false)
        self.BrandType_ScrollView.gameObject:SetActive(true)
        -- self.SVSwitch.gameObject:SetActive(true)
        self:SwitchGroup(self.parm)
        self:DDZTgeIsOn(self.parm)
    end
end
function DdzHelpPanel:SetActiveTag()
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

function DdzHelpPanel:ClearCellList()
    if self.CellList then
        for k,v in ipairs(self.CellList) do
            GameObject.Destroy(v.gameObject)
        end
    end
    self.CellList = {}
end

function DdzHelpPanel:MyExit()
    destroy(self.gameObject)
end

function DdzHelpPanel:Close()
	self:MyExit()
end

function DdzHelpPanel:OnBackClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:Close()
end
function DdzHelpPanel:OnRuleClick()
   ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    if self.selectIndex ~= 1 then
        self.selectIndex = 1
        self:UpdateUI()
    end
end
function DdzHelpPanel:OnBrandTypeClick()
   ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    if self.selectIndex ~= 2 then
        self.selectIndex = 2
        self:UpdateUI()
    end	
end
