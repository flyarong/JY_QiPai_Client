-- 创建时间:2018-06-11

local basefunc = require "Game.Common.basefunc"

MjXzFKPlayerManger = basefunc.class()

MjXzFKPlayerManger.name = "MjXzFKPlayerManger"

-- 自己的对象节点，玩家的UI位置
function MjXzFKPlayerManger.Create(transform, pos,gamePanel)
	return MjXzFKPlayerManger.New(transform, pos,gamePanel)
end
function MjXzFKPlayerManger:ctor(transform, pos,gamePanel)
	self.gamePanel = gamePanel
	self.uiPos = pos
	self.transform = transform
	self.gameObject = transform.gameObject
	local tran = transform

	self.HeadRect = tran:Find("HeadRect")
	self.DQIcon = tran:Find("HeadRect/DQIcon"):GetComponent("Image")
	self.HeadFrameImage = tran:Find("HeadRect/HeadFrameImage"):GetComponent("Image")
	self.head_vip_txt = tran:Find("HeadRect/@head_vip_txt"):GetComponent("Text")
	self.ZJImage = tran:Find("HeadRect/ZJImage")
	self.HandImage = tran:Find("HandImage")
	self.FZImage = tran:Find("HeadRect/FZImage")
	self.HeadButton = tran:Find("HeadButton"):GetComponent("Button")
	self.HeadButton.onClick:AddListener(function ()
		SysInteractivePlayerManager.Create(self.playerData.base, self.uiPos)
	end)

	-- 手牌组件
	if self:IsMyself() then
		self.ShouPai = MjMyShouPaiManger3D.Create(tran, self , MjXzFKLogic , MjXzFKModel , MjXzFKGamePanel)
		self.ShouPai.lister = {["model_nMjXzFKfg_ting_data_change_msg"] = basefunc.handler(self.ShouPai, self.ShouPai.nmjfg_ting_data_change_msg)}
		self.ShouPai.Logic.setViewMsgRegister(self.ShouPai.lister,self.ShouPai.listerRegisterName)
	else
		self.ShouPai = MjShouPaiManger3D.Create(tran, self , MjXzFKLogic , MjXzFKModel , MjXzFKGamePanel)
	end

	self.ScoreText = tran:Find("HeadRect/Image/ScoreText"):GetComponent("Text")
	self.NameText = tran:Find("HeadRect/nameBg/NameText"):GetComponent("Text")
	self.HeadIcon = tran:Find("HeadRect/HeadIcon"):GetComponent("Image")
	self.HeadIconFram = tran:Find("HeadRect/HeadIconFram")
	self.DXImage = tran:Find("HeadRect/DXImage")
	self.nameBg = tran:Find("HeadRect/nameBg")


	self:InitUI()
end
function MjXzFKPlayerManger:OnDestroy()
	GameObject.Destroy(self.gameObject)
end
function MjXzFKPlayerManger:MyExit()
	self.ShouPai:MyExit()
	self.ShouPai = nil
	self.seatno = nil
end

function MjXzFKPlayerManger:adjustShouPaiPos()
	if self:IsMyself() then
		--dump(MjXzModel.cardScale , "<color=yellow>------------ adjustShouPaiPos:</color>")
		if MjXzFKModel.checkIsEr7zhang() then
			print("<color=yellow>-------------- 调整7张手牌位置<color>")
			---- 因为是7张手牌，所以调整一下自己手牌节点的位置
			local oriShouPaiPos = self.ShouPai:getShouPaiNodePosOriginPos()
			self.ShouPai:setShouPaiNodePosOriginPos( Vector3.New( -0.97 , oriShouPaiPos.y , oriShouPaiPos.z ) )
		elseif MjXzFKModel.cardScale and MjXzFKModel.cardScale.localScale and MjXzFKModel.cardScale.localPosition then
			print("<color=yellow>-------------- 自动调整 手牌大小和位置<color>")
			self.ShouPai:setShouPaiNodePosOriginPos( MjXzFKModel.cardScale.localPosition )
			self.ShouPai:setShouPaiLocalScale(MjXzFKModel.cardScale.localScale)
		end
	end
