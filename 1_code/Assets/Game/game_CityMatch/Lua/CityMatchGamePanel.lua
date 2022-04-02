local basefunc = require "Game.Common.basefunc"
local nor_ddz_base_lib = require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"
--数据结构
--说明：位置坐标系  我的位置永远为1 逆时针 2 3，

CityMatchGamePanel = basefunc.class()

CityMatchGamePanel.name = "CityMatchGamePanel"
local lister
local listerRegisterName = "CityMatchGameListerRegister"

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
        self.close_txt.text = text
    end
end

local function auto_chu_last_pai(self)
    local m_data = CityMatchModel.data
    if m_data.status == CityMatchModel.Status.cp then
        local pos = m_data.s2cSeatNum[m_data.cur_p]
        if pos == 1 then
            local _act =
                CityMatchModel.ddz_algorithm:check_is_only_last_pai(
                m_data.action_list,
                m_data.my_pai_list,
                m_data.laizi
            )
            if _act then
                self.last_pai_auto_countdown = 1
                self.last_pai_auto_cb = function()
                    self.last_pai_auto_cb = nil
                    self.last_pai_auto_countdown = nil
                    local manager = self.CityMatchPlayersActionManger
                    --将所有的牌弹起
                    for no, v in pairs(manager.my_pai_hash) do
                        v:ChangePosStatus(1)
                    end
                    --出牌btn
                    manager:SendChupaiRequest(_act)
                end
            end
        end
    end
end

local instance

--**********************框架
function CityMatchGamePanel.Create()
    instance = CityMatchGamePanel.New()
    instance.dzCardObj = GetPrefab("DdzDzCard")
    instance.cardObj = GetPrefab("DdzCard")
    return createPanel(instance, CityMatchGamePanel.name)
end

function CityMatchGamePanel.Bind()
    local _in = instance
    instance = nil
    return _in
end

function CityMatchGamePanel:Awake()
    ExtendSoundManager.PlaySceneBGM(audio_config.ddz.ddz_bgm_game.audio_name)
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
    self.promoted_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_promoted_ui.transform, self.promoted_son)
    self.wait_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_wait_ui.transform, self.wait_son)
    self.menu_son = {}
    LuaHelper.GeneratingVar(self.menu_btn.transform, self.menu_son)
    self.statistics_son = {}
    LuaHelper.GeneratingVar(self.statistics.transform, self.statistics_son)

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
            SysInteractiveChatManager.Show()
        end
    )

    self.EasyButton = {[1]=self.EasyButton1, [2]=self.EasyButton2, [3]=self.EasyButton3}
    self.HeroEasyButton = {[1]=self.HeroEasyButton1, [2]=self.HeroEasyButton2, [3]=self.HeroEasyButton3}
    for i=1,3 do
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
    self:MyRefresh()
end

function CityMatchGamePanel:Start()
    -- self:MyRefresh()
end

function CityMatchGamePanel:MyInit()
    self.CityMatchActionUiManger = CityMatchActionUiManger.Create(self, self.playerOperateUI, self.dizhu_card_son)
    self.CityMatchPlayersActionManger = CityMatchPlayersActionManger.Create(self)
    self:MakeLister()
    CityMatchLogic.setViewMsgRegister(lister, listerRegisterName)

    EventTriggerListener.Get(self.change_cards_pos_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.ChangeCardsPosBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_bg_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.no_play_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.out_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.ChupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.hint_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.HintBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.JiabeiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_not_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.BujiabeiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_1_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.Jdz1BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_2_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.Jdz2BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_3_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.Jdz3BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_not_btn.gameObject).onClick =
        basefunc.handler(self.CityMatchPlayersActionManger, self.CityMatchPlayersActionManger.Bujdz1BtnCB)

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

