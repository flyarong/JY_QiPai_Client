local basefunc = require "Game.Common.basefunc"
local tyDdzFunc=require "Game.normal_ddz_common.Lua.tingyong_ddz_func"
--数据结构
--说明：位置坐标系  我的位置永远为1 逆时针 2 3，

DdzTyGamePanel = basefunc.class()

DdzTyGamePanel.name = "DdzTyGamePanel"

local lister
local listerRegisterName="ddzTYFreeGameListerRegister"
-- local seatNum
-- local s2cSeatNum

-- local function transform_seat(self,mySeatNum)
--     if mySeatNum then
--         self.seatNum={}
--         self.s2cSeatNum = {}
--         self.seatNum[1]=mySeatNum
--         self.s2cSeatNum[mySeatNum]=1
--         for i=2,3 do
--             mySeatNum=mySeatNum+1
--             if mySeatNum>3 then
--                 mySeatNum=1
--             end
--             self.seatNum[i]=mySeatNum
--             self.s2cSeatNum[mySeatNum]=i
--         end

--         seatNum=self.seatNum
--         s2cSeatNum=self.s2cSeatNum
--     end
-- end
local function change_btn_image( btn,image,enabled,text)
    local btn_img = btn.gameObject:GetComponent("Image")
    btn_img.sprite = GetTexture(image)
    btn_img:SetNativeSize()
    -- btn.enabled = enabled
    -- btn.interactable = enabled
    btn_img.raycastTarget=enabled
    -- btn.gameObject.GetComponent<Button>().enabled = false
    if text then
        self.close_txt.text = text 
    end
end

local instance
function DdzTyGamePanel.Create()
    instance=DdzTyGamePanel.New()
    instance.dzCardObj = GetPrefab("DdzTyDzCard")
    instance.cardObj = GetPrefab("DdzTyCard")
    instance.lzSelectCardObj = GetPrefab("DdzTySelectCard")
    return createPanel(instance,DdzTyGamePanel.name)
end
function DdzTyGamePanel.Bind()
    local _in=instance
    instance=nil
    return _in
end

function DdzTyGamePanel:Awake()
    ExtendSoundManager.PlaySceneBGM(audio_config.ddz.ddz_bgm_game.audio_name)
    LuaHelper.GeneratingVar(self.transform,  self)
    self.pairdesk_son={}
    LuaHelper.GeneratingVar(self.ddz_match_pairdesk_ui.transform,  self.pairdesk_son)
    self.dizhu_card_son={}
    LuaHelper.GeneratingVar(self.ddz_match_dizhu_card_ui.transform,  self.dizhu_card_son)
    self.playerright_info_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerright_info_ui.transform,  self.playerright_info_son)
    self.playerright_operate_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerright_operate_ui.transform,  self.playerright_operate_son)
    self.playerleft_info_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerleft_info_ui.transform,  self.playerleft_info_son)
    self.playerleft_operate_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerleft_operate_ui.transform,  self.playerleft_operate_son)
    self.playerself_info_son  = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerself_info_ui.transform,  self.playerself_info_son)
    self.playerself_operate_son = {}
    LuaHelper.GeneratingVar(self.ddz_match_playerself_operate_ui.transform,  self.playerself_operate_son)
    self.menu_son = {}
    LuaHelper.GeneratingVar(self.menu_btn.transform,  self.menu_son)
    self.select_laizi_son = {}
    LuaHelper.GeneratingVar(self.ddz_select_laizi_ui.transform, self.select_laizi_son)

    --托管UI
    self.autoUI={}
    self.autoUI[1]=self.playerself_operate_son.auto.gameObject
    self.autoUI[2]=self.playerright_operate_son.auto.gameObject
    self.autoUI[3]=self.playerleft_operate_son.auto.gameObject

    --警报UI
    self.warningUI={} 
    self.warningUI[2]=self.playerright_operate_son.alarm.gameObject
    self.warningUI[3]=self.playerleft_operate_son.alarm.gameObject
    --剩余的牌
    self.cardsRemainUI={} 
    self.cardsRemainUI[2]=self.playerright_operate_son.cards_remain.gameObject
    self.cardsRemainUI[3]=self.playerleft_operate_son.cards_remain.gameObject

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

    self.ChatButton_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        SysInteractiveChatManager.Show()
    end)

    self.EasyButton = {[1]=self.EasyButton1, [2]=self.EasyButton2, [3]=self.EasyButton3}
    self.HeroEasyButton = {[1]=self.HeroEasyButton1, [2]=self.HeroEasyButton2, [3]=self.HeroEasyButton3}
    for i=1,3 do
        local btn = self.EasyButton[i]
        EventTriggerListener.Get(btn.gameObject).onClick = basefunc.handler(self, self.OnEasyClick)

        local herobtn = self.HeroEasyButton[i]
        EventTriggerListener.Get(herobtn.gameObject).onClick = basefunc.handler(self, self.OnEasyClick)
    end

    self.countdown=0
    --初始化闹钟 time < 0 隐藏 timer ，time > 0 显示
    self.timer = nil
    self.timerTween = {}

    self.TopButtonImage = self.transform:Find("TopButtonImage"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButtonImage.gameObject).onClick = basefunc.handler(self, self.SetHideMenu)
    self.TopButtonImage.gameObject:SetActive(false)

    self.updateTimer = Timer.New(basefunc.handler(self,self.update_callback), 1, -1, true)
    self.updateTimer:Start()
    self:MyInit()
    self.TimeCallDict = {}

    self.selectTyBtnTable = {}
    self:MyRefresh()
end
function DdzTyGamePanel:OnEasyClick(obj)
    local uipos = tonumber(string.sub(obj.name,-1,-1))
    local data = DdzTyModel.GetPosToPlayer(uipos)
    if data then
        SysInteractivePlayerManager.Create(data, uipos)
    else
        dump(data, "<color=red>玩家没有入座</color>")
    end
