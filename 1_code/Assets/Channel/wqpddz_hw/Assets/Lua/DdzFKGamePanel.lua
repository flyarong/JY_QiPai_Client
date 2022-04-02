local basefunc = require "Game.Common.basefunc"
local nor_ddz_base_lib=require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"
--数据结构
--说明：位置坐标系  我的位置永远为1 逆时针 2 3，

DdzFKGamePanel = basefunc.class()

DdzFKGamePanel.name = "DdzFKGamePanel"

local lister
local listerRegisterName="ddzLzGameListerRegister"
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
function DdzFKGamePanel.Create()
    instance=DdzFKGamePanel.New()
    instance.dzCardObj = GetPrefab("DdzDzCard")
    instance.cardObj = GetPrefab("DdzCard")
    instance.lzSelectCardObj = GetPrefab("DdzFKSelectCard")
    return createPanel(instance,DdzFKGamePanel.name)
end
function DdzFKGamePanel.Bind()
    local _in=instance
    instance=nil
    return _in
end

function DdzFKGamePanel:Awake()
    ExtendSoundManager.PlaySceneBGM(audio_config.ddz.ddz_bgm_game.audio_name)
    LuaHelper.GeneratingVar(self.transform,  self)
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
    self.select_laizi_son = {}
    LuaHelper.GeneratingVar(self.ddz_select_laizi_ui.transform, self.select_laizi_son)

    local tran = self.transform
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
        GameSpeedyPanel.Show()
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

    self.RoomIDText = self.transform:Find("@ddz_match_dizhu_card_ui/RoomIDText"):GetComponent("Text")
    self.DdzTypeText = self.transform:Find("@ddz_match_dizhu_card_ui/DdzTypeText"):GetComponent("Text")
    self.RateNumText = self.transform:Find("@ddz_match_dizhu_card_ui/RateNumText"):GetComponent("Text")
    self.RuleText = self.transform:Find("RuleRect/BG/RuleText"):GetComponent("Text")

    self.BeginButton = self.transform:Find("BeginButton")
    self.ShareButton = self.transform:Find("ShareButton")
    self.CopyButton = self.transform:Find("CopyButton")
    EventTriggerListener.Get(self.BeginButton.gameObject).onClick = basefunc.handler(self, self.OnBeginClick)
    EventTriggerListener.Get(self.ShareButton.gameObject).onClick = basefunc.handler(self, self.OnShareClick)
    EventTriggerListener.Get(self.CopyButton.gameObject).onClick = basefunc.handler(self, self.OnCopyClick)

    -- 语音聊天按钮
    self.VoiceButton = self.transform:Find("VoiceButton")
    EventTriggerListener.Get(self.VoiceButton.gameObject).onDown = basefunc.handler(self, self.OnVoiceDown)
    EventTriggerListener.Get(self.VoiceButton.gameObject).onUp = basefunc.handler(self, self.OnVoiceUp)

    self.GPSButton = self.transform:Find("GPSButton"):GetComponent("Button")
    self.GPSHintImg = self.transform:Find("GPSButton/GPSHintImg"):GetComponent("Image")
    EventTriggerListener.Get(self.GPSButton.gameObject).onClick = basefunc.handler(self, self.OnClickGPSButton)

    self.MenuButton = tran:Find("MenuButton"):GetComponent("Button")
    self.MenuBG = tran:Find("MenuButton/MenuBG")
    self.CloseImage = tran:Find("MenuButton/MenuBG/CloseButton"):GetComponent("Image")
    self.CloseButton = tran:Find("MenuButton/MenuBG/CloseButton"):GetComponent("Button")
    self.SetButton = tran:Find("MenuButton/MenuBG/SetButton"):GetComponent("Button")
    self.HelpButton = tran:Find("MenuButton/MenuBG/HelpButton"):GetComponent("Button")
    self.MenuButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            local b = not self.MenuBG.gameObject.activeSelf
            self.MenuBG.gameObject:SetActive(b)
            self.TopButtonImage.gameObject:SetActive(b)
        end
    )
    self.HelpButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            DdzHelpPanel.Create("JD")
        end
    )

    self.CloseButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            if self:IsJSFun() then
                local m_data = DdzFKModel.data
                -- 游戏中要发起投票
                if m_data and m_data.model_status == DdzFKModel.Model_Status.gaming then
                    local hint =
                        HintPanel.Create(
                        2,
                        "是否要申请解散房间",
                        function()
                            --发起申请解散房间
                            Network.SendRequest("begin_vote_cancel_room", nil, function (data)
                                if data.result == 0 then
                                else
                                    HintPanel.ErrorMsg(data.result)
                                end
                            end)
                        end
                    )
                    hint:SetSmallHint("提示：游戏中途解散所有房卡不予退回")
                    hint:SetButtonText("否", "是")
                else
                    local hint =
                        HintPanel.Create(
                        2,
                        "是否要申请解散房间",
                        function()
                            --房主未开始解散游戏
                            self:OnExitClick()
                        end
                    )
                end
            else
                self:OnExitClick()
            end
        end
    )
    self.SetButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            SettingPanel.Show()
        end
    )

    self.updateTimer = Timer.New(basefunc.handler(self,self.update_callback), 1, -1, true)
    self.updateTimer:Start()
    self:MyInit()
    self.TimeCallDict = {}

    self.selectLaiziBtnTable = {}
    self:MyRefresh()
end
function DdzFKGamePanel:OnEasyClick(obj)
    local uipos = tonumber(string.sub(obj.name,-1,-1))
    local data = DdzFKModel.GetPosToPlayer(uipos)
    if data and data.base then
        PlayerInfoPanel.Create(data.base, uipos)
    else
        dump(data, "<color=red>玩家没有入座</color>")
    end
end
function DdzFKGamePanel:OnExitClick()
    Network.SendRequest(
        "friendgame_exit_room",
        nil,
        "请求退出",
        function(data)
            if data.result == 0 then
                --清除数据
                DdzFKModel.ClearMatchData()
                MainLogic.ExitGame()
                MainLogic.GotoScene("game_Hall")
            else
                HintPanel.ErrorMsg(data.result)
            end
        end
    )
end
function DdzFKGamePanel:OnBeginClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if DdzFKModel.data.player_count == DdzFKModel.GetCurrPlayerCount() then
        Network.SendRequest("friendgame_begin_game", nil, "请求开始游戏")
    else
        HintPanel.Create(1, "人数不足，不能开始游戏")
    end
end
function DdzFKGamePanel:OnCopyClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    LittleTips.Create("已复制微信号请前往微信进行添加")
    UniClipboard.SetText(DdzFKModel.data.friendgame_room_no)

    -- Network.SendRequest("query_gps_info",nil,"xx",function (data)
    --     dump(data,"xxx*****-------")
    -- end)