function CityMatchGamePanel:MyRefresh()
    if CityMatchModel.data then
        local m_data = CityMatchModel.data
        dump(m_data, "<color=blue>m_data</color>")
        self.countdown = math.floor(m_data.countdown)
        if m_data.model_status == CityMatchModel.Model_Status.wait_table then
            self.ddz_match_pairdesk_ui.gameObject:SetActive(true)
            self:ShowOrHideDdzView(false)
            self.ddz_match_promoted_ui.gameObject:SetActive(false)
            self:ShowOrHideWarningView(false)
            self.cardsRemainUI[2].gameObject:SetActive(false)
            self.cardsRemainUI[3].gameObject:SetActive(false)

            SpineManager.RemoveAllDDZPlayerSpine()
        else
            self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
            if m_data.status == CityMatchModel.Status.wait_join then
                self:ShowOrHideWarningView(false)
                self.cardsRemainUI[2].gameObject:SetActive(false)
                self.cardsRemainUI[3].gameObject:SetActive(false)
            end
            self:ShowOrHideDdzView(true)

            -- transform_seat(self,m_data.seat_num)
            --刷新警报
            self:RefreshRemainPaiWarningStatus()
            --刷新我的牌展示UI 及 操作
            self.CityMatchPlayersActionManger:Refresh()
            --刷新托管
            self:RefreshAutoStatus()
            --刷新权限
            self:RefreshPermitStatus()
            --刷新操作展示UI
            self.CityMatchActionUiManger:Refresh()
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
            --晋级
            self:RefreshPromoted()
            --等待
            self:RefreshWait()
            --记牌器
            self:RefreshDdzJiPaiQi()
        end
    end
end

function CityMatchGamePanel:MyExit()
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

    self.updateTimer:Stop()
    self.CityMatchPlayersActionManger:MyExit()
    self.CityMatchActionUiManger:MyExit()
    SpineManager.RemoveAllDDZPlayerSpine()
    CityMatchLogic.clearViewMsgRegister(listerRegisterName)
    --closePanel(CityMatchGamePanel.name)
    self.dzCardObj = nil
    self.cardObj = nil
end

function CityMatchGamePanel:MyClose()
    self:MyExit()
    closePanel(CityMatchGamePanel.name)
end

function CityMatchGamePanel:MakeLister()
    print("<color=blue>MakeLister</color>")
    lister = {}
    --模式
    lister["model_citymg_enter_room_msg"] = basefunc.handler(self, self.citymg_enter_room_msg)
    lister["model_citymg_join_msg"] = basefunc.handler(self, self.citymg_join_msg)
    lister["model_citymg_wait_result_msg"] = basefunc.handler(self, self.citymg_wait_result_msg)
    lister["model_citymg_promoted_msg"] = basefunc.handler(self, self.citymg_promoted_msg)
    lister["model_citymg_score_change_msg"] = basefunc.handler(self, self.citymg_score_change_msg)
    lister["model_citymg_rank_msg"] = basefunc.handler(self, self.citymg_rank_msg)
    --玩法
    lister["model_nor_ddz_nor_begin_msg"] = basefunc.handler(self, self.nor_ddz_nor_begin_msg)
    lister["model_nor_ddz_nor_pai_msg"] = basefunc.handler(self, self.nor_ddz_nor_pai_msg)
    lister["model_nor_ddz_nor_action_msg"] = basefunc.handler(self, self.nor_ddz_nor_action_msg)
    lister["model_nor_ddz_nor_permit_msg"] = basefunc.handler(self, self.nor_ddz_nor_permit_msg)
    lister["model_nor_ddz_nor_dizhu_msg"] = basefunc.handler(self, self.nor_ddz_nor_dizhu_msg)
    lister["model_nor_ddz_nor_auto_msg"] = basefunc.handler(self, self.nor_ddz_nor_auto_msg)
    lister["model_nor_ddz_nor_settlement_msg"] = basefunc.handler(self, self.nor_ddz_nor_settlement_msg)
    lister["model_nor_ddz_nor_new_game_msg"] = basefunc.handler(self, self.nor_ddz_nor_new_game_msg)
    lister["model_nor_ddz_nor_start_again_msg"] = basefunc.handler(self, self.nor_ddz_nor_start_again_msg)
    lister["model_nor_ddz_nor_jiabeifinshani_msg"] = basefunc.handler(self, self.nor_ddz_nor_jiabeifinshani_msg)
end

--************************模式消息
function CityMatchGamePanel:citymg_enter_room_msg()
    print("<color=yellow>gamepanel: citymg_enter_room_msg</color>")
    self:MyRefresh()
end

function CityMatchGamePanel:citymg_join_msg(seat_num)
    self:RefreshPlayerInfo(CityMatchModel.data.s2cSeatNum[seat_num])
end

function CityMatchGamePanel:citymg_score_change_msg()
    self:RefreshScore(1)
end

function CityMatchGamePanel:citymg_rank_msg()
    self:RefreshRank()
end

function CityMatchGamePanel:citymg_wait_result_msg()
    self:RefreshWait()
end

