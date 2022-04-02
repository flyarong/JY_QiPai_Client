-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"
local nor_ddz_base_lib = require "Game.normal_ddz_common.Lua.nor_pdk_base_lib"

DdzPDKClearing = basefunc.class()

DdzPDKClearing.name = "DdzPDKClearing"

local instance
function DdzPDKClearing.Create(isdelay)
    PlayerInfoPanel.Exit()
    GameSpeedyPanel.Hide()

    if not instance then
        instance = DdzPDKClearing.New(isdelay)
    else
        instance:MyRefresh()
    end
    return instance
end
-- 关闭
function DdzPDKClearing.Close()
    if instance then
        instance:MyExit()
    end
end
-- 关闭
function DdzPDKClearing:MyExit()
    print("<color=red>跑得快结算退出</color>")

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

function DdzPDKClearing:AddMsgListener(lister)
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function DdzPDKClearing:MakeLister()
    self.lister = {}
    self.lister["model_fg_gameover_msg"] = basefunc.handler(self, self.on_fg_gameover_msg)
    self.lister["fg_ready_response_code"] = basefunc.handler(self, self.on_fg_ready_response_code)
    self.lister["fg_huanzhuo_response_code"] = basefunc.handler(self, self.on_fg_huanzhuo_response_code)
    self.lister["activity_fg_activity_data_msg"] = basefunc.handler(self, self.OnRefreshActivityData)
    self.lister["game_share"] = basefunc.handler(self, self.game_share)
    self.lister["fg_settle_exchange_hongbao_response"] = basefunc.handler(self, self.on_fg_settle_exchange_hongbao_response)
end
 
function DdzPDKClearing:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function DdzPDKClearing:ctor(isdelay)
    self.gameExitTime = os.time()

    self.isdelay = isdelay
    local parent = GameObject.Find("Canvas/LayerLv2").transform
    self:MakeLister()
    self:AddMsgListener(self.lister)
    local obj = newObject(DdzPDKClearing.name, parent)
    local tran = obj.transform
    self.transform = tran

    self.GameExitTimeText = tran:Find("GameExitTimeText"):GetComponent("Text")
    self.GameExitTimeText.text = os.date("%Y.%m.%d %H:%M:%S", self.gameExitTime)
    LuaHelper.GeneratingVar(self.transform, self)

    self.detailPosSelf = tran:Find("@settlement_detail_pos_self")
    self.detailPosRight = tran:Find("@settlement_detail_pos_right")
    self.detailPosLeft = tran:Find("@settlement_detail_pos_left")
    
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

    self.GameHonorNode = self.HonorNode
    self.playerInfo = {}

    for i = 1, DdzPDKModel.maxPlayerNumber do
        local player = ""
        if i == 1 then
            player = "self"
        elseif i == 2 then
            player = "right"
        elseif i == 3 then
            player = "left"
        end

        local playerPos = player
        self.playerInfo[i] = {}
        LuaHelper.GeneratingVar(self["player" .. i], self.playerInfo[i])

        self.playerInfo[i].BPF = self.playerInfo[i].BPF_btn:GetComponent("Image")

        self["settlement_detail_" .. playerPos].gameObject:SetActive(false)
        self["settlement_detail_mld_" .. playerPos].gameObject:SetActive(false)

        EventTriggerListener.Get(self.playerInfo[i].BPF_btn.gameObject).onDown = function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self.playerInfo[i].BPF_tips.gameObject:SetActive(true)
        end
        EventTriggerListener.Get(self.playerInfo[i].BPF_btn.gameObject).onUp = function ()
            self.playerInfo[i].BPF_tips.gameObject:SetActive(false)
        end
    end

    local gameCfg = GameFreeModel.GetGameIDToConfig(DdzPDKModel.baseData.game_id)
    if gameCfg then
        local gameTypeCfg = GameFreeModel.GetGameTypeToConfig(gameCfg.game_type)
        self.gameName_txt.text = gameTypeCfg.name .. "  " .. gameCfg.game_name
    end

    self.isWin = DdzPDKModel.IsMyWin()
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
        end, 3, 1, true)
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
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "pdk_free_js")
    
    self.ext_model = DdzPDKModel
    Event.Brocast("global_sysqx_uichange_msg", {key="dh", panelSelf=self})

	local rplTxt = tran:Find("ExchangeNode/Text"):GetComponent("Text")
	rplTxt.text = "将赢的鲸币兑换为福利券"
