-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"
local nor_ddz_base_lib = require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"

DdzFreeClearing = basefunc.class()

DdzFreeClearing.name = "DdzFreeClearing_New"

local instance
function DdzFreeClearing.Create(isdelay)
    PlayerInfoPanel.Exit()
    GameSpeedyPanel.Hide()

    if not instance then
        instance = DdzFreeClearing.New(isdelay)
    else
        instance:MyRefresh()
    end
    return instance
end
-- 关闭
function DdzFreeClearing.Close()
    if instance then
        instance:MyExit()
    end
end
-- 关闭
function DdzFreeClearing:MyExit()
    print("<color=red>自由场结算退出</color>")

    if self.game_btn_pre then
        self.game_btn_pre:MyExit()
        self.game_btn_pre = nil
    end
    Event.Brocast("activity_fg_close_clearing")
    Event.Brocast("fg_close_clearing")
    if self.delayTime then
        self.delayTime:Stop()
    end
    self.delayTime = nil

    if self.room_rent_time then
        self.room_rent_time:Stop()
        self.room_rent_time = nil
    end
    
    self:StopFixStuck()

    self:RemoveListener()
    TotalRedPrefab.Exit()
    destroy(self.transform.gameObject)

    instance = nil
end

function DdzFreeClearing:AddMsgListener(lister)
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function DdzFreeClearing:MakeLister()
    self.lister = {}
    self.lister["model_fg_gameover_msg"] = basefunc.handler(self, self.on_fg_gameover_msg)
    self.lister["fg_ready_response_code"] = basefunc.handler(self, self.on_fg_ready_response_code)
    self.lister["fg_huanzhuo_response_code"] = basefunc.handler(self, self.on_fg_huanzhuo_response_code)
    self.lister["activity_fg_activity_data_msg"] = basefunc.handler(self, self.OnRefreshActivityData)
    self.lister["game_share"] = basefunc.handler(self, self.game_share)
    self.lister["fg_settle_exchange_hongbao_response"] = basefunc.handler(self, self.on_fg_settle_exchange_hongbao_response)
end
 