function CityMatchGamePanel:citymg_promoted_msg()
    self:RefreshPromoted()
end

--************************玩法消息
function CityMatchGamePanel:nor_ddz_nor_begin_msg()
    print("<color=blue>nor_ddz_nor_begin_msg</color>")
    self:MyRefresh()
end

function CityMatchGamePanel:nor_ddz_nor_pai_msg()
    print("<color=blue>nor_ddz_nor_pai_msg</color>")
    self.CityMatchPlayersActionManger:Fapai(CityMatchModel.data.my_pai_list)
    self:RefreshRemainPaiWarningStatus()
end

function CityMatchGamePanel:nor_ddz_nor_action_msg()
    local act = CityMatchModel.data.action_list[#CityMatchModel.data.action_list]
    self.CityMatchPlayersActionManger:DealAction(CityMatchModel.data.s2cSeatNum[act.p], act)
    self:RefreshDdzJiPaiQi()
end

function CityMatchGamePanel:nor_ddz_nor_jiabeifinshani_msg()
    DDZAnimation.ChangeRate(self.cur_multiple_txt, CityMatchModel.data.my_rate)
end

function CityMatchGamePanel:nor_ddz_nor_permit_msg()
    self.countdown = math.floor(CityMatchModel.data.countdown)
    self:ShowOrHideActionUI(false, CityMatchModel.data.s2cSeatNum[CityMatchModel.data.cur_p])
    self:RefreshPermitStatus()
    self.CityMatchActionUiManger:changeActionUIShowByStatus()

    auto_chu_last_pai(self)
end

function CityMatchGamePanel:nor_ddz_nor_dizhu_msg()
    if CityMatchModel.data.dizhu == CityMatchModel.data.seat_num then
        self.CityMatchPlayersActionManger:AddPai(CityMatchModel.data.dz_pai)
    end
    self:RefreshDiZhuAndMultipleStatus()
    self:RefreshRate()
    self:RefreshPlayerInfo()
    self:RefreshDdzJiPaiQi()
    self:RefreshRemainPaiWarningStatus()

    --加倍动画
    if CityMatchModel.data then
        if CityMatchModel.data.my_rate and CityMatchModel.data.round_info.init_rate then
            DDZAnimation.ChangeRate(self.cur_multiple_txt, CityMatchModel.data.my_rate)
        end
    end
end

function CityMatchGamePanel:nor_ddz_nor_auto_msg(player)
    self:RefreshAutoStatus(CityMatchModel.data.s2cSeatNum[player])
end

function CityMatchGamePanel:nor_ddz_nor_settlement_msg()
    self:RefreshSettlement()

    local settlement_info = CityMatchModel.data.citymg_ddz_settlement_info
    if settlement_info then
        --得分 动画
        if settlement_info.p_scores then
            for p_seat, score in pairs(settlement_info.p_scores) do
                local cSeat = CityMatchModel.data.s2cSeatNum[p_seat]
                local playerUI = self.playerInfoUI[cSeat]
                DDZAnimation.ChangeScore(cSeat, score, playerUI.score_change_pos)
                if score >= 0 then
                    SpineManager.Win(cSeat)
                else
                    SpineManager.Lose(cSeat)
                end
            end
        end
        --春天
        if settlement_info.chuntian then
            local chun_tian = settlement_info.chuntian
            --春天 0-无 1-春天  2-反春
            if chun_tian == 1 or chun_tian == 2 then
                ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_spring.audio_name)
                DDZAnimation.Spring()
                --加倍动画
                if CityMatchModel.data then
                    if CityMatchModel.data.my_rate and CityMatchModel.data.round_info.init_rate then
                        DDZAnimation.ChangeRate(self.cur_multiple_txt, CityMatchModel.data.my_rate)
                    end
                end
            end
        end
    end
    self:RefreshScore()
end

function CityMatchGamePanel:nor_ddz_nor_new_game_msg()
    self:MyRefresh()
    --新的局数
    if CityMatchModel.data then
        local curRace = CityMatchModel.data.race
        if curRace then
            DDZAnimation.CurRace(curRace, self.start_again_cards_pos)
        end
    end
end

function CityMatchGamePanel:nor_ddz_nor_start_again_msg()
    self:MyRefresh()
    --重新发牌
    DDZAnimation.StartAgainCard(self.start_again_cards_pos)
end

--*************************Refresh
function CityMatchGamePanel:update_callback()
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

