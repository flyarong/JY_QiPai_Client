-- 创建时间:2018-06-19

local basefunc = require "Game.Common.basefunc"

HelpPanel = basefunc.class()

HelpPanel.name = "HelpPanel"

HelpPanel.instance = nil

function HelpPanel.Show(desc)
	if HelpPanel.instance then
		HelpPanel.instance.desc = desc
		HelpPanel.instance:ShowUI()
		return
	end
	HelpPanel.Create(desc)
end
function HelpPanel.Create(desc)
	HelpPanel.instance = HelpPanel.New(desc)
	return HelpPanel.instance
end
function HelpPanel:ctor(desc)

	ExtPanel.ExtMsg(self)
	self.desc = desc
	local parent = GameObject.Find("Canvas/LayerLv2").transform
	HelpPanel.HideParent = GameObject.Find("GameManager").transform

	local obj = newObject(HelpPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.BackButton = tran:Find("BackImage"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function (val)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	
	self.Content = tran:Find("ScrollView/Viewport/Content"):GetComponent("RectTransform")
	self.HelpText = tran:Find("ScrollView/Viewport/Content/HelpText"):GetComponent("Text")

	self:InitRect()
end
function HelpPanel:InitRect()
	self.Content.localPosition = Vector3.zero
	self.HelpText.text = self.desc
end

-- 关闭
function HelpPanel:OnBackClick()
	self:HideUI()
end

-- 显示
function HelpPanel:ShowUI()
	local parent = GameObject.Find("Canvas/LayerLv2").transform
	self.transform:SetParent(parent)
	self:InitRect()
end

function HelpPanel:MyExit()
	self.transform:SetParent(HelpPanel.HideParent)
end

-- 隐藏
function HelpPanel:HideUI()
	self:MyExit()
end

