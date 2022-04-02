---- 其他玩家的手牌管理

local basefunc = require "Game.Common.basefunc"

MjShouPaiManger3D = basefunc.class()

local C = MjShouPaiManger3D

function C.Create(transform, playerMgr, logic , model , gamePanel)
	return C.New(transform, playerMgr, logic , model , gamePanel)
end

--- 
function C:ctor( transform , playerMgr , logic , model , gamePanel)
	---- 各个玩家的ui根节点
	self.transform = transform
	---- 对应的玩家管理器
	self.playerMgr = playerMgr
	---- 手牌数据,(如果是其他玩家这个数据是假的，如果是自己这个数据是按 万筒条 顺序排的 )
	self.cardVec = {}

	---- 是否有摸的牌
	self.isMoPaiIndex = nil

	---- 动画时间
	self.aniTime = 0.35

	---- 手牌的放置的位置
	self.shouPaiNodePos = GameObject.Find( "majiang_fj/mjz_01/handCardPos" .. self.playerMgr.uiPos )
	self.shouPaiNodePosOriAngle = self.shouPaiNodePos.transform.localEulerAngles
	self.nowAngle = self.shouPaiNodePosOriAngle

	self.huPaiNodePos = GameObject.Find( "majiang_fj/mjz_01/huCardPos" .. self.playerMgr.uiPos )

	---- 摸得牌和手牌的间隔
	self.moPaiSpace = 0.5*MjCard3D.size.x

	self.defaultCardId = 11

	--- 胡牌的列表
	self.hpPaiList = {}

	self.Model = model
	self.Logic = logic
	self.GamePanel = gamePanel

	---- 血流模式的table
    self.xlModels = { MjXlModel }

end

function C:checkIsXlModel()
	for k,v in pairs(self.xlModels) do
		if self.Model and self.Model == v then
			return true
		end
	end
	return false
end

function C:changeCardLayer(card)
	if self.playerMgr.uiPos == 2 then
		card:setLayer("rightCard")
	elseif self.playerMgr.uiPos == 4 then
		card:setLayer("leftCard")
	end
end

function C:Refresh(paiList, moPai, huPaiData,cur_p , isFaPai)
	---- 删掉手牌&胡牌
	for key,card in pairs(self.cardVec) do
		card:OnDestroy()
	end
	self.cardVec = {}
	for key,card in pairs(self.hpPaiList) do
		card:OnDestroy()
	end
	self.hpPaiList = {}

	if IsEquals(self.hpImg) then
		GameObject.Destroy(self.hpImg.gameObject)
		self.hpImg = nil
	end
	--- 先还原一下
	self.shouPaiNodePos.transform.localEulerAngles = Vector3.New( self.shouPaiNodePosOriAngle.x , self.shouPaiNodePosOriAngle.y , self.shouPaiNodePosOriAngle.z )
	
	----- 当前是否是 权限人
	local cur_refersh_seat =  self.Model.GetPosToSeatno (self.playerMgr.uiPos)
	local isPermitPlayer = (cur_refersh_seat == cur_p)

	--- 是否胡牌
	local isHu = huPaiData ~= nil and true or false

	----- 全部创建
	if paiList and next(paiList) then
		local uiOffset = (self.playerMgr.uiPos - self.Model.GetSeatnoToPos(self.Model.data.zjSeatno))
		uiOffset = uiOffset >= 0 and uiOffset  or (uiOffset + 4)
		local delayTimeCount = uiOffset * self.Model.data.faPaiDelayTime
		local totalNum = #paiList
		for i=1,totalNum do
			
			local card = MjCard3D.Create ( self.shouPaiNodePos.transform , self.Model.PaiType.sp , self.defaultCardId  )
			self:changeCardLayer(card)
			self.cardVec[#self.cardVec + 1] = card

			card.transform.localPosition = self:getTargetPosByIndex(i)

			if isFaPai then
				card.gameObject:SetActive(false)

				MjAnimation.DelayTimeAction( function() 
					if IsEquals(card) and IsEquals(card.gameObject) then
		                card.gameObject:SetActive(true)
		            end
				end , delayTimeCount + self.Model.data.faPaiDelayTime * 4 * math.floor((i - 1)/4) )
				if (i - 1) % 4 == 0 then
					MjAnimation.DelayTimeAction( function() 
						ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_fapai.audio_name)
					end , delayTimeCount + self.Model.data.faPaiDelayTime * 4 * math.floor((i - 1)/4)  )
				end
			end

		end
	end

	self:setNowLocalAngle( self.shouPaiNodePosOriAngle )

	--[[if self.Model.data.status == "start" and self.Model.daPiao then
		--- 有打漂功能的，发牌的时候所有的牌是扣着的
    	self:setNowLocalAngle( Vector3.New(-120,0,0) )
	end--]]

	if isFaPai then
		if self.Model.daPiao then
			---- 胡牌之后扣下来
			
			self:hidePai()
		else

		end
	end

	---- 如果胡牌
	if isHu then
		self:RefreshHuPai(huPaiData)
	end
	--else
		--- 如果当前没有胡牌又是权限人，显示摸的牌
		if isPermitPlayer then
			local cardVecLength = #self.cardVec
			self.isMoPaiIndex = cardVecLength
			local targetPos = self:getTargetPosByIndex(cardVecLength)
			if cardVecLength > 0 and IsEquals(self.cardVec[cardVecLength]) then
				self.cardVec[cardVecLength].transform.localPosition = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )
			end
		else
			self.isMoPaiIndex = nil
		end
	--end

