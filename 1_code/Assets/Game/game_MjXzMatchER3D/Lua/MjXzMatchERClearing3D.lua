-- 创建时间:2018-06-06

local basefunc = require "Game.Common.basefunc"

MjXzMatchERClearing3D = basefunc.class()

MjXzMatchERClearing3D.name = "MjXzMatchERClearing3D"

local instance
function MjXzMatchERClearing3D.Create(parent)
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

	if not instance then
		instance = MjXzMatchERClearing3D.New(parent)
	end
	return instance
end
-- 关闭
function MjXzMatchERClearing3D.Close()
	if instance then
		instance:RemoveListener()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end
function MjXzMatchERClearing3D:MakeLister()
    self.lister = {}

end
function MjXzMatchERClearing3D:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end
function MjXzMatchERClearing3D:ctor(parent)
	parent = parent or GameObject.Find("Canvas/LayerLv2").transform
	self:MakeLister()
	local obj = newObject(MjXzMatchERClearing3D.name, parent)
	local tran = obj.transform
	self.transform = tran

	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.ConfirmButton = tran:Find("ConfirmButton"):GetComponent("Button")
	self.ConfirmButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnConfirmClick()
	end)
	self.RoomRentTxt = tran:Find("RoomRent/RoomRentTxt"):GetComponent("Text")
	self.RoomRentTxt.gameObject:SetActive(false)

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

		tab.piaoIcon = rect:Find("piaoIcon"):GetComponent("Image")
		tab.daPiaoStakeText = rect:Find("DaPiaoStakeText"):GetComponent("Text")
		
	end
	self.LoseNode = tran:Find("LoseNode").gameObject
	self.WinNode = tran:Find("WinNode").gameObject

    self.ShareBtn = tran:Find("ShareBtn"):GetComponent("Button")
    self.ShareBtn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnShareClick()
    end)

	self:InitRect()
	DOTweenManager.OpenClearUIAnim(self.transform)
end

