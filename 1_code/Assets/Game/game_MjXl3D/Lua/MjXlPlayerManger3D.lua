-- 创建时间:2018-06-11

local basefunc = require "Game.Common.basefunc"

MjXlPlayerManger = basefunc.class()

MjXlPlayerManger.name = "MjXlPlayerManger"

-- 自己的对象节点，玩家的UI位置
function MjXlPlayerManger.Create(transform, pos,gamePanel)
	return MjXlPlayerManger.New(transform, pos,gamePanel)
end
function MjXlPlayerManger:ctor(transform, pos,gamePanel)
	self.gamePanel = gamePanel
	self.uiPos = pos
	self.transform = transform
	self.gameObject = transform.gameObject
	local tran = transform

	self.HeadRect = tran:Find("HeadRect")
	self.DQIcon = tran:Find("HeadRect/DQIcon"):GetComponent("Image")
	self.piaoIcon = tran:Find("HeadRect/piaoIcon"):GetComponent("Image")
	self.HeadFrameImage = tran:Find("HeadRect/HeadFrameImage"):GetComponent("Image")
	self.head_vip_txt = tran:Find("HeadRect/@head_vip_txt"):GetComponent("Text")
	self.ZJImage = tran:Find("HeadRect/ZJImage")
	self.HandImage = tran:Find("HandImage")
	self.NoReadImage = tran:Find("NoReadImage")
	self.HeadButton = tran:Find("HeadButton"):GetComponent("Button")
	self.HeadButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		if MjXlModel.data.model_status == MjXlModel.Model_Status.gaming then
			SysInteractivePlayerManager.Create(self.playerData.base, self.uiPos)
		end
	end)

	-- 手牌组件
	if self:IsMyself() then
		self.ShouPai = MjMyShouPaiManger3D.Create(tran, self , MjXlLogic , MjXlModel , MjXlGamePanel)
		self.ShouPai.lister = {["model_nmjxzfg_ting_data_change_msg"] = basefunc.handler(self.ShouPai, self.ShouPai.nmjfg_ting_data_change_msg)}
		self.ShouPai.Logic.setViewMsgRegister(self.ShouPai.lister,self.ShouPai.listerRegisterName)

		
	else
		self.ShouPai = MjShouPaiManger3D.Create(tran, self, MjXlLogic , MjXlModel , MjXlGamePanel)
	end

	self.ScoreText = tran:Find("HeadRect/Image/ScoreText"):GetComponent("Text")
	self.NameText = tran:Find("HeadRect/nameBg/NameText"):GetComponent("Text")
	self.HeadIcon = tran:Find("HeadRect/HeadIcon"):GetComponent("Image")
	self.HeadIconFram = tran:Find("HeadRect/HeadIconFram")


	self:InitUI()
end

function MjXlPlayerManger:adjustShouPaiPos()
	if self:IsMyself() then
		if MjXlModel.checkIsEr7zhang() then
			print("<color=yellow>-------------- 调整7张手牌位置<color>")
			---- 因为是7张手牌，所以调整一下自己手牌节点的位置
			local oriShouPaiPos = self.ShouPai:getShouPaiNodePosOriginPos()
			self.ShouPai:setShouPaiNodePosOriginPos( Vector3.New( -0.97 , oriShouPaiPos.y , oriShouPaiPos.z ) )
		elseif MjXlModel.cardScale and MjXlModel.cardScale.localScale and MjXlModel.cardScale.localPosition then
			print("<color=yellow>-------------- è‡ªåŠ¨è°ƒæ•´ æ‰‹ç‰Œå¤§å°å’Œä½ç½®<color>")
			self.ShouPai:setShouPaiNodePosOriginPos( MjXlModel.cardScale.localPosition )
			self.ShouPai:setShouPaiLocalScale(MjXlModel.cardScale.localScale)
		
		end
	end
end


function MjXlPlayerManger:OnDestroy()
	GameObject.Destroy(self.gameObject)
end
function MjXlPlayerManger:MyExit()
	if self.ShouPai then
		self.ShouPai:MyExit()
		self.ShouPai = nil
	end
	self.seatno = nil
end