end
function DdzFKGamePanel:OnShareClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    -- local title
    -- local description
    -- local strOff = "false"
    -- local url
    -- description = "AA付费，" .. self.RuleText.text
    -- title = "斗地主 房号：" .. DdzFKModel.data.friendgame_room_no

    --url = "http://jingyu://www.jyhd919.cn?room_no=" .. DdzFKModel.data.friendgame_room_no
    --url = "http://192.168.0.207:6688/files/JY/Apk/html.html"
    -- url =
    --     "http://es-caller.jyhd919.cn/Share.app.do?urlScheme=jingyu://www.jyhd919.cn?room_no/" ..
    --     DdzFKModel.data.friendgame_room_no

    -- 分享链接
end

function DdzFKGamePanel:OnClickGPSButton()
    DdzFKModel.RefreshGPS(true)
end
function DdzFKGamePanel:OnVoiceDown()
    self.begPos = UnityEngine.Input.mousePosition
    GameVoicePanel.RecordVoice()
end
function DdzFKGamePanel:OnVoiceUp()
    local pos = UnityEngine.Input.mousePosition
    local x = pos.x - self.begPos.x
    local y = pos.y - self.begPos.y
    print("<color=red>语音 滑动距离 x = " .. x .. "  y = " .. y .. "</color>")
    if y < 20 then
        GameVoicePanel.FinishVoice()
    else
        GameVoicePanel.CancelVoice()
    end
end


function DdzFKGamePanel:SetHideMenu()
    self.MenuBG.gameObject:SetActive(false)
    self.TopButtonImage.gameObject:SetActive(false)
end
function DdzFKGamePanel:update_callback()
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

function DdzFKGamePanel:RefreshClock()
    local flag=nil
    for i=1,#self.timerUI,1 do
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

function DdzFKGamePanel:Start()
    -- self:MyRefresh()
end

function DdzFKGamePanel:MyInit()
    self.DdzFKActionUiManger=DdzFKActionUiManger.Create(self,self.playerOperateUI,self.dizhu_card_son)
    self.DdzFKPlayersActionManger=DdzFKPlayersActionManger.Create(self)
    self:MakeLister()
    DdzFKLogic.setViewMsgRegister(lister,listerRegisterName)
    self.behaviour:AddClick(self.back_btn.gameObject, DdzFKGamePanel.OnClickCloseSignup, self)
    self.behaviour:AddClick(self.select_laizi_son.select_laizi_btn_bg.gameObject, DdzFKGamePanel.OnClickCloseSelectLaizi, self);

    EventTriggerListener.Get(self.change_cards_pos_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.ChangeCardsPosBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_bg_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.not_play_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.BuchupaiBtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.no_play_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.BuchupaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.out_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.ChupaiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.hint_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.HintBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.JiabeiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.jiabei_not_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.BujiabeiBtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.jdz_1_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.Jdz1BtnCB)  
    EventTriggerListener.Get(self.playerself_operate_son.jdz_2_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.Jdz2BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_3_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.Jdz3BtnCB)
    EventTriggerListener.Get(self.playerself_operate_son.jdz_not_btn.gameObject).onClick=basefunc.handler(self.DdzFKPlayersActionManger,self.DdzFKPlayersActionManger.Bujdz1BtnCB)  

    EventTriggerListener.Get(self.playerself_operate_son.close_auto_btn.gameObject).onClick=basefunc.handler(self,self.CanelAutoBtnCB) 
    EventTriggerListener.Get(self.playerself_operate_son.record_btn.gameObject).onClick=basefunc.handler(self,self.DdzJiPaiQiCB) 
    EventTriggerListener.Get(self.playerself_operate_son.pay_record_btn.gameObject).onClick=basefunc.handler(self,self.DdzPayJiPaiQiCB) 
end

local function BackBtnCountdown(self)   
    if self.countdown and self.countdown > 0 then
        self.back_time_txt.text = self.countdown .. "秒后可返回"
    else
        self:RefreshBackBtn()
    end
end
function DdzFKGamePanel:RefreshBackBtn()
    local m_data = DdzFKModel.data
    self.offback.gameObject:SetActive(true) 
    if m_data and m_data.status == DdzFKModel.Status.wait_table then
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
function DdzFKGamePanel:OnClickCloseSignup()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Network.SendRequest("nor_ddz_nor_cancel_signup",{})
end

function DdzFKGamePanel:MyRefresh()
    if DdzFKModel.data then
        local m_data=DdzFKModel.data
        if m_data.countdown then
            self.countdown=math.floor(m_data.countdown)
        end
        self:RefreshCenter()
        self:RefreshMenu()
        self:RefreshRoomDissolveStatus()
        if m_data.model_status == DdzFKModel.Model_Status.wait_begin then
            self:ShowOrHideDdzView(true)
            self:RefreshBackBtn()
            self:ShowOrHideWarningView(false)
            self:RefreshPlayerInfo()
            SpineManager.RemoveAllDDZPlayerSpine()
        else
            if m_data.status == DdzFKModel.Status.ready then
                self:ShowOrHideWarningView(false)
                self.cardsRemainUI[2].gameObject:SetActive(false)
                self.cardsRemainUI[3].gameObject:SetActive(false)
                SpineManager.RemoveAllDDZPlayerSpine()
            end
            self:ShowOrHideDdzView(true)
            -- transform_seat(self,m_data.seat_num)
            --刷新警报
            self:RefreshRemainPaiWarningStatus()
            --刷新我的牌展示UI 及 操作
            self.DdzFKPlayersActionManger:Refresh()
            --刷新托管
            self:RefreshAutoStatus()
            --刷新权限
            self:RefreshPermitStatus()
            --刷新操作展示UI
            self.DdzFKActionUiManger:Refresh()
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
            self:RefreshVoteStatus()
        end
    end
end


-- 是否是房主或者游戏中
function DdzFKGamePanel:IsJSFun()
    local m_data = DdzFKModel.data
    if
        m_data and m_data.playerInfo and m_data.playerInfo[m_data.seat_num] and
            (DdzFKModel.IsFZ(m_data.seat_num) or m_data.model_status == DdzFKModel.Model_Status.gaming)
     then
        return true
    end
