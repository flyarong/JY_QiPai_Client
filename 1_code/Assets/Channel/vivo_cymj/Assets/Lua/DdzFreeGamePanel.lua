local basefunc = require "Game.Common.basefunc"
local nor_ddz_base_lib = require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"
--数据结构
--说明：位置坐标系  我的位置永远为1 逆时针 2 3，

DdzFreeGamePanel = basefunc.class()

DdzFreeGamePanel.name = "DdzFreeGamePanel"
local lister
local listerRegisterName = "ddzFreeGameListerRegister"

local function change_btn_image(btn, image, enabled, text)
    local btn_img = btn.gameObject:GetComponent("Image")
    local hi = btn.transform:Find("hi")
    local no = btn.transform:Find("no")
    hi.gameObject:SetActive(enabled)
    no.gameObject:SetActive(not enabled)
    btn_img.sprite = GetTexture(image)
    btn_img:SetNativeSize()
    btn.gameObject:GetComponent("Image").raycastTarget = enabled
    if text then
        self.close_txt.text = text
    end
end

--自动出最后一手牌
local function auto_chu_last_pai(self)
    local m_data = DdzFreeModel.data
    if m_data.status == DdzFreeModel.Status.cp then
        local pos = m_data.s2cSeatNum[m_data.cur_p]
        if pos == 1 then
            local _act = DdzFreeModel.ddz_algorithm:check_is_only_last_pai(m_data.action_list, m_data.my_pai_list, m_data.laizi)
            
            if _act then
                self.last_pai_auto_countdown = 1
                self.last_pai_auto_cb = function()
                    self.last_pai_auto_cb = nil
                    self.last_pai_auto_countdown = nil
                    local manager = self.DdzFreePlayersActionManger
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

local function BackBtnCountdown(self)
    if self.countdown and self.countdown > 0 then
        self.back_time_txt.text = self.countdown .. "秒后可返回"
    else
        self:RefreshBackBtn()
    end
end
local function ChangedeskCountdown(self)
    if self.countdown and self.countdown > 0 then
        self.changedesk_hint_txt.text = "换  桌(" .. self.countdown .. "s)"
    else
        self:RefreshChangedesk()
    end
end

local instance
--******************框架
function DdzFreeGamePanel.Create()
    DSM.PushAct({panel = "DdzFreeGamePanel"})
    instance = DdzFreeGamePanel.New()
    instance.dzCardObj = GetPrefab("DdzDzCard")
    instance.cardObj = GetPrefab("DdzCard")
    instance.lzSelectCardObj = GetPrefab("DdzLaiziSelectCard")
    return createPanel(instance, DdzFreeGamePanel.name)
end

function DdzFreeGamePanel.Bind()
    local _in = instance
    instance = nil
    return _in
end

function DdzFreeGamePanel:Awake()
    print("---------------------------awake")
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
    self.menu_son = {}
    LuaHelper.GeneratingVar(self.menu_btn.transform, self.menu_son)
    --赖子选择框
    self.select_laizi_son = {}
    LuaHelper.GeneratingVar(self.ddz_select_laizi_ui.transform, self.select_laizi_son)

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
    self.timerUI[4] = self.select_laizi_son.wait_time

    self.timerTextUI = {}
    self.timerTextUI[1] = self.playerself_operate_son.wait_time_txt
    self.timerTextUI[2] = self.playerright_operate_son.wait_time_txt
    self.timerTextUI[3] = self.playerleft_operate_son.wait_time_txt
    self.timerTextUI[4] = self.select_laizi_son.wait_time_txt

    self.ChatButton_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if DdzFreeModel.data.model_status == DdzFreeModel.Model_Status.gaming then
                SysInteractiveChatManager.Show()
            else

            end
        end
    )
    self.ChatButton_btn.gameObject:SetActive(false)

    EventTriggerListener.Get(self.changedesk_btn.gameObject).onClick = basefunc.handler(self, self.OnChangedeskClick)

    self.EasyButton = {[1] = self.EasyButton1, [2] = self.EasyButton2, [3] = self.EasyButton3}
    self.HeroEasyButton = {[1] = self.HeroEasyButton1, [2] = self.HeroEasyButton2, [3] = self.HeroEasyButton3}
    for i = 1, DdzFreeModel.maxPlayerNumber do
        local btn = self.EasyButton[i]
        EventTriggerListener.Get(btn.gameObject).onClick = basefunc.handler(self, self.OnEasyClick)

        local herobtn = self.HeroEasyButton[i]
        EventTriggerListener.Get(herobtn.gameObject).onClick = basefunc.handler(self, self.OnEasyClick)
    end

    self.countdown = 0
    --初始化闹钟 time < 0 隐藏 timer ，time > 0 显示
    self.timer = nil
    self.timerTween = {}

    self.TopButtonImage = self.transform:Find("TopButtonImage"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButtonImage.gameObject).onClick = basefunc.handler(self, self.SetHideMenu)
    self.TopButtonImage.gameObject:SetActive(false)

    self.updateTimer = Timer.New(basefunc.handler(self, self.update_callback), 1, -1, true)
    self.updateTimer:Start()
    self:MyInit()
    self.TimeCallDict = {}
    self.selectLaiziBtnTable = {}
    self:MyRefresh()

    local btn_map = {}
    btn_map["right_top"] = {self.rt_btn_1, self.rt_btn_2, self.rt_btn_3, self.rt_btn_4}
    btn_map["right"] = {self.right_btn_1}
    btn_map["left_top"] = {self.left_top_node}
    btn_map["left"] = {self.left_node}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "ddz_free_game")
    self.dh_node.gameObject:SetActive(false)
end

function DdzFreeGamePanel:Start()
end

function DdzFreeGamePanel:MyInit()
    self.DdzFreeActionUiManger = DdzFreeActionUiManger.Create(self, self.playerOperateUI, self.dizhu_card_son)
    self.DdzFreePlayersActionManger = DdzFreePlayersActionManger.Create(self)
    self:MakeLister()
    DdzFreeLogic.setViewMsgRegister(lister, listerRegisterName)
    self.behaviour:AddClick(self.back_btn.gameObject, DdzFreeGamePanel.OnClickCloseSignup, self)
    self.behaviour:AddClick(
        self.select_laizi_son.select_laizi_btn_bg.gameObject,
        DdzFreeGamePanel.OnClickCloseSelectLaizi,
        self
    )

    EventTriggerListener.Get(self.change_cards_pos_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.ChangeCardsPosBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_bg_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.no_play_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.out_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.ChupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.hint_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.HintBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.JiabeiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_not_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.BujiabeiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_1_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.Jdz1BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_2_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.Jdz2BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_3_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.Jdz3BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_not_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.Bujdz1BtnCB)

    --二人叫地主
    EventTriggerListener.Get(self.playerself_operate_son.jdz_er_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.Jdz1BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_not_er_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.Bujdz1BtnCB)
    --二人场抢地主
    EventTriggerListener.Get(self.playerself_operate_son.qdz_1_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.Qdz1BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.qdz_not_btn.gameObject).onClick =
        basefunc.handler(self.DdzFreePlayersActionManger, self.DdzFreePlayersActionManger.Buqdz1BtnCB)

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

    --闷拉倒
    EventTriggerListener.Get(self.playerself_operate_son.kan_pai_btn.gameObject).onClick=basefunc.handler(self.DdzFreePlayersActionManger,self.DdzFreePlayersActionManger.KanPaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.men_zhua_btn.gameObject).onClick=basefunc.handler(self.DdzFreePlayersActionManger,self.DdzFreePlayersActionManger.MenZhuaBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.zhua_btn.gameObject).onClick=basefunc.handler(self.DdzFreePlayersActionManger,self.DdzFreePlayersActionManger.ZhuaPaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.bu_zhua_btn.gameObject).onClick=basefunc.handler(self.DdzFreePlayersActionManger,self.DdzFreePlayersActionManger.BuZhuaPaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.dao_btn.gameObject).onClick=basefunc.handler(self.DdzFreePlayersActionManger,self.DdzFreePlayersActionManger.DaoBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.bu_dao_btn.gameObject).onClick=basefunc.handler(self.DdzFreePlayersActionManger,self.DdzFreePlayersActionManger.BuDaoBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.la_btn.gameObject).onClick=basefunc.handler(self.DdzFreePlayersActionManger,self.DdzFreePlayersActionManger.LaBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.bu_la_btn.gameObject).onClick=basefunc.handler(self.DdzFreePlayersActionManger,self.DdzFreePlayersActionManger.BuLaBtnCB)  

    PointerEventListener.Get(self.dh_tips_btn.gameObject).onDown = basefunc.handler(self, self.OnDHDown)
    PointerEventListener.Get(self.dh_tips_btn.gameObject).onUp = basefunc.handler(self, self.OnDHUp)

    --奖励等级
    -- EventTriggerListener.Get(self.playerself_operate_son.drivingrange_btn.gameObject).onClick =
    --     basefunc.handler(self, self.DrivingRangeCB)
    --任务
    GameTaskBtnPrefab.Create()
