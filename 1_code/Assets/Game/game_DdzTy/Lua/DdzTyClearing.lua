-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"

DdzTyClearing = basefunc.class()

DdzTyClearing.name = "DdzTyClearing"


local instance
function DdzTyClearing.Create(parent)
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

	if not instance then
		instance = DdzTyClearing.New(parent)
	end
	return instance
end
-- 关闭
function DdzTyClearing.Close()
	if instance then
		instance:RemoveListener()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end
function DdzTyClearing:MakeLister()
    self.lister = {}
end
function DdzTyClearing:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function DdzTyClearing:ctor(parent)
	parent = parent or GameObject.Find("Canvas/LayerLv2").transform
	self:MakeLister()
	local obj = newObject(DdzTyClearing.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
		self:OnBackClick()
	end)
	self.ConfirmButton = tran:Find("ConfirmButton"):GetComponent("Button")
	self.ConfirmButton.onClick:AddListener(function ()
		self:OnConfirmClick()
	end)
	self.GotoMatchButton = tran:Find("GotoMatchButton"):GetComponent("Button")
	self.GotoMatchButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		local state = gameMgr:CheckUpdate("game_MatchHall")
        if state == "Install" or state == "Update" then
            HintPanel.Create(1, "请返回大厅更新游戏")
        else
			if Network.SendRequest("tydfg_quit_game") then
				MainLogic.ExitGame()
                MainLogic.GotoScene("game_MatchHall")
            end
        end
	end)
	if not GameGlobalOnOff.Diversion then
		self.GotoMatchButton.gameObject:SetActive(false)
	end
	
	self.SettlementDetail = tran:Find("Genter/Self/SettlementDetail")
	self.DetailBtn = tran:Find("Genter/Self/DetailBtn"):GetComponent("Button")
	self.DetailBtn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.SettlementDetail.gameObject:SetActive(not self.SettlementDetail.gameObject.activeSelf)
	end)

	self.ShareBtn = tran:Find("ShareBtn"):GetComponent("Button")
	self.ShareBtn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		 self:OnShareClick()
	end)

	self.LoseNode = tran:Find("LoseNode").gameObject
	self.WinNode = tran:Find("WinNode").gameObject
	-- self.WinClearingText = tran:Find("WinNode/ClearingImage/ClearingText"):GetComponent("Text")
	-- self.LoseClearingText = tran:Find("LoseNode/ClearingImage/ClearingText"):GetComponent("Text")

	self.MenZhuaRateText = tran:Find("Genter/Self/SettlementDetail/men"):GetComponent("Text")
	self.ZPRate = tran:Find("Genter/Self/SettlementDetail/TextZP"):GetComponent("Text")
	self.DaoRateText = tran:Find("Genter/Self/SettlementDetail/dao"):GetComponent("Text")
	self.LaRateText = tran:Find("Genter/Self/SettlementDetail/la"):GetComponent("Text")
	self.BoomRateText = tran:Find("Genter/Self/SettlementDetail/bomb"):GetComponent("Text")
	self.CTRate = tran:Find("Genter/Self/SettlementDetail/TextCT"):GetComponent("Text")
	self.CTRateText = tran:Find("Genter/Self/SettlementDetail/chuntian"):GetComponent("Text")
	self.AllRateText = tran:Find("Genter/Self/SettlementDetail/allScore"):GetComponent("Text")
	self.RoomRentText = tran:Find("RoomRentText"):GetComponent("Text")

	self.playerInfo = {}
	self.playerInfo[1] = {}
	self.playerInfo[1].HeadFrame = tran:Find("Genter/Self/HeadBG"):GetComponent("Image")
	self.playerInfo[1].head_vip_txt = tran:Find("Genter/Self/@head_vip_txt"):GetComponent("Text")
	self.playerInfo[1].Head = tran:Find("Genter/Self/Head"):GetComponent("Image")
	self.playerInfo[1].RoleIcon = tran:Find("Genter/Self/RoleIcon"):GetComponent("Image")
	self.playerInfo[1].BaseScore = tran:Find("Genter/Self/BaseScore"):GetComponent("Text")
	self.playerInfo[1].CurScore = tran:Find("Genter/Self/CurScore"):GetComponent("Text")
	self.playerInfo[1].AllScore = tran:Find("Genter/Self/AllScore"):GetComponent("Text")
	self.playerInfo[2] = {}
	self.playerInfo[2].HeadFrame = tran:Find("Genter/Right/HeadBG"):GetComponent("Image")
	self.playerInfo[2].head_vip_txt = tran:Find("Genter/Right/@head_vip_txt"):GetComponent("Text")
	self.playerInfo[2].Head = tran:Find("Genter/Right/Head"):GetComponent("Image")
	self.playerInfo[2].RoleIcon = tran:Find("Genter/Right/RoleIcon"):GetComponent("Image")
	self.playerInfo[2].BaseScore = tran:Find("Genter/Right/BaseScore"):GetComponent("Text")
	self.playerInfo[2].CurScore = tran:Find("Genter/Right/CurScore"):GetComponent("Text")
	self.playerInfo[2].AllScore = tran:Find("Genter/Right/AllScore"):GetComponent("Text")
	self.playerInfo[3] = {}
	self.playerInfo[3].HeadFrame = tran:Find("Genter/Left/HeadBG"):GetComponent("Image")
	self.playerInfo[3].head_vip_txt = tran:Find("Genter/Left/@head_vip_txt"):GetComponent("Text")
	self.playerInfo[3].Head = tran:Find("Genter/Left/Head"):GetComponent("Image")
	self.playerInfo[3].RoleIcon = tran:Find("Genter/Left/RoleIcon"):GetComponent("Image")
	self.playerInfo[3].BaseScore = tran:Find("Genter/Left/BaseScore"):GetComponent("Text")
	self.playerInfo[3].CurScore = tran:Find("Genter/Left/CurScore"):GetComponent("Text")
	self.playerInfo[3].AllScore = tran:Find("Genter/Left/AllScore"):GetComponent("Text")
	
	self.isWin = DdzTyModel.IsMyWin()
	self:InitRect()
	DOTweenManager.OpenClearUIAnim(self.transform)