end
-- 刷新游戏左上角UI 包括顶部规则说明
function DdzFKGamePanel:RefreshMenu()
    if self:IsJSFun() then
        self.CloseImage.sprite = GetTexture("com_btn_back3")
    else
        self.CloseImage.sprite = GetTexture("com_btn_back")
    end
    local m_data = DdzFKModel.data
    if m_data and m_data.ori_game_cfg then
        local list = {}
        for k, v in ipairs(m_data.ori_game_cfg) do
            local d = {}
            d.key = v.option
            d.sort = RoomCardModel.UIConfig.ruleNameMap[v.option].sort
            list[#list + 1] = d
        end
        list = MathExtend.SortList(list, "sort", true)
        local ss = ""
        for k, v in ipairs(list) do
            ss = ss .. " " .. RoomCardModel.UIConfig.ruleNameMap[v.key].name
        end
        self.RuleText.text = ss
    else
        self.RuleText.text = "游戏规则显示"
    end
end
-- 刷新中间区域(方位)
function DdzFKGamePanel:RefreshCenter()
    local data = DdzFKModel.data
    if data then
        if data.model_status == DdzFKModel.Model_Status.wait_begin then
            if GameGlobalOnOff.InviteFriends then
                self.ShareButton.gameObject:SetActive(true)
                if not DdzFKModel.IsFZ(data.seat_num) then
                    self.ShareButton.transform.localPosition = Vector3.New(0,self.ShareButton.transform.localPosition.y, 0)
                end
            else
                self.ShareButton.gameObject:SetActive(false)
            end
        else
            self.ShareButton.gameObject:SetActive(false)
        end

        if data.model_status == DdzFKModel.Model_Status.wait_begin and DdzFKModel.IsFZ(data.seat_num) then
            self.BeginButton.gameObject:SetActive(true)
            self.CopyButton.gameObject:SetActive(true)
            if not GameGlobalOnOff.InviteFriends then
                self.CopyButton.transform.localPosition = Vector3.New(0,self.CopyButton.transform.localPosition.y,0)
            end
        else
            self.BeginButton.gameObject:SetActive(false)
            self.CopyButton.gameObject:SetActive(false)
        end
        self.CopyButton.gameObject:SetActive(false)
        if data.init_stake then
            self.dizhu_card_son.cur_base_score_txt.text = "底分：" .. data.init_stake
        else
            self.dizhu_card_son.cur_base_score_txt.text = "底分：--"
        end

        if data.friendgame_room_no then
            self.RoomIDText.text = "房间号：" .. data.friendgame_room_no
        else
            self.RoomIDText.text = ""
        end

        if data.game_type then
            local typeStr = ""
            if data.game_type == "nor_ddz_nor" then
                typeStr = "经典斗地主"
            elseif data.game_type == "nor_ddz_ty" then
                typeStr = "听用斗地主"
            elseif data.game_type == "nor_ddz_lz" then
                typeStr = "癞子斗地主"
            end
            self.DdzTypeText.text = typeStr
        else
            self.DdzTypeText.text = ""
        end
    end
    self:SetRate()
end
function DdzFKGamePanel:SetRate()
    if DdzFKModel.data.cur_race and DdzFKModel.data.race_count then
        self.RateNumText.text = "第 " .. DdzFKModel.data.cur_race .. "/" .. DdzFKModel.data.race_count .. " 局"
    else
        self.RateNumText.text = "第 -/- 局"
    end
end


function DdzFKGamePanel:RefreshDdzJiPaiQi()
    --自动显示记牌器
    self:AutoShowDdzJiPaiQiCB()
    if DdzFKModel.data then
        local m_data=DdzFKModel.data
        local statistics = self.playerself_operate_son.statistics

        local jipaiqi = m_data.jipaiqi
        if not jipaiqi then
            for i=0,statistics.transform.childCount - 1 do
                local child = statistics:GetChild(i)
                local childText = child:GetComponent("Text")
                childText.text = "-"
                childText.color = Color.New(194 / 255, 171 / 255, 160 / 255, 255 / 255)
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

        self.playerself_operate_son.record_btn.gameObject:SetActive(GameGlobalOnOff.JPQTool)
    end
end
function DdzFKGamePanel:AutoShowDdzJiPaiQiCB()
    if GameGlobalOnOff.JPQTool and GameItemModel.GetItemCount("jipaiqi") > 0 then
        local is_show = true
        if self.isShowStatistics ~= nil then is_show = self.isShowStatistics end
        self.playerself_operate_son.statistics.gameObject:SetActive(is_show)
    end
end
--记牌器
function DdzFKGamePanel:DdzJiPaiQiCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if GameItemModel.GetItemCount("jipaiqi") > 0 then
        local statistics = self.playerself_operate_son.statistics
        local laizi_icon = self.playerself_operate_son.laizi
        laizi_icon.gameObject:SetActive(not statistics.gameObject.activeSelf)
        self.isShowStatistics = not statistics.gameObject.activeSelf
        statistics.gameObject:SetActive(self.isShowStatistics)
        self:RefreshDdzJiPaiQi()
    else
        local pay_record = self.playerself_operate_son.pay_record
        pay_record.gameObject:SetActive(not pay_record.gameObject.activeSelf)
    end   
end

function DdzFKGamePanel:DdzPayJiPaiQiCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    PayPanel.Create(GOODS_TYPE.item, "normal",function ()
        self:RefreshDdzJiPaiQi()
    end,ITEM_TYPE.expression)
    self.playerself_operate_son.pay_record.gameObject:SetActive(false)
end

-- 刷新游戏结算界面
--todo
function DdzFKGamePanel:RefreshClearing()
    if DdzFKModel.data.status == DdzFKModel.Status.settlement and DdzFKModel.data.settlement_info then
        DdzFKClearing.Create()
    else
         DdzFKClearing.Close()
    end
    self:RefreshGameOver()
end
function DdzFKGamePanel:RefreshRate()
    self.cur_multiple_txt.gameObject:SetActive(false)
    if DdzFKModel.data then
        local my_rate = DdzFKModel.data.my_rate
        if  my_rate then
            self.cur_multiple_txt.gameObject:SetActive(true)
            self.cur_multiple_txt.text = my_rate .. "倍"
        end
    end
end

function  DdzFKGamePanel:RefreshScore(p_seat)
    if DdzFKModel.data then
    	local m_data = DdzFKModel.data
        if p_seat then
            local player = self.playerInfoUI[p_seat]
            local grades
            if p_seat==1 then
                grades=m_data.grades
            else
                grades=m_data.playerInfo[DdzFKModel.data.seatNum[p_seat]].base.grades
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
                    grades=m_data.playerInfo[DdzFKModel.data.seatNum[p_seat]].base.grades
                end
                if grades then
                    player.score_txt.text = grades
                end
            end
        end
        
     end
end

function DdzFKGamePanel:ShowOrHideWarningView(status)
    for i=1,3 do
        --刷新warning
        if self.warningUI[i] then
            --隐藏
            self.warningUI[i]:SetActive(false)
        end
    end
end

function DdzFKGamePanel:ShowOrHideDdzView(status)
    self.ddz_match_dizhu_card_ui.gameObject:SetActive(status)
    self.ddz_match_playerright_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerright_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerleft_operate_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_info_ui.gameObject:SetActive(status)
    self.ddz_match_playerself_operate_ui.gameObject:SetActive(status)
end
function DdzFKGamePanel:ShowOrHidePermitUI(status,people)   
    if people==2 then
        self.playerright_operate_son.wait_time.gameObject:SetActive(status)
    elseif people==3 then
        self.playerleft_operate_son.wait_time.gameObject:SetActive(status)
    else
        self.playerself_operate_son.wait_time.gameObject:SetActive(status)
        if self.playerself_operate_son.yaobuqi.gameObject.activeSelf then
            if status == true then
                self.DdzFKPlayersActionManger:ChangeClickStatus(1)
            else
                if not self.autoUI[1].activeSelf then
                    self.DdzFKPlayersActionManger:ChangeClickStatus(0)
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
function DdzFKGamePanel:ShowOrHideActionUI(status,people)    
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

function DdzFKGamePanel:MyExit()
    PlayerInfoPanel.Exit()
    GameSpeedyPanel.Hide()

    self.updateTimer:Stop()
    self.DdzFKPlayersActionManger:MyExit()
    self.DdzFKActionUiManger:MyExit()
    SpineManager.RemoveAllDDZPlayerSpine()
    DdzFKLogic.clearViewMsgRegister(listerRegisterName)
    DdzFKClearing.Close()
    RoomCardGameOver.Close()
    GPSPanel.Close()
    --closePanel(DdzFKGamePanel.name)
    self.dzCardObj = nil
    self.cardObj = nil
    self.lzSelectCardObj = nil
end

function DdzFKGamePanel:MyClose()
    self:MyExit()
    closePanel(DdzFKGamePanel.name)
end

function DdzFKGamePanel:RefreshAutoStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzFKModel.data then
        local auto=DdzFKModel.data.auto_status
        if auto and DdzFKModel.data.seatNum then
            --刷新全部 
            if not pSeatNum then
                for i=1,3 do
                    if  auto[DdzFKModel.data.seatNum[i]]==1 then
                         --显示
                        if i == 1 then
                            self.DdzFKPlayersActionManger:ChangeClickStatus(1)
                        end
                        self.autoUI[i]:SetActive(true)
                    else
                        --隐藏
                        if i == 1 then
                            self.DdzFKPlayersActionManger:ChangeClickStatus(0)
                        end
                        self.autoUI[i]:SetActive(false)
                    end
                end
            --刷新单个人
            else
                if auto[DdzFKModel.data.seatNum[pSeatNum]]==1 then
                  --显示
                    if pSeatNum == 1 then
                        self.DdzFKPlayersActionManger:ChangeClickStatus(1)
                    end
                    self.autoUI[pSeatNum]:SetActive(true)
                else
                    --隐藏
                    if pSeatNum == 1 then
                        self.DdzFKPlayersActionManger:ChangeClickStatus(0)
                    end
                    self.autoUI[pSeatNum]:SetActive(false)
                end
            end
            
        end
    end
end

--刷新剩余的牌 和warning 
function DdzFKGamePanel:RefreshRemainPaiWarningStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if DdzFKModel.data then
        local remain_pai_amount=DdzFKModel.data.remain_pai_amount
        if remain_pai_amount and DdzFKModel.data.seatNum then
            --刷新全部 
            if not pSeatNum then

                for i=1,3 do
                    --刷新warning
                    if self.warningUI[i] then
                        if  remain_pai_amount[DdzFKModel.data.seatNum[i]]<3 then
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
                        self.playerOperateUI[i].remain_count_txt.text=remain_pai_amount[DdzFKModel.data.seatNum[i]]
                    end

                end
            --刷新单个人
            else
                --刷新warning
                if self.warningUI[pSeatNum] then
                    if  remain_pai_amount[DdzFKModel.data.seatNum[pSeatNum]]<3 then
                      --显示
                        self.warningUI[pSeatNum]:SetActive(true)
                    else
                        --隐藏
                        self.warningUI[pSeatNum]:SetActive(false)
                    end
                end

                --刷新牌的数量
                if self.cardsRemainUI[pSeatNum] then
                    self.playerOperateUI[pSeatNum].remain_count_txt.text=remain_pai_amount[DdzFKModel.data.seatNum[pSeatNum]]
                end

            end
            
        end
    end
end

--带动画和音效刷新剩余的牌 和warning  
function DdzFKGamePanel:RefreshRemainPaiWarningStatusWithAni(pSeatNum,act_type,pai_count)
    self:RefreshRemainPaiWarningStatus(pSeatNum)
    pai_count=pai_count or DdzFKModel.data.remain_pai_amount[DdzFKModel.data.seatNum[pSeatNum]]
    -- ###_test 根据牌的数量播放音效 动画等
    if (pai_count==2 or pai_count==1) and act_type~=0 then
        ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_card_leftwarning.audio_name)
        if pai_count==2 then
            local sound = "sod_game_card_left2" .. AudioBySex(DdzFKModel,DdzFKModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        elseif pai_count==1 then
            local sound = "sod_game_card_left1" .. AudioBySex(DdzFKModel,DdzFKModel.data.seatNum[pSeatNum])
            ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
        end
    end
end
function DdzFKGamePanel:CanelAutoBtnCB()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if Network.SendRequest("nor_ddz_nor_auto", {operate=0}) then
        self.autoUI[1]:SetActive(false)
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end
-- 刷新简易交互UI
function DdzFKGamePanel:RefreshEasyChat()
    local dizhu = DdzFKModel.data.dizhu
    local b = true
    if dizhu and dizhu > 0 then
        b = false
    end
    for i=1,3 do
        self.EasyButton[i].gameObject:SetActive(b)
        self.HeroEasyButton[i].gameObject:SetActive(not b)
    end
end

function DdzFKGamePanel:RefreshPlayerInfo(pSeatNum)
    if DdzFKModel.data and DdzFKModel.data.seat_num then
        self:RefreshEasyChat()
    	local m_data = DdzFKModel.data
        local seat_num = DdzFKModel.data.seat_num
        local dizhu = m_data.dizhu
        local playerInfo = m_data.playerInfo

        local RefreshPlayerAllInfo=function (pSeatNum)
            local dataPos = DdzFKModel.data.seatNum[pSeatNum]
            local info = playerInfo[dataPos]
            local player = self.playerInfoUI[pSeatNum]
            if info and info.base then
                --刷新头像 根据渠道 1，微信 2，游客
                URLImageManager.UpdateHeadImage(info.base.head_link, player.cust_head_img)
                self:ShowOrHideCustHeadIcon(false,pSeatNum)
                self:RefreshScore(pSeatNum)                
                self:ShowOrHideHeadInfo(true,pSeatNum)
                self:ShowOrHidePlayerInfo(true,pSeatNum)
                
                PersonalInfoManager.SetHeadFarme(player.cust_head_icon_img, info.dressed_head_frame)
                VIPManager.set_vip_text(player.head_vip_txt,info.vip_level)
                player.name2_txt.text = info.base.name
                self:SetScore(player.score2_txt, info.base.score)
                player.BigDXImage.gameObject:SetActive(false)
                self:SetDX(player.DXImage, player.cust_head_img, info.base.net_quality)
                self:SetFZ(player.FZImage, dataPos)
                if m_data.status == DdzFKModel.Status.ready and DdzFKModel.data.ready then
                    if (DdzFKModel.IsFZ(seat_num) and DdzFKModel.data.ready[dataPos] == 1) or 
                        (not DdzFKModel.IsFZ(seat_num) and (DdzFKModel.data.ready[dataPos] == 1 or (DdzFKModel.IsFZ(dataPos) and m_data.model_status == DdzFKModel.Model_Status.wait_begin)) ) then
                        player.HandImage.gameObject:SetActive(true)
                    else
                        player.HandImage.gameObject:SetActive(false)
                    end
                else
                    player.HandImage.gameObject:SetActive(false)
                end

            else
                player.HandImage.gameObject:SetActive(false)
                self:ShowOrHideCustHeadIcon(true,pSeatNum)
                self:ShowOrHideHeadInfo(false,pSeatNum)
                self:ShowOrHidePlayerInfo(false,pSeatNum)
            end
        end

        local RefreshPlayerTextInfo=function (pSeatNum)
            local dataPos = DdzFKModel.data.seatNum[pSeatNum]
            local info = playerInfo[dataPos]
            local player = self.playerInfoUI[pSeatNum]
            if info and info.base then
                player.name2_txt.text = info.base.name
                self:SetScore(player.score2_txt, info.base.score)
                self:SetDXSpine(player.BigDXImage, SpineManager.GetSpine(pSeatNum), info.base.net_quality)
                self:SetFZ(player.FZImage, dataPos)
                self:RefreshScore(pSeatNum)
            else
                self:ShowOrHidePlayerInfo(false,pSeatNum)
            end
        end

        if m_data.init_stake then
            self.dizhu_card_son.cur_base_score_txt.text = "底分：" .. m_data.init_stake
        else
            self.dizhu_card_son.cur_base_score_txt.text = "底分：--"
        end
                
        --地主框 隐藏
        SpineManager.RemoveAllDDZPlayerSpine()
        --头像隐藏
        self:ShowOrHideCustHeadIcon(true,pSeatNum)
        self:ShowOrHideHeadInfo(false,pSeatNum)
        self:ShowOrHidePlayerInfo(false,pSeatNum)

	   if dizhu ~= nil and dizhu > 0 then
            self:ShowOrHidePlayerInfo(true,pSeatNum)
            for i=1,3 do
                --地主
                if DdzFKModel.data.seatNum[i] == dizhu then
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
function DdzFKGamePanel:SetFZ(FZImage, seatno)
    if DdzFKModel.IsFZ(seatno) then
        FZImage.gameObject:SetActive(true)     
    else
        FZImage.gameObject:SetActive(false)
    end

end
-- 设置离线状态
function DdzFKGamePanel:SetDX(DXImage, HeadIcon, net_quality)
    -- 离线状态
    if not net_quality or net_quality == 1 then
        DXImage.gameObject:SetActive(false)
        HeadIcon.color = Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255)
    else
        DXImage.gameObject:SetActive(true)
        HeadIcon.color = Color.New(41 / 255, 41 / 255, 41 / 255, 255 / 255)
    end
