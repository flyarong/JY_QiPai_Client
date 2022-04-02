-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"

MjXzClearing = basefunc.class()

MjXzClearing.name = "MjXzClearing_New"

local instance
function MjXzClearing.Create(parent)
    PlayerInfoPanel.Exit()
    GameSpeedyPanel.Hide()

	if not instance then
		instance = MjXzClearing.New(parent)
	else
		instance:MyRefresh()
	end
	return instance
end

function MjXzClearing.isGameOverStatus()
	return MjXzModel.data.model_status == MjXzModel.Model_Status.gameover
end

-- 关闭
function MjXzClearing:Close()
	Event.Brocast("activity_fg_close_clearing")
	Event.Brocast("fg_close_clearing")
	if self.delayShow then
		self.delayShow:Stop()
		self.delayShow = nil
	end
	
    if self.room_rent_time then
        self.room_rent_time:Stop()
        self.room_rent_time = nil
	end

	self:StopFixStuck()
	self:MyExit()
	
	if instance then
		instance:RemoveListener()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
		TotalRedPrefab.Exit()
	end
end

function MjXzClearing:AddMsgListener(lister)
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

function MjXzClearing:MakeLister()
    self.lister = {}
    self.lister["model_fg_gameover_msg"] = basefunc.handler(self, self.on_model_fg_gameover_msg)
    self.lister["fg_ready_response_code"] = basefunc.handler(self, self.on_fg_ready_response_code)
    self.lister["fg_huanzhuo_response_code"] = basefunc.handler(self, self.on_fg_huanzhuo_response_code)
    self.lister["game_share"] = basefunc.handler(self, self.game_share)
    self.lister["fg_settle_exchange_hongbao_response"] = basefunc.handler(self, self.on_fg_settle_exchange_hongbao_response)
end
function MjXzClearing:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end
function MjXzClearing:MyRefresh()
	self:SetBackAndConfirmBtn()
	self:ShowMyself()
end

function MjXzClearing:ctor(parent)
	self.gameExitTime = os.time()

	local parent = parent or GameObject.Find("Canvas/LayerLv2").transform
	self:MakeLister()
	self:AddMsgListener(self.lister)
	local obj = newObject(MjXzClearing.name, parent)
	local tran = obj.transform
	self.transform = tran
	LuaHelper.GeneratingVar(self.transform, self)

    self.GameExitTimeText = tran:Find("GameExitTimeText"):GetComponent("Text")
    self.GameExitTimeText.text = os.date("%Y.%m.%d %H:%M:%S", self.gameExitTime)
	self.fengding = tran:Find("fengding")
	self.HonorNode = tran:Find("HonorNode")
	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		local callback = basefunc.handler(self, self.OnBackClick)
		GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
	end)
    self.ExchangeNode = tran:Find("ExchangeNode")
    self.ExChongbao = tran:Find("ExchangeNode/ExChongbao"):GetComponent("Text")
    self.ExchangeButton = tran:Find("ExchangeNode/ExchangeButton"):GetComponent("Button")
    self.ExchangeButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnExchangeClick()
    end)

	self.ChangedeskButton = tran:Find("ChangedeskButton"):GetComponent("Button")
	self.ChangedeskButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnChangedeskClick()
	end)

	self.ReadyButton = tran:Find("ReadyButton"):GetComponent("Button")
	self.ReadyButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnReadyClick()
	end)
    self.ReadyButton.transform.localPosition = Vector3.New(0, -440, 0)

	self.RoomRentTxt = tran:Find("RoomRentTxt"):GetComponent("Text")
	self.Details = tran:Find("Details")
	self.Players = tran:Find("Players")
	self.bg = tran:Find("bg")
	self.DetailItem = tran:Find("Details/DetailItem").gameObject
	--self.DetailList = tran:Find("Details/Scroll View/Viewport/Content")
	self.ShowCard = false

	EventTriggerListener.Get(self.seeCard_btn.gameObject).onClick = basefunc.handler(self, self.OnSeeCardBtnClicked)
	EventTriggerListener.Get(self.mission_btn.gameObject).onClick = basefunc.handler(self, self.OnMissionBtnClicked)

	self.playerRectObj = {}
	self.playerRect = {}
	for i = 2, 4 do
		local rect = tran:Find("Players/PlayerRect" .. i)
		local tab = {}
		self.playerRectObj[i] = rect
		self.playerRectObj[i].gameObject:SetActive(false)
		self.playerRect[i] = tab
		tab.HeadImage = rect:Find("HeadIcon/HeadImage"):GetComponent("Image")
		tab.HeadFrame = rect:Find("HeadIcon/HeadFrame"):GetComponent("Image")
		tab.head_vip_txt = rect:Find("HeadIcon/@head_vip_txt"):GetComponent("Text")
		tab.CoinCount = rect:Find("HeadIcon/CoinCount"):GetComponent("Text")
		tab.NameText = rect:Find("NameText"):GetComponent("Text")
		--tab.HuTypeText = rect:Find("HuTypeText"):GetComponent("Text")
		--tab.HuSXImage = rect:Find("HuSXImage"):GetComponent("Image")
		--tab.HuSXImageBg = rect:Find("HuSXImageBg"):GetComponent("Image")
		tab.MoneyText1 = rect:Find("MoneyText1"):GetComponent("Text")
		tab.MoneyText2 = rect:Find("MoneyText2"):GetComponent("Text")
		--tab.FanText = rect:Find("FanText"):GetComponent("Text")
		--tab.Rect = rect:Find("Rect")
		--tab.PPRect = rect:Find("Rect/PPRect")
		--tab.SPRect = rect:Find("Rect/SPRect")
		--tab.HPRect = rect:Find("Rect/HPRect")

		tab.piaoIcon = rect:Find("piaoIcon"):GetComponent("Image")
		--tab.daPiaoStakeText = rect:Find("DaPiaoStakeText"):GetComponent("Text")

		--包赔 破产 封顶
		tab.BPF = rect:Find("BPF"):GetComponent("Image")
		tab.BPFBtn = rect:Find("BPF"):GetComponent("Button")
		tab.BPFTips = rect:Find("BPF/BPFTips")
		tab.BPFTipsBG = rect:Find("BPF/BPFTips/BPFTipsBG")
		tab.BPFText = rect:Find("BPF/BPFTips/BPFTipsBG/Image/BPFText"):GetComponent("Text")
		EventTriggerListener.Get(tab.BPFBtn.gameObject).onDown = function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            tab.BPFTips.gameObject:SetActive(true)
        end
        EventTriggerListener.Get(tab.BPFBtn.gameObject).onUp = function ()
            tab.BPFTips.gameObject:SetActive(false)
        end

	end

	local gameCfg = GameFreeModel.GetGameIDToConfig(MjXzModel.baseData.game_id)
	if gameCfg then
		local gameTypeCfg = GameFreeModel.GetGameTypeToConfig(gameCfg.game_type)
		self.gameName_txt.text = gameTypeCfg.name .. "  " .. gameCfg.game_name
	end

	self.LoseNode = tran:Find("Details/LoseNode").gameObject
	self.WinNode = tran:Find("Details/WinNode").gameObject
	self.ContinusWin = tran:Find("Details/ContinusWin").gameObject

    self.ShareBtn = tran:Find("ShareBtn"):GetComponent("Button")
    self.ShareBtn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnShareClick()
    end)

	self.transform.gameObject:SetActive(false)
	self.delayShow = Timer.New(function()
		self:ShowMyself()
	end, 1, 1, false)
	self.delayShow:Start()

	self.room_rent_time = Timer.New(function()
        if IsEquals(self.RoomRentTxt.gameObject) then
            self.RoomRentTxt.gameObject:SetActive(false)
        end
    end, 3, 1, true)
    self.room_rent_time:Start()
    self.ext_model = MjXzModel
    Event.Brocast("global_sysqx_uichange_msg", {key="dh", panelSelf=self})
    local btn_map = {}
    btn_map["top_right"] = {self.tr_node}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "mj_free_js")

	local rplTxt = tran:Find("ExchangeNode/Text"):GetComponent("Text")
	rplTxt.text = "将赢的鲸币兑换为福利券"
