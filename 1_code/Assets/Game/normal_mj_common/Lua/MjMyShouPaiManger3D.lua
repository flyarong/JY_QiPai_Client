local basefunc = require "Game.Common.basefunc"

MjMyShouPaiManger3D = basefunc.class()
local C = MjMyShouPaiManger3D
--local lister
--local listerRegisterName="mjXzFreeMySpListerRegister"
--手牌管理
function C.Create(transform, p, logic , model , gamePanel)
	return C.New(transform, p, logic , model , gamePanel)
end

function C:ctor(transform, p , logic , model , gamePanel)
	self.transform = transform
	self.gameObject = transform.gameObject

	self.player = p

	--手牌区域
	self.spRect = transform:Find("Rect/SPRect")
	--摸牌
	self.zpRect = transform:Find("Rect/ZPRect")
	--听牌区域
	self.tpRoot = transform:Find("Rect/TPRoot")
	--胡牌
	self.hpRect = transform:Find("Rect/HPRect")

	--- 摄像机位置
	self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
	self.handCardCamera = GameObject.Find("majiang_fj/HandCardCamera"):GetComponent("Camera")
	self.mainCamera = GameObject.Find("MainCamera"):GetComponent("Camera")

	self.canvas = GameObject.Find("Canvas")

	self.tpArrowParent = transform  -- :Find("Rect")


	self.aniTimeOrig = 0.35
	self.aniTime = self.aniTimeOrig

	self.shouPaiNodePosAniTime = 0.2
	self.shouPaiNodePosPengGangAddOffset = 0.06

	---- 手牌的放置的位置
	local path = "majiang_fj/mjz_01/handCardPos" .. self.player.uiPos

	self.shouPaiNodePos = GameObject.Find( path )
	self.shouPaiNodePosOriginPos = self.shouPaiNodePos.transform.localPosition
	self.shouPaiNodePosOriAngle = self.shouPaiNodePos.transform.localEulerAngles
	self.shouPaiNodeAngleX = self.shouPaiNodePos.transform.localEulerAngles.x

	self.nowAngle = self.shouPaiNodePosOriAngle

	self.huPaiNodePos = GameObject.Find( "majiang_fj/mjz_01/huCardPos" .. self.player.uiPos )

	self.collisionCube = GameObject.Find( "majiang_fj/mjz_01/handCardPos1/collisionCube" )

	--将弹出的牌收回的button
	self.changeSpStatusBtn = transform:Find("Rect/ChangeSpStatus"):GetComponent("Button")
    self.changeSpStatusBtn.onClick:AddListener(function ()

    	if self.Model and self.Model.data and not self.Model.data.isCanOpPai then
    		return
    	end

		if self.lastPai then
			self.lastPai:ChangePosStatus(0)
			self.lastPai=nil
			self:HideTingPai()
			self:CancelHintYiChuxianPai()
		end

		self:hideAllHint()
		self:resetAllSelectHuanPai()
    end)

	--听牌插入节点
	self.tpArea = transform:Find("Rect/TPRoot/TPRect/mjList")
	self.tpTotalCnt = self.tpArea.transform:Find("mjTitle/tpTotalCnt"):GetComponent("Text")
	local hintBtn = transform:Find("hupai_hint_btn")
	if not hintBtn then
		hintBtn = transform:Find("hupai_hint/hupai_hint_btn")
	end
	self.hupai_hint_btn = hintBtn:GetComponent("Button")
	
	EventTriggerListener.Get(self.hupai_hint_btn.gameObject).onDown = basefunc.handler(self, self.OnHuPaiHintBtnDown) 
	EventTriggerListener.Get(self.hupai_hint_btn.gameObject).onUp = basefunc.handler(self, self.OnHuPaiHintBtnUp)

	--ui数据
	self.spList = {}
	self.zpPai = nil
	self.zpPaiIndex = nil
	self.cpZP = false
	self.hpPai = nil
	self.hpPaiList = {}
	self.hpImg = nil
	---- 摸得牌和手牌的间隔
	self.moPaiSpace = 0.5*MjCard3D.size.x

	--- 触摸选择的牌
	self.touchSelectedCard = nil

	--- 拖动创建出来的牌
	self.touchMoveCard = nil

	self.tpRoot.gameObject:SetActive(false)
	self.tpList = {}
	self.tpArrowTmpl = GetPrefab("TingPaiArrow")
	self.tpArrowTmpl3D = GetPrefab("mj_jiantou") 
	self.tpArrowList = {}

	self.Logic = logic
	self.Model = model
	self.GamePanel = gamePanel
	self.lister = nil
	self.listerRegisterName="mjXzFreeMySpListerRegister"
	-- lister={["model_nmjxzfg_ting_data_change_msg"] = basefunc.handler(self, self.nmjfg_ting_data_change_msg)}
	--self.Logic.setViewMsgRegister(self.lister,listerRegisterName)

	--- 创建一个update
	self.updateDt = 0.012
    self.updateTimer = Timer.New(basefunc.handler(self, self.Update), self.updateDt , -1, true)
    self.updateTimer:Start()

    ---- 血流模式的table
    self.xlModels = { MjXlModel }

    self.shouPaiActionModel = {
    	normal = "normal",
    	huanSanZhang = "huanSanZhang",
	}

    --- 当前的手牌操作模式、
    self.nowShouPaiActionModel = self.shouPaiActionModel.normal

    --- 当前选中的换三张的数量
    self.nowSelectSanZhangNum = 0

    self.maxSelectSanZhangNum = 3

    self.nowSelectSanZhangPaiVec = {}

end

function C:setShouPaiActionModel(str)
	self.nowShouPaiActionModel = str
end

function C:refreshHuanSanZhangPai(paiVec)
	dump(paiVec , "<color=yellow>----------------- refreshHuanSanZhangPai paiVec </color>")
	if not self.spList then
		return false
	end

	self.nowSelectSanZhangNum = 0
	self:hideAllHint()
	self.nowSelectSanZhangPaiVec = {}

	for k,pai in ipairs(paiVec) do
		for key,card in pairs(self.spList) do
			if card.card == pai and card.posStatus ~= 1 then
				card:ChangePosStatus(1)
				self.nowSelectSanZhangNum = self.nowSelectSanZhangNum + 1
				--self.nowSelectSanZhangPaiVec[#self.nowSelectSanZhangPaiVec+1] = card
				self:addSelectSanZhangPaiVec(card)

				break
			end
		end
	end

	if self.nowSelectSanZhangNum == self.maxSelectSanZhangNum then
		self:hideNotSelectPai()
	end

	return false
end

function C:addSelectSanZhangPaiVec(card)
	self.nowSelectSanZhangPaiVec[#self.nowSelectSanZhangPaiVec+1] = card
end

function C:delSelectSanZhangPaiVec(card)
	for k,value in pairs(self.nowSelectSanZhangPaiVec) do
		if value == card then
			table.remove( self.nowSelectSanZhangPaiVec , k )
			break
		end
	end
end

--- 设置没有起来的牌的隐藏
function C:hideNotSelectPai()
	for key,card in pairs(self.spList) do
		if card.posStatus ~= 1 then
			card:SetMark( true )
		end
	end
end

function C:showAllMask()
	for key,card in pairs(self.spList) do
		card:SetMark( false )
	end
end

function C:ShowTingPaiMask()
	local n = #self.spList
	for key,card in pairs(self.spList) do
		if key < n then
			card:SetMark( true )
		end
	end
end

function C:huanPai(newPaiVec , newSpList)
	dump(newPaiVec , "<color=yellow>------- myShouPai newPaiVec: </color>")
	dump(newSpList , "<color=yellow>------- myShouPai newSpList: </color>")
	dump(self.spList , "<color=yellow>------- myShouPai self.spList: </color>")
	print("<color=yellow>------------------ self.nowSelectSanZhangNum : </color>",self.nowSelectSanZhangNum)

	--- 不判断这个，也无伤大雅；因为这个有时候报错
	if self.nowSelectSanZhangNum ~= #newPaiVec then
		--error("huanPai , the num is not equal !!!!!!!!!!!!!!")
	end

	if #newSpList ~= #self.spList then
		error("huanPai , the spList num is not equal !!!!!!!!!!!!!!")
	end

	---旧的选中用来换的牌，去掉
	for k,value in pairs(self.nowSelectSanZhangPaiVec) do
		for _,card in pairs(self.spList) do
			if value == card then
				card:OnDestroy()
				table.remove(self.spList,_)
				break
			end
		end
	end
	self.nowSelectSanZhangPaiVec = {}

	local oldShoupai = {}
	for k,v in pairs(self.spList) do
		oldShoupai[v] = true
	end

	----
	local newSp = self:SortList(newSpList)

	for k,v in ipairs(newSp) do
		--print("<color=yellow>---------- k,v: </color>",k,v)
		if not self.spList[k] or v ~= self.spList[k].card then
			local card = self:createMyPlayerCard3D( self.Model.PaiType.sp , v , function(selfCard)
				self:OnClickPai(selfCard)
			end )

			table.insert(self.spList, k, card )
			--- 设置位置
			local targetPos = self:getTargetPosByIndex(k)
			if self:checkIsShowMoPai() and k == #newSp then
				targetPos = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )
			end

			card.transform.localPosition = Vector3.New( targetPos.x , targetPos.y , targetPos.z + 2*MjCard3D.size.z )
		end
	end

	for k,v in pairs(self.spList) do
		local targetPos = self:getTargetPosByIndex(k)
		if self:checkIsShowMoPai() and k == #self.spList then
			targetPos = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )
		end

		if oldShoupai[v] then
			self:doParallelAni(self.spList[k] , targetPos)
		else
			MjAnimation.DelayTimeAction(function()
				self:doParallelAni(self.spList[k] , targetPos)
			end,0.5)
		end

		
	end

	self.nowSelectSanZhangNum = 0

	--self:RefreshAllCardPos(true)
	self:showAllMask()