-- 初始化UI
function MjXlPlayerManger:InitUI()
	self.gameObject:SetActive(false)
	self.HeadRect.gameObject:SetActive(false)
	self.DQIcon.gameObject:SetActive(false)
	self.piaoIcon.gameObject:SetActive(false)
	self.ScoreText.text = ""
	self.NameText.text = ""
	self.HeadIcon.gameObject:SetActive(false)
	self.ZJImage.gameObject:SetActive(false)
	self.HandImage.gameObject:SetActive(false)
	self.NoReadImage.gameObject:SetActive(false)
end

-- 玩家进入
function MjXlPlayerManger:PlayerEnter()
	self.seatno = MjXlModel.GetPosToSeatno(self.uiPos)
	self:Refresh()
end
-- 玩家离开
function MjXlPlayerManger:PlayerExit()
	self.seatno = nil
	self:InitUI()
end
-- 发牌
function MjXlPlayerManger:PlayerFapai()
	normal_majiang.sort_pai(self.playerData.spList)
	self.ShouPai:Fapai(self.playerData.spList)
	self.HandImage.gameObject:SetActive(false)
	self.NoReadImage.gameObject:SetActive(false)
	--清空碰杠区的牌
	MjXlGamePanel.PengGangMag:Clear(self.uiPos)
end

--[[*****************************
刷新
*****************************--]]

-- 刷新玩家
function MjXlPlayerManger:Refresh()
	dump(self.playerData , "<color=yellow>----------------- MjXlPlayerManger:Refresh </color>")
	self:InitUI()
	local model = MjXlModel.data
	if not model then
		return
	end
	self.gameObject:SetActive(true)
	--print( "MjXlPlayerManger Refresh ***" .. self.uiPos )
	self.playerData = MjXlModel.GetPosToPlayer(self.uiPos)
	
	self.HeadRect.gameObject:SetActive(true)
	--if not self.seatno then
		self.seatno = MjXlModel.GetPosToSeatno(self.uiPos)
	--end

	----- 必须！！ 已出牌，碰杠牌先于shoupai 刷新
	MjXlGamePanel.ChupaiMag:Refresh(self.uiPos, self.playerData.cpList, model.cur_chupai)
	MjXlGamePanel.PengGangMag:Refresh(self.uiPos, self.playerData.pgList)

	--if not self.playerData or not self.playerData.base then
	--	return
	--end

	-- 头像
	if self.playerData and self.playerData.base then
		PersonalInfoManager.SetHeadFarme(self.HeadFrameImage, self.playerData.base.dressed_head_frame)
		VIPManager.set_vip_text(self.head_vip_txt,self.playerData.base.vip_level)
		self.HeadIcon.gameObject:SetActive(true)
		URLImageManager.UpdateHeadImage(self.playerData.base.head_link, self.HeadIcon)
		self.ScoreText.text = StringHelper.ToCash(self.playerData.base.score)
		self.NameText.text = "" .. self.playerData.base.name
	else
		self.gameObject:SetActive(false)
		self.HeadRect.gameObject:SetActive(false)
	end

    if model.model_status == MjXlModel.Model_Status.wait_begin then
    	if self.playerData.base and self.playerData.base.ready == 1 then
			self.HandImage.gameObject:SetActive(true)
			self.NoReadImage.gameObject:SetActive(false)
    	else
			self.HandImage.gameObject:SetActive(false)
			self.NoReadImage.gameObject:SetActive(true)
    	end
	else
		self.HandImage.gameObject:SetActive(false)
		self.NoReadImage.gameObject:SetActive(false)
	end

	local hupai
	local hu_data_map = MjXlModel.GetHuPaiInfo()
	if hu_data_map and hu_data_map[self.seatno] then
		hupai = { [1] = hu_data_map[self.seatno] }
	end
	dump(self.playerData, "<color=red>self.PlayerData:</color>")
	normal_majiang.sort_pai(self.playerData.spList)
	self.ShouPai:Refresh(self.playerData.spList, model.cur_mopai, hupai,model.cur_p)
	local playerInfo = MjXlModel.GetPosToPlayer(self.uiPos)
	if playerInfo.lackColor then
		self.ShouPai:DingqueJustData(playerInfo.lackColor)
	end
	---- 如果杀游戏重来，还在打漂状态，并且自己还没打漂，扣牌
	if MjXlModel.daPiao and MjXlModel.data.status == MjXlModel.Status.fp or (MjXlModel.data.status == MjXlModel.Status.da_piao and playerInfo.piaoNum == -1) then
		self.ShouPai:hidePai()
	end

	
	if model.zjSeatno and model.zjSeatno == self.seatno then
		self:SetZJ(true)
	else
		self:SetZJ(false)
	end