end

function MjXzClearing:ShowMyself()
	PlayerInfoPanel.Exit()
    GameSpeedyPanel.Hide()
	if self.delayShow then
		self.delayShow:Stop()
		self.delayShow = nil
		self.transform.gameObject:SetActive(true)
		self:InitRect()
		DOTweenManager.OpenClearUIAnim(self.transform,function(  )
			GameManager.GuideToMiniGame()
		end)
	end
end

function MjXzClearing:InitRect()
	if MjXzModel.data.glory_score_count then
		local v1 = MjXzModel.data.glory_score_count
		local v2 = MjXzModel.data.glory_score_change
		--GameHonorModel.UpdateHonorValue(v1)
	end
	self:SetBackAndConfirmBtn()
	local room_rent = MjXzModel.baseData.room_rent
	if room_rent then
		self.RoomRentTxt.text = "服务费：" .. room_rent.asset_count .. AwardManager.GetAwardName(room_rent.asset_type)
	end
	
	if MjXzModel.data.score_change_list then
		dump(MjXzModel.data.score_change_list, "<color=yellow>==============================================>>> MjXzModel.data.score_change_list:</color>")
		self:GetMyScoreChange(MjXzModel.data.score_change_list)
	else
		log("<color=yellow>---------------------------------------->>>> No score change list!</color>")
	end

	local clearData = MjXzModel.data.settlement_info
	local playerNum = #clearData
	
	--for i = 1, #clearData do
	for _, data in ipairs(clearData) do
		local i = MjXzModel.GetSeatnoToPos (data.seat_num)
		if i == 1 then
			self:CalcMyResult(data)
		else
			if playerNum == 2 then
				i = 3
			end

			self:InitOthers(i, data)
		end
	end

	self:OnOff()
	
	local cfg = GameFreeModel.GetGameIDToConfig(MjXzModel.baseData.game_id)
    if cfg and cfg.max_rate then
        self.maxRate_txt.text = cfg.max_rate .. "倍"
        self.maxRate_txt.transform.parent.gameObject:SetActive(true)
    else
        self.maxRate_txt.transform.parent.gameObject:SetActive(false)
	end
	if GuideLogic then
		GuideLogic.CheckRunGuide("free_js")
	end