end
function DdzFreeGamePanel:OnDHDown()
    local pos = UnityEngine.Input.mousePosition
    GameTipsPrefab.ShowDesc("福卡可在游戏主界面右下角兑换处进行购物", pos, GameTipsPrefab.TipsShowStyle.TSS_3)
end

function DdzFreeGamePanel:OnDHUp()
    GameTipsPrefab.Hide()
end

function DdzFreeGamePanel:MyRefresh()
    if DdzFreeModel.data then
        local m_data = DdzFreeModel.data
        if m_data.countdown then
            self.countdown = math.floor(m_data.countdown)
        end

        local gameCfg = GameFreeModel.GetGameIDToConfig(DdzFreeModel.baseData.game_id)
        if gameCfg then
            local gameTypeCfg = GameFreeModel.GetGameTypeToConfig(gameCfg.game_type)
            if IsEquals(self.gameName_txt) then
                self.gameName_txt.text = gameTypeCfg.name .. "  " .. gameCfg.game_name
            end
        end
    
        if not m_data.model_status then
            print("<color=red>状态为空，等待AllInfo消息</color>")
        else
            self:RefreshRed()
            self:ShowOrHideWarningView(false)

            self:ShowOrHideDdzView(true)
            -- 刷新房间状态
            self:RefreshRoom()
            -- 废牌
            self:RefreshDeadwood()
            -- 换桌
            self:RefreshChangedesk()
            --刷新警报
            self:RefreshRemainPaiWarningStatus()
            --刷新我的牌展示UI 及 操作
            self.DdzFreePlayersActionManger:Refresh()
            --刷新操作展示UI
            self.DdzFreeActionUiManger:Refresh()
            --刷新托管
            self:RefreshAutoStatus()
            --刷新权限
            self:RefreshPermitStatus()
            --刷新地主牌
            self:RefreshDiZhuAndMultipleStatus()
            --刷新赖子
            self:RefreshLaiziStatus(false)
            --刷新玩家信息
            self:RefreshPlayerInfo()
            --刷新结算
            self:RefreshSettlement()
            --刷新倍数
            self:RefreshRate()
            --记牌器
            self:RefreshDdzJiPaiQi()
            -- 结算界面
            self:RefreshClearing()
            -- 抢地主次数
            self:RefreshQDZUI()
            -- 让牌提示
            self:RefreshRangHint()
        end
        self:IsShow_JpqNotice()
    end
end

-- 刷新房间状态
function DdzFreeGamePanel:RefreshRoom()
    local m_data = DdzFreeModel.data
    if m_data and m_data.model_status then
        if m_data.model_status == DdzFreeModel.Model_Status.wait_table then
            self.ddz_match_pairdesk_ui.gameObject:SetActive(true)
            self:RefreshBackBtn()
        else
            self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
        end
        if m_data.model_status == DdzFreeModel.Model_Status.gaming then
            self.record_btn.gameObject:SetActive(true)
            self.ChatButton_btn.gameObject:SetActive(true)
        else
            self.ChatButton_btn.gameObject:SetActive(false)
            self.record_btn.gameObject:SetActive(false)
        end
    end
end

function DdzFreeGamePanel:MyExit()
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()
    if self.game_btn_pre then
        self.game_btn_pre:MyExit()
        self.game_btn_pre = nil
    end
    if self.updateTimer then
        self.updateTimer:Stop()
        self.updateTimer = nil
    end
    self.DdzFreePlayersActionManger:MyExit()
    self.DdzFreeActionUiManger:MyExit()
    SpineManager.RemoveAllDDZPlayerSpine()
    DdzFreeLogic.clearViewMsgRegister(listerRegisterName)

    DdzFreeClearing.Close()

    --closePanel(DdzFreeGamePanel.name)
    self.dzCardObj = nil
    self.cardObj = nil
    self.lzSelectCardObj = nil
    --任务取消
    Event.Brocast("close_task")
end

function DdzFreeGamePanel:MyClose()
    DSM.PopAct()
    self:MyExit()
    closePanel(DdzFreeGamePanel.name)
end

function DdzFreeGamePanel:MakeLister()
    lister = {}
    --模式
    lister["model_fg_enter_room_msg"] = basefunc.handler(self, self.fg_enter_room_msg)
    lister["model_fg_join_msg"] = basefunc.handler(self, self.fg_join_msg)
    lister["model_fg_leave_msg"] = basefunc.handler(self, self.fg_leave_msg)
    lister["model_fg_score_change_msg"] = basefunc.handler(self, self.fg_score_change_msg)
    lister["model_fg_ready_msg"] = basefunc.handler(self, self.model_fg_ready_msg)

    lister["model_fg_huanzhuo_response"] = basefunc.handler(self, self.model_fg_huanzhuo_response)
    lister["model_fg_ready_response"] = basefunc.handler(self, self.model_fg_ready_response)

    --玩法
    lister["model_nor_ddz_nor_pai_msg"] = basefunc.handler(self, self.nor_ddz_nor_pai_msg)
    lister["model_nor_ddz_nor_action_msg"] = basefunc.handler(self, self.nor_ddz_nor_action_msg)
    lister["model_nor_ddz_nor_permit_msg"] = basefunc.handler(self, self.nor_ddz_nor_permit_msg)
    lister["model_nor_ddz_nor_dizhu_msg"] = basefunc.handler(self, self.nor_ddz_nor_dizhu_msg)
    lister["model_nor_ddz_nor_laizi_msg"] = basefunc.handler(self, self.nor_ddz_nor_laizi_msg)
    lister["model_nor_ddz_nor_auto_msg"] = basefunc.handler(self, self.nor_ddz_nor_auto_msg)
    lister["model_nor_ddz_nor_new_game_msg"] = basefunc.handler(self, self.nor_ddz_nor_new_game_msg)
    lister["model_nor_ddz_nor_start_again_msg"] = basefunc.handler(self, self.nor_ddz_nor_start_again_msg)
    lister["model_nor_ddz_nor_settlement_msg"] = basefunc.handler(self, self.nor_ddz_nor_settlement_msg)
    lister["model_nor_ddz_mld_kan_my_pai_msg"] = basefunc.handler(self, self.nor_ddz_mld_kan_my_pai_msg)
    lister["model_nor_ddz_mld_dizhu_pai_msg"] = basefunc.handler(self, self.nor_ddz_mld_dizhu_pai_msg)

    --资产改变
    lister["model_AssetChange"] = basefunc.handler(self, self.AssetChange)
end

--************************模式消息
function DdzFreeGamePanel:fg_enter_room_msg()
    self:MyRefresh()
    dump("<color>++++++++++++++++++++++++++++++++33</color>")
    Event.Brocast("Sys_Guide_3_tips_msg",{panelSelf = self}) 
end

-- 玩家进入
function DdzFreeGamePanel:fg_join_msg(seat_num)
    dump("<color>++++++++++++++++++++++++++++++++44</color>")
    self:RefreshPlayerInfo(DdzFreeModel.data.s2cSeatNum[seat_num])
end