function DdzFreeClearing:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function DdzFreeClearing:ctor(isdelay)
    self.gameExitTime = os.time()

    self.isdelay = isdelay
    local parent = GameObject.Find("Canvas/LayerLv2").transform
    self:MakeLister()
    self:AddMsgListener(self.lister)
    local obj = newObject(DdzFreeClearing.name, parent)
    local tran = obj.transform
    self.transform = tran

    self.GameExitTimeText = tran:Find("GameExitTimeText"):GetComponent("Text")
    self.GameExitTimeText.text = os.date("%Y.%m.%d %H:%M:%S", self.gameExitTime)
    LuaHelper.GeneratingVar(self.transform, self)

    self.detailBtnPosSelf = self.detail_self_btn.transform.parent
    self.detailBtnPosRight = self.detail_right_btn.transform.parent
    self.detailBtnPosLeft = self.detail_left_btn.transform.parent
    self.detailBtnPosSelfEr = self.detail_er_self_btn.transform.parent
    self.detailBtnPosRightEr = self.detail_er_right_btn.transform.parent
    self.detailPosSelf = tran:Find("@settlement_detail_pos_self")
    self.detailPosRight = tran:Find("@settlement_detail_pos_right")
    self.detailPosLeft = tran:Find("@settlement_detail_pos_left")
    self.detailPosSelfEr = tran:Find("@settlement_er_detail_pos_self")
    self.detailPosRightEr = tran:Find("@settlement_er_detail_pos_right")
    
    self.ExchangeNode = tran:Find("ExchangeNode")
    self.ExChongbao = tran:Find("ExchangeNode/ExChongbao"):GetComponent("Text")
    self.ExchangeButton = tran:Find("ExchangeNode/ExchangeButton"):GetComponent("Button")
    self.ExchangeButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnExchangeClick()
    end)

    self.ready_btn.transform.localPosition = Vector3.New(0, -440, 0)
    self.BackButton = tran:Find("BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            --self:OnBackClick()
            local callback = basefunc.handler(self, self.OnBackClick)
            GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
        end
    )

    self.changedesk_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnChangedeskClick()
        end
    )
    self.ready_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnReadyClick()
        end
    )
    self.goto_match_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            local state = gameMgr:CheckUpdate("game_MatchHall")
            if state == "Install" or state == "Update" then
                HintPanel.Create(1, "请返回大厅更新游戏")
            else
                if Network.SendRequest("fg_quit_game", nil, "") then
                    MainLogic.ExitGame()
                    GameManager.GotoUI({gotoui = "game_MatchHall"})
                end
            end
        end
    )
    if not GameGlobalOnOff.Diversion then
        self.goto_match_btn.gameObject:SetActive(false)
    end

    self.share_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnShareClick()
        end
    )

    if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.er then
        self.GameHonorNode = self.HonorNodeER
    else
        self.GameHonorNode = self.HonorNode
    end
    self.playerInfo = {}

    for i = 1, DdzFreeModel.maxPlayerNumber do
        local player = ""
        if i == 1 then
            player = "self"
        elseif i == 2 then
            player = "right"
        elseif i == 3 then
            player = "left"
        end

        local playerPos = player
        if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.er then
            player = player .. "_er"
        end
        self.playerInfo[i] = {}
        self.playerInfo[i].HeadFrame = self[player .. "_HeadFrameImage_img"]
        self.playerInfo[i].head_vip_txt = self[player .. "_head_vip_txt"]
        self.playerInfo[i].Head = self[player .. "_head_img"]
        self.playerInfo[i].RoleIcon = self[player .. "_role_icon_img"]
        self.playerInfo[i].playerName = self[player .. "_name_txt"]
        self.playerInfo[i].BaseScore = self[player .. "_base_score_txt"]
        self.playerInfo[i].times = self[player .. "_times_txt"]
        self.playerInfo[i].looseScore = self[player .. "_loose_score_txt"]
        self.playerInfo[i].BPF = self[player .. "_BPF_btn"]:GetComponent("Image")
        self.playerInfo[i].BPFBtn = self[player .. "_BPF_btn"]
        self.playerInfo[i].BPFTips = self[player .. "_BPF_tips"]
        self.playerInfo[i].BPFTipsBG = self[player .. "_BPF_tips_bg"]
        self.playerInfo[i].BPFText = self[player .. "_BPF_txt"]

        self["settlement_detail_" .. playerPos].gameObject:SetActive(false)
        self["settlement_detail_mld_" .. playerPos].gameObject:SetActive(false)

        EventTriggerListener.Get(self["detail_" .. playerPos .. "_btn"].gameObject).onDown = function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.nor then
                self["settlement_detail_" .. playerPos].gameObject:SetActive(true)
            elseif DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
                self["settlement_detail_mld_" .. playerPos].gameObject:SetActive(true)
            end
        end
        EventTriggerListener.Get(self["detail_" .. playerPos .. "_btn"].gameObject).onUp = function ()
            if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.nor then
                self["settlement_detail_" .. playerPos].gameObject:SetActive(false)
            elseif DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
                self["settlement_detail_mld_" .. playerPos].gameObject:SetActive(false)
            end
        end

        EventTriggerListener.Get(self.playerInfo[i].BPFBtn.gameObject).onDown = function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.playerInfo[i].BPFTips.gameObject:SetActive(true)
        end
        EventTriggerListener.Get(self.playerInfo[i].BPFBtn.gameObject).onUp = function ()
            self.playerInfo[i].BPFTips.gameObject:SetActive(false)
        end
    end

    local gameCfg = GameFreeModel.GetGameIDToConfig(DdzFreeModel.baseData.game_id)
    if gameCfg then
        local gameTypeCfg = GameFreeModel.GetGameTypeToConfig(gameCfg.game_type)
        self.gameName_txt.text = gameTypeCfg.name .. "  " .. gameCfg.game_name
    end

    self.isWin = DdzFreeModel.IsMyWin()
    self:InitRect()

    if self.isdelay then
        self.transform.gameObject:SetActive(false)
        self.delayTime = Timer.New(function()
            PlayerInfoPanel.Exit()
            GameSpeedyPanel.Hide()

            if IsEquals(self.transform) then
                self.transform.gameObject:SetActive(true)
                -- DOTweenManager.OpenClearUIAnim(self.transform, basefunc.handler(self, self.CheckShow1YuanGift))
                DOTweenManager.OpenClearUIAnim(self.transform, function (  )
                    self.CheckShow1YuanGift()
                    GameManager.GuideToMiniGame()
                end)
            end
        end, 2, 1, true)
        self.delayTime:Start()
    else
        -- DOTweenManager.OpenClearUIAnim(self.transform, basefunc.handler(self, self.CheckShow1YuanGift))
        DOTweenManager.OpenClearUIAnim(self.transform, function (  )
            self.CheckShow1YuanGift()
            GameManager.GuideToMiniGame()
        end)
    end

    self.room_rent_time = Timer.New(function()
        if IsEquals(self.room_rent_txt.gameObject) then
            self.room_rent_txt.gameObject:SetActive(false)
        end
    end, 3, 1, true)
    self.room_rent_time:Start()
    local btn_map = {}
    btn_map["left"] = {self.left_node}
    btn_map["top_right"] = {self.tr_node}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "ddz_free_js")
    self.ext_model = DdzFreeModel
    Event.Brocast("global_sysqx_uichange_msg", {key="dh", panelSelf=self})

	local rplTxt = tran:Find("ExchangeNode/Text"):GetComponent("Text")
	rplTxt.text = "将赢的鲸币兑换为福利券"