end
function MjXzClearing:UpdateExchange()
    local is_game_over = MjXzModel.data.model_status == MjXzModel.Model_Status.gameover

    if is_game_over and MjXzModel.data.exchange_hongbao and MjXzModel.data.exchange_hongbao.is_exchanged == 0 then
        self.ReadyButton.transform.localPosition = Vector3.New(268, -393, 0)
        self.ExChongbao.text = StringHelper.ToRedNum(MjXzModel.data.exchange_hongbao.hong_bao / 100)
        Event.Brocast("global_sysqx_uichange_msg", {key="dh", panelSelf=self})
        self.ExchangeNode.gameObject:SetActive(true)
    else
        self.ExchangeNode.gameObject:SetActive(false)
        self.ReadyButton.transform.localPosition = Vector3.New(0, -440, 0)
    end
end
function MjXzClearing:OnExchangeClick()
    local iss = PlayerPrefs.GetInt(MainModel.FreeDHRedHintKey, 0)
    if iss == 1 then
        iss = true
    else
        iss = false
    end
    if not iss then
        local rr = StringHelper.ToRedNum(MjXzModel.data.exchange_hongbao.hong_bao / 100)
        local jb = self.my_score
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
function MjXzClearing:on_fg_settle_exchange_hongbao_response(_, data)
    dump(data, "<color=red>on_fg_settle_exchange_hongbao_response</color>")
    if data.result == 0 then
    	MjXzModel.data.exchange_hongbao.is_exchanged = 1
    	self:UpdateExchange()
    end
end

function MjXzClearing:InitOthers(i, data)
	self.playerRectObj[i].gameObject:SetActive(true)
	--local data = clearData[i]
	local rect = self.playerRect[i]
	local seatno = data.seat_num
	local base = MjXzModel.data.game_players_info[seatno]
	URLImageManager.UpdateHeadImage(base.head_link, rect.HeadImage)
	PersonalInfoManager.SetHeadFarme(rect.HeadFrame, base.dressed_head_frame)
	VIPManager.set_vip_text(rect.head_vip_txt,base.vip_level)
	rect.NameText.text = base.name
	local hupai
	--dump(data.settle_data, "胡牌")
	dump(data, "胡牌")

	--- 飘的多少倍
	if MjXzModel.daPiao then
		local piaoNum = MjXzModel.data.playerInfo[seatno].piaoNum
		if piaoNum and (piaoNum == 0 or piaoNum == 1 or piaoNum == 3 or piaoNum == 5 ) then
			
			if piaoNum > 0 then
				rect.piaoIcon.gameObject:SetActive(true)
				--rect.piaoIcon.sprite = GetTexture( MjXzModel.piaoIconVec[piaoNum] )
			else
				rect.piaoIcon.gameObject:SetActive(false)
			end
		else
			rect.piaoIcon.gameObject:SetActive(false)
		end
		--- 总共有几个人飘
		--[[local piaoPlayerNum = MjXzModel.GetDaPiaoPlayerNum()
		if piaoPlayerNum > 0 then
			rect.daPiaoStakeText.gameObject:SetActive(true)
		else
			rect.daPiaoStakeText.gameObject:SetActive(false)
		end

		if piaoPlayerNum == 1 then
			rect.daPiaoStakeText.text = string.format("%d人飘底分%d",piaoPlayerNum,2*MjXzModel.data.init_stake)
		elseif piaoPlayerNum >= 2 then
			rect.daPiaoStakeText.text = string.format("%d人飘底分%d",piaoPlayerNum,4*MjXzModel.data.init_stake)
		end]]
	else
		rect.piaoIcon.gameObject:SetActive(false)
		--rect.daPiaoStakeText.gameObject:SetActive(false)
	end

	--[[if data.settle_data.settle_type == "hu" then
		rect.HuTypeText.text = self:GetHuPaiType(data.settle_data,data.pg_pai)
		rect.FanText.text = data.settle_data.sum .. "倍"
		rect.HuSXImageBg.gameObject:SetActive(true)
		rect.HuSXImage.gameObject:SetActive(true)
		rect.HuSXImage.sprite = GetTexture("mj_game_icon_hu" .. i)

		if data.settle_data.hu_pai then
			MjCard.Create(rect.HPRect, MjXzModel.PaiType.hu, data.settle_data.hu_pai)
			hupai = data.settle_data.hu_pai
		end
	else
		if data.settle_data.settle_type == "ting" then
			rect.HuTypeText.text = NOR_MAJIANG_SETTLE_TYPE[data.settle_data.settle_type] .. self:GetHuPaiType(data.settle_data,data.pg_pai)
		else
			rect.HuTypeText.text = NOR_MAJIANG_SETTLE_TYPE[data.settle_data.settle_type]
		end
		rect.FanText.text = ""
		rect.HuSXImage.gameObject:SetActive(false)
		rect.HuSXImageBg.gameObject:SetActive(false)
	end]]
	
	local score = 0
	if data.settle_data.score then
		score = data.settle_data.score
	end
	if score > 0 then
		rect.MoneyText1.text = "+" .. StringHelper.ToCash(score)
		rect.MoneyText2.text = ""
	elseif score < 0 then
		rect.MoneyText1.text = ""
		rect.MoneyText2.text = "-" .. StringHelper.ToCash(score)
	elseif score == 0 then
		if data.settle_data.settle_type == "hu" then
			rect.MoneyText1.text = "+0"
			rect.MoneyText2.text = ""
		else
			rect.MoneyText1.text = "+0" 
			rect.MoneyText2.text = ""
		end
	end
	
	rect.CoinCount.text = StringHelper.ToCash(self:GetPlayerScore(seatno))
	
	--self:CalcMyResult(data)

	--[[if data.shou_pai then
		if hupai then
			for idx = 1, #data.shou_pai, 1 do
				if data.shou_pai[idx] == hupai then
					table.remove(data.shou_pai, idx)
					break
				end
			end
		end
		
		normal_majiang.sort_pai(data.shou_pai)
		for i,v in ipairs(data.shou_pai) do
			MjCard.Create(rect.SPRect, MjXzModel.PaiType.sp, v)
		end
	end]]
	--[[if data.pg_pai then
		for i,v in ipairs(data.pg_pai) do
			MjCard.Create(rect.PPRect, v.pg_type, v.pai)
		end
	end]]

	self:InitBPF(data, self.playerRect[i].BPF)