end
function DdzTyGamePanel:SetHideMenu()
    local menu_bg = self.menu_son.menu_bg
    menu_bg.gameObject:SetActive(false)
    self.TopButtonImage.gameObject:SetActive(false)
end

function DdzTyGamePanel:update_callback()
    local dt=1
    if self.countdown and self.countdown>0 then 
        self.countdown=self.countdown-dt
    end
    self:RefreshClock()
    for k,call in pairs(self.TimeCallDict) do
        call(self)
    end

    --最后一手牌自动出牌
    if self.last_pai_auto_countdown then
        self.last_pai_auto_countdown=self.last_pai_auto_countdown-dt
        if self.last_pai_auto_countdown==0 and self.last_pai_auto_cb then
            self.last_pai_auto_cb()
        end
    end

end

function DdzTyGamePanel:RefreshClock()
    local flag=nil
    for i=1,#self.timerUI,1 do
        if self.timerUI[i].gameObject.activeSelf then
            local isZero = self.timerTextUI[i].text == "0"
            self.timerTextUI[i].text = self.countdown
            if self.countdown <= 5 and not isZero  and not self.timerTween[i] then
                self.timerTween[i] = DDZAnimation.clockCountdown(self.timerTextUI[i])
                flag=true
            end
        end
    end 
    if flag then
        ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_timeout.audio_name)
    end
end

function DdzTyGamePanel:Start()
    -- self:MyRefresh()
end

function DdzTyGamePanel:MyInit()
    self.DdzTyActionUiManger=DdzTyActionUiManger.Create(self,self.playerOperateUI,self.dizhu_card_son)
    self.DdzTyPlayersActionManger=DdzTyPlayersActionManger.Create(self)
    self:MakeLister()
    DdzTyLogic.setViewMsgRegister(lister,listerRegisterName)
    self.behaviour:AddClick(self.back_btn.gameObject, DdzTyGamePanel.OnClickCloseSignup, self)
    self.behaviour:AddClick(self.select_laizi_son.select_laizi_btn_bg.gameObject, DdzTyGamePanel.OnClickCloseSelectTy, self);

    EventTriggerListener.Get(self.change_cards_pos_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.ChangeCardsPosBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_bg_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.no_play_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.BuchupaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.out_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.ChupaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.hint_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.HintBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.kan_pai_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.KanPaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.men_zhua_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.MenZhuaBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.zhua_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.ZhuaPaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.bu_zhua_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.BuZhuaPaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.dao_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.DaoBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.bu_dao_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.BuDaoBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.la_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.LaBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.bu_la_btn.gameObject).onClick=basefunc.handler(self.DdzTyPlayersActionManger,self.DdzTyPlayersActionManger.BuLaBtnCB)  

    EventTriggerListener.Get(self.playerself_operate_son.close_auto_btn.gameObject).onClick=basefunc.handler(self,self.CanelAutoBtnCB) 
    EventTriggerListener.Get(self.playerself_operate_son.record_btn.gameObject).onClick=basefunc.handler(self,self.DdzJiPaiQiCB) 
    EventTriggerListener.Get(self.playerself_operate_son.pay_record_btn.gameObject).onClick=basefunc.handler(self,self.DdzPayJiPaiQiCB) 
    EventTriggerListener.Get(self.menu_btn.gameObject).onClick=basefunc.handler(self,self.MenuCB) 
    EventTriggerListener.Get(self.menu_son.set_btn.gameObject).onClick=basefunc.handler(self,self.SetCB) 
    EventTriggerListener.Get(self.menu_son.close_btn.gameObject).onClick=basefunc.handler(self,self.CloseCB)
    EventTriggerListener.Get(self.menu_son.help_btn.gameObject).onClick=basefunc.handler(self,self.HelpCB) 
end

local function BackBtnCountdown(self)   
    if self.countdown and self.countdown > 0 then
        self.back_time_txt.text = self.countdown .. "秒后可返回"
    else
        self:RefreshBackBtn()
    end
end
function DdzTyGamePanel:RefreshBackBtn()
    local m_data = DdzTyModel.data
    self.offback.gameObject:SetActive(true) 
    if m_data and m_data.status == macth_status.wait_table then
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
function DdzTyGamePanel:OnClickCloseSignup()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Network.SendRequest("tydfg_cancel_signup",{})
end

function DdzTyGamePanel:MyRefresh()
    if DdzTyModel.data then
        local m_data=DdzTyModel.data
        self.countdown=math.floor(m_data.countdown)
        
        if m_data.status==macth_status.wait_table then
            self.ddz_match_pairdesk_ui.gameObject:SetActive(true)
            self:ShowOrHideDdzView(false)
            self:RefreshBackBtn()
            self:ShowOrHideWarningView(false)
            self.cardsRemainUI[2].gameObject:SetActive(false)
            self.cardsRemainUI[3].gameObject:SetActive(false)
            
            SpineManager.RemoveAllDDZPlayerSpine()
        else
            self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
            self:ShowOrHideDdzView(true)
            
            -- transform_seat(self,m_data.seat_num)
            --刷新警报
            self:RefreshRemainPaiWarningStatus()
            --刷新我的牌展示UI 及 操作
            self.DdzTyPlayersActionManger:Refresh()
            --刷新托管
            self:RefreshAutoStatus()
            --刷新权限
            self:RefreshPermitStatus()
            --刷新操作展示UI
            self.DdzTyActionUiManger:Refresh()
            --刷新地主牌
            self:RefreshDiZhuAndMultipleStatus()
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
        end
    end
end