end
function DdzPDKClearing:MyRefresh()
    if self.delayTime then
        self.delayTime:Stop()
    end
    self.delayTime = nil
    self.transform.gameObject:SetActive(true)

    self:SetBackAndConfirmBtn()
end
function DdzPDKClearing:UpdateExchange()
    local is_game_over = DdzPDKModel.data.model_status == DdzPDKModel.Model_Status.gameover

    if is_game_over and DdzPDKModel.data.exchange_hongbao and DdzPDKModel.data.exchange_hongbao.is_exchanged == 0 then
        self.ready_btn.transform.localPosition = Vector3.New(268, -393, 0)
        self.ExchangeNode.gameObject:SetActive(true)
        self.ExChongbao.text = StringHelper.ToRedNum(DdzPDKModel.data.exchange_hongbao.hong_bao / 100)
        Event.Brocast("global_sysqx_uichange_msg", {key="dh", panelSelf=self})
    else
        self.ExchangeNode.gameObject:SetActive(false)
        self.ready_btn.transform.localPosition = Vector3.New(0, -440, 0)
    end
end
function DdzPDKClearing:OnExchangeClick()
    local iss = PlayerPrefs.GetInt(MainModel.FreeDHRedHintKey, 0)
    if iss == 1 then
        iss = true
    else
        iss = false
    end
    if not iss then
        local rr = StringHelper.ToRedNum(DdzPDKModel.data.exchange_hongbao.hong_bao / 100)
        local jb = DdzPDKModel.data.settlement_info.score_data[DdzPDKModel.GetPlayerSeat()].score
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
function DdzPDKClearing:on_fg_settle_exchange_hongbao_response(_, data)
    dump(data, "<color=red>on_fg_settle_exchange_hongbao_response</color>")
    if data.result == 0 then
        DdzPDKModel.data.exchange_hongbao.is_exchanged = 1
        self:UpdateExchange()
    end
end

function DdzPDKClearing:IsCanShare()
    return false
end
-- 分享战绩
function DdzPDKClearing:OnShareClick()
    if self:IsCanShare() then
        DDZSharePrefab.Create(
            DdzPDKModel.baseData.game_id,
            {
                myseatno = DdzPDKModel.GetPlayerSeat(),
                dzseatno = DdzPDKModel.data.dizhu,
                bei = self.bei,
                settlement = DdzPDKModel.data.settlement_info,
                gameExitTime = self.gameExitTime,
            }
        )
    end
end