end

function DdzTyClearing:InitRect()
	if DdzTyModel.data.settlement_info.chuntian ~= 2 then
		self.CTRate.text = "春天"
	else
		self.CTRate.text = "反春"
	end
	self.RoomRentText.text = "本场房费：" .. DdzTyModel.data.settlement_info.room_rent.asset_count

	local rateData = DdzTyModel.GetSettlementRateShowData()
	local data = DdzTyModel.data
	if data.seat_num ~= data.dizhu then
		--农民
		if rateData.men_pai == 2 then
			self.MenZhuaRateText.text = "x" .. rateData.men_pai
			self.ZPRate.text = "闷抓"
		else
			self.MenZhuaRateText.text = "x" .. rateData.men_pai
			self.ZPRate.text = "抓"
		end
		if rateData.dao then
			self.DaoRateText.text = "x" .. rateData.dao
		else
			self.DaoRateText.text =  "--"
		end
		if rateData.la then
			self.LaRateText.text = "x" .. rateData.la
		else
			self.LaRateText.text = "--"
		end
	else
		--地主
		if rateData.men_pai == 4 then
			self.MenZhuaRateText.text = "x" .. rateData.men_pai
			self.ZPRate.text = "闷抓"
		else
			self.MenZhuaRateText.text = "x" .. rateData.men_pai
			self.ZPRate.text = "抓"
		end
		if rateData.dao then
			self.DaoRateText.text = "+" .. rateData.dao
		else
			self.DaoRateText.text = "--"
		end
		if rateData.la then
			self.DaoRateText.text = "+" .. rateData.la
		else
			self.DaoRateText.text = "--"
		end
	end

	self.BoomRateText.text = "x" .. rateData.zhadan
	self.CTRateText.text = "x" .. rateData.chuntian
	self.AllRateText.text = rateData.all

	if self.isWin then
		ExtendSoundManager.PlaySound(audio_config.game.sod_game_win.audio_name)
		self.LoseNode:SetActive(false)
		self.WinNode:SetActive(true)
	else
		ExtendSoundManager.PlaySound(audio_config.game.sod_game_lose.audio_name)
		self.LoseNode:SetActive(true)
		self.WinNode:SetActive(false)
	end

	local sData = DdzTyModel.data.settlement_info
	local pData = DdzTyModel.data.players_info
	for i=1,3 do
		local pSeat = DdzTyModel.GetPosToSeatno(i)
		URLImageManager.UpdateHeadImage(pData[pSeat].head_link, self.playerInfo[i].Head)
		PersonalInfoManager.SetHeadFarme(self.playerInfo[i].HeadFrame, pData[pSeat].dressed_head_frame)
		VIPManager.set_vip_text(self.playerInfo[i].head_vip_txt,pData[pSeat].vip_level)

		self.playerInfo[i].BaseScore.text = DdzTyModel.data.init_stake 
		self.playerInfo[i].CurScore.text = StringHelper.ToCashSymbol(sData.award[pSeat])
		self.playerInfo[i].RoleIcon.sprite = pSeat == DdzTyModel.data.dizhu and GetTexture("ddz_settlement_icon_dz") or GetTexture("ddz_settlement_icon_nm")
		self.playerInfo[i].AllScore.text = StringHelper.ToCash(pData[pSeat].jing_bi)
	end
	local isDZ
	if DdzTyModel.GetPlayerSeat () == DdzTyModel.data.dizhu then
		isDZ = true
	else
		isDZ = false
	end
	self.isDZ = isDZ
	self.bei = rateData.all
	if self:IsCanShare() then
		self.ShareBtn.gameObject:SetActive(true)
		self:OnShareClick()
	else
		self.ShareBtn.gameObject:SetActive(false)
	end

	self:OnOff()