function DdzTyGamePanel:RefreshDdzJiPaiQi()
    --自动显示记牌器
    self:AutoShowDdzJiPaiQiCB()
    if DdzTyModel.data then
        local m_data=DdzTyModel.data
        local statistics = self.playerself_operate_son.statistics
        if m_data then
            if m_data.model_status == DdzTyModel.Model_Status.wait_table or m_data.model_status == DdzTyModel.Model_Status.wait_begin then
                self.playerself_operate_son.record_btn.gameObject:SetActive(false)
                self.playerself_operate_son.pay_record.gameObject:SetActive(false)
                statistics.gameObject:SetActive(false)
            else
                local jipaiqi = m_data.jipaiqi
                if not jipaiqi then
                    for i=0,statistics.transform.childCount - 1 do
                        local child = statistics:GetChild(i)
                        child:GetComponent("Text").text = "-"
                    end
                else
                    for i=0,statistics.transform.childCount - 1 do
                        local child = statistics:GetChild(i)
                        local childText = child:GetComponent("Text")
                        local key = 18 - i
                        local count = jipaiqi[key]
                        
                        childText.text = count
                        if key == 18 or key == 17 or key == 16 then
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
                local is_show = DdzTyModel.data.model_status == DdzTyModel.Model_Status.gaming
                self.playerself_operate_son.record_btn.gameObject:SetActive(GameGlobalOnOff.JPQTool and is_show)
            end
        end
    end
end
function DdzTyGamePanel:AutoShowDdzJiPaiQiCB()
    if GameGlobalOnOff.JPQTool and GameItemModel.GetItemCount("jipaiqi") > 0 then
        local is_show = true
        if self.isShowStatistics ~= nil then is_show = self.isShowStatistics end
        self.playerself_operate_son.statistics.gameObject:SetActive(is_show)
    end
end
--记牌器
function DdzTyGamePanel:DdzJiPaiQiCB()
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

function DdzTyGamePanel:DdzPayJiPaiQiCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    PayPanel.Create(GOODS_TYPE.item, "normal" ,function ()
        self:RefreshDdzJiPaiQi()
    end,ITEM_TYPE.expression)
    self.playerself_operate_son.pay_record.gameObject:SetActive(false)
end

--菜单
function DdzTyGamePanel:MenuCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local menu_bg = self.menu_son.menu_bg
    local b = not menu_bg.gameObject.activeSelf
    menu_bg.gameObject:SetActive(b)
    self.TopButtonImage.gameObject:SetActive(b)
end

--退出
function DdzTyGamePanel:CloseCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    HintPanel.Create(1,"比赛中不能退出")
end

--退出
function DdzTyGamePanel:HelpCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    DdzHelpPanel.Create("TY")
end

--设置
function DdzTyGamePanel:SetCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
end

-- 刷新游戏结算界面
--todo
function DdzTyGamePanel:RefreshClearing()
    if DdzTyModel.data.status == macth_status.gameover then
        DdzTyClearing.Create()
    else
        DdzTyClearing.Close()
    end
end
function DdzTyGamePanel:RefreshRate()
    self.cur_multiple_txt.gameObject:SetActive(false)
    if DdzTyModel.data then
        local my_rate = DdzTyModel.data.my_rate
        if  my_rate then
            self.cur_multiple_txt.gameObject:SetActive(true)
            self.cur_multiple_txt.text = my_rate .. "倍"
        end
    end
end

function  DdzTyGamePanel:RefreshScore(p_seat)
    if DdzTyModel.data then
    	local m_data = DdzTyModel.data
        if p_seat then
            local player = self.playerInfoUI[p_seat]
            local grades
            if p_seat==1 then
                grades=m_data.grades
            else
                grades=m_data.players_info[DdzTyModel.data.seatNum[p_seat]].grades
            end
            if grades then
                player.score_txt.text = grades
            end
        else
            for p_seat=1,3 do
                local player = self.playerInfoUI[p_seat]
                 local grades
                if p_seat==1 then
                    grades=m_data.grades
                else
                    grades=m_data.players_info[DdzTyModel.data.seatNum[p_seat]].grades
                end
                if grades then
                    player.score_txt.text = grades
                end
            end
        end
        
     end
end

function DdzTyGamePanel:ShowOrHideWarningView(status)
    for i=1,3 do
        --刷新warning
        if self.warningUI[i] then
            --隐藏
            self.warningUI[i]:SetActive(false)
        end
    end
end

function DdzTyGamePanel:ShowOrHideDdzView(status)
    self.ddz_match_dizhu_card_ui.gameObject:SetActive(status)
    self.menu_btn.gameObject:SetActive(status)
    self.ddz_match_playerright_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerright_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_operate_ui.gameObject:SetActive(status)
end
function DdzTyGamePanel:ShowOrHidePermitUI(status,people)
    if people==2 then
        self.playerright_operate_son.wait_time.gameObject:SetActive(status)
    elseif people==3 then
        self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
    else
        self.playerself_operate_son.wait_time.gameObject:SetActive(status)
        if self.playerself_operate_son.yaobuqi.gameObject.activeSelf then
            if status == true then
                self.DdzTyPlayersActionManger:ChangeClickStatus(1)
            else
                if not self.autoUI[1].activeSelf then
                    self.DdzTyPlayersActionManger:ChangeClickStatus(0)
                end
            end
        end
        self.playerself_operate_son.yaobuqi.gameObject:SetActive(status)
        -- if not status then
        --     SpineManager.DaiJi(1)
        -- end
        self.playerself_operate_son.chupai.gameObject:SetActive(status)
        self.playerself_operate_son.kanpai_menzhua.gameObject:SetActive(status)
        self.playerself_operate_son.zhua.gameObject:SetActive(status)
        self.playerself_operate_son.dao.gameObject:SetActive(status)
        self.playerself_operate_son.la.gameObject:SetActive(status)
        if not people then
            self.playerright_operate_son.wait_time.gameObject:SetActive(status)
            self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
        end
    end    