function DdzPDKClearing:InitRect()
    if not DdzPDKModel.data.settlement_info then
        return
    end
    if DdzPDKModel.data.glory_score_count then
        local v1 = DdzPDKModel.data.glory_score_count
        local v2 = DdzPDKModel.data.glory_score_change
        --GameHonorModel.UpdateHonorValue(v1)
    end

    self:SetBackAndConfirmBtn()

    local settlement_info = DdzPDKModel.data.settlement_info

    self.lose_node.parent = self.node_pos.transform
    self.lose_node.localPosition = Vector3.New(0,50,0)
    self.win_node.parent = self.node_pos.transform
    self.win_node.localPosition = Vector3.New(0,50,0)
    --[[self.settlement_detail.parent = self.settlement_detail_pos.transform
    self.settlement_detail.localPosition = Vector3.zero
    self.detail_btn.transform.parent = self.detail_btn_pos.transform
    self.detail_btn.transform.localPosition = Vector3.zero]]
    self.BGImage.gameObject:SetActive(true)
    self.base_rate_title_txt.text = "叫分"

    local isDZ
    if DdzPDKModel.GetPlayerSeat() == DdzPDKModel.data.dizhu then
        isDZ = true
    else
        isDZ = false
    end

    if DdzPDKModel.baseData.room_rent then
        self.room_rent_txt.text = "服务费：" .. DdzPDKModel.baseData.room_rent.asset_count
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
    local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = DdzPDKModel.baseData.game_id,activity_type = ActivityType.Consecutive_Win}, "CheckIsActivated")
    local is_true = a and b
    if is_true then
        self.shengli.gameObject:SetActive(false)
    else
        self.shengli.gameObject:SetActive(self.isWin)
    end

    local sData = settlement_info
    local pData = DdzPDKModel.data.settlement_players_info
    if not pData then
        pData = DdzPDKModel.data.players_info
    end
    local remain_pai = {}
    if sData.remain_pai and next(sData.remain_pai) then
        for k,v in ipairs(sData.remain_pai) do
            remain_pai[v.p] = v.pai
        end
    end
    for i = 1, DdzPDKModel.maxPlayerNumber do
        local pSeat = DdzPDKModel.GetPosToSeatno(i)
        local p_data = pData[pSeat]
        local set_player_ui = function(  )
            URLImageManager.UpdateHeadImage(p_data.head_link, self.playerInfo[i].head_img)
            self.playerInfo[i].name_txt.text = p_data.name
            PersonalInfoManager.SetHeadFarme(self.playerInfo[i].HeadFrameImage_img, p_data.dressed_head_frame)
            VIPManager.set_vip_text(self.playerInfo[i].head_vip_txt,p_data.vip_level)
        end
        if p_data then
            set_player_ui()            
        end
        self.playerInfo[i].base_score_txt.text = remain_pai[pSeat] and #remain_pai[pSeat] or 0

        self.playerInfo[i].times_txt.text = sData.score_data[pSeat].bomb_count or 0
        self.playerInfo[i].loose_score_txt.text = StringHelper.ToCashSymbol(sData.score_data[pSeat].score)
        if sData.score_data[pSeat].type == 2 then
            self.playerInfo[i].guan_img.gameObject:SetActive(true)
            self.playerInfo[i].guan_img.sprite = GetTexture("pdk_settlement_icon_bg")
        elseif sData.score_data[pSeat].type == 7 then
            self.playerInfo[i].guan_img.gameObject:SetActive(true)
            self.playerInfo[i].guan_img.sprite = GetTexture("pdk_settlement_icon_bbp")
        elseif sData.score_data[pSeat].type == 6 then
            self.playerInfo[i].guan_img.gameObject:SetActive(true)
            self.playerInfo[i].guan_img.sprite = GetTexture("pdk_settlement_icon_bp")
        elseif sData.score_data[pSeat].type == 4 then
            self.playerInfo[i].guan_img.gameObject:SetActive(true)
            self.playerInfo[i].guan_img.sprite = GetTexture("pdk_settlement_icon_dg")
        elseif sData.score_data[pSeat].type == 5 then
            self.playerInfo[i].guan_img.gameObject:SetActive(true)
            self.playerInfo[i].guan_img.sprite = GetTexture("pdk_settlement_icon_sg")
        else
            self.playerInfo[i].guan_img.gameObject:SetActive(false)
        end
        self.playerInfo[i].guan_img:SetNativeSize()
    end

    --包赔
    if sData.auto_baopei_pos then
        local i = DdzPDKModel.GetSeatnoToPos(sData.auto_baopei_pos)
        self.playerInfo[i].BPF.sprite = GetTexture("ddz_settlement_icon_bp")
        self.playerInfo[i].BPF.gameObject:SetActive(true)
        self.playerInfo[i].BPF_tips_bg.gameObject:SetActive(false)
    end

    local cfg = GameFreeModel.GetGameIDToConfig(DdzPDKModel.baseData.game_id)
    if cfg and cfg.max_rate then
        self.maxRate_txt.text = cfg.max_rate .. "倍"
        self.maxRate_txt.transform.parent.gameObject:SetActive(true)

        for i = 1, DdzPDKModel.maxPlayerNumber do
            local pSeat = DdzPDKModel.GetPosToSeatno(i)
            local t = self.betMuls and self.betMuls[pSeat] or 0
            if t > cfg.max_rate and sData.score_data[pSeat].score > 0 then
                self.playerInfo[i].BPF.sprite = GetTexture("ddz_settlement_icon_fd")
                self.playerInfo[i].BPF.gameObject:SetActive(true)
                self.playerInfo[i].BPF_tips.gameObject:SetActive(false)
                self.playerInfo[i].BPF_tips_bg.gameObject:SetActive(true)
                self.playerInfo[i].BPF_txt.text = "超过场次最大倍数啦！"
            end
        end
    else
        self.maxRate_txt.transform.parent.gameObject:SetActive(false)
    end
    -- 屏蔽赢封顶
    self.fengding.gameObject:SetActive(false)

    --封顶
    if sData.yingfengding then
        --dump(sData, "<color=green>------------->>> yingfengding:</color>")
        for i = 1, DdzPDKModel.maxPlayerNumber do
            local pSeat = DdzPDKModel.GetPosToSeatno(i)
            if sData.yingfengding[pSeat] == 1 then
                self.playerInfo[i].BPF.sprite = GetTexture("ddz_settlement_icon_yfd")
                self.playerInfo[i].BPF.gameObject:SetActive(true)
                self.playerInfo[i].BPF_tips.gameObject:SetActive(true)
                self.playerInfo[i].BPF_tips_bg.gameObject:SetActive(true)
                self.playerInfo[i].BPF_txt.text = "带多少只能赢多少哦！"
            end
        end
    end

    --破产
    for i = 1, DdzPDKModel.maxPlayerNumber do
        local pSeat = DdzPDKModel.GetPosToSeatno(i)
        local lose_surplus = sData.score_data[pSeat].lose_surplus
        if lose_surplus > 0 and sData.auto_baopei_pos ~= pSeat and sData.score_data[pSeat].score <= 0 then
            self.playerInfo[i].BPF.sprite = GetTexture("ddz_settlement_icon_pc")
            self.playerInfo[i].BPF.gameObject:SetActive(true)
            self.playerInfo[i].BPF_txt.text = "全输光了"
            self.playerInfo[i].BPF_tips.gameObject:SetActive(false)
            self.playerInfo[i].BPF_tips_bg.gameObject:SetActive(true)
        end
    end

    self:OnOff()