function MjXzMatchERClearing3D:InitRect()
	--local room_rent = MjXzModel.data.room_rent
	--self.RoomRentTxt.text = room_rent.asset_count .. AwardManager.GetAwardName(room_rent.asset_type)

	local clearData = MjXzModel.data.settlement_info
	
	for i = 1, 4 do
		local data = clearData[i]
		local rect = self.playerRect[i]
		local seatno = data.seat_num
		local base = MjXzModel.data.playerInfo[seatno].base
		URLImageManager.UpdateHeadImage(base.head_link, rect.HeadImage)
		PersonalInfoManager.SetHeadFarme(rect.HeadFrame, base.dressed_head_frame)
		VIPManager.set_vip_text(rect.head_vip_txt,base.vip_level)
		rect.NameText.text = base.name
		local hupai
		dump(data.settle_data, "胡牌")

		--- 飘的多少倍
		--if MjXzModel.daPiao then
			local piaoNum = MjXzModel.data.playerInfo[seatno].piaoNum
			if piaoNum and (piaoNum == 0 or piaoNum == 1 or piaoNum == 3 or piaoNum == 5 ) then
				
				if piaoNum > 0 then
					rect.piaoIcon.gameObject:SetActive(true)
					rect.piaoIcon.sprite = GetTexture( MjXzModel.piaoIconVec[piaoNum] )
				else
					rect.piaoIcon.gameObject:SetActive(false)
				end
			else
				rect.piaoIcon.gameObject:SetActive(false)
			end						
			--- 总共有几个人飘
			local piaoPlayerNum = MjXzModel.GetDaPiaoPlayerNum()
			if piaoPlayerNum > 0 then
				rect.daPiaoStakeText.gameObject:SetActive(true)
			else
				rect.daPiaoStakeText.gameObject:SetActive(false)
			end

			if piaoPlayerNum == 1 then
				rect.daPiaoStakeText.text = string.format("%d人飘底分%d",piaoPlayerNum,2*MjXzModel.data.init_stake)
			elseif piaoPlayerNum >= 2 then
				rect.daPiaoStakeText.text = string.format("%d人飘底分%d",piaoPlayerNum,4*MjXzModel.data.init_stake)
			end
		--else
		--	rect.piaoIcon.gameObject:SetActive(false)
		--	rect.daPiaoStakeText.gameObject:SetActive(false)
		--end

		if data.settle_data.settle_type == "hu" then
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
		
		if MjXzModel.GetRealPlayerSeat () == seatno then
			self.huindex = i
			local pai = {}
			if data.shou_pai then
				for idx = #data.shou_pai, 1, -1 do
					pai[#pai + 1] = data.shou_pai[idx]
				end
			end
			if data.pg_pai then
				for i,v in ipairs(data.pg_pai) do
					if v.pg_type == MjCard.PaiType.ag or v.pg_type == MjCard.PaiType.zg or v.pg_type == MjCard.PaiType.wg then
						for k = 1, 4 do
							pai[#pai + 1] =v.pai
						end
					elseif v.pg_type == MjCard.PaiType.pp then
						for k = 1, 3 do
							pai[#pai + 1] =v.pai
						end
					end
				end
			end
			self.my_shou_pai = pai

			if data.settle_data.settle_type == "hu" then
				if data.settle_data.hu_type == "qghu" then
					local pai_type,hu_type = IsMjShareCondition(data.settle_data.multi)
                    self.pai_type = pai_type
                    self.hu_type = "qghu"
				else				
					local pai_type,hu_type = IsMjShareCondition(data.settle_data.multi)
					self.pai_type = pai_type
					self.hu_type = hu_type
				end
			end

			if score > 0 then
				-- MJParticleManager.JieSuanWin(self.WinNode.transform)
				ExtendSoundManager.PlaySound(audio_config.game.sod_game_win.audio_name)
				self.WinNode:SetActive(true)
				self.LoseNode:SetActive(false)
			else
				-- MJParticleManager.JieSuanLose(self.LoseNode.transform)
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
				MjCard.Create(rect.SPRect, MjXzModel.PaiType.sp, v)
			end
		end
		if data.pg_pai then
			for i,v in ipairs(data.pg_pai) do
				MjCard.Create(rect.PPRect, v.pg_type, v.pai)
			end
		end
	end
	if self:IsCanShare() then
		self.ShareBtn.gameObject:SetActive(true)
		self:OnShareClick()
	else
		self.ShareBtn.gameObject:SetActive(false)
	end
	self:OnOff()
end
function MjXzMatchERClearing3D:IsCanShare()
	if GameGlobalOnOff.ShowOff and self.pai_type or self.hu_type then
		return true
	end
	return true
end
function MjXzMatchERClearing3D:OnOff()
end

function MjXzMatchERClearing3D:GetFanShu(data)
	local fan = 0
	for k,v in pairs(data) do
		fan = fan + v
	end
	return fan
end

function MjXzMatchERClearing3D:GetHuPaiType(settle_data,pg_pai)
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
		else
			hu_type_str = NOR_MAJIANG_HU_TYPE[settle_data.hu_type]
		end
	end
	
	self.geng = 0
	dump(settle_data.multi, "<color=green>multi胡牌数据：</color>")
	if next(settle_data.multi) then
		for k,v in pairs(settle_data.multi) do
			if v then
				if k == "dai_geng" then
					self.geng = v
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

function MjXzMatchERClearing3D:MyExit()
end
--[[
Botton
--]]
-- 继续游戏
function MjXzMatchERClearing3D:OnConfirmClick()
	local config = MatchModel.GetGameCfg(MjXzModel.data.game_id)
    if config and config.enter_condi_count then
        if config.enter_condi_count > MainModel.UserInfo.jing_bi then
            HintPanel.Create(
                3,
                "当前场次入场要求为" .. StringHelper.ToCash(config.enter_condi_count) .. "鲸币以上\n您鲸币不足，请前往购买",
                function()
                    PayPanel.Create(GOODS_TYPE.jing_bi)
                end
            )
            return
        end
    end

    dump(MjXzModel.data.game_id, "<color=red>MjXzModel.data.game_id</color>")
    if Network.SendRequest("nor_mg_replay_game", {id = MjXzModel.data.game_id}) then
        MjXzModel.ClearMatchData(MjXzModel.data.game_id)
    else
        DDZAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
    end

end

-- 返回
function MjXzMatchERClearing3D:OnBackClick()
	if Network.SendRequest("nor_mg_quit_game") then
		MjXzMatchERClearing3D.Close()
    else
		MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
    end
end
function MjXzMatchERClearing3D:OnShareClick()
	MJSharePrefab.Create("mjxz", {paiType=self.pai_type, huType=self.hu_type, pai=self.my_shou_pai, geng=self.geng, huindex=self.huindex})
end

-- function MjXzMatchERClearing3D:GetData()
-- 	local data = {}
-- 	data[1] = {seat_num=1, 
-- 	settle_data={
-- 	  settle_type="hu",
-- 	  multi={men_qing=1},
-- 	  sum_multi=1,
-- 	  score = 999,
-- 	  hu_pai=36,
-- 	  hu_type="pao",
-- 	  },
-- 	shou_pai={35,36,36,37,37,38,14,15,16,17,18,19,31,31},
-- 	peng_pai={},
-- 	pg_pai={}
-- 	}
-- 	data[2] = {seat_num=2, 
-- 	settle_data={
-- 	  settle_type="hu",
-- 	  multi={men_qing=1},
-- 	  sum_multi=1,
-- 	  score = 999,
-- 	  hu_pai=36,
-- 	  hu_type="pao",
-- 	  },
-- 	shou_pai={35,36,36,37,37,38,14,15,16,17,18,19,31,31},
-- 	peng_pai={},
-- 	pg_pai={}
-- 	}
-- 	data[3] = {seat_num=3, 
-- 	settle_data={
-- 	  settle_type="hu",
-- 	  multi={men_qing=1},
-- 	  sum_multi=1,
-- 	  score = 999,
-- 	  hu_pai=36,
-- 	  hu_type="pao",
-- 	  },
-- 	shou_pai={35,36,36,37,37,38,14,15,16,17,18,19,31,31},
-- 	peng_pai={},
-- 	pg_pai={}
-- 	}
-- 	data[4] = {seat_num=4, 
-- 	settle_data={
-- 	  settle_type="hu",
-- 	  multi={men_qing=1},
-- 	  sum_multi=1,
-- 	  score = 999,
-- 	  hu_pai=36,
-- 	  hu_type="pao",
-- 	  },
-- 	shou_pai={35,36,36,37,37,38,14,15,16,17,18,19,31,31},
-- 	peng_pai={},
-- 	pg_pai={}
-- 	}
-- 	return data
--   end
  

