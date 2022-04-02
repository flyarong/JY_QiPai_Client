-- 创建时间:2019-03-26
-- 玩家操作面板

local basefunc = require "Game.Common.basefunc"

FishingOperPrefab = basefunc.class()

local C = FishingOperPrefab

C.name = "FishingOperPrefab"

function C.Create(tran, panelSelf)
	return C.New(tran, panelSelf)
end
function C:FrameUpdate()
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ui_auto_change"] = basefunc.handler(self, self.on_ui_auto_change)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(tran, panelSelf)
	self.panelSelf = panelSelf
	self.gameObject = tran.gameObject
	self.transform = tran

	self:MakeLister()
    self:AddMsgListener()

    self.OperRect = tran:Find("OperRight/OperRect")
    self.OpenOperButton = tran:Find("OperRight/OpenOperButton"):GetComponent("Button")
    self.OpenOperJT1 = tran:Find("OperRight/OpenOperButton/Image1")
    self.OpenOperJT2 = tran:Find("OperRight/OpenOperButton/Image2")
    self.BackButton = tran:Find("OperRight/OperRect/BackButton"):GetComponent("Button")
    self.SetButton = tran:Find("OperRight/OperRect/SetButton"):GetComponent("Button")
    self.WikiButton = tran:Find("OperRight/OperRect/WikiButton"):GetComponent("Button")
    self.ShopButton = tran:Find("OperRight/OperRect/ShopButton"):GetComponent("Button")
    self.AutoBGImage = tran:Find("AutoRect/AutoBGImage")
    self.AutoYesButton = tran:Find("AutoRect/AutoYesButton"):GetComponent("Button")
    self.AutoNoButton = tran:Find("AutoRect/AutoNoButton"):GetComponent("Button")
    self.AutoScaleButton = tran:Find("AutoRect/AutoScaleButton"):GetComponent("Button")
    self.AutoScaleText = tran:Find("AutoRect/AutoScaleButton/AutoScaleText"):GetComponent("Text")
    self.BackButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    self.SetButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
        -- local data = {}
        -- local i = 1
        -- data[i] = {}
        -- data[i].data = {1}
        -- data[i].msg_type = "activity"
        -- data[i].type = 14
        -- data[i].seat_num = 1
        -- data[i].rates = {1, 2}
        -- data[i].status = 1
        -- i = 2
        -- data[i] = {}
        -- data[i].data = {1}
        -- data[i].msg_type = "activity"
        -- data[i].type = 16
        -- data[i].seat_num = 1
        -- data[i].rates = {1, 2}
        -- data[i].status = 1
        -- Event.Brocast("model_receive_skill_data_msg", data)
    end)
    self.OpenOperButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnOpenOperClick()
    end)
    self.WikiButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnWikeClick()
    end)
    self.ShopButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end)
    self.AutoNoButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAutoClick(false)
    end)
    self.AutoYesButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAutoClick(true)
    end)
    self.AutoScaleButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAutoScaleClick()
    end)

    self:MyRefresh() 
end
function C:MyRefresh()
	self:SetOpenOper(false)
    self.AutoScaleButton.gameObject:SetActive(false)
    self.AutoYesButton.gameObject:SetActive(true)
    self.AutoNoButton.gameObject:SetActive(false)
    self.AutoBGImage.gameObject:SetActive(false)
end

function C:MyExit()
	self:RemoveListener()
end

function C:SetOpenOper(b)
    self.OperRect.gameObject:SetActive(b)
    self.OpenOperJT1.gameObject:SetActive(b)
    self.OpenOperJT2.gameObject:SetActive(not b)
end
function C:OnOpenOperClick()
    local b = not self.OperRect.gameObject.activeSelf
    self:SetOpenOper(b)
end

function C:OnBackClick()
    HintPanel.Create(1, "您离大奖就差一步了，千万别放弃哦")
    -- FishingMatchLogic.quit_game()
end

function C:OnWikeClick()
    FishingBKPanel.New(true)
end

function C:OnAutoClick(is_auto)
    if FishingMatchModel.GetPlayerLaserState(FishingMatchModel.GetPlayerSeat()) == "nor" then
        local userdata = FishingMatchModel.GetPlayerData()
        local uipos = FishingMatchModel.GetSeatnoToPos(userdata.base.seat_num)
        if userdata.isPC then
            print("<color=red>破产不能使用自动开炮</color>")
        else
            if is_auto then
                userdata.is_auto = true
                userdata.auto_index = 1
            else
                userdata.is_auto = false
                userdata.auto_index = 1
            end
            self:on_ui_auto_change()
        end
    else
        LittleTips.Create("激光处于蓄力或者使用中，无法使用自动开炮")
    end
end
function C:OnAutoScaleClick()
    local userdata = FishingMatchModel.GetPlayerData()
    local uipos = FishingMatchModel.GetSeatnoToPos(userdata.base.seat_num)
    userdata.auto_index = userdata.auto_index + 1
    if userdata.auto_index > #FishingMatchModel.Defines.auto_bullet_speed then
        userdata.auto_index = 1
    end
    local v = FishingMatchModel.Defines.auto_bullet_speed[userdata.auto_index]
    self.AutoScaleText.text = "x" .. v

    self:SetAutoCoefficient(v)
end

function C:SetAutoCoefficient(v)
    local userdata = FishingMatchModel.GetPlayerData()
    local uipos = FishingMatchModel.GetSeatnoToPos(userdata.base.seat_num)
    self.panelSelf.PlayerClass[uipos]:SetAutoCoefficient(v)
end

function C:on_ui_auto_change()
    local userdata = FishingMatchModel.GetPlayerData()
    local uipos = FishingMatchModel.GetSeatnoToPos(userdata.base.seat_num)
    if userdata.is_auto then
        local v = FishingMatchModel.Defines.auto_bullet_speed[userdata.auto_index]
        self.AutoScaleText.text = "x" .. v
        self.AutoScaleButton.gameObject:SetActive(true)
        self.AutoYesButton.gameObject:SetActive(false)
        self.AutoNoButton.gameObject:SetActive(true)
        self.AutoBGImage.gameObject:SetActive(true)

        Event.Brocast("auto_state_change_msg", userdata.base.seat_num)
    else
        self.AutoScaleButton.gameObject:SetActive(false)
        self.AutoYesButton.gameObject:SetActive(true)
        self.AutoNoButton.gameObject:SetActive(false)
        self.AutoBGImage.gameObject:SetActive(false)

        Event.Brocast("auto_state_change_msg", userdata.base.seat_num)
    end
end