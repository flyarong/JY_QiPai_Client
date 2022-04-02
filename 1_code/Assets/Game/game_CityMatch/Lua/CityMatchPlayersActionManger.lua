--by hewei
--斗地主 我的牌 UI管理器
local nor_ddz_base_lib=require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"
local basefunc = require "Game.Common.basefunc"

CityMatchPlayersActionManger = basefunc.class()
local instance
function CityMatchPlayersActionManger.Create(gamePanel)
	instance=CityMatchPlayersActionManger.New()
	--no 2 object
	instance.my_pai_hash={}
	instance.gamePanel=gamePanel
	--我上一次action的记录 用于判断是否已经走过
	instance.my_last_action=nil
	--出牌提示
	instance.my_hint_chupai=nil
	instance.uiManager=CityMatchMyCardUiManger.Create(instance.gamePanel.playerself_operate_son.cards_remain,212,302,90)
	instance.cardObj = GetPrefab("DdzCard")
	return instance
end
function CityMatchPlayersActionManger:Refresh()
	local hash={}
	local flag=false
	--
	self.my_last_action=nil
	self.my_hint_chupai=nil
	local my_pai_list=nil
	if CityMatchModel.data then
		my_pai_list=CityMatchModel.data.my_pai_list
	end 
	if my_pai_list then
		for k,v in pairs(my_pai_list) do
			hash[v]=true
			if not self.my_pai_hash[v] then
				flag=true
				--创建牌 添加牌
				local card=DdzCard.New(self.cardObj, self.uiManager.node,v,v,0)
				card.transform:SetSiblingIndex(100-card.weight)
				self.my_pai_hash[v]= card
				self.uiManager:addItemByWeight(card)

				--已经进入托管状态，将card设为不可点击状态
				local data = CityMatchModel.data
				if data then
					local auto = data.auto_status
					if auto and data.seatNum then
						if auto[data.seatNum[1]] == 1 then
							card:ChangeToNotClickCard()
						end
					end
				end
			end
		end
	end
	for no,v in pairs(self.my_pai_hash) do
		if not hash[no] then
			flag=true
			self.my_pai_hash[no]=nil
			self.uiManager:DeleteItemByNo(no)
		end
	end
	--刷新UI
	if flag then
		self.uiManager:Refresh()
	end
end
--添加牌
function CityMatchPlayersActionManger:AddPai(pai_list)
	for k,v in ipairs(pai_list) do
		local card=DdzCard.New(self.cardObj, self.uiManager.node,v,v,2)
		self.my_pai_hash[v]=card
		self.uiManager:addItemByWeight(card)
		card:ChangePosStatus(0)
	end
	self.uiManager:Refresh()
end
function CityMatchPlayersActionManger:Fapai(pai_list)
	self.uiManager:DeleteAllItem()
	local aniPaiList = {}
	for k,v in ipairs(pai_list) do
		local card=DdzCard.New(self.cardObj, self.uiManager.node,v,v,0)
		self.my_pai_hash[v]=card
		self.uiManager:addItemByOrder(card)
		aniPaiList[k] = card
	end
	self.uiManager:Refresh()
	--动画
	DDZAnimation.FaPai(aniPaiList,2)
end
--加倍回调
function CityMatchPlayersActionManger:JiabeiBtnCB()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local m_data=CityMatchModel.data
	if m_data and Network.SendRequest("nor_ddz_nor_jiabei", {rate=2}) then
		if m_data.countdown and m_data.countdown>0 then 
			local act={type=101,rate=0}
			act.myrate=m_data.my_rate
			self:DealAction(1,act)
		end
	else
		DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
	end
end
--不加倍回调
function CityMatchPlayersActionManger:BujiabeiBtnCB()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local m_data=CityMatchModel.data
	if m_data and Network.SendRequest("nor_ddz_nor_jiabei", {rate=0}) then
		if m_data.countdown and m_data.countdown>0 then
			local act={type=101,rate=0}
			self:DealAction(1,act)
		end
	else
		DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
	end

end
--jdz 1 回调
function CityMatchPlayersActionManger:Jdz1BtnCB()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local m_data=CityMatchModel.data
	if m_data and Network.SendRequest("nor_ddz_nor_jiao_dizhu", {rate=1}) then
		if m_data.countdown and m_data.countdown>0 then
			local act={type=100,rate=1}
			self:DealAction(1,act)
		end
	else
		DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
	end
end
--jdz 2 回调
function CityMatchPlayersActionManger:Jdz2BtnCB()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local m_data=CityMatchModel.data
	if m_data and Network.SendRequest("nor_ddz_nor_jiao_dizhu", {rate=2}) then
		if m_data.countdown and m_data.countdown>0 then
			local act={type=100,rate=2}
			self:DealAction(1,act)
		end
	else
		DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
	end
end
--jdz 3 回调
function CityMatchPlayersActionManger:Jdz3BtnCB()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local m_data=CityMatchModel.data
	if m_data and Network.SendRequest("nor_ddz_nor_jiao_dizhu", {rate=3}) then
		if m_data.countdown and m_data.countdown>0 then
			local act={type=100,rate=3}
			self:DealAction(1,act)
		end
	else
		DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
	end