function CityMatchGamePanel:RefreshPromoted()
    if CityMatchModel.data then
        --玩家在配桌界面直接进入游戏需要隐藏
        self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
        self.ddz_match_promoted_ui.gameObject:SetActive(false)
        self:RefreshWait()
        local myData = CityMatchModel.data
        if myData.model_status == CityMatchModel.Model_Status.promoted then
            if myData.promoted_type then
                --0表示普通晋级 1表示晋级决赛
                local isMatch = myData.promoted_type == 1
                self.promoted_son.promoted_img.gameObject:SetActive(not isMatch)
                self.promoted_son.promoted_match.gameObject:SetActive(isMatch)

                if myData.rank and myData.total_players then
                    --排名
                    self.promoted_son.rank_txt.text = myData.rank .. "/"
                    self.promoted_son.rank_base_txt.text = myData.total_players
                elseif myData.total_players then
                    self.promoted_son.rank_txt.text = myData.total_players .. "/"
                    self.promoted_son.rank_base_txt.text = myData.total_players
                end
                self.ddz_match_promoted_ui.gameObject:SetActive(true)
            end
        end
    end
end

function CityMatchGamePanel:RefreshWait()
    if CityMatchModel.data then
        --玩家在配桌界面直接进入游戏需要隐藏
        self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
        self.ddz_match_wait_ui.gameObject:SetActive(false)
        local myData = CityMatchModel.data
        if myData.model_status == CityMatchModel.Model_Status.wait_result then
            if myData.rank and myData.total_players then
                --排名
                self.wait_son.rank_txt.text = myData.rank .. "/"
                self.wait_son.rank_base_txt.text = myData.total_players
            elseif myData.total_players then
                self.wait_son.rank_txt.text = myData.total_players .. "/"
                self.wait_son.rank_base_txt.text = myData.total_players
            end
            self.ddz_match_wait_ui.gameObject:SetActive(true)
        end
    end
end

function CityMatchGamePanel:RefreshRound()
    if CityMatchModel.data then
        local data = CityMatchModel.data
        local round_info = CityMatchModel.data.round_info
        local race = CityMatchModel.data.race
        self.dizhu_card_son.cur_match_txt.gameObject:SetActive(false)
        self.dizhu_card_son.cur_base_score_txt.gameObject:SetActive(false)
        self.dizhu_card_son.cur_multiple_txt.gameObject:SetActive(false)
        if round_info then
             --此轮晋级人数 此轮的局数
            if round_info.round_type == 0 then
                --初赛
                self.dizhu_card_son.cur_match_txt.text = "预赛 第" .. round_info.round .. "局（低于" .. round_info.rise_score .. "分将被淘汰）" .. round_info.rise_num .. "人晋级"
            elseif round_info.round_type == 1 then
                --决赛
                self.dizhu_card_son.cur_match_txt.text = "晋级赛 第" .. round_info.round .. "局 " .. round_info.rise_num .. "人晋级"
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
            if round_info.init_rate and CityMatchModel.data.my_rate then
                self.dizhu_card_son.cur_multiple_txt.text = CityMatchModel.data.my_rate .. "倍"
                self.dizhu_card_son.cur_multiple_txt.gameObject:SetActive(true)
            end
        end
    end
end

function CityMatchGamePanel:RefreshRate()
    self.cur_multiple_txt.gameObject:SetActive(false)
    if CityMatchModel.data then
        local my_rate = CityMatchModel.data.my_rate
        if my_rate then
            self.cur_multiple_txt.gameObject:SetActive(true)
            self.cur_multiple_txt.text = my_rate .. "倍"
        end
    end
end

function CityMatchGamePanel:RefreshRank()
    if CityMatchModel.data then
        local player = self.playerInfoUI[1]
        if CityMatchModel.data.rank and CityMatchModel.data.total_players then
            player.rank_txt.text = CityMatchModel.data.rank .. "/" .. CityMatchModel.data.total_players
            self.promoted_son.rank_txt.text = CityMatchModel.data.rank .. "/"
            self.promoted_son.rank_base_txt.text = CityMatchModel.data.total_players

            self.wait_son.rank_txt.text = CityMatchModel.data.rank .. "/"
            self.wait_son.rank_base_txt.text = CityMatchModel.data.total_players
        elseif CityMatchModel.data.total_players then
            player.rank_txt.text = CityMatchModel.data.total_players .. "/" .. CityMatchModel.data.total_players
            self.promoted_son.rank_txt.text = CityMatchModel.data.total_players .. "/"
            self.promoted_son.rank_base_txt.text = CityMatchModel.data.total_players

            self.wait_son.rank_txt.text = CityMatchModel.data.total_players .. "/"
            self.wait_son.rank_base_txt.text = CityMatchModel.data.total_players
        end
    end
