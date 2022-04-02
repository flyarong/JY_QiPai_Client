-- 创建时间:2018-06-11

local basefunc = require "Game.Common.basefunc"

MjXzPlayerManger = basefunc.class()

MjXzPlayerManger.name = "MjXzPlayerManger"

-- 自己的对象节点，玩家的UI位置
function MjXzPlayerManger.Create(transform, pos,gamePanel)
	return MjXzPlayerManger.New(transform, pos,gamePanel)
end
function MjXzPlayerManger:ctor(transform, pos,gamePanel)
	self.gamePanel = gamePanel
	self.uiPos = pos
	self.transform = transform
	self.gameObject = transform.gameObject
	local tran = transform

	---- 搜集所有的@的变量
	LuaHelper.GeneratingVar(self.transform, self)

	self.HeadRect = tran:Find("HeadRect")
	self.DQIcon = tran:Find("HeadRect/DQIcon"):GetComponent("Image")
	self.HeadFrameImage = tran:Find("HeadRect/HeadFrameImage"):GetComponent("Image")
	self.head_vip_txt = tran:Find("HeadRect/@head_vip_txt"):GetComponent("Text")
	self.ZJImage = tran:Find("HeadRect/ZJImage")
	self.HeadButton = tran:Find("HeadButton"):GetComponent("Button")
	self.HeadButton.onClick:AddListener(function ()
		SysInteractivePlayerManager.Create(self.playerData.base, self.uiPos)
	end)

	-- 手牌组件
	if self:IsMyself() then
		self.ShouPai = MjMyShouPaiManger3D.Create(tran, self , MjXzLogic , MjXzModel , MjXzGamePanel)
		self.ShouPai.lister = {["model_nmjxzfg_ting_data_change_msg"] = basefunc.handler(self.ShouPai, self.ShouPai.nmjfg_ting_data_change_msg)}
		self.ShouPai.Logic.setViewMsgRegister(self.ShouPai.lister,self.ShouPai.listerRegisterName)
		
		---- 因为是7张手牌，所以调整一下自己手牌节点的位置
		---local oriShouPaiPos = self.ShouPai:getShouPaiNodePosOriginPos()
		---self.ShouPai:setShouPaiNodePosOriginPos( Vector3.New( -0.97 , oriShouPaiPos.y , oriShouPaiPos.z ) )
	else
		self.ShouPai = MjShouPaiManger3D.Create(tran, self, MjXzLogic , MjXzModel , MjXzGamePanel)
	end

	self.ScoreText = tran:Find("HeadRect/Image/ScoreText"):GetComponent("Text")
	self.NameText = tran:Find("HeadRect/nameBg/NameText"):GetComponent("Text")
	self.HeadIcon = tran:Find("HeadRect/HeadIcon"):GetComponent("Image")
	self.HeadIconFram = tran:Find("HeadRect/HeadIconFram")

	--- 排名
	--self.score_txt = self.transform.parent:Find("@info/Image1/@score_txt")
	--self.score_img = self.transform.parent:Find("@info/Image1/@score_Img")
	--self.rank_img = self.transform.parent:Find("@info/Image1/@rank_img")
	self.rank_txt = self.transform.parent:Find("@info/Image2/@rank_txt")
	if self.rank_txt then
		self.rankText = self.rank_txt.transform:GetComponent("Text") -- tran:Find("@info/Image2/@rank_txt"):GetComponent("Text")
	end

	self:InitUI()
end
function MjXzPlayerManger:OnDestroy()
	GameObject.Destroy(self.gameObject)
end
function MjXzPlayerManger:MyExit()
	if self.ShouPai then
		self.ShouPai:MyExit()
		self.ShouPai = nil
	end
	self.seatno = nil
end

-- 初始化UI
function MjXzPlayerManger:InitUI()
	self.gameObject:SetActive(false)
	self.HeadRect.gameObject:SetActive(true)
	self.DQIcon.gameObject:SetActive(false)
	self.ScoreText.text = ""
	self.NameText.text = ""
	self.HeadIcon.gameObject:SetActive(false)
	self.ZJImage.gameObject:SetActive(false)