end

function C:setNowLocalAngle( angle)
	self.nowAngle = angle
	self.shouPaiNodePos.transform.localEulerAngles = self.nowAngle
end

function C:hidePai()
	if self.playerMgr.uiPos == 2 then
		self:setNowLocalAngle( Vector3.New( self.shouPaiNodePosOriAngle.x , 90 , self.shouPaiNodePosOriAngle.z ) )
	elseif self.playerMgr.uiPos == 3 then
		self:setNowLocalAngle( Vector3.New( 90 , self.shouPaiNodePosOriAngle.y , self.shouPaiNodePosOriAngle.z ) )
	elseif self.playerMgr.uiPos == 4 then
		self:setNowLocalAngle( Vector3.New( self.shouPaiNodePosOriAngle.x , -90 , self.shouPaiNodePosOriAngle.z ) )
	end
end

function C:RotateUpShouPai()
	--local targetAngle = self.shouPaiNodePosOriAngle
	--dump(self.nowAngle , "<color=yellow>--------------------- MjShouPaiManger3D , self.nowAngle </color>")
	--dump(targetAngle , "<color=yellow>--------------------- MjShouPaiManger3D , RotateUpShouPai </color>")
	--MjAnimation.MyHandCardUp(self.shouPaiNodePos , Vector3.New(self.shouPaiNodePosOriAngle.x - self.nowAngle.x , self.shouPaiNodePosOriAngle.y - self.nowAngle.y ,self.shouPaiNodePosOriAngle.z - self.nowAngle.z ) , targetAngle , nil)

	self:setNowLocalAngle( self.shouPaiNodePosOriAngle )
end

---- 玩家出牌
function C:Chupai(data)
	local pai = data.pai
	local from = data.from   ----- 这个数据从 mjfg_action_msg 中过来是没有这个数据的。
	
	---- 如果牌不够了	
	if #self.cardVec <= 1 then
		print(string.format("<color=red>[MJ] MjXzShouPaiManger3D Chupai cardNum not enough: type(%s) player:%d</color>", data.type, self.playerMgr.uiPos))
		return 
	end
	
	

	---- 直接删掉尾部的牌
	-- self:DelTail()

	---- 做一个假的效果
	-------- 先找一个要打的位置
	local cardVecLength = #self.cardVec
	local randomChupaiIndex , deleteWorldPos = self:DelSerialCardByNum(1)

	-------- 再找一个要插入的位置，只有出的牌不是新摸的牌才要做进入动作
	if randomChupaiIndex == cardVecLength then
		self.isMoPaiIndex = nil
	else
		self.isMoPaiIndex = #self.cardVec
		local isMoPaiCard = self.cardVec[self.isMoPaiIndex]
		local randomInsertIndex = math.random(1,self.isMoPaiIndex)

		self.isMoPaiIndex = randomInsertIndex

		
		for i=#self.cardVec , randomInsertIndex + 1, -1 do
			self.cardVec[i] = self.cardVec[i-1]
		end
		self.cardVec[self.isMoPaiIndex] = isMoPaiCard

	end

	----用已出牌管理器加一张牌到已出牌区域
	self.GamePanel.ChupaiMag:AddChupai(self.playerMgr.uiPos, pai , false , Vector3.New( deleteWorldPos.x , deleteWorldPos.y  , deleteWorldPos.z ) )

	---- 刷新位置&做动作
	self:refreshPosAndAni()