end
function DdzTyGamePanel:ShowOrHideActionUI(status,people)
    if people==2 then
        self.playerright_operate_son.my_action.gameObject:SetActive(status)
    elseif people==3 then
        self.playerleft_operate_son.my_action.gameObject:SetActive(status)
    else
        self.playerself_operate_son.my_action.gameObject:SetActive(status)
        if not people then
            self.playerright_operate_son.my_action.gameObject:SetActive(status)
            self.playerleft_operate_son.my_action.gameObject:SetActive(status)
        end
    end    
end

function DdzTyGamePanel:MyExit()
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

    self.updateTimer:Stop()
    self.DdzTyPlayersActionManger:MyExit()
    self.DdzTyActionUiManger:MyExit()
    SpineManager.RemoveAllDDZPlayerSpine()
    DdzTyLogic.clearViewMsgRegister(listerRegisterName)
    DdzTyClearing.Close()
    --closePanel(DdzTyGamePanel.name)
    self.dzCardObj = nil
    self.cardObj = nil
    self.lzSelectCardObj = nil
end
function DdzTyGamePanel:MyClose()
    self:MyExit()
    closePanel(DdzTyGamePanel.name)
end

function DdzTyGamePanel:RefreshAutoStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzTyModel.data then
        local auto=DdzTyModel.data.auto_status
        if auto and DdzTyModel.data.seatNum then
            --刷新全部 
            if not pSeatNum then
                for i=1,3 do
                    if  auto[DdzTyModel.data.seatNum[i]]==1 then
                        --显示
                        if i == 1 then
                            self.DdzTyPlayersActionManger:ChangeClickStatus(1)
                        end
                        print("<color=green>托管</color>")
                        self.autoUI[i]:SetActive(true)
                    else
                        --隐藏
                        if i == 1 then
                            self.DdzTyPlayersActionManger:ChangeClickStatus(0)
                        end
                        self.autoUI[i]:SetActive(false)
                    end
                end
            --刷新单个人
            else
                if auto[DdzTyModel.data.seatNum[pSeatNum]]==1 then
                    --显示
                    if pSeatNum == 1 then
                        self.DdzTyPlayersActionManger:ChangeClickStatus(1)
                    end
                    self.autoUI[pSeatNum]:SetActive(true)
                else
                    --隐藏
                    if pSeatNum == 1 then
                        self.DdzTyPlayersActionManger:ChangeClickStatus(0)
                    end
                    self.autoUI[pSeatNum]:SetActive(false)
                end
            end
            
        end
    end
end

--刷新剩余的牌 和warning 
function DdzTyGamePanel:RefreshRemainPaiWarningStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzTyModel.data then
        local remain_pai_amount=DdzTyModel.data.remain_pai_amount
        if remain_pai_amount and DdzTyModel.data.seatNum then
            --刷新全部 
            if not pSeatNum then

                for i=1,3 do
                    --刷新warning
                    if self.warningUI[i] then
                        if  remain_pai_amount[DdzTyModel.data.seatNum[i]]<3 then
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
                        self.playerOperateUI[i].remain_count_txt.text=remain_pai_amount[DdzTyModel.data.seatNum[i]]
                    end

                end
            --刷新单个人
            else
                --刷新warning
                if self.warningUI[pSeatNum] then
                    if  remain_pai_amount[DdzTyModel.data.seatNum[pSeatNum]]<3 then
                      --显示
                        self.warningUI[pSeatNum]:SetActive(true)
                    else
                        --隐藏
                        self.warningUI[pSeatNum]:SetActive(false)
                    end
                end

                --刷新牌的数量
                if self.cardsRemainUI[pSeatNum] then
                    self.playerOperateUI[pSeatNum].remain_count_txt.text=remain_pai_amount[DdzTyModel.data.seatNum[pSeatNum]]
                end

            end
            
        end
    end
end