end

function DdzFKGamePanel:SetDXSpine(DXImage, HeadIcon, net_quality)
    local renders = HeadIcon.gameObject:GetComponent(typeof(UnityEngine.Renderer))

    -- 离线状态
    if not net_quality or net_quality == 1 then
        DXImage.gameObject:SetActive(false)
        -- renders.sharedMaterial:SetColor("_FillColor", Color.black)
        -- renders.sharedMaterial:SetFloat("_FillPhase", 0)
    else
        DXImage.gameObject:SetActive(true)
        -- renders.sharedMaterial:SetColor("_FillColor", Color.black)
		-- renders.sharedMaterial:SetFloat("_FillPhase", 0.4)
    end
end

-- 设置分数
function DdzFKGamePanel:SetScore(ScoreText, score)
    if score >= 0 then
        ScoreText.text = StringHelper.ToCash(score)
    else
        ScoreText.text = "-" .. StringHelper.ToCash(score)
    end
end

function DdzFKGamePanel:RefreshPermitStatus()
    --隐藏所有权限
    self:ShowOrHidePermitUI(false) 
    if DdzFKModel.data and DdzFKModel.data.seat_num then
        local data=DdzFKModel.data
        local status=data.status
        local cur_p=data.cur_p
        if (status==DdzFKModel.Status.jdz or status==DdzFKModel.Status.jiabei or status==DdzFKModel.Status.cp ) and cur_p then
            if cur_p>0 and cur_p<4 then
                --我自己
                if cur_p==data.seat_num then
                    local permitData=DdzFKModel.getMyPermitData()
                    if permitData then
                        self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                        if permitData.type==DdzFKModel.Status.jdz then
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

                        elseif  permitData.jiabei==DdzFKModel.Status.jiabei then
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
                                self.DdzFKPlayersActionManger:ChangeClickStatus(1)
                                self:RefreshClockPos(self.playerself_operate_son.yaobuqi_time_pos)
                            end

                        end    

                    end
                --其他人    
                elseif DdzFKModel.data.s2cSeatNum then
                    if DdzFKModel.data.s2cSeatNum[cur_p]==2 then
                        self:ShowOrHidePermitUI(true,2)
                    elseif DdzFKModel.data.s2cSeatNum[cur_p]==3 then
                        self:ShowOrHidePermitUI(true,3)
                    end
                end
            --teshu
            else
                if  status==DdzFKModel.Status.jiabei then
                    if cur_p==6 then 
                        if data.jiabei==0 then
                            self.playerself_operate_son.wait_time.gameObject:SetActive(true)
                            self.playerself_operate_son.jiabei.gameObject:SetActive(true)
                            self:RefreshClockPos(self.playerself_operate_son.jiabei_time_pos)
                        end

                        self:ShowOrHidePermitUI(true,2)
                        self:ShowOrHidePermitUI(true,3)
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

