local basefunc = require "Game.Common.basefunc"
local nor_pdk_base_lib = require "Game.normal_ddz_common.Lua.nor_pdk_base_lib"

--数据结构
--说明：位置坐标系  我的位置永远为1 逆时针 2 3，

DdzPDKMatchGamePanel = basefunc.class()

DdzPDKMatchGamePanel.name = "DdzPDKMatchGamePanel"
local lister
local listerRegisterName = "DdzPDKMatchGameListerRegister"

local function change_btn_image(btn, image, enabled, text)
    local btn_img = btn.gameObject:GetComponent("Image")
    local hi = btn.transform:Find("hi")
    local no = btn.transform:Find("no")
    hi.gameObject:SetActive(enabled)
    no.gameObject:SetActive(not enabled)

    btn_img.sprite = GetTexture(image)
    btn_img:SetNativeSize()
    -- btn.enabled = enabled
    -- btn.interactable = enabled
    btn_img.raycastTarget = enabled
    -- btn.gameObject.GetComponent<Button>().enabled = false
    if text then
        -- self.close_txt.text = text
    end
end

--自动出最后一手牌
local function auto_chu_last_pai(self)
    local m_data = DdzPDKMatchModel.data
    if m_data.status == DdzPDKMatchModel.Status.cp then
        local pos = m_data.s2cSeatNum[m_data.cur_p]
        if pos == 1 then
            local _act =
                DdzPDKMatchModel.ddz_algorithm:check_is_only_last_pai(m_data.action_list, m_data.my_pai_list, m_data.laizi)
            if _act then
                self.last_pai_auto_countdown = 1
                self.last_pai_auto_cb = function()
                    self.last_pai_auto_cb = nil
                    self.last_pai_auto_countdown = nil
                    local manager = self.DdzPDKMatchPlayersActionManger
                    --将所有的牌弹起
                    for no, v in pairs(manager.my_pai_hash) do
                        v:ChangePosStatus(1)
                    end
                    --出牌btn
                    manager:ChupaiBtnCB()
                end
            end
        end
    end
end

local instance
--******************框架
function DdzPDKMatchGamePanel.Create()
    DSM.PushAct({panel = DdzPDKMatchGamePanel.name})
    instance = DdzPDKMatchGamePanel.New()
    instance.dzCardObj = GetPrefab("DdzDzCard")
    instance.cardObj = GetPrefab("DdzCard")
    return createPanel(instance, DdzPDKMatchGamePanel.name)
end

function DdzPDKMatchGamePanel.Bind()
    local _in = instance
    instance = nil
    return _in
end

function DdzPDKMatchGamePanel:Awake()
    LuaHelper.GeneratingVar(self.transform, self)
    self.pairdesk_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_pairdesk_ui.transform, self.pairdesk_son)
    self.dizhu_card_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_dizhu_card_ui.transform, self.dizhu_card_son)
    self.playerright_info_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerright_info_ui.transform, self.playerright_info_son)
    self.playerright_operate_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerright_operate_ui.transform, self.playerright_operate_son)
    self.playerleft_info_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerleft_info_ui.transform, self.playerleft_info_son)
    self.playerleft_operate_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerleft_operate_ui.transform, self.playerleft_operate_son)
    self.playerself_info_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerself_info_ui.transform, self.playerself_info_son)
    self.playerself_operate_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerself_operate_ui.transform, self.playerself_operate_son)
    self.menu_son = {}
    LuaHelper.GeneratingVar(self.menu_btn.transform, self.menu_son)
    self.statistics_son = {}
    LuaHelper.GeneratingVar(self.statistics.transform, self.statistics_son)

    self.isGuideHint = true
    --托管UI
    self.autoUI = {}
    self.autoUI[1] = self.playerself_operate_son.auto.gameObject
    self.autoUI[2] = self.playerright_operate_son.auto.gameObject
    self.autoUI[3] = self.playerleft_operate_son.auto.gameObject

    --警报UI
    self.warningUI = {}
    self.warningUI[2] = self.playerright_operate_son.alarm.gameObject
    self.warningUI[3] = self.playerleft_operate_son.alarm.gameObject
    --剩余的牌
    self.cardsRemainUI = {}
    self.cardsRemainUI[2] = self.playerright_operate_son.cards_remain.gameObject
    self.cardsRemainUI[3] = self.playerleft_operate_son.cards_remain.gameObject

    self.playerInfoUI = {}
    self.playerInfoUI[1] = self.playerself_info_son
    self.playerInfoUI[2] = self.playerright_info_son
    self.playerInfoUI[3] = self.playerleft_info_son

    self.playerOperateUI = {}
    self.playerOperateUI[1] = self.playerself_operate_son
    self.playerOperateUI[2] = self.playerright_operate_son
    self.playerOperateUI[3] = self.playerleft_operate_son

    self.timerUI = {}
    self.timerUI[1] = self.playerself_operate_son.wait_time
    self.timerUI[2] = self.playerright_operate_son.wait_time
    self.timerUI[3] = self.playerleft_operate_son.wait_time
    self.timerTextUI = {}
    self.timerTextUI[1] = self.playerself_operate_son.wait_time_txt
    self.timerTextUI[2] = self.playerright_operate_son.wait_time_txt
    self.timerTextUI[3] = self.playerleft_operate_son.wait_time_txt

    self.ChatButton_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            GameSpeedyPanel.Show()
        end
    )

    self.EasyButton = {[1] = self.EasyButton1, [2] = self.EasyButton2, [3] = self.EasyButton3}
    self.HeroEasyButton = {[1] = self.HeroEasyButton1, [2] = self.HeroEasyButton2, [3] = self.HeroEasyButton3}
    for i = 1, DdzPDKMatchModel.maxPlayerNumber do
        local btn = self.EasyButton[i]
        EventTriggerListener.Get(btn.gameObject).onClick = basefunc.handler(self, self.OnEasyClick)

        local herobtn = self.HeroEasyButton[i]
        EventTriggerListener.Get(herobtn.gameObject).onClick = basefunc.handler(self, self.OnEasyClick)
    end

    self.countdown = 0
    --初始化闹钟 time < 0 隐藏 timer ，time > 0 显示
    self.timer = nil
    self.timerTween = {}

    self.colorGary = Color.New(194 / 255, 171 / 255, 160 / 255, 255 / 255)
    self.colorYellow = Color.New(255 / 255, 211 / 255, 0 / 255, 255 / 255)

    self.TopButtonImage = self.transform:Find("TopButtonImage"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButtonImage.gameObject).onClick = basefunc.handler(self, self.SetHideMenu)
    self.TopButtonImage.gameObject:SetActive(false)

    self.updateTimer = Timer.New(basefunc.handler(self, self.update_callback), 1, -1, true)
    self.updateTimer:Start()
    self:MyInit()
    --dump(DdzPDKMatchModel.data, "<color=yellow>------------------------------------->>>> DdzPDKMatchModel.data:</color>")
    self:MyRefresh()
    self.BubbleNode.gameObject:SetActive(false)
end

function DdzPDKMatchGamePanel:Start()
    -- self:MyRefresh()
    -- if MainModel.UserInfo.xsyd_status == 0 and GameGlobalOnOff.IsOpenGuide and self.isGuideHint then
    --     self.BubbleNode.gameObject:SetActive(true)
    -- else
    --     self.BubbleNode.gameObject:SetActive(false)
    -- end
end

