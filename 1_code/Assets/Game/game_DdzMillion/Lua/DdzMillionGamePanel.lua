local basefunc = require "Game.Common.basefunc"
local nDdzFunc=require "Game.normal_ddz_common.Lua.normal_ddz_func_lib"
--数据结构
--说明：位置坐标系  我的位置永远为1 逆时针 2 3，

DdzMillionGamePanel = basefunc.class()

DdzMillionGamePanel.name = "DdzMillionGamePanel"
local lister
local listerRegisterName="ddzMillionGameListerRegister"
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
    local hi = btn.transform:Find("hi")
    local no = btn.transform:Find("no")
    hi.gameObject:SetActive(enabled)
    no.gameObject:SetActive(not enabled)

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
function DdzMillionGamePanel.Create()
    instance=DdzMillionGamePanel.New()
    instance.dzCardObj = GetPrefab("DdzDzCard")
    instance.cardObj = GetPrefab("DdzCard")
    return createPanel(instance,DdzMillionGamePanel.name)
end
function DdzMillionGamePanel.Bind()
    local _in=instance
    instance=nil
    return _in
end
function DdzMillionGamePanel:Awake()
    ExtendSoundManager.PlaySceneBGM(audio_config.ddz.ddz_bgm_game.audio_name)
    LuaHelper.GeneratingVar(self.transform,  self)
    self.pairdesk_son={}
    LuaHelper.GeneratingVar(self.ddz_million_pairdesk_ui.transform,  self.pairdesk_son)
    self.dizhu_card_son={}
    LuaHelper.GeneratingVar(self.ddz_million_dizhu_card_ui.transform,  self.dizhu_card_son)
    self.playerright_info_son = {}
    LuaHelper.GeneratingVar(self.ddz_million_playerright_info_ui.transform,  self.playerright_info_son)
    self.playerright_operate_son = {}
    LuaHelper.GeneratingVar(self.ddz_million_playerright_operate_ui.transform,  self.playerright_operate_son)
    self.playerleft_info_son = {}
    LuaHelper.GeneratingVar(self.ddz_million_playerleft_info_ui.transform,  self.playerleft_info_son)
    self.playerleft_operate_son = {}
    LuaHelper.GeneratingVar(self.ddz_million_playerleft_operate_ui.transform,  self.playerleft_operate_son)
    self.playerself_info_son  = {}
    LuaHelper.GeneratingVar(self.ddz_million_playerself_info_ui.transform,  self.playerself_info_son)
    self.playerself_operate_son = {}
    LuaHelper.GeneratingVar(self.ddz_million_playerself_operate_ui.transform,  self.playerself_operate_son)
    self.promoted_son = {}
    LuaHelper.GeneratingVar(self.ddz_million_promoted_ui.transform,  self.promoted_son)   
    self.wait_son = {}
    LuaHelper.GeneratingVar(self.ddz_million_wait_ui.transform,  self.wait_son)
    self.menu_son = {}
    LuaHelper.GeneratingVar(self.menu_btn.transform,  self.menu_son)
    self.statistics_son = {}
    LuaHelper.GeneratingVar(self.statistics.transform,  self.statistics_son)

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
    self.timerTextUI = {}
    self.timerTextUI[1] = self.playerself_operate_son.wait_time_txt
    self.timerTextUI[2] = self.playerright_operate_son.wait_time_txt
    self.timerTextUI[3] = self.playerleft_operate_son.wait_time_txt

    self.GotoMatchButton = self.GotoMatchButton:GetComponent("Button")
    self.GotoMatchButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        local state = gameMgr:CheckUpdate("game_MatchHall")
        if state == "Install" or state == "Update" then
            HintPanel.Create(1, "请返回大厅更新游戏")
        else
            if Network.SendRequest("dbwg_quit_game") then
                MainLogic.ExitGame()
                MainLogic.GotoScene("game_MatchHall")
            end
        end
    end)

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

    self.colorGary = Color.New(194 / 255, 171 / 255, 160 / 255, 255 / 255)
    self.colorYellow = Color.New(255 / 255, 211 / 255, 0 / 255, 255 / 255)

    self.TopButtonImage = self.transform:Find("TopButtonImage"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButtonImage.gameObject).onClick = basefunc.handler(self, self.SetHideMenu)
    self.TopButtonImage.gameObject:SetActive(false)

    self.updateTimer = Timer.New(basefunc.handler(self,self.update_callback), 1, -1, true)
    self.updateTimer:Start()
    self:MyInit()
    self:MyRefresh()
end
function DdzMillionGamePanel:OnEasyClick(obj)
    local uipos = tonumber(string.sub(obj.name,-1,-1))
    local data = DdzMillionModel.GetPosToPlayer(uipos)
    if data then
        SysInteractivePlayerManager.Create(data, uipos)
    else
        dump(data, "<color=red>玩家没有入座</color>")
    end
end