end
function DdzTyClearing:IsCanShare()
	if GameGlobalOnOff.ShowOff and self.isWin and self.bei >= 48 then
		return true
	end
	return false
end
function DdzTyClearing:OnOff()
	if not GameGlobalOnOff.Diversion then
		self.GotoMatchButton.gameObject:SetActive(false)
	else
		self.GotoMatchButton.gameObject:SetActive(true)
	end
end

--[[
Botton
--]]
-- 继续游戏
function DdzTyClearing:OnConfirmClick()
	local ss = DdzTyModel.IsAgainRoomEnter(DdzTyModel.data.hallGameID)
	if ss == 1 then
		local v = DdzTyModel.UIConfig.entrance[DdzTyModel.data.hallGameID]
		HintPanel.Create(3, "当前场次入场要求为" .. StringHelper.ToCash(v.min_coin) .. "鲸币以上\n您鲸币不足，请前往购买", function ()
			PayPanel.Create(GOODS_TYPE.jing_bi)
		end)
		return
	end
	if Network.SendRequest("tydfg_replay_game", {id=DdzTyModel.data.hallGameID}) then
		DdzTyModel.ClearMatchData(DdzTyModel.data.hallGameID)
		self.ConfirmButton.enabled = false
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end

-- 返回
function DdzTyClearing:OnBackClick()
    if Network.SendRequest("tydfg_quit_game") then
		DdzTyClearing.Close()
    else
        DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end

-- 分享战绩
function DdzTyClearing:OnShareClick()
	if self:IsCanShare() then
		DDZSharePrefab.Create("ddz_ty", {myseatno=DdzTyModel.GetPlayerSeat(), dzseatno=DdzTyModel.data.dizhu , bei=self.bei, settlement=DdzTyModel.data.settlement_info})
	else
	end
end