end
function DdzFreeClearing:MyRefresh()
    if self.delayTime then
        self.delayTime:Stop()
    end
    self.delayTime = nil
    self.transform.gameObject:SetActive(true)

    self:SetBackAndConfirmBtn()
end
function DdzFreeClearing:UpdateExchange()
    local is_game_over = DdzFreeModel.data.model_status == DdzFreeModel.Model_Status.gameover

    if is_game_over and DdzFreeModel.data.exchange_hongbao and DdzFreeModel.data.exchange_hongbao.is_exchanged == 0 then
        self.ready_btn.transform.localPosition = Vector3.New(268, -393, 0)
        self.ExchangeNode.gameObject:SetActive(true)
        self.ExChongbao.text = StringHelper.ToRedNum(DdzFreeModel.data.exchange_hongbao.hong_bao / 100)
        self.ext_model = DdzFreeModel
        Event.Brocast("global_sysqx_uichange_msg", {key="dh", panelSelf=self})
    else
        self.ExchangeNode.gameObject:SetActive(false)
        self.ready_btn.transform.localPosition = Vector3.New(0, -440, 0)
    end
end
function DdzFreeClearing:OnExchangeClick()
    local iss = PlayerPrefs.GetInt(MainModel.FreeDHRedHintKey, 0)
    if iss == 1 then
        iss = true
    else
        iss = false
    end
    if not iss then
        local rr = StringHelper.ToRedNum(DdzFreeModel.data.exchange_hongbao.hong_bao / 100)
        local jb = DdzFreeModel.data.settlement_info.award[DdzFreeModel.GetPlayerSeat()]
        local str = string.format("为你将本局赢得的%s鲸币兑换成%s福利券", jb, rr)
        local pre = HintPanel.Create(2, str, function (b)
            Network.SendRequest("fg_settle_exchange_hongbao", nil, "")
            if b then
                PlayerPrefs.SetInt(MainModel.FreeDHRedHintKey, 1)
            else
                PlayerPrefs.SetInt(MainModel.FreeDHRedHintKey, 0)
            end
        end)
        pre:ShowGou()
        pre:SetButtonText(nil, "立即兑换")
    else
        Network.SendRequest("fg_settle_exchange_hongbao", nil, "")
    end
end
function DdzFreeClearing:on_fg_settle_exchange_hongbao_response(_, data)
    dump(data, "<color=red>on_fg_settle_exchange_hongbao_response</color>")
    if data.result == 0 then
        DdzFreeModel.data.exchange_hongbao.is_exchanged = 1
        self:UpdateExchange()
    end