function DdzPDKMatchGamePanel:MyInit()
    self.DdzPDKMatchActionUiManger = DdzPDKMatchActionUiManger.Create(self, self.playerOperateUI, self.dizhu_card_son)
    self.DdzPDKMatchPlayersActionManger = DdzPDKMatchPlayersActionManger.Create(self)
    self:MakeLister()
    DdzPDKMatchLogic.setViewMsgRegister(lister, listerRegisterName)

    EventTriggerListener.Get(self.change_cards_pos_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.ChangeCardsPosBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_bg_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.no_play_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.out_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.ChupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.hint_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.HintBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.JiabeiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_not_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.BujiabeiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_1_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.Jdz1BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_2_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.Jdz2BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_3_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.Jdz3BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_not_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.Bujdz1BtnCB)

    --二人叫地主
    EventTriggerListener.Get(self.playerself_operate_son.jdz_er_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.Jdz1BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_not_er_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.Bujdz1BtnCB)
    --二人场抢地主
    EventTriggerListener.Get(self.playerself_operate_son.qdz_1_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.Qdz1BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.qdz_not_btn.gameObject).onClick =
        basefunc.handler(self.DdzPDKMatchPlayersActionManger, self.DdzPDKMatchPlayersActionManger.Buqdz1BtnCB)

    EventTriggerListener.Get(self.playerself_operate_son.close_auto_btn.gameObject).onClick =
        basefunc.handler(self, self.CanelAutoBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.record_btn.gameObject).onClick =
        basefunc.handler(self, self.DdzJiPaiQiCB)
    EventTriggerListener.Get(self.playerself_operate_son.pay_record_btn.gameObject).onClick =
        basefunc.handler(self, self.DdzPayJiPaiQiCB)
    EventTriggerListener.Get(self.menu_btn.gameObject).onClick = basefunc.handler(self, self.MenuCB)
    EventTriggerListener.Get(self.menu_son.set_btn.gameObject).onClick = basefunc.handler(self, self.SetCB)
    EventTriggerListener.Get(self.menu_son.close_btn.gameObject).onClick = basefunc.handler(self, self.CloseCB)
    EventTriggerListener.Get(self.menu_son.help_btn.gameObject).onClick = basefunc.handler(self, self.HelpCB)
end

function DdzPDKMatchGamePanel:MyRefresh()
    if DdzPDKMatchModel.data then
        self.DdzPDKMatchActionUiManger:RefreshBGM()
        -- 废牌
        self:RefreshDeadwood()
        local m_data = DdzPDKMatchModel.data
        self.countdown = math.floor(m_data.countdown)
        self:HideWaitPanel()
        self:HideRevivePanel()
        if m_data.model_status == DdzPDKMatchModel.Model_Status.wait_table then
            self.ddz_match_pairdesk_ui.gameObject:SetActive(true)
            self:ShowOrHideDdzView(false)
            self:ShowOrHideWarningView(false)
            self.cardsRemainUI[2].gameObject:SetActive(false)
            self.cardsRemainUI[3].gameObject:SetActive(false)
            SpineManager.RemoveAllDDZPlayerSpine()
        else
            self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
            if m_data.status == DdzPDKMatchModel.Status.wait_join then
                self:ShowOrHideWarningView(false)
                self.cardsRemainUI[2].gameObject:SetActive(false)
                self.cardsRemainUI[3].gameObject:SetActive(false)
            end
            self:ShowOrHideDdzView(true)

            if not self.refreshInTablePlayerNum then
                self.refreshInTablePlayerNum = Timer.New(basefunc.handler(self, self.RefreshGamingPlayerNum), 2, -1, false)
                self.refreshInTablePlayerNum:Start()
            end
            
            -- transform_seat(self,m_data.seat_num)
            --刷新警报
            self:RefreshRemainPaiWarningStatus()
            --刷新我的牌展示UI 及 操作
            self.DdzPDKMatchPlayersActionManger:Refresh()
            --刷新托管
            self:RefreshAutoStatus()
            --刷新权限
            self:RefreshPermitStatus()
            --刷新操作展示UI
            self.DdzPDKMatchActionUiManger:Refresh()
            --刷新地主牌
            self:RefreshDiZhuAndMultipleStatus()
            --刷新玩家信息
            self:RefreshPlayerInfo()
            --刷新结算
            self:RefreshSettlement()
            --刷新轮数
            self:RefreshRound()
            --刷新倍数
            self:RefreshRate()
            --记牌器
            self:RefreshDdzJiPaiQi()
            -- 抢地主次数
            self:RefreshQDZUI()
            -- 让牌提示
            self:RefreshRangHint()

            --晋级
            self:RefreshPromoted()
            --等待
            self:RefreshWait()
            -- 复活
            self:RefreshRevive()
        end
        self:IsShow_JpqNotice()
    end
end

function DdzPDKMatchGamePanel:MyExit()
    PlayerInfoPanel.Exit()
    GameSpeedyPanel.Hide()
    self:HideWaitPanel()
    self:HideRevivePanel()

    if self.updateTimer then
        self.updateTimer:Stop()
        self.updateTimer = nil
    end
    self.DdzPDKMatchPlayersActionManger:MyExit()
    self.DdzPDKMatchActionUiManger:MyExit()
    SpineManager.RemoveAllDDZPlayerSpine()
    DdzPDKMatchLogic.clearViewMsgRegister(listerRegisterName)
    --closePanel(DdzPDKMatchGamePanel.name)
    self.dzCardObj = nil
    self.cardObj = nil

    if self.refreshInTablePlayerNum then
        self.refreshInTablePlayerNum:Stop()
        self.refreshInTablePlayerNum = nil
    end
end

function DdzPDKMatchGamePanel:MyClose()
    DSM.PopAct()
    self:MyExit()
    closePanel(DdzPDKMatchGamePanel.name)
end

function DdzPDKMatchGamePanel:MakeLister()
    lister = {}
    --模式
    lister["model_nor_mg_enter_room_msg"] = basefunc.handler(self, self.nor_mg_enter_room_msg)
    lister["model_nor_mg_join_msg"] = basefunc.handler(self, self.nor_mg_join_msg)
    lister["model_nor_mg_wait_result_msg"] = basefunc.handler(self, self.nor_mg_wait_result_msg)
    lister["model_nor_mg_promoted_msg"] = basefunc.handler(self, self.nor_mg_promoted_msg)
    lister["model_nor_mg_score_change_msg"] = basefunc.handler(self, self.nor_mg_score_change_msg)
    lister["model_nor_mg_rank_msg"] = basefunc.handler(self, self.nor_mg_rank_msg)
    lister["model_nor_mg_gameover_msg"] = basefunc.handler(self, self.nor_mg_gameover_msg)
    lister["model_nor_mg_req_cur_player_num_response"] = basefunc.handler(self, self.on_nor_mg_req_cur_player_num__response)

    --玩法
    lister["model_nor_pdk_nor_begin_msg"] = basefunc.handler(self, self.nor_pdk_nor_begin_msg)
    lister["model_nor_pdk_nor_pai_msg"] = basefunc.handler(self, self.nor_pdk_nor_pai_msg)
    lister["model_nor_pdk_nor_action_msg"] = basefunc.handler(self, self.nor_pdk_nor_action_msg)
    lister["model_nor_pdk_nor_permit_msg"] = basefunc.handler(self, self.nor_pdk_nor_permit_msg)
    lister["model_nor_pdk_nor_show_pai_msg"] = basefunc.handler(self, self.nor_pdk_nor_show_pai_msg)
    lister["model_nor_pdk_nor_auto_msg"] = basefunc.handler(self, self.nor_pdk_nor_auto_msg)
    lister["model_nor_pdk_nor_settlement_msg"] = basefunc.handler(self, self.nor_pdk_nor_settlement_msg)
    lister["model_nor_pdk_nor_new_game_msg"] = basefunc.handler(self, self.nor_pdk_nor_new_game_msg)
    lister["model_nor_pdk_nor_bomb_settlement_msg"] = basefunc.handler(self, self.nor_pdk_nor_bomb_settlement_msg)

    --复活
    lister["model_nor_mg_wait_revive_msg"] = basefunc.handler(self, self.nor_mg_wait_revive_msg)
    lister["model_nor_mg_free_revive_msg"] = basefunc.handler(self, self.nor_mg_free_revive_msg)
    lister["model_nor_mg_revive_response"] = basefunc.handler(self, self.nor_mg_revive_response)