function DdzFKGamePanel:RefreshClockPos(parent)
    self.playerself_operate_son.wait_time.transform.parent = parent.transform
    self.playerself_operate_son.wait_time.transform.localPosition = Vector3.zero
end

--刷新结算
function DdzFKGamePanel:RefreshSettlement()
    if DdzFKModel.data and DdzFKModel.data.seat_num  then
        local data = DdzFKModel.data
        local settlement_info = data.settlement_info
        dump(settlement_info, "<color=yellow>玩家剩余的牌</color>")
        if settlement_info then
            --玩家剩余的牌
            if settlement_info.remain_pai then
                for k,v in pairs(settlement_info.remain_pai) do
                    --其他玩家的牌
                    local p_seat = v.p
                    local pai_list = v.pai
                    local cSeatNum = DdzFKModel.data.s2cSeatNum[p_seat]
                    if cSeatNum~=1 then 
                        local show_list=nor_ddz_base_lib.norId_convert_to_lzId(pai_list,DdzFKModel.data.laizi)
                        if show_list then
                            table.sort(show_list)
                        end
                        self.DdzFKActionUiManger:RefreshAction(cSeatNum,{type=-1,show_list=show_list})
                    end    
                end
            end
        end
    end
end

--刷新地主UI显示
function DdzFKGamePanel:RefreshDiZhuAndMultipleStatus()
    if DdzFKModel.data and DdzFKModel.data.seat_num then
        local data = DdzFKModel.data
        if not data.dz_pai then
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(true)
            self.dizhu_card_son.dzcards.gameObject:SetActive(false)
        else
            self.dizhu_card_son.dzcardsbg.gameObject:SetActive(false)
            self.dizhu_card_son.dzcards.gameObject:SetActive(true)
            destroyChildren(self.dizhu_card_son.dzcards.transform)

	    local pai_list = data.dz_pai
	    if self:LaiziInDizhu() then
	    	pai_list = nor_ddz_base_lib.norId_convert_to_lzId(pai_list,self:GetLaizi())
	    end
	    for k,v in pairs(pai_list) do
	        DdzDzCard.New(self.dzCardObj, self.dizhu_card_son.dzcards.transform,v,v,0)
	    end
        end
    end