function DdzMillionGamePanel:SetHideMenu()
    local menu_bg = self.menu_son.menu_bg
    menu_bg.gameObject:SetActive(false)
    self.TopButtonImage.gameObject:SetActive(false)
end
function DdzMillionGamePanel:update_callback()
    local dt=1
    if self.countdown and self.countdown>0 then 
        self.countdown=self.countdown-dt
    end
    self:RefreshClock()
    self:RefreshWaitFuHuoCountdown()

    --最后一手牌自动出牌
    if self.last_pai_auto_countdown then
        self.last_pai_auto_countdown=self.last_pai_auto_countdown-dt
        if self.last_pai_auto_countdown==0 and self.last_pai_auto_cb then
            self.last_pai_auto_cb()
        end
    end
end
function DdzMillionGamePanel:RefreshClock()
    local flag=nil
    for i=1,3 do
        if self.timerUI[i].gameObject.activeSelf then
            local isZero = self.timerTextUI[i].text == "0"            
            self.timerTextUI[i].text = self.countdown
            if self.countdown <= 5 and not isZero and not self.timerTween[i] then
                self.timerTween[i] = DDZAnimation.clockCountdown(self.timerTextUI[i])
                flag=true
            end
        end
    end 
    if flag then
        ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_timeout.audio_name)
    end
end

function DdzMillionGamePanel:Start()
    -- self:MyRefresh()
end

function DdzMillionGamePanel:MyInit()
    self.DdzMillionActionUiManger=DdzMillionActionUiManger.Create(self,self.playerOperateUI,self.dizhu_card_son)
    self.DdzMillionPlayersActionManger=DdzMillionPlayersActionManger.Create(self)
    self:MakeLister()
    DdzMillionLogic.setViewMsgRegister(lister,listerRegisterName)

    EventTriggerListener.Get(self.change_cards_pos_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.ChangeCardsPosBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_bg_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.no_play_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.BuchupaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.out_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.ChupaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.hint_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.HintBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.JiabeiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_not_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.BujiabeiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.jdz_1_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.Jdz1BtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.jdz_2_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.Jdz2BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_3_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.Jdz3BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_not_btn.gameObject).onClick=basefunc.handler(self.DdzMillionPlayersActionManger,self.DdzMillionPlayersActionManger.Bujdz1BtnCB)  

    EventTriggerListener.Get(self.playerself_operate_son.close_auto_btn.gameObject).onClick=basefunc.handler(self,self.CanelAutoBtnCB) 
    EventTriggerListener.Get(self.playerself_operate_son.record_btn.gameObject).onClick=basefunc.handler(self,self.DdzJiPaiQiCB) 
    EventTriggerListener.Get(self.playerself_operate_son.pay_record_btn.gameObject).onClick=basefunc.handler(self,self.DdzPayJiPaiQiCB) 
    EventTriggerListener.Get(self.menu_btn.gameObject).onClick=basefunc.handler(self,self.MenuCB) 
    EventTriggerListener.Get(self.menu_son.set_btn.gameObject).onClick=basefunc.handler(self,self.SetCB) 
    EventTriggerListener.Get(self.menu_son.close_btn.gameObject).onClick=basefunc.handler(self,self.CloseCB) 

    EventTriggerListener.Get(self.fuhuo_btn.gameObject).onClick=basefunc.handler(self,self.FuhuoCB) 
    EventTriggerListener.Get(self.close_fuhuo_btn.gameObject).onClick=basefunc.handler(self,self.CloseFuhuoCB) 

    EventTriggerListener.Get(self.award_confirm_btn.gameObject).onClick=basefunc.handler(self,self.AwardConfirmCB) 
    EventTriggerListener.Get(self.menu_son.help_btn.gameObject).onClick=basefunc.handler(self,self.HelpCB) 
end

function DdzMillionGamePanel:MyRefresh()
    if DdzMillionModel.data then
        local m_data=DdzMillionModel.data
        self.countdown=math.floor(m_data.countdown)
        
        if m_data.status==million_status.wait_table then
            self.ddz_million_pairdesk_ui.gameObject:SetActive(true)
            self:ShowOrHideDdzView(false)
            self.ddz_million_promoted_ui.gameObject:SetActive(false)
            self:ShowOrHideWarningView(false)
            self.cardsRemainUI[2].gameObject:SetActive(false)
            self.cardsRemainUI[3].gameObject:SetActive(false)
            
            SpineManager.RemoveAllDDZPlayerSpine()
        else
            self.ddz_million_pairdesk_ui.gameObject:SetActive(false)
            if m_data.status==macth_status.wait_p then
                self:ShowOrHideWarningView(false)
                self.cardsRemainUI[2].gameObject:SetActive(false)
                self.cardsRemainUI[3].gameObject:SetActive(false)
            end
            self:ShowOrHideDdzView(true)
            
            -- transform_seat(self,m_data.seat_num)
            --刷新警报
            self:RefreshRemainPaiWarningStatus()
            --刷新我的牌展示UI 及 操作
            self.DdzMillionPlayersActionManger:Refresh()
            --刷新托管
            self:RefreshAutoStatus()
            --刷新权限
            self:RefreshPermitStatus()
            --刷新操作展示UI
            self.DdzMillionActionUiManger:Refresh()
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
            self:RefreshWaitFuHuo()
            --记牌器
            self:RefreshDdzJiPaiQi()
            --安慰奖
            self:RefreshAward()
        end
    end