--带动画和音效刷新剩余的牌 和warning  
function DdzTyGamePanel:RefreshRemainPaiWarningStatusWithAni(pSeatNum,act_type,pai_count)
    self:RefreshRemainPaiWarningStatus(pSeatNum)
    pai_count=pai_count or DdzTyModel.data.remain_pai_amount[DdzTyModel.data.seatNum[pSeatNum]]
    -- ###_test 根据牌的数量播放音效 动画等
    if (pai_count==2 or pai_count==1) and act_type~=0 then
         ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_card_leftwarning.audio_name)
        if pai_count==2 then
            local sound = "sod_game_card_left2" .. AudioBySex(DdzTyModel,DdzTyModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        elseif pai_count==1 then
            local sound = "sod_game_card_left1" .. AudioBySex(DdzTyModel,DdzTyModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        end
    end
end
function DdzTyGamePanel:CanelAutoBtnCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if Network.SendRequest("tydfg_auto", {operate=0}) then
        self.autoUI[1]:SetActive(false)
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end
-- 刷新简易交互UI
function DdzTyGamePanel:RefreshEasyChat()
    local dizhu = DdzTyModel.data.dizhu
    local b = true
    if dizhu and dizhu > 0 then
        b = false
    end
    for i=1,3 do
        self.EasyButton[i].gameObject:SetActive(b)
        self.HeroEasyButton[i].gameObject:SetActive(not b)
    end
end
function DdzTyGamePanel:RefreshPlayerInfo(pSeatNum)
    if DdzTyModel.data then
        self:RefreshEasyChat()
    	local m_data = DdzTyModel.data
        local dizhu = m_data.dizhu
        local playerInfo = m_data.players_info
        local RefreshPlayerAllInfo=function (pSeatNum)
            local info = playerInfo[DdzTyModel.data.seatNum[pSeatNum]]
            local player = self.playerInfoUI[pSeatNum]
            if info then
                --刷新头像 根据渠道 1，微信 2，游客
                URLImageManager.UpdateHeadImage(info.head_link, player.cust_head_img)
                self:ShowOrHideCustHeadIcon(false,pSeatNum)
                self:RefreshScore(pSeatNum)                
                self:ShowOrHideHeadInfo(true,pSeatNum)
                self:ShowOrHidePlayerInfo(true,pSeatNum)
                PersonalInfoManager.SetHeadFarme(player.cust_head_icon_img, info.dressed_head_frame)
                VIPManager.set_vip_text(player.head_vip_txt,info.vip_level)
		player.infoRect1.gameObject:SetActive(false)
                player.infoRect2.gameObject:SetActive(true)
                player.name2_txt.text = info.name
                player.score2_txt.text = StringHelper.ToCash(info.jing_bi)
            else
                self:ShowOrHideCustHeadIcon(true,pSeatNum)
                self:ShowOrHideHeadInfo(false,pSeatNum)
                self:ShowOrHidePlayerInfo(false,pSeatNum)
            end
        end

        local RefreshPlayerTextInfo=function (pSeatNum)
            local info = playerInfo[DdzTyModel.data.seatNum[pSeatNum]]
            local player = self.playerInfoUI[pSeatNum]
            if info then
                player.infoRect1.gameObject:SetActive(false)
                player.infoRect2.gameObject:SetActive(true)
                player.name2_txt.text = info.name
                player.score2_txt.text = StringHelper.ToCash(info.jing_bi)
                self:RefreshScore(pSeatNum)
            else
                self:ShowOrHidePlayerInfo(false,pSeatNum)
            end
        end

        self.dizhu_card_son.cur_base_score_txt.text = "底分:" .. m_data.init_stake
        
        --地主框 隐藏
        SpineManager.RemoveAllDDZPlayerSpine()
        --头像隐藏
        self:ShowOrHideCustHeadIcon(true,pSeatNum)
        self:ShowOrHideHeadInfo(false,pSeatNum)
        self:ShowOrHidePlayerInfo(false,pSeatNum)

	if dizhu ~= nil and dizhu > 0 then
            self:ShowOrHidePlayerInfo(true,pSeatNum)
            if  playerInfo then
                --刷新全部 
                if not pSeatNum then
                    for i=1,3 do
                        RefreshPlayerTextInfo(i)
                    end
                --刷新单个人
                else
                    RefreshPlayerTextInfo(pSeatNum)
                end

            end    

            for i=1,3 do
                --地主
                if DdzTyModel.data.seatNum[i] == dizhu then
                    if not SpineManager.GetSpine(i) then
                        local spine = newObject("@spine_dz_nan",self.playerInfoUI[i].spine_node.transform):GetComponent("SkeletonAnimation")
                        SpineManager.AddDDZPlayerSpine(spine,i)
                        if i == 1 then
                            SetSortingOrder(i,-1)
                        end  
                    end
                else
                    if not SpineManager.GetSpine(i) then
                        local spine = newObject("@spine_nm_nan",self.playerInfoUI[i].spine_node.transform):GetComponent("SkeletonAnimation")
                        SpineManager.AddDDZPlayerSpine(spine,i)
                        if i == 1 then
                            SetSortingOrder(i,-1)
                        end  
                    end
                end
            end
        else
            if  playerInfo then
                --刷新全部 
                if not pSeatNum then
                    for i=1,3 do
                        RefreshPlayerAllInfo(i)
                    end
                --刷新单个人
                else
                    RefreshPlayerAllInfo(pSeatNum)
                end

            end    
        end 
    end
end

function DdzTyGamePanel:RefreshJDZStatus(pSeatNum)
    local data=DdzTyModel.data
    if data then
        if pSeatNum then
            if pSeatNum == data.seat_num then
                --自己
                local jdz_permit_data = data.jdz_permit_data
                local my_men_data = data.men_data[data.seat_num]
                if my_men_data == 0 then
                    self.playerself_operate_son.men_zhua_btn.gameObject:SetActive(jdz_permit_data.kan == true)
                    self.playerself_operate_son.men_zhua_btn.gameObject:SetActive(jdz_permit_data.men == true)
                    self.playerself_operate_son.kanpai_menzhua.gameObject:SetActive(true)
                    self:RefreshClockPos(self.playerself_operate_son.kp_mz_time_pos)
                else
                    if my_men_data == 1 then
                    -- self.playerself_operate_son.message_hint_txt.gameObject:SetActive(true)
                    elseif my_men_data == 2 then
                    end
                    
                    local my_p_dao_la = data.p_dao_la[data.seat_num]
                    if my_p_dao_la == -1 then
                        self.playerself_operate_son.zhua_btn.gameObject:SetActive(jdz_permit_data.zhua == true)
                        self.playerself_operate_son.bu_zhua_btn.gameObject:SetActive(jdz_permit_data.buzhua == true)
                        self.playerself_operate_son.zhua.gameObject:SetActive(true)
                        self:RefreshClockPos(self.playerself_operate_son.zhua_time_pos)
                    elseif my_p_dao_la == 0 then
                        
                    elseif my_p_dao_la == 1 then
                    end
                end
            else
                local my_men_data = data.men_data[pSeatNum]
                if my_men_data == 0 then
                    -- self:ShowOrHidePermitUI(true,s2cSeatNum[pSeatNum])
                elseif my_men_data == 1 then
                elseif my_men_data == 2 then
                end

                local my_p_dao_la = data.p_dao_la[pSeatNum]
                if my_p_dao_la == -1 then
                    -- self:ShowOrHidePermitUI(true,s2cSeatNum[pSeatNum])
                elseif my_p_dao_la == 0 then
                elseif my_p_dao_la == 1 then
                end
            end
        end
    end
end

function DdzTyGamePanel:RefreshJBStatus(pSeatNum)
    local data=DdzTyModel.data
    if data then
        if pSeatNum then
            if pSeatNum == data.seat_num then
                local my_men_data = data.men_data[data.seat_num]
                local jb_permit_data = data.jb_permit_data
                --玩家没有闷操作可以选择倒或不倒
                if my_men_data == 0 then
                    if jb_permit_data.dao then
                        self.playerself_operate_son.dao_btn.gameObject:SetActive(jb_permit_data.dao == true)
                        self.playerself_operate_son.dao.gameObject:SetActive(true)
                        self:RefreshClockPos(self.playerself_operate_son.dao_time_pos)
                    else
                        self.playerself_operate_son.dao_btn.gameObject:SetActive(false)
                    end
            
                    if jb_permit_data.budao then
                        self.playerself_operate_son.bu_dao_btn.gameObject:SetActive(jb_permit_data.budao == true)
                        self.playerself_operate_son.dao.gameObject:SetActive(true)
                        self:RefreshClockPos(self.playerself_operate_son.dao_time_pos)
                    else
                        self.playerself_operate_son.bu_dao_btn.gameObject:SetActive(false)
                    end
                elseif my_men_data == 1 then
                       
                elseif my_men_data == 2 then

                end
        
                --玩家进行了闷操作
                if my_men_data ~= 0 then
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
            else

            end
        else

        
        end
    end
end

function DdzTyGamePanel:RefreshPermitStatus()
    --隐藏所有权限
    self:ShowOrHidePermitUI(false) 
    if DdzTyModel.data then
        local data=DdzTyModel.data
        local status=data.status
        local cur_p=data.cur_p
        if (status==macth_status.jdz or status==macth_status.jiabei or status==macth_status.cp ) and cur_p then
            if cur_p>0 and cur_p<4 then
                --我自己
                if cur_p==data.seat_num then
                    local permitData=DdzTyModel.getMyPermitData()
                    if permitData then


                        self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                        if permitData.type==macth_status.jdz then
                            self:RefreshJDZStatus(data.seat_num)
                        elseif permitData.type==macth_status.jiabei then
                            self:RefreshJBStatus(data.seat_num)
                        else
                            --cp
                            if permitData.power==0 then
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
                                    self.playerself_operate_son.yaobuqi.transform:Find("@yaobuqi_txt").gameObject:SetActive(false)
                                else
                                    self.playerself_operate_son.yaobuqi.transform:Find("@yaobuqi_txt").gameObject:SetActive(true)
                                end
                                self.DdzTyPlayersActionManger:ChangeClickStatus(1)
                                self:RefreshClockPos(self.playerself_operate_son.yaobuqi_time_pos)
                            end

                        end    

                    end
                --其他人    
                elseif DdzTyModel.data.s2cSeatNum then
                    if DdzTyModel.data.s2cSeatNum[cur_p]==2 then
                        self:ShowOrHidePermitUI(true,2)
                    elseif DdzTyModel.data.s2cSeatNum[cur_p]==3 then
                        self:ShowOrHidePermitUI(true,3)
                    end
                end
            --teshu
            else
                if status==macth_status.jiabei then
                    if cur_p == 4 then
                        if data.seat_num ~= data.dizhu then
                            --隐藏操作

                            self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                            self:RefreshJBStatus(data.seat_num)
                            
                            for i=1,3 do
                                if data.seat_num~=i and data.dizhu~=i then
                                    self:ShowOrHidePermitUI(true,DdzTyModel.data.s2cSeatNum[i])
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
                            self:RefreshJBStatus(data.seat_num)
                        else
                            self:ShowOrHidePermitUI(true,DdzTyModel.data.s2cSeatNum[data.dizhu])
                        end
                    end
                end
            end
            --给闹钟赋予初始值
            for i=1,#self.timerUI,1 do
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

function DdzTyGamePanel:RefreshClockPos(parent)
    self.playerself_operate_son.wait_time.transform.parent = parent.transform
    self.playerself_operate_son.wait_time.transform.localPosition = Vector3.zero
end

--刷新结算
function DdzTyGamePanel:RefreshSettlement()
    if DdzTyModel.data then
        local data = DdzTyModel.data
        local settlement_info = data.settlement_info
        if settlement_info then
            --玩家剩余的牌
            if settlement_info.remain_pai then
                for k,v in pairs(settlement_info.remain_pai) do
                    --其他玩家的牌
                    local p_seat = v.p
                    local pai_list = v.pai
                    local cSeatNum = DdzTyModel.data.s2cSeatNum[p_seat]
                    if cSeatNum~=1 then 
                        local show_list=tyDdzFunc.norId_convert_to_lzId(pai_list,DdzTyModel.data.laizi)
                        if show_list then
                            table.sort(show_list)
                        end
                        self.DdzTyActionUiManger:RefreshAction(cSeatNum,{type=-1,show_list=show_list})
                    end    
                end
            end
        end
    end
end

--刷新地主UI显示
function DdzTyGamePanel:RefreshDiZhuAndMultipleStatus()
    if DdzTyModel.data then
        local data = DdzTyModel.data
        if not data.dz_pai then
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(true)
            self.dizhu_card_son.dzcards.gameObject:SetActive(false)
        else
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(false)
            self.dizhu_card_son.dzcards.gameObject:SetActive(true)
            destroyChildren(self.dizhu_card_son.dzcards.transform)

	    local pai_list = data.dz_pai
	    if self:TyInDizhu() then
	    	pai_list = tyDdzFunc.norId_convert_to_lzId(pai_list,self:GetTy())
	    end
	    for k,v in pairs(pai_list) do
	        DdzTyDzCard.New(self.dzCardObj, self.dizhu_card_son.dzcards.transform,v,v,0)
	    end
        end
    end
end

function DdzTyGamePanel:GetTy()
	local data = DdzTyModel.data
	if not data or not data.laizi then return 0 end
	return data.laizi
end

function DdzTyGamePanel:GetDizhu()
	local data = DdzTyModel.data
	if not data then return nil end
	return data.dz_pai
end

function DdzTyGamePanel:RefreshTyDepend(laizi)
    --刷新牌
	self.DdzTyPlayersActionManger:Refresh()

	--刷新记牌器中赖子位置
	local index = 17 - laizi
	local statistics = self.playerself_operate_son.statistics
	local child = statistics:GetChild(index)
	local position = child.transform.position
	local laizi_icon = self.playerself_operate_son.laizi
	local laizi_pos = laizi_icon.transform.position
	laizi_pos.x = position.x
	laizi_icon.transform.position = laizi_pos

	if self:TyInDizhu() then
		self:RefreshDiZhuAndMultipleStatus()
	end
end

function DdzTyGamePanel:TyInDizhu()
	local laizi = self:GetTy()
	if laizi <= 0 then return false end
	local dizhu = self:GetDizhu() or {}
	for k, v in pairs(dizhu) do
		if laizi == v then
			return true
		end
	end
	return false
end

function DdzTyGamePanel:FillSelectTy(btn_ident, btn_table, pai_list, container, callback)
	local lzSelectCardObj = self.lzSelectCardObj
	for k,v in pairs(pai_list) do
		local go = GameObject.Instantiate(lzSelectCardObj, container.transform)
		go.name = v
		
		local num_img = go.transform:Find("@card_img/@card_num/@num_img"):GetComponent("Image")
		local type_img = go.transform:Find("@card_img/@card_num/@type_big_img"):GetComponent("Image")
		if not num_img or not type_img then
			print("errrrrrrrrrrrrrrrrrrrrrrrrrrrrr")
			return
		end
		if v >= 60 then
			local pai = tyDdzFunc.get_pai_info(v)
			local typeIcon = "poker_laizi"
			local noIcon = "poker_icon_laizi" .. pai.type
			num_img.sprite = GetTexture(noIcon)
			type_img.sprite = GetTexture(typeIcon)
		else
			--数字牌
			local noIcon = "poker_icon_"
			local typeIcon = "poker_"
			local typeNumIcon = ""
			local pai = tyDdzFunc.get_pai_info(v)
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
		--DdzDzCard.New(self.dzCardObj, container.transform, v, v, 0)
	end

	local btn = container:GetComponent("Button")
	if btn then
		btn.name = btn_ident
		btn_table[btn_ident] = btn
		self.behaviour:AddClick(btn.gameObject, callback, self);
	else
		print("[DDZ LZ] FillSelectTy but btn is nil " .. btn_ident)
	end
end

function DdzTyGamePanel:ShowSelectTyType(pai_list_table, callback)
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
		self:FillSelectTy(btn_ident, btn_table, pai_list, child, function()
			self:ResetSelectTyType(btn_table)
			if callback then callback(btn_ident) end
		end)

		index = index + 1
	end
	self.selectTyBtnTable = btn_table

	--隐藏操作面板
	self:ShowOrHidePermitUI(false)
end

function DdzTyGamePanel:ResetSelectTyType(btn_table)
	if not self.ddz_select_laizi_ui.gameObject.activeSelf then 
        return 
    end
    
	coroutine.start(function ()
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
	end)
end

function DdzTyGamePanel:OnClickCloseSelectTy()
	self:ResetSelectTyType(self.selectTyBtnTable)
	self:RefreshPermitStatus()
end


function DdzTyGamePanel:ShowOrHideCustHeadIcon(status,seatNum)
    -- if not seatNum then
    --     for i=1,3 do
    --         self.playerInfoUI[i].cust_head_icon_img.gameObject:SetActive(status)
    --     end
    -- else
    --     self.playerInfoUI[seatNum].cust_head_icon_img.gameObject:SetActive(status)
    -- end
end

function DdzTyGamePanel:ShowOrHideHeadInfo(status,seatNum)
    if DdzTyModel.data then
        if not seatNum then
            for i=1,3 do
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

function DdzTyGamePanel:ShowOrHidePlayerInfo(status,seatNum)
    if DdzTyModel.data then
        if not seatNum then
            for i=1,3 do
                self.playerInfoUI[i].infoRect.gameObject:SetActive(status)
            end
        else
            self.playerInfoUI[seatNum].infoRect.gameObject:SetActive(status)
        end
    end
end

function DdzTyGamePanel:MakeLister()
    lister={} 
    lister["tydfgModel_tydfg_enter_room_msg"]=basefunc.handler(self,self.on_tydfg_enter_room_msg)
    lister["tydfgModel_tydfg_join_msg"]=basefunc.handler(self,self.on_tydfg_join_msg) 
    lister["tydfgModel_tydfg_pai_msg"]=basefunc.handler(self,self.on_tydfg_pai_msg)
    lister["tydfgModel_tydfg_kan_my_pai_msg"]=basefunc.handler(self,self.on_tydfg_kan_my_pai_msg)
    lister["tydfgModel_tydfg_action_msg"]=basefunc.handler(self,self.on_tydfg_action_msg) 
    lister["tydfgModel_tydfg_permit_msg"]=basefunc.handler(self,self.on_tydfg_permit_msg)
    lister["tydfgModel_tydfg_dizhu_msg"]=basefunc.handler(self,self.on_tydfg_dizhu_msg)
    lister["tydfgModel_tydfg_dizhu_pai_msg"]=basefunc.handler(self,self.on_tydfg_dizhu_pai_msg)
    lister["tydfgModel_tydfg_auto_msg"]=basefunc.handler(self,self.on_tydfg_auto_msg) 
    lister["tydfgModel_tydfg_new_game_msg"]=basefunc.handler(self,self.on_tydfg_new_game_msg)
    lister["tydfgModel_tydfg_start_again_msg"]=basefunc.handler(self,self.on_tydfg_start_again_msg)
    lister["tydfgModel_tydfg_gameover_msg"]=basefunc.handler(self,self.on_tydfg_game_clearing_msg)
    
end

function DdzTyGamePanel:on_tydfg_enter_room_msg()
    self:MyRefresh()
end

function DdzTyGamePanel:on_tydfg_join_msg(seat_num)
    self:RefreshPlayerInfo(DdzTyModel.data.s2cSeatNum[seat_num])
end

function DdzTyGamePanel:on_tydfg_pai_msg()
    local my_pai_list=DdzTyModel.data.my_pai_list
    dump(DdzTyModel.data.my_pai_list, "<color=green>发牌》》》》》》</color>")
    if my_pai_list  then
        self.DdzTyPlayersActionManger:Fapai(my_pai_list)
    end
    self:RefreshRemainPaiWarningStatus()
end

function DdzTyGamePanel:on_tydfg_kan_my_pai_msg()
    local my_pai_list=DdzTyModel.data.my_pai_list
    if my_pai_list  then
        self.DdzTyPlayersActionManger:UiManagerClearAndRefresh()
    end
    self:RefreshRemainPaiWarningStatus()
end


function DdzTyGamePanel:on_tydfg_action_msg()
    local act=DdzTyModel.data.action_list[#DdzTyModel.data.action_list]
    self.DdzTyPlayersActionManger:DealAction(DdzTyModel.data.s2cSeatNum[act.p],act)
    self:RefreshDdzJiPaiQi()
end

--自动出最后一手牌
local function auto_chu_last_pai(self)
    local m_data=DdzTyModel.data
    if m_data.status==macth_status.cp then
        local pos=m_data.s2cSeatNum[m_data.cur_p]
        if pos==1 then
            local _act=tyDdzFunc.check_is_only_last_pai(m_data.action_list,m_data.my_pai_list)
            if _act then
                self.last_pai_auto_countdown=1
                self.last_pai_auto_cb=function ()
                    self.last_pai_auto_cb=nil
                    self.last_pai_auto_countdown=nil
                    local manager=self.DdzTyPlayersActionManger
                    --将所有的牌弹起
                    for no,v in pairs(manager.my_pai_hash) do
                        v:ChangePosStatus(1)
                    end
                    --出牌btn
                    manager:SendChupaiRequest(_act)
                end
            end
        end
    end

end

function DdzTyGamePanel:on_tydfg_permit_msg()
    self.countdown=math.floor(DdzTyModel.data.countdown)
    if DdzTyModel.data.cur_p==4 then
        for i=1,3 do 
            if i~=DdzTyModel.data.dizhu then
                self:ShowOrHideActionUI(false,DdzTyModel.data.s2cSeatNum[i])
            end
        end
    elseif DdzTyModel.data.cur_p==5 then
        self:ShowOrHideActionUI(false,DdzTyModel.data.s2cSeatNum[DdzTyModel.data.dizhu])
    else
        self:ShowOrHideActionUI(false,DdzTyModel.data.s2cSeatNum[DdzTyModel.data.cur_p])
    end
    self:RefreshPermitStatus()
    --隐藏
    self:ResetSelectTyType(self.selectTyBtnTable)

    self.DdzTyActionUiManger:changeActionUIShowByStatus()

    auto_chu_last_pai(self)
end
function DdzTyGamePanel:on_tydfg_dizhu_msg()
    if DdzTyModel.data then
        local data = DdzTyModel.data
        self:RefreshRate()
        self:RefreshPlayerInfo()
        self:RefreshDdzJiPaiQi()
    end
end

function DdzTyGamePanel:on_tydfg_dizhu_pai_msg()
    if DdzTyModel.data then
        local data = DdzTyModel.data
        --to be 插入地主牌动画
        if data.dizhu==data.seat_num then
	        self.DdzTyPlayersActionManger:AddPai(data.dz_pai)
        end
        self:RefreshDiZhuAndMultipleStatus()
        self:RefreshRate()
        self:RefreshPlayerInfo()
    end
end

function DdzTyGamePanel:on_tydfg_auto_msg(player)
    self:RefreshAutoStatus(DdzTyModel.data.s2cSeatNum[player])
    self:OnClickCloseSelectTy()
	--[[local list_table = {}
	list_table[1] = {2,9,8,7,6}
	list_table[2] = {5,6,7,8,9,12,13,14,15}
	self:ShowSelectTyType(list_table, function(ident)
		print("ShowSelectTyType callback " .. ident)
	end)]]--
end

function DdzTyGamePanel:on_tydfg_new_game_msg()
    self:MyRefresh()
    --新的局数
    if DdzTyModel.data then
        local curRace = DdzTyModel.data.race
        if curRace then
            DDZAnimation.CurRace(curRace,self.start_again_cards_pos)
        end
    end
end
function DdzTyGamePanel:on_tydfg_start_again_msg()
    self:MyRefresh()
    DDZAnimation.StartAgainCard(self.start_again_cards_pos)
end

function DdzTyGamePanel:on_tydfg_game_clearing_msg()
    self:RefreshSettlement()

    if DdzTyModel.data then
        local data = DdzTyModel.data
	local settlement_info = data.settlement_info

	if settlement_info then
	    --得分 动画
	    if settlement_info.award then
	        for p_seat,score in pairs(settlement_info.award) do
	            local cSeat = DdzTyModel.data.s2cSeatNum[p_seat]
		    local playerUI = self.playerInfoUI[cSeat]
            DDZAnimation.ChangeScore(cSeat, score ,playerUI.score_change_pos)
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
    		    if data.my_rate then
    		        DDZAnimation.ChangeRate(self.cur_multiple_txt,data.my_rate)
    		    end
    		end
	    end
	    if settlement_info.chuntian or settlement_info.award then
	        local t1 = Timer.New(function ()
		    self:RefreshClearing()
		end, 2, 1, true)
		t1:Start()
	    else
	        self:RefreshClearing()
	    end
	end
        self:RefreshScore()
    end    
end


