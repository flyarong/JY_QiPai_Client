-- 个人中心
local basefunc = require "Game.Common.basefunc"

PersonalInfoPanel = basefunc.class()

PersonalInfoPanel.name = "PersonalInfoPanel"

local panelNameMap = {
    hallplayer = "HallPlayerInfoPanel",
}

local instance
function PersonalInfoPanel.Create(parm)
    if instance then
        return instance
    end
    instance = PersonalInfoPanel.New(parm)
    return instance
end
function PersonalInfoPanel.Exit()
    if instance then
        instance:MyExit()
    end
end

function PersonalInfoPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function PersonalInfoPanel:MakeLister()
    self.lister = {}
end

function PersonalInfoPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function PersonalInfoPanel:ctor(parm)

	ExtPanel.ExtMsg(self)

    self.parm = parm
    local parent = GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(PersonalInfoPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj

    self:MakeLister()
    self:AddMsgListener()
    self.BackButton = tran:Find("BackButton"):GetComponent("Button")

    self.BackButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)

    self.CenterRect = tran:Find("CenterRect").transform

    DOTweenManager.OpenPopupUIAnim(self.transform)
    self:InitUI()
end

--初始化UI
function PersonalInfoPanel:InitUI()
    self:OnZLClick()
end
function PersonalInfoPanel:MyExit()
    if self.cur_panel then
        self.cur_panel.instance:MyClose()
        self.cur_panel = nil
    end

    self:RemoveListener()
    destroy(self.gameObject)
    instance = nil
end

function PersonalInfoPanel:ChangePanel(panelName)
    if self.cur_panel then
        if self.cur_panel.name == panelName then
            self.cur_panel.instance:MyRefresh()
        else
            self.cur_panel.instance:MyClose()
            self.cur_panel = nil
        end
    end
    if not self.cur_panel then
        if panelName == panelNameMap.hallplayer then
            self.cur_panel = {name = panelName, instance = HallPlayerInfoPanel.Create(self.CenterRect, self.parm)}
        else
            dump(panelName, "<color=red>没有这个Panel</color>")
        end
    end
    self.parm = nil
end

-- 返回
function PersonalInfoPanel:OnBackClick(go)
    self:MyExit()
end

-- 资料
function PersonalInfoPanel:OnZLClick(go)
    self:ChangePanel(panelNameMap.hallplayer)
end