end

function MjXzClearing:CalcMyResult(data)
	local seatno = data.seat_num
	if MjXzModel.GetRealPlayerSeat () == seatno then
		self.huindex = 1

		self.my_shou_pai = data
		self.multi = data.settle_data.multi

		if data.settle_data.settle_type == "hu" then
		    local ui_config = GameFreeModel.GetGameIDToConfig(MjXzModel.baseData.game_id)
		    local share_fan_shu = 3
		    if ui_config.game_type == "game_MjXzER3D" then
		    	share_fan_shu = 4
		    end
			local pai_type,hu_type = IsMjShareCondition(data.settle_data.multi, share_fan_shu)
			self.pai_type = pai_type
			self.hu_type = hu_type
		end

		local score = 0
		if data.settle_data.score then
			score = data.settle_data.score
		end

		local isWin = (score > 0 or (score == 0 and data.settle_data.settle_type == "hu"))
		self.my_score = score
		    local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator"}, "IsBigUI")
    local is_show_big_ui = a and not b
    if not is_show_big_ui then
			self:OnShareClick()
		end

		if IsEquals(self.ShareBtn) then
			if self:IsCanShare() then
				self.ShareBtn.gameObject:SetActive(true)
			else
				self.ShareBtn.gameObject:SetActive(false)
			end
		end
		
		ExtendSoundManager.PlaySound(isWin and audio_config.game.sod_game_win.audio_name or audio_config.game.sod_game_lose.audio_name)
		self.LoseNode:SetActive(not isWin)
		self.winCoin_txt.text = (score >= 0 and "+" .. StringHelper.ToCash(score) or "")
		self.looseCoin_txt.text = (score >= 0 and "" or "-" .. StringHelper.ToCash(score))
		local a,b = GameButtonManager.RunFun({gotoui="sys_act_operator",game_id = MjXzModel.baseData.game_id}, "CheckShowLS")
		local is_show_ls = a and b
		if isWin and MjXzModel.data.ls_count > 1 and is_show_ls then
			self.WinNode:SetActive(false)
			self.count_txt.text = MjXzModel.data.ls_count
			self.ContinusWin:SetActive(true)
		else
			self.WinNode:SetActive(isWin)
			self.count_txt.text = ""
			self.ContinusWin:SetActive(false)
		end

		if MjXzModel.daPiao then
			local piaoNum = MjXzModel.data.playerInfo[seatno].piaoNum
			local icon = self.Details:Find("piaoIcon")
			if icon then
				icon.gameObject:SetActive(piaoNum and piaoNum > 0)
			end
		end

		self:InitDetailList(data)
		self:CheckShow1YuanGift()
	end
end

function MjXzClearing:CreateDetailItem(col1, col2, col3, col4, isBroke)
	local item = GameObject.Instantiate(self.DetailItem, self.detail_content)
	item:SetActive(true)
	item.transform:Find("col1"):GetComponent("Text").text = col1
	item.transform:Find("col2"):GetComponent("Text").text = col2 .. "倍"
	item.transform:Find("col3"):GetComponent("Text").text = col3
	item.transform:Find("col4"):GetComponent("Text").text = col4

	local cfg = GameFreeModel.GetGameIDToConfig(MjXzModel.baseData.game_id)
	local icon = item.transform:Find("col5")
	icon.gameObject:SetActive(isBroke)
	if not isBroke and cfg and cfg.max_rate and col2 > cfg.max_rate then
		icon.gameObject:GetComponent("Image").sprite = GetTexture("ddz_settlement_icon_fd")
		icon.gameObject:SetActive(true)
	end