end

function C:getShouPaiNodePosOriginPos()
	return self.shouPaiNodePosOriginPos
end

function C:setShouPaiNodePosOriginPos(pos)
	self.shouPaiNodePos.transform.localPosition = pos
	self.shouPaiNodePosOriginPos = self.shouPaiNodePos.transform.localPosition
end

function C:setShouPaiLocalScale(scale)
	self.shouPaiNodePos.transform.localScale = scale
	--self.shouPaiNodePosOriginPos = self.shouPaiNodePos.transform.localPosition
end

function C:checkIsXlModel()
	for k,v in pairs(self.xlModels) do
		if self.Model and self.Model == v then
			return true
		end
	end
	return false
end


function C:Update()
	local dt = self.updateDt

	local dealTouch = function()
		
		---- 某些状态不能点击牌
		if (self.Model.data.status == "huan_san_zhang" and not self.Model.data.isCanOpPai) or 
			self.Model.data.status == "fp" or self.Model.data.status == "da_piao" 
			or self.Model.data.status == "da_piao_finish" or self.Model.data.status == "huan_san_zhang_finish"
			or self.Model.data.status == "ding_que" then
			return
		end

		local isHuPai = (self.hpPaiList and #self.hpPaiList > 0)
		if UnityEngine.Input.GetMouseButton(0) and not isHuPai then

			local ray = self.handCardCamera:ScreenPointToRay( UnityEngine.Input.mousePosition )
			local hitInfo = nil
			local isCol , hitInfo = UnityEngine.Physics.Raycast( ray , hitInfo )

			local isSelectedCard = false
			local isSelectedCollisionCube = false
			---- 有选到牌
		    if isCol then
		    	local colliderGameObject = hitInfo.collider.gameObject
		    	for k,card in ipairs(self.spList) do
		    		if card and colliderGameObject.transform == card.transform and card.callbackClick then
		    			self.touchSelectedCard = card
		    			isSelectedCard = true
		    			break
		    		end
		    	end
		    	if colliderGameObject.transform == self.collisionCube.transform then
		    		isSelectedCollisionCube = true
		    	end
		    end
		    
		    --- 没有选到牌
		    if isSelectedCollisionCube and self.touchSelectedCard and self.touchSelectedCard.card then
		    	if self.nowShouPaiActionModel == self.shouPaiActionModel.normal and not self.touchMoveCard then
		    		self.touchMoveCard = self:createMyPlayerCard3D( self.Model.PaiType.sp, self.touchSelectedCard.card , function(selfCard)
											self:OnClickPai(selfCard)
										end )
		    		local boxColliderCom = self.touchMoveCard.gameObject:GetComponent("BoxCollider")
		    		if boxColliderCom then
		    			GameObject.Destroy(boxColliderCom)
		    		end

		    	end

		    end
		    if self.touchMoveCard and isCol and hitInfo then
		    	self.touchMoveCard.transform.position = hitInfo.point
			end
		end


		----- 触摸抬起来了
		if UnityEngine.Input.GetMouseButtonUp(0) and not isHuPai then
			local ray = self.handCardCamera:ScreenPointToRay( UnityEngine.Input.mousePosition )
			local hitInfo = nil
			local isCol , hitInfo = UnityEngine.Physics.Raycast( ray , hitInfo )

			local isSelectedCard = false
			---- 有选到牌
		    if isCol then
		    	local colliderGameObject = hitInfo.collider.gameObject
		    	for k,card in ipairs(self.spList) do
		    		if card and colliderGameObject.transform == card.transform and card.callbackClick then
		    			self.touchSelectedCard = card
		    			isSelectedCard = true
		    			break
		    		end
		    	end
		    end

		    ------------------------------- 换三张模式的操作 ------------------------------------------
		    if self.nowShouPaiActionModel == self.shouPaiActionModel.huanSanZhang then
		    	if self.touchSelectedCard then
		    		if self.touchSelectedCard.posStatus == 1 then
		    			if self.nowSelectSanZhangNum > 0 then
		    				self:delSelectSanZhangPaiVec(self.touchSelectedCard)
		    				self.Model.delHuanSanZhangPai( self.touchSelectedCard.card )
		    				self.Model.saveHuanSanZhangData()
		    				self.touchSelectedCard:ChangePosStatus(0)

		    				if self.nowSelectSanZhangNum == self.maxSelectSanZhangNum then
		    					self:showAllMask()
		    				end

		    				self.nowSelectSanZhangNum = self.nowSelectSanZhangNum - 1
		    			end
		    		elseif self.touchSelectedCard.posStatus == 0 then
		    			if self.nowSelectSanZhangNum < self.maxSelectSanZhangNum then
		    				self:addSelectSanZhangPaiVec(self.touchSelectedCard)
		    				self.Model.addHuanSanZhangPai( self.touchSelectedCard.card )
		    				self.Model.saveHuanSanZhangData()
		    				self.touchSelectedCard:ChangePosStatus(1)
		    				self.nowSelectSanZhangNum = self.nowSelectSanZhangNum + 1
		    				if self.nowSelectSanZhangNum == self.maxSelectSanZhangNum then
		    					self:hideNotSelectPai()
		    				end
		    			end
		    		end
		    	end

		    	self.touchSelectedCard = nil

		    	if self.touchMoveCard then
					self.touchMoveCard:OnDestroy()
					self.touchMoveCard = nil
				end

		    	return
		    end

			---- 如果射线打到了牌
			if isSelectedCard then
				if self.touchMoveCard then
					self.touchMoveCard:OnDestroy()
					self.touchMoveCard = nil
				end
				if self.touchSelectedCard and self.touchSelectedCard.callbackClick then
					self.touchSelectedCard:callbackClick()

				end
			else
				if self.touchSelectedCard then
					if self:checkPaiCanOut(self.touchSelectedCard) then
						self:hideAllHint()
						self.touchSelectedCard:ChangePosStatus(1)
						self.lastPai = nil
						self.player:SendChupai(self.touchSelectedCard.card)

					else

					end
				end


				if self.touchMoveCard then
					self.touchMoveCard:OnDestroy()
					self.touchMoveCard = nil
				end

			end

			self.touchSelectedCard = nil
		end
	end

	if gameRuntimePlatform == "Ios" or gameRuntimePlatform == "Andriod" then
		----- windows
		dealTouch()


	else
		--[[if UnityEngine.Input.GetMouseButtonUp(0) then
			local ray = self.handCardCamera:ScreenPointToRay( UnityEngine.Input.mousePosition )
			local hitInfo = nil
			local isCol , hitInfo = UnityEngine.Physics.Raycast( ray , hitInfo )

		    if isCol then
		    	local colliderGameObject = hitInfo.collider.gameObject
		    	-- print("<color=yellow> hitInfo.collider.gameObject = ".. hitInfo.collider.gameObject .." </color>")
		    	for k,card in ipairs(self.spList) do
		    		if card and colliderGameObject.transform == card.transform and card.callbackClick then
		    			card:callbackClick()
		    			break
		    		end
		    	end

		    end
		end--]]
		
		--[[---- 移动设备
		if UnityEngine.Input.touchCount > 0 then
			print("<color=yellow>----------------- touchCount > 0 </color>")
		end

		if UnityEngine.Input.touchCount > 0 and UnityEngine.GetTouch(0).phase == UnityEngine.TouchPhase.Ended then
			print("<color=yellow>----------------- touch card end </color>")
			print( string.format( "<color=yellow> UnityEngine.Input.GetTouch(0).position : %.2f,%.2f </color>" , UnityEngine.Input.GetTouch(0).position.x ,UnityEngine.Input.GetTouch(0).position.y ) )
			local ray = self.camera:ScreenPointToRay( UnityEngine.Input.GetTouch(0).position )
			local hitInfo = nil
			local isCol , hitInfo = UnityEngine.Physics.Raycast( ray , hitInfo )

		    if isCol then
		    	print("<color=yellow>----------------- isCol is true </color>")
		    	local colliderGameObject = hitInfo.collider.gameObject
		    	-- print("<color=yellow> hitInfo.collider.gameObject = ".. hitInfo.collider.gameObject .." </color>")
		    	for k,card in ipairs(self.spList) do
		    		if card and colliderGameObject.transform == card.transform and card.callbackClick then
		    			print("<color=yellow>----------------- card.callbackClick </color>")
		    			card:callbackClick()
		    			break
		    		end
		    	end

		    end
		end--]]


		dealTouch()

	end

end

function C:nmjfg_ting_data_change_msg()
	self:HupaiTing()
end


---- 移除掉手牌的回调函数
function C:removeShouPaiCallBack()
	for k,v in pairs(self.spList) do
		v.callbackClick = nil
	end
end

function C:ClearCards()
	---- 清理
	for _,card in pairs(self.spList) do
		card:OnDestroy()
	end
	self.spList = {}

	for _,card in pairs(self.hpPaiList) do
		card:OnDestroy()
	end
	self.hpPaiList = {}
end

function C:MyExit()
	--print("MjXzMyShouPaiManger3D:MyExit")
	self.Logic.clearViewMsgRegister(self.listerRegisterName)

	self:ClearCards()

	if self.updateTimer then
		self.updateTimer:Stop()
		self.updateTimer = nil
	end

	self.shouPaiNodePos.transform.localPosition = self.shouPaiNodePosOriginPos 
	self.tpArrowTmpl = nil
	self.tpArrowTmpl3D = nil
end

---检查是否需要显示摸得牌
function C:checkIsShowMoPai()
	if self.Model.data.status == "start" or self.Model.data.status == "fp" or self.Model.data.status == "da_piao" or self.Model.data.status == "huan_san_zhang" or self.Model.data.status == "ding_que" then
		if self.Model.isZj() then
			return true
		end
	end
	--[[if self.Model.data.status == "mo_pai" and self.Model.isMyPermit() then
		return true
	end--]]

	return false
end

function C:Refresh(paiList, moPai, huPaiData ,cur_p, isFaPai )
	dump(moPai, "<color=red>moPaimoPai</color>")
	paiList = paiList or {}
	local paiList = self:SortList(paiList)

	--[[for k,card in ipairs(paiList) do
		print("<color=yellow> Refresh card = ".. card .." </color>")
	end--]]

	if self.touchMoveCard then
		self.touchMoveCard:OnDestroy()
		self.touchMoveCard = nil
	end
	if self.touchSelectedCard and self.touchSelectedCard.callbackClick then
		self.touchSelectedCard:callbackClick()
		self.touchSelectedCard = nil
	end


	self:HideTingPai()
	self:CancelHintYiChuxianPai()

	local filterPai = moPai or 0
	---- 血战的话直接只用一个
	local firstHuPaiData = nil

	-- 是否胡了
	self.isHu = false
	if huPaiData and #huPaiData > 0 then
		self.isHu = true
	end

	---- 血战模式只用一个数据
	if self.Model == MjXzModel or self.Model == MjXzFKModel then
		firstHuPaiData = huPaiData and huPaiData[1] or nil

		---- 看一下这个pailist是否包含了胡牌的数据，然后看MjXzSHouPaiManager3D.lua中的逻辑是否正确！！！！
		if filterPai == 0 and firstHuPaiData ~= nil then
			filterPai = firstHuPaiData.pai or 0
		end
	end
	
	print("<color=yellow>--------------- filterPai :".. filterPai .." </color>")
	local cpyList = {}
	local pai = 0
	for idx = 1, #paiList, 1 do
		pai = paiList[idx]
		if pai ~= filterPai then
			table.insert(cpyList, pai)
		else
			--过滤一张
			filterPai = 0
		end
	end
	dump(cpyList, "<color=yellow>cpyList :</color>")
	local spList = self.spList
	for idx = 1, #spList, 1 do
		spList[idx]:OnDestroy()
	end
	self.spList = nil
	self.spList = {}
	

	local newSpList = {}
	for idx = 1, #cpyList, 1 do
		pai = cpyList[idx]
		local item = self:createMyPlayerCard3D( self.Model.PaiType.sp , pai , function(selfCard)
			self:OnClickPai(selfCard)
		end )

		-- 如果是血流模式，那么糊了之后就得灰掉 ，不能点了
		if self:checkIsXlModel() then
			if self.isHu then
				item:SetMark(true)
				item.callbackClick = nil
			end
		end

		--- 游戏结束不能点了
		if self.Model.data.status=="settlement" or self.Model.data.status=="gameover" then
			item.callbackClick = nil
		end

		table.insert(newSpList, item)
		--- 设置位置
		item.transform.localPosition = self:getTargetPosByIndex(idx)
	end

	self.spList = newSpList
	self.lastPai = nil

	self:setNowLocalAngle( self.shouPaiNodePosOriAngle )

	--[[if self.Model.data.status == "start" and self.Model.daPiao then
		--- 有打漂功能的，发牌的时候所有的牌是扣着的
    	self:setNowLocalAngle( Vector3.New(-120,0,0) )
	end--]]

	--print("<color=yellow> ---------------------- isFaPai:" .. (isFaPai and "true" or "false") .. " </color>")
	if isFaPai then
		local randomCardVec = {}
		for i=1,#self.spList do
			randomCardVec[#randomCardVec+1] = self.spList[i]
		end
		
		local uiOffset = (self.player.uiPos - self.Model.GetSeatnoToPos(self.Model.data.zjSeatno))
		uiOffset = uiOffset >= 0 and uiOffset or (uiOffset + 4) 
		local delayTimeCount = uiOffset * self.Model.data.faPaiDelayTime
		---- 如果是发牌的话先打乱顺序
		for i=1,#self.spList do
			local randomPosIndex = math.random(1,#randomCardVec)
			local item = randomCardVec[randomPosIndex]
			item.transform.localPosition = self:getTargetPosByIndex(i)
			
			---- 如果是庄家&随机的索引数是最后一个。直接分割一下
			if self.Model.isZj() and i == #self.spList then
				item.transform.localPosition = Vector3.New( item.transform.localPosition.x + self.moPaiSpace , item.transform.localPosition.y , item.transform.localPosition.z )
			end

			item.gameObject:SetActive(false)

			MjAnimation.DelayTimeAction( function() 
				if IsEquals(item) and IsEquals(item.gameObject) then
		        	item.gameObject:SetActive(true)
		       	end
	        end , delayTimeCount + self.Model.data.faPaiDelayTime * 4 * math.floor((i - 1)/4)  )
			if (i - 1) % 4 == 0 then
				MjAnimation.DelayTimeAction( function() 
					ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_fapai.audio_name)
				end , delayTimeCount + self.Model.data.faPaiDelayTime * 4 * math.floor((i - 1)/4)  )
			end
	        table.remove(randomCardVec , randomPosIndex)
    	end
		
    	
    	---- 是发牌的话要先扣下再起来
    	if self.Model.daPiao then
    		--- 有打漂功能的，发牌的时候所有的牌是扣着的
    		self:setNowLocalAngle( Vector3.New(-120,0,0) )

    	else
	    	MjAnimation.DelayTimeAction( function() 
				MjAnimation.MyHandCardDownAndUp( self.shouPaiNodePos , -30 , self.shouPaiNodeAngleX , function()
					for i=1,#self.spList do
						self.spList[i].gameObject.transform.localPosition = self:getTargetPosByIndex(i)
					end
				end , function() 
					ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_deal.audio_name)

					--- 如果是庄家要隔一张
					--print("<color=yellow>/*/*/*/*/*/*/*/*/*/*/*/*  设置庄家牌隔一张 1</color>")
					if self.Model.isZj() then
						--print("<color=yellow>/*/*/*/*/*/*/*/*/*/*/*/*  设置庄家牌隔一张 2</color>")
						---- 出牌ting提示
						self:ChupaiTingArrow()

						local targetPos = self:getTargetPosByIndex(#self.spList)
						self.spList[#self.spList].gameObject.transform.localPosition = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )
					end

					if self.Model.data and self.Model.data.huanSanZhangVec and self.nowShouPaiActionModel == self.shouPaiActionModel.huanSanZhang then
						self:refreshHuanSanZhangPai(self.Model.data.huanSanZhangVec)
					end

				 end)
		    end , delayTimeCount + self.Model.data.faPaiDelayTime * 4 * math.floor((#cpyList - 1)/4) + 0.1 )
	    end

	end



	self:RefreshDQColor(nil)
	

	self:RefreshHuPai(huPaiData)

	--zp  如果有手抓牌
	if moPai ~= nil and moPai > 0 then
		--print("<color=yellow>-------+++++++++ -- moPai :".. moPai .." </color>")

		--print("<color=yellow>  ------------ hava moPai  </color>")
		---- 再创建一张牌到最后的索引位置去
		local card = self:createMyPlayerCard3D( self.Model.PaiType.zp, moPai, function(selfCard)
			self:OnClickPai(selfCard)
		end )

		self.zpPaiIndex = #self.spList + 1
		self.spList[self.zpPaiIndex] = card
		-- 位置
		local targetPos = self:getTargetPosByIndex(self.zpPaiIndex)
		card.transform.localPosition = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )

		--print( string.format("<color=yellow>-------+++++++++ -- moPai targetPos.x:%.2f , self.zpPaiIndex:%d </color>" , card.transform.localPosition.x , self.zpPaiIndex))
		self:HintYiChuxianPai(moPai)

		
		self:ChupaiTingArrow()
		

	else
		self.zpPaiIndex = nil
	end

	if not isFaPai and self:checkIsShowMoPai() then

		self.zpPaiIndex = #self.spList
	end

	if self.player:IsChupai() then
		--print("<color=yellow>----------------- self.player:IsChupai , true </color>")
		self:ChupaiTingArrow()
	else
		self:HupaiTing()
	end

	if not isFaPai then
		self:RefreshAllCardPos(false)
		
	end

	self:RefreshShouPaiNodePos()
end

function C:RotateUpShouPai()
	--- 位置直接设为正确的位置
    for i=1,#self.spList do
		self.spList[i].gameObject.transform.localPosition = self:getTargetPosByIndex(i)
	end

	--local nowAngle = self.shouPaiNodePos.transform.localEulerAngles
	--dump(nowAngle , "<color=yellow>--------------- RotateUpShouPai *** nowAngle </color>")
	--dump(self.shouPaiNodePosOriAngle , "<color=yellow>--------------- RotateUpShouPai *** self.shouPaiNodePosOriAngle </color>")
	MjAnimation.MyHandCardUp(self.shouPaiNodePos , Vector3.New( self.shouPaiNodePosOriAngle.x - self.nowAngle.x , self.shouPaiNodePosOriAngle.y - self.nowAngle.y , self.shouPaiNodePosOriAngle.z - self.nowAngle.z  ) , self.shouPaiNodePosOriAngle , function()   -- Vector3.New(self.shouPaiNodePosOriAngle.x - nowAngle.x , 0 , 0  )
		ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_deal.audio_name)

		--- 如果是庄家要隔一张
		--print("<color=yellow>/*/*/*/*/*/*/*/*/*/*/*/*  设置庄家牌隔一张 1</color>")
		if self.Model.isZj() then
			--print("<color=yellow>/*/*/*/*/*/*/*/*/*/*/*/*  设置庄家牌隔一张 2</color>")
			---- 出牌ting提示
			self:ChupaiTingArrow()

			local targetPos = self:getTargetPosByIndex(#self.spList)
			self.spList[#self.spList].gameObject.transform.localPosition = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )
		end

	end )
end

function C:setNowLocalAngle( angle)
	self.nowAngle = angle
	self.shouPaiNodePos.transform.localEulerAngles = self.nowAngle

end

function C:hidePai()
	self:setNowLocalAngle( Vector3.New(-120,0,0) )
end

------ 创建自己的手牌
function C:createMyPlayerCard3D( paiType , pai , callback )
	local card = MjCard3D.Create(self.shouPaiNodePos.transform , paiType , pai, callback)
	card.transform.gameObject.layer = LayerMask.NameToLayer("handCard")

	if paiType == self.Model.PaiType.sp or paiType == self.Model.PaiType.zp then	
		card:setOriMaterialName("mj_01")
	end

	return card
end

--p 玩家座位（1-4）
function C:Chupai(data)
	local pai = data.pai
	local from = data.from
	self:HideTingPai()
	self.autoShowCp = false

	self:CancelHintYiChuxianPai()

	
	if IsEquals(self.lastPai) then
		self.lastPai:ChangePosStatus(0)
		self.lastPai = nil
	end
	

	local spList = self.spList
	local spCnt = #spList
	if spCnt <= 0 then
		print(string.format("[MJ] MjXzMyShouPaiManger3D Chupai exception: spCnt(%d) <= 0", spCnt))
		return
	end

	local remList = {}
	for idx = 1, spCnt do
		--print("查找删除: " .. spList[idx].card)
		if spList[idx].card == pai then
			--print("删除：找到了 " .. idx)
			table.insert(remList, idx)
		end
	end
	local remCnt = #remList
	if remCnt <= 0 then
		print(string.format("[MJ] MjXzMyShouPaiManger3D Chupai exception: can't find(%d)", pai))
	end
	local deleteWorldPos = nil
	for idx = 1, remCnt, 1 do
		local index = remList[idx]
		--print("<color=yellow> --------------------------- for , spList[index].posStatus: ".. spList[index].posStatus .." </color>")
		if spList[index].posStatus ~= nil and spList[index].posStatus > 0 then
			deleteWorldPos = spList[index].gameObject.transform.position
			spList[index]:OnDestroy()
			--GameObject.Destroy(spList[index].gameObject)
			table.remove(spList, index)

			if self.zpPaiIndex and self.zpPaiIndex == index then
				self.zpPaiIndex = nil
			end

			--print("删除弹起的牌 " .. pai)
			break
		elseif idx == remCnt then
			deleteWorldPos = spList[index].gameObject.transform.position
			spList[index]:OnDestroy()
			--GameObject.Destroy(spList[index].gameObject)
			table.remove(spList, index)

			if self.zpPaiIndex and self.zpPaiIndex == index then
				self.zpPaiIndex = nil
			end
			--print("<color=yellow> --------------------------- delete last chupai , remCnt: ".. remCnt .." </color>")
			--print("删除相同的一张 " .. pai)
			break
		end
	end



	if self.zpPaiIndex then
		self.zpPaiIndex = self.zpPaiIndex - 1
		--self.zpPaiIndex = nil
	end

	--- 用出牌管理器出一张牌
	self.GamePanel.ChupaiMag:AddChupai(self.player.uiPos, pai ,false ,deleteWorldPos)



	self:RefreshAllCardPos(true)
	self:RefreshDQColor(true)
	self:HideTingArrow()

	self.zpPaiIndex = nil
end

--[[
data 
   type  -- peng ag zg wg
   pai
--]]
function C:PengGang(data)
	---- 所有牌下来
	self:hideAllHint()

	print("<color=yellow>-------------- MjMyShouPaiManger3D PengGang ---------------</color>")
	self:HideTingPai()
	self:CancelHintYiChuxianPai()

	if IsEquals(self.lastPai) then
		self.lastPai:ChangePosStatus(0)
		--self.lastPai.transform.localPosition= Vector3.New( self.lastPai.transform.localPosition.x , self.lastPai.transform.localPosition.y , 0 )
		self.lastPai = nil
	end

	local cntTbl = {
		["peng"] = 2,
		["ag"] = 4,
		["zg"] = 3,
		["wg"] = 1,
	}

	local remCnt = cntTbl[data.type] or 0
	if remCnt <= 0 then
		print(string.format("[MJ] MjXzMyShouPaiManger3D PengGang exception: invalid type(%s)", data.type))
		return
	end

	local pai = data.pai

	--local hasZP = IsEquals(self.zpPai)
	if self.zpPaiIndex and self.spList[self.zpPaiIndex] then
		if self.spList[self.zpPaiIndex].card == pai then
			--self.spList[self.zpPaiIndex]:OnDestroy()
			self:DelCardByIndex(self.zpPaiIndex)
			
			self.zpPaiIndex = nil
			remCnt = remCnt - 1
			--hasZP = false
		end
	end

	local spList = self.spList
	local spCnt = #spList
	if spCnt <= remCnt then
		print(string.format("[MJ] MjXzMyShouPaiManger3D PengGang exception: spCnt(%d) <= remCnt(%d)", spCnt, remCnt))
		return
	end
	----- 手摸牌索引要减少
	if self.zpPaiIndex and self.zpPaiIndex == spCnt then
		self.zpPaiIndex = self.zpPaiIndex - remCnt
	end

	if remCnt > 0 then
		local remList = {}
		for idx = 1, spCnt, 1 do
			if spList[idx].card == pai then
				table.insert(remList, idx)
				if #remList >= remCnt then break end
			end
		end

		for idx = #remList, 1, -1 do
			--GameObject.Destroy(spList[remList[idx]].gameObject)
			spList[remList[idx]]:OnDestroy()
			table.remove(spList, remList[idx])
		end
	end

	
	self:RefreshSPSort()
	--table.print("<color=blue>弯杠3:</color>",data)
	if data.type == "wg" then
		self.GamePanel.PengGangMag:ChangeWG(self.player.uiPos, data.pai)
	else
		self.GamePanel.PengGangMag:AddPg(self.player.uiPos, data)
	end

	if data.type == "zg" or data.type == "peng" then
		self.GamePanel.ChupaiMag:DelTail()
	end

	if data.type == "peng" then
		self:RefreshDQColor(false)
		self:ChupaiTingArrow()
		self.autoShowCp = true
	else
		self:HideTingArrow()
	end

	if self.zpPaiIndex and self.spList[self.zpPaiIndex] and self.spList[self.zpPaiIndex].card ~= pai then	
		self.aniTime = 0.2 -- self.aniTimeOrig
	else
		self.aniTime = 0.2
	end
	self:RefreshAllCardPos(true)
	self.aniTime = self.aniTimeOrig

	self:RefreshShouPaiNodePos()
end

function C:RefreshShouPaiNodePos()
	local pengGangNum = self.GamePanel.PengGangMag:getPengGangNum(self.player.uiPos)
    local targetPos	= Vector3.New( self.shouPaiNodePosOriginPos.x + pengGangNum * self.shouPaiNodePosPengGangAddOffset , self.shouPaiNodePosOriginPos.y , self.shouPaiNodePosOriginPos.z )

    if self.shouPaiNodePos.transform.localPosition.x ~= targetPos.x or self.shouPaiNodePos.transform.localPosition.y ~= targetPos.y or self.shouPaiNodePos.transform.localPosition.z ~= targetPos.z then
    	local tween = self.shouPaiNodePos.transform:DOLocalMove( targetPos , self.shouPaiNodePosAniTime )
    	local tweenKey = DOTweenManager.AddTweenToStop(tween)

    	tween:OnKill(function() 
    		DOTweenManager.RemoveStopTween(tweenKey) 

    		SafaSetTransformPeoperty(self.shouPaiNodePos , "localPosition" , targetPos)

    	end)
    end

	
end
--
function C:Mopai(pai)	
	---- 所有牌下来
	--self:hideAllHint()

	if IsEquals(self.lastPai) then
		self.lastPai:ChangePosStatus(0)
		--self.lastPai.transform.localPosition = Vector3.New( self.lastPai.transform.localPosition.x , self.lastPai.transform.localPosition.y , 0 )
		self.lastPai = nil
	end


	local card = self:createMyPlayerCard3D( self.Model.PaiType.zp, pai, function(selfCard)
			self:OnClickPai(selfCard)
	end )
	
	self.zpPaiIndex = #self.spList + 1
	self.spList[self.zpPaiIndex] = card

	---- 
	local targetPos = self:getTargetPosByIndex(self.zpPaiIndex)
	-- card.transform.localPosition = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )

	MjAnimation.ChaPai3D(card , Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z ))


	self:RefreshDQColor(false )
	self:HideTingPai()
	self:CancelHintYiChuxianPai()

	self:ChupaiTingArrow()

	self.hupai_hint_btn.gameObject:SetActive(false)

	self:HintYiChuxianPai(pai)
end

function C:Hupai(data)
	print("<color=yellow>-------------- MjMyShouPaiManger3D Hupai ---------------</color>")
	if data == nil or type(data) ~= "table" then
		print("[MJ] MjXzMyShouPaiManger3D Hupai exception: data invalid")
		return
	end

	---- 所有牌下来
	self:hideAllHint()

	local huType = data.hu_type
	local huIdx = data.shunxu
	local huPai = data.pai

	if huType == "qghu" then
		self.GamePanel.PengGangMag:ChangePeng()
	elseif huType == "pao" then
		self.GamePanel.ChupaiMag:DelTail()
	end

	MJParticleManager.MJHuPaiAni(self.player.uiPos)

	---- 
	
	if huType == "zimo" then
		self.player:PlayMusicEffect("zimo")
		ExtendSoundManager.PlaySound(audio_config.mj.majiang_hu_hu.audio_name)
		--- 如果有手牌则删掉
		if self.zpPaiIndex then
			self:DelCardByIndex(self.zpPaiIndex)
			self.zpPaiIndex = nil
		end
	--[[elseif huType == "tian_hu" then
		self.player:PlayMusicEffect("zimo")
		return  --- 
		--self:DelCardByIndex( #self.spList )--]]
	else
		self.player:PlayMusicEffect("hu")
		ExtendSoundManager.PlaySound(audio_config.mj.majiang_hu_hu.audio_name)
	end

	self:CancelHintYiChuxianPai()

	local huPai,targetPos = self:AddHuPai(data)

	self.isHu = true
	if self:checkIsXlModel() then
		self:RefreshSPList()
	end

	---- 胡牌特效
	if huPai then
		--("<color=yellow>-------------- MjAnimation.HuPai3D 特效 --------------- </color>")
		MjAnimation.HuPai3D(huPai,targetPos)
	end
end

function C:RefreshSPList()
	for k,v in ipairs(self.spList) do
		if self.isHu then
			--v:SetMark(true)
			v.callbackClick = nil
		end
	end
end

function C:Fapai(list)
	print("<color=yellow>  ------------------- myshoupaiMgr Fapai </color>")
	self:Refresh(list, 0, nil ,nil , true)
	--MjAnimation.FaPai(self.spList, function()
	--end)
end

function C:Dingque(dqColor )
	dump(dqColor)
	self.dqColor = dqColor
	self:RefreshDQColor(nil)

	self:RefreshAllCardPos(true)

end

function C:DingqueJustData(dqColor )
	dump(dqColor)
	self.dqColor = dqColor
	self:RefreshDQColor(nil)

	self:RefreshAllCardPos(false)
end

----- 没人调用可以不管
function C:RefreshList(list, paiRect, paiList, paiType)
	for k, v in pairs(list) do
		if not IsEquals(paiList[k]) then
			paiList[k] = MjCard.Create(paiRect, paiType, v, function(selfCard)
				self:OnClickPai(selfCard)
			end)
		elseif paiList[k].card ~= v then
			paiList[k]:OnDestroy()
			paiList[k] = MjCard.Create(paiRect, paiType, v, function(selfCard)
				self:OnClickPai(selfCard)
			end)
		end
	end

	for idx = #list + 1, #paiList, 1 do
		paiList[idx]:OnDestroy()
		paiList[idx] = nil
	end
	
	return paiList
end

function C:checkPaiCanOut(card)
	if not self.player:IsChupai() then
		return false
	end

	if not card.card then
		return false
	end

	local hasQP = false
	local dqColor = self.dqColor or 0
	if dqColor > 0 then
		if not hasQP then
			local spList = self.spList
			local spCnt = #spList
			for idx = 1, spCnt, 1 do
				if self.Model.GetSe(spList[idx].card) == dqColor then
					hasQP = true
					break
				end
			end
		end
	end
	if hasQP then
		if self.Model.GetSe(card.card) ~= dqColor then
			return false
		end
	end

	return true
end


function C:OnClickPai(selectedPai)
	if not self.player:IsChupai() then
		--- 是否选的相同的牌
		local isSelectSame = false
		if selectedPai.posStatus==0 then
			isSelectSame = false
		else
			isSelectSame = true
		end

		--- 将所有的牌给缩下去
		self:hideAllHint()

		if isSelectSame then
			--selectedPai:ChangePosStatus(0)
			self:CancelHintYiChuxianPai()
		else
			self.lastPai = selectedPai
			selectedPai:ChangePosStatus(1)
			self:HintYiChuxianPai(selectedPai.card)
		end
		ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_pickupcard.audio_name)
		return
	end
	--先打缺牌
	local hasQP = false

	local dqColor = self.dqColor or 0
	if dqColor > 0 then
		--[[if IsEquals(self.zpPai) then
			if self.Model.GetSe(self.zpPai.card) == dqColor then
				hasQP = true
			end
		end--]]

		if not hasQP then
			local spList = self.spList
			local spCnt = #spList
			for idx = 1, spCnt, 1 do
				if self.Model.GetSe(spList[idx].card) == dqColor then
					hasQP = true
					break
				end
			end
		end
	end

	if hasQP then
		if selectedPai.card and self.Model.GetSe(selectedPai.card) ~= dqColor then
			return
		end
	end

	local lastPai = self.lastPai
	if lastPai then
		self:HideTingPai()

		if lastPai == selectedPai then
			--self.cpZP = true
			--if selectedPai.transform.parent == self.spRect.transform then
			--	self.cpZP = false
			--end
			
			print("[MJ Debug] OnClickPai ChuPai: " .. selectedPai.card)
			self.lastPai = nil
			self.player:SendChupai(selectedPai.card)

			--- 发送牌后，清理回调，避免错误
			selectedPai.callbackClick = nil

			return
		end
		lastPai:ChangePosStatus(0)
		self:CancelHintYiChuxianPai()
	end

	--- 将所有的牌给缩下去
	self:hideAllHint()

	self.lastPai = selectedPai
	selectedPai:ChangePosStatus(1)

	self:HintYiChuxianPai(selectedPai.card)

	if not self:HasHuPai() then
		self:ShowChupaiTing(selectedPai.card)
	end
	ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_pickupcard.audio_name)
end

function C:CheckDQPai()
	local dqColor = self.dqColor or 0
	if dqColor <= 0 then return false end

	--[[if IsEquals(self.zpPai) then
		if self.Model.GetSe(self.zpPai.card) == dqColor then
			return true
		end
	end--]]

	local spList = self.spList
	local spCnt = #spList

	for idx = 1, spCnt, 1 do
		local pai = spList[idx].card
		if self.Model.GetSe(pai) == dqColor then
			return true
		end
	end

	return false
end

----- 刷新所有的位置
function C:RefreshAllCardPos( isDoEffect )
	--[[if not self.zpPaiIndex or not self.spList[self.zpPaiIndex] then
		print("<color=yellow> InsertSP , return </color>")
		return
	end--]]

	local spList = self.spList
	local spCnt = #spList

	if spCnt <= 0 then
		return
	end

	local rawList, sortList = self:Resort()

	local newSpList = {}

	local isFindInsertIndex = false
	local pai = 0
	for idx = 1, spCnt, 1 do
		pai = sortList[idx]
		for k, v in pairs(rawList) do
			if v == pai then
				rawList[k] = -1

				newSpList[idx] = spList[k]

				--插入动画做一次
				if not isFindInsertIndex and self.zpPaiIndex == k then
					isFindInsertIndex = true
					self.zpPaiIndex = idx
					-- MjAnimation.ChaPai(newSpList[idx].mj_bg_img)

					---- 如果要做动作 & 要插入的位置是最后一个位置。就做平移不做插入
					if idx == spCnt and isDoEffect then
						self.zpPaiIndex = nil
					end
				end
				break
			end
		end
	end

	self.spList = newSpList
	if self.zpPaiIndex then
		print("<color=yellow> InsertSP , self.zpPaiIndex = " .. self.zpPaiIndex .. " </color>")
	end
	----- 重刷位置
	if isDoEffect then
		self:refreshPosAndAni()
	else
		local setPosVec = {}
		if self.zpPaiIndex then
			for key,card in ipairs(self.spList) do
				if key ~= self.zpPaiIndex then
					setPosVec[#setPosVec+1] = card
				end
			end

			setPosVec[#setPosVec+1] = self.spList[self.zpPaiIndex]
			self.spList = setPosVec
			self.zpPaiIndex = #setPosVec

			for key,card in ipairs(setPosVec) do
				card.transform.localPosition = self:getTargetPosByIndex(key)
			end

			local targetPos = self:getTargetPosByIndex(self.zpPaiIndex)
			self.spList[self.zpPaiIndex].transform.localPosition = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )

		else
			for key,card in ipairs(self.spList) do
				card.transform.localPosition = self:getTargetPosByIndex(key)
			end
		end
		
	end

	if spCnt ~= #newSpList then
		print("出问题啦 。。。"..paiObject.card)
	end

end

-- 判断是否已经胡牌
function C:HasHuPai()
	local list = self.hpPaiList or {}
	return #list > 0
end

function C:RefreshDQColor(reset )
	--local dqColor = self.dqColor or 0
	local m_data=self.Model.data
  	local dqColor =0
  	local mySeatno = self.Model.GetPlayerSeat()

  	if m_data and m_data.playerInfo and mySeatno then
    		dqColor=m_data.playerInfo[mySeatno].lackColor or 0
  	end

	if dqColor <= 0 then return end

	local reset = reset
	if reset == nil then
		reset = not self.player:IsChupai()
	end
	if not reset then
		reset = not self:CheckDQPai()
	end

	local spList = self.spList
	local spCnt = #spList

	self:RefreshSPSort()

	if self:checkIsXlModel() and self:HasHuPai() then
		for idx = 1, spCnt, 1 do
			spList[idx]:SetMark(true)
		end
		if self.zpPaiIndex and spList[self.zpPaiIndex] then
			spList[self.zpPaiIndex]:SetMark(false)
		end
		
	else
		if reset then
			for idx = 1, spCnt, 1 do
				spList[idx]:SetMark(false)
			end
		else
			for idx = 1, spCnt, 1 do
				local pai = spList[idx].card
				if self.Model.GetSe(pai) == dqColor then
					spList[idx]:SetMark(false)
				else
					spList[idx]:SetMark(true)
				end
			end

		end
	end
end


function C:RefreshSPSort()
	local spList = self.spList
	local spCnt = #spList
	if spCnt <= 0 then return end

	for idx = 1, spCnt, 1 do
		spList[idx].transform:SetSiblingIndex(idx - 1)
	end
end

function C:InsertSP() 
	if not self.zpPaiIndex or not self.spList[self.zpPaiIndex] then
		print("<color=yellow> InsertSP , return </color>")
		return
	end

	local spList = self.spList
	local spCnt = #spList

	local rawList, sortList = self:Resort()

	local newSpList = {}

	local isFindInsertIndex = false
	local pai = 0
	for idx = 1, spCnt, 1 do
		pai = sortList[idx]
		for k, v in pairs(rawList) do
			if v == pai then
				rawList[k] = -1

				newSpList[idx] = spList[k]

				--插入动画做一次
				if not isFindInsertIndex and self.zpPaiIndex == k then
					isFindInsertIndex = true
					self.zpPaiIndex = idx
					-- MjAnimation.ChaPai(newSpList[idx].mj_bg_img)
				end
				break
			end
		end
	end

	self.spList = newSpList
	print("<color=yellow> InsertSP , self.zpPaiIndex = " .. self.zpPaiIndex .. " </color>")
	----- 重刷位置
	self:refreshPosAndAni()

	if spCnt ~= #newSpList then
		print("出问题啦 。。。"..paiObject.card)
	end
end

function C:Resort()
	local spList = self.spList
	local spCnt = #spList

	local rawList = {}
	for idx = 1, spCnt, 1 do
		rawList[idx] = spList[idx].card
	end

	local sortList = self:SortList(rawList)

	return rawList, sortList
end

function C:SortList(list)
	local qp = {}
	local sp = {}

	for k, v in pairs(list) do
		if self.Model.GetSe(v) == self.dqColor then
			qp[#qp + 1] = v
		else
			sp[#sp+1]=v
		end
	end

	if #qp > 1 then table.sort(qp, function(a, b) return a < b end) end
	if #sp > 1 then table.sort(sp, function(a, b) return a < b end) end

	local sort_list = {}

	
	for _, v in ipairs(sp) do
		table.insert(sort_list, v)
	end

	for _, v in ipairs(qp) do
		table.insert(sort_list, v)
	end

	return sort_list
end

function C:RefreshHuPai(data)
	dump(data, "<color=red>刷新胡牌</color>")
	if IsEquals(self.hpImg) then
		GameObject.Destroy(self.hpImg.gameObject)
		self.hpImg = nil
	end

	--删掉胡牌区的牌
	if self.hpPaiList and type(self.hpPaiList) == "table" then
		for k,v in pairs(self.hpPaiList) do
			--GameObject.Destroy(v.gameObject)
			v:OnDestroy()
		end
		self.hpPaiList = {}
	end

	if data == nil then return end
	
	

	--隐藏hint
	self.hupai_hint_btn.gameObject:SetActive(false)

    --删除自摸的牌
    if #data > 0 and not self:checkIsXlModel() then
		if self.zpPaiIndex and IsEquals( self.spList[self.zpPaiIndex] ) then
			self:DelCardByIndex(self.zpPaiIndex)

			--self.spList[self.zpPaiIndex]:OnDestroy()
			--table.remove( self.spList , self.zpPaiIndex)
			self.zpPaiIndex = nil

		end
		dump(data, "RefreshHuPai")
	end

	--[[local huType = data.hu_type
	local huIdx = data.shunxu
	local huPai = data.pai or 0--]]

	-- self.hpImg = MjAnimation.HuPai(self.player.uiPos, huType, huIdx, huPai, self.transform)
	-- self.hpImg = MJParticleManager.MJHuPai(self.player.uiPos, huType, huIdx, huPai, self.transform)
	--if huPai <= 0 then return end
	-- self.hpPai = MjCard.Create(self.hpRect, self.Model.PaiType.hp, huPai)

	for _,v in pairs(data) do
		self:AddHuPai(v)
	end

end

function C:AddHuPai(data)
	if not data then return end
	local huType = data.hu_type
	local huIdx = data.shunxu
	local huPai = data.pai or 0

	if IsEquals(self.hpImg) then
		GameObject.Destroy(self.hpImg.gameObject)
		self.hpImg = nil
	end

	if not self:checkIsXlModel() then
		self.hpImg = MJParticleManager.MJHuPai(self.player.uiPos, huType, huIdx, huPai, self.transform)
	end

	if huType == "tian_hu" then
		return nil
	end

	local card = MjCard3D.Create(self.huPaiNodePos.transform , self.Model.PaiType.hp , huPai )

	self:HideTingPai()
	self:HideTingArrow()
	self:CancelHintYiChuxianPai()

	local nextHuPaiIndex = #self.hpPaiList + 1
	self.hpPaiList[nextHuPaiIndex] = card
	--- 刷新胡牌的位置
	card.transform.localPosition = self:getHuPaiPos(nextHuPaiIndex , self.player.uiPos )

	return card , card.transform.localPosition
end

function C:ShowPoChan()
	if IsEquals(self.hpImg) then
		GameObject.Destroy(self.hpImg.gameObject)
		self.hpImg = nil
	end
	self.hpImg = MJParticleManager.MJHuPai(self.player.uiPos, "pochan", 1, 11, self.transform)
end

--听牌:出牌听 和 胡牌听
function C:ShowChupaiTing(pai)
	local tpList = self.tpList
	for k, v in pairs(tpList) do
		GameObject.Destroy(v.gameObject)
	end
	tpList = {}

	local data = self.Model.data
	if not data or not data.chupai_ting_data then
		return
	end

	dump(data.chupai_ting_data, "chupai_ting_data")

	local ting_data = data.chupai_ting_data[pai]
	if not ting_data then return end

	dump(ting_data, "ting_data")

	local total = 0

	--ting_pai,mul,remain
	local item = nil
	for k, v in pairs(ting_data) do
		item = MjCard.Create(self.tpArea, self.Model.PaiType.sp, v.ting_pai)
		item.mj_mul:GetComponent("Text").text = math.pow(2,v.mul) .. "倍"
		item.mj_cnt:GetComponent("Text").text = v.remain
		table.insert(self.tpList, item)

		if v.remain <= 0 then
			item:SetMark(true)
		end

		total = total + v.remain
	end

	self.tpTotalCnt.text = total

	self.tpRoot.gameObject:SetActive(true)
end

function C:ShowHupaiTing()
	local tpList = self.tpList
	for k, v in pairs(tpList) do
		GameObject.Destroy(v.gameObject)
	end
	tpList = {}

	local data = self.Model.data
	if not data or not data.ting_data then
		return
	end

	dump(data.ting_data, "hupai_ting_data")

	local ting_data = data.ting_data

	local total = 0

	--ting_pai,mul,remain
	local item = nil
	for k, v in pairs(ting_data) do
		item = MjCard.Create(self.tpArea, self.Model.PaiType.sp, v.ting_pai)
		item.mj_mul:GetComponent("Text").text = math.pow(2,v.mul) .. "倍"
		item.mj_cnt:GetComponent("Text").text = v.remain
		table.insert(self.tpList, item)

		if v.remain <= 0 then
			item:SetMark(true)
		end

		total = total + v.remain
	end

	self.tpTotalCnt.text = total

	self.tpRoot.gameObject:SetActive(true)
end

function C:HideTingPai()
	if self:HasHupaiTing() then
		self.hupai_hint_btn.gameObject:SetActive(true)
	else
		self.hupai_hint_btn.gameObject:SetActive(false)
	end

	local tpList = self.tpList
	for k, v in pairs(tpList) do
		GameObject.Destroy(v.gameObject)
	end
	tpList = {}

	self.tpRoot.gameObject:SetActive(false)
end

function C:HasHupaiTing()
	local data = self.Model.data
	if not data then
		return false
	end
	local ting_data = data.ting_data or {}

	local cnt = 0
	for k, _ in pairs(ting_data) do
		cnt = cnt + 1
		if cnt > 0 then return true end
	end

	return false
end

function C:OnHuPaiHintBtnDown()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	self:ShowHupaiTing()
end
function C:OnHuPaiHintBtnUp()
	self:HideTingPai()
end

function C:ChupaiTingArrow()
	print("[MJ Debug] ChupaiTingArrow")

	self:HideTingArrow()

	local data = self.Model.data
	if not data or not data.chupai_ting_data then
		print("<color=yellow>----- return ---- ChupaiTingArrow</color>")
		return
	end

	--胡牌不再显示
	if self:HasHuPai() then
		return
	end

	local ting_data = data.chupai_ting_data
	dump(ting_data, "chupai_ting_data")

	local tpArrowList = self.tpArrowList

	local spList = self.spList
	local spCnt = #spList

	local arrow = nil
	for pai, _ in pairs(ting_data) do
		for idx = 1, spCnt, 1 do
			if spList[idx].card == pai then
				arrow = GameObject.Instantiate(self.tpArrowTmpl3D, spList[idx].gameObject.transform )
				tpArrowList[idx] = arrow
			end
		end
	end


	self.tpArrowList = tpArrowList
end

function C:HupaiTing()
	print("[MJ Debug] HupaiTing")
	if not IsEquals(self.hupai_hint_btn) then return end
	--if self.hupai_hint_btn == nil or self.hupai_hint_btn.gameObject == nil then return end
	self:HideTingPai()
	if self:HasHupaiTing() then
		self.hupai_hint_btn.gameObject:SetActive(true)
		print("显示胡牌提示")
	else
		self.hupai_hint_btn.gameObject:SetActive(false)
		print("隐藏胡牌提示")
	end
end

function C:HideTingArrow()
	local tpArrowList = self.tpArrowList
	for _, v in pairs(tpArrowList) do
		GameObject.Destroy(v.gameObject)
	end
	self.tpArrowList = {}
end


--对已经出现的牌进行变颜色提示
function C:HintYiChuxianPai(card)
	if not card then
		return 
	end
	if self.curHintYiChuxianPai then
		self:CancelHintYiChuxianPai()
	end
	self.curHintYiChuxianPai=card
	local gp=self.player.gamePanel
    for i = 1, 4 do
       local player=gp.PlayerClass[i]
       if player and player.PPObjList then
       		for _,v in pairs(player.PPObjList) do 
       			if v.card==card then
       				v:SetHintMark()
       			end
       		end
       end
       if player and player.CPObjList then
       		for _,v in pairs(player.CPObjList) do 
       			if v.card==card then
       				v:SetHintMark()
       			end
       		end
       end
       if player and IsEquals(player.ShouPai.hpPai) then
       		if card==player.ShouPai.hpPai.card then
       			player.ShouPai.hpPai:SetHintMark()
       		end
       end
    end

end
function C:CancelHintYiChuxianPai()
	if not self.curHintYiChuxianPai then
		return 
	end

	local gp=self.player.gamePanel
	local card=self.curHintYiChuxianPai
	self.curHintYiChuxianPai=nil

    for i = 1, 4 do
       local player=gp.PlayerClass[i]
       if player and player.PPObjList then
       		for _,v in pairs(player.PPObjList) do 
       			if v.card==card then
       				v:CancelHintMark()
       			end
       		end
       end
       if player and player.CPObjList then
       		for _,v in pairs(player.CPObjList) do 
       			if v.card==card then
       				v:CancelHintMark()
       			end
       		end
       end
       if player and player.ShouPai.hpPaiList then
	       	for _,v in ipairs(player.ShouPai.hpPaiList) do
				if v.card==card then
					v:CancelHintMark()
				end
			end
        end

    end

end






---------------------------------------------------------------------------------------- 
----- 删掉尾部的牌
function C:DelTail()
	if self.spList and type(self.spList) == "table" then
		local tailIndex = #self.spList
		if self.spList[tailIndex] and self.spList[tailIndex].gameObject then
			self.spList[tailIndex]:OnDestroy()

			table.remove(self.spList , tailIndex)
		end
	end
end

---- 烧掉指定位置的牌
function C:DelCardByIndex(index)
	if self.spList and type(self.spList) == "table" then
		if self.spList[index] and self.spList[index].gameObject then
			self.spList[index]:OnDestroy()

			table.remove(self.spList , index)
		end
	end
end


----- 带动作的刷新位置
function C:refreshPosAndAni(  )
	for key,card in ipairs(self.spList) do
		local targetPos = self:getTargetPosByIndex(key)
		local nowPos = card.transform.localPosition

		--- 如果是定缺的颜色，然后看后面有没有不同的颜色，如果有则要搞动画
		local isDoDqAni = false
		if self.Model.GetSe(card.card) == self.dqColor then
			for i = 1 , #self.spList do
				if self.spList[i].transform.localPosition.x > nowPos.x then
					if i ~= self.zpPaiIndex and self.Model.GetSe(self.spList[i].card) ~= self.dqColor then
						isDoDqAni = true
						break
					end
				end
			end
		end

		local offset = (self.autoShowCp and key == #self.spList) and Vector3.New(self.moPaiSpace, 0, 0) or Vector3.zero

		if targetPos.x ~= nowPos.x or targetPos.y ~= nowPos.y or targetPos.z ~= nowPos.z then
			if key == self.zpPaiIndex or isDoDqAni then
				--print("<color=yellow> do doInsertAni--- </color>")
				if isDoDqAni and key == #self.spList and self:checkIsShowMoPai() then
					targetPos = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )
				end

				self:doInsertAni(card , targetPos + offset)
			else
				if key == #self.spList and self.Model.data.status == "ding_que" and self.Model.isZj() then
					targetPos = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )
				end
				--[[if key == #self.spList and self.Model.data.status == "peng_gang_hu" and self.Model.data.pgh_data and self.Model.data.pgh_data.peng then
					targetPos = Vector3.New( targetPos.x + self.moPaiSpace , targetPos.y , targetPos.z )
				end--]]

				self:doParallelAni(card , targetPos + offset)
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
		SafaSetTransformPeoperty(cardNode , "localPosition" , targetPos)

		DOTweenManager.RemoveStopTween(tweenKey) 
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

		SafaSetTransformPeoperty(cardNode , "localPosition" , targetPos)

		DOTweenManager.RemoveStopTween(tweenKey) 
	end)

end

function C:getHuPaiPos(index , playerUiPos)
	local huPaiPosCfg = self.Model.HuPaiPosCfg[playerUiPos]

	local rowNum = math.floor((index-1) / huPaiPosCfg.splitNum)
	local offset = Vector3.New( rowNum * huPaiPosCfg.splitOffset.x , rowNum * huPaiPosCfg.splitOffset.y, rowNum * huPaiPosCfg.splitOffset.z)

	return Vector3.New( ((index-1) % huPaiPosCfg.splitNum) * MjCard3D.size.x + offset.x , 0 + offset.y , 0 + offset.z )

end


function C:showPengHint(pengData)
	local dealNum = 0
	for key,card in ipairs(self.spList) do
		if card.card == pengData.pai then
			dealNum = dealNum + 1
			if dealNum > 2 then
				break
			else
				card:ChangePosStatus(1)
			end
		end
	end
end

function C:showGangHint(gangData)
	for _,data in pairs(gangData) do
		for key,card in ipairs(self.spList) do
			if card.card == data.pai then
				card:ChangePosStatus(1)
			end
		end
	end
end


function C:hidePengGangHint()
	for key,card in ipairs(self.spList) do
		card:ChangePosStatus(0)
	end
end

function C:showAllHint()
	for key,card in ipairs(self.spList) do
		card:ChangePosStatus(1)
	end
end

function C:hideAllHint()
	for key,card in ipairs(self.spList) do
		card:ChangePosStatus(0)
	end
	self:HideTingPai()
	self:CancelHintYiChuxianPai()
	

end


function C:resetAllSelectHuanPai()
	if self.nowShouPaiActionModel == self.shouPaiActionModel.huanSanZhang then
		print("<color=yellow>------------ myshoupaiMgr resetAllSelectHuanPai ------------------</color>",self.nowSelectSanZhangNum)
		dump(self.nowSelectSanZhangPaiVec , "<color=red>---------------- self.nowSelectSanZhangPaiVec: </color>")
		if self.nowSelectSanZhangNum > 0 then
			for k,value in pairs(self.nowSelectSanZhangPaiVec) do
				self.Model.delHuanSanZhangPai(value.card)
				
			end
			self.Model.saveHuanSanZhangData()
			self.nowSelectSanZhangPaiVec = {}
			self.nowSelectSanZhangNum = 0
			self:showAllMask()
		end
	end
end
