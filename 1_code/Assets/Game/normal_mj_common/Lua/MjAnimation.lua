MjAnimation = {}
function MjAnimation.ChuPai(cpPaiObj)
	local tran =cpPaiObj.transform
	local cg = tran:GetComponent("CanvasGroup")
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:AppendInterval(1)
	seq:Append(cg:DOFade(0, 1))
	seq:AppendInterval(1)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(cpPaiObj.gameObject)
	end)
end

--碰杠胡
function MjAnimation.AniItemMjPGH(p,mjType)
	local pos = Vector3.zero
	if p == 1 then
		pos = Vector3.New(0,-200,0)
	elseif p == 2 then
		pos = Vector3.New(200,0,0)
	elseif p == 3 then
		pos = Vector3.New(0,200,0)
	elseif p == 4 then
		pos = Vector3.New(-200,0,0)
	end

	local parent = GameObject.Find("Canvas/LayerLv1")
	local UIEntity = newObject("ItemMjPGH", parent.transform)
	UIEntity.transform.localPosition = pos
	local img = UIEntity.transform:GetComponent("Image")
	local imgStr=""
	if mjType == MjCard.PaiType.hp then
		imgStr = "mj_game_icon_hu"
	elseif mjType == MjCard.PaiType.zg or mjType == MjCard.PaiType.wg or mjType == MjCard.PaiType.ag then
		imgStr = "mj_game_icon_gang"
	elseif mjType == MjCard.PaiType.pp then
		imgStr = "mj_game_icon_peng"
	end
	img.sprite = GetTexture(imgStr)

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:AppendInterval(3)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(UIEntity)
	end)
end

--mjPos 当前麻将的绝对坐标 mj.transform.position
function MjAnimation.CurrMjHint(curMj,p)
	local pos = Vector3.zero
	if p == 1 then
		pos = Vector3.New(0,50,0)
	elseif p == 2 then
		pos = Vector3.New(0,30,0)
	elseif p == 3 then
		pos = Vector3.New(0,50,0)
	elseif p == 4 then
		pos = Vector3.New(0,30,0)
	end

	local UIEntity = newObject("ItemCurrMjHint", curMj.transform)
	UIEntity.transform.localPosition = Vector3.New(pos.x, pos.y, 0)
	return UIEntity
end