end

function MjXzClearing.GetGangName(op)
	return (op == "wg" and "刮风" or "下雨")
end

function MjXzClearing.GetGangPlusCount(op)
	return (op == "wg" and 1 or 2)
end

function MjXzClearing.GetAffectedPlayerPos(mySeat, affected)
	local p = {}
	if #MjXzModel.data.settlement_info == 2 then
		p[1] = "对家"
	else
		for _, pos in ipairs(affected) do
			if pos == (mySeat + 1) or pos == (mySeat - 3) then
				p[#p + 1] = "下家"
			elseif pos == (mySeat + 3) or pos == (mySeat - 1) then
				p[#p + 1] = "上家"
			elseif pos == (mySeat + 2) or pos == (mySeat - 2) then
				p[#p + 1] = "对家"
			end
		end
	end

	if #p == 3 then
		return "三家"
	elseif #p == 2 then
		return p[1] .. "," .. p[2]
	else
		return p[1]
	end
end

function MjXzClearing:ShowDetailsAndPlayers(isShow)
	self.Details.gameObject:SetActive(isShow)
	self.Players.gameObject:SetActive(isShow)
	self.bg.gameObject:SetActive(isShow)

	self.seeCard_txt.text = (isShow and "查看牌型" or "查看结算")
	-- self.GameExitTimeText.transform.localPosition = self.GameExitTimeText.transform.localPosition + Vector3.New(0, 130, 0) * (isShow and -1 or 1)
	-- self.fengding.localPosition = self.fengding.localPosition + Vector3.New(0, 130, 0) * (isShow and -1 or 1)
	self.ReadyButton.transform.localPosition = self.ReadyButton.transform.localPosition + Vector3.New(0, 170, 0) * (isShow and -1 or 1)
	self.ExchangeNode.transform.localPosition = self.ExchangeNode.transform.localPosition + Vector3.New(0, 170, 0) * (isShow and -1 or 1)
end

function MjXzClearing:GetPlayerScore(seatno)
	local myScore = 0
	for _, info in ipairs(MjXzModel.data.game_players_info) do
		if info.seat_num == seatno then	
			myScore = info.score
			break
		end
	end
	return myScore
end

function MjXzClearing:InitBPF(data, bpf)
	dump(data, "<color=yellow>--->>>MjXzClearing:InitBPF</color>")
	local yingfengding = MjXzModel.data.yingfengding
	local sData = data.settle_data
	local msg = ""
	local show = false
	local showMsg = false
	local iconImg = "ddz_settlement_icon_bp_normal_mj_common"
	local cfg = GameFreeModel.GetGameIDToConfig(MjXzModel.baseData.game_id)
	dump(cfg, "<color=yellow>game id:" .. MjXzModel.baseData.game_id .. ", config</color>")

	--包赔
	if sData.auto_baopei_pos and sData.auto_baopei_pos == data.seat_num then
        show = true
	end
	
	local t = 1
	if sData.multi then
		for k,v in pairs(sData.multi) do
			t = t * v * 2
		end
	end
	if cfg and cfg.max_rate and sData.sum and sData.score > 0 and t > cfg.max_rate then
		msg = "超过场次最大倍数啦！"
		iconImg = "ddz_settlement_icon_fd"
		show = true
	end

	--封顶
	if yingfengding then
		for i, v in ipairs(yingfengding) do
			if i == data.seat_num and v == 1 then
				msg = "带多少只能赢多少哦！"
				iconImg = "ddz_settlement_icon_yfd"
				show = true
				showMsg = true
				break
			end
		end
	end

	--破产
	--[[if sData.lose_surplus then
		local v = sData.lose_surplus
		if v > 0 and data.settle_data.score <= 0 then
			msg = "鲸币不够继续游戏了！"
			iconImg = "ddz_settlement_icon_pc"
			show = true
		end
	end]]
	if MjXzModel.data.game_bankrupt then
        for i, d in ipairs(MjXzModel.data.game_bankrupt) do
            if d == 1 and i == data.seat_num then
                msg = "鲸币不够继续游戏了！"
				iconImg = "ddz_settlement_icon_pc"
				show = true
				break
            end
        end
    end

	if show then
		local tips = bpf.transform:Find("BPFTips")
		local bg = tips:Find("BPFTipsBG")
		bpf.sprite = GetTexture(iconImg)
		bpf.gameObject:SetActive(true)
		bg.transform:Find("Image/BPFText"):GetComponent("Text").text = msg
		bg.gameObject:SetActive(true)
		if showMsg then
			tips.gameObject:SetActive(true)
		end
	end
end

function MjXzClearing:IsCanShare()
	if GameGlobalOnOff.ShowOff and self.my_score > 0 and (self.pai_type or self.hu_type) then
		return true
	end
	return false
end
function MjXzClearing:OnOff()
end

function MjXzClearing:GetFanShu(data)
	local fan = 0
	for k,v in pairs(data) do
		fan = fan + v
	end
	return fan
end

function MjXzClearing:GetHuPaiType(settle_data,pg_pai)
	local huPaiType = ""
	local hu_type_str = ""
	local dai_geng_str = ""
	local gang_str = ""
	
	if settle_data.hu_type	then
		if settle_data.hu_type == "zimo" then
			if settle_data.multi.tian_hu or settle_data.multi.di_hu then
				hu_type_str = ""
			else
				hu_type_str = NOR_MAJIANG_HU_TYPE[settle_data.hu_type] .. "x" .. math.pow(2, 1)
			end
		elseif settle_data.hu_type == "qghu" then
			hu_type_str = NOR_MAJIANG_HU_TYPE[settle_data.hu_type] .. "x" .. math.pow(2, 1)
		else
			hu_type_str = NOR_MAJIANG_HU_TYPE[settle_data.hu_type]
		end
	end
	
	self.geng = 0
	if settle_data.multi and next(settle_data.multi) then
		dump(settle_data.multi, "<color=green>multi胡牌数据：</color>")
		for k,v in pairs(settle_data.multi) do
			if v then
				if k == "dai_geng" then
					self.geng = v
					dai_geng_str = NOR_MAJIANG_MULTI_TYPE[k] .. "x" .. math.pow(2, v)
				elseif k == "zimo" or k == "qiangganghu" then --忽略自摸和抢杠胡
				elseif k == "di_hu" then
					huPaiType = NOR_MAJIANG_MULTI_TYPE[k] .. "x" .. math.pow(2, v) .. " " .. huPaiType
				else
					huPaiType = huPaiType .. " " .. NOR_MAJIANG_MULTI_TYPE[k] .. "x" .. math.pow(2, v)
				end
			end
		end
	else
		huPaiType = NOR_MAJIANG_MULTI_TYPE.ping_hu
	end	

	local ag = 0
	local wg = 0
	local zg = 0
	if pg_pai then
		for idx = 1, #pg_pai, 1 do
			if pg_pai[idx].gang_type == "ag" then
				ag = pg_pai[idx].sum
			elseif pg_pai[idx].gang_type == "wg" then
				wg = pg_pai[idx].sum
			elseif pg_pai[idx].gang_type == "zg" then
				zg = pg_pai[idx].sum
			end
		end
	end
	if ag > 0 then
		gang_str = gang_str .. " " .. NOR_GANG_TYPE.ag .. "+" .. ag
	end
	if wg > 0 then
		gang_str = gang_str .. " " .. NOR_GANG_TYPE.wg .. "+" .. wg
	end
	if zg > 0 then
		gang_str = gang_str .. " " .. NOR_GANG_TYPE.zg .. "+" .. zg
	end

	return hu_type_str .. " " .. huPaiType .. " " .. dai_geng_str .. gang_str
end

function MjXzClearing:MyExit()
	if self.game_btn_pre then
        self.game_btn_pre:MyExit()
        self.game_btn_pre = nil
    end
end

--[[
Botton
--]]
-- 换桌
local hz_call = function ()
    Network.SendRequest("fg_huanzhuo", nil, "请求换桌")
end
local zb_call = function ()
    Network.SendRequest("fg_ready", nil, "请求准备")
end
function MjXzClearing:OnChangedeskClick()
	self:CheckShow1YuanGift(function ()
		MjXzModel.HZCheck()
	end)
end

-- 准备
function MjXzClearing:OnReadyClick()
	self:CheckShow1YuanGift(function ()
		MjXzModel.ZBCheck()
	end)
end

-- 返回
function MjXzClearing:OnBackClick()
	if Network.SendRequest("fg_quit_game", nil, "") then
		self:Close()
    else
		MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end
function MjXzClearing:OnShareClick()
	if not self:IsCanShare() then return end
	MJSharePrefab.Create(MjXzModel.baseData.game_id, {time=self.gameExitTime, my_score = self.my_score, multi = self.multi,
		paiType=self.pai_type, huType=self.hu_type, pai=self.my_shou_pai, geng=self.geng, huindex=self.huindex})
end
function MjXzClearing:on_fg_ready_response_code(result)
	if result == 0 then
		self:Close()
	end
end
function MjXzClearing:on_fg_huanzhuo_response_code(result)
	if result == 0 then
		self:Close()
	end
end

function MjXzClearing:on_model_fg_gameover_msg()
	self.BackButton.gameObject:SetActive(true)
	self.ChangedeskButton.gameObject:SetActive(true)
	self.ReadyButton.gameObject:SetActive(true)
	self:SetBackAndConfirmBtn()
	local room_rent = MjXzModel.baseData.room_rent
	if room_rent then
		self.RoomRentTxt.text = room_rent.asset_count .. AwardManager.GetAwardName(room_rent.asset_type)
	end
    if MjXzModel.data.glory_score_count then
		local v1 = MjXzModel.data.glory_score_count
		local v2 = MjXzModel.data.glory_score_change
		--GameHonorModel.UpdateHonorValue(v1)
	end
	
	self:StopFixStuck()

end
function MjXzClearing:SetBackAndConfirmBtn()
	local is_game_over = MjXzClearing.isGameOverStatus()
    if is_game_over then
        --福卡
        TotalRedPrefab.Create(self.transform, {game_id = MjXzModel.baseData.game_id})
    end
	self.BackButton.gameObject:SetActive(is_game_over)
	self.ChangedeskButton.gameObject:SetActive(is_game_over)
	self.ReadyButton.gameObject:SetActive(is_game_over)

	self:TryFixStuck()
    self:UpdateExchange()
end

function MjXzClearing:TryFixStuck()
	if not self.fixStuck then
		self.fixStuck = Timer.New(function()
			logWarn("<color=yellow>--->>>(MJ)Player stucked in game over!</color>")
			self.BackButton.gameObject:SetActive(true)
			self.ChangedeskButton.gameObject:SetActive(true)
			self.ReadyButton.gameObject:SetActive(true)
			self.fixStuck = nil
		end, 5, 1, false)
		self.fixStuck:Start()
	end
end

function MjXzClearing:StopFixStuck()
	if self.fixStuck then
		self.fixStuck:Stop()
		self.fixStuck = nil
	end
end

function MjXzClearing:OnSeeCardBtnClicked()
	self.ShowCard = not self.ShowCard
	self:ShowDetailsAndPlayers(not self.ShowCard)
end

function MjXzClearing:OnMissionBtnClicked()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	GameTaskPanel.Create()
end

function MjXzClearing:GetPlayerScore(seatno)
	local myScore = 0
	for _, info in ipairs(MjXzModel.data.game_players_info) do
		if info.seat_num == seatno then	
			myScore = info.score
			break
		end
	end
	return myScore
end

function MjXzClearing:CheckShow1YuanGift(call)
	if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
		if call then call() end
		return
	end

	log("<color=blue>-------------------------------------->>> My seat:" .. MjXzModel.data.seat_num .. "</color>")
	local brokeUp = false
	local myScore = MainModel.UserInfo.jing_bi
	local gameCfg = GameFreeModel.GetGameIDToConfig(MjXzModel.baseData.game_id)
	log("<color=blue>--------------------------------->>> gameType:</color>" .. gameCfg.game_name)
	print(myScore)

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
 
	if brokeUp then
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

function MjXzClearing:GetHuTypeShort(settleData, pg_pai)
	local s = self:GetHuPaiType(settleData, pg_pai)
	local StrList = {}
	log("<color=yellow>HuType:" .. s .. "</color>")
	string.gsub(s,'[^'.. ' ' ..']+', function (w)
		table.insert(StrList,w)
	end)

	local l = math.min(#StrList, 3)
	local result = "(" .. StrList[1]
	if l > 2 then
		result = result .. " " .. StrList[2] .. "…"
	elseif l == 2 then
		result = result .. " " .. StrList[2]
	end
	result = result .. ")"

	return result
end

function MjXzClearing:GetMyScoreChange(dataList)
	local index = 1
	local mySeat = MjXzModel.data.seat_num
	self.scoreDetails = {}

	for _, data in pairs(dataList) do
		local type = data.type
		local realScore = 0
		local myScore = 0
		local getter = {}
		local sender = {}
		
		for _, s in ipairs(data.data) do
			if s.cur_p == mySeat then
				myScore = s.score
				realScore = s.score - s.lose_surplus
			end
			
			if (s.score - s.lose_surplus) > 0 then
				getter[#getter + 1] = s.cur_p
			else
				sender[#sender + 1] = s.cur_p
			end
		end
	
		if realScore ~= 0 then
			self.scoreDetails[index] = {}
			local sd = self.scoreDetails[index]
			sd.score = realScore
			sd.getScore = myScore
			sd.data = data.data
			sd.affected = (sd.score > 0 and sender or getter)
			sd.op = type
		
			if type == "ag" or type == "wg" or type == "zg" then
				sd.op_type = "gang"
			elseif type == "zimo" or type == "pao" or type == "qghu" or type == "tian_hu" then
				sd.op_type = "hu"
			elseif type == "cj" or type == "chz" or type == "ts" then
				sd.op_type = "settle"
			elseif type == "zhuan_yu" then
				sd.op_type = "zhuan_yu"
			end

			index = index + 1
		end
	end
end

function MjXzClearing:InitDetailList(data)
	--dump(self.scoreDetails, "<color=green>---------------------------------->>>> score details:</color>")
	--dump(data, "<color=green>===============================================>>> settle data:</color>")
	--dump(MjXzModel.data.settlement_info, "<color=green>===============================================>>> settle info:</color>")

	if self.scoreDetails and #self.scoreDetails > 0 then
		local gameCfg = GameFreeModel.GetGameIDToConfig(MjXzModel.baseData.game_id)
		local seatno = data.seat_num
		local settleInfo = MjXzModel.data.settlement_info
		local details = self.scoreDetails
		local mySeat = MjXzModel.data.seat_num
		local piaoNum = 0

		if MjXzModel.data.playerInfo then
			for i = 1, #MjXzModel.data.playerInfo do
				if MjXzModel.data.playerInfo[i].piaoNum and MjXzModel.data.playerInfo[i].piaoNum > 0 then
					piaoNum = piaoNum + MjXzModel.data.playerInfo[i].piaoNum
				end
			end
			log("<color=yellow>--------------->>>> player piao count:" .. piaoNum .. "</color>")
		end

		for n = #details, 1, -1 do
			local content = {}
			local opType = details[n].op_type
			local op = details[n].op
			if opType ~= "settle" then
				local op = details[n].op
				if op == "zhuan_yu" then
					content[1] = details[n].score > 0 and "被转雨" or "转雨"
					content[2] = math.floor(math.abs(details[n].score)/(gameCfg.base * math.pow(2, piaoNum)))
				elseif opType == "gang" then
					content[1] = (details[n].score < 0 and "被" or "" ) .. MjXzClearing.GetGangName(op)
					content[2] = MjXzClearing.GetGangPlusCount(op)
				elseif opType == "hu" then
					if details[n].score > 0 then
						if op == "qghu" then
							content[1] = "抢杠胡" .. self:GetHuTypeShort(data.settle_data, data.pg_pai)
						else
							content[1] = "胡" .. self:GetHuTypeShort(data.settle_data, data.pg_pai)
						end
						content[2] = data.settle_data.sum
					else
						for _, seatId in ipairs(details[n].affected) do
							local isBroke = false
							for _, d in ipairs(details[n].data) do
								if mySeat == d.cur_p and d.lose_surplus > 0 then
									isBroke = true
									break
								end
							end

							for _, info in ipairs(settleInfo) do
								if info.seat_num == seatId then
									if op == "qghu" then
										content[1] = "被抢杠胡" .. self:GetHuTypeShort(info.settle_data, info.pg_pai)
									elseif op == "zimo" or op == "tian_hu" then
										content[1] = "被自摸" .. self:GetHuTypeShort(info.settle_data, info.pg_pai)
									elseif op == "zhuan_yu" then
										content[1] = "转雨" .. self:GetHuTypeShort(info.settle_data, info.pg_pai)
									else
										content[1] = "点炮" .. self:GetHuTypeShort(info.settle_data, info.pg_pai)
									end
									content[2] = info.settle_data.sum
									self:CreateDetailItem(content[1], content[2], (details[n].score < 0 and "-" or "+") .. StringHelper.ToCash(math.abs(details[n].getScore)), MjXzClearing.GetAffectedPlayerPos(seatno, {seatId}), isBroke)
									break
								end
							end
						end
					end
				end
				
				if opType == "gang" or (opType == "hu" and details[n].score > 0) or op == "zhuan_yu" then
					self:CreateDetailItem(content[1], content[2], (details[n].score < 0 and "-" or "+") .. StringHelper.ToCash(math.abs(details[n].getScore)), MjXzClearing.GetAffectedPlayerPos(seatno, details[n].affected), details[n].score ~= details[n].getScore)
				end
			else
				if op == "cj" then
					content[1] = (details[n].score > 0 and "" or "被") .. "查大叫"
				elseif op == "chz" then
					content[1] = (details[n].score > 0 and "" or "被") .. "查花猪"
				elseif op == "ts" then
					content[1] = (details[n].score < 0 and "" or "被") .. "退税"
				end
				
				for _, d in ipairs(details[n].data) do
					local rs = (d.score - d.lose_surplus)
					local t = 0
					if (details[n].score > 0 and rs < 0) or (details[n].score < 0 and rs > 0) then
						if op == "cj" then
							if details[n].score > 0 then
								content[1] = content[1] .. self:GetHuTypeShort(data.settle_data, data.pg_pai)
								t = data.settle_data.sum or 0
							else
								for _, info in ipairs(settleInfo) do
									if info.seat_num == d.cur_p then
										content[1] = content[1] .. self:GetHuTypeShort(info.settle_data, info.pg_pai)
										t = info.settle_data.sum or 0
									end
								end
							end
						end

						content[2] = t > 0 and t or math.ceil(math.abs(rs)/(gameCfg.base * math.pow(2, piaoNum)))
						self:CreateDetailItem(content[1], content[2], (rs > 0 and "-" or "+") .. StringHelper.ToCash(math.abs(d.score)), MjXzClearing.GetAffectedPlayerPos(seatno, {d.cur_p}), d.lose_surplus ~= 0)
					end
				end
			end
		end
	end
	
	self.scoreDetails = nil
	local bpfBtn = self.Details:Find("BPF"):GetComponent("Button")
	local bpfTips = self.Details:Find("BPF/BPFTips")
	EventTriggerListener.Get(bpfBtn.gameObject).onDown = function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		bpfTips.gameObject:SetActive(true)
	end
	EventTriggerListener.Get(bpfBtn.gameObject).onUp = function ()
		bpfTips.gameObject:SetActive(false)
	end
	self:InitBPF(data, self.Details:Find("BPF"):GetComponent("Image"))
end

function MjXzClearing:FormatNum(num)
	local intNum = math.floor(num)
	if (num - intNum) > 0 then
		intNum = math.floor(num * 10)
		if ((num * 10) - intNum) > 0 then
			return string.format("%.2f", num)
		else
			return string.format("%.1f", num)
		end
	else
		return intNum
	end
end

function MjXzClearing:game_share()
	self:OnShareClick()
end