end

function DdzMillionGamePanel:RefreshDdzJiPaiQi()
    --自动显示记牌器
    self:AutoShowDdzJiPaiQiCB()
    if DdzMillionModel.data then
        local statistics = self.playerself_operate_son.statistics
        if DdzMillionModel.data then
            local jipaiqi = DdzMillionModel.data.jipaiqi
            if not jipaiqi then
                for i=0,statistics.transform.childCount - 1 do
                    local child = statistics:GetChild(i):GetComponent("Text")
                    child.text = "-"
                    child.color = self.colorGary
                end
            else
                for i=0,statistics.transform.childCount - 1 do
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

function DdzMillionGamePanel:AutoShowDdzJiPaiQiCB()
    if GameGlobalOnOff.JPQTool and GameItemModel.GetItemCount("jipaiqi") > 0 then
        local is_show = true
        if self.isShowStatistics ~= nil then is_show = self.isShowStatistics end
        self.playerself_operate_son.statistics.gameObject:SetActive(is_show)
    end
end
--记牌器
function DdzMillionGamePanel:DdzJiPaiQiCB()
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

function DdzMillionGamePanel:DdzPayJiPaiQiCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    PayPanel.Create(GOODS_TYPE.item, "normal",function ()
        self:RefreshDdzJiPaiQi()
    end,ITEM_TYPE.expression)
    self.playerself_operate_son.pay_record.gameObject:SetActive(false)
end

--菜单
function DdzMillionGamePanel:MenuCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local menu_bg = self.menu_son.menu_bg
    local b = not menu_bg.gameObject.activeSelf
    menu_bg.gameObject:SetActive(b)
    self.TopButtonImage.gameObject:SetActive(b)
end

--退出
function DdzMillionGamePanel:CloseCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    HintPanel.Create(1,"比赛中不能退出")
end

--退出
function DdzMillionGamePanel:HelpCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    DdzHelpPanel.Create("JD")
end

--设置
function DdzMillionGamePanel:SetCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
end

function DdzMillionGamePanel:RefreshRound()
    if DdzMillionModel.data then
        local round_info = DdzMillionModel.data.round_info
        local race = DdzMillionModel.data.race
        self.dizhu_card_son.cur_match_txt.gameObject:SetActive(false)
        self.dizhu_card_son.cur_base_score_txt.gameObject:SetActive(false)
        self.dizhu_card_son.cur_multiple_txt.gameObject:SetActive(false)
        if round_info then
            self.dizhu_card_son.cur_match_txt.text = round_info.rise_grades .."分晋级 第"..race .."副（共"..round_info.race_count.."副）"
            self.dizhu_card_son.cur_match_txt.gameObject:SetActive(true)
            --此轮的底分
            if round_info.init_stake then
                self.dizhu_card_son.cur_base_score_txt.text ="底分" .. round_info.init_stake
                self.dizhu_card_son.cur_base_score_txt.gameObject:SetActive(true)
            end
            --此轮的初始倍率
            if DdzMillionModel.data.my_rate then
                self.dizhu_card_son.cur_multiple_txt.text = DdzMillionModel.data.my_rate .. "倍"
                self.dizhu_card_son.cur_multiple_txt.gameObject:SetActive(true)
            end
        end
    end
end

function DdzMillionGamePanel:RefreshRate()
    self.cur_multiple_txt.gameObject:SetActive(false)
    if DdzMillionModel.data then
        local my_rate = DdzMillionModel.data.my_rate
        if  my_rate then
            self.cur_multiple_txt.gameObject:SetActive(true)
            self.cur_multiple_txt.text = my_rate .. "倍"
        end
    end
end

function  DdzMillionGamePanel:RefreshScore(p_seat)
    if DdzMillionModel.data then
        if p_seat then
            local player = self.playerInfoUI[p_seat]
            local grades
            if DdzMillionModel.data.players_info and DdzMillionModel.data.seatNum and DdzMillionModel.data.players_info[DdzMillionModel.data.seatNum[p_seat]] then
                grades=DdzMillionModel.data.players_info[DdzMillionModel.data.seatNum[p_seat]].grades
                if grades then
                    player.score_txt.text = grades
                end
            end
        else
            for p_seat=1,3 do
                local player = self.playerInfoUI[p_seat]
                 local grades
                if p_seat==1 then
                    grades=DdzMillionModel.data.grades
                else
                    grades=DdzMillionModel.data.players_info[DdzMillionModel.data.seatNum[p_seat]].grades
                end
                if grades then
                    player.score_txt.text = grades
                end
            end
        end
        
     end