end

-- 设置庄家
function MjXlPlayerManger:SetZJ(b)
	self.ZJImage.gameObject:SetActive(b)
end

--是否玩家自己
function MjXlPlayerManger:IsMyself()
	return MjXlModel.IsPlayerSelf(self.uiPos)
end

-- 分数修改
function MjXlPlayerManger:ChangeMoney(val)
	MjAnimation.ChangeScore(val, self.uiPos)
	if self.playerData.base then
		self.playerData.base.score = self.playerData.base.score + val
		if self.uiPos == 1 then
			if self.playerData.base.score ~= MainModel.UserInfo.jing_bi then
				self.playerData.base.score = MainModel.UserInfo.jing_bi
			end
		end
		if self.playerData.base.score >= 0 then
			self.ScoreText.text = StringHelper.ToCash(self.playerData.base.score)
		else
			self.ScoreText.text = "-" .. StringHelper.ToCash(self.playerData.base.score)
		end
	end
end

-- 分数修改
function MjXlPlayerManger:RefreshMoney()
	if self.playerData.base and self.playerData.base.score then
		if self.playerData.base.score >= 0 then
			self.ScoreText.text = StringHelper.ToCash(self.playerData.base.score)
		else
			self.ScoreText.text = "-" .. StringHelper.ToCash(self.playerData.base.score)
		end
	end
end

--[[*****************************
网络消息
*****************************--]]
-- 动作
function MjXlPlayerManger:Action(data)
	if data.type == "dq" then
		self:Dingque(data)
	elseif data.type == "cp" then
		self:Chupai(data)
		-- local chupaiData = {type = "gang",other = "zg",pai = data.pai}
		-- self:PengGang(chupaiData)
	elseif data.type == "peng" or data.type == "gang" then
		self:PengGang(data)
		-- local chupaiData = {type = "gang",other = "wg",pai = data.pai}
		-- self:PengGang(chupaiData)
	elseif data.type == "hu" then
		self:Hu(data)
	elseif data.type == "guo" then
		self:Guo(data)
	end
end
function MjXlPlayerManger:RefreshMopaiPermit(pai)
	self.isSendCP = true
	self.ShouPai:RefreshDQColor(false)
end


---- add by wss
--- 检查麻将摸牌时的数量对不对
function MjXlPlayerManger:checkMjMoPaiNum( spList )
	if #spList ~= 2 and #spList ~= 5 and #spList ~= 8 and
		 #spList ~= 11 and #spList ~= 14 then
		return false
	end
	return true
end 