function MjAnimation.FaPai(spList, callback)
	local tempSPL = {}
	math.randomseed(os.time())
	for k,v in pairs(spList) do
		v.mj_bg_img.gameObject:SetActive(false)
		v.gameObject.transform:SetSiblingIndex(math.random(1,#spList))
	end  

	for k,v in pairs(spList) do
		local tf = v.gameObject.transform
		tempSPL[tf:GetSiblingIndex()] = v
	end  

	local spCnt = #spList

	local framerate = 30
	local imgAni = nil

	ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_deal.audio_name)

	local count = 1
	local countTail = 1
	Timer.New(function ()
		countTail = count + 3
		if countTail > spCnt then countTail = spCnt end
		for idx = count, countTail, 1 do
			tempSPL[spCnt - idx + 1].mj_bg_img.gameObject:SetActive(false)
			tempSPL[spCnt - idx + 1].mj_img_ani.gameObject:SetActive(true)
			imgAni = tempSPL[spCnt - idx + 1].mj_img_ani.transform:GetComponent("UI2DImageAnimation")
			imgAni.framerate = framerate
			imgAni:SetFGFrame(3, tempSPL[spCnt - idx + 1].mj_img.sprite)
	
			imgAni:Play(function(pad)
				tempSPL[spCnt - idx + 1].mj_bg_img.gameObject:SetActive(true)
				tempSPL[spCnt - idx + 1].mj_img_ani.gameObject:SetActive(false)
				tempSPL[spCnt - idx + 1].mj_ani_bg.transform:GetComponent("Image").sprite = GetTexture("mj_green_ani1")
				tempSPL[spCnt - idx + 1].mj_ani_fg.gameObject:SetActive(false)

				if idx == spCnt then
					--从新排序
					for k,v in pairs(spList) do
						v.mj_img_ani.gameObject:SetActive(true)
						v.gameObject.transform:SetAsLastSibling()
					end
					Timer.New(function ()
						for k,v in pairs(spList) do
							v.mj_img_ani.gameObject:SetActive(false)
						end
						MJParticleManager.MJFanPai(spList[spCnt].transform.parent.transform.position)
					end, 0.15, 1):Start()
				end

				if callback ~= nil and idx == spCnt then
					callback()
				end
			end)
		end

		if count < spCnt then
			count = count + 4
		else
			count = 13
		end
	end, 0.2, 4):Start()
	
	-- print("<color=red>发牌啦啦啦啦啦</color>")
	-- local call = function ()
	-- 	countTail = count + 3
	-- 	print("<color=red>countTail=" .. countTail .. "</color>")
	-- 	if countTail > spCnt then countTail = spCnt end
	-- 	for idx = count, countTail, 1 do
	-- 		tempSPL[spCnt - idx + 1].mj_bg_img.gameObject:SetActive(false)
	-- 		tempSPL[spCnt - idx + 1].mj_img_ani.gameObject:SetActive(true)
	-- 		imgAni = tempSPL[spCnt - idx + 1].mj_img_ani.transform:GetComponent("UI2DImageAnimation")
	-- 		imgAni.framerate = framerate
	-- 		imgAni:SetFGFrame(3, tempSPL[spCnt - idx + 1].mj_img.sprite)
	
	-- 		imgAni:Play(function(pad)
	-- 			tempSPL[spCnt - idx + 1].mj_bg_img.gameObject:SetActive(true)
	-- 			tempSPL[spCnt - idx + 1].mj_img_ani.gameObject:SetActive(false)
	-- 			tempSPL[spCnt - idx + 1].mj_ani_bg.transform:GetComponent("Image").sprite = GetTexture("mj_green_ani1")
	-- 			tempSPL[spCnt - idx + 1].mj_ani_fg.gameObject:SetActive(false)

	-- 			if idx == spCnt then
	-- 				--从新排序
	-- 				for k,v in pairs(spList) do
	-- 					v.mj_img_ani.gameObject:SetActive(true)
	-- 					v.gameObject.transform:SetAsLastSibling()
	-- 				end
	-- 				Timer.New(function ()
	-- 					for k,v in pairs(spList) do
	-- 						v.mj_img_ani.gameObject:SetActive(false)
	-- 					end
	-- 					MJParticleManager.MJFanPai(spList[spCnt].transform.parent.transform.position)
	-- 				end, 0.15, 1):Start()
	-- 			end

	-- 			if callback ~= nil and idx == spCnt then
	-- 				callback()
	-- 			end
	-- 		end)
	-- 	end

	-- 	if count < spCnt then
	-- 		count = count + 4
	-- 	else
	-- 		count = 13
	-- 	end
	-- end
	-- print("<color=red>发牌动画创建</color>")
	-- local seq = DG.Tweening.DOTween.Sequence()
	-- local tweenKey = DOTweenManager.AddTweenToStop(seq)
	-- seq:AppendCallback(function ()
	-- 	print("<color=red>发牌动画1</color>")
	-- 	call()
	-- end)
	-- seq:AppendInterval(0.2)
	-- seq:AppendCallback(function ()
	-- 	print("<color=red>发牌动画2</color>")
	-- 	call()
	-- end)
	-- seq:AppendInterval(0.2)
	-- seq:AppendCallback(function ()
	-- 	print("<color=red>发牌动画3</color>")
	-- 	call()
	-- end)
	-- seq:AppendInterval(0.2)
	-- seq:AppendCallback(function ()
	-- 	print("<color=red>发牌动画4</color>")
	-- 	call()
	-- end)
	-- seq:OnKill(
	-- function()
	-- 	print("<color=red>发牌动画结束</color>")
	-- 	DOTweenManager.RemoveStopTween(tweenKey)
	-- end)
end

function MjAnimation.ChaPai(paiNode, callback)
	local tran = paiNode.transform
	tran.localPosition = Vector3.New(0,50,0)
	local tweenMove = tran:DOLocalMove(Vector3.zero, 0.5)
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:Append(tweenMove):OnKill(
	function()
		DOTweenManager.RemoveStopTween(tweenKey)
		if IsEquals(tran) then
		  	tran.localPosition = Vector3.zero
	    end
	  	if callback ~= nil then callback() end
	end)

	return seq
end

function MjAnimation.ChaPai3D(paiNode , targetPos)
	local tran = paiNode.transform
	local totalHeight = 2 * MjCard3D.size.z
	local upSecondHeight = 0.6 * MjCard3D.size.z
	tran.localPosition = Vector3.New(targetPos.x , targetPos.y , targetPos.z + totalHeight)
	local tweenMove = tran:DOLocalMove(targetPos, 0.08):SetEase(DG.Tweening.Ease.Linear)
	local tweenUp = tran:DOLocalMove(Vector3.New(targetPos.x , targetPos.y , targetPos.z + upSecondHeight), 0.07):SetEase(DG.Tweening.Ease.Linear)
	local tweenDown = tran:DOLocalMove(targetPos, 0.05):SetEase(DG.Tweening.Ease.Linear)
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:Append(tweenMove)
	seq:Append(tweenUp)
	seq:Append(tweenDown):OnKill(
	function()
		DOTweenManager.RemoveStopTween(tweenKey)
		if IsEquals(tran) then
		  	tran.localPosition = targetPos
	    end 
	end)

	return seq
end

---- 自己的手牌扣下再起来
function MjAnimation.MyHandCardDownAndUp( cardPosNode , downAngle , upAngle , callback , completeCall )
	local tran = cardPosNode.transform

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
    local rotateDown = tran:DOLocalRotate( Vector3.New(downAngle,0,0) , 0.1 ):SetEase(DG.Tweening.Ease.Linear):OnComplete(function() 
		if callback then
			callback()
		end
	end)
    local rotateUp = tran:DOLocalRotate( Vector3.New(upAngle,0,0) , 0.15 ):SetEase(DG.Tweening.Ease.Linear):OnComplete(function() 
		if completeCall then
			completeCall()
		end
	end)

    seq:Append(rotateDown)
    seq:AppendInterval(0.08)
    seq:Append(rotateUp)

    seq:OnKill(
	function()
		DOTweenManager.RemoveStopTween(tweenKey)
		--if IsEquals(tran) then
		--  	tran.localEulerAngles = Vector3.New(upAngle,0,0)
	    --end

	    SafaSetTransformPeoperty(cardPosNode , "localEulerAngles.x" , upAngle)
	end)

end

function MjAnimation.MyHandCardUp(cardPosNode , addAngle , targetAngle , completeCall)
	local tran = cardPosNode.transform

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
   	
    local rotateUp = tran:DOLocalRotate( addAngle , 0.5 , DG.Tweening.RotateMode.LocalAxisAdd ):SetEase(DG.Tweening.Ease.Linear):OnComplete(function() 
		if completeCall then
			completeCall()
		end
	end)

    seq:Append(rotateUp)

    seq:OnKill(
	function()
		DOTweenManager.RemoveStopTween(tweenKey)
	    SafaSetTransformPeoperty(cardPosNode , "localEulerAngles" , targetAngle)
	end)
end

local HUPAI_TABLE = {
	[1] = Vector3.New(0,-200,0),
	[2] = Vector3.New(-500,0,0),
	[3] = Vector3.New(0,200,0),
	[4] = Vector3.New(500,0,0)
}

function MjAnimation.HuPaiAnimation(p, parent, callback)
	local pos = HUPAI_TABLE[p]
	if pos == nil then return end

	local UIEntity = newObject("ItemMjHuPaiAni", parent.transform)
	UIEntity.transform.localPosition = pos

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	local tweenMove = UIEntity.transform:DOMove(pos, 0.6):From()
	seq:Append(tweenMove):OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey)
		if IsEquals(UIEntity) then
			UIEntity.transform.localPosition = pos
			GameObject.Destroy(UIEntity.gameObject)
		end
		if callback then
			callback()
		end
	end)