end

function DdzFKGamePanel:GetLaizi()
	local data = DdzFKModel.data
	if not data or not data.laizi then return 0 end
	return data.laizi
end

function DdzFKGamePanel:GetDizhu()
	local data = DdzFKModel.data
	if not data then return nil end
	return data.dz_pai
end

--刷新赖子牌显示
function DdzFKGamePanel:RefreshLaiziStatus(playAnim)
    local laizi = self:GetLaizi()
	if laizi <= 0 then
        self.dizhu_card_son.dzcardlz.gameObject:SetActive(false)
        self.playerself_operate_son.laizi.gameObject:SetActive(false)
        self.cur_multiple_txt.transform.localPosition = Vector3.New(192,453,0)
    else
        self.dizhu_card_son.dzcardlz.gameObject:SetActive(true)
		destroyChildren(self.dizhu_card_son.dzcardlz.transform)
		local lz_id=nor_ddz_base_lib.get_lzId(laizi)
		DdzDzCard.New(self.dzCardObj, self.dizhu_card_son.dzcardlz.transform,lz_id,lz_id,0)

		if playAnim then
			DDZAnimation.ShowLaizi(lz_id, self.dizhu_card_son.dzcardlz, function()
                self.DdzFKPlayersActionManger:CreateLz(true)
                self.cur_multiple_txt.transform.localPosition = Vector3.New(292,453,0)
				self:RefreshLaiziDepend(laizi)
			end)
		else
            self.DdzFKPlayersActionManger:CreateLz(false)
            self.cur_multiple_txt.transform.localPosition = Vector3.New(292,453,0)
			self:RefreshLaiziDepend(laizi)
		end
	end
end

function DdzFKGamePanel:RefreshLaiziDepend(laizi)
    --刷新牌
	self.DdzFKPlayersActionManger:Refresh()

	--刷新记牌器中赖子位置
	local index = 17 - laizi
	local statistics = self.playerself_operate_son.statistics
	local child = statistics:GetChild(index)
	local position = child.transform.position
	local laizi_icon = self.playerself_operate_son.laizi
	local laizi_pos = laizi_icon.transform.position
	laizi_pos.x = position.x
    laizi_icon.transform.position = laizi_pos
    laizi_icon.transform.parent = child.transform
    self.playerself_operate_son.laizi.gameObject:SetActive(true)

	if self:LaiziInDizhu() then
		self:RefreshDiZhuAndMultipleStatus()
	end
end

function DdzFKGamePanel:LaiziInDizhu()
	local laizi = self:GetLaizi()
	if laizi <= 0 then return false end
	local dizhu = self:GetDizhu() or {}
	for k, v in pairs(dizhu) do
		if laizi == v then
			return true
		end
	end
	return false
end

function DdzFKGamePanel:FillSelectLaizi(btn_ident, btn_table, pai_list, container, callback)
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
			local pai = nor_ddz_base_lib.get_pai_info(v)
			local typeIcon = "poker_laizi"
			local noIcon = "poker_icon_laizi" .. pai.type
			num_img.sprite = GetTexture(noIcon)
			type_img.sprite = GetTexture(typeIcon)
		else
            local type_img1 = go.transform:Find("@card_img/@card_num/@type_img"):GetComponent("Image")

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
            type_img1.sprite = GetTexture(typeIcon)
		end
		--DdzDzCard.New(self.dzCardObj, container.transform, v, v, 0)
	end

	--[[local qRot = Quaternion.AngleAxis(90, Vector3.New(0.0, 0.0, 1.0))
	for idx = 0, container.transform.childCount - 1 do
		local child = container.transform:GetChild(idx)
		child.transform.rotation = qRot
	end]]--

	local btn = container:GetComponent("Button")
	if btn then
		btn.name = btn_ident
		btn_table[btn_ident] = btn
		self.behaviour:AddClick(btn.gameObject, callback, self);
	else
		print("[DDZ LZ] FillSelectLaizi but btn is nil " .. btn_ident)
	end
end

function DdzFKGamePanel:ShowSelectLaiziType(pai_list_table, callback)
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
		self:FillSelectLaizi(btn_ident, btn_table, pai_list, child, function()
			self:ResetSelectLaiziType(btn_table)
			if callback then callback(btn_ident) end
		end)

		index = index + 1
	end

	--[[if table_count % 2 == 1 then
		item = GameObject.Instantiate(item_tmpl, list_area)
		child = GameObject.Instantiate(child_tmpl, item)

		item.gameObject:SetActive(true)
		child.gameObject:SetActive(true)

		pai_list = pai_list_table[index]
		--fill
		local btn_ident = index
		self:FillSelectLaizi(btn_ident, btn_table, pai_list, child, function()
			self:ResetSelectLaiziType(btn_table)
			if callback then callback(btn_ident) end
		end)

		index = index + 1
	end

	local count = 0
	for i = index, table_count do
		if count % 2 == 0 then
			item = GameObject.Instantiate(item_tmpl, list_area)
			item.gameObject:SetActive(true)
		end
		count = count + 1

		child = GameObject.Instantiate(child_tmpl, item)
		child.gameObject:SetActive(true)

		pai_list = pai_list_table[i]
		--fill
		local btn_ident = i
		self:FillSelectLaizi(btn_ident, btn_table, pai_list, child, function()
			self:ResetSelectLaiziType(btn_table)
			if callback then callback(btn_ident) end
		end)
	end]]--

	self.selectLaiziBtnTable = btn_table

	--隐藏操作面板
	self:ShowOrHidePermitUI(false)
end

function DdzFKGamePanel:ResetSelectLaiziType(btn_table)
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

function DdzFKGamePanel:OnClickCloseSelectLaizi()
	self:ResetSelectLaiziType(self.selectLaiziBtnTable)
	self:RefreshPermitStatus()
end