end

function DdzFreeClearing:IsCanShare()
    if GameGlobalOnOff.ShowOff and self.isWin and self.bei >= 48 then
        return true
    end
    return false
end
-- 分享战绩
function DdzFreeClearing:OnShareClick()
    if self:IsCanShare() then
        DDZSharePrefab.Create(
            DdzFreeModel.baseData.game_id,
            {
                myseatno = DdzFreeModel.GetPlayerSeat(),
                dzseatno = DdzFreeModel.data.dizhu,
                bei = self.bei,
                settlement = DdzFreeModel.data.settlement_info,
                gameExitTime = self.gameExitTime,
            }
        )
    end
end

function DdzFreeClearing:InitRect()
    if not DdzFreeModel.data.settlement_info then
        return
    end
    if DdzFreeModel.data.glory_score_count then
        local v1 = DdzFreeModel.data.glory_score_count
        local v2 = DdzFreeModel.data.glory_score_change
        GameHonorModel.UpdateHonorValue(v1)
    end

    self:SetBackAndConfirmBtn()

    local settlement_info = DdzFreeModel.data.settlement_info

    if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.er then
        self.lose_node.parent = self.node_er_pos.transform
        self.lose_node.localPosition = Vector3.zero
        self.win_node.parent = self.node_er_pos.transform
        self.win_node.localPosition = Vector3.zero
        self.detailPosSelf.localPosition = self.detailPosSelfEr.localPosition
        self.detailPosRight.localPosition = self.detailPosRightEr.localPosition
        self.detail_self_btn.transform.parent = self.detail_er_self_btn.transform.parent
        self.detail_self_btn.transform.localPosition = Vector3.zero
        self.detail_right_btn.transform.parent = self.detail_er_right_btn.transform.parent
        self.detail_right_btn.transform.localPosition = Vector3.zero
        self.BGImage.gameObject:SetActive(false)
        self.BGImageER.gameObject:SetActive(true)
        self.base_rate_title_txt.text = "抢地主"
    else
        self.lose_node.parent = self.node_pos.transform
        self.lose_node.localPosition = Vector3.New(0,50,0)
        self.win_node.parent = self.node_pos.transform
        self.win_node.localPosition = Vector3.New(0,50,0)
        --[[self.settlement_detail.parent = self.settlement_detail_pos.transform
        self.settlement_detail.localPosition = Vector3.zero
        self.detail_btn.transform.parent = self.detail_btn_pos.transform
        self.detail_btn.transform.localPosition = Vector3.zero]]
        self.BGImage.gameObject:SetActive(true)
        self.BGImageER.gameObject:SetActive(false)
        self.base_rate_title_txt.text = "叫分"
    end

    local isDZ
    if DdzFreeModel.GetPlayerSeat() == DdzFreeModel.data.dizhu then
        isDZ = true
    else
        isDZ = false
    end
    if settlement_info.chuntian ~= 2 then
        self.ct_txt.text = "春天"
    else
        self.ct_txt.text = "反春"
    end

    dump(DdzFreeModel.data, "<color=green>------------------------------------------------->>>> settle info:</color>")
    self.detail_self_btn.transform.parent.gameObject:SetActive(false)
    self.detail_right_btn.transform.parent.gameObject:SetActive(false)
    self.detail_left_btn.transform.parent.gameObject:SetActive(false)
    
    if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.nor then
        local m_data = {}
        local settlement_data = {}
        m_data.settlement_info = settlement_info
        m_data.er_qiang_dizhu_count = settlement_info.er_qiang_dizhu_count
        m_data.base_rate = DdzFreeModel.data.base_rate
        m_data.init_rate = DdzFreeModel.data.init_rate
        m_data.jdz_type = DdzFreeModel.baseData.jdz_type
        dump( m_data , "<color=yellow>------------------------------ settlement_data 1 </color>")
        settlement_data = nor_ddz_base_lib.GetSettlementDetailedInfo(m_data)
        dump(settlement_data , "<color=yellow>------------------------------ settlement_data 2 </color>")
        if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.er then
            self["base_rate_self_txt"].text = settlement_data.q_dizhu == 0 and "--" or "x" .. settlement_data.q_dizhu
        else
            self["base_rate_self_txt"].text = settlement_data.jdz == 0 and "--" or "x" .. settlement_data.jdz
        end

        self["bomb_self_txt"].text = settlement_data.bomb == 0 and "--" or "x" .. settlement_data.bomb
        self["chuntian_self_txt"].text = settlement_data.chuntian == 0 and "--" or "x" .. settlement_data.chuntian
        self["get_score_self_txt"].text = settlement_data.base == 0 and "--" or settlement_data.base
        self["all_score_self_txt"].text = settlement_data.all == 0 and "--" or settlement_data.all
        self["dz_self_txt"].text = settlement_data.dizhu == 0 and "--" or settlement_data.dizhu
        self["nm_self_txt"].text = settlement_data.nongmin == 0 and "--" or settlement_data.nongmin 
        self.bei = settlement_data.all
        self.detail_self_btn.transform.parent.gameObject:SetActive(true)
    elseif DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
        --1:self 2:right 3:left
        local betData = DdzFreeModel.CalcBetMultipliers()
        local total = 0
        dump(betData, "<color=yellow>-------------------------------->>>> betData:</color>")

        self.betMuls = {}
        for i, bd in ipairs(betData) do
            local pos = "self"
            local seat_num = DdzFreeModel.GetSeatnoToPos(bd.seat)
            -- dump(bd, "<color=green>======================================>>> seat:" .. seat_num .. ", bd:</color>")
            if seat_num == 1 then
                self.detail_self_btn.transform.parent.gameObject:SetActive(true)
            elseif seat_num == 2 then
                pos = "right"
                self.detail_right_btn.transform.parent.gameObject:SetActive(true)
            elseif seat_num == 3 then
                pos = "left"
                self.detail_left_btn.transform.parent.gameObject:SetActive(true)
            end

            self["men_" .. pos .. "_txt"].text = "x" .. bd.menMul
            self["men_base_" .. pos .. "_txt"].text = (bd.menMul == 2 and "闷抓" or "抓")
            self["dao_" .. pos .. "_txt"].text = (bd.daoMul > 1 and "x" .. bd.daoMul or "--")
            self["la_" .. pos .. "_txt"].text = (bd.laMul > 1 and "x" .. bd.laMul or "--")
            self["bomb_mld_" .. pos .. "_txt"].text = "x" .. (bd.bombMul > 1 and bd.bombMul or 0)
            self["chuntian_mld_" .. pos .. "_txt"].text = "x" .. (bd.springMul > 1 and bd.springMul or 0)
            self["all_score_mld_" .. pos .. "_txt"].text = bd.betTimes
            self.betMuls[bd.seat] = bd.betTimes
            total = total + bd.betTimes
        end
        self.bei = total
        self.betMuls[DdzFreeModel.data.dizhu] = total
    end

    if DdzFreeModel.baseData.room_rent then
        self.room_rent_txt.text = "服务费：" .. DdzFreeModel.baseData.room_rent.asset_count
    end

    self.isDZ = isDZ

    local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator"}, "IsBigUI")
    local is_show_big_ui = a and not b
    if not is_show_big_ui then
        self:OnShareClick()
    end
    if self:IsCanShare() then
        self.share_btn.gameObject:SetActive(true)
    else
        self.share_btn.gameObject:SetActive(false)
    end

    ExtendSoundManager.PlaySound(self.isWin and audio_config.game.sod_game_win.audio_name or audio_config.game.sod_game_lose.audio_name)
    self.lose_node.gameObject:SetActive(not self.isWin)
    self.win_node.gameObject:SetActive(self.isWin)
    self.liansheng_count_txt.text = ""
    self.liansheng.gameObject:SetActive(false)
    local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = DdzFreeModel.baseData.game_id,activity_type = ActivityType.Consecutive_Win}, "CheckIsActivated")
    local is_true = a and b
    if is_true then
        self.shengli.gameObject:SetActive(false)
    else
        self.shengli.gameObject:SetActive(self.isWin)
    end

    local sData = settlement_info
    local pData = DdzFreeModel.data.settlement_players_info
    if not pData then
        pData = DdzFreeModel.data.players_info
    end

    for i = 1, DdzFreeModel.maxPlayerNumber do
        local pSeat = DdzFreeModel.GetPosToSeatno(i)
        local p_data = pData[pSeat]
        if not p_data then
            Network.SendRequest("fg_get_settlement_players_info",nil,"正在请求数据",function (data)
                if data and data.result == 0 then
                    if DdzFreeModel.data then
                        DdzFreeModel.data.settlement_players_info = data.settlement_players_info 
                        pData = DdzFreeModel.data.settlement_players_info
                        for i = 1, DdzFreeModel.maxPlayerNumber do
                            local pSeat = DdzFreeModel.GetPosToSeatno(i)
                            if pData then
                            local p_data = pData[pSeat]
                            local set_player_ui = function(  )
                                URLImageManager.UpdateHeadImage(p_data.head_link, self.playerInfo[i].Head)
                                self.playerInfo[i].playerName.text = p_data.name
                                PersonalInfoManager.SetHeadFarme(self.playerInfo[i].HeadFrame, p_data.dressed_head_frame)
                                VIPManager.set_vip_text(self.playerInfo[i].head_vip_txt,p_data.vip_level)
                            end
                            if p_data then
                                set_player_ui()            
                                end
                            end
                        end 
                    end
                else
                    HintPanel.ErrorMsg(data.result)
                end
            end)
            break
        end
    end
    dump(pData, "<color=green>pData</color>")
    for i = 1, DdzFreeModel.maxPlayerNumber do
        local pSeat = DdzFreeModel.GetPosToSeatno(i)
        local p_data = pData[pSeat]
        local set_player_ui = function(  )
            URLImageManager.UpdateHeadImage(p_data.head_link, self.playerInfo[i].Head)
            self.playerInfo[i].playerName.text = p_data.name
            PersonalInfoManager.SetHeadFarme(self.playerInfo[i].HeadFrame, p_data.dressed_head_frame)
            VIPManager.set_vip_text(self.playerInfo[i].head_vip_txt,p_data.vip_level)
        end
        if p_data then
            set_player_ui()            
        end
       
        self.playerInfo[i].BaseScore.text = DdzFreeModel.data.init_stake
        --self.playerInfo[i].times.text = math.abs(sData.award[pSeat])/DdzFreeModel.data.init_stake
        if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.nor then
            if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.er then
                self.playerInfo[i].times.text = self.bei
            else
                self.playerInfo[i].times.text = (pSeat == DdzFreeModel.data.dizhu and self.bei or self.bei/2)
            end
        elseif DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
            self.playerInfo[i].times.text = self.betMuls[pSeat]
        end
        
        --[[self.playerInfo[i].RoleIcon.sprite =
            pSeat == DdzFreeModel.data.dizhu and GetTexture("ddz_settlement_icon_dz") or
            GetTexture("ddz_settlement_icon_nm")]]
        self.playerInfo[i].RoleIcon.gameObject:SetActive(pSeat == DdzFreeModel.data.dizhu)
        self.playerInfo[i].looseScore.text = StringHelper.ToCashSymbol(sData.award[pSeat])
    end

    --包赔
    if sData.auto_baopei_pos then
        local i = DdzFreeModel.GetSeatnoToPos(sData.auto_baopei_pos)
        self.playerInfo[i].BPF.sprite = GetTexture("ddz_settlement_icon_bp")
        self.playerInfo[i].BPF.gameObject:SetActive(true)
        self.playerInfo[i].BPFTipsBG.gameObject:SetActive(false)
    end

    local cfg = GameFreeModel.GetGameIDToConfig(DdzFreeModel.baseData.game_id)
    if cfg and cfg.max_rate then
        self.maxRate_txt.text = cfg.max_rate .. "倍"
        self.maxRate_txt.transform.parent.gameObject:SetActive(true)

        for i = 1, DdzFreeModel.maxPlayerNumber do
            local pSeat = DdzFreeModel.GetPosToSeatno(i)
            local t = 0
            if DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.nor then
                if DdzFreeModel.baseData.game_type == DdzFreeModel.game_type.er then
                    t = self.bei
                else
                    t = (pSeat == DdzFreeModel.data.dizhu and self.bei or self.bei/2)
                end
            elseif DdzFreeModel.baseData.jdz_type == DdzFreeModel.jdz_type.mld then
                t = self.betMuls[pSeat]
            end

            if t > cfg.max_rate and sData.award[pSeat] > 0 then
                self.playerInfo[i].BPF.sprite = GetTexture("ddz_settlement_icon_fd")
                self.playerInfo[i].BPF.gameObject:SetActive(true)
                self.playerInfo[i].BPFTips.gameObject:SetActive(false)
                self.playerInfo[i].BPFTipsBG.gameObject:SetActive(true)
                self.playerInfo[i].BPFText.text = "超过场次最大倍数啦！"
            end
        end
    else
        self.maxRate_txt.transform.parent.gameObject:SetActive(false)
    end

    --封顶
    if sData.yingfengding then
        --dump(sData, "<color=green>------------->>> yingfengding:</color>")
        for i = 1, DdzFreeModel.maxPlayerNumber do
            local pSeat = DdzFreeModel.GetPosToSeatno(i)
            if sData.yingfengding[pSeat] == 1 then
                self.playerInfo[i].BPF.sprite = GetTexture("ddz_settlement_icon_yfd")
                self.playerInfo[i].BPF.gameObject:SetActive(true)
                self.playerInfo[i].BPFTips.gameObject:SetActive(true)
                self.playerInfo[i].BPFTipsBG.gameObject:SetActive(true)
                self.playerInfo[i].BPFText.text = "带多少只能赢多少哦！"
            end
        end
    end

    --破产
    if sData.lose_surplus then
        for i = 1, DdzFreeModel.maxPlayerNumber do
            local pSeat = DdzFreeModel.GetPosToSeatno(i)
            local lose_surplus = sData.lose_surplus[pSeat]
            if lose_surplus > 0 and sData.auto_baopei_pos ~= pSeat and sData.award[pSeat] <= 0 then
                self.playerInfo[i].BPF.sprite = GetTexture("ddz_settlement_icon_pc")
                self.playerInfo[i].BPF.gameObject:SetActive(true)
                self.playerInfo[i].BPFText.text = "全输光了"
                self.playerInfo[i].BPFTips.gameObject:SetActive(false)
                self.playerInfo[i].BPFTipsBG.gameObject:SetActive(true)
            end
        end
    end

    self:OnOff()
