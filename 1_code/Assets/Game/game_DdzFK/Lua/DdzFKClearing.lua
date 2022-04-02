-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"
local nDdzFunc=require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"

DdzFKClearing = basefunc.class()

DdzFKClearing.name = "DdzFKClearing"


local instance
function DdzFKClearing.Create(parent)
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

	if not instance then
		instance = DdzFKClearing.New(parent)
	end
	return instance
end
-- 关闭
function DdzFKClearing.Close()
	if instance then
		instance:RemoveListener()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end
-- 获得大结算
function DdzFKClearing.SetGameOver()
	if instance then
		instance:UpdateGameOver()
	end
end

function DdzFKClearing:MakeLister()
    self.lister = {}
end
function DdzFKClearing:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end
function DdzFKClearing:ctor(parent)
	parent = parent or GameObject.Find("Canvas/LayerLv2").transform
	self:MakeLister()
	local obj = newObject(DdzFKClearing.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.ConfirmButton = tran:Find("ConfirmButton"):GetComponent("Button")
	self.ConfirmButton.onClick:AddListener(function ()
		self:OnConfirmClick()
	end)

	self.SettlementDetail = tran:Find("Genter/Self/SettlementDetail")
	self.DetailBtn = tran:Find("Genter/Self/DetailBtn"):GetComponent("Button")
	self.DetailBtn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self.SettlementDetail.gameObject:SetActive(not self.SettlementDetail.gameObject.activeSelf)
	end)
	
	self.LoseNode = tran:Find("LoseNode").gameObject
	self.WinNode = tran:Find("WinNode").gameObject
	-- self.WinClearingText = tran:Find("WinNode/ClearingImage/ClearingText"):GetComponent("Text")
	-- self.LoseClearingText = tran:Find("LoseNode/ClearingImage/ClearingText"):GetComponent("Text")

	self.BaseRateText = tran:Find("Genter/Self/SettlementDetail/base"):GetComponent("Text")
	self.GetScoreText = tran:Find("Genter/Self/SettlementDetail/get_score"):GetComponent("Text")
	self.BoomRateText = tran:Find("Genter/Self/SettlementDetail/bomb"):GetComponent("Text")
	self.CTRate = tran:Find("Genter/Self/SettlementDetail/chuntian/TextCT"):GetComponent("Text")
	self.CTRateText = tran:Find("Genter/Self/SettlementDetail/chuntian"):GetComponent("Text")
	self.AllRateText = tran:Find("Genter/Self/SettlementDetail/allScore"):GetComponent("Text")
	self.DZText = tran:Find("Genter/Self/SettlementDetail/ImageDZ/dz"):GetComponent("Text")
	self.NMText = tran:Find("Genter/Self/SettlementDetail/ImageNM/nm"):GetComponent("Text")
	self.RoomRentText = tran:Find("RoomRentText"):GetComponent("Text")
	self.HintText = tran:Find("HintText"):GetComponent("Text")

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
	
	self.isWin = DdzFKModel.IsMyWin()
	self:InitRect()
	DOTweenManager.OpenClearUIAnim(self.transform)
end

function DdzFKClearing:InitRect()
	if DdzFKModel.data.settlement_info.chuntian ~= 2 then
		self.CTRate.text = "春天"
	else
		self.CTRate.text = "反春"
	end
	-- local base = DdzFKModel.GetGongGongBeishu()
	-- local erwai = DdzFKModel.GetEWaiBeishu()
	-- local zhadan = DdzFKModel.GetZhadanBeishu()
	-- local chuntain = DdzFKModel.GetCTBeishu()
	-- local zong = DdzFKModel.GetZongBeishu()

	local settlement_data = nDdzFunc.GetSettlementDetailedInfo(DdzFKModel.data)
	self.BaseRateText.text = settlement_data.jdz == 0 and "--" or "x" .. settlement_data.jdz
	self.BoomRateText.text = settlement_data.bomb == 0 and "--" or "x" .. settlement_data.bomb
	self.CTRateText.text = settlement_data.chuntian == 0 and "--" or "x" .. settlement_data.chuntian
	self.GetScoreText.text = settlement_data.base == 0 and "--" or settlement_data.base
	self.AllRateText.text = settlement_data.all == 0 and "--" or settlement_data.all
	self.DZText.text = settlement_data.dizhu == 0 and "--" or settlement_data.dizhu
	self.NMText.text = settlement_data.nongmin == 0 and "--" or settlement_data.nongmin

	if self.isWin then
		ExtendSoundManager.PlaySound(audio_config.game.sod_game_win.audio_name)
		self.LoseNode:SetActive(false)
		self.WinNode:SetActive(true)
		-- self.WinClearingText.text = "+" .. StringHelper.ToCash(DdzFKModel.data.settlement_info.award[DdzFKModel.data.seat_num]) 
	else
		ExtendSoundManager.PlaySound(audio_config.game.sod_game_lose.audio_name)
		self.LoseNode:SetActive(true)
		self.WinNode:SetActive(false)
		-- self.LoseClearingText.text = "" .. StringHelper.ToCash(DdzFKModel.data.settlement_info.award[DdzFKModel.data.seat_num])
	end

	local sData = DdzFKModel.data.settlement_info
	local pData = DdzFKModel.data.playerInfo
	for i=1,3 do
		local pSeat = DdzFKModel.GetPosToSeatno(i)
		URLImageManager.UpdateHeadImage(pData[pSeat].base.head_link, self.playerInfo[i].Head)
		PersonalInfoManager.SetHeadFarme(self.playerInfo[i].HeadFrame, pData[pSeat].dressed_head_frame)
		VIPManager.set_vip_text(self.playerInfo[i].head_vip_txt,pData[pSeat].vip_level)
		self.playerInfo[i].BaseScore.text = DdzFKModel.data.init_stake
		self.playerInfo[i].CurScore.text = StringHelper.ToCashSymbol(sData.award[pSeat])
		self.playerInfo[i].RoleIcon.sprite = pSeat == DdzFKModel.data.dizhu and GetTexture("ddz_settlement_icon_dz") or GetTexture("ddz_settlement_icon_nm")
		self.playerInfo[i].AllScore.text = StringHelper.ToCashSymbol(pData[pSeat].base.score)
	end
	self:UpdateGameOver()

	-- self:OnOff()
end

function DdzFKClearing:OnOff()
	
end

--[[
Botton
--]]
-- 继续游戏
function DdzFKClearing:OnConfirmClick()
	if DdzFKModel.data.model_status == DdzFKModel.Model_Status.gameover then
		--总结算数据有，展示总结算
		DdzFKClearing.Close()
		Event.Brocast("model_friendgame_gameover_msg")
	elseif DdzFKModel.data.status == DdzFKModel.Status.settlement then
        DdzFKModel.InitGameData()
        DdzFKLogic.refresh_panel()
		Network.SendRequest("nor_ddz_nor_ready", nil, "请求准备", function (data)
			if data.result == 0 then
				DdzFKClearing.Close()
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	end
end
function DdzFKClearing:UpdateGameOver()
	if DdzFKModel.data.status == DdzFKModel.Status.settlement and DdzFKModel.data.is_over == 1 then
		self.ConfirmButton.gameObject:SetActive(false)
		self.HintText.gameObject:SetActive(true)
	else
		self.ConfirmButton.gameObject:SetActive(true)
		self.HintText.gameObject:SetActive(false)
	end
end