end

-- 玩家进入
function MjXzPlayerManger:PlayerEnter()
	self.seatno = MjXzModel.GetPosToSeatno(self.uiPos)
	self:Refresh()
end
-- 玩家离开
function MjXzPlayerManger:PlayerExit()
	self.seatno = nil
	self:InitUI()
end
-- 发牌
function MjXzPlayerManger:PlayerFapai()
	normal_majiang.sort_pai(self.playerData.spList)
	self.ShouPai:Fapai(self.playerData.spList)
	dump(self.playerData.spList , "<color=yellow>--------------- MjXzPlayerManger PlayerFapai ,</color>")
	--清空碰杠区的牌
	MjXzGamePanel.PengGangMag:Clear(self.uiPos)
end

function MjXzPlayerManger:adjustShouPaiPos()
	if self:IsMyself() then
		if MjXzModel.checkIsEr7zhang() then
			print("<color=yellow>-------------- 调整7张手牌位置<color>")
			---- 因为是7张手牌，所以调整一下自己手牌节点的位置
			local oriShouPaiPos = self.ShouPai:getShouPaiNodePosOriginPos()
			self.ShouPai:setShouPaiNodePosOriginPos( Vector3.New( -0.97 , oriShouPaiPos.y , oriShouPaiPos.z ) )
		elseif MjXzModel.cardScale and MjXzModel.cardScale.localScale and MjXzModel.cardScale.localPosition then
			print("<color=yellow>-------------- 自动调整 手牌大小和位置<color>")
			self.ShouPai:setShouPaiNodePosOriginPos( MjXzModel.cardScale.localPosition )
			self.ShouPai:setShouPaiLocalScale(MjXzModel.cardScale.localScale)
		end
	end
end

--[[*****************************
刷新
*****************************--]]

-- 刷新玩家
function MjXzPlayerManger:Refresh()

	self:InitUI()
	local model = MjXzModel.data
	dump(model , "<color=yellow>-------------------- MjXzPlayerManger:Refresh MjXzModel.data </color>")
	if not model then
		return
	end
	self.gameObject:SetActive(true)
	--print( "MjXzPlayerManger Refresh ***" .. self.uiPos )
	self.playerData = MjXzModel.GetPosToPlayer(self.uiPos)
	dump(self.playerData , "<color=yellow>-------------------- MjXzPlayerManger:Refresh playerData </color>")
	if not self.playerData or not self.playerData.base then
		return
	end
	--[[if not self.seatno then
		self.seatno = MjXzModel.GetPosToSeatno(self.uiPos)
	end--]]
	--if self.seatno then
		self.seatno = MjXzModel.GetPosToSeatno(self.uiPos)
	--end
	PersonalInfoManager.SetHeadFarme(self.HeadFrameImage, self.playerData.base.dressed_head_frame)
	VIPManager.set_vip_text(self.head_vip_txt,self.playerData.base.vip_level)

	----- 必须！！ 已出牌，碰杠牌先于shoupai 刷新
	MjXzGamePanel.ChupaiMag:Refresh(self.uiPos, self.playerData.cpList, model.cur_chupai)
	MjXzGamePanel.PengGangMag:Refresh(self.uiPos, self.playerData.pgList)

	-- 头像
	self.HeadIcon.gameObject:SetActive(true)
	URLImageManager.UpdateHeadImage(self.playerData.base.head_link, self.HeadIcon)
	self:ToCashScore(self.playerData.base.score)
	self.NameText.text = "" .. self.playerData.base.name

	local hupai
	local hu_data_map = MjXzModel.GetHuPaiInfo()
	if hu_data_map and hu_data_map[self.seatno] then
		hupai = { [1] = hu_data_map[self.seatno] }
	end
	dump(self.playerData, "<color=red>self.PlayerData:</color>")
	normal_majiang.sort_pai(self.playerData.spList)
	self.ShouPai:Refresh(self.playerData.spList, model.cur_mopai, hupai,model.cur_p)
	local playerInfo = MjXzModel.GetPosToPlayer(self.uiPos) -- MjXzModel.GetTranslatePlayerInfo()
	if playerInfo.lackColor then
		self.ShouPai:DingqueJustData(playerInfo.lackColor)
	end

	---- 如果杀游戏重来，还在打漂状态，并且自己还没打漂，扣牌
	if MjXzModel.daPiao and MjXzModel.data.status == MjXzModel.Status.fp or (MjXzModel.data.status == MjXzModel.Status.da_piao and playerInfo.piaoNum == -1) then
		self.ShouPai:hidePai()
	end
	
	if model.zjSeatno and model.zjSeatno == self.seatno then
		self:SetZJ(true)
	else
		self:SetZJ(false)
	end
