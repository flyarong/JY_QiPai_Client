--by hewei
--斗地主 我的牌 UI管理器

local basefunc = require "Game.Common.basefunc"
local lzDdzFunc=require "Game.normal_ddz_common.Lua.tingyong_ddz_func"
DdzTyActionUiManger = basefunc.class()


function DdzTyActionUiManger.Create(gamePanel,playerOperateUI,dizhuCardUI)
	local instance=DdzTyActionUiManger.New()
	instance.gamePanel=gamePanel
	instance.playerOperateUI=playerOperateUI
	instance.dizhuCardUI=dizhuCardUI
	--正在my_action容器里面的card`
	instance.showCardList={}
	instance.cardObj = GetPrefab("DdzTyOutCard")
	return instance
end

function DdzTyActionUiManger:Refresh()
	--全部隐藏
	for k,v in pairs(self.playerOperateUI) do
		v.my_action.gameObject:SetActive(false)
	end
	if DdzTyModel.data then
		local m_data=DdzTyModel.data
		local act_list=DdzTyModel.data.action_list
		if act_list and #act_list>0 and DdzTyModel.data.s2cSeatNum then
			local act=act_list[#act_list]
			local len= #act_list
			local hash={}
			for i=len,len-1,-1 do
				if i>0 then
					local act=act_list[i]
					if not hash[act.p] then
						if not m_data.cur_p or act.p~=m_data.cur_p or m_data.status==lzDdzFunc.get_action_status(act) then
							if act.type~=103 and act.type~=108 and act.type~=109 then
								 hash[act.p]=true
								self:RefreshAction(DdzTyModel.data.s2cSeatNum[act.p],act)
							end
						end
					end
				else
					break
				end
			end
		end
		self:changeActionUIShowByStatus()
	end	
end

--根据当前状态调整动作的UI的显示
function DdzTyActionUiManger:changeActionUIShowByStatus()
	--如果上一个已经是不同类型
	local m_data=DdzTyModel.data
	if m_data then
		if m_data.status==macth_status.cp then
			local cur_p=m_data.cur_p
			if cur_p and DdzTyModel.data.s2cSeatNum then 
			 	local other_p={}
			 	other_p[1]=DdzTyModel.data.s2cSeatNum[cur_p]
			 	for i=2,3 do
			 		other_p[i]=other_p[i-1]-1
			 		if other_p[i]==0 then
			 			other_p[i]=3
			 		end
			 	end
			 	local type_zero_count=0
			 	for i=2,3 do
			 		local _seat_num=other_p[i]
				 	if self.playerOperateUI[_seat_num] and self.playerOperateUI[_seat_num].action then
				 		if self.playerOperateUI[_seat_num].action.type>99 then
			 				self.playerOperateUI[_seat_num].my_action.gameObject:SetActive(false)
			 			elseif self.playerOperateUI[_seat_num].action.type==0 then
			 				type_zero_count=type_zero_count+1
			 			end	
			 		end
		 		end
		 		if type_zero_count==2 then
		 			for i=2,3 do
		 				local _seat_num=other_p[i]
		 				self.playerOperateUI[_seat_num].my_action.gameObject:SetActive(false)
		 			end
		 		elseif type_zero_count==1 then
		 			if m_data.action_list and #m_data.action_list==2 then
		 				--只有两个动作 且第一个type为0 也将其隐藏
		 				if m_data.action_list[1].type==0 and m_data.action_list[2].type>0 and m_data.action_list[2].type<100  then
		 					self.playerOperateUI[other_p[3]].my_action.gameObject:SetActive(false)
		 				end
		 			end
		 		end
			end
		end
	end
end

local function changeImage(image,object)
	local img = object:GetComponent("Image")
   	img.sprite = GetTexture(image)
    img:SetNativeSize()
end
function DdzTyActionUiManger:RefreshAction(seatNum,act)
	--清空之前残留
	if self.showCardList[seatNum] then
		for _,v in pairs(self.showCardList[seatNum]) do
			--销毁
			v:Destroy()
		end
	end
	
	self.gamePanel:ShowOrHidePermitUI(false,seatNum)

	self.playerOperateUI[seatNum].my_action.gameObject:SetActive(true)
	self.playerOperateUI[seatNum].cards_out.gameObject:SetActive(false)
	self.playerOperateUI[seatNum].message_hint_img.gameObject:SetActive(false)
	self.playerOperateUI[seatNum].action=act
	if act.type>99 or act.type==0 then		
		local object = self.playerOperateUI[seatNum].message_hint_img
		object.gameObject:SetActive(true)
		--替换图片
		if act.type==0 then
			changeImage("ddz_font_1",object)
		elseif act.type==102 then
			changeImage("game_imgf_font_14",object)
		elseif act.type==103 then
			changeImage("game_imgf_font_19",object)
		elseif act.type==104 then
			changeImage("game_imgf_font_15",object)
		elseif act.type==105 then
			changeImage("game_imgf_font_11",object)
		elseif act.type==106 then
			changeImage("game_imgf_font_12",object)
		elseif act.type==107 then
			changeImage("game_imgf_font_9",object)
		elseif act.type==108 then
			changeImage("game_imgf_font_13",object)
		elseif act.type==109 then
			changeImage("game_imgf_font_10",object)
		end
	else
		self.playerOperateUI[seatNum].cards_out.gameObject:SetActive(true)
		lzDdzFunc.get_cpInfo_by_action(act)

		--创建card 加入容器中
		local cardList={}
		local fatherNode=self.playerOperateUI[seatNum].cards_out.transform
		for _,no in ipairs(act.show_list) do
			local card=DdzTyCard.New(self.cardObj,fatherNode,no,no,0,true,4)
			cardList[#cardList+1]=card
		end

		local tagCard = cardList[#cardList]
		if DdzTyModel.data then
			if DdzTyModel.data.seatNum[seatNum] == DdzTyModel.data.dizhu then
				DdzCardTag.New(tagCard.transform:Find("@card_img/@tag"),DdzCardTagType.cp,2)
			end
		end
		self.showCardList[seatNum]=cardList  
	end
end
--带动画和音效刷新
function DdzTyActionUiManger:RefreshActionWithAni(seatNum,act)
	self:RefreshAction(seatNum,act)
	--根据act数据播放动画  和 音效
	if act.type>99 or act.type==0 then
		local sound
		if act.type==0 then
			sound="sod_game_but_buchu"
		elseif act.type==102 then
			--闷抓
			sound="sod_game_menzhua"
			local my_rate=  act.my_rate or DdzTyModel.data.my_rate
			DDZAnimation.ChangeRate(self.dizhuCardUI.cur_multiple_txt,my_rate)
		elseif act.type==103 then
			--看牌
			sound="sod_game_kanpai"
		elseif act.type == 104 then
			--抓牌
			sound="sod_game_zhua"
			local data = DdzTyModel.data
			--自己是地主
			if not act.p or data.dizhu == data.seat_num then
				local my_rate = act.my_rate or DdzTyModel.data.my_rate
				DDZAnimation.ChangeRate(self.dizhuCardUI.cur_multiple_txt,my_rate)
			end
		elseif act.type == 105 then
			--不抓
			sound="sod_game_buzhua"
		elseif act.type == 106 then
			--倒
			sound="sod_game_dao"
			local data = DdzTyModel.data
			if not act.p or data.dizhu==data.seat_num or act.p==data.seat_num  then
				local my_rate = act.my_rate or DdzTyModel.data.my_rate
				DDZAnimation.ChangeRate(self.dizhuCardUI.cur_multiple_txt,my_rate)
			end
		elseif act.type == 107 then
			--不倒
			sound="sod_game_budao"
		elseif act.type == 108 then
			--拉
			sound="sod_game_la"
			local data = DdzTyModel.data
			if not act.p or data.dizhu==data.seat_num or data.p_dao_la[data.seat_num] == 1 then
				local my_rate = act.my_rate or DdzTyModel.data.my_rate
				DDZAnimation.ChangeRate(self.dizhuCardUI.cur_multiple_txt,my_rate)
			end
		elseif act.type == 109 then
			--不拉
			sound="sod_game_bula"
		end

		sound=sound..AudioBySex(DdzTyModel, DdzTyModel.data.seatNum[seatNum])
		ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
	else
		ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_outcard.audio_name)
		local sound=lzDdzFunc.get_paiType_sound(act.type,act.pai)
		sound=sound..AudioBySex(DdzTyModel, DdzTyModel.data.seatNum[seatNum])
		for idx,card in ipairs(self.showCardList[seatNum]) do
			if idx==#self.showCardList[seatNum] then
				if act.type == 13 or act.type == 14 then
					SpineManager.ZhaBieRen(seatNum)
					if  DdzTyModel.data.seatNum[seatNum] == DdzTyModel.data.dizhu then
						for i=1,3 do
							if i ~= seatNum then
								SpineManager.BeiZha(i)
								DDZParticleManager.DDZBeiZha(i)
							end
						end
					else
						for i=1,3 do
							if i ~= seatNum then
								if DdzTyModel.data.seatNum[i] == DdzTyModel.data.dizhu then
									SpineManager.BeiZha(i)
									DDZParticleManager.DDZBeiZha(i)
								else
									SpineManager.ZhaBieRen(i)
								end
							end
						end
					end
				else
					SpineManager.ChuPai(seatNum)
				end

				DDZAnimation.ShowChupaiCard(card,function ()
					ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
						local my_rate = DdzTyModel.data.my_rate
						if seatNum==1 and not act.p and (act.type==13 or act.type==14 or act.type==15  or act.type==16 or act.type==17 or act.type==18) then
							if act.type==17 or act.type==18 then
								my_rate = act.rate * 4
							else
								my_rate = act.rate * 2
							end
						end
						--播放动画
						if act.type==6 then
							DDZParticleManager.DDZShunZi(self.playerOperateUI[seatNum].cards_out_ani_pos)
						elseif act.type==7 then
							DDZParticleManager.DDZLianDui(self.playerOperateUI[seatNum].cards_out_ani_pos)
						elseif act.type==11 or act.type==10 or act.type==12  then
							DDZAnimation.plain_animation()
							DDZParticleManager.DDZFeiJi(self.playerOperateUI[seatNum].cards_out_ani_pos)
						elseif act.type==13 or act.type==15 or act.type==17 then
							local direction = 1
							if seatNum == 2 then
								direction = 2
							end 
							DDZAnimation.ChangeRate(self.dizhuCardUI.cur_multiple_txt,my_rate)
							DDZAnimation.bomb_animation(direction)
							self:PlayBombBGM()
						elseif act.type==14  or act.type==16 or act.type==18 then
							DDZAnimation.ChangeRate(self.dizhuCardUI.cur_multiple_txt,my_rate)
							DDZAnimation.rocket_animation()
							self:PlayBombBGM()
						end
					end)
			else
				DDZAnimation.ShowChupaiCard(card)
			end
		end
	end
end
function DdzTyActionUiManger:PlayBombBGM()
	if not self.bombbgmKey then
		ExtendSoundManager.PauseSceneBGM()
		self.bombbgmKey = ExtendSoundManager.PlaySound(audio_config.ddz.bgm_gameboom.audio_name, 1, function ()
			self.bombbgmKey = nil
			ExtendSoundManager.PlaySceneBGM(audio_config.ddz.ddz_bgm_game.audio_name)
		end)
	end
end
function DdzTyActionUiManger:ClearCardList()
end

function DdzTyActionUiManger:MyExit()
	if self.bombbgmKey then
		soundMgr:CloseLoopSound(self.bombbgmKey)
	end
	self.bombbgmKey = nil
	self.cardObj = nil
end

