end

function MjAnimation.HuPai(p, huType, huIdx, huPai, parent)
	local pos = HUPAI_TABLE[p]
	if pos == nil then return end

	local UIEntity = newObject("ItemMjHuPai", parent.transform)
	local img = UIEntity.transform:GetComponent("Image")

	local imgStr=""
	if huType == "zimo" then
		imgStr = "mj_game_icon_zimo"..huIdx
	else
		imgStr = "mj_game_icon_hu"..huIdx
	end
	img.sprite = GetTexture(imgStr)
	img:SetNativeSize()
	UIEntity.transform.localPosition = pos

	return UIEntity
end

function MjAnimation.DQIcon(dqIcon)
	local pos = dqIcon.transform.localPosition
	local tween1 = dqIcon.transform:DOMove(Vector3.zero,0.5):From()
	local tween2 =  dqIcon.transform:DOScale(Vector3.one * 1.2,0.5):From():OnComplete(function()
		MJParticleManager.MJDQIcon(dqIcon.transform.position)
	end)
	
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:Append(tween1):Append(tween2):OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		if IsEquals(dqIcon) then
			dqIcon.transform.localPosition = pos
		end
	end)
end

function MjAnimation.TJColor(tjImg)	
	local TJFX = MJParticleManager.MJDQSwitchCreate(tjImg)	
	local tween = tjImg.transform:DOScale (Vector3.one * 1.2, 0.7):SetEase (DG.Tweening.Ease.Linear):SetLoops (-1, DG.Tweening.LoopType.Yoyo)
	local tweenKey = DOTweenManager.AddTweenToStop(tween)
	tween:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(TJFX.gameObject)
		if IsEquals(tjImg) then
			tjImg.transform.localScale = Vector3.one
		end
	end)
	return tweenKey
