-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"

MjXzFKClearing = basefunc.class()

MjXzFKClearing.name = "MjXzFKClearing3D"

local zimo_jia
local race_count
local feng_ding
local instance
function MjXzFKClearing.Create(parent)
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

	if not instance then
		instance = MjXzFKClearing.New(parent)
	end
	return instance
end
-- 关闭
function MjXzFKClearing.Close()
	if instance then
		instance:RemoveListener()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end
-- 获得大结算
function MjXzFKClearing.SetGameOver()
	if instance then
		instance:UpdateGameOver()
	end
end
function MjXzFKClearing:MakeLister()
    self.lister = {}
end
function MjXzFKClearing:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end
function MjXzFKClearing:ctor(parent)
	parent = parent or GameObject.Find("Canvas/LayerLv2").transform
	self:MakeLister()
	local obj = newObject(MjXzFKClearing.name, parent)
	local tran = obj.transform
	self.transform = tran

	self.ConfirmButton = tran:Find("ConfirmButton"):GetComponent("Button")
	self.ConfirmButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnConfirmClick()
	end)
	self.RoomRentTxt = tran:Find("RoomRent/RoomRentTxt"):GetComponent("Text")
	self.HintText = tran:Find("HintText"):GetComponent("Text")
	self.playerRect = {}
	for i = 1, 4 do
		local rect = tran:Find("PlayerRect" .. i)
		local tab = {}
		self.playerRect[i] = tab
		tab.HeadImage = rect:Find("HeadImage"):GetComponent("Image")
		tab.HeadFrame = rect:Find("HeadFrame"):GetComponent("Image")
		tab.head_vip_txt = rect:Find("@head_vip_txt"):GetComponent("Text")
		tab.NameText = rect:Find("NameText"):GetComponent("Text")
		tab.HuTypeText = rect:Find("HuTypeText"):GetComponent("Text")
		tab.HuSXImage = rect:Find("HuSXImage"):GetComponent("Image")
		tab.HuSXImageBg = rect:Find("HuSXImageBg"):GetComponent("Image")
		tab.MoneyText1 = rect:Find("MoneyText1"):GetComponent("Text")
		tab.MoneyText2 = rect:Find("MoneyText2"):GetComponent("Text")
		tab.FanText = rect:Find("FanText"):GetComponent("Text")
		tab.Rect = rect:Find("Rect")
		tab.PPRect = rect:Find("Rect/PPRect")
		tab.SPRect = rect:Find("Rect/SPRect")
		tab.HPRect = rect:Find("Rect/HPRect")
		tab.FengImg = rect:Find("FengImage"):GetComponent("Image")
	end

	self.JCount = tran:Find("ju_count"):GetComponent("Text")
	self.LoseNode = tran:Find("LoseNode").gameObject
	self.WinNode = tran:Find("WinNode").gameObject
	self:UpdateGameOver()
	self:InitRect()
	DOTweenManager.OpenClearUIAnim(self.transform)
end

function  MjXzFKClearing:GetRuleData()
	local zimo_jia
	local race_count
	local feng_ding
	for i,v in ipairs(MjXzFKModel.data.ori_game_cfg) do
		if string.match( v.option,"zimo_") then
			zimo_jia = v.option
		elseif string.match( v.option,"race_count_") then
			local str = split(v.option,"_")
			race_count = str[3]
			race_count = tonumber(race_count)
			str = nil
		elseif string.match( v.option,"feng_ding_") then
			local str = split(v.option,"_")
			feng_ding = str[3]
			feng_ding = string.sub(feng_ding,1,string.len(feng_ding)-1)
			feng_ding = tonumber(feng_ding)
			str = nil
		end
	end
	return zimo_jia,race_count,feng_ding
end