end
--不叫地主
function CityMatchPlayersActionManger:Bujdz1BtnCB()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local m_data=CityMatchModel.data
	if m_data and Network.SendRequest("nor_ddz_nor_jiao_dizhu", {rate=0}) then
		if m_data.countdown and m_data.countdown>0 then
			local act={type=100,rate=0}
			self:DealAction(1,act)
		end
	else
		DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
	end
end
--出牌回调
function CityMatchPlayersActionManger:ChupaiBtnCB()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local m_data=CityMatchModel.data
	if m_data then
		--情况自动出最后一手牌回调
		self.gamePanel.last_pai_auto_cb=nil
		local pai_list={}
		for no,v in pairs(self.my_pai_hash) do
			if v.posStatus==1 then
				pai_list[#pai_list+1]=no
			end
		end

		local ret, list_table = CityMatchModel.ddz_algorithm:check_chupai_safe(m_data.action_list, pai_list, m_data.laizi, CityMatchModel.data.remain_pai_amount[CityMatchModel.data.seat_num])
		if ret then

			print("[DDZ LZ] ChupaiBtnCB ret ok: ")
			for kt, vt in pairs(list_table) do
				print("\t" .. kt)
				for ki, vi in pairs(vt) do
					local content = ""
					if vi.show_list == nil then
						print("\t\tshowlist is nil")
					else
						--for i = 1, i < #vi.show_list do
						for k, v in pairs(vi.show_list) do
							content = content .. v .. ", "
						end
					end
					print("\t\t" .. content)
				end
			end


			local index = 0
			local list_map = {}
			local list_array = {}
			for ktype, vtable in pairs(list_table) do
				for kidx, vitem in ipairs(vtable) do
					index = index + 1
					list_array[index] = vitem.show_list
					list_map[index] = { type = vitem.type, cp_list = vitem.cp_list }
				end
			end

			if index <= 0 then
				print("[DDZ LZ] ChupaiBtnCB exception: check_chupai_safe")
				return
			end
			if index == 1 then
				local act = list_map[1]
				self:SendChupaiRequest(act)
			else
				local gamePanel = CityMatchLogic.get_cur_panel()
				if gamePanel then
					gamePanel:ShowSelectLaiziType(list_array, function(ident)
						local act = list_map[ident]
						self:SendChupaiRequest(act)
						print("[DDZ LZ] ChupaiBtnCB selectLaiziType: " .. ident .. " type: " .. act.type)
					end)
				end
			end
		else
			DDZAnimation.Hint(1,Vector3.New(0,-350,0), Vector3.New(0,0,0))
		end
	else
		DDZAnimation.Hint(2,Vector3.New(0,-350,0), Vector3.New(0,0,0))
	end
end

function CityMatchPlayersActionManger:SendChupaiRequest(act)
	local m_data=CityMatchModel.data
	--情况自动出最后一手牌回调
	self.gamePanel.last_pai_auto_cb=nil
	
	if m_data and Network.SendRequest("nor_ddz_nor_chupai", act) then
		if m_data.countdown and m_data.countdown>0 then
			act.myrate=CityMatchModel.data.my_rate
			self:DealAction(1,act)
		end
	else
		DDZAnimation.Hint(2,Vector3.New(0,-350,0), Vector3.New(0,0,0))
	end
end

--不出牌和要不起回调
function CityMatchPlayersActionManger:ChangeCardsPosBtnCB()
	--将牌复位牌
	for no,v in pairs(self.my_pai_hash) do
		v:ChangePosStatus(0)
	end
end

--不出牌和要不起回调
function CityMatchPlayersActionManger:BuchupaiBtnCB()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local m_data=CityMatchModel.data
	--情况自动出最后一手牌回调
	self.gamePanel.last_pai_auto_cb=nil
	if m_data and Network.SendRequest("nor_ddz_nor_chupai", {type=0}) then
		if m_data.countdown and m_data.countdown>0 then
			local act={type=0}
			self:DealAction(1,act)
			--将牌复位牌
			for no,v in pairs(self.my_pai_hash) do
				v:ChangePosStatus(0)
			end
		end
	else
		DDZAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
	end
end
--提示回调
function CityMatchPlayersActionManger:HintBtnCB()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	--情况自动出最后一手牌回调
	self.gamePanel.last_pai_auto_cb=nil
	
	local get_hint_by_act=function ()
		--选取
		local pos=nor_ddz_base_lib.get_real_chupai_pos_by_act(CityMatchModel.data.action_list)
		local type=nil
		local pai=nil
		if pos then
			type=CityMatchModel.data.action_list[pos].type
			pai=CityMatchModel.data.action_list[pos].pai
		end
		self.my_hint_chupai=CityMatchModel.ddz_algorithm:cp_hint(type,pai, CityMatchModel.data.my_pai_list,CityMatchModel.data.laizi)
	end

	if not self.my_hint_chupai or self.my_hint_chupai.type==0  then
		get_hint_by_act()
	else
		self.my_hint_chupai=CityMatchModel.ddz_algorithm:cp_hint(self.my_hint_chupai.type,self.my_hint_chupai.pai, CityMatchModel.data.my_pai_list,CityMatchModel.data.laizi)
	end
	--循环
	if not self.my_hint_chupai or self.my_hint_chupai.type==0 then
		get_hint_by_act()
	end
	if  self.my_hint_chupai and self.my_hint_chupai.show_list then
		local teshu_no=200
		local hash={}
		for _,no in ipairs(self.my_hint_chupai.show_list) do
			if no>59 then
				no=teshu_no
			end
			hash[no]=hash[no] or 0
			hash[no]=hash[no]+1
		end
		--将不需要弹出的牌复位  弹出提示的牌
		for no,v in pairs(self.my_pai_hash) do
			if no>59 then
				--癞子牌
				no=teshu_no
			end
			if hash[no] and hash[no]>0 then
				--弹出
				v:ChangePosStatus(1)
				hash[no]=hash[no]-1
			else
				--复位
				v:ChangePosStatus(0)
			end
		end 
	end	
end
function CityMatchPlayersActionManger:DealAction(seatNum,action)
	if seatNum==1 then
		if action.type<100 and action.type>0 then
			CityMatchModel.ddz_algorithm:get_cpInfo_by_action(action)
		end
		if self:CheckActionIsRun(action) then
			return 
		end
	end
	if action.type<100 then
		self:ChupaiAction(seatNum,action)
	else
		self:OtherAction(seatNum,action)
	end
end
--检查动作是否已经做过 false 表示没有运行过
function CityMatchPlayersActionManger:CheckActionIsRun(action)
	--没有操作人 则一定是客户端发起的 一定没有做过
	if not action.p then
		self.my_last_action=action
		return false
	--从服务器发过来的
	else
		if not self.my_last_action then
			return false
		else
			--检测服务器与客户端的操作是否一致
			local checkActionIsEquel=function(act1,act2)
				if act1.type==act2.type then
					if act1.type>=100 then
						if act1.rate==act2.rate then
							return true
						end
						return false
					--等于零的时候为不出  不用校验
					elseif act1.type>0 then
						if #act1.cp_list==#act2.cp_list then
							local hash=nor_ddz_base_lib.list_to_map(act1.cp_list)
							for _,v in ipairs(act2.cp_list) do
								if not hash[v] then
									return false
								end 
							end
							return true							
						end
					end
					return true
				end 
				return false 
			end 
			--判断是否和客户端一致否则以服务器为准
			if checkActionIsEquel(action,self.my_last_action) then

				self.my_last_action=nil
				return true
			else
				self.my_last_action=nil
				DDZAnimation.Hint(2,Vector3.New(0,-350,0), Vector3.New(0,0,0))
				--刷新我的牌列表
				self:Refresh()
				self.gamePanel.CityMatchActionUiManger:RefreshActionWithAni(1,action)
				--刷新倍数显示  过一秒执行 因为有可能有changeRate动画在执行
				Timer.New(function ()
					self.gamePanel:RefreshRate()
					end, 1, 1, true):Start()

				return true
			end

		end
	end
end
--出牌action
function CityMatchPlayersActionManger:ChupaiAction(seatNum,action)
	local pai_list= action.cp_list and action.cp_list.nor or nil
	local remain_card=nil
	--如果是我自己要出牌 
	if seatNum==1 then
		self.my_hint_chupai=nil
		--退出CardUImanger的管理
		if pai_list then
			for _,no in ipairs(pai_list) do
				self.uiManager:RemoveItemByNo(no)
				--动画和音效
				DDZAnimation.MyChuPai(self.my_pai_hash[no])
				self.my_pai_hash[no]=nil
			end
			--刷新UI
			self.uiManager:RefreshWithAni()
		end
		--统计我手里的牌的数量
		remain_card=self.uiManager.cardCount
	elseif seatNum==2 then

	elseif seatNum==3 then

	end
	--提交给actionUimanger
	self.gamePanel.CityMatchActionUiManger:RefreshActionWithAni(seatNum,action)

	--刷新warning和剩余的pai
	self.gamePanel:RefreshRemainPaiWarningStatusWithAni(seatNum,action.type,remain_card) 
end
--其他操作
function CityMatchPlayersActionManger:OtherAction(seatNum,action)
	--如果是我自己的操作
	if seatNum==1 then

	elseif seatNum==2 then

	elseif seatNum==3 then

	end
	--提交给actionUimanger
	self.gamePanel.CityMatchActionUiManger:RefreshActionWithAni(seatNum,action)
end
function CityMatchPlayersActionManger:MyExit()
	if instance then
		instance.cardObj = nil
		instance.uiManager:MyExit()
		instance.uiManager=nil
	end
end


--status 1不可点击状态 不为1可点击状态
function CityMatchPlayersActionManger:ChangeClickStatus(status)
	for k,v in pairs(self.my_pai_hash) do
		if status == 1 then
			v:ChangeToNotClickCard()
		else
			v:ChangeToClickCard()
		end
	end
end