-- 玩家离开
function DdzFreeGamePanel:fg_leave_msg(seat_num)
    self:RefreshPlayerInfo(DdzFreeModel.data.s2cSeatNum[seat_num])
end

function DdzFreeGamePanel:fg_score_change_msg()
    self:RefreshScore(1)
end

function DdzFreeGamePanel:model_fg_huanzhuo_response()
    self:MyRefresh()
end

function DdzFreeGamePanel:model_fg_ready_response()
    self:MyRefresh()
end

function DdzFreeGamePanel:model_fg_ready_msg(seat_num)
    self:RefreshPlayerInfo(DdzFreeModel.data.s2cSeatNum[seat_num])
end

--************************玩法消息
function DdzFreeGamePanel:nor_ddz_nor_pai_msg()
    self.DdzFreePlayersActionManger:Fapai(DdzFreeModel.data.my_pai_list)
    self:RefreshRemainPaiWarningStatus()
    self:RefreshDeadwood()
end

function DdzFreeGamePanel:nor_ddz_mld_kan_my_pai_msg()
    local my_pai_list = DdzFreeModel.data.my_pai_list
    if my_pai_list then
        self.DdzFreePlayersActionManger:UiManagerClearAndRefresh()
    end
    self:RefreshRemainPaiWarningStatus()
end

function DdzFreeGamePanel:nor_ddz_mld_dizhu_pai_msg()
    local data = DdzFreeModel.data
    if data.dizhu == data.seat_num then
        self.DdzFreePlayersActionManger:AddPai(data.dz_pai)
    end
    self:RefreshDiZhuAndMultipleStatus()
    self:RefreshRate()
    self:RefreshPlayerInfo()
    self:RefreshDdzJiPaiQi()
    self:RefreshRangHint()
    self:RefreshRemainPaiWarningStatus()
    if data.my_rate then
        DDZAnimation.ChangeRate(self.cur_multiple_txt, data.my_rate)
    end
end