end

-- 设置庄家
function MjXzPlayerManger:SetZJ(b)
	self.ZJImage.gameObject:SetActive(b)
end

--是否玩家自己
function MjXzPlayerManger:IsMyself()
	return MjXzModel.IsPlayerSelf(self.uiPos)
end

-- 分数修改
function MjXzPlayerManger:ChangeMoney(val)
	MjAnimation.ChangeScore(val, self.uiPos)
	self.playerData.base.score = self.playerData.base.score + val
	self:ToCashScore(self.playerData.base.score)
end

function MjXzPlayerManger:ToCashScore(score)
	if score >= 0 then
		self.ScoreText.text = StringHelper.ToCash(score)
	else
		self.ScoreText.text = "-" .. StringHelper.ToCash(score)
	end
end

function MjXzPlayerManger:ChangeScore(val)
	self:ToCashScore(val)
end

function MjXzPlayerManger:SetRank(val)
	if self.rankText then
		self.rankText.text = val
	end
end

--[[*****************************
网络消息
*****************************--]]
-- 动作
function MjXzPlayerManger:Action(data)
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
function MjXzPlayerManger:RefreshMopaiPermit(pai)
	self.isSendCP = true
	self.ShouPai:RefreshDQColor(false)
end

---- add by wss
--- 检查麻将摸牌时的数量对不对
function MjXzPlayerManger:checkMjMoPaiNum( spList )
	if #spList ~= 2 and #spList ~= 5 and #spList ~= 8 and
		 #spList ~= 11 and #spList ~= 14 then
		return false
	end
	return true
end 