end

function MjAnimation.TJColorOnKill(tweenKey,tjImg)
	if tweenKey then
		local tween = DOTweenManager.GetKeyToTween(tweenKey)
		if tween then
			tween:Kill()
	    end
	end
end

local CHANGE_SCORE_TABLE = {
	[1] = Vector3.New(0,-256,0),
	[2] = Vector3.New(690,165,0),
	[3] = Vector3.New(0,425,0),
	[4] = Vector3.New(-690,80,0)
}
-- 分数 父节点
function MjAnimation.ChangeScore(score, p)
	print("<color=red>改变分数</color>",score,p)
	local parent = GameObject.Find("Canvas/LayerLv2")
	local typeStr
	local strScore
	if score > 0 then
		typeStr = "ItemMjScoreAdd"
		strScore = "+" .. StringHelper.ToCash(score)
	elseif score < 0 then
		typeStr = "ItemMjScoreRem"
		strScore = "-" .. StringHelper.ToCash(score)
	else
		typeStr = "ItemMjScoreAdd"
		strScore = "0"
	end
	local scoreItem = GameObject.Instantiate(GetPrefab(typeStr), parent.transform)
	local textCom = scoreItem.transform:GetComponent("Text")
	textCom.text = strScore
	scoreItem.transform.localPosition = CHANGE_SCORE_TABLE[p]
	local seq = scoreItem.transform:DOLocalMoveY(CHANGE_SCORE_TABLE[p].y + 50, 1)
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(scoreItem)
	end)
end

-- 分数 父节点
function MjAnimation.ShowLast4Pai(startPos,targetPos)
	local parent = GameObject.Find("Canvas/LayerLv1")
	local hintItem = newObject("ItemLast4Pai", parent.transform)
	hintItem.transform.localPosition = Vector3.zero
	local tran = hintItem.transform
	local cg = tran:GetComponent("CanvasGroup")
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:AppendInterval(1)
	seq:Append(cg:DOFade(0, 1))
	seq:AppendInterval(1)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(hintItem.gameObject)
	end)
end