end

function DdzFreeClearing:OnOff()
end

--[[
Botton
--]]
function DdzFreeClearing:OnChangedeskClick()
    self:CheckShow1YuanGift(function ()
        DdzFreeModel.HZCheck()
    end)
end

-- 准备
function DdzFreeClearing:OnReadyClick()
    self:CheckShow1YuanGift(function ()
        DdzFreeModel.ZBCheck()
    end)
end

-- 返回
function DdzFreeClearing:OnBackClick()
    if Network.SendRequest("fg_quit_game", nil, "") then
        self:MyExit()
    else
        DDZAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end
end

function DdzFreeClearing:on_fg_gameover_msg()
    self.room_rent_txt.text = "服务费：" .. DdzFreeModel.baseData.room_rent.asset_count
    if DdzFreeModel.data.glory_score_count then
        local v1 = DdzFreeModel.data.glory_score_count
        local v2 = DdzFreeModel.data.glory_score_change
        GameHonorModel.UpdateHonorValue(v1)
    end

    self:SetBackAndConfirmBtn()
    self:StopFixStuck()
    if GuideLogic then
        GuideLogic.CheckRunGuide("free_js")
    end
end
function DdzFreeClearing:on_fg_ready_response_code(result)
    if result == 0 then
        self:MyExit()
    end