end

--************************模式消息
function DdzPDKMatchGamePanel:nor_mg_enter_room_msg()
    self.DdzPDKMatchActionUiManger:PlayBSKS()
    self:MyRefresh()
    -- local m_data = DdzPDKMatchModel.data
    -- transform_seat(self,m_data.seat_num)
    -- self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
    -- self:ShowOrHideDdzView(true)
    -- self:ShowOrHideCustHeadIcon(true)
    -- self:RefreshPlayerInfo()
end

function DdzPDKMatchGamePanel:nor_mg_join_msg(seat_num)
    self:RefreshPlayerInfo(DdzPDKMatchModel.data.s2cSeatNum[seat_num])
end

function DdzPDKMatchGamePanel:nor_mg_score_change_msg()
    self:RefreshScore(1)
end

function DdzPDKMatchGamePanel:nor_mg_rank_msg()
    self:RefreshRank()
end

function DdzPDKMatchGamePanel:nor_mg_wait_result_msg()
    self:RefreshWait()
end

function DdzPDKMatchGamePanel:nor_mg_promoted_msg()
    self:RefreshPromoted(true)
end

--************************玩法消息
function DdzPDKMatchGamePanel:nor_pdk_nor_begin_msg()
    print("<color=blue>nor_pdk_nor_begin_msg</color>")
    self:ShowOrHideWarningView(false)
    self.cardsRemainUI[2].gameObject:SetActive(false)
    self.cardsRemainUI[3].gameObject:SetActive(false)
    self:MyRefresh()
end

function DdzPDKMatchGamePanel:nor_pdk_nor_pai_msg()
    self.DdzPDKMatchPlayersActionManger:Fapai(DdzPDKMatchModel.data.my_pai_list)
    self:RefreshDeadwood()
    self:RefreshRemainPaiWarningStatus()
    ComMatchWaitPanel.ShowPromotionInfo(MatchModel.data.game_id,DdzPDKMatchModel.data.round_info)
end