function MjXzFKClearing:InitRect()
	MjXzFKClearing.zimo_jia,MjXzFKClearing.race_count,MjXzFKClearing.feng_ding = self:GetRuleData()
	local room_rent = MjXzFKModel.data.room_rent
	-- self.RoomRentTxt.text = room_rent.asset_count .. AwardManager.GetAwardName(room_rent.asset_type)
	local ju_count = MjXzFKModel.data.cur_race or 1
	self.JCount.text =MjXzFKModel.JUCountNumToChar(ju_count)
	local clearData = MjXzFKModel.data.settlement_info
	dump(clearData)	
	for i = 1, 4 do
		local data = clearData[i]
		local rect = self.playerRect[i]
		local seatno = data.seat_num
		local base = MjXzFKModel.data.playerInfo[seatno].base
		URLImageManager.UpdateHeadImage(base.head_link, rect.HeadImage)
		PersonalInfoManager.SetHeadFarme(rect.HeadFrame, base.dressed_head_frame)
		VIPManager.set_vip_text(rect.head_vip_txt,base.vip_level)
		rect.NameText.text = base.name
		local hupai
		-- dump(data.settle_data, "胡牌")
		if data.settle_data.settle_type == "hu" then
			rect.HuTypeText.text = self:GetHuPaiType(data.settle_data,data.pg_pai)
			-- rect.FanText.text = data.settle_data.sum_multi .. "番"
			rect.FanText.text = math.pow(2,data.settle_data.sum_multi) .. "倍"
			rect.FengImg.gameObject:SetActive(data.settle_data.sum_multi == MjXzFKClearing.feng_ding)
			rect.HuSXImageBg.gameObject:SetActive(true)
			rect.HuSXImage.gameObject:SetActive(true)
			rect.HuSXImage.sprite = GetTexture("mj_game_icon_hu" .. i)

			if data.settle_data.hu_pai then
				MjCard.Create(rect.HPRect, MjXzFKModel.PaiType.hu, data.settle_data.hu_pai)
				hupai = data.settle_data.hu_pai
			end
		else
			if data.settle_data.settle_type == "ting" then
				rect.HuTypeText.text = NOR_MAJIANG_SETTLE_TYPE[data.settle_data.settle_type] .. self:GetHuPaiType(data.settle_data,data.pg_pai)
			else
				rect.HuTypeText.text = NOR_MAJIANG_SETTLE_TYPE[data.settle_data.settle_type]
			end
			rect.FanText.text = ""
			rect.FengImg.gameObject:SetActive(data.settle_data.sum_multi == MjXzFKClearing.feng_ding)
			rect.HuSXImage.gameObject:SetActive(false)
			rect.HuSXImageBg.gameObject:SetActive(false)
		end
		
		local score = 0
		if data.settle_data.score then
			score = data.settle_data.score
		end
		if score >= 0 then
			rect.MoneyText1.text = "+" .. StringHelper.ToCash(score)
			rect.MoneyText2.text = ""
		else
			rect.MoneyText1.text = ""
			rect.MoneyText2.text = "-" .. StringHelper.ToCash(score)
		end

		if MjXzFKModel.GetPlayerSeat () == seatno then
			if score > 0 then
				ExtendSoundManager.PlaySound(audio_config.game.sod_game_win.audio_name)
				self.WinNode:SetActive(true)
				self.LoseNode:SetActive(false)
			else
				ExtendSoundManager.PlaySound(audio_config.game.sod_game_lose.audio_name)
				self.WinNode:SetActive(false)
				self.LoseNode:SetActive(true)
			end
		end

		if data.shou_pai then
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
				MjCard.Create(rect.SPRect, MjXzFKModel.PaiType.sp, v)
			end
		end
		if data.pg_pai then
			for i,v in ipairs(data.pg_pai) do
				MjCard.Create(rect.PPRect, v.pg_type, v.pai)
			end
		end
	end
end
function MjXzFKClearing:UpdateGameOver()
	if MjXzFKModel.data.status == MjXzFKModel.Status.settlement and MjXzFKModel.data.is_over == 1 then
		self.ConfirmButton.gameObject:SetActive(false)
		self.HintText.gameObject:SetActive(true)
	else
		self.ConfirmButton.gameObject:SetActive(true)
		self.HintText.gameObject:SetActive(false)
	end
end


function MjXzFKClearing:GetFanShu(data)
	local fan = 0
	for k,v in pairs(data) do
		fan = fan + v
	end
	return fan
end

function MjXzFKClearing:GetHuPaiType(settle_data,pg_pai)
	local huPaiType = ""
	local hu_type_str = ""
	local dai_geng_str = ""
	local gang_str = ""
	
	if settle_data.hu_type	then
		if settle_data.hu_type == "zimo" then
			if settle_data.multi.tian_hu or settle_data.multi.di_hu then
				hu_type_str = ""
			else
				-- print("<color=yellow>MjXzFKClearing.zimo_jia>>>>>>>></color>",MjXzFKClearing.zimo_jia)
				if MjXzFKClearing.zimo_jia == "zimo_jiadi" then
					hu_type_str = NOR_MAJIANG_HU_TYPE[settle_data.hu_type] .. "+1"
				elseif MjXzFKClearing.zimo_jia == "zimo_jiafan" then
					hu_type_str = NOR_MAJIANG_HU_TYPE[settle_data.hu_type] .. "x" .. math.pow(2, 1)
				end
			end
		else
			hu_type_str = NOR_MAJIANG_HU_TYPE[settle_data.hu_type]
		end
	end
	
	-- dump(settle_data.multi, "<color=green>multi胡牌数据：</color>")
	if next(settle_data.multi) then
		for k,v in pairs(settle_data.multi) do
			if v then
				if k == "dai_geng" then
					dai_geng_str = NOR_MAJIANG_MULTI_TYPE[k] .. "x" .. math.pow(2, v)
				elseif k == "zimo" or k == "qiangganghu" then --忽略自摸和抢杠胡
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

function MjXzFKClearing:MyExit()
end

--[[
    @desc: 准备下一局，没有下一局的时候为总结算
    author:{author}
    time:2018-08-09 11:14:52
    @return:
]]
function MjXzFKClearing:OnConfirmClick()
	if MjXzFKModel.data.model_status == MjXzFKModel.Model_Status.gameover then
		--总结算数据有，展示总结算
		-- RoomCardGameOver.Create()
		MjXzFKClearing.Close()
		Event.Brocast("model_friendgame_gameover_msg")
	elseif MjXzFKModel.data.status == MjXzFKModel.Status.settlement then
        MjXzFKModel.InitGameData()
        MjXzFKLogic.refresh_panel()

		Network.SendRequest("nor_mj_xzdd_operator", {type="ready"}, "请求准备", function (data)
			if data.result == 0 then
				MjXzFKClearing.Close()
			else
				HintPanel.ErrorMsg(data.result)
			end
		end)
	end
end
  