-- GamePanel的权限调用它
function MjXlPlayerManger:MopaiPermit(pai)
	self.isSendCP = true
	self.playerData.spList[#self.playerData.spList + 1] = pai
	self.ShouPai:Mopai(pai)
	
	---- add by wss 
	-- 如果张数不对，则重新刷新
	if self:IsMyself() then
		if not self:checkMjMoPaiNum( self.playerData.spList ) or not self:checkMjMoPaiNum( self.ShouPai.spList ) then
			print("<color=red>------------------------ #self.playerData.spList</color>",#self.playerData.spList)
			print("<color=red>------------------------ #self.ShouPai.spList</color>",#self.ShouPai.spList)
			MjXlLogic.on_mjfg_status_error_msg()
		end
	end

end

function MjXlPlayerManger:RefreshChupaiPermit()
	self.isSendCP = true
	self.ShouPai:RefreshDQColor(false)
end
-- GamePanel的权限调用它
function MjXlPlayerManger:ChupaiPermit()
	self.isSendCP = true
	self.ShouPai:RefreshDQColor(false)
end
function MjXlPlayerManger:SetSendCP()
	self.isSendCP = false
end

-- 定缺
function MjXlPlayerManger:Dingque(data)
	self.ShouPai:Dingque(data.pai)
	self.DQIcon.gameObject:SetActive(true)
end
-- 出牌
function MjXlPlayerManger:Chupai(data)
	--print( "MjXlPlayerManger Chupai ***" .. self.uiPos )
	-- 隐藏操作
	self.gamePanel:ShowOrHideOperRect(false)
	self.playerData.cpList[#self.playerData.cpList + 1] = data.pai
	if not self:IsMyself() then
		table.remove(self.playerData.spList, 1)
	else
		for k,v in ipairs(self.playerData.spList) do
			if data.pai == v then
				table.remove(self.playerData.spList, k)
				break
			end
		end
	end
	
	self.ShouPai:Chupai(data)
end
-- 碰
function MjXlPlayerManger:PengGang(data)
	local buf
	if data.type == "gang" then
    	buf = {type=data.other, pai=data.pai}
	else
		buf = {type=data.type, pai=data.pai}
	end

	if data.other == "wg" then 
        for idx,v in ipairs(self.playerData.pgList) do
            if v.type == "peng" and v.pai == data.pai then
                self.playerData.pgList[idx].type = "wg"
                break
            end
        end
    else
        self.playerData.pgList[#self.playerData.pgList + 1] = buf
    end

	local removeN = 0
    local removeM = nil
    if buf.type == "ag" then
    	removeM = 4
    end
    if buf.type == "wg" then
    	removeM = 1
    end
    if buf.type == "zg" then
    	removeM = 3
    end
    if buf.type == "peng" then
    	removeM = 2
    end
    if removeM then
		for i = #self.playerData.spList, 1, -1 do
			if self.playerData.spList[i] == buf.pai then
				table.remove(self.playerData.spList, i)
				removeN = removeN + 1
				if removeN >= removeM then
					break
				end
	    	end
		end
	end
	table.print("<color=blue>弯杠1：</color>",buf)
	self.ShouPai:PengGang(buf)
end
-- 胡
function MjXlPlayerManger:Hu(data)
	dump(data,"<color=yellow>---------------------- 胡牌数据 ---------------------------</color>")
	local hupai
	local model = MjXlModel.data
	local hu_data_map = MjXlModel.GetHuPaiInfo()
	if hu_data_map and hu_data_map[self.seatno] then
		hupai = hu_data_map[self.seatno] 
	end
	if data.hu_data.hu_type == "zimo" then
		if self:IsMyself() then
			for k,v in ipairs(self.playerData.spList) do
				if data.hu_data.pai == v then
					table.remove(self.playerData.spList, k)
					break
				end
			end
		else
			table.remove(self.playerData.spList, 1)
		end
	end
    self.ShouPai:Hupai(hupai)
end
-- 过
function MjXlPlayerManger:Guo(data)
	-- todo nmg 音效
	--print("<color=yellow> ---------- action Guo -------------- </color>")
	--[[if self:IsMyself() then
		self.ShouPai:hideAllHint()
	end--]]

end

-- 回退动作
function MjXlPlayerManger:BackChupai()
	MjXlGamePanel.ChupaiMag:DelTail()

	local pai = self.playerData.cpList[#self.playerData.cpList]
	table.remove(self.playerData.cpList, #self.playerData.cpList)
	self.playerData.spList[#self.playerData.spList + 1] = pai
	
	local model = MjXlModel.data
	normal_majiang.sort_pai(self.playerData.spList)
	self.ShouPai:Refresh(self.playerData.spList)
	local playerInfo = MjXlModel.GetPosToPlayer(self.uiPos)
	if playerInfo.lackColor then
		self.ShouPai:Dingque(playerInfo.lackColor)
	end
end


--[[****************************
发送网络消息
****************************--]]

function MjXlPlayerManger:SendAction(data)
	dump(data, "<color=blue>chupaiSendAction:</color>")		
	if Network.SendRequest("nor_mj_xzdd_operator", data) then
		return true
	else
		print("<color=red>网络不好...</color>")
		return false
	end
	
end
-- 发送出牌消息
function MjXlPlayerManger:SendChupai(pai)
	local act = {type="cp", pai=pai}
	if self:SendAction(act) then
		self.isSendCP = false
		local m_data=MjXlModel.data
		if m_data and m_data.countdown and m_data.countdown>0 then
			-- 绕过服务器
			local data = {type="cp", pai=pai, p=self.seatno, from="client"}
			Event.Brocast("model_nor_mj_xzdd_action_msg", data)   -- model_nor_mj_xzdd_action_msg
		end
	end
end

-- 播放音效 
function MjXlPlayerManger:PlayMusicEffect(val)
	--local playerInfo = MjXlModel.data.playerInfo[self.seatno]
	local playerInfo = MjXlModel.GetPosToPlayer(self.uiPos)
	if playerInfo then
		local sound
		playerInfo.base.sex  = playerInfo.base.sex or 1
		if playerInfo.base.sex ~= 0 and playerInfo.base.sex ~= 1 then
			print("<color=red>Error:性别是人妖sex=" .. playerInfo.base.sex .. "</color>")
			playerInfo.base.sex = 1
		end
        if type(val) == "number" then
        	val = tonumber(val)
	        local t1 = math.floor(val / 10)
			local t2 = val % 10
			sound = "majiang_" .. t1 .. "_" .. t2 .. "_" .. playerInfo.base.sex
        else
        	sound = "majiang_" .. val .. "_" .. playerInfo.base.sex
        end
        print("播放的音效名字 = " .. sound)
		ExtendSoundManager.PlaySound(audio_config.mj[sound].audio_name)
	else
		print("<color=red>播放音效失败 玩家不存在</color>")
	end
end

-- 是否可以出牌
function MjXlPlayerManger:IsChupai()
	if not self.isSendCP then
		print("<color=red>已经发送出牌</color>")
		return false
	end
	if MjXlModel.data and MjXlModel.data.status then
		local ss = MjXlModel.data.status 
		local now_cur_p = MjXlModel.data.cur_p

		if MjXlModel.checkIsEr() then
			now_cur_p = MjXlModel.translateSeatNo( MjXlModel.data.cur_p )
		end

		if (ss == MjXlModel.Status.mo_pai or ss == MjXlModel.Status.chu_pai or ss == MjXlModel.Status.start) and
			now_cur_p == self.seatno then
			return true
		end
	end
	-- dump(MjXlModel.data, "<color=red>MjXlPlayerManger:IsChupai</color>")
	return false
end

function MjXlPlayerManger:daPiaoFinish()
	self.ShouPai:RotateUpShouPai()
end

---------------------------------------------------------- 冒起来的提示
---- 显示碰杠的提示(要碰杠的牌，起来)
function MjXlPlayerManger:showPengHint( pengData )
	self.ShouPai:showPengHint(pengData)

end

function MjXlPlayerManger:showGangHint( gangData )
	self.ShouPai:showGangHint(gangData)

end

---- 隐藏碰杠的提示(要碰杠的牌，回去)
function MjXlPlayerManger:hidePengGangHint()
	self.ShouPai:hidePengGangHint()
end

----- 显示所有的牌的提示
function MjXlPlayerManger:showAllHint()
	self.ShouPai:showAllHint()
end


---- 隐藏所有的牌的提示
function MjXlPlayerManger:hideAllHint()
	self.ShouPai:hideAllHint()
end
---------------------------------------------------------- 

function MjXlPlayerManger:setShouPaiActionModel(modelStr)
	self.ShouPai:setShouPaiActionModel(modelStr)
end

function MjXlPlayerManger:refreshHuanSanZhangPai(data)
	self.ShouPai:refreshHuanSanZhangPai(data)
end

function MjXlPlayerManger:ShowCards(cardList, huPai)
	if not self:IsMyself() and cardList and #cardList > 0 then
		self.ShouPai:ShowCards(cardList, huPai)
	end
end

function MjXlPlayerManger:ClearShowCards()
	if not self:IsMyself() then
		self.ShouPai:ClearShowCards()
	end
end