end

function CityMatchGamePanel:RefreshScore(p_seat)
    if CityMatchModel.data then
        if p_seat then
            local player = self.playerInfoUI[p_seat]
            local score
            if
                CityMatchModel.data.players_info and CityMatchModel.data.seatNum and
                    CityMatchModel.data.players_info[CityMatchModel.data.seatNum[p_seat]]
             then
                score = CityMatchModel.data.players_info[CityMatchModel.data.seatNum[p_seat]].score
                if score then
                    player.score_txt.text = score
                end
            end
        else
            for p_seat = 1, 3 do
                local player = self.playerInfoUI[p_seat]
                local score
                score = CityMatchModel.data.players_info[CityMatchModel.data.seatNum[p_seat]].score
                if score then
                    player.score_txt.text = score
                end
            end
        end
    end
end

function CityMatchGamePanel:RefreshAutoStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if CityMatchModel.data then
        local auto = CityMatchModel.data.auto_status
        if auto and CityMatchModel.data.seatNum then
            --刷新全部
            if not pSeatNum then
                --刷新单个人
                for i = 1, 3 do
                    if auto[CityMatchModel.data.seatNum[i]] == 1 then
                        --显示
                        if i == 1 then
                            self.CityMatchPlayersActionManger:ChangeClickStatus(1)
                        end
                        self.autoUI[i]:SetActive(true)
                    else
                        --隐藏
                        if i == 1 then
                            self.CityMatchPlayersActionManger:ChangeClickStatus(0)
                        end
                        self.autoUI[i]:SetActive(false)
                    end
                end
            else
                if auto[CityMatchModel.data.seatNum[pSeatNum]] == 1 then
                    --显示
                    if pSeatNum == 1 then
                        self.CityMatchPlayersActionManger:ChangeClickStatus(1)
                    end
                    self.autoUI[pSeatNum]:SetActive(true)
                else
                    --隐藏
                    if pSeatNum == 1 then
                        self.CityMatchPlayersActionManger:ChangeClickStatus(0)
                    end
                    self.autoUI[pSeatNum]:SetActive(false)
                end
            end
        end
    end
end

function CityMatchGamePanel:RefreshRemainPaiWarningStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if CityMatchModel.data then
        local remain_pai_amount = CityMatchModel.data.remain_pai_amount
        if remain_pai_amount and CityMatchModel.data.seatNum then
            --刷新全部
            if not pSeatNum then
                --刷新单个人
                for i = 1, 3 do
                    --刷新warning
                    if self.warningUI[i] then
                        if remain_pai_amount[CityMatchModel.data.seatNum[i]] < 3 then
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
                        self.playerOperateUI[i].remain_count_txt.text =
                            remain_pai_amount[CityMatchModel.data.seatNum[i]]
                    end
                end
            else
                --刷新warning
                if self.warningUI[pSeatNum] then
                    if remain_pai_amount[CityMatchModel.data.seatNum[pSeatNum]] < 3 then
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
                        remain_pai_amount[CityMatchModel.data.seatNum[pSeatNum]]
                end
            end
        end
    end
end