function DdzFreeGamePanel:nor_ddz_nor_action_msg()
    local act = DdzFreeModel.data.action_list[#DdzFreeModel.data.action_list]
    self.DdzFreePlayersActionManger:DealAction(DdzFreeModel.data.s2cSeatNum[act.p], act)
    self:RefreshDdzJiPaiQi()
    self:RefreshRangHint()
end

function DdzFreeGamePanel:nor_ddz_nor_permit_msg()
    self.countdown = math.floor(DdzFreeModel.data.countdown)
    self:ShowOrHideActionUI(false, DdzFreeModel.data.s2cSeatNum[DdzFreeModel.data.cur_p])
    self:RefreshPermitStatus()
    self:RefreshDeadwood()
    self:RefreshQDZUI()
    --隐藏赖子
    self:ResetSelectLaiziType(self.selectLaiziBtnTable)
    self.DdzFreeActionUiManger:changeActionUIShowByStatus()
    auto_chu_last_pai(self)
end

function DdzFreeGamePanel:nor_ddz_nor_dizhu_msg()
    if DdzFreeModel.data then
        if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.nor then
            if DdzFreeModel.data.dizhu == DdzFreeModel.data.seat_num then
                self.DdzFreePlayersActionManger:AddPai(DdzFreeModel.data.dz_pai)
            end
            self:RefreshDiZhuAndMultipleStatus()
            self:RefreshRate()
            self:RefreshPlayerInfo()
            self:RefreshDdzJiPaiQi()
            self:RefreshRangHint()
            self:RefreshRemainPaiWarningStatus()
            if DdzFreeModel.data.my_rate then
                DDZAnimation.ChangeRate(self.cur_multiple_txt, DdzFreeModel.data.my_rate)
            end
        elseif DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
            self:RefreshRate()
            self:RefreshPlayerInfo()
            self:RefreshDdzJiPaiQi()
        end
    end
end

--赖子消息
function DdzFreeGamePanel:nor_ddz_nor_laizi_msg()
    self:RefreshLaiziStatus(true)
end

function DdzFreeGamePanel:nor_ddz_nor_auto_msg(player)
    self:RefreshAutoStatus(DdzFreeModel.data.s2cSeatNum[player])
    self:OnClickCloseSelectLaizi()
end

function DdzFreeGamePanel:nor_ddz_nor_new_game_msg()
    self:MyRefresh()

    self:ShowOrHideWarningView(false)
    self.cardsRemainUI[2].gameObject:SetActive(false)
    self.cardsRemainUI[3].gameObject:SetActive(false)
    --新的局数
    if DdzFreeModel.data then
        local curRace = DdzFreeModel.data.race
        if curRace then
            DDZAnimation.CurRace(curRace, self.start_again_cards_pos)
        end
    end
end

function DdzFreeGamePanel:nor_ddz_nor_start_again_msg()
    self:MyRefresh()
    DDZAnimation.StartAgainCard(self.start_again_cards_pos)
end

function DdzFreeGamePanel:nor_ddz_nor_settlement_msg()
    self:RefreshSettlement()
    self:RefreshDeadwood()

    local settlement_info = DdzFreeModel.data.settlement_info
    if settlement_info then
        --得分 动画
        if settlement_info.award then
            for p_seat, score in pairs(settlement_info.award) do
                local cSeat = DdzFreeModel.data.s2cSeatNum[p_seat]
                self:RefreshPlayerInfo(cSeat)
            end
            for p_seat, score in pairs(settlement_info.award) do
                local cSeat = DdzFreeModel.data.s2cSeatNum[p_seat]
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
                if DdzFreeModel.data then
                    if DdzFreeModel.data.my_rate then
                        DDZAnimation.ChangeRate(self.cur_multiple_txt, DdzFreeModel.data.my_rate)
                    end
                end
            end
        end
        if settlement_info.chuntian or settlement_info.award then
            self:RefreshClearing(true)
        else
            self:RefreshClearing()
        end
    end
    self:RefreshScore()

    Event.Brocast("game_ready_finish_by_exit")
end

function DdzFreeGamePanel:AssetChange()
    self:RefreshScore(1)
    self:RefreshRed()
end
--************************Refresh
function DdzFreeGamePanel:update_callback()
    local dt = 1
    if self.countdown and self.countdown > 0 then
        self.countdown = self.countdown - dt
    end
    self:RefreshClock()
    for k, call in pairs(self.TimeCallDict) do
        call(self)
    end
    --最后一手牌自动出牌
    if self.last_pai_auto_countdown then
        self.last_pai_auto_countdown = self.last_pai_auto_countdown - dt
        if self.last_pai_auto_countdown == 0 and self.last_pai_auto_cb then
            self.last_pai_auto_cb()
        end
    end
end

function DdzFreeGamePanel:RefreshClock()
    local flag = nil
    for i = 1, DdzFreeModel.maxPlayerNumber do
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

function DdzFreeGamePanel:RefreshBackBtn()
    local m_data = DdzFreeModel.data
    self.offback.gameObject:SetActive(true)
    if m_data and m_data.model_status == DdzFreeModel.Model_Status.wait_table then
        if self.countdown and self.countdown > 0 then
            self.offback.gameObject:SetActive(true)
            self.TimeCallDict["BackBtnCountdown"] = BackBtnCountdown
            BackBtnCountdown(self)
        else
            self.offback.gameObject:SetActive(false)
            self.TimeCallDict["BackBtnCountdown"] = nil
        end
    end
end

function DdzFreeGamePanel:RefreshDdzJiPaiQi()
    --自动显示记牌器
    self:AutoShowDdzJiPaiQiCB()
    local m_data = DdzFreeModel.data
    local statistics = self.playerself_operate_son.statistics
    if m_data then
        if m_data.model_status == DdzFreeModel.Model_Status.wait_table or m_data.model_status == DdzFreeModel.Model_Status.wait_begin then
            self.playerself_operate_son.record_btn.gameObject:SetActive(false)
            self.playerself_operate_son.pay_record.gameObject:SetActive(false)
            statistics.gameObject:SetActive(false)
        else
            -- statistics.gameObject:SetActive(true)
            local jipaiqi = DdzFreeModel.data.jipaiqi
            if not jipaiqi then
                for i = 0, statistics.transform.childCount - 1 do
                    local child = statistics:GetChild(i)
                    local childText = child:GetComponent("Text")
                    childText.text = "-"
                    childText.color = Color.New(194 / 255, 171 / 255, 160 / 255, 255 / 255)
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
                            childText.color = Color.New(255 / 255, 211 / 255, 0 / 255, 255 / 255)
                        else
                            childText.color = Color.New(194 / 255, 171 / 255, 160 / 255, 255 / 255)
                        end
                    else
                        if count == 4 then
                            childText.color = Color.New(255 / 255, 211 / 255, 0 / 255, 255 / 255)
                        elseif count == 0 then
                            childText.color = Color.New(194 / 255, 171 / 255, 160 / 255, 255 / 255)
                        else
                            childText.color = Color.white
                        end
                    end
                end
            end
            local is_show = DdzFreeModel.data.model_status == DdzFreeModel.Model_Status.gaming
            self.playerself_operate_son.record_btn.gameObject:SetActive(GameGlobalOnOff.JPQTool and is_show)
        end
    else
        self.playerself_operate_son.record_btn.gameObject:SetActive(false)
        statistics.gameObject:SetActive(false)
    end
    self:IsShow_JpqNotice()
end

--累胜
function DdzFreeGamePanel:DrivingRangeCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    DdzExerPanel.Create(nil, DdzFreeModel.data.DrivingRange, DdzFreeModel.UIConfig)
end

-- 刷新游戏结算界面
function DdzFreeGamePanel:RefreshClearing(isdelay)
    if DdzFreeModel.data.model_status == DdzFreeModel.Model_Status.wait_begin then
        return
    end
    if DdzFreeModel.data.status == DdzFreeModel.Status.settlement or DdzFreeModel.data.status == DdzFreeModel.Status.gameover then
        DdzFreeClearing.Create(isdelay)
    else
        DdzFreeClearing.Close()
    end
end

function DdzFreeGamePanel:RefreshRate()
    self.cur_multiple_txt.gameObject:SetActive(false)
    if DdzFreeModel.data then
        local my_rate = DdzFreeModel.data.my_rate
        if my_rate then
            self.cur_multiple_txt.gameObject:SetActive(true)
            self.cur_multiple_txt.text = my_rate .. "倍"
        end
    end
end

function DdzFreeGamePanel:RefreshScore(p_seat)
    local m_data = DdzFreeModel.data
    if m_data then
        if p_seat then
            local player = self.playerInfoUI[p_seat]
            local score
            if m_data.players_info and m_data.seatNum and
                next(m_data.seatNum) and m_data.players_info[m_data.seatNum[p_seat]] then
                score = m_data.players_info[m_data.seatNum[p_seat]].score
                if score then
                    player.score2_txt.text = StringHelper.ToCash(score)
                end
            end
        else
            for p_seat = 1, DdzFreeModel.maxPlayerNumber do
                local player = self.playerInfoUI[p_seat]
                local score
                if p_seat == 1 then
                    score = m_data.score
                else
                    local _p = m_data.players_info[m_data.seatNum[p_seat]]
                    if _p then
                        score = _p.score
                    end
                end
                if score then
                    player.score2_txt.text = StringHelper.ToCash(score)
                end
            end
        end
    end
end

function DdzFreeGamePanel:RefreshAutoStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzFreeModel.data then
        local auto = DdzFreeModel.data.auto_status
        if auto and DdzFreeModel.data.seatNum then
            --刷新全部
            if not pSeatNum then
                --刷新单个人
                for i = 1, DdzFreeModel.maxPlayerNumber do
                    if auto[DdzFreeModel.data.seatNum[i]] == 1 then
                        --显示
                        if i == 1 then
                            self.DdzFreePlayersActionManger:ChangeClickStatus(1)
                        end
                        self.autoUI[i]:SetActive(true)
                    else
                        if i == 1 then
                            self.DdzFreePlayersActionManger:ChangeClickStatus(0)
                        end
                        --隐藏
                        self.autoUI[i]:SetActive(false)
                    end
                end
            else
                if auto[DdzFreeModel.data.seatNum[pSeatNum]] == 1 then
                    --显示
                    if pSeatNum == 1 then
                        self.DdzFreePlayersActionManger:ChangeClickStatus(1)
                    end
                    self.autoUI[pSeatNum]:SetActive(true)
                else
                    --隐藏
                    if pSeatNum == 1 then
                        self.DdzFreePlayersActionManger:ChangeClickStatus(0)
                    end
                    self.autoUI[pSeatNum]:SetActive(false)
                end
            end
        else
            for i = 1, DdzFreeModel.maxPlayerNumber do
                if i == 1 then
                    self.DdzFreePlayersActionManger:ChangeClickStatus(0)
                end
                self.autoUI[i]:SetActive(false)
            end
        end
    end
end

--刷新剩余的牌 和warning
function DdzFreeGamePanel:RefreshRemainPaiWarningStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzFreeModel.data then
        local remain_pai_amount = DdzFreeModel.data.remain_pai_amount
        if not next(DdzFreeModel.data.seatNum) then
            print(debug.traceback())
        end
        if remain_pai_amount and DdzFreeModel.data.seatNum and next(DdzFreeModel.data.seatNum) then
            dump(DdzFreeModel.data.seatNum, "<color=red>DdzFreeModel.data.seatNum</color>")
            --刷新全部
            if not pSeatNum then
                for i = 1, DdzFreeModel.maxPlayerNumber do
                    --刷新warning
                    if self.warningUI[i] then
                        if remain_pai_amount[DdzFreeModel.data.seatNum[i]] < 3 then
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
                        self.playerOperateUI[i].remain_count_txt.text = remain_pai_amount[DdzFreeModel.data.seatNum[i]]
                    end
                end
            else
                --刷新warning
                if self.warningUI[pSeatNum] then
                    if remain_pai_amount[DdzFreeModel.data.seatNum[pSeatNum]] < 3 then
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
                        remain_pai_amount[DdzFreeModel.data.seatNum[pSeatNum]]
                end
            end
        else
            for i = 1, DdzFreeModel.maxPlayerNumber do
                if self.warningUI[i] then
                    self.warningUI[i]:SetActive(false)
                end
                if self.cardsRemainUI[i] then
                    self.cardsRemainUI[i].gameObject:SetActive(false)
                end
            end
        end
    end
end

--带动画和音效刷新剩余的牌 和warning
function DdzFreeGamePanel:RefreshRemainPaiWarningStatusWithAni(pSeatNum, act_type, pai_count)
    self:RefreshRemainPaiWarningStatus(pSeatNum)
    pai_count = pai_count or DdzFreeModel.data.remain_pai_amount[DdzFreeModel.data.seatNum[pSeatNum]]
    -- ###_test 根据牌的数量播放音效 动画等
    if (pai_count == 2 or pai_count == 1) and act_type ~= 0 then
         ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_card_leftwarning.audio_name)
        if pai_count == 2 then
            local sound = "sod_game_card_left2" .. AudioBySex(DdzFreeModel, DdzFreeModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        elseif pai_count == 1 then
            local sound = "sod_game_card_left1" .. AudioBySex(DdzFreeModel, DdzFreeModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        end
    end
end

-- 刷新换桌状态
function DdzFreeGamePanel:RefreshChangedesk()
    local m_data = DdzFreeModel.data
    if m_data.model_status and m_data.model_status == DdzFreeModel.Model_Status.wait_begin then
        self.changedesk.gameObject:SetActive(true)
        self.countdown = math.floor(DdzFreeModel.data.countdown)
        if self.countdown > 0 then
            self.TimeCallDict["ChangedeskCountdown"] = ChangedeskCountdown
            ChangedeskCountdown(self)
            self.changedesk_no.gameObject:SetActive(true)
        else
            self.TimeCallDict["ChangedeskCountdown"] = nil
            self.changedesk_no.gameObject:SetActive(false)
        end
    else
        self.changedesk.gameObject:SetActive(false)
    end
end

-- 刷新简易交互UI
function DdzFreeGamePanel:RefreshEasyChat()
    local dizhu = DdzFreeModel.data.dizhu
    local b = true
    if dizhu and dizhu > 0 then
        b = false
    end
    for i = 1, 3 do
        if i <= DdzFreeModel.maxPlayerNumber then
            self.EasyButton[i].gameObject:SetActive(b)
            self.HeroEasyButton[i].gameObject:SetActive(not b)
        else
            self.EasyButton[i].gameObject:SetActive(false)
            self.HeroEasyButton[i].gameObject:SetActive(false)
        end
    end
end

function DdzFreeGamePanel:RefreshPlayerInfo(pSeatNum)
    dump(pSeatNum,"<color=yellow>RefreshPlayerInfo</color>")
    dump( DdzFreeModel.data,"<color=yellow>RefreshPlayerInfo</color>")
    local m_data = DdzFreeModel.data
    if m_data then
        self:RefreshEasyChat()
        local dizhu = m_data.dizhu
        local playerInfo = m_data.players_info
        local RefreshPlayerAllInfo = function(pSeatNum)
            local info = playerInfo[m_data.seatNum[pSeatNum]]
            local player = self.playerInfoUI[pSeatNum]
            if m_data.model_status ~= DdzFreeModel.Model_Status.wait_table and info then
                --刷新头像 根据渠道 1，微信 2，游客
                URLImageManager.UpdateHeadImage(info.head_link, player.cust_head_img)
                self:ShowOrHideCustHeadIcon(false, pSeatNum)
                self:RefreshScore(pSeatNum)
                self:ShowOrHideHeadInfo(true, pSeatNum)
                self:ShowOrHidePlayerInfo(true, pSeatNum)
                player.infoRect1.gameObject:SetActive(false)
                player.infoRect2.gameObject:SetActive(true)
                player.name2_txt.text = info.name
                player.score2_txt.text = StringHelper.ToCash(info.score)
                PersonalInfoManager.SetHeadFarme(player.cust_head_icon_img, info.dressed_head_frame)
                VIPManager.set_vip_text(player.head_vip_txt,info.vip_level)
                if m_data.model_status == DdzFreeModel.Model_Status.wait_begin then
                    if info.ready == 1 then
                        player.HandImage.gameObject:SetActive(true)
                        player.NoReadImage.gameObject:SetActive(false)
                    else
                        player.HandImage.gameObject:SetActive(false)
                        player.NoReadImage.gameObject:SetActive(true)
                    end
                else
                    player.HandImage.gameObject:SetActive(false)
                    player.NoReadImage.gameObject:SetActive(false)
                end
            else
                player.HandImage.gameObject:SetActive(false)
                player.NoReadImage.gameObject:SetActive(false)
                self:ShowOrHideCustHeadIcon(true, pSeatNum)
                self:ShowOrHideHeadInfo(false, pSeatNum)
                self:ShowOrHidePlayerInfo(false, pSeatNum)
            end
        end

        local RefreshPlayerTextInfo = function(pSeatNum)
            local info = playerInfo[DdzFreeModel.data.seatNum[pSeatNum]]
            local player = self.playerInfoUI[pSeatNum]
            if m_data.model_status ~= DdzFreeModel.Model_Status.wait_table and info then
                player.infoRect1.gameObject:SetActive(false)
                player.infoRect2.gameObject:SetActive(true)
                player.name2_txt.text = info.name
                player.score2_txt.text = StringHelper.ToCash(info.score)
                self:RefreshScore(pSeatNum)
            else
                self:ShowOrHidePlayerInfo(false, pSeatNum)
            end
        end

        self.dizhu_card_son.cur_base_score_txt.text = "底分:" .. DdzFreeModel.data.init_stake

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
                    for i = 1, DdzFreeModel.maxPlayerNumber do
                        RefreshPlayerTextInfo(i)
                    end
                else
                    RefreshPlayerTextInfo(pSeatNum)
                end
            end
            for i = 1, DdzFreeModel.maxPlayerNumber do
                local info = playerInfo[DdzFreeModel.data.seatNum[i]]
                if info then
                    --地主
                    if DdzFreeModel.data.seatNum[i] == dizhu then
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
            end
        else
            if playerInfo then
                --刷新全部
                if not pSeatNum then
                    --刷新单个人
                    for i = 1, DdzFreeModel.maxPlayerNumber do
                        RefreshPlayerAllInfo(i)
                    end
                else
                    RefreshPlayerAllInfo(pSeatNum)
                end
            end
        end
    end
end

function DdzFreeGamePanel:RefreshMLDJDZStatus(pSeatNum)
    local data=DdzFreeModel.data
    if data then
        if pSeatNum then
            if pSeatNum == data.seat_num then
                --自己
                local jdz_permit_data = data.jdz_permit_data
                local my_men_data = data.men_data[pSeatNum]
                if my_men_data == 0 then
                    self.playerself_operate_son.men_zhua_btn.gameObject:SetActive(jdz_permit_data.men == true)
                    local is_kan = jdz_permit_data.kan == true
                    if is_kan then
                        change_btn_image(self.playerself_operate_son.kan_pai_btn, "ddz_btn_1", true)
                    else
                        change_btn_image(self.playerself_operate_son.kan_pai_btn, "ddz_btn_2", false)
                    end
                    self.playerself_operate_son.kan_pai_btn.gameObject:SetActive(true)
                    self.playerself_operate_son.kanpai_menzhua.gameObject:SetActive(true)
                    self:RefreshClockPos(self.playerself_operate_son.kp_mz_time_pos)
                else
                    local my_dao_la_data = data.dao_la_data[pSeatNum]
                    if my_dao_la_data == -1 then
                        self.playerself_operate_son.zhua_btn.gameObject:SetActive(jdz_permit_data.zhua == true)
                        local is_zhua = jdz_permit_data.buzhua == true
                        if is_zhua then
                            change_btn_image(self.playerself_operate_son.bu_zhua_btn, "ddz_btn_1", true)
                        else
                            change_btn_image(self.playerself_operate_son.bu_zhua_btn, "ddz_btn_2", false)
                        end
                        self.playerself_operate_son.bu_zhua_btn.gameObject:SetActive(true)
                        self.playerself_operate_son.zhua.gameObject:SetActive(true)
                        self:RefreshClockPos(self.playerself_operate_son.zhua_time_pos)
                    end
                end
            end
        end
    end
end

function DdzFreeGamePanel:RefreshMLDJBStatus(pSeatNum)
    local data=DdzFreeModel.data
    if data then
        if pSeatNum and pSeatNum == data.seat_num then
            local my_men_data = data.men_data[data.seat_num]
            local jb_permit_data = data.jb_permit_data
            --玩家没有闷操作可以选择倒或不倒
            if my_men_data == 0 then
                if jb_permit_data.dao then
                    local is_dao = jb_permit_data.dao == true
                    if is_dao then
                        change_btn_image(self.playerself_operate_son.dao_btn, "ddz_btn_3", true)
                    else
                        change_btn_image(self.playerself_operate_son.dao_btn, "ddz_btn_2", false)
                    end
                    self.playerself_operate_son.dao_btn.gameObject:SetActive(true)
                    self.playerself_operate_son.dao.gameObject:SetActive(true)
                    self:RefreshClockPos(self.playerself_operate_son.dao_time_pos)
                else
                    change_btn_image(self.playerself_operate_son.dao_btn, "ddz_btn_2", false)
                    self.playerself_operate_son.dao_btn.gameObject:SetActive(true)
                end
        
                if jb_permit_data.budao then
                    local is_budao = jb_permit_data.budao == true
                    if is_budao then
                        change_btn_image(self.playerself_operate_son.bu_dao_btn, "ddz_btn_1", true)
                    else
                        change_btn_image(self.playerself_operate_son.bu_dao_btn, "ddz_btn_2", false)
                    end
                    self.playerself_operate_son.bu_dao_btn.gameObject:SetActive(true)
                    self.playerself_operate_son.dao.gameObject:SetActive(true)
                    self:RefreshClockPos(self.playerself_operate_son.dao_time_pos)
                else
                    change_btn_image(self.playerself_operate_son.bu_dao_btn, "ddz_btn_2", false)
                    self.playerself_operate_son.bu_dao_btn.gameObject:SetActive(true)
                end
            else
                --玩家进行了闷操作
                if jb_permit_data.la then
                    self.playerself_operate_son.la_btn.gameObject:SetActive(jb_permit_data.la == true)
                    self.playerself_operate_son.la.gameObject:SetActive(true)
                    self:RefreshClockPos(self.playerself_operate_son.la_time_pos)
                end
        
                if jb_permit_data.bula then
                    self.playerself_operate_son.bu_la_btn.gameObject:SetActive(jb_permit_data.bula == true)
                    self.playerself_operate_son.la.gameObject:SetActive(true)
                    self:RefreshClockPos(self.playerself_operate_son.la_time_pos)
                end
            end
        end
    end
end

function DdzFreeGamePanel:RefreshJDZStatus(permitData)
    --将背景颜色还原
    change_btn_image(self.playerself_operate_son.jdz_1_btn, "ddz_btn_3", true)
    change_btn_image(self.playerself_operate_son.jdz_2_btn, "ddz_btn_3", true)
    change_btn_image(self.playerself_operate_son.jdz_3_btn, "ddz_btn_3", true)

    if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.er then
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
end

function DdzFreeGamePanel:RefreshJBStatus(permitData)
    self.playerself_operate_son.jiabei.gameObject:SetActive(true)
    self:RefreshClockPos(self.playerself_operate_son.jiabei_time_pos)
end

function DdzFreeGamePanel:RefreshPermitStatus()
    --隐藏所有权限
    self:ShowOrHidePermitUI(false)
    local data = DdzFreeModel.data
    if data then 
        local status = data.status
        local cur_p = data.cur_p
        if
            (status == DdzFreeModel.Status.jdz or 
                status == DdzFreeModel.Status.jiabei or
                status == DdzFreeModel.Status.cp or
                status == DdzFreeModel.Status.q_dizhu
            ) and
                cur_p
         then
            if cur_p > 0 and cur_p < 4 then
                --我自己
                if cur_p == data.seat_num then
                    local permitData = DdzFreeModel.getMyPermitData()
                    if permitData then
                        self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                        if permitData.type == DdzFreeModel.Status.jdz then
                            if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.nor then
                                self:RefreshJDZStatus(permitData)
                            elseif DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
                                self:RefreshMLDJDZStatus(data.seat_num)
                            end
                        elseif permitData.type == DdzFreeModel.Status.jiabei then
                            if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.nor then
                                self:RefreshJBStatus(permitData)
                            elseif DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
                                self:RefreshMLDJBStatus(data.seat_num)
                            end
                        elseif permitData.type == DdzFreeModel.Status.q_dizhu then
                            self.playerself_operate_son.qiangdizhu.gameObject:SetActive(true)
                            self:RefreshClockPos(self.playerself_operate_son.qiangdizhu_time_pos)
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
                                self.DdzFreePlayersActionManger:ChangeClickStatus(1)
                                self:RefreshClockPos(self.playerself_operate_son.yaobuqi_time_pos)
                            end
                        end
                    end
                elseif DdzFreeModel.data.s2cSeatNum then
                    if DdzFreeModel.data.s2cSeatNum[cur_p] == 2 then
                        self:ShowOrHidePermitUI(true, 2)
                    elseif DdzFreeModel.data.s2cSeatNum[cur_p] == 3 then
                        self:ShowOrHidePermitUI(true, 3)
                    end
                end
            else
                if status == DdzFreeModel.Status.jiabei then
                    if cur_p == 4 then
                        if data.seat_num ~= data.dizhu then
                            --隐藏操作
                            self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                            self:RefreshMLDJBStatus(data.seat_num)
                            for i=1,3 do
                                if data.seat_num~=i and data.dizhu~=i then
                                    self:ShowOrHidePermitUI(true,DdzFreeModel.data.s2cSeatNum[i])
                                    break
                                end
                            end
                        else
                            self:ShowOrHidePermitUI(true,2)
                            self:ShowOrHidePermitUI(true,3)
                        end
                    elseif cur_p == 5 then
                        if data.seat_num == data.dizhu then
                            --隐藏操作
                            self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                            self:RefreshMLDJBStatus(data.seat_num)
                        else
                            self:ShowOrHidePermitUI(true,DdzFreeModel.data.s2cSeatNum[data.dizhu])
                        end
                    elseif cur_p == 6 then
                        if data.jiabei == 0 then
                            self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                            self.playerself_operate_son.jiabei.gameObject:SetActive(true)
                            self:RefreshClockPos(self.playerself_operate_son.jiabei_time_pos)
                        end
                        self:ShowOrHidePermitUI(true, 2)
                        self:ShowOrHidePermitUI(true, 3)
                    end
                end
            end
            --给闹钟赋予初始值
            for i = 1, DdzFreeModel.maxPlayerNumber do
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

function DdzFreeGamePanel:RefreshClockPos(parent)
    self.playerself_operate_son.wait_time.transform.parent = parent.transform
    self.playerself_operate_son.wait_time.transform.localPosition = Vector3.zero
end

--刷新结算
function DdzFreeGamePanel:RefreshSettlement()
    if DdzFreeModel.data then
        local mData = DdzFreeModel.data
        local settlement_info = DdzFreeModel.data.settlement_info
        if settlement_info then
            --玩家剩余的牌
            if settlement_info.remain_pai then
                for k, v in pairs(settlement_info.remain_pai) do
                    --其他玩家的牌
                    local p_seat = v.p
                    local pai_list = v.pai
                    local cSeatNum = mData.s2cSeatNum[p_seat]
                    print("<color=yellow>cSeatNum>>>>>>>>>></color>", cSeatNum)
                    if cSeatNum ~= 1 then
                        local show_list = nor_ddz_base_lib.norId_convert_to_lzId(pai_list, DdzFreeModel.data.laizi)
                        if show_list then
                            table.sort(show_list)
                        end
                        self.DdzFreeActionUiManger:RefreshAction(cSeatNum, {type = -1, show_list = show_list})
                    end
                end
            end
        end
    end
end

--刷新地主UI显示
function DdzFreeGamePanel:RefreshDiZhuAndMultipleStatus()
    if DdzFreeModel.data then
        local myData = DdzFreeModel.data
        if not myData.dz_pai then
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(true)
            self.dizhu_card_son.dzcards.gameObject:SetActive(false)
        else
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(false)
            self.dizhu_card_son.dzcards.gameObject:SetActive(true)
            destroyChildren(self.dizhu_card_son.dzcards.transform)

            local pai_list = myData.dz_pai
            if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.lz then
                if self:LaiziInDizhu() then
                    pai_list = nor_ddz_base_lib.norId_convert_to_lzId(pai_list, self:GetLaizi())
                end
            end
            for k, v in pairs(pai_list) do
                DdzDzCard.New(self.dzCardObj, self.dizhu_card_son.dzcards.transform, v, v, 0)
            end
        end
    end
end

--刷新废牌
function DdzFreeGamePanel:RefreshDeadwood()
    if DdzFreeModel.baseData.game_type ~= DdzFreeModel.game_type.er then
        return
    end
    print("<color=red>RefreshDeadwood>>>>>>>>>>>>>>>>>>>>>>>>> </color>")
    self:DelDeadwood()
    local mData = DdzFreeModel.data
    if mData.status == DdzFreeModel.Status.fp or mData.status == DdzFreeModel.Status.settlement or mData.deadwood_list then
        self.DNode.gameObject:SetActive(true)
        if mData.deadwood_list then
            local show_list = nor_ddz_base_lib.norId_convert_to_lzId(mData.deadwood_list.pai, mData.laizi)
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
function DdzFreeGamePanel:RefreshQDZUI()
    if DdzFreeModel.baseData.game_type ~= DdzFreeModel.game_type.er then
        return
    end
    local m_data = DdzFreeModel.data
    if
        m_data and m_data.status == DdzFreeModel.Status.q_dizhu and m_data.er_qiang_dizhu_count and
            m_data.er_qiang_dizhu_count > 0
     then
        self.playerOperateUI[1].qiang_hint_txt.text = "抢" .. m_data.er_qiang_dizhu_count .. "次"
    else
        self.playerOperateUI[1].qiang_hint_txt.text = ""
    end
end

-- 刷新让牌提示
function DdzFreeGamePanel:RefreshRangHint()
    if DdzFreeModel.baseData.game_type ~= DdzFreeModel.game_type.er then
        return
    end
    local m_data = DdzFreeModel.data
    if m_data and m_data.dizhu and m_data.remain_pai_amount then
        self.rang_pai_hint_node.gameObject:SetActive(true)
        local num = m_data.remain_pai_amount[DdzFreeModel.GetSeatNM()] - m_data.rangpai_num
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

--刷新赖子牌显示
function DdzFreeGamePanel:RefreshLaiziStatus(playAnim)
    if DdzFreeModel.baseData.game_type ~= DdzFreeModel.game_type.lz then
        return
    end
    local laizi = self:GetLaizi()
    print("<color=green>刷新赖子牌显示</color>",laizi)
    if laizi <= 0 then
        self.dizhu_card_son.dzcardlz.gameObject:SetActive(false)
        self.playerself_operate_son.laizi.gameObject:SetActive(false)
        self.cur_multiple_txt.transform.localPosition = Vector3.New(192, 513, 0)
        self.playerself_operate_son.laizi.gameObject:SetActive(false)
    else
        self.dizhu_card_son.dzcardlz.gameObject:SetActive(true)
        destroyChildren(self.dizhu_card_son.dzcardlz.transform)
        local lz_id = nor_ddz_base_lib.get_lzId(laizi)
        DdzDzCard.New(self.dzCardObj, self.dizhu_card_son.dzcardlz.transform, lz_id, lz_id, 0)

        if playAnim then
            DDZAnimation.ShowLaizi(
                lz_id,
                self.dizhu_card_son.dzcardlz,
                function()
                    self.DdzFreePlayersActionManger:CreateLz(true)
                    self.cur_multiple_txt.transform.localPosition = Vector3.New(292, 513, 0)
                    self:UpdateLaiziDepend(laizi)
                end
            )
        else
            self.DdzFreePlayersActionManger:CreateLz(false)
            self.cur_multiple_txt.transform.localPosition = Vector3.New(292, 513, 0)
            self:UpdateLaiziDepend(laizi)
        end
    end
end

function DdzFreeGamePanel:RefreshRed()
    if IsEquals(self.red_txt) then
        self.red_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
    end
end

--********************callback
function DdzFreeGamePanel:OnEasyClick(obj)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if DdzFreeModel.data and DdzFreeModel.data.model_status == DdzFreeModel.Model_Status.gaming then
        local uipos = tonumber(string.sub(obj.name, -1, -1))
        local data = DdzFreeModel.GetPosToPlayer(uipos)
        if data then
            SysInteractivePlayerManager.Create(data, uipos)
        else
            dump(data, "<color=red>玩家没有入座</color>")
        end
    else            
    end
end

function DdzFreeGamePanel:OnChangedeskClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    DdzFreeModel.HZCheck()
end


function DdzFreeGamePanel:OnClickCloseSignup()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local callback = function (  )
        Network.SendRequest("fg_quit_game", {})
    end
    GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
end

function DdzFreeGamePanel:AutoShowDdzJiPaiQiCB()
    if GameGlobalOnOff.JPQTool and GameItemModel.GetItemCount("jipaiqi") > 0 then
        local is_show = true
        if DdzFreeModel.data.model_status == DdzFreeModel.Model_Status.wait_begin then
            is_show = false
        else
            is_show = true
        end
       
        if self.isShowStatistics ~= nil then
            is_show = self.isShowStatistics
        end
        self.playerself_operate_son.statistics.gameObject:SetActive(is_show)
    end
end

--记牌器
function DdzFreeGamePanel:DdzJiPaiQiCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if GameItemModel.GetItemCount("jipaiqi") > 0 then
        local statistics = self.playerself_operate_son.statistics
        if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.lz then
            local laizi_icon = self.playerself_operate_son.laizi
            local laizi = self:GetLaizi()
            laizi_icon.gameObject:SetActive(not statistics.gameObject.activeSelf and laizi > 0)
        end

        self.isShowStatistics = not statistics.gameObject.activeSelf
        statistics.gameObject:SetActive(self.isShowStatistics)
        self:RefreshDdzJiPaiQi()
    else
        local pay_record = self.playerself_operate_son.pay_record
        pay_record.gameObject:SetActive(not pay_record.gameObject.activeSelf)
    end
end

function DdzFreeGamePanel:DdzPayJiPaiQiCB()
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

--菜单
function DdzFreeGamePanel:MenuCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local menu_bg = self.menu_son.menu_bg
    local b = not menu_bg.gameObject.activeSelf
    menu_bg.gameObject:SetActive(b)
    self.TopButtonImage.gameObject:SetActive(b)
end

--退出
function DdzFreeGamePanel:CloseCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if DdzFreeModel.data and DdzFreeModel.data.model_status == DdzFreeModel.Model_Status.gaming then
        Network.SendRequest("fg_quit_game")
    else
        local callback = function (  )
            Network.SendRequest("fg_quit_game")
        end
        GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
    end
end

--帮助
function DdzFreeGamePanel:HelpCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.lz then
        DdzHelpPanel.Create("LZ")
    elseif DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.er then
        DdzHelpPanel.Create("ER")
    else
        if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
            DdzHelpPanel.Create("TF")
        else
            DdzHelpPanel.Create("JD")
        end
    end
end

--设置
function DdzFreeGamePanel:SetCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
end

function DdzFreeGamePanel:CanelAutoBtnCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if Network.SendRequest("nor_ddz_nor_auto", {operate = 0}) then
        self.autoUI[1]:SetActive(false)
    else
        DDZAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end
end

--*****************ShowOrHide
function DdzFreeGamePanel:ShowOrHideDdzView(status)
    self.ddz_match_dizhu_card_ui.gameObject:SetActive(status)
    self.menu_btn.gameObject:SetActive(status)
    self.ddz_match_playerright_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerright_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_operate_ui.gameObject:SetActive(status)
end

function DdzFreeGamePanel:ShowOrHideWarningView(status)
    for i = 1, DdzFreeModel.maxPlayerNumber do
        --刷新warning
        if self.warningUI[i] then
            --隐藏
            self.warningUI[i]:SetActive(false)
        end
    end
end

function DdzFreeGamePanel:ShowOrHidePermitUI(status, people)
    if people == 2 then
        self.playerright_operate_son.wait_time.gameObject:SetActive(status)
    elseif people == 3 then
        self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
    else
        self.playerself_operate_son.wait_time.gameObject:SetActive(status)
        if self.playerself_operate_son.yaobuqi.gameObject.activeSelf then
            if status == true then
                self.DdzFreePlayersActionManger:ChangeClickStatus(1)
            else
                if not self.autoUI[1].activeSelf then
                    self.DdzFreePlayersActionManger:ChangeClickStatus(0)
                end
            end
        end
        self.playerself_operate_son.yaobuqi.gameObject:SetActive(status)
        -- if not status then
        --     SpineManager.DaiJi(1)
        -- end
        self.playerself_operate_son.chupai.gameObject:SetActive(status)

        if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.nor then
            if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.er then
                self.playerself_operate_son.jiaodizhuer.gameObject:SetActive(status)
                self.playerself_operate_son.qiangdizhu.gameObject:SetActive(status)
            else
                self.playerself_operate_son.jiaodizhu.gameObject:SetActive(status)
            end
            self.playerself_operate_son.jiabei.gameObject:SetActive(status)
        elseif DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
            self.playerself_operate_son.kanpai_menzhua.gameObject:SetActive(status)
            self.playerself_operate_son.zhua.gameObject:SetActive(status)
            self.playerself_operate_son.dao.gameObject:SetActive(status)
            self.playerself_operate_son.la.gameObject:SetActive(status)
        end
        if not people then
            self.playerright_operate_son.wait_time.gameObject:SetActive(status)
            self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
        end
    end
end

function DdzFreeGamePanel:ShowOrHideActionUI(status, people)
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

function DdzFreeGamePanel:ShowOrHideCustHeadIcon(status, seatNum)
    -- if not seatNum then
    --     for i = 1, DdzFreeModel.maxPlayerNumber do
    --         self.playerInfoUI[i].cust_head_icon_img.gameObject:SetActive(status)
    --     end
    -- else
    --     self.playerInfoUI[seatNum].cust_head_icon_img.gameObject:SetActive(status)
    -- end
end

function DdzFreeGamePanel:ShowOrHideHeadInfo(status, seatNum)
    if DdzFreeModel.data then
        if not seatNum then
            for i = 1, DdzFreeModel.maxPlayerNumber do
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

function DdzFreeGamePanel:ShowOrHidePlayerInfo(status, seatNum)
    if DdzFreeModel.data then
        if not seatNum then
            for i = 1, DdzFreeModel.maxPlayerNumber do
                self.playerInfoUI[i].infoRect.gameObject:SetActive(status)
            end
        else
            self.playerInfoUI[seatNum].infoRect.gameObject:SetActive(status)
        end
    end
end

function DdzFreeGamePanel:SetHideMenu()
    self.menu_son.menu_bg.gameObject:SetActive(false)
    self.TopButtonImage.gameObject:SetActive(false)
end

--赖子
function DdzFreeGamePanel:UpdateLaiziDepend(laizi)
    print("<color=green>UpdateLaiziDepend</color>")
    --刷新牌
    self.DdzFreePlayersActionManger:Refresh()

    --刷新记牌器中赖子位置
    local index = 17 - laizi
    local statistics = self.playerself_operate_son.statistics
    local child = statistics:GetChild(index)
    local position = child.transform.position
    local laizi_icon = self.playerself_operate_son.laizi
    local laizi_pos = laizi_icon.transform.position
    laizi_pos.x = position.x + 2
    laizi_icon.transform.position = laizi_pos
    laizi_icon.transform.parent = child.transform
    self.playerself_operate_son.laizi.gameObject:SetActive(true)

    if self:LaiziInDizhu() then
        self:RefreshDiZhuAndMultipleStatus()
    end
end

function DdzFreeGamePanel:GetLaizi()
    local data = DdzFreeModel.data
    if not data or not data.laizi then
        return 0
    end
    return data.laizi
end

function DdzFreeGamePanel:GetDizhu()
    local data = DdzFreeModel.data
    if not data then
        return nil
    end
    return data.dz_pai
end

function DdzFreeGamePanel:LaiziInDizhu()
    local laizi = self:GetLaizi()
    if laizi <= 0 then
        return false
    end
    local dizhu = self:GetDizhu() or {}
    for k, v in pairs(dizhu) do
        if laizi == v then
            return true
        end
    end
    return false
end

function DdzFreeGamePanel:FillSelectLaizi(btn_ident, btn_table, pai_list, container, callback)
    local lzSelectCardObj = self.lzSelectCardObj
    for k, v in pairs(pai_list) do
        local go = GameObject.Instantiate(lzSelectCardObj, container.transform)
        go.name = v

        local num_img = go.transform:Find("@card_img/@card_num/@num_img"):GetComponent("Image")
        local type_img = go.transform:Find("@card_img/@card_num/@type_big_img"):GetComponent("Image")
        if not num_img or not type_img then
            print("errrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
            return
        end
        if v >= 60 then
            local pai = nor_ddz_base_lib.get_pai_info(v)
            local typeIcon = "poker_laizi"
            local noIcon = "poker_icon_laizi" .. pai.type
            num_img.sprite = GetTexture(noIcon)
            type_img.sprite = GetTexture(typeIcon)
        else
            --数字牌
            local noIcon = "poker_icon_"
            local typeIcon = "poker_"
            local typeNumIcon = ""
            local pai = nor_ddz_base_lib.get_pai_info(v)
            local paiType = pai.type
            local color = pai.color
            --红黑梅方 0，1，2，3
            if color == 1 then
                noIcon = noIcon .. "nr" .. paiType
                typeIcon = typeIcon .. "heart"
            elseif color == 2 then
                noIcon = noIcon .. "nb" .. paiType
                typeIcon = typeIcon .. "spade"
            elseif color == 3 then
                noIcon = noIcon .. "nb" .. paiType
                typeIcon = typeIcon .. "plum"
            elseif color == 4 then
                noIcon = noIcon .. "nr" .. paiType
                typeIcon = typeIcon .. "block"
            end
            num_img.sprite = GetTexture(noIcon)
            type_img.sprite = GetTexture(typeIcon)
        end
    end
    local btn = container:GetComponent("Button")
    if btn then
        btn.name = btn_ident
        btn_table[btn_ident] = btn
        self.behaviour:AddClick(btn.gameObject, callback, self)
    else
        print("[DDZ LZ] FillSelectLaizi but btn is nil " .. btn_ident)
    end
end

function DdzFreeGamePanel:ShowSelectLaiziType(pai_list_table, callback)
    self.ddz_select_laizi_ui.gameObject:SetActive(true)
    self.timerUI[4].gameObject:SetActive(true)

    local select_laizi_son = self.select_laizi_son
    local list_area = select_laizi_son.list_area
    local item_tmpl = select_laizi_son.item_tmpl
    local child_tmpl = select_laizi_son.child_tmpl
    local wait_time = select_laizi_son.wait_time
    local wait_time_txt = select_laizi_son.wait_time_txt
    wait_time_txt.text = self.countdown

    local item = nil
    local child = nil
    local btn_table = {}
    local table_count = table.getn(pai_list_table)
    local index = 1
    local pai_list = nil

    for index = 1, table_count, 1 do
        item = GameObject.Instantiate(item_tmpl, list_area)
        child = GameObject.Instantiate(child_tmpl, item)

        item.gameObject:SetActive(true)
        child.gameObject:SetActive(true)

        pai_list = pai_list_table[index]
        --fill
        local btn_ident = index
        self:FillSelectLaizi(
            btn_ident,
            btn_table,
            pai_list,
            child,
            function()
                self:ResetSelectLaiziType(btn_table)
                if callback then
                    callback(btn_ident)
                end
            end
        )

        index = index + 1
    end
    self.selectLaiziBtnTable = btn_table
    --隐藏操作面板
    self:ShowOrHidePermitUI(false)
end

function DdzFreeGamePanel:ResetSelectLaiziType(btn_table)
    if not self.ddz_select_laizi_ui.gameObject.activeSelf then
        return
    end

    coroutine.start(
        function()
            -- 下一帧
            Yield(0)
            local select_laizi_son = self.select_laizi_son
            local list_area = select_laizi_son.list_area
            for k, v in pairs(btn_table) do
                self.behaviour:RemoveClick(v.gameObject)
            end
            btn_table = {}

            destroyChildren(list_area)
            self.ddz_select_laizi_ui.gameObject:SetActive(false)
            self.timerUI[4].gameObject:SetActive(false)
        end
    )
end

function DdzFreeGamePanel:OnClickCloseSelectLaizi()
    self:ResetSelectLaiziType(self.selectLaiziBtnTable)
    self:RefreshPermitStatus()
end

--二人
function DdzFreeGamePanel:DelDeadwood()
    if self.deadwoodList then
        for i = 1, #self.deadwoodList do
            self.deadwoodList[i]:Destroy()
        end
    end
    self.deadwoodList = {}
end

function DdzFreeGamePanel:IsShow_JpqNotice()
    self.playerself_operate_son.jipaiqi_notice.gameObject.transform.localPosition = Vector2.New(329,-507)
    --if GameItemModel.GetItemCount("jipaiqi") > 0 or (_G["SYSYKManager"] and SYSYKManager.IsBuy) then
        self.playerself_operate_son.jipaiqi_notice.gameObject:SetActive(false)
    -- else
    -- 	self.playerself_operate_son.jipaiqi_notice.gameObject:SetActive(true)
    -- end 
end