function DdzPDKMatchGamePanel:nor_pdk_nor_action_msg()
    local act = DdzPDKMatchModel.data.action_list[#DdzPDKMatchModel.data.action_list]
    self.DdzPDKMatchPlayersActionManger:DealAction(DdzPDKMatchModel.data.s2cSeatNum[act.p], act)
    self:RefreshDdzJiPaiQi()
    self:RefreshRangHint()
end

function DdzPDKMatchGamePanel:nor_pdk_nor_permit_msg()
    self.countdown = math.floor(DdzPDKMatchModel.data.countdown)
    self:ShowOrHideActionUI(false, DdzPDKMatchModel.data.s2cSeatNum[DdzPDKMatchModel.data.cur_p])
    self:RefreshPermitStatus()
    self:RefreshDeadwood()
    self:RefreshQDZUI()
    self.DdzPDKMatchActionUiManger:changeActionUIShowByStatus()

    auto_chu_last_pai(self)
end

function DdzPDKMatchGamePanel:nor_pdk_nor_show_pai_msg()
    if not DdzPDKMatchModel.data then return end
    self:RefreshDiZhuAndMultipleStatus()
    self:RefreshRate()
    self:RefreshPlayerInfo()
    self:RefreshDdzJiPaiQi()
    self:RefreshRangHint()
    self:RefreshRemainPaiWarningStatus()
    if DdzPDKMatchModel.data.dizhu then
        local ui_num = DdzPDKMatchModel.GetSeatnoToPos(DdzPDKMatchModel.data.dizhu)
        DDZAnimation.PlayPDKSC(self.transform, ui_num, DdzPDKMatchModel.data.first_cp_type)
    end
end

function DdzPDKMatchGamePanel:nor_pdk_nor_auto_msg(player)
    self:RefreshAutoStatus(DdzPDKMatchModel.data.s2cSeatNum[player])
end

function DdzPDKMatchGamePanel:nor_pdk_nor_bomb_settlement_msg(data)
    for p_seat, pd in ipairs(data) do
        local cSeat = DdzPDKMatchModel.data.s2cSeatNum[p_seat]
        local playerUI = self.playerInfoUI[cSeat]
        DDZAnimation.ChangeScore(cSeat, pd.award, playerUI.score_change_pos)
        if pd.award >= 0 then
            SpineManager.Win(cSeat)
        else
            SpineManager.Lose(cSeat)
        end
    end
    self:RefreshScore()
end

function DdzPDKMatchGamePanel:nor_pdk_nor_settlement_msg()
    self:RefreshSettlement()
    self:RefreshDeadwood()

    local settlement_info = DdzPDKMatchModel.data.settlement_info
    if settlement_info then
        --得分 动画
        if settlement_info.score_data then
            for p_seat, score in pairs(settlement_info.score_data) do
                local cSeat = DdzPDKMatchModel.data.s2cSeatNum[p_seat]
                local playerUI = self.playerInfoUI[cSeat]
                DDZAnimation.ChangeScore(cSeat, score.score, playerUI.score_change_pos)
                if score.score >= 0 then
                    SpineManager.Win(cSeat)
                else
                    SpineManager.Lose(cSeat)
                end
            end
        end
        for p_seat, pd in pairs(settlement_info.score_data) do
            local cSeat = DdzPDKMatchModel.data.s2cSeatNum[p_seat]
            local playerUI = self.playerInfoUI[cSeat]
            if pd.type and pd.type > 1 then
                DDZAnimation.PlayPDKJS(playerUI.js_anim_node, pd.type)
            end
        end
    end
    self:RefreshScore()
end

function DdzPDKMatchGamePanel:nor_pdk_nor_new_game_msg()
    self:MyRefresh()
    --新的局数
    if DdzPDKMatchModel.data then
        local curRace = DdzPDKMatchModel.data.race
        if curRace then
            DDZAnimation.CurRace(curRace, self.start_again_cards_pos)
        end
    end
end

function DdzPDKMatchGamePanel:nor_mg_wait_revive_msg()
    if not DdzPDKMatchModel.data then return end
    self:RefreshRevive()
end

function DdzPDKMatchGamePanel:nor_mg_free_revive_msg()
    self:HideRevivePanel()
end

function DdzPDKMatchGamePanel:nor_mg_revive_response(data)
    if data.result == 0 then
        self:HideRevivePanel()
    end
end

--************************Refresh
function DdzPDKMatchGamePanel:update_callback()
    local dt = 1
    if self.countdown and self.countdown > 0 then
        self.countdown = self.countdown - dt
    end
    self:RefreshClock()

    --最后一手牌自动出牌
    if self.last_pai_auto_countdown then
        self.last_pai_auto_countdown = self.last_pai_auto_countdown - dt
        if self.last_pai_auto_countdown == 0 and self.last_pai_auto_cb then
            self.last_pai_auto_cb()
        end
    end
end

--刷新晋级
function DdzPDKMatchGamePanel:RefreshPromoted(is_ani)
    if DdzPDKMatchModel.data then
        --玩家在配桌界面直接进入游戏需要隐藏
        self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
        local myData = DdzPDKMatchModel.data
        if myData.model_status == DdzPDKMatchModel.Model_Status.promoted then
            if myData.promoted_type then
                --0表示普通晋级 1表示晋级决赛
                local isMatch = myData.promoted_type == 1
                ExtendSoundManager.PlaySound(audio_config.match.bgm_bisai_jinji.audio_name)
                PlayerInfoPanel.Exit()
                GameSpeedyPanel.Hide()
                self:ShowWaitPanel(is_ani)
            end
        end
    end
end

--刷新等待
function DdzPDKMatchGamePanel:RefreshWait()
    if DdzPDKMatchModel.data then
        --玩家在配桌界面直接进入游戏需要隐藏
        self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
        local myData = DdzPDKMatchModel.data
        if myData.model_status == DdzPDKMatchModel.Model_Status.wait_result then
            PlayerInfoPanel.Exit()
            GameSpeedyPanel.Hide()
            self:ShowWaitPanel()
        end
    end
end

function DdzPDKMatchGamePanel:RefreshRound()
    if DdzPDKMatchModel.data then
        local round_info = DdzPDKMatchModel.data.round_info
        local race = DdzPDKMatchModel.data.race
        self.dizhu_card_son.cur_match_txt.gameObject:SetActive(false)
        self.dizhu_card_son.cur_base_score_txt.gameObject:SetActive(false)
        self.dizhu_card_son.cur_multiple_txt.gameObject:SetActive(false)
        if round_info then
            --此轮晋级人数 此轮的局数
            if round_info.round_type == 0 then
                --初赛
                self.dizhu_card_son.cur_match_txt.text =
                    "预赛 第" .. round_info.round .. "局（低于" .. round_info.rise_score .. "分将被淘汰）"
            elseif round_info.round_type == 1 then
                --决赛
                self.dizhu_card_son.cur_match_txt.text =
                    "晋级赛 第" .. round_info.round .. "局 " .. round_info.rise_num .. "人晋级"
            end

            if race and round_info.race_count then
                self.dizhu_card_son.cur_pai_race_txt.text = "第" .. race .. "副（共" .. round_info.race_count .. "副）"
            end

            self.dizhu_card_son.cur_match_txt.gameObject:SetActive(true)
            --此轮的底分
            if round_info.init_stake then
                if round_info.round_type == 0 then
                    --初赛
                    self.dizhu_card_son.cur_base_score_txt.text = "预赛 底分" .. round_info.init_stake
                elseif round_info.round_type == 1 then
                    --决赛
                    self.dizhu_card_son.cur_base_score_txt.text = "晋级赛 底分" .. round_info.init_stake
                end
                self.dizhu_card_son.cur_base_score_txt.gameObject:SetActive(true)
            end
            --此轮的初始倍率
            if round_info.init_rate and DdzPDKMatchModel.data.my_rate then
                self.dizhu_card_son.cur_multiple_txt.text = DdzPDKMatchModel.data.my_rate .. "倍"
                self.dizhu_card_son.cur_multiple_txt.gameObject:SetActive(true)
            end
        end
    end
end

function DdzPDKMatchGamePanel:RefreshRate()
    self.cur_multiple_txt.gameObject:SetActive(false)
    -- if DdzPDKMatchModel.data then
    --     local my_rate = DdzPDKMatchModel.data.my_rate
    --     if my_rate then
    --         self.cur_multiple_txt.gameObject:SetActive(true)
    --         self.cur_multiple_txt.text = my_rate .. "倍"
    --     end
    -- end
end

function DdzPDKMatchGamePanel:RefreshRank()
    if DdzPDKMatchModel.data then
        local player = self.playerInfoUI[1]
        if DdzPDKMatchModel.data.rank and DdzPDKMatchModel.data.total_players then
            if DdzPDKMatchModel.data.match_player_num and DdzPDKMatchModel.data.rank <= DdzPDKMatchModel.data.match_player_num then
                player.rank_txt.text = DdzPDKMatchModel.data.rank .. "/" .. DdzPDKMatchModel.data.match_player_num
            else
                player.rank_txt.text = DdzPDKMatchModel.data.rank .. "/" .. DdzPDKMatchModel.data.total_players
            end
        elseif DdzPDKMatchModel.data.total_players then
            player.rank_txt.text = DdzPDKMatchModel.data.total_players .. "/" .. DdzPDKMatchModel.data.total_players
        end
    end
end

function DdzPDKMatchGamePanel:RefreshScore(p_seat)
    if DdzPDKMatchModel.data then
        if p_seat then
            local player = self.playerInfoUI[p_seat]
            local score
            if
                DdzPDKMatchModel.data.players_info and DdzPDKMatchModel.data.seatNum and
                    DdzPDKMatchModel.data.players_info[DdzPDKMatchModel.data.seatNum[p_seat]]
             then
                score = DdzPDKMatchModel.data.players_info[DdzPDKMatchModel.data.seatNum[p_seat]].score
                if score then
                    player.score_txt.text = score
                end
            end
        else
            for p_seat = 1, DdzPDKMatchModel.maxPlayerNumber do
                local player = self.playerInfoUI[p_seat]
                local score
                if p_seat == 1 then
                    score = DdzPDKMatchModel.data.score
                else
                    score = DdzPDKMatchModel.data.players_info[DdzPDKMatchModel.data.seatNum[p_seat]].score
                end
                if score then
                    player.score_txt.text = score
                end
            end
        end
    end
end

function DdzPDKMatchGamePanel:RefreshAutoStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzPDKMatchModel.data then
        local auto = DdzPDKMatchModel.data.auto_status
        if auto and DdzPDKMatchModel.data.seatNum then
            --刷新全部
            if not pSeatNum then
                --刷新单个人
                for i = 1, DdzPDKMatchModel.maxPlayerNumber do
                    if auto[DdzPDKMatchModel.data.seatNum[i]] == 1 then
                        --显示
                        if i == 1 then
                            self.DdzPDKMatchPlayersActionManger:ChangeClickStatus(1)
                        end
                        self.autoUI[i]:SetActive(true)
                    else
                        --隐藏
                        if i == 1 then
                            self.DdzPDKMatchPlayersActionManger:ChangeClickStatus(0)
                        end
                        self.autoUI[i]:SetActive(false)
                    end
                end
            else
                if auto[DdzPDKMatchModel.data.seatNum[pSeatNum]] == 1 then
                    --显示
                    if pSeatNum == 1 then
                        self.DdzPDKMatchPlayersActionManger:ChangeClickStatus(1)
                    end
                    self.autoUI[pSeatNum]:SetActive(true)
                else
                    --隐藏
                    if pSeatNum == 1 then
                        self.DdzPDKMatchPlayersActionManger:ChangeClickStatus(0)
                    end
                    self.autoUI[pSeatNum]:SetActive(false)
                end
            end
        end
    end
end

function DdzPDKMatchGamePanel:RefreshRemainPaiWarningStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzPDKMatchModel.data then
        local remain_pai_amount = DdzPDKMatchModel.data.remain_pai_amount
        if remain_pai_amount and DdzPDKMatchModel.data.seatNum then
            --刷新全部
            if not pSeatNum then
                --刷新单个人
                for i = 1, DdzPDKMatchModel.maxPlayerNumber do
                    --刷新warning
                    if self.warningUI[i] then
                        if remain_pai_amount[DdzPDKMatchModel.data.seatNum[i]] < 2 then
                            --显示
                            self.warningUI[i]:SetActive(true)
                        else
                            --隐藏
                            self.warningUI[i]:SetActive(false)
                        end
                    end
                    --刷新牌的数量
                    if self.cardsRemainUI[i] then
                        self.playerOperateUI[i].cards_remain.transform.gameObject:SetActive(true)
                        self.playerOperateUI[i].remain_count_txt.text = remain_pai_amount[DdzPDKMatchModel.data.seatNum[i]]
                    end
                end
            else
                --刷新warning
                if self.warningUI[pSeatNum] then
                    if remain_pai_amount[DdzPDKMatchModel.data.seatNum[pSeatNum]] < 2 then
                        --显示
                        self.warningUI[pSeatNum]:SetActive(true)
                    else
                        --隐藏
                        self.warningUI[pSeatNum]:SetActive(false)
                    end
                end

                --刷新牌的数量
                if self.cardsRemainUI[pSeatNum] then
                    self.playerOperateUI[pSeatNum].remain_count_txt.text =
                        remain_pai_amount[DdzPDKMatchModel.data.seatNum[pSeatNum]]
                end
            end
        end
    end
end

function DdzPDKMatchGamePanel:RefreshRemainPaiWarningStatusWithAni(pSeatNum, act_type, pai_count)
    self:RefreshRemainPaiWarningStatus(pSeatNum)
    pai_count = pai_count or DdzPDKMatchModel.data.remain_pai_amount[DdzPDKMatchModel.data.seatNum[pSeatNum]]
    if pai_count == 1 and act_type ~= 0 then
        ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_card_leftwarning.audio_name)
        local sound = "sod_game_card_left1" .. AudioBySex(DdzPDKMatchModel, DdzPDKMatchModel.data.seatNum[pSeatNum])
        ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
    end