end
function DdzFreeClearing:on_fg_huanzhuo_response_code(result)
    if result == 0 then
        self:MyExit()
    end
end

function DdzFreeClearing:SetBackAndConfirmBtn()
    local is_game_over = DdzFreeModel.data.model_status == DdzFreeModel.Model_Status.gameover
    if is_game_over then
        --福卡
        TotalRedPrefab.Create(self.transform, {game_id = DdzFreeModel.baseData.game_id})
    end
    if IsEquals(self.goto_match_btn.gameObject) then
        if is_game_over then
            if not GameGlobalOnOff.Diversion then
                self.goto_match_btn.gameObject:SetActive(false)
            else
                self.goto_match_btn.gameObject:SetActive(false)
            end
        else
            self.goto_match_btn.gameObject:SetActive(false)
        end
    end
    self.BackButton.gameObject:SetActive(is_game_over)
    self.changedesk_btn.gameObject:SetActive(is_game_over)
    self.ready_btn.gameObject:SetActive(is_game_over)
    is_game_over = nil

    self:TryFixStuck()
    self:UpdateExchange()
end

function DdzFreeClearing:TryFixStuck()
    if not self.fixStuck then
        self.fixStuck = Timer.New(function()
            logWarn("<color=yellow>--->>>(DDZ)Player stucked in game over!</color>")
            self.BackButton.gameObject:SetActive(true)
            self.changedesk_btn.gameObject:SetActive(true)
            self.ready_btn.gameObject:SetActive(true)
            self.fixStuck = nil
        end, 5, 1, false)
        self.fixStuck:Start()
    end