--- add by wss 指示灯闪烁
function MjAnimation.BlinkZhiShiDeng( zhishidengNode , darkColor , now_tweenKey )
	local oldTween = DOTweenManager.GetKeyToTween (now_tweenKey)
	if oldTween then
		oldTween:Kill()
	end

	local tran = zhishidengNode.transform
	local bright = zhishidengNode:GetComponent("MeshRenderer").material:DOColor( Color.New(1,1,1,1) , 0.5 )
	local dark = zhishidengNode:GetComponent("MeshRenderer").material:DOColor( darkColor , 0.5 )
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)

	seq:Append(bright)
	seq:Append(dark)
	seq:SetLoops(-1, DG.Tweening.LoopType.Yoyo)

	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
	end)

	return tweenKey
end

----- 出牌口降低&升起
function MjAnimation.CardDoorDownAndUp( cardDoorNode , downCallBack )
	local cardDoorNode = cardDoorNode
	local cardDoorTran = cardDoorNode.transform
	local downCallBackTem = downCallBack
	local doorDown = cardDoorTran:DOLocalMoveY(-0.7 , 1):OnComplete(function() 
		if downCallBackTem then
			downCallBackTem()
			downCallBackTem = nil
		end
	end)
	local doorUp = cardDoorTran:DOLocalMoveY(0 , 1)
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:Append(doorDown)
	seq:Append(doorUp)
	seq:OnKill(function ()
		if downCallBackTem then
			downCallBackTem()
			downCallBackTem = nil
		end
		--cardDoorTran.localPosition = Vector3.New( cardDoorTran.localPosition.x , 0 , cardDoorTran.localPosition.z )

		SafaSetTransformPeoperty(cardDoorNode , "localPosition.y" , 0)

		DOTweenManager.RemoveStopTween(tweenKey)
	end)

	
end

----- 当前出牌的指标的上下的动作
function MjAnimation.nowChuPaiUpDownAni( hintNode , globalPos , old_tweenKey )
	local oldTween = DOTweenManager.GetKeyToTween (old_tweenKey)
	if oldTween then
		DOTweenManager.RemoveStopTween(oldTween)
		oldTween:Kill()
		--print( "<color=red> --------------------- old_tweenKey " .. old_tweenKey .. " </color>" )
	end

	local hintNodeTran = hintNode.transform
	local startPos = Vector3.New( globalPos.x , globalPos.y + 0.1  , globalPos.z )
	hintNodeTran.position = startPos

	local moveUp = hintNodeTran:DOMoveY(  startPos.y + 0.2  , 0.5 )
	local moveDown = hintNodeTran:DOMoveY(  startPos.y  , 0.5 )

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)

	seq:Append(moveUp)
	seq:Append(moveDown)

	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
	end)

	seq:SetLoops(-1, DG.Tweening.LoopType.Yoyo)

	return tweenKey
end

----- 出牌动画
function MjAnimation.ChuPai3D( cardNode , targetPos , startPos , isPlayer )
	local cardNode = cardNode
	local cardNodeTran = cardNode.transform


	local startPosTem = Vector3.New( targetPos.x + 0.5 * MjCard3D.size.x , targetPos.y , targetPos.z )
	if startPos then
		cardNodeTran.position = startPos
		local offset = 0
		if isPlayer then
			offset = 0.5 * MjCard3D.size.y
		else
			offset = 1.5 * MjCard3D.size.y
		end

		cardNodeTran.localPosition = Vector3.New(cardNodeTran.localPosition.x , cardNodeTran.localPosition.y , cardNodeTran.localPosition.z + offset )
	else
		cardNodeTran.localPosition = startPosTem
	end

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	local tween = cardNodeTran:DOLocalMove(targetPos , 0.15):SetEase(DG.Tweening.Ease.Linear)
	seq:Append(tween)

	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		SafaSetTransformPeoperty(cardNode , "localPosition" , targetPos)
	end)

end