end

-- 刷新简易交互UI
function DdzPDKMatchGamePanel:RefreshEasyChat()
    local dizhu = DdzPDKMatchModel.data.dizhu
    local b = true
    if dizhu and dizhu > 0 then
        b = false
    end
    for i = 1, DdzPDKMatchModel.maxPlayerNumber do
        self.EasyButton[i].gameObject:SetActive(b)
        self.HeroEasyButton[i].gameObject:SetActive(not b)
    end
end

function DdzPDKMatchGamePanel:RefreshPlayerInfo(pSeatNum)
    if DdzPDKMatchModel.data then
        self:RefreshEasyChat()
        local dizhu = DdzPDKMatchModel.data.dizhu
        local playerInfo = DdzPDKMatchModel.data.players_info
        local RefreshPlayerAllInfo = function(pSeatNum)
            if not pSeatNum then
                return
            end
            
            local info = playerInfo[DdzPDKMatchModel.data.seatNum[pSeatNum]]
            local player = self.playerInfoUI[pSeatNum]
            if info then
                --刷新头像 根据渠道 1，微信 2，游客
                URLImageManager.UpdateHeadImage(info.head_link, player.cust_head_img)
                self:ShowOrHideCustHeadIcon(false, pSeatNum)
                self:RefreshScore(pSeatNum)
                self:ShowOrHideHeadInfo(true, pSeatNum)
                self:ShowOrHidePlayerInfo(true, pSeatNum)
                PersonalInfoManager.SetHeadFarme(player.cust_head_icon_img, info.dressed_head_frame)
                VIPManager.set_vip_text(player.head_vip_txt,info.vip_level)
                if pSeatNum == 1 then
                    self:RefreshRank(pSeatNum)
                else
                    player.name_txt.text = info.name
                end
            else
                self:ShowOrHideCustHeadIcon(true, pSeatNum)
                self:ShowOrHideHeadInfo(false, pSeatNum)
                self:ShowOrHidePlayerInfo(false, pSeatNum)
            end
        end

        local RefreshPlayerTextInfo = function(pSeatNum)
            local info = playerInfo[DdzPDKMatchModel.data.seatNum[pSeatNum]]
            local player = self.playerInfoUI[pSeatNum]
            if info then
                local player = self.playerInfoUI[pSeatNum]
                self:RefreshScore(pSeatNum)
                if pSeatNum == 1 then
                    self:RefreshRank(pSeatNum)
                else
                    player.name_txt.text = info.name
                end
            else
                self:ShowOrHidePlayerInfo(false, pSeatNum)
            end
        end

        --地主框 隐藏
        SpineManager.RemoveAllDDZPlayerSpine()
        --头像隐藏
        self:ShowOrHideCustHeadIcon(true, pSeatNum)
        self:ShowOrHideHeadInfo(false, pSeatNum)
        self:ShowOrHidePlayerInfo(false, pSeatNum)

        if playerInfo and next(playerInfo) then
            --刷新全部
            if not pSeatNum then
                --刷新单个人
                for i = 1, DdzPDKMatchModel.maxPlayerNumber do
                    RefreshPlayerAllInfo(i)
                end
            else
                RefreshPlayerAllInfo(pSeatNum)
            end
        end
    end
end

-- 刷新放走包赔提示
function DdzPDKMatchGamePanel:RefreshFZBPHint()
    self.playerOperateUI[1].hint_baopei.gameObject:SetActive(false)
    local data = DdzPDKMatchModel.data
    if data then
        local status = data.status
        local cur_p = data.cur_p
        if status == DdzPDKMatchModel.Status.cp then
            if cur_p == data.seat_num then
                -- 获取下家座位号(自己的UI位置是1,下家就是2)
                local xj_seat = DdzPDKMatchModel.GetPosToSeatno(2)
                dump(data.remain_pai_amount, "<color=red>remain_pai_amount</color>")
                print(xj_seat)
                if data.remain_pai_amount[xj_seat] < 2 then
                    self.playerOperateUI[1].hint_baopei.gameObject:SetActive(true)
                end
            end
        end
    end
end