function DdzFKGamePanel:ShowOrHideCustHeadIcon(status,seatNum)
    -- if not seatNum then
    --     for i=1,3 do
    --         self.playerInfoUI[i].cust_head_icon_img.gameObject:SetActive(status)
    --     end
    -- else
    --     self.playerInfoUI[seatNum].cust_head_icon_img.gameObject:SetActive(status)
    -- end
end

function DdzFKGamePanel:ShowOrHideHeadInfo(status,seatNum)
    if DdzFKModel.data and DdzFKModel.data.seat_num then
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

function DdzFKGamePanel:ShowOrHidePlayerInfo(status,seatNum)
    if DdzFKModel.data and DdzFKModel.data.seat_num then
        if not seatNum then
            for i=1,3 do
                self.playerInfoUI[i].infoRect.gameObject:SetActive(status)
            end
        else
            self.playerInfoUI[seatNum].infoRect.gameObject:SetActive(status)
        end
    end
end
-- 刷新游戏总结算界面
function DdzFKGamePanel:RefreshGameOver()
    if DdzFKModel.data.model_status==DdzFKModel.Model_Status.gameover or
    DdzFKModel.data.status==DdzFKModel.Status.gameover then
        RoomCardGameOver.Create(
            self.transform,
            DdzFKModel.data.gameover_info,
            DdzFKModel.data.playerInfo,
            "DDZ",
            DdzFKModel.data.room_owner,
            function()
                DdzFKModel.ClearMatchData()
            end
        )
    else
        RoomCardGameOver.Close()
    end
end