---- 碰杠的麻将牌动作
function MjAnimation.PengGangAnimation( cardNode , targetPos , penggangData )
	local cardNode = cardNode
	local cardNodeTran = cardNode.transform

	local delayTimeOri = 0.2
	local delayTime = delayTimeOri
	local offset = 2 * MjCard3D.size.x
	if penggangData.isPengLastCard or penggangData.isGangLastCard then
		if penggangData.isPengLastCard then
			offset = offset + 1 * MjCard3D.size.x
		end
		delayTime = 0

		cardNodeTran.localPosition = Vector3.New( targetPos.x - offset , targetPos.y , targetPos.z + 4*MjCard3D.size.z)
	else
		cardNodeTran.localPosition = Vector3.New( targetPos.x - offset , targetPos.y , targetPos.z )

	end

	
	local tween = cardNodeTran:DOLocalMoveX(targetPos.x , 0.5):SetEase(DG.Tweening.Ease.OutSine)
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:AppendInterval(delayTime)
	if penggangData.isPengLastCard or penggangData.isGangLastCard then
		local acTime = 0.1     --- 这个时间要小于delayTimeOri
		seq:Append(cardNodeTran:DOLocalMoveZ(targetPos.z , acTime):SetEase(DG.Tweening.Ease.InSine))
		seq:AppendInterval(delayTimeOri - acTime)
	end
	seq:Append(tween)

	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)

		SafaSetTransformPeoperty(cardNode , "localPosition" , targetPos)
	end)

end


function MjAnimation.HeadBG(fill_img,cg,countdown)
	fill_img.fillAmount = 0
	local t = 0
	local direction = 0.02
	local countNum = countdown / direction
	
	-- local angleDire = (endFillAmount - startFillAmount) * 360 / countNum
	local fillAmountDire = 1 / countNum
	local timer = Timer.New(function ()
		-- lerp = Mathf.Lerp(startFillAmount,endFillAmount,t)
		-- t = t + direction
		if fill_img.fillAmount then
			fill_img.fillAmount = fill_img.fillAmount + fillAmountDire
		end
		-- effect.transform:RotateAround(Vector3.zero, Vector3.back,angleDire)
	
	end, direction,countNum)
	timer:Start()

	-- local timerCG = Timer.New(function ()
	-- 	if cg.alpha then
	-- 		if cg.alpha == 0.5 then
	-- 			cg:DOFade(1,0.5)
	-- 		else
	-- 			cg:DOFade(0.5,0.5)
	-- 		end
	-- 	end
	-- end, 0.5, -1)
	-- timerCG:Start()

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:Append(cg:DOFade(0.5, 0.5))
	seq:Append(cg:DOFade(1, 0.5))
	seq:SetLoops(-1, DG.Tweening.LoopType.Restart)
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
	end)

	return timer,seq
end

--type : 1 出牌不合法 2 操作失败
function MjAnimation.Hint(type,startPos,targetPos)
	local parent = GameObject.Find("Canvas/LayerLv1").transform
	local hintItem =GameObject.Instantiate(GetPrefab("ItemMjGameHint"),parent)
	local sprite = ""
	--1 出牌不合法
	if type == 1 then
		sprite = "mj_font_inconformity"
	elseif type == 2 then
		sprite = "game_imgf_failure_normal_mj_common"
	end
	local img = hintItem:GetComponent("Image")
	img.sprite = GetTexture(sprite)
	img:SetNativeSize()
	hintItem.transform.localPosition = startPos
	local seq = hintItem.transform:DOLocalMove(targetPos,0.8)
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(hintItem.gameObject)
	end)
end


----- 一个延迟效果
function MjAnimation.DelayTimeAction( callback , delaytime )
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	local callbackTem = callback
	seq:AppendInterval(delaytime):OnComplete(function() 
		if callbackTem then
			callbackTem()
			callbackTem = nil
			callback = nil
		end
	end)
	seq:OnKill(function()
		DOTweenManager.RemoveStopTween(tweenKey)
		if callbackTem then
			callbackTem()
			callbackTem = nil
			callback = nil
		end
	end)
end

---- 胡牌
function MjAnimation.HuPai3D( cardNode , targetPos )
	local cardNode = cardNode
	local cardNodeTran = cardNode.transform
	cardNodeTran.localPosition = Vector3.New(targetPos.x , targetPos.y , targetPos.z + 2)

	local huEffect = GameObject.Instantiate( GetPrefab( "majiang_hu" ), cardNodeTran )
	--huEffect.transform.localEulerAngles = cardNodeTran.localEulerAngles

	local moveDown = cardNodeTran:DOLocalMove( targetPos , 0.5 ):SetEase(DG.Tweening.Ease.OutSine)
	local tweenKey = DOTweenManager.AddTweenToStop(moveDown)

	moveDown:OnKill(function()
		SafaSetTransformPeoperty(cardNode , "localPosition" , targetPos)
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(huEffect.gameObject)	
	end)