end




---- 碰杠
--[[
data 
   type  -- peng ag zg wg
   pai
--]]
function C:PengGang(data)
	print("<color=yellow>---------- shoupai PengGang </color>")
	local deleteShouPaiNumCfg = {
		[self.Model.PaiType.pp] = 2,
		[self.Model.PaiType.ag] = 4,
		[self.Model.PaiType.zg] = 3,
		[self.Model.PaiType.wg] = 1,
	}

	local deleteNum = deleteShouPaiNumCfg[data.type] or 0
	if deleteNum <= 0 then
		print(string.format("<color=red>[MJ] MjXzShouPaiManger PengGang exception: invalid type(%s) player:%d </color>", data.type, self.playerMgr.uiPos))
		return
	end

	if #self.cardVec <= deleteNum then
		print(string.format("<color=red>[MJ] MjXzShouPaiManger PengGang exception: invalid type(%s) player:%d </color>", data.type, self.playerMgr.uiPos))
		return
	end

	---- 暗杠，弯杠要去掉自己的摸得牌
	if data.type == self.Model.PaiType.ag or data.type == self.Model.PaiType.wg then
		if self.isMoPaiIndex then
			print("<color=yellow>-------------- PengGang , self.isMoPaiIndex </color>" , self.isMoPaiIndex )
			deleteNum = deleteNum - 1
			self:DelCardByIndex(self.isMoPaiIndex)
			self.isMoPaiIndex = nil
		end
	end

	---- 删掉连续的 
	if deleteNum > 0 then
		print("<color=yellow>-------------- PengGang , deleteNum: </color>" , deleteNum )
		self:DelSerialCardByNum(deleteNum)
	end

	--- 刷新位置
	self:refreshPosAndAni()

	-------- 
	if data.type == self.Model.PaiType.wg then
		self.GamePanel.PengGangMag:ChangeWG(self.playerMgr.uiPos, data.pai)
	else
		self.GamePanel.PengGangMag:AddPg(self.playerMgr.uiPos, data)
	end
	if data.type == self.Model.PaiType.zg or data.type == self.Model.PaiType.pp then
		self.GamePanel.ChupaiMag:DelTail()
	end

end

------ 摸牌
function C:Mopai(pai)
	print("<color=yellow>---------- shoupai Mopai </color>")

	local card = MjCard3D.Create ( self.shouPaiNodePos.transform , self.Model.PaiType.zp , self.defaultCardId )
	self:changeCardLayer(card)
	self.isMoPaiIndex = #self.cardVec + 1
	self.cardVec[self.isMoPaiIndex] = card

	local targetPos = self:getTargetPosByIndex(self.isMoPaiIndex)
	--card.transform.localPosition = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )

	MjAnimation.ChaPai3D(card , Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z ))

end

---- 胡牌
function C:Hupai(data)
	if data == nil or type(data) ~= "table" then
		print("[MJ] MjXzShouPaiManger Hupai exception: data invalid")
		return
	end

	local huType = data.hu_type
	if huType == "qghu" then
		self.GamePanel.PengGangMag:ChangePeng()
	elseif huType == "pao" then
		self.GamePanel.ChupaiMag:DelTail()
	end

	MJParticleManager.MJHuPaiAni(self.playerMgr.uiPos)

	if huType == "zimo" then
		self.playerMgr:PlayMusicEffect("zimo")
		ExtendSoundManager.PlaySound(audio_config.mj.majiang_hu_hu.audio_name)
		--- 如果有手牌则删掉
		if self.isMoPaiIndex then
			self:DelCardByIndex(self.isMoPaiIndex)
			self.isMoPaiIndex = nil
		end
	else
		self.playerMgr:PlayMusicEffect("hu")
		ExtendSoundManager.PlaySound(audio_config.mj.majiang_hu_hu.audio_name)
	end

	local huPai , targetPos = self:AddHuPai(data)

	---- 胡牌特效
	if huPai then
		MjAnimation.HuPai3D(huPai,targetPos)
		print("<color=yellow>----------------------------  show HuPai3D !!!</color>")
	end
	

	--self:RefreshHuPai(data)
end