function DdzFKGamePanel:MakeLister()
    lister={}
    lister["model_friendgame_net_quality"]=basefunc.handler(self,self.model_friendgame_net_quality)
    lister["model_friendgame_join_msg"]=basefunc.handler(self,self.model_friendgame_join_msg)
    lister["model_friendgame_quit_msg"]=basefunc.handler(self,self.model_friendgame_quit_msg)
    lister["model_friendgame_gameover_msg"]=basefunc.handler(self,self.friendgame_gameover_msg)
    lister["model_friendgame_gameover_msg_com"]=basefunc.handler(self,self.friendgame_gameover_msg_com)
    
    lister["model_nor_ddz_nor_ready_msg"] = basefunc.handler(self, self.model_nor_ddz_nor_ready_msg)
    lister["model_nor_ddz_nor_begin_msg"] = basefunc.handler(self, self.model_nor_ddz_nor_begin_msg)

    lister["model_nor_ddz_nor_settlement_msg"] = basefunc.handler(self, self.model_nor_ddz_nor_settlement_msg)
    

    lister["model_nor_ddz_nor_score_change_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_score_change_msg)
    lister["dfgModel_nor_ddz_nor_enter_room_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_enter_room_msg)
    lister["dfgModel_nor_ddz_nor_pai_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_pai_msg)
    lister["dfgModel_nor_ddz_nor_action_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_action_msg) 
    lister["dfgModel_nor_ddz_nor_permit_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_permit_msg)
    lister["dfgModel_nor_ddz_nor_dizhu_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_dizhu_msg)
    lister["dfgModel_nor_ddz_nor_laizi_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_laizi_msg)  
    lister["dfgModel_nor_ddz_nor_auto_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_auto_msg) 
    lister["dfgModel_nor_ddz_nor_new_game_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_new_game_msg)
    lister["dfgModel_nor_ddz_nor_start_again_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_start_again_msg)
    lister["dfgModel_nor_ddz_nor_gameover_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_game_clearing_msg)
    lister["dfgModel_nor_ddz_nor_jiabeifinshani_msg"]=basefunc.handler(self,self.on_nor_ddz_nor_jiabeifinshani_msg)
    
    lister["model_begin_vote_cancel_room_response"] = basefunc.handler(self, self.model_begin_vote_cancel_room_response)
    lister["model_player_vote_cancel_room_response"] = basefunc.handler(self, self.model_player_vote_cancel_room_response)
    lister["model_friendgame_begin_vote_cancel_room_msg"] = basefunc.handler(self, self.model_friendgame_begin_vote_cancel_room_msg)
    lister["model_friendgame_over_vote_cancel_room_msg"] = basefunc.handler(self, self.model_friendgame_over_vote_cancel_room_msg)
    --gps
    lister["model_query_gps_info_msg"] = basefunc.handler(self, self.model_query_gps_info_msg)
end

-- 发起投票
function DdzFKGamePanel:model_begin_vote_cancel_room_response()
    -- RoomCardDissolve.Create(parm)
end

-- 玩家投票返回
function DdzFKGamePanel:model_player_vote_cancel_room_response()
end

-- 投票开始
function DdzFKGamePanel:model_friendgame_begin_vote_cancel_room_msg()
    if DdzFKModel.data and DdzFKModel.data.vote_parm then
        RoomCardDissolve.Create(DdzFKModel.data.cur_race, DdzFKModel.data.room_rent, DdzFKModel.data.vote_data.begin_player_id, DdzFKModel.data.vote_parm)
    end
end

-- 投票结束
function DdzFKGamePanel:model_friendgame_over_vote_cancel_room_msg()
    RoomCardDissolve.MyExit()
    local data = DdzFKModel.data
    if data then
        if data.vote_result then
            if data.vote_result == 0 then
                HintPanel.Create(1, "该次投票已通过，房间已解散")
            elseif data.vate_data == 1 then
                HintPanel.Create(1, "该次投票未通过，无法解散房间")
            elseif data.vate_data == 2 then
                HintPanel.Create(1, "投票已取消")
            end
        end
    end
end

--gps
function DdzFKGamePanel:model_query_gps_info_msg(isTrustDistance)
    self.GPSHintImg.gameObject:SetActive(isTrustDistance)
end

function DdzFKGamePanel:RefreshVoteStatus()
    --根据状态显示和隐藏面板
    RoomCardDissolve.MyExit()
    if DdzFKModel.data and DdzFKModel.data.vote_data and DdzFKModel.data.vote_parm then
        local parm = DdzFKModel.data.vote_parm
        RoomCardDissolve.Create(DdzFKModel.data.cur_race, DdzFKModel.data.room_rent, DdzFKModel.data.vote_data.begin_player_id, parm)
    end
end

--刷新房间是否退出
function DdzFKGamePanel:RefreshRoomDissolveStatus()
    if DdzFKModel.data and DdzFKModel.data.room_dissolve and DdzFKModel.data.room_dissolve ~= 0 then
        if not (DdzFKModel.data.status == DdzFKModel.Status.settlement and DdzFKModel.data.settlement_info) then
            --在结算状态时不需要提示
            if not (DdzFKModel.data.model_status==DdzFKModel.Model_Status.gameover or
                DdzFKModel.data.status==DdzFKModel.Status.gameover) then
                    --在总结算状态时也不需要提示
        HintPanel.Create(
            1,
            "房间已经解散",
            function()
                DdzFKModel.ClearMatchData()
                MainLogic.ExitGame()
                MainLogic.GotoScene("game_Hall")
            end
        )
             end
        end
    end
end

-- 离线状态变化
function DdzFKGamePanel:model_friendgame_net_quality(pSeatNum)
    local uiPos = DdzFKModel.data.s2cSeatNum[pSeatNum]
    self:RefreshPlayerInfo(uiPos)
end
--开始游戏
function DdzFKGamePanel:model_nor_ddz_nor_begin_msg()
    self:MyRefresh()
end
--准备
function DdzFKGamePanel:model_nor_ddz_nor_ready_msg(pSeatNum)
    print("<color=red>准备 pSeatNum " .. pSeatNum .. "</color>")
    local uiPos = DdzFKModel.data.s2cSeatNum[pSeatNum]
    self:RefreshPlayerInfo(uiPos)
end
function DdzFKGamePanel:model_nor_ddz_nor_settlement_msg()
    self:RefreshSettlement()
    local settlement_info = DdzFKModel.data.settlement_info
    local data = DdzFKModel.data
    --春天
    if settlement_info and settlement_info.chuntian then
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
    --得分 动画
    if settlement_info then
        if settlement_info.award then
            for p_seat,score in pairs(settlement_info.award) do
                local cSeat = DdzFKModel.data.s2cSeatNum[p_seat]
                DdzFKModel.data.playerInfo[p_seat].base.score = DdzFKModel.data.playerInfo[p_seat].base.score + score
                local playerUI = self.playerInfoUI[cSeat]
                DDZAnimation.ChangeScore(cSeat, score ,playerUI.score_change_pos)
                self:RefreshPlayerInfo(cSeat)
            end
        end
    end

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(2)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        self:RefreshClearing()
    end)
end
function DdzFKGamePanel:on_nor_ddz_nor_enter_room_msg()
    print("[DDZ LaiZi] GamePanel on_nor_ddz_nor_enter_room_msg")
    self:MyRefresh()
end

-- 分数改变
function DdzFKGamePanel:on_nor_ddz_nor_score_change_msg()
end
-- 玩家进入
function DdzFKGamePanel:model_friendgame_join_msg(seatno)
    print("<color=red>玩家进入 model_friendgame_join_msg</color>")
    self:RefreshPlayerInfo(DdzFKModel.data.s2cSeatNum[seatno])
end
-- 玩家退出
function DdzFKGamePanel:model_friendgame_quit_msg(seatno)
    self:RefreshPlayerInfo(DdzFKModel.data.s2cSeatNum[seatno])
end
-- 总结算
function DdzFKGamePanel:friendgame_gameover_msg(pSeatNum)
    self:RefreshGameOver()
end

function DdzFKGamePanel:friendgame_gameover_msg_com()
    DdzFKClearing.SetGameOver()
end

function DdzFKGamePanel:on_nor_ddz_nor_pai_msg()
    print("<color=green>GamePanel on_nor_ddz_nor_pai_msg</color>")
    self.DdzFKPlayersActionManger:Fapai(DdzFKModel.data.my_pai_list)
    self:RefreshRemainPaiWarningStatus()
    self:RefreshMenu()
end


function DdzFKGamePanel:on_nor_ddz_nor_action_msg()
    local act=DdzFKModel.data.action_list[#DdzFKModel.data.action_list]
    self.DdzFKPlayersActionManger:DealAction(DdzFKModel.data.s2cSeatNum[act.p],act)
    self:RefreshDdzJiPaiQi()
end

function DdzFKGamePanel:on_nor_ddz_nor_jiabeifinshani_msg()
    DDZAnimation.ChangeRate(self.cur_multiple_txt,DdzFKModel.data.my_rate)
end

--自动出最后一手牌
local function auto_chu_last_pai(self)
    local m_data=DdzFKModel.data
    if m_data.status==DdzFKModel.Status.cp then
        local pos=m_data.s2cSeatNum[m_data.cur_p]
        if pos==1 then
            local _act=DdzFKModel.data.ddz_algorithm:check_is_only_last_pai(m_data.action_list,m_data.my_pai_list,m_data.laizi)
            if _act then
                self.last_pai_auto_countdown=1
                self.last_pai_auto_cb=function ()
                    self.last_pai_auto_cb=nil
                    self.last_pai_auto_countdown=nil
                    local manager=self.DdzFKPlayersActionManger
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

function DdzFKGamePanel:on_nor_ddz_nor_permit_msg()
    self.countdown=math.floor(DdzFKModel.data.countdown)
    self:ShowOrHideActionUI(false,DdzFKModel.data.s2cSeatNum[DdzFKModel.data.cur_p])
    self:RefreshPermitStatus()
    --隐藏
    self:ResetSelectLaiziType(self.selectLaiziBtnTable)
    self.DdzFKActionUiManger:changeActionUIShowByStatus()

    auto_chu_last_pai(self)
end
function DdzFKGamePanel:on_nor_ddz_nor_dizhu_msg()
    if DdzFKModel.data then
        local data = DdzFKModel.data

        if data.dizhu==data.seat_num then
	    self.DdzFKPlayersActionManger:AddPai(DdzFKModel.data.dz_pai)
        end
        self:RefreshDiZhuAndMultipleStatus()
        self:RefreshRate()
        self:RefreshPlayerInfo()
        self:RefreshDdzJiPaiQi()
	    if data.my_rate then
            DDZAnimation.ChangeRate(self.cur_multiple_txt,data.my_rate)
        end
    end
end
function DdzFKGamePanel:on_nor_ddz_nor_laizi_msg()
    self:RefreshLaiziStatus(true)
end

function DdzFKGamePanel:on_nor_ddz_nor_auto_msg(player)
    self:RefreshAutoStatus(DdzFKModel.data.s2cSeatNum[player])
    self:OnClickCloseSelectLaizi()
	--[[local list_table = {}
	list_table[1] = {2,9,8,7,6}
	list_table[2] = {5,6,7,8,9,12,13,14,15}
	self:ShowSelectLaiziType(list_table, function(ident)
		print("ShowSelectLaiziType callback " .. ident)
	end)]]--
end

function DdzFKGamePanel:on_nor_ddz_nor_new_game_msg()
    self:MyRefresh()
    --新的局数
    if DdzFKModel.data then
        local curRace = DdzFKModel.data.race
        if curRace then
            DDZAnimation.CurRace(curRace,self.start_again_cards_pos)
        end
    end
end
function DdzFKGamePanel:on_nor_ddz_nor_start_again_msg()
    self:MyRefresh()
    DDZAnimation.StartAgainCard(self.start_again_cards_pos)
end

function DdzFKGamePanel:on_nor_ddz_nor_game_clearing_msg()
    self:RefreshSettlement()

    if DdzFKModel.data then
        local data = DdzFKModel.data
	local settlement_info = data.settlement_info

	if settlement_info then
	    --得分 动画
	    if settlement_info.award then
	        for p_seat,score in pairs(settlement_info.award) do
	            local cSeat = DdzFKModel.data.s2cSeatNum[p_seat]
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