-- GamePanel的权限调用它
function MjXzPlayerManger:MopaiPermit(pai)
	self.isSendCP = true
	self.playerData.spList[#self.playerData.spList + 1] = pai
	self.ShouPai:Mopai(pai)

	---- add by wss 
	-- 如果张数不对，则重新刷新
	if self:IsMyself() then
		if not self:checkMjMoPaiNum( self.playerData.spList ) or not self:checkMjMoPaiNum( self.ShouPai.spList ) then
			print("<color=red>------------------------ #self.playerData.spList</color>",#self.playerData.spList)
			print("<color=red>------------------------ #self.ShouPai.spList</color>",#self.ShouPai.spList)
			MjXzLogic.on_nor_mg_status_error_msg()
		end
	end

end

function MjXzPlayerManger:RefreshChupaiPermit()
	self.isSendCP = true
	self.ShouPai:RefreshDQColor(false)
end
-- GamePanel的权限调用它
function MjXzPlayerManger:ChupaiPermit()
	self.isSendCP = true
	self.ShouPai:RefreshDQColor(false)
end
function MjXzPlayerManger:SetSendCP()
	self.isSendCP = false
end

-- 定缺
function MjXzPlayerManger:Dingque(data)
	self.ShouPai:Dingque(data.pai)
	self.DQIcon.gameObject:SetActive(true)
end
-- 出牌
function MjXzPlayerManger:Chupai(data)
	--print( "MjXzPlayerManger Chupai ***" .. self.uiPos )
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
function MjXzPlayerManger:PengGang(data)
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
function MjXzPlayerManger:Hu(data)
	local hupai
	local model = MjXzModel.data

	local hu_data_map = MjXzModel.GetHuPaiInfo()
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
function MjXzPlayerManger:Guo(data)
	-- todo nmg 音效
	--print("<color=yellow> ---------- action Guo -------------- </color>")
	--[[if self:IsMyself() then
		self.ShouPai:hideAllHint()
	end--]]

end

-- 回退动作
function MjXzPlayerManger:BackChupai()
	MjXzGamePanel.ChupaiMag:DelTail()

	local pai = self.playerData.cpList[#self.playerData.cpList]
	table.remove(self.playerData.cpList, #self.playerData.cpList)
	self.playerData.spList[#self.playerData.spList + 1] = pai
	
	local model = MjXzModel.data
	normal_majiang.sort_pai(self.playerData.spList)
	self.ShouPai:Refresh(self.playerData.spList)
	local playerInfo = MjXzModel.GetPosToPlayer(self.uiPos)  -- MjXzModel.GetTranslatePlayerInfo()
	if playerInfo.lackColor then
		self.ShouPai:Dingque(playerInfo.lackColor)
	end
end


--[[****************************
发送网络消息
****************************--]]

function MjXzPlayerManger:SendAction(data)
	dump(data, "<color=blue>chupaiSendAction:</color>")		
	if Network.SendRequest("nor_mj_xzdd_operator", data) then
		return true
	else
		print("<color=red>网络不好...</color>")
		return false
	end
	
end
-- 发送出牌消息
function MjXzPlayerManger:SendChupai(pai)
	print("<color=yellow>---------- MjXzPlayerManger:chupaiSendAction:</color>")		
	local act = {type="cp", pai=pai}
	if self:SendAction(act) then
		self.isSendCP = false
		local m_data=MjXzModel.data
		if m_data and m_data.countdown and m_data.countdown>0 then
			-- 绕过服务器
			local data = {type="cp", pai=pai, p=self.seatno, from="client"}
			Event.Brocast("model_nor_mj_xzdd_action_msg", data)
		end
	end
end

-- 播放音效 
function MjXzPlayerManger:PlayMusicEffect(val)
	--local playerInfo = MjXzModel.data.playerInfo[self.seatno]
	local playerInfo = MjXzModel.GetPosToPlayer(self.uiPos)  --MjXzModel.GetTranslatePlayerInfo()
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
function MjXzPlayerManger:IsChupai()
	if not self.isSendCP then
		print("<color=red>已经发送出牌</color>")
		return false
	end
	if MjXzModel.data and MjXzModel.data.status then
		local ss = MjXzModel.data.status 

		local now_cur_p = MjXzModel.data.cur_p

		if MjXzModel.checkIsEr() then
			now_cur_p = MjXzModel.translateSeatNo( MjXzModel.data.cur_p )
		end
		
		if (ss == MjXzModel.Status.mo_pai or ss == MjXzModel.Status.chu_pai or ss == MjXzModel.Status.start) and
			now_cur_p == self.seatno then
			return true
		end
	end
	-- dump(MjXzModel.data, "<color=red>MjXzPlayerManger:IsChupai</color>")
	return false
end

function MjXzPlayerManger:daPiaoFinish()
	self.ShouPai:RotateUpShouPai()
end

---------------------------------------------------------- 冒起来的提示
---- 显示碰杠的提示(要碰杠的牌，起来)
function MjXzPlayerManger:showPengHint( pengData )
	self.ShouPai:showPengHint(pengData)

end

function MjXzPlayerManger:showGangHint( gangData )
	self.ShouPai:showGangHint(gangData)

end

---- 隐藏碰杠的提示(要碰杠的牌，回去)
function MjXzPlayerManger:hidePengGangHint()
	self.ShouPai:hidePengGangHint()
end

----- 显示所有的牌的提示
function MjXzPlayerManger:showAllHint()
	self.ShouPai:showAllHint()
end


---- 隐藏所有的牌的提示
function MjXzPlayerManger:hideAllHint()
	self.ShouPai:hideAllHint()
end
---------------------------------------------------------- 

function MjXzPlayerManger:setShouPaiActionModel(modelStr)
	self.ShouPai:setShouPaiActionModel(modelStr)
end

function MjXzPlayerManger:refreshHuanSanZhangPai(data)
	self.ShouPai:refreshHuanSanZhangPai(data)
end