end

function DdzMillionGamePanel:ShowOrHideWarningView(status)
    for i=1,3 do
        --刷新warning
        if self.warningUI[i] then
            --隐藏
            self.warningUI[i]:SetActive(false)
        end
    end
end

function DdzMillionGamePanel:ShowOrHideDdzView(status)
    self.ddz_million_dizhu_card_ui.gameObject:SetActive(status)
    self.menu_btn.gameObject:SetActive(status)
    self.ddz_million_playerright_info_ui.gameObject:SetActive(status)
    self.ddz_million_playerright_operate_ui.gameObject:SetActive(status)
    self.ddz_million_playerleft_info_ui.gameObject:SetActive(status)
    self.ddz_million_playerleft_operate_ui.gameObject:SetActive(status)
    self.ddz_million_playerself_info_ui.gameObject:SetActive(status)
    self.ddz_million_playerself_operate_ui.gameObject:SetActive(status)
end
function DdzMillionGamePanel:ShowOrHidePermitUI(status,people)    
    if people==2 then
        self.playerright_operate_son.wait_time.gameObject:SetActive(status)
    elseif people==3 then
        self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
    else
        self.playerself_operate_son.wait_time.gameObject:SetActive(status)
        if self.playerself_operate_son.yaobuqi.gameObject.activeSelf then
            if status == true then
                self.DdzMillionPlayersActionManger:ChangeClickStatus(1)
            else
                if not self.autoUI[1].activeSelf then
                    self.DdzMillionPlayersActionManger:ChangeClickStatus(0)
                end
            end
        end
        self.playerself_operate_son.yaobuqi.gameObject:SetActive(status)
        -- if not status then
        --     SpineManager.DaiJi(1)
        -- end
        self.playerself_operate_son.chupai.gameObject:SetActive(status)
        self.playerself_operate_son.jiaodizhu.gameObject:SetActive(status)
        self.playerself_operate_son.jiabei.gameObject:SetActive(status)
        if not people then
            self.playerright_operate_son.wait_time.gameObject:SetActive(status)
            self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
        end
    end    

end
function DdzMillionGamePanel:ShowOrHideActionUI(status,people)    
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

function DdzMillionGamePanel:MyExit()
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

    self.updateTimer:Stop()
    self.DdzMillionPlayersActionManger:MyExit()
    self.DdzMillionActionUiManger:MyExit()
    SpineManager.RemoveAllDDZPlayerSpine()
    DdzMillionLogic.clearViewMsgRegister(listerRegisterName)
    --closePanel(DdzMillionGamePanel.name)
    self.dzCardObj = nil
    self.cardObj = nil
end
function DdzMillionGamePanel:MyClose()
    self:MyExit()
    closePanel(DdzMillionGamePanel.name)
end


function DdzMillionGamePanel:RefreshAutoStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzMillionModel.data then
        local auto=DdzMillionModel.data.auto_status
        if auto and DdzMillionModel.data.seatNum then
            --刷新全部 
            if not pSeatNum then
                for i=1,3 do
                    if  auto[DdzMillionModel.data.seatNum[i]]==1 then
                        --显示
                        if i == 1 then
                            self.DdzMillionPlayersActionManger:ChangeClickStatus(1)
                        end
                        self.autoUI[i]:SetActive(true)
                    else
                        --隐藏
                        if i == 1 then
                            self.DdzMillionPlayersActionManger:ChangeClickStatus(0)
                        end
                        self.autoUI[i]:SetActive(false)
                    end
                end
            --刷新单个人
            else
                if auto[DdzMillionModel.data.seatNum[pSeatNum]]==1 then
                     --显示
                    if pSeatNum == 1 then
                        self.DdzMillionPlayersActionManger:ChangeClickStatus(1)
                    end
                    self.autoUI[pSeatNum]:SetActive(true)
                else
                    --隐藏
                    if pSeatNum == 1 then
                        self.DdzMillionPlayersActionManger:ChangeClickStatus(0)
                    end
                    self.autoUI[pSeatNum]:SetActive(false)
                end
            end
            
        end
    end
