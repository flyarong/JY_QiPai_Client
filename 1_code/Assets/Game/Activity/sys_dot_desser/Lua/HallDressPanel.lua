-- 创建时间:2018-11-08
package.loaded["Game.game_Hall.Lua.HallDressTXPanel"] = nil
require "Game.game_Hall.Lua.HallDressTXPanel"
package.loaded["Game.game_Hall.Lua.HallDressBQPanel"] = nil
require "Game.game_Hall.Lua.HallDressBQPanel"
package.loaded["Game.game_Hall.Lua.HallDressDYPanel"] = nil
require "Game.game_Hall.Lua.HallDressDYPanel"

local basefunc = require "Game.Common.basefunc"

HallDressPanel = basefunc.class()

HallDressPanel.name = "HallDressPanel"

local panelNameMap = {
    halldresstx = "HallDressTXPanel",
    halldressbq = "HallDressBQPanel",
    halldressdy = "HallDressDYPanel",
}

local instance
function HallDressPanel.Create(parent)
	instance = HallDressPanel.New(parent)
	return instance
end

function HallDressPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallDressPanel:MakeLister()
    self.lister = {}
end

function HallDressPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function HallDressPanel:MyClose()
    if self.cur_panel then
        self.cur_panel.instance:MyClose()
        self.cur_panel = nil
    end

	self:MyExit()
end

function HallDressPanel:MyExit()
	self:RemoveListener()
    destroy(self.gameObject) 
end

function HallDressPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(HallDressPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.CenterRect = tran:Find("Rect/CenterRect").transform
    self.TXButton = tran:Find("Rect/TopRect/TXButton"):GetComponent("Button")
    self.BQButton = tran:Find("Rect/TopRect/BQButton"):GetComponent("Button")
    self.DYButton = tran:Find("Rect/TopRect/DYButton"):GetComponent("Button")
    self.TXHiImage = tran:Find("Rect/TopRect/TXButton/HiImage")
    self.BQHiImage = tran:Find("Rect/TopRect/BQButton/HiImage")
    self.DYHiImage = tran:Find("Rect/TopRect/DYButton/HiImage")
    self.TXText = tran:Find("Rect/TopRect/TXButton/Text")
    self.BQText = tran:Find("Rect/TopRect/BQButton/Text")
    self.DYText = tran:Find("Rect/TopRect/DYButton/Text")

    self.TXButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnTXClick()
    end)
    self.BQButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBQClick()
    end)
    self.DYButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnDYClick()
    end)

	self:InitUI()
end
function HallDressPanel:ChangePanel(panelName)
    if self.cur_panel then
        if self.cur_panel.name == panelName then
            self.cur_panel.instance:MyRefresh()
        else
            self.cur_panel.instance:MyClose()
            self.cur_panel = nil
        end
    end
    if not self.cur_panel then
        self.TXHiImage.gameObject:SetActive(false)
        self.BQHiImage.gameObject:SetActive(false)
        self.DYHiImage.gameObject:SetActive(false)
        self.TXText.gameObject:SetActive(true)
        self.BQText.gameObject:SetActive(true)
        self.DYText.gameObject:SetActive(true)

        if panelName == panelNameMap.halldresstx then
            self.TXHiImage.gameObject:SetActive(true)
            self.TXText.gameObject:SetActive(false)
            self.cur_panel = {name = panelName, instance = HallDressTXPanel.Create(self.CenterRect)}
        elseif panelName == panelNameMap.halldressbq then
            self.BQHiImage.gameObject:SetActive(true)
            self.BQText.gameObject:SetActive(false)
            self.cur_panel = {name = panelName, instance = HallDressBQPanel.Create(self.CenterRect)}
        elseif panelName == panelNameMap.halldressdy then
            self.DYHiImage.gameObject:SetActive(true)
            self.DYText.gameObject:SetActive(false)
            self.cur_panel = {name = panelName, instance = HallDressDYPanel.Create(self.CenterRect)}
        else
            dump(panelName, "<color=red>没有这个Panel</color>")
        end
    end
end
function HallDressPanel:InitUI()
	self:OnTXClick()
end

function HallDressPanel:MyRefresh()

end

function HallDressPanel:UpdateUI()
	for i = 1, #self.HiImage do
		self.HiImage[i].gameObject:SetActive(false)
		self.UIRect[i].gameObject:SetActive(false)
	end
	self.HiImage[self.selectIndex].gameObject:SetActive(true)
	self.UIRect[self.selectIndex].gameObject:SetActive(true)
	if self.selectIndex == 1 then
		self:UpdateUITX()
	elseif self.selectIndex == 2 then
	else
	end
end
function HallDressPanel:UpdateUITX()
end

-- 头像
function HallDressPanel:OnTXClick()
	self:ChangePanel(panelNameMap.halldresstx)
end
-- 表情
function HallDressPanel:OnBQClick()
	self:ChangePanel(panelNameMap.halldressbq)
end
-- 短语
function HallDressPanel:OnDYClick()
	self:ChangePanel(panelNameMap.halldressdy)
end