function DdzPDKMatchGamePanel:RefreshPermitStatus()
    --隐藏所有权限
    self:ShowOrHidePermitUI(false)
    if DdzPDKMatchModel.data then
        self:RefreshFZBPHint()
        local data = DdzPDKMatchModel.data
        local status = DdzPDKMatchModel.data.status
        local cur_p = DdzPDKMatchModel.data.cur_p
        if
            (status == DdzPDKMatchModel.Status.jdz or 
                status == DdzPDKMatchModel.Status.jiabei or
                status == DdzPDKMatchModel.Status.cp or
                status == DdzPDKMatchModel.Status.q_dizhu) and
                cur_p
         then
            if cur_p > 0 and cur_p < 4 then
                --teshu
                --我自己
                if cur_p == data.seat_num then
                    --其他人
                    local permitData = DdzPDKMatchModel.getMyPermitData()
                    if permitData then
                        self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                        if permitData.type == DdzPDKMatchModel.Status.jdz then
                            --将背景颜色还原
                            change_btn_image(self.playerself_operate_son.jdz_1_btn, "ddz_btn_3", true)
                            change_btn_image(self.playerself_operate_son.jdz_2_btn, "ddz_btn_3", true)
                            change_btn_image(self.playerself_operate_son.jdz_3_btn, "ddz_btn_3", true)

                            if DdzPDKMatchModel.data.game_type == DdzPDKMatchModel.game_type.er then
                                self.playerself_operate_son.jiaodizhuer.gameObject:SetActive(true)
                                self:RefreshClockPos(self.playerself_operate_son.dizhu_time_er_pos)
                            else
                                self.playerself_operate_son.jiaodizhu.gameObject:SetActive(true)
                                self:RefreshClockPos(self.playerself_operate_son.dizhu_time_pos)
                            end

                            --根据数据将背景颜色变灰
                            if permitData.jdz_min == 3 then
                                change_btn_image(self.playerself_operate_son.jdz_1_btn, "ddz_btn_2", false)
                                change_btn_image(self.playerself_operate_son.jdz_2_btn, "ddz_btn_2", false)
                            elseif permitData.jdz_min == 2 then
                                change_btn_image(self.playerself_operate_son.jdz_1_btn, "ddz_btn_2", false)
                            end
                        elseif permitData.jiabei == DdzPDKMatchModel.Status.jiabei then
                            self.playerself_operate_son.jiabei.gameObject:SetActive(true)
                            self:RefreshClockPos(self.playerself_operate_son.jiabei_time_pos)
                        elseif permitData.type == DdzPDKMatchModel.Status.q_dizhu then
                            self.playerself_operate_son.qiangdizhu.gameObject:SetActive(true)
                            self:RefreshClockPos(self.playerself_operate_son.qiangdizhu_time_pos)
                        else
                            --cp
                            if permitData.power == 0 then
                                --将不出显示
                                -- self.playerself_operate_son.no_play_btn.gameObject:SetActive(true)
                                self.playerself_operate_son.chupai.gameObject:SetActive(true)
                                if permitData.is_must then
                                    --将不出隐藏
                                    -- self.playerself_operate_son.no_play_btn.gameObject:SetActive(false)
                                end
                                self:RefreshClockPos(self.playerself_operate_son.chupai_time_pos)
                            else
                                self.playerself_operate_son.yaobuqi.gameObject:SetActive(true)
                                SpineManager.YaoBuQi(1)
                                if self.autoUI[1].activeSelf then
                                    self.playerself_operate_son.yaobuqi.transform:Find("@yaobuqi_txt").gameObject:SetActive(
                                        false
                                    )
                                else
                                    self.playerself_operate_son.yaobuqi.transform:Find("@yaobuqi_txt").gameObject:SetActive(
                                        true
                                    )
                                end
                                self.DdzPDKMatchPlayersActionManger:ChangeClickStatus(1)
                                self:RefreshClockPos(self.playerself_operate_son.yaobuqi_time_pos)
                            end
                        end
                    end
                elseif DdzPDKMatchModel.data.s2cSeatNum then
                    if DdzPDKMatchModel.data.s2cSeatNum[cur_p] == 2 then
                        self:ShowOrHidePermitUI(true, 2)
                    elseif DdzPDKMatchModel.data.s2cSeatNum[cur_p] == 3 then
                        self:ShowOrHidePermitUI(true, 3)
                    end
                end
            else
            end
            --给闹钟赋予初始值
            for i = 1, DdzPDKMatchModel.maxPlayerNumber do
                if self.timerUI[i].gameObject.activeSelf then
                    self.timerTextUI[i].text = self.countdown
                else
                    if self.timerTween[i] then
                        self.timerTween[i].Kill()
                    end
                end
            end
        end
    end
end

function DdzPDKMatchGamePanel:RefreshClockPos(parent)
    self.playerself_operate_son.wait_time.transform:SetParent(parent.transform)
    self.playerself_operate_son.wait_time.transform.localPosition = Vector3.zero
end

--刷新结算
function DdzPDKMatchGamePanel:RefreshSettlement()
    if DdzPDKMatchModel.data then
        local mData = DdzPDKMatchModel.data
        local settlement_info = DdzPDKMatchModel.data.settlement_info
        if settlement_info then
            --玩家剩余的牌
            if settlement_info.remain_pai then
                for k, v in pairs(settlement_info.remain_pai) do
                    --其他玩家的牌
                    local p_seat = v.p
                    local pai_list = v.pai
                    local cSeatNum = DdzPDKMatchModel.data.s2cSeatNum[p_seat]
                    if cSeatNum ~= 1 then
                        local show_list = nor_pdk_base_lib.norId_convert_to_lzId(pai_list, DdzPDKMatchModel.data.laizi)
                        if show_list then
                            table.sort(show_list)
                        end
                        self.DdzPDKMatchActionUiManger:RefreshAction(cSeatNum, {type = -1, show_list = show_list})
                    end
                end
            end
        end
    end
end

--刷新地主UI显示
function DdzPDKMatchGamePanel:RefreshDiZhuAndMultipleStatus()
    if DdzPDKMatchModel.data then
        local myData = DdzPDKMatchModel.data
        if not myData.dz_pai then
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(false)
            self.dizhu_card_son.dzcards.gameObject:SetActive(false)
        else
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(false)
            self.dizhu_card_son.dzcards.gameObject:SetActive(true)
            destroyChildren(self.dizhu_card_son.dzcards.transform)
            for k, v in pairs(myData.dz_pai) do
                DdzDzCard.New(self.dzCardObj, self.dizhu_card_son.dzcards.transform, v, v, 0)
            end
        end
    end
end

function DdzPDKMatchGamePanel:RefreshClock()
    local flag = nil
    for i = 1, DdzPDKMatchModel.maxPlayerNumber do
        if self.timerUI[i].gameObject.activeSelf then
            local isZero = self.timerTextUI[i].text == "0"
            self.timerTextUI[i].text = self.countdown
            if self.countdown <= 5 and not isZero and not self.timerTween[i] then
                self.timerTween[i] = DDZAnimation.clockCountdown(self.timerTextUI[i])
                flag = true
            end
        end
    end
    if flag then
        ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_timeout.audio_name)
    end
end

function DdzPDKMatchGamePanel:RefreshDdzJiPaiQi()
    self:AutoShowDdzJiPaiQiCB()
    if DdzPDKMatchModel.data then
        local statistics = self.playerself_operate_son.statistics
        if DdzPDKMatchModel.data then
            local jipaiqi = DdzPDKMatchModel.data.jipaiqi
            if not jipaiqi then
                for i = 0, statistics.transform.childCount - 1 do
                    local child = statistics:GetChild(i):GetComponent("Text")
                    child.text = "-"
                    child.color = self.colorGary
                end
            else
                for i = 0, statistics.transform.childCount - 1 do
                    local child = statistics:GetChild(i)
                    local childText = child:GetComponent("Text")
                    local key = 15 - i
                    local count = jipaiqi[key]

                    childText.text = count
                    -- if key == 17 or key == 16 then
                    --     if count == 1 then
                    --         childText.color = self.colorYellow
                    --     else
                    --         childText.color = self.colorGary
                    --     end
                    -- else
                        if count == 4 then
                            childText.color = self.colorYellow
                        elseif count == 0 then
                            childText.color = self.colorGary
                        else
                            childText.color = Color.white
                        end
                    -- end
                end
            end
        end
        self.playerself_operate_son.record_btn.gameObject:SetActive(GameGlobalOnOff.JPQTool)
    end
    self:IsShow_JpqNotice()