----- 
function C:AddHuPai(data)
	local huType = data.hu_type
	local huIdx = data.shunxu
	local huPai = data.pai or 0

	if IsEquals(self.hpImg) then
		GameObject.Destroy(self.hpImg.gameObject)
		self.hpImg = nil
	end


	if not self:checkIsXlModel() then
		self.hpImg = MJParticleManager.MJHuPai(self.playerMgr.uiPos, huType, huIdx, huPai, self.transform)
	end

	---- 胡牌之后扣下来
	if not self:checkIsXlModel() then
		
		if self.playerMgr.uiPos == 2 then
			self:setNowLocalAngle( Vector3.New( self.shouPaiNodePosOriAngle.x , 90 , self.shouPaiNodePosOriAngle.z ) )
		elseif self.playerMgr.uiPos == 3 then
			self:setNowLocalAngle( Vector3.New( 90 , self.shouPaiNodePosOriAngle.y , self.shouPaiNodePosOriAngle.z ) )
		elseif self.playerMgr.uiPos == 4 then
			self:setNowLocalAngle( Vector3.New( self.shouPaiNodePosOriAngle.x , -90 , self.shouPaiNodePosOriAngle.z ) )
		end

	end

	if huType == "tian_hu" then
		return nil
	end

	local card = MjCard3D.Create( self.huPaiNodePos.transform , self.Model.PaiType.hp , huPai )
	self:changeCardLayer(card)
	local nextHuPaiIndex = #self.hpPaiList + 1
	self.hpPaiList[nextHuPaiIndex] = card
	--- 刷新胡牌的位置
	card.transform.localPosition = self:getHuPaiPos(nextHuPaiIndex , self.playerMgr.uiPos )


	return card ,card.transform.localPosition
end

function C:ShowPoChan()
	if IsEquals(self.hpImg) then
		GameObject.Destroy(self.hpImg.gameObject)
		self.hpImg = nil
	end
	self.hpImg = MJParticleManager.MJHuPai(self.playerMgr.uiPos, "pochan", 1, 11, self.transform)
end

----- 这个要写的通用一点，血战和血流都一样
function C:RefreshHuPai(data)
	if IsEquals(self.hpImg) then
		GameObject.Destroy(self.hpImg.gameObject)
		self.hpImg = nil
	end
	--删除胡牌区的牌
	if self.hpPaiList then
		for k,v in ipairs(self.hpPaiList) do
			--GameObject.Destroy(v.gameObject)
			v:OnDestroy()
		end
	end
	self.hpPaiList = {}

	for _,v in pairs(data) do
		self:AddHuPai(v)
	end

end	

function C:getHuPaiPos(index , playerUiPos)
	local huPaiPosCfg = self.Model.HuPaiPosCfg[playerUiPos]

	local rowNum = math.floor((index-1) / huPaiPosCfg.splitNum)
	local offset = Vector3.New( rowNum * huPaiPosCfg.splitOffset.x , rowNum * huPaiPosCfg.splitOffset.y, rowNum * huPaiPosCfg.splitOffset.z)

	return Vector3.New( ((index-1) % huPaiPosCfg.splitNum) * MjCard3D.size.x + offset.x , 0 + offset.y , 0 + offset.z )

end

function C:Fapai(list)
	--##_动画
	self:Refresh(list, 0, nil , nil , true)
end

function C:Dingque(dqColor)

end

function C:DingqueJustData(dqColor)

end

function C:RefreshDQColor(myPermit)
end



----- 删掉尾部的牌
function C:DelTail()
	if self.cardVec and type(self.cardVec) == "table" then
		local tailIndex = #self.cardVec
		if self.cardVec[tailIndex] and self.cardVec[tailIndex].gameObject then
			self.cardVec[tailIndex]:OnDestroy()

			table.remove(self.cardVec , tailIndex)
		end
	end
end

---- 烧掉指定位置的牌
function C:DelCardByIndex(index)
	if self.cardVec and type(self.cardVec) == "table" then
		if self.cardVec[index] and self.cardVec[index].gameObject then
			self.cardVec[index]:OnDestroy()

			table.remove(self.cardVec , index)
		end
	end
end