end

function DdzFreeClearing:StopFixStuck()
	if self.fixStuck then
		self.fixStuck:Stop()
		self.fixStuck = nil
	end
end

function DdzFreeClearing:GetPlayerScore(seatno)
    local pData = DdzFreeModel.data.settlement_players_info
    if not pData then
        pData = DdzFreeModel.data.players_info
    end
    
	local myScore = 0
	for _, info in pairs(pData) do
		if info.seat_num == seatno then	
			myScore = info.score
			break
		end
	end
	return myScore
end

function DdzFreeClearing:CheckShow1YuanGift(call)
    if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
    	if call then call() end
    	return
    end

	-- log("<color=yellow>-------------------------------------->>> My seat:%s</color>",DdzFreeModel.data.seat_num)
	local brokeUp = false
	local myScore = MainModel.UserInfo.jing_bi
    local gameCfg = GameFreeModel.GetGameIDToConfig(DdzFreeModel.baseData.game_id)
    if myScore and gameCfg then
        if gameCfg.order == 1 and myScore < gameCfg.enterMin then
            brokeUp = true
        else
            local uiConfigs = GameFreeModel.UIConfig.gameConfigMap
            for _, config in ipairs(uiConfigs) do
                if config.game_type == gameCfg.game_type and config.order == 1 and myScore < config.enterMin then
                    brokeUp = true
                    break
                end
            end
        end
    end

    if brokeUp then
        LittleTips.Create("当前鲸币不足")
        if gameCfg.game_name == "新手场" then
            local pc_num =  UnityEngine.PlayerPrefs.GetString(MainModel.UserInfo.user_id .. "_pc_num",0)
            if tonumber(pc_num) <= 1 then
                --每日首次破产
                OneYuanGift.ChekcBroke()
            else
                OneYuanGift.Create(nil, call)
            end
        else
            OneYuanGift.Create(nil, call)
        end
    else
        if call then
            call()
        end
	end
end
function DdzFreeClearing:OnRefreshActivityData()
    local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = DdzFreeModel.baseData.game_id}, "CheckShowLS")
    local is_show_ls = a and b
    if self.isWin and DdzFreeModel.data.ls_count > 1 and is_show_ls then
        self.shengli.gameObject:SetActive(false)
        self.liansheng_count_txt.text = DdzFreeModel.data.ls_count
        self.liansheng.gameObject:SetActive(true)
    else
        self.shengli.gameObject:SetActive(self.isWin)
        self.liansheng_count_txt.text = ""
        self.liansheng.gameObject:SetActive(false)
    end
end

function DdzFreeClearing:game_share()
    self:OnShareClick()
end