end

-- 初始化UI
function MjXzFKPlayerManger:InitUI()
	self.gameObject:SetActive(false)
	self.HeadIconFram.gameObject:SetActive(false)
	self.HeadRect.gameObject:SetActive(false)
	self.DQIcon.gameObject:SetActive(false)
	self.ScoreText.text = ""
	self.NameText.text = ""
	self.HeadIcon.gameObject:SetActive(false)
	self.ZJImage.gameObject:SetActive(false)
	self.HandImage.gameObject:SetActive(false)
	self.FZImage.gameObject:SetActive(false)
	self.nameBg.gameObject:SetActive(false)
end

-- 玩家进入
function MjXzFKPlayerManger:PlayerEnter()
	self.seatno = MjXzFKModel.GetPosToSeatno(self.uiPos)
	self:Refresh()
end
-- 玩家离开
function MjXzFKPlayerManger:PlayerExit()
	self.seatno = nil
	self:InitUI()
end
-- 发牌
function MjXzFKPlayerManger:PlayerFapai()
	normal_majiang.sort_pai(self.playerData.spList)
	self.ShouPai:Fapai(self.playerData.spList)
	self.HandImage.gameObject:SetActive(false)

	MjXzFKGamePanel.PengGangMag:Clear(self.uiPos)
end

--[[*****************************
刷新
*****************************--]]

-- 刷新玩家
function MjXzFKPlayerManger:Refresh()
	self:InitUI()
	local model = MjXzFKModel.data
	if not model then
		return
	end
	self.gameObject:SetActive(true)
	print("MjXzFKPlayerManger Refresh ***")
	self.playerData = MjXzFKModel.GetPosToPlayer(self.uiPos)
	if not self.playerData or not self.playerData.base then
		return
	end
	if not self.seatno then
		self.seatno = MjXzFKModel.GetPosToSeatno(self.uiPos)
	end

	PersonalInfoManager.SetHeadFarme(self.HeadFrameImage, self.playerData.base.dressed_head_frame)
	VIPManager.set_vip_text(self.head_vip_txt,self.playerData.base.vip_level)
	self.HeadRect.gameObject:SetActive(true)
	-- 头像
	self.HeadIcon.gameObject:SetActive(true)
	self.HeadIconFram.gameObject:SetActive(true)
	self.nameBg.gameObject:SetActive(true)
	URLImageManager.UpdateHeadImage(self.playerData.base.head_link, self.HeadIcon)
	dump(self.playerData, "<color=red>MjXzFKPlayerManger 玩家数据</color>")
	self:SetScore()
	self.NameText.text = "" .. self.playerData.base.name

	self:SetDX()

	-- 房主
	if MjXzFKModel.IsFZ(self.seatno) then
		self.FZImage.gameObject:SetActive(true)		
	else
		self.FZImage.gameObject:SetActive(false)
	end

	if model.status == MjXzFKModel.Status.ready and MjXzFKModel.data.ready then
		if (MjXzFKModel.IsFZ(model.seat_num) and MjXzFKModel.data.ready[self.seatno] == 1) or 
			(not MjXzFKModel.IsFZ(model.seat_num) and (MjXzFKModel.data.ready[self.seatno] == 1 or (MjXzFKModel.IsFZ(self.seatno) and model.model_status == MjXzFKModel.Model_Status.wait_begin)) ) then
			self.HandImage.gameObject:SetActive(true)
		else
			self.HandImage.gameObject:SetActive(false)
		end
	else
		self.HandImage.gameObject:SetActive(false)
	end

	----- 必须！！ 已出牌，碰杠牌先于shoupai 刷新
	MjXzFKGamePanel.ChupaiMag:Refresh(self.uiPos, self.playerData.cpList, model.cur_chupai)
	MjXzFKGamePanel.PengGangMag:Refresh(self.uiPos, self.playerData.pgList)

	local hupai
	if model.hu_data_map and model.hu_data_map[self.seatno] then
		hupai = { [1] = MjXzFKModel.data.hu_data_map[self.seatno] }
	end
	normal_majiang.sort_pai(self.playerData.spList)
	self.ShouPai:Refresh(self.playerData.spList, model.cur_mopai, hupai, model.cur_p)
	if model.playerInfo[self.seatno].lackColor then
		self.ShouPai:DingqueJustData(model.playerInfo[self.seatno].lackColor)
	end

	
	if model.zjSeatno and model.zjSeatno == self.seatno then
		self:SetZJ(true)
	else
		self:SetZJ(false)
	end