end


function MjAnimation.ChangeWaitUI(fill_img,effect,startFillAmount,endFillAmount)
	local t = 0
	local totalTime = 0.5
	local direction = 0.02
	local countNum = totalTime / direction
	local angleDire = (endFillAmount - startFillAmount) * 360 / countNum
	local fillAmountDire = (endFillAmount - startFillAmount) / countNum
	local timer = Timer.New(function ()
		-- lerp = Mathf.Lerp(startFillAmount,endFillAmount,t)
		-- t = t + direction
		-- print("<color=yellow>事件</color>",t)

		fill_img.fillAmount = fill_img.fillAmount + fillAmountDire
		if fill_img then
			effect.transform:RotateAround(fill_img.transform.position, Vector3.back, angleDire)
		else
			effect.transform:RotateAround(Vector3.zero, Vector3.back,angleDire)

		end
	end, direction,countNum)
	timer:Start()
	return timer
end

-- 新手引导福卡动画
function MjAnimation.GuideRedAnim(hongbaoSpine, redNode, textCanvasGroup)
	local spine = hongbaoSpine:GetComponent("SkeletonAnimation")

	spine.AnimationName = "animation"

	hongbaoSpine.gameObject:SetActive(true)

	redNode.gameObject:SetActive(false)
	textCanvasGroup.alpha = 0.1
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:AppendInterval(1.2)
	seq:AppendCallback(function ()
		spine.AnimationName = "doudong"
		redNode.gameObject:SetActive(true)

	end)
	seq:Append(textCanvasGroup:DOFade(1, 1))
	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		spine.AnimationName = "doudong"
		redNode.gameObject:SetActive(true)
		textCanvasGroup.alpha = 1
	end)
end

function MjAnimation.CurRace(curRace,parent)
	local curRaceItem =GameObject.Instantiate(GetPrefab("ItemMjCurRace"),parent)
	local curRaceText = curRaceItem.transform:GetComponent("Text")
	curRaceText.text = "第" .. curRace .. "副"
	local tween1 = curRaceItem.transform:DOLocalMoveX(-1200,0.5):From()
	local tween2 = curRaceItem.transform:DOLocalMoveX(1200,0.5)
	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)
	seq:Append(tween1):AppendInterval(1):Append(tween2):OnKill(function ( )
		DOTweenManager.RemoveStopTween(tweenKey)
		GameObject.Destroy(curRaceItem.gameObject)	
	end)
end

--- 打漂上浮动画
function MjAnimation.DapiaoAnimation( texStr , posNode )
	local dapiaoIcon =GameObject.Instantiate(GetPrefab("MjDapiaoIcon") , posNode.transform.parent )
	local dapiaoImage = dapiaoIcon.transform:GetComponent("Image")

	dapiaoImage.sprite = GetTexture(texStr)

	local nowPos = Vector3.New( posNode.transform.localPosition.x , posNode.transform.localPosition.y , posNode.transform.localPosition.z )
	local targetPos = Vector3.New( nowPos.x , nowPos.y + 80, nowPos.z )
	dapiaoIcon.transform.localPosition = nowPos

	local acTime = 1.5
	local changeColor = dapiaoImage:DOColor( Color.New(1,1,1,0.2) , acTime )
	local moveUp = dapiaoIcon.transform:DOLocalMove( targetPos , acTime ):SetEase(DG.Tweening.Ease.OutSine)

	local seq = DG.Tweening.DOTween.Sequence()
	local tweenKey = DOTweenManager.AddTweenToStop(seq)

	seq:Append(moveUp)

	seq:OnKill(function ()
		DOTweenManager.RemoveStopTween(tweenKey)
		SafaSetTransformPeoperty(dapiaoIcon , "localPosition" , targetPos)
		GameObject.Destroy(dapiaoIcon)
	end)

end