function CityMatchGamePanel:RefreshRemainPaiWarningStatusWithAni(pSeatNum, act_type, pai_count)
    self:RefreshRemainPaiWarningStatus(pSeatNum)
    pai_count = pai_count or CityMatchModel.data.remain_pai_amount[CityMatchModel.data.seatNum[pSeatNum]]
    -- ###_test 根据牌的数量播放音效 动画等
    if (pai_count == 2 or pai_count == 1) and act_type ~= 0 then
        ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_card_leftwarning.audio_name)

        if pai_count == 2 then
            local sound = "sod_game_card_left2" .. AudioBySex(CityMatchModel, CityMatchModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        elseif pai_count == 1 then
            local sound = "sod_game_card_left1" .. AudioBySex(CityMatchModel, CityMatchModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        end
    end
end

-- 刷新简易交互UI
function CityMatchGamePanel:RefreshEasyChat()
    local dizhu = CityMatchModel.data.dizhu
    local b = true
    if dizhu and dizhu > 0 then
        b = false
    end
    for i = 1, 3 do
        self.EasyButton[i].gameObject:SetActive(b)
        self.HeroEasyButton[i].gameObject:SetActive(not b)
    end
end

function CityMatchGamePanel:RefreshPlayerInfo(pSeatNum)
    if CityMatchModel.data then
        self:RefreshEasyChat()
        local dizhu = CityMatchModel.data.dizhu
        local playerInfo = CityMatchModel.data.players_info
        local RefreshPlayerAllInfo = function(pSeatNum)
            local info = playerInfo[CityMatchModel.data.seatNum[pSeatNum]]
            local player = self.playerInfoUI[pSeatNum]
            if info then
                --刷新头像 根据渠道 1，微信 2，游客
                URLImageManager.UpdateHeadImage(info.head_link, player.cust_head_img)
                self:ShowOrHideCustHeadIcon(false, pSeatNum)
                self:RefreshScore(pSeatNum)
                self:ShowOrHideHeadInfo(true, pSeatNum)
                self:ShowOrHidePlayerInfo(true, pSeatNum)
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
            local info = playerInfo[CityMatchModel.data.seatNum[pSeatNum]]
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

        if dizhu ~= nil and dizhu > 0 then
            self:ShowOrHidePlayerInfo(true, pSeatNum)
            if playerInfo then
                --刷新全部
                if not pSeatNum then
                    --刷新单个人
                    for i = 1, 3 do
                        RefreshPlayerTextInfo(i)
                    end
                else
                    RefreshPlayerTextInfo(pSeatNum)
                end
            end

            for i = 1, 3 do
                --地主
                if CityMatchModel.data.seatNum[i] == dizhu then
                    if not SpineManager.GetSpine(i) then
                        local spine =
                            newObject("@spine_dz_nan", self.playerInfoUI[i].spine_node.transform):GetComponent(
                            "SkeletonAnimation"
                        )
                        SpineManager.AddDDZPlayerSpine(spine, i)
                        if i == 1 then
                            SetSortingOrder(i, -1)
                        end
                    end
                else
                    if not SpineManager.GetSpine(i) then
                        local spine =
                            newObject("@spine_nm_nan", self.playerInfoUI[i].spine_node.transform):GetComponent(
                            "SkeletonAnimation"
                        )
                        SpineManager.AddDDZPlayerSpine(spine, i)
                        if i == 1 then
                            SetSortingOrder(i, -1)
                        end
                    end
                end
            end
        else
            if playerInfo then
                --刷新全部
                if not pSeatNum then
                    --刷新单个人
                    for i = 1, 3 do
                        RefreshPlayerAllInfo(i)
                    end
                else
                    RefreshPlayerAllInfo(pSeatNum)
                end
            end
        end
    end
end

function CityMatchGamePanel:RefreshPermitStatus()
    --隐藏所有权限
    self:ShowOrHidePermitUI(false)
    if CityMatchModel.data then
        local data = CityMatchModel.data
        local status = CityMatchModel.data.status
        local cur_p = CityMatchModel.data.cur_p
        if
            (status == CityMatchModel.Status.jdz or status == CityMatchModel.Status.jiabei or
                status == CityMatchModel.Status.cp) and
                cur_p
         then
            if cur_p > 0 and cur_p < 4 then
                --teshu
                --我自己
                if cur_p == data.seat_num then
                    --其他人
                    local permitData = CityMatchModel.getMyPermitData()
                    if permitData then
                        self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                        if permitData.type == CityMatchModel.Status.jdz then
                            --将背景颜色还原
                            change_btn_image(self.playerself_operate_son.jdz_1_btn, "ddz_btn_3", true)
                            change_btn_image(self.playerself_operate_son.jdz_2_btn, "ddz_btn_3", true)
                            change_btn_image(self.playerself_operate_son.jdz_3_btn, "ddz_btn_3", true)
                            self.playerself_operate_son.jiaodizhu.gameObject:SetActive(true)
                            self:RefreshClockPos(self.playerself_operate_son.dizhu_time_pos)

                            --根据数据将背景颜色变灰
                            if permitData.jdz_min == 3 then
                                change_btn_image(self.playerself_operate_son.jdz_1_btn, "ddz_btn_2", false)
                                change_btn_image(self.playerself_operate_son.jdz_2_btn, "ddz_btn_2", false)
                            elseif permitData.jdz_min == 2 then
                                change_btn_image(self.playerself_operate_son.jdz_1_btn, "ddz_btn_2", false)
                            end
                        elseif permitData.jiabei == CityMatchModel.Status.jiabei then
                            self.playerself_operate_son.jiabei.gameObject:SetActive(true)
                            self:RefreshClockPos(self.playerself_operate_son.jiabei_time_pos)
                        else
                            --cp
                            if permitData.power == 0 then
                                --将不出显示
                                self.playerself_operate_son.no_play_btn.gameObject:SetActive(true)
                                self.playerself_operate_son.chupai.gameObject:SetActive(true)
                                if permitData.is_must then
                                    --将不出隐藏
                                    self.playerself_operate_son.no_play_btn.gameObject:SetActive(false)
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
                                self.CityMatchPlayersActionManger:ChangeClickStatus(1)
                                self:RefreshClockPos(self.playerself_operate_son.yaobuqi_time_pos)
                            end
                        end
                    end
                elseif CityMatchModel.data.s2cSeatNum then
                    if CityMatchModel.data.s2cSeatNum[cur_p] == 2 then
                        self:ShowOrHidePermitUI(true, 2)
                    elseif CityMatchModel.data.s2cSeatNum[cur_p] == 3 then
                        self:ShowOrHidePermitUI(true, 3)
                    end
                end
            else
            end
            --给闹钟赋予初始值
            for i = 1, 3 do
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

function CityMatchGamePanel:RefreshClockPos(parent)
    self.playerself_operate_son.wait_time.transform.parent = parent.transform
    self.playerself_operate_son.wait_time.transform.localPosition = Vector3.zero
end

function CityMatchGamePanel:RefreshSettlement()
    if CityMatchModel.data then
        local mData = CityMatchModel.data
        local settlement_info = CityMatchModel.data.citymg_ddz_settlement_info
        if settlement_info then
            --玩家剩余的牌
            if settlement_info.remain_pai then
                for k, v in pairs(settlement_info.remain_pai) do
                    --其他玩家的牌
                    local p_seat = v.p
                    local pai_list = v.pai
                    local cSeatNum = CityMatchModel.data.s2cSeatNum[p_seat]
                    if cSeatNum ~= 1 then
                        local show_list = nor_ddz_base_lib.norId_convert_to_lzId(pai_list, CityMatchModel.data.laizi)
                        if show_list then
                            table.sort(show_list)
                        end
                        self.CityMatchActionUiManger:RefreshAction(cSeatNum, {type = -1, show_list = show_list})
                    end
                end
            end
        end
    end
end

function CityMatchGamePanel:RefreshDiZhuAndMultipleStatus()
    if CityMatchModel.data then
        local myData = CityMatchModel.data
        if not myData.dz_pai then
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(true)
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

function CityMatchGamePanel:RefreshClock()
    local flag = nil
    for i = 1, 3 do
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

function CityMatchGamePanel:RefreshDdzJiPaiQi()
    self:AutoShowDdzJiPaiQiCB()
    if CityMatchModel.data then
        local statistics = self.playerself_operate_son.statistics
        if CityMatchModel.data then
            local jipaiqi = CityMatchModel.data.jipaiqi
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
                    local key = 17 - i
                    local count = jipaiqi[key]

                    childText.text = count
                    if key == 17 or key == 16 then
                        if count == 1 then
                            childText.color = self.colorYellow
                        else
                            childText.color = self.colorGary
                        end
                    else
                        if count == 4 then
                            childText.color = self.colorYellow
                        elseif count == 0 then
                            childText.color = self.colorGary
                        else
                            childText.color = Color.white
                        end
                    end
                end
            end
        end
        self.playerself_operate_son.record_btn.gameObject:SetActive(GameGlobalOnOff.JPQTool)
    end
end

--*****************Callback
function CityMatchGamePanel:OnEasyClick(obj)
    local uipos = tonumber(string.sub(obj.name,-1,-1))
    local data = CityMatchModel.GetPosToPlayer(uipos)
    if data then
        SysInteractivePlayerManager.Create(data, uipos)
    else
        dump(data, "<color=red>玩家没有入座</color>")
    end
end

function CityMatchGamePanel:DdzJiPaiQiCB()
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

function CityMatchGamePanel:DdzPayJiPaiQiCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    PayPanel.Create(GOODS_TYPE.item, "normal",nil,ITEM_TYPE.expression)
    self.playerself_operate_son.pay_record.gameObject:SetActive(false)
end

function CityMatchGamePanel:MenuCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local menu_bg = self.menu_son.menu_bg
    local b = not menu_bg.gameObject.activeSelf
    menu_bg.gameObject:SetActive(b)
    self.TopButtonImage.gameObject:SetActive(b)
end

function CityMatchGamePanel:CloseCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    HintPanel.Create(1, "比赛中不能退出")
end

function CityMatchGamePanel:HelpCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    DdzHelpPanel.Create("JD")
end

function CityMatchGamePanel:SetCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
end

function CityMatchGamePanel:CanelAutoBtnCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if Network.SendRequest("nor_ddz_nor_auto", {operate = 0}) then
        self.autoUI[1]:SetActive(false)
    else
        DDZAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end
end

--*****************ShowOrHide
function CityMatchGamePanel:ShowOrHideWarningView(status)
    for i = 1, 3 do
        --刷新warning
        if self.warningUI[i] then
            --隐藏
            self.warningUI[i]:SetActive(false)
        end
    end
end

function CityMatchGamePanel:ShowOrHideDdzView(status)
    self.ddz_match_dizhu_card_ui.gameObject:SetActive(status)
    self.menu_btn.gameObject:SetActive(status)
    self.ddz_match_playerright_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerright_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_operate_ui.gameObject:SetActive(status)
end

function CityMatchGamePanel:ShowOrHidePermitUI(status, people)
    if people == 2 then
        self.playerright_operate_son.wait_time.gameObject:SetActive(status)
    elseif people == 3 then
        self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
    else
        self.playerself_operate_son.wait_time.gameObject:SetActive(status)
        if self.playerself_operate_son.yaobuqi.gameObject.activeSelf then
            if status == true then
                self.CityMatchPlayersActionManger:ChangeClickStatus(1)
            else
                if not self.autoUI[1].activeSelf then
                    self.CityMatchPlayersActionManger:ChangeClickStatus(0)
                end
            end
        end
        self.playerself_operate_son.yaobuqi.gameObject:SetActive(status)
        if not status then
            SpineManager.DaiJi(1)
        end
        self.playerself_operate_son.chupai.gameObject:SetActive(status)
        self.playerself_operate_son.jiaodizhu.gameObject:SetActive(status)
        self.playerself_operate_son.jiabei.gameObject:SetActive(status)
        if not people then
            self.playerright_operate_son.wait_time.gameObject:SetActive(status)
            self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
        end
    end
end

function CityMatchGamePanel:ShowOrHideActionUI(status, people)
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

function CityMatchGamePanel:ShowOrHideCustHeadIcon(status, seatNum)
    if not seatNum then
        for i = 1, 3 do
            self.playerInfoUI[i].cust_head_icon_img.gameObject:SetActive(status)
        end
    else
        self.playerInfoUI[seatNum].cust_head_icon_img.gameObject:SetActive(status)
    end
end

function CityMatchGamePanel:ShowOrHideHeadInfo(status, seatNum)
    if CityMatchModel.data then
        if not seatNum then
            for i = 1, 3 do
                self.playerInfoUI[i].cust_head_icon_img.gameObject:SetActive(status)
                self.playerInfoUI[i].cust_head_bg_img.gameObject:SetActive(status)
            end
        else
            self.playerInfoUI[seatNum].cust_head_icon_img.gameObject:SetActive(status)
            self.playerInfoUI[seatNum].cust_head_bg_img.gameObject:SetActive(status)
        end
    end
end

function CityMatchGamePanel:ShowOrHidePlayerInfo(status, seatNum)
    if CityMatchModel.data then
        if not seatNum then
            for i = 1, 3 do
                self.playerInfoUI[i].info.gameObject:SetActive(status)
            end
        else
            self.playerInfoUI[seatNum].info.gameObject:SetActive(status)
        end
    end
end

function CityMatchGamePanel:SetHideMenu()
    local menu_bg = self.menu_son.menu_bg
    menu_bg.gameObject:SetActive(false)
    self.TopButtonImage.gameObject:SetActive(false)
end

function CityMatchGamePanel:AutoShowDdzJiPaiQiCB()
    if GameGlobalOnOff.JPQTool and GameItemModel.GetItemCount("jipaiqi") > 0 then
        local is_show = true
        if self.isShowStatistics ~= nil then is_show = self.isShowStatistics end
        self.playerself_operate_son.statistics.gameObject:SetActive(is_show)
    end
end