end
--刷新剩余的牌 和warning 
function DdzMillionGamePanel:RefreshRemainPaiWarningStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzMillionModel.data then
        local remain_pai_amount=DdzMillionModel.data.remain_pai_amount
        if remain_pai_amount and DdzMillionModel.data.seatNum then
            --刷新全部 
            if not pSeatNum then

                for i=1,3 do
                    --刷新warning
                    if self.warningUI[i] then
                        if  remain_pai_amount[DdzMillionModel.data.seatNum[i]]<3 then
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
                        self.playerOperateUI[i].remain_count_txt.text=remain_pai_amount[DdzMillionModel.data.seatNum[i]]
                    end

                end
            --刷新单个人
            else
                --刷新warning
                if self.warningUI[pSeatNum] then
                    if  remain_pai_amount[DdzMillionModel.data.seatNum[pSeatNum]]<3 then
                      --显示
                        self.warningUI[pSeatNum]:SetActive(true)
                    else
                        --隐藏
                        self.warningUI[pSeatNum]:SetActive(false)
                    end
                end

                --刷新牌的数量
                if self.cardsRemainUI[pSeatNum] then
                    self.playerOperateUI[pSeatNum].remain_count_txt.text=remain_pai_amount[DdzMillionModel.data.seatNum[pSeatNum]]
                end

            end
            
        end
    end