end

--刷新废牌
function DdzPDKMatchGamePanel:RefreshDeadwood()
    if DdzPDKMatchModel.data.game_type ~= DdzPDKMatchModel.game_type.er then
        return
    end
    print("<color=red>RefreshDeadwood>>>>>>>>>>>>>>>>>>>>>>>>> </color>")
    self:DelDeadwood()
    local mData = DdzPDKMatchModel.data
    if mData.status == DdzPDKMatchModel.Status.fp or mData.status == DdzPDKMatchModel.Status.settlement or mData.deadwood_list then
        self.DNode.gameObject:SetActive(true)
        if mData.deadwood_list then
            local show_list = nor_pdk_base_lib.norId_convert_to_lzId(mData.deadwood_list.pai, mData.laizi)
            if show_list then
                table.sort(show_list)
            end
            for k, v in ipairs(show_list) do
                local card = DdzCard.New(self.cardObj, self.DeadwoodNode, v, v, 0)
                self.deadwoodList[#self.deadwoodList + 1] = card
            end
        else
            for i = 1, 9 do
                local card = DdzCard.New(self.cardObj, self.DeadwoodNode, 0, 0, 0)
                self.deadwoodList[#self.deadwoodList + 1] = card
            end
        end
    else
        self.DNode.gameObject:SetActive(false)
        self:DelDeadwood()
    end
end

--抢地主
function DdzPDKMatchGamePanel:RefreshQDZUI()
    if DdzPDKMatchModel.data.game_type ~= DdzPDKMatchModel.game_type.er then
        return
    end
    local m_data = DdzPDKMatchModel.data
    if
        m_data and m_data.status == DdzPDKMatchModel.Status.q_dizhu and m_data.er_qiang_dizhu_count and
            m_data.er_qiang_dizhu_count > 0
     then
        self.playerOperateUI[1].qiang_hint_txt.text = "抢" .. m_data.er_qiang_dizhu_count .. "次"
    else
        self.playerOperateUI[1].qiang_hint_txt.text = ""
    end
end

-- 刷新让牌提示
function DdzPDKMatchGamePanel:RefreshRangHint()
    if DdzPDKMatchModel.data.game_type ~= DdzPDKMatchModel.game_type.er then
        return
    end
    local m_data = DdzPDKMatchModel.data
    if m_data and m_data.dizhu and m_data.remain_pai_amount then
        self.rang_pai_hint_node.gameObject:SetActive(true)
        local num = m_data.remain_pai_amount[DdzPDKMatchModel.GetSeatNM()] - m_data.rangpai_num
        if num < 0 then
            num = 0
        end
        if m_data.dizhu == m_data.seat_num then
            self.rang_pai_hint_txt.text = string.format("你需要让出%d张牌，对方再打出%d张牌即可获得胜利", m_data.rangpai_num, num)
        else
            self.rang_pai_hint_txt.text = string.format("你被让了%d张牌，再打出%d张牌就可获得胜利", m_data.rangpai_num, num)
        end
    else
        self.rang_pai_hint_node.gameObject:SetActive(false)
    end
end

--********************callback
function DdzPDKMatchGamePanel:OnEasyClick(obj)
    local uipos = tonumber(string.sub(obj.name, -1, -1))
    local data = DdzPDKMatchModel.GetPosToPlayer(uipos)
    if data then
        PlayerInfoPanel.Create(data, uipos)
    else
        dump(data, "<color=red>玩家没有入座</color>")
    end
end

function DdzPDKMatchGamePanel:DdzJiPaiQiCB()
    -- isGuideHint = false
    self.BubbleNode.gameObject:SetActive(false)

    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if GameItemModel.GetItemCount("jipaiqi") > 0 then
        local statistics = self.playerself_operate_son.statistics
        self.isShowStatistics = not statistics.gameObject.activeSelf
        statistics.gameObject:SetActive(self.isShowStatistics)
        self:RefreshDdzJiPaiQi()
    else
        local pay_record = self.playerself_operate_son.pay_record
        pay_record.gameObject:SetActive(not pay_record.gameObject.activeSelf)
    end
end

function DdzPDKMatchGamePanel:DdzPayJiPaiQiCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    PayPanel.Create(
        GOODS_TYPE.item,
        "normal",
        function()
            self:RefreshDdzJiPaiQi()
        end,
        ITEM_TYPE.expression
    )
    self.playerself_operate_son.pay_record.gameObject:SetActive(false)
end

function DdzPDKMatchGamePanel:MenuCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local menu_bg = self.menu_son.menu_bg
    local b = not menu_bg.gameObject.activeSelf
    menu_bg.gameObject:SetActive(b)
    self.TopButtonImage.gameObject:SetActive(b)
end

function DdzPDKMatchGamePanel:CloseCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    HintPanel.Create(1, "比赛中不能退出")
end

function DdzPDKMatchGamePanel:HelpCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    DdzHelpPanel.Create("PDK")
end

function DdzPDKMatchGamePanel:SetCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    SettingPanel.Show()
end

function DdzPDKMatchGamePanel:CanelAutoBtnCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if Network.SendRequest("nor_pdk_nor_auto", {operate = 0}) then
        self.autoUI[1]:SetActive(false)
    else
        DDZAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end
end

--*****************ShowOrHide
function DdzPDKMatchGamePanel:ShowOrHideWarningView(status)
    for i = 1, DdzPDKMatchModel.maxPlayerNumber do
        --刷新warning
        if self.warningUI[i] then
            --隐藏
            self.warningUI[i]:SetActive(false)
        end
    end
end

function DdzPDKMatchGamePanel:ShowOrHideDdzView(status)
    self.ddz_match_dizhu_card_ui.gameObject:SetActive(status)
    self.menu_btn.gameObject:SetActive(status)
    self.ddz_match_playerright_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerright_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_operate_ui.gameObject:SetActive(status)
end

function DdzPDKMatchGamePanel:ShowOrHidePermitUI(status, people)
    if people == 2 then
        self.playerright_operate_son.wait_time.gameObject:SetActive(status)
    elseif people == 3 then
        self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
    else
        self.playerself_operate_son.wait_time.gameObject:SetActive(status)
        if self.playerself_operate_son.yaobuqi.gameObject.activeSelf then
            if status == true then
                self.DdzPDKMatchPlayersActionManger:ChangeClickStatus(1)
            else
                if not self.autoUI[1].activeSelf then
                    self.DdzPDKMatchPlayersActionManger:ChangeClickStatus(0)
                end
            end
        end
        self.playerself_operate_son.yaobuqi.gameObject:SetActive(status)
        -- if not status then
        --     SpineManager.DaiJi(1)
        -- end
        self.playerself_operate_son.chupai.gameObject:SetActive(status)
        if DdzPDKMatchModel.data.game_type == DdzPDKMatchModel.game_type.er then
            self.playerself_operate_son.jiaodizhuer.gameObject:SetActive(status)
            self.playerself_operate_son.qiangdizhu.gameObject:SetActive(status)
        else
            self.playerself_operate_son.jiaodizhu.gameObject:SetActive(status)
        end
        self.playerself_operate_son.jiabei.gameObject:SetActive(status)
        if not people then
            self.playerright_operate_son.wait_time.gameObject:SetActive(status)
            self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
        end
    end
end

function DdzPDKMatchGamePanel:ShowOrHideActionUI(status, people)
    if people == 2 then
        self.playerright_operate_son.my_action.gameObject:SetActive(status)
    elseif people == 3 then
        self.playerleft_operate_son.my_action.gameObject:SetActive(status)
    else
        self.playerself_operate_son.my_action.gameObject:SetActive(status)
        if not people then
            self.playerright_operate_son.my_action.gameObject:SetActive(status)
            self.playerleft_operate_son.my_action.gameObject:SetActive(status)
        end
    end
end

function DdzPDKMatchGamePanel:ShowOrHideCustHeadIcon(status, seatNum)
    -- if not seatNum then
    --     for i = 1, DdzPDKMatchModel.maxPlayerNumber do
    --         self.playerInfoUI[i].cust_head_icon_img.gameObject:SetActive(status)
    --     end
    -- else
    --     self.playerInfoUI[seatNum].cust_head_icon_img.gameObject:SetActive(status)
    -- end
end

function DdzPDKMatchGamePanel:ShowOrHideHeadInfo(status, seatNum)
    if DdzPDKMatchModel.data then
        if not seatNum then
            for i = 1, DdzPDKMatchModel.maxPlayerNumber do
                self.playerInfoUI[i].cust_head_icon_img.gameObject:SetActive(status)
                self.playerInfoUI[i].head_vip_txt.gameObject:SetActive(status)
                self.playerInfoUI[i].cust_head_img.gameObject:SetActive(status)
            end
        else
            self.playerInfoUI[seatNum].cust_head_icon_img.gameObject:SetActive(status)
            self.playerInfoUI[seatNum].head_vip_txt.gameObject:SetActive(status)
            self.playerInfoUI[seatNum].cust_head_img.gameObject:SetActive(status)
        end
    end
end

function DdzPDKMatchGamePanel:ShowOrHidePlayerInfo(status, seatNum)
    if DdzPDKMatchModel.data then
        if not seatNum then
            for i = 1, DdzPDKMatchModel.maxPlayerNumber do
                self.playerInfoUI[i].info.gameObject:SetActive(status)
                if self.playerInfoUI[i].myscore then
                    self.playerInfoUI[i].myscore.gameObject:SetActive(status)
                end
            end
        else
            self.playerInfoUI[seatNum].info.gameObject:SetActive(status)
            if self.playerInfoUI[seatNum].myscore then
                self.playerInfoUI[seatNum].myscore.gameObject:SetActive(status)
            end
        end
    end
end

function DdzPDKMatchGamePanel:SetHideMenu()
    local menu_bg = self.menu_son.menu_bg
    menu_bg.gameObject:SetActive(false)
    self.TopButtonImage.gameObject:SetActive(false)
end

function DdzPDKMatchGamePanel:AutoShowDdzJiPaiQiCB()
    if GameGlobalOnOff.JPQTool and GameItemModel.GetItemCount("jipaiqi") > 0 then
        -- isGuideHint = false
        self.BubbleNode.gameObject:SetActive(false)
        local is_show = true     
        -- if DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.wait_begin then
        --     is_show = false
        -- else
        --     is_show = true
        -- end
        if self.isShowStatistics ~= nil then
            is_show = self.isShowStatistics
        end
        self.playerself_operate_son.statistics.gameObject:SetActive(is_show)
    end
end

--二人
function DdzPDKMatchGamePanel:DelDeadwood()
    if self.deadwoodList then
        for i = 1, #self.deadwoodList do
            self.deadwoodList[i]:Destroy()
        end
    end
    self.deadwoodList = {}
end

function DdzPDKMatchGamePanel:nor_mg_gameover_msg()
    local gameCfg = MatchModel.GetGameCfg(MatchModel.data.game_id)
    if gameCfg.round and #gameCfg.round > 0 and DdzPDKMatchModel.data.round_info and DdzPDKMatchModel.GetCurRoundId() < #gameCfg.round then
        self:ShowWaitPanel()
    end
end

function DdzPDKMatchGamePanel:RefreshGamingPlayerNum()
    if DdzPDKMatchModel.data.model_status ~= DdzPDKMatchModel.Model_Status.wait_begin then
        Network.SendRequest("nor_mg_req_cur_player_num")
    end
end

function DdzPDKMatchGamePanel:on_nor_mg_req_cur_player_num__response(proto_name, data)
    --dump(data, "<color=yellow>on_nor_mg_req_cur_player_num</color>")
    if DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.gameover then
        return
    end
    self:RefreshRank()
end

function DdzPDKMatchGamePanel:RefreshRevive()
    if not DdzPDKMatchModel.data then return end
    self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
    local myData = DdzPDKMatchModel.data
    if myData.model_status == DdzPDKMatchModel.Model_Status.wait_revive then
        PlayerInfoPanel.Exit()
        GameSpeedyPanel.Hide()
        self:ShowRevivePanel()
    end
end

function DdzPDKMatchGamePanel:ShowWaitPanel(is_ani)
    local _data = DdzPDKMatchModel.data
    local data = {}
    data.state = _data.model_status
	data.game_cfg = MatchModel.GetGameCfg(_data.game_id)
	data.award_cfg = MatchModel.GetGameIDToAward(_data.game_id)
	data.my_rank = _data.rank
	data.match_player_num = _data.match_player_num
	data.in_table_player_num = _data.in_table_player_num
    data.one_table_player_num = DdzPDKMatchModel.maxPlayerNumber
    
    data.is_pro = is_ani
    data.round_info = _data.round_info
    data.total_players = _data.total_players

    ComMatchWaitPanel.Create(data)
end

function DdzPDKMatchGamePanel:HideWaitPanel()
    ComMatchWaitPanel.Close()
end

function DdzPDKMatchGamePanel:ShowRevivePanel()
    local _data = DdzPDKMatchModel.data
    if not _data.revive_num or _data.revive_num <= 0 or not _data.revive_time or _data.revive_time <= 0 then 
        self:HideRevivePanel()
        return 
    end

    local data = {}
    data.revive_num = _data.revive_num
    data.revive_time = _data.revive_time
    data.revive_assets = _data.revive_assets
    data.revive_round = _data.revive_round
    local game_cfg = MatchModel.GetGameCfg(_data.game_id)
    ComMatchRevivePanel.Create(data,game_cfg)
end

function DdzPDKMatchGamePanel:HideRevivePanel()
    ComMatchRevivePanel.Close()
end

function DdzPDKMatchGamePanel:IsShow_JpqNotice()
    if true then
        self.playerself_operate_son.jipaiqi_notice.gameObject:SetActive(false)
        return
    end

    self.playerself_operate_son.jipaiqi_notice.gameObject.transform.localPosition = Vector2.New(329,-507)
    if GameItemModel.GetItemCount("jipaiqi") > 0 or (_G["SYSYKManager"] and SYSYKManager.IsBuy) then
        self.playerself_operate_son.jipaiqi_notice.gameObject:SetActive(false)
    else
        if GameGlobalOnOff.IOSTS then
            self.playerself_operate_son.jipaiqi_notice.gameObject:SetActive(false)
	else
	    self.playerself_operate_son.jipaiqi_notice.gameObject:SetActive(true)
	end
    end 
end