---- 随机删除 n个连续的 位置
function C:DelSerialCardByNum(num)
	local randomDeleteStart = math.random( 1 , #self.cardVec - num + 1)

	local worldPos = self.cardVec[randomDeleteStart].transform.position

	for i = 1 , num do
		--local delIndex = randomDeleteStart + i - 1
		
		print("<color=yellow>----------------- DelSerialCardByNum , delete index: </color>",delIndex)
		self:DelCardByIndex( randomDeleteStart )
	end


	---

	return randomDeleteStart , worldPos
end

---------------------------------------------------------------------------------------- 
----- 带动作的刷新位置
function C:refreshPosAndAni()
	for key,card in ipairs(self.cardVec) do
		local targetPos = self:getTargetPosByIndex(key)
		local nowPos = card.transform.localPosition

		if targetPos.x ~= nowPos.x or targetPos.y ~= nowPos.y or targetPos.z ~= nowPos.z then
			if key == self.isMoPaiIndex then
				self:doInsertAni(card , targetPos)
			else
				self:doParallelAni(card , targetPos)
			end
		end
	end
end

----- 根据索引获得应该在的位置
function C:getTargetPosByIndex(index)
	return Vector3.New( (index-1) * MjCard3D.size.x , 0 , 0 )
end

---- 做平移动作
function C:doParallelAni(cardNode , targetPos)
	local cardNode = cardNode
	local cardNodeTran = cardNode.transform
	local tween = cardNodeTran:DOLocalMove(targetPos , self.aniTime):SetEase(DG.Tweening.Ease.Linear)
	local tweenKey = DOTweenManager.AddTweenToStop(tween)

	tween:OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey) 
		SafaSetTransformPeoperty(cardNode , "localPosition" , targetPos)

	end)
end

---- 做插入动画
function C:doInsertAni(cardNode , targetPos)
	local cardNode = cardNode
	local cardNodeTran = cardNode.transform

	---- 先上升再平移再下降
	local moveUp = cardNodeTran:DOLocalMoveZ( MjCard3D.size.z * 2 , 0.4*self.aniTime )

	--- 平移
	local moveParal = cardNodeTran:DOLocalMoveX( targetPos.x , 0.5*self.aniTime )

	--- 下降
	local moveDown = cardNodeTran:DOLocalMoveZ( 0 , 0.4*self.aniTime )

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)

	seq:Append(moveUp)
	seq:Append(moveParal)
	seq:Append(moveDown)

	seq:OnKill(function() 
		DOTweenManager.RemoveStopTween(tweenKey) 

		SafaSetTransformPeoperty(cardNode , "localPosition" , targetPos)

	end)

end

function C:ClearCards()
	for _,card in pairs(self.cardVec) do
		card:OnDestroy()
	end
	self.cardVec = {}

	for _,card in pairs(self.hpPaiList) do
		card:OnDestroy()
	end
	self.hpPaiList = {}
end

---- 退出，清理
function C:MyExit()
	self:ClearCards()
end	

function C:ShowCards(cardList, huPai)
	log("<color=yellow>----------------------------------------->>>> uiPos:</color>" .. self.playerMgr.uiPos)
	local scale = 5.25
	for i = 1, self.shouPaiNodePos.transform.childCount do
		local mj = self.shouPaiNodePos.transform:GetChild(i - 1)
		scale = mj.localScale.x
		GameObject.Destroy(mj.gameObject)
	end
	
	table.sort(cardList, function(a,b)
        return a < b
	end)

	local pos = 0
	self.cardList = {}
	for id = 1, #cardList do
		if huPai and huPai > 0 and huPai == cardList[id] then
			huPai = -1
		else
			local mj = newObject("mj_" .. cardList[id], self.shouPaiNodePos.transform)
			local box = mj:GetComponent("BoxCollider")
			mj.transform.localScale = Vector3.one * scale
			--mj.transform.localPosition = Vector3.New(pos, -box.size.y * scale/2, 0)
			mj.transform.localPosition = Vector3.New(pos, 0, 0)
			mj.transform.parent = nil
			mj.transform.rotation = Quaternion.AngleAxis(-180, mj.transform.right)
			mj.transform.parent = self.shouPaiNodePos.transform
			if self.playerMgr.uiPos == 2 then
				mj.transform:RotateAround(mj.transform.position, mj.transform.up, 90)
			elseif self.playerMgr.uiPos == 4 then
				mj.transform:RotateAround(mj.transform.position, mj.transform.up, -90)
			end
			pos = pos + box.size.x * scale
			self.cardList[#self.cardList + 1] = mj
		end
	end
end

function C:ClearShowCards()
	if self.cardList then
		for _, c in ipairs(self.cardList) do
			GameObject.Destroy(c)
		end

		self.cardList = {}
	end
end