end

function DdzPDKClearing:OnOff()
end

--[[
Botton
--]]
function DdzPDKClearing:OnChangedeskClick()
    self:CheckShow1YuanGift(function ()
        DdzPDKModel.HZCheck()
    end)
end

-- 准备
function DdzPDKClearing:OnReadyClick()
    self:CheckShow1YuanGift(function ()
        DdzPDKModel.ZBCheck()
    end)
end

-- 返回
function DdzPDKClearing:OnBackClick()
    if Network.SendRequest("fg_quit_game", nil, "") then
        self:MyExit()
    else
        DDZAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end
end

function DdzPDKClearing:on_fg_gameover_msg()
    self.room_rent_txt.text = "服务费：" .. DdzPDKModel.baseData.room_rent.asset_count
    if DdzPDKModel.data.glory_score_count then
        local v1 = DdzPDKModel.data.glory_score_count
        local v2 = DdzPDKModel.data.glory_score_change
        --GameHonorModel.UpdateHonorValue(v1)
    end

    self:SetBackAndConfirmBtn()
    self:StopFixStuck()
end
function DdzPDKClearing:on_fg_ready_response_code(result)
    if result == 0 then
        self:MyExit()
    end
end
function DdzPDKClearing:on_fg_huanzhuo_response_code(result)
    if result == 0 then
        self:MyExit()
    end
end

function DdzPDKClearing:SetBackAndConfirmBtn()
    local is_game_over = DdzPDKModel.data.model_status == DdzPDKModel.Model_Status.gameover
    if is_game_over then
        --福卡
        TotalRedPrefab.Create(self.transform, {game_id = DdzPDKModel.baseData.game_id})
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

function DdzPDKClearing:TryFixStuck()
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

function DdzPDKClearing:StopFixStuck()
	if self.fixStuck then
		self.fixStuck:Stop()
		self.fixStuck = nil
	end
end

function DdzPDKClearing:GetPlayerScore(seatno)
    local pData = DdzPDKModel.data.settlement_players_info
    if not pData then
        pData = DdzPDKModel.data.players_info
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

function DdzPDKClearing:CheckShow1YuanGift(call)
    if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
    	if call then call() end
    	return
    end

	-- log("<color=yellow>-------------------------------------->>> My seat:%s</color>",DdzPDKModel.data.seat_num)
	local brokeUp = false
	local myScore = MainModel.UserInfo.jing_bi
    local gameCfg = GameFreeModel.GetGameIDToConfig(DdzPDKModel.baseData.game_id)
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
                OneYuanGift.ChekcBroke(call)
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
function DdzPDKClearing:OnRefreshActivityData()
    local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = DdzPDKModel.baseData.game_id}, "CheckShowLS")
    local is_show_ls = a and b
    if self.isWin and DdzPDKModel.data.ls_count > 1 and is_show_ls then
        self.shengli.gameObject:SetActive(false)
        self.liansheng_count_txt.text = DdzPDKModel.data.ls_count
        self.liansheng.gameObject:SetActive(true)
    else
        self.shengli.gameObject:SetActive(self.isWin)
        self.liansheng_count_txt.text = ""
        self.liansheng.gameObject:SetActive(false)
    end
end

function DdzPDKClearing:game_share()
    self:OnShareClick()
end