end
-- 设置离线状态
function MjXzFKPlayerManger:SetDX()
	-- 离线状态
	if not self.playerData.base.net_quality or self.playerData.base.net_quality == 1 then
		self.DXImage.gameObject:SetActive(false)
		self.HeadIcon.color = Color.New(255 / 255, 255 / 255, 255 / 255, 255 / 255)
	else
		self.DXImage.gameObject:SetActive(true)
		self.HeadIcon.color = Color.New(41 / 255, 41 / 255, 41 / 255, 255 / 255)
	end
end

-- 设置庄家
function MjXzFKPlayerManger:SetZJ(b)
	self.ZJImage.gameObject:SetActive(b)
end

-- 设置分数
function MjXzFKPlayerManger:SetScore()
	if self.playerData.base.score >= 0 then
		self.ScoreText.text = StringHelper.ToCash(self.playerData.base.score)
	else
		self.ScoreText.text = "-" .. StringHelper.ToCash(self.playerData.base.score)
	end
end

--是否玩家自己
function MjXzFKPlayerManger:IsMyself()
	return MjXzFKModel.IsPlayerSelf(self.uiPos)
end

-- 分数修改
function MjXzFKPlayerManger:ChangeMoney(val)
	MjAnimation.ChangeScore(val, self.uiPos)
	self.playerData.base.score = self.playerData.base.score + val
	self:SetScore()
end

--[[*****************************
网络消息
*****************************--]]
-- 动作
function MjXzFKPlayerManger:Action(data)
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
function MjXzFKPlayerManger:RefreshMopaiPermit(pai)
	self.isSendCP = true
	self.ShouPai:RefreshDQColor(false)
end

---- add by wss
--- 检查麻将摸牌时的数量对不对
function MjXzFKPlayerManger:checkMjMoPaiNum( spList )
	if #spList ~= 2 and #spList ~= 5 and #spList ~= 8 and
		 #spList ~= 11 and #spList ~= 14 then
		return false
	end
	return true
end 

