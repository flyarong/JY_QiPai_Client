--by hewei
--斗地主 我的牌 UI管理器

local basefunc = require "Game.Common.basefunc"
local nDdzFunc=require "Game.normal_ddz_common.Lua.normal_ddz_func_lib"
DdzMillionActionUiManger = basefunc.class()


function DdzMillionActionUiManger.Create(gamePanel,playerOperateUI,dizhuCardUI)
	local instance=DdzMillionActionUiManger.New()
	instance.gamePanel=gamePanel
	instance.playerOperateUI=playerOperateUI
	instance.dizhuCardUI=dizhuCardUI
	--正在my_action容器里面的card
	instance.showCardList={}
	instance.cardObj = GetPrefab("DdzOutCard")
	return instance
end

function DdzMillionActionUiManger:Refresh()
	--全部隐藏
	for k,v in pairs(self.playerOperateUI) do
		v.my_action.gameObject:SetActive(false)
	end
	if DdzMillionModel.data then
		local m_data=DdzMillionModel.data
		local act_list=m_data.action_list
		local hash={}
		if act_list and #act_list>0 and m_data.s2cSeatNum then
			local len= #act_list
			for i=len,len-1,-1 do
				if i>0 then
					local act=act_list[i]
					if not hash[act.p] then
						if not m_data.cur_p or  (act.p~=m_data.cur_p and m_data.cur_p~=6) or m_data.status==nDdzFunc.get_action_status(act) then
							hash[act.p]=true
							self:RefreshAction(m_data.s2cSeatNum[act.p],act)
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
function DdzMillionActionUiManger:changeActionUIShowByStatus()
	--如果上一个已经是不同类型
	local m_data=DdzMillionModel.data
	if m_data then
		if m_data.status==macth_status.cp then
			local cur_p=m_data.cur_p
			if cur_p and DdzMillionModel.data.s2cSeatNum then 
			 	local other_p={}
			 	other_p[1]=DdzMillionModel.data.s2cSeatNum[cur_p]
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
function DdzMillionActionUiManger:RefreshAction(seatNum,act)
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
		local object=self.playerOperateUI[seatNum].message_hint_img.gameObject
		object:SetActive(true)
		--替换图片
		if act.type==0 then
			changeImage("ddz_font_1",object)
		elseif act.type==100 then
			if act.rate==0 then
				changeImage("ddz_font_5",object)
			else
				changeImage("ddz_btn_score"..act.rate,object)	
			end
		elseif act.type==101 then
			if act.rate==2 then
				changeImage("ddz_font_3",object)
			else
				changeImage("ddz_font_2",object)
			end
		end
	else
		ExtendSoundManager.PlaySound(audio_config.ddz.sod_game_outcard.audio_name)
		self.playerOperateUI[seatNum].cards_out.gameObject:SetActive(true)
		local pai_type=nDdzFunc.get_pai_type(act.cp_list)
		--将牌排顺序
		local list=nDdzFunc.sort_pai_for_show(act.cp_list,pai_type)
		--创建card 缩放到具体的尺寸加入容器中
		local cardList={}
		local fatherNode=self.playerOperateUI[seatNum].cards_out.transform
		print("xxxxxxxxxxxxxxxxxxxxxxxxshow cp  list ")
		dump(act.cp_list) 
		dump(list) 
		for _,no in ipairs(list) do
			local card=DdzCard.New(self.cardObj,fatherNode,no,no,0,true)
			cardList[#cardList+1]=card
		end

		local tagCard = cardList[#cardList]
		if DdzMillionModel.data then
			if DdzMillionModel.data.seatNum[seatNum] == DdzMillionModel.data.dizhu then
				DdzCardTag.New(tagCard.transform:Find("@card_img/@tag"),DdzCardTagType.cp,2)
			end
		end
		self.showCardList[seatNum]=cardList  
	end
end
--带动画和音效刷新
function DdzMillionActionUiManger:RefreshActionWithAni(seatNum,act)
	self:RefreshAction(seatNum,act)
	--根据act数据播放动画  和 音效
	if act.type>99 or act.type==0 then
		local sound
		if act.type==0 then
			sound="sod_game_but_buchu"
		elseif act.type==100 then
			if act.rate==0 then
				sound="sod_game_but_bujiao"
			elseif act.rate==1 then
				sound="sod_game_but_yifen"
			elseif act.rate==2 then
				sound="sod_game_but_liangfen"
			else
				sound="sod_game_but_sanfen"
			end
		elseif act.type==101 then
			if act.rate==2 then
				sound="sod_game_double"
			else
				sound="sod_game_nodouble"
			end
		end
		sound=sound..AudioBySex(DdzMillionModel, DdzMillionModel.data.seatNum[seatNum])
		ExtendSoundManager.PlaySound(audio_config.ddz[sound].audio_name)
	else
		local sound=nDdzFunc.get_paiType_sound(act.cp_list)
		sound=sound..AudioBySex(DdzMillionModel, DdzMillionModel.data.seatNum[seatNum])
		for idx,card in ipairs(self.showCardList[seatNum]) do
			if idx==#self.showCardList[seatNum] then
				if act.type == 13 or act.type == 14 then
					SpineManager.ZhaBieRen(seatNum)
					if  DdzMillionModel.data.seatNum[seatNum] == DdzMillionModel.data.dizhu then
						for i=1,3 do
							if i ~= seatNum then
								SpineManager.BeiZha(i)
								DDZParticleManager.DDZBeiZha(i)
							end
						end
					else
						for i=1,3 do
							if i ~= seatNum then
								if DdzMillionModel.data.seatNum[i] == DdzMillionModel.data.dizhu then
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
						local my_rate = DdzMillionModel.data.my_rate
						if seatNum==1 and not act.p and (act.type==13 or act.type==14) then
							my_rate = act.myrate * 2
						end
						--播放动画
						if act.type==6 then
							DDZParticleManager.DDZShunZi(self.playerOperateUI[seatNum].cards_out_ani_pos)
						elseif act.type==7 then
							DDZParticleManager.DDZLianDui(self.playerOperateUI[seatNum].cards_out_ani_pos)
						elseif act.type==11 or act.type==10 or act.type==12  then
							DDZAnimation.plain_animation()
							DDZParticleManager.DDZFeiJi(self.playerOperateUI[seatNum].cards_out_ani_pos)
						elseif act.type==13 then
							local direction = 1
							if seatNum == 2 then
								direction = 2
							end 
							DDZAnimation.ChangeRate(self.dizhuCardUI.cur_multiple_txt,my_rate)
							DDZAnimation.bomb_animation(direction)
							self:PlayBombBGM()
						elseif act.type==14 then
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
function DdzMillionActionUiManger:PlayBombBGM()
	if not self.bombbgmKey then
		ExtendSoundManager.PauseSceneBGM()
		self.bombbgmKey = ExtendSoundManager.PlaySound(audio_config.ddz.bgm_gameboom.audio_name, 1, function ()
			self.bombbgmKey = nil
			ExtendSoundManager.PlaySceneBGM(audio_config.ddz.ddz_bgm_game.audio_name)
		end)
	end
end
function DdzMillionActionUiManger:ClearCardList()
end

function DdzMillionActionUiManger:MyExit()
	if self.bombbgmKey then
		soundMgr:CloseLoopSound(self.bombbgmKey)
	end
	self.bombbgmKey = nil
	self.cardObj = nil
end

