end
--带动画和音效刷新剩余的牌 和warning  
function DdzMillionGamePanel:RefreshRemainPaiWarningStatusWithAni(pSeatNum,act_type,pai_count)
    self:RefreshRemainPaiWarningStatus(pSeatNum)
    pai_count=pai_count or DdzMillionModel.data.remain_pai_amount[DdzMillionModel.data.seatNum[pSeatNum]]
    -- ###_test 根据牌的数量播放音效 动画等
    if (pai_count==2 or pai_count==1) and act_type~=0 then
         ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_card_leftwarning.audio_name)
        if pai_count==2 then
            local sound = "sod_game_card_left2"..AudioBySex(DdzMillionModel,DdzMillionModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        elseif pai_count==1 then
            local sound = "sod_game_card_left1"..AudioBySex(DdzMillionModel,DdzMillionModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        end
    end
end
function DdzMillionGamePanel:CanelAutoBtnCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if Network.SendRequest("dbwg_auto", {operate=0}) then
        self.autoUI[1]:SetActive(false)
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end
-- 刷新简易交互UI
function DdzMillionGamePanel:RefreshEasyChat()
    local dizhu = DdzMillionModel.data.dizhu
    local b = true
    if dizhu and dizhu > 0 then
        b = false
    end
    for i=1,3 do
        self.EasyButton[i].gameObject:SetActive(b)
        self.HeroEasyButton[i].gameObject:SetActive(not b)
    end
end
function DdzMillionGamePanel:RefreshPlayerInfo(pSeatNum)
    if DdzMillionModel.data then
        self:RefreshEasyChat()
        local dizhu = DdzMillionModel.data.dizhu
        local playerInfo=DdzMillionModel.data.players_info
        local RefreshPlayerAllInfo=function (pSeatNum)
            local info = playerInfo[DdzMillionModel.data.seatNum[pSeatNum]]
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
                player.name_txt.text = info.name
            else
                self:ShowOrHideCustHeadIcon(true,pSeatNum)
                self:ShowOrHideHeadInfo(false,pSeatNum)
                self:ShowOrHidePlayerInfo(false,pSeatNum)
            end
        end

        local RefreshPlayerTextInfo=function (pSeatNum)
            local info = playerInfo[DdzMillionModel.data.seatNum[pSeatNum]]
            local player = self.playerInfoUI[pSeatNum]
            if info then
                local player = self.playerInfoUI[pSeatNum]
                self:RefreshScore(pSeatNum)
                player.name_txt.text = info.name
                self:RefreshScore(pSeatNum)
            else
                self:ShowOrHidePlayerInfo(false,pSeatNum)
            end
        end
       
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
                if DdzMillionModel.data.seatNum[i] == dizhu then
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
-- local function AddClock(isNeedS,isNeedVoice,c)
--     local clock={}
--     clock.isNeedS
--     clock.isNeedVoice
    

-- end

function DdzMillionGamePanel:RefreshPermitStatus()
    --隐藏所有权限
    self:ShowOrHidePermitUI(false) 
    if DdzMillionModel.data then
        local data=DdzMillionModel.data
        local status=DdzMillionModel.data.status
        local cur_p=DdzMillionModel.data.cur_p
        if (status==million_status.jdz or status==million_status.jiabei or status==million_status.cp ) and  cur_p then
            if cur_p>0 and cur_p<4 then
                --我自己
                if cur_p==data.seat_num then
                    local permitData=DdzMillionModel.getMyPermitData()
                    if permitData then
                        self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                        if permitData.type==million_status.jdz then
                            --将背景颜色还原
                            change_btn_image(self.playerself_operate_son.jdz_1_btn,"ddz_btn_3",true)
                            change_btn_image(self.playerself_operate_son.jdz_2_btn,"ddz_btn_3",true)
                            change_btn_image(self.playerself_operate_son.jdz_3_btn,"ddz_btn_3",true)
                            self.playerself_operate_son.jiaodizhu.gameObject:SetActive(true)
                            self:RefreshClockPos(self.playerself_operate_son.dizhu_time_pos)

                            --根据数据将背景颜色变灰
                            if permitData.jdz_min==3 then
                                change_btn_image(self.playerself_operate_son.jdz_1_btn,"ddz_btn_2",false)
                                change_btn_image(self.playerself_operate_son.jdz_2_btn,"ddz_btn_2",false)
                            elseif permitData.jdz_min==2 then
                                change_btn_image(self.playerself_operate_son.jdz_1_btn,"ddz_btn_2",false)
                            end

                        elseif  permitData.jiabei==million_status.jiabei then
                            self.playerself_operate_son.jiabei.gameObject:SetActive(true)
                            self:RefreshClockPos(self.playerself_operate_son.jiabei_time_pos)
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
                                self.DdzMillionPlayersActionManger:ChangeClickStatus(1)
                                self:RefreshClockPos(self.playerself_operate_son.yaobuqi_time_pos)
                            end

                        end    

                    end
                --其他人    
                elseif DdzMillionModel.data.s2cSeatNum then
                    if DdzMillionModel.data.s2cSeatNum[cur_p]==2 then
                        self:ShowOrHidePermitUI(true,2)
                    elseif DdzMillionModel.data.s2cSeatNum[cur_p]==3 then
                        self:ShowOrHidePermitUI(true,3)
                    end
                end
            --teshu
            else
                
            end
            --给闹钟赋予初始值
            for i=1,3 do
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

function DdzMillionGamePanel:RefreshClockPos(parent)
    self.playerself_operate_son.wait_time.transform.parent = parent.transform
    self.playerself_operate_son.wait_time.transform.localPosition = Vector3.zero
end


--刷新结算
function DdzMillionGamePanel:RefreshSettlement()
    if DdzMillionModel.data then
        local mData = DdzMillionModel.data
        local settlement_info = DdzMillionModel.data.dbwg_ddz_settlement_info
        if settlement_info then
            --玩家剩余的牌
            if settlement_info.remain_pai then
                for k,v in pairs(settlement_info.remain_pai) do
                    --其他玩家的牌
                    local p_seat = v.p
                    local pai_list = v.pai
                    local cSeatNum = DdzMillionModel.data.s2cSeatNum[p_seat]
                    if cSeatNum~=1 then 
                        self.DdzMillionActionUiManger:RefreshAction(cSeatNum,{type=-1,cp_list=pai_list})
                    end    
                end
            end
        end
    end
end

--刷新晋级
function DdzMillionGamePanel:RefreshPromoted()
    if DdzMillionModel.data then
        --玩家在配桌界面直接进入游戏需要隐藏
        self.ddz_match_pairdesk_ui.gameObject:SetActive(false)
        self.ddz_million_promoted_ui.gameObject:SetActive(false)
        self:RefreshWaitFuHuo()
        local myData = DdzMillionModel.data
        if myData.status==million_status.promoted then
            self.promoted_son.promoted_img.gameObject:SetActive(true)
            self.promoted_son.promoted_match.gameObject:SetActive(false)

            if myData.round and myData.match_info then
                --排名
                self.promoted_son.rank_txt.text = myData.round.. "/"
                self.promoted_son.rank_base_txt.text = myData.match_info.total_round
            else
                self.promoted_son.rank_txt.text = myData.match_info.total_round .."/"
                self.promoted_son.rank_base_txt.text = myData.match_info.total_round
            end
            self.ddz_million_promoted_ui.gameObject:SetActive(true)
        end
    end
end

--复活
function DdzMillionGamePanel:FuhuoCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if Network.SendRequest("dbwg_fuhuo_game",{fuhuo = 1}) then
        self.ddz_million_wait_ui.gameObject:SetActive(false)
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end

--取消复活
function DdzMillionGamePanel:CloseFuhuoCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if Network.SendRequest("dbwg_fuhuo_game",{fuhuo = 0}) then
        self.ddz_million_wait_ui.gameObject:SetActive(false)
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end

function DdzMillionGamePanel:RefreshWaitFuHuoCountdown()
    self.wait_countdown_txt.text = self.countdown
end

--刷新复活
function DdzMillionGamePanel:RefreshWaitFuHuo()
    if DdzMillionModel.data then
        self.ddz_million_wait_ui.gameObject:SetActive(false)
        local myData = DdzMillionModel.data
        if myData.status==million_status.wait_fuhuo then
            if myData.countdown then
                self.countdown = myData.countdown
            end
            if myData.round_info and myData.match_info then
                
                self.wait_round_txt.text = "当前第" .. myData.round_info.round .. "/" .. myData.match_info.total_round
            end
            if myData.match_info.bonus then
                self.gold_txt.text = myData.match_info.bonus
            end
            --###_test 消耗复活卷读表
            self.fuhuo_num_txt.text = "复活消耗 X1 复活卷"
            self.ddz_million_wait_ui.gameObject:SetActive(true)
        end
    end
end

--刷新地主UI显示
function DdzMillionGamePanel:RefreshDiZhuAndMultipleStatus()
    if DdzMillionModel.data then
        local myData = DdzMillionModel.data
        if not myData.dz_pai then
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(true)
            self.dizhu_card_son.dzcards.gameObject:SetActive(false)
        else
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(false)
            self.dizhu_card_son.dzcards.gameObject:SetActive(true)
            destroyChildren(self.dizhu_card_son.dzcards.transform)
            for k,v in pairs(myData.dz_pai) do
                DdzDzCard.New(self.dzCardObj, self.dizhu_card_son.dzcards.transform,v,v,0)
            end
        end
    end
end


function DdzMillionGamePanel:ShowOrHideCustHeadIcon(status,seatNum)
    -- if not seatNum then
    --     for i=1,3 do
    --         self.playerInfoUI[i].cust_head_icon_img.gameObject:SetActive(status)
    --     end
    -- else
    --     self.playerInfoUI[seatNum].cust_head_icon_img.gameObject:SetActive(status)
    -- end
end

function DdzMillionGamePanel:ShowOrHideHeadInfo(status,seatNum)
    if DdzMillionModel.data then
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

function DdzMillionGamePanel:ShowOrHidePlayerInfo(status,seatNum)
    if DdzMillionModel.data then
        if not seatNum then
            for i=1,3 do
                self.playerInfoUI[i].info.gameObject:SetActive(status)
            end
        else
            self.playerInfoUI[seatNum].info.gameObject:SetActive(status)
        end
    end
end

function DdzMillionGamePanel:MakeLister()
	lister={} 
	lister["dbwgModel_dbwg_enter_room_msg"]=basefunc.handler(self,self.dbwg_enter_room_msg)
    lister["dbwgModel_dbwg_join_msg"]=basefunc.handler(self,self.dbwg_join_msg) 
    lister["dbwgModel_dbwg_pai_msg"]=basefunc.handler(self,self.dbwg_pai_msg)
    lister["dbwgModel_dbwg_action_msg"]=basefunc.handler(self,self.dbwg_action_msg) 
    lister["dbwgModel_dbwg_permit_msg"]=basefunc.handler(self,self.dbwg_permit_msg)
    lister["dbwgModel_dbwg_dizhu_msg"]=basefunc.handler(self,self.dbwg_dizhu_msg) 
    lister["dbwgModel_dbwg_auto_msg"]=basefunc.handler(self,self.dbwg_auto_msg) 
    lister["dbwgModel_dbwg_ddz_settlement_msg"]=basefunc.handler(self,self.dbwg_ddz_settlement_msg) 
    lister["dbwgModel_dbwg_wait_fuhuo_msg"]=basefunc.handler(self,self.dbwg_wait_fuhuo_msg) 
    lister["dbwgModel_dbwg_promoted_msg"]=basefunc.handler(self,self.dbwg_promoted_msg) 
    lister["dbwgModel_dbwg_new_game_msg"]=basefunc.handler(self,self.dbwg_new_game_msg)
    lister["dbwgModel_dbwg_start_again_msg"]=basefunc.handler(self,self.dbwg_start_again_msg)
    lister["dbwgModel_dbwg_grades_change_msg"]=basefunc.handler(self,self.dbwg_grades_change_msg) 
    lister["dbwgModel_dbwg_consolation_ward_msg"]=basefunc.handler(self,self.dbwg_consolation_ward_msg)
    lister["dbwgModel_dbwg_jiabeifinshani_msg"]=basefunc.handler(self,self.dbwg_jiabeifinshani_msg) 
end

function DdzMillionGamePanel:dbwg_enter_room_msg()
    self:MyRefresh()
end

function DdzMillionGamePanel:dbwg_join_msg(seat_num)

    self:RefreshPlayerInfo(DdzMillionModel.data.s2cSeatNum[seat_num])

end

function DdzMillionGamePanel:dbwg_pai_msg()
    self.DdzMillionPlayersActionManger:Fapai(DdzMillionModel.data.my_pai_list)
    self:RefreshRemainPaiWarningStatus()
end


function DdzMillionGamePanel:dbwg_action_msg()
    local act=DdzMillionModel.data.action_list[#DdzMillionModel.data.action_list]
    self.DdzMillionPlayersActionManger:DealAction(DdzMillionModel.data.s2cSeatNum[act.p],act)
    self:RefreshDdzJiPaiQi()
end

function DdzMillionGamePanel:dbwg_jiabeifinshani_msg()
    DDZAnimation.ChangeRate(self.cur_multiple_txt,DdzMillionModel.data.my_rate)
end

--自动出最后一手牌
local function auto_chu_last_pai(self)
    local m_data=DdzMillionModel.data
    if m_data.status==million_status.cp then
        local pos=m_data.s2cSeatNum[m_data.cur_p]
        if pos==1 then
            local _ok=nDdzFunc.check_is_only_last_pai(m_data.action_list,m_data.my_pai_list)
            if _ok then
                self.last_pai_auto_countdown=1
                self.last_pai_auto_cb=function ()
                    self.last_pai_auto_cb=nil
                    self.last_pai_auto_countdown=nil
                    local manager=self.DdzMillionPlayersActionManger
                    --将所有的牌弹起
                    for no,v in pairs(manager.my_pai_hash) do
                        v:ChangePosStatus(1)
                    end
                    --出牌btn
                    manager:ChupaiBtnCB()
                end
            end
        end
    end

end
function DdzMillionGamePanel:dbwg_permit_msg()
    self.countdown=math.floor(DdzMillionModel.data.countdown)
    self:ShowOrHideActionUI(false,DdzMillionModel.data.s2cSeatNum[DdzMillionModel.data.cur_p])
    self:RefreshPermitStatus()
    self.DdzMillionActionUiManger:changeActionUIShowByStatus()
    auto_chu_last_pai(self)
end
function DdzMillionGamePanel:dbwg_dizhu_msg()
    if DdzMillionModel.data.dizhu==DdzMillionModel.data.seat_num then
        self.DdzMillionPlayersActionManger:AddPai(DdzMillionModel.data.dz_pai)
    end
    self:RefreshDiZhuAndMultipleStatus()
    self:RefreshRate()
    self:RefreshPlayerInfo()
    self:RefreshDdzJiPaiQi()
    --加倍动画
    if DdzMillionModel.data then
        if DdzMillionModel.data.my_rate and DdzMillionModel.data.round_info.init_rate then
            DDZAnimation.ChangeRate(self.cur_multiple_txt,DdzMillionModel.data.my_rate)
        end
    end
end

function DdzMillionGamePanel:dbwg_auto_msg(player)
    self:RefreshAutoStatus(DdzMillionModel.data.s2cSeatNum[player])
end
function DdzMillionGamePanel:dbwg_ddz_settlement_msg()
    self:RefreshSettlement()

    local settlement_info = DdzMillionModel.data.dbwg_ddz_settlement_info
    if settlement_info then
        --得分 动画
        if settlement_info.p_scores then
            for p_seat,score in pairs(settlement_info.p_scores) do
                local cSeat = DdzMillionModel.data.s2cSeatNum[p_seat]
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
                if DdzMillionModel.data then
                    if DdzMillionModel.data.my_rate and DdzMillionModel.data.round_info.init_rate then
                        DDZAnimation.ChangeRate(self.cur_multiple_txt,DdzMillionModel.data.my_rate)
                    end
                end
            end
        end
    end
    self:RefreshScore()
end

function DdzMillionGamePanel:dbwg_wait_fuhuo_msg()
    self:RefreshWaitFuHuo()
end

function DdzMillionGamePanel:dbwg_promoted_msg()
    self:RefreshPromoted()
end

function DdzMillionGamePanel:dbwg_new_game_msg()
    self:MyRefresh()
    --新的局数
    if DdzMillionModel.data then
        local curRace = DdzMillionModel.data.race
        if curRace then
            DDZAnimation.CurRace(curRace,self.start_again_cards_pos)
        end
    end
end
function DdzMillionGamePanel:dbwg_start_again_msg()
    self:MyRefresh()
    --重新发牌
    DDZAnimation.StartAgainCard(self.start_again_cards_pos)
end
function DdzMillionGamePanel:dbwg_grades_change_msg()
    self:RefreshScore(1)
end

--安慰奖
function DdzMillionGamePanel:dbwg_consolation_ward_msg()
    self:RefreshAward()
end

function DdzMillionGamePanel:RefreshAward()
    if DdzMillionModel.data then
        self.ddz_millio_award_ui.gameObject:SetActive(false)
        local final_result = DdzMillionModel.data.dbwg_final_result
        local matchInfo = DdzMillionModel.data.match_info
        if final_result then
            local ItemAward = GetPrefab("ItemAward")
            if final_result.is_win == 0  and final_result.reward then
                for k,v in pairs(final_result.reward) do
                    local go = GameObject.Instantiate(ItemAward,self.award_root)
                    local award_type_img = go.transform:Find("@award_type_img").transform:GetComponent("Image")
                    award_type_img.sprite = GetTexture("com_icon_" .. v.asset_type)
                    award_type_img:SetNativeSize()
                    go.transform:Find("@award_num_txt").transform:GetComponent("Text").text ="X" .. v.value
                end
                self.ddz_millio_award_ui.gameObject:SetActive(true)
            end
            if matchInfo.bonus then
				self.gold_txt.text = "￥" .. math.floor(matchInfo.bonus / 100)
			else
				self.gold_txt.text = "￥0"
			end
        end
    end
end

--确认安慰奖
function DdzMillionGamePanel:AwardConfirmCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if Network.SendRequest("dbwg_quit_game") then
		DdzMillionModel.ClearMatchData()
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end