-- GamePanel的权限调用它
function MjXzFKPlayerManger:MopaiPermit(pai)
	self.isSendCP = true
	self.playerData.spList[#self.playerData.spList + 1] = pai
	self.ShouPai:Mopai(pai)

	---- add by wss 
	-- 如果张数不对，则重新刷新
	if self:IsMyself() then
		if not self:checkMjMoPaiNum( self.playerData.spList ) or not self:checkMjMoPaiNum( self.ShouPai.spList ) then
			print("<color=red>------------------------ #self.playerData.spList</color>",#self.playerData.spList)
			print("<color=red>------------------------ #self.ShouPai.spList</color>",#self.ShouPai.spList)
			MjXzFKLogic.on_nor_mj_xzdd_status_error_msg()
		end
	end

end

function MjXzFKPlayerManger:RefreshChupaiPermit()
	self.isSendCP = true
	self.ShouPai:RefreshDQColor(false)
end
-- GamePanel的权限调用它
function MjXzFKPlayerManger:ChupaiPermit()
	self.isSendCP = true
	self.ShouPai:RefreshDQColor(false)
end
function MjXzFKPlayerManger:SetSendCP()
	self.isSendCP = false
end

-- 定缺
function MjXzFKPlayerManger:Dingque(data)
	self.ShouPai:Dingque(data.pai)
	self.DQIcon.gameObject:SetActive(true)
end
-- 出牌
function MjXzFKPlayerManger:Chupai(data)
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
function MjXzFKPlayerManger:PengGang(data)
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
function MjXzFKPlayerManger:Hu(data)
	local hupai
	local model = MjXzFKModel.data
	if model.hu_data_map and model.hu_data_map[self.seatno] then
		hupai = MjXzFKModel.data.hu_data_map[self.seatno]
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
function MjXzFKPlayerManger:Guo(data)
	-- todo nmg 音效
end

-- 回退动作
function MjXzFKPlayerManger:BackChupai()
	MjXzFKGamePanel.ChupaiMag:DelTail()

	local pai = self.playerData.cpList[#self.playerData.cpList]
	table.remove(self.playerData.cpList, #self.playerData.cpList)
	self.playerData.spList[#self.playerData.spList + 1] = pai
	
	local model = MjXzFKModel.data
	normal_majiang.sort_pai(self.playerData.spList)
	self.ShouPai:Refresh(self.playerData.spList)
	if model.playerInfo[self.seatno].lackColor then
		self.ShouPai:Dingque(model.playerInfo[self.seatno].lackColor)
	end
end


--[[****************************
发送网络消息
****************************--]]

function MjXzFKPlayerManger:SendAction(data)
	dump(data, "<color=blue>chupaiSendAction:</color>")		
	if Network.SendRequest("nor_mj_xzdd_operator", data) then
		return true
	else
		print("<color=red>网络不好...</color>")
		return false
	end
	
end
-- 发送出牌消息
function MjXzFKPlayerManger:SendChupai(pai)
	local act = {type="cp", pai=pai}
	if self:SendAction(act) then
		self.isSendCP = false
		local m_data=MjXzFKModel.data
		if m_data and m_data.countdown and m_data.countdown>0 then
			-- 绕过服务器
			local data = {type="cp", pai=pai, p=self.seatno, from="client"}
			Event.Brocast("model_nor_mj_xzdd_action_msg", data)
		end
	end
end

-- 播放音效 
function MjXzFKPlayerManger:PlayMusicEffect(val)
	local playerInfo = MjXzFKModel.data.playerInfo[self.seatno]
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
function MjXzFKPlayerManger:IsChupai()
	if not self.isSendCP then
		print("<color=red>已经发送出牌</color>")
		return false
	end
	if MjXzFKModel.data and MjXzFKModel.data.status then
		local ss = MjXzFKModel.data.status 
		if (ss == MjXzFKModel.Status.mo_pai or ss == MjXzFKModel.Status.chu_pai or ss == MjXzFKModel.Status.start) and
			MjXzFKModel.data.cur_p == self.seatno then
			return true
		end
	end
	return false
end

---------------------------------------------------------- 冒起来的提示
---- 显示碰杠的提示(要碰杠的牌，起来)
function MjXzFKPlayerManger:showPengHint( pengData )
	self.ShouPai:showPengHint(pengData)

end

function MjXzFKPlayerManger:showGangHint( gangData )
	self.ShouPai:showGangHint(gangData)

end

---- 隐藏碰杠的提示(要碰杠的牌，回去)
function MjXzFKPlayerManger:hidePengGangHint()
	self.ShouPai:hidePengGangHint()
end

----- 显示所有的牌的提示
function MjXzFKPlayerManger:showAllHint()
	self.ShouPai:showAllHint()
end


---- 隐藏所有的牌的提示
function MjXzFKPlayerManger:hideAllHint()
	self.ShouPai:hideAllHint()
end
---------------------------------------------------------- 

function MjXzFKPlayerManger:setShouPaiActionModel(modelStr)
	self.ShouPai:setShouPaiActionModel(modelStr)
end

function MjXzFKPlayerManger:refreshHuanSanZhangPai(data)
	self.ShouPai:refreshHuanSanZhangPai(data)
end
