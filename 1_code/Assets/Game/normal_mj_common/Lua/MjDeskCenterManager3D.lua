------ 桌子中间的管理器,
--- 包括庄家指示灯，倒计时，待摸牌...
---


local basefunc = require "Game.Common.basefunc"

MjDeskCenterManager3D = basefunc.class()
local C = MjDeskCenterManager3D

function C.Create()
    return C.New()
end

function C:ctor()
    self.jsq = GameObject.Find("majiang_fj/jsq")

    ---- 方位指示灯
    self.tagDong3D = GameObject.Find("majiang_fj/jsq/jsq_dong")
    self.tagNan3D = GameObject.Find("majiang_fj/jsq/jsq_nan")
    self.tagXi3D = GameObject.Find("majiang_fj/jsq/jsq_xi")
    self.tagBei3D = GameObject.Find("majiang_fj/jsq/jsq_bei")
    self.zhiShiDeng3D = {}
    self.zhiShiDeng3D[1] = self.tagDong3D
    self.zhiShiDeng3D[2] = self.tagNan3D
    self.zhiShiDeng3D[3] = self.tagXi3D
    self.zhiShiDeng3D[4] = self.tagBei3D

    self.zhiShiDeng3DBlinkTweenKey = {}
    self.zhiShiDeng3DBlinkTweenKey[1] = 0
    self.zhiShiDeng3DBlinkTweenKey[2] = 0
    self.zhiShiDeng3DBlinkTweenKey[3] = 0
    self.zhiShiDeng3DBlinkTweenKey[4] = 0

    self.zhiShiDengDarkColor = Color.New(0.6,0.6,0.6,1)
    -- 3D倒计时
    self.operTime3D = GameObject.Find("majiang_fj/jsq_shuzi")
    -- 3D待摸牌
    self.remaindCardVec = nil

    ---骰子
    self.shaizi1 = GameObject.Find("majiang_fj/shaiziParentNode/mj_shaizi1")
    self.shaizi2 = GameObject.Find("majiang_fj/shaiziParentNode/mj_shaizi2")
    self.shaiziParentNode = GameObject.Find("majiang_fj/shaiziParentNode")

    --self.shaizi = GameObject.Find("majiang_fj/shaizi_01_02")
    --self.shaiziAnimator = self.shaizi:GetComponent("Animator")

    --self.shaiziAnimator:SetActive(false)

    -- 待摸牌的4个位置
    self.remaindCardPosVec = {}
    self.remaindCardPosVec[1] = GameObject.Find("majiang_fj/mjz_02/remainCardPos1")
    self.remaindCardPosVec[2] = GameObject.Find("majiang_fj/mjz_02/remainCardPos2")
    self.remaindCardPosVec[3] = GameObject.Find("majiang_fj/mjz_02/remainCardPos3")
    self.remaindCardPosVec[4] = GameObject.Find("majiang_fj/mjz_02/remainCardPos4")

    --- 麻将类型的桌面ui
    self.mjTypeDeskUi = GameObject.Find("majiang_fj/mjz_01/tableCanvas/matchTypeImage")
    self.mjTypeDeskUi.gameObject:SetActive(false)
    --- 麻将底分的桌面ui
    self.mjBaseScoreDeskUi = GameObject.Find("majiang_fj/mjz_01/tableCanvas/matchScoreText")
    self.mjBaseScoreDeskUi.gameObject:SetActive(false)

    --- 麻将房号
    self.roomNumTextDeskUi = GameObject.Find("majiang_fj/mjz_01/tableCanvas/roomNumText")
    self.roomNumTextDeskUi.gameObject:SetActive(false)

    ---- 房卡场的局数
    self.raceNumTextDeskUi = GameObject.Find("majiang_fj/mjz_01/tableCanvas/raceNumText")
    self.raceNumTextDeskUi.gameObject:SetActive(false)

    --- card prefab
    self.cardPerfab = {}
    for i=1,3 do
        for j=1,9 do
            self.cardPerfab[i*10+j] = GetPrefab( string.format( "mj_%d" , i*10 + j ) )
        end
    end

    --- 投色子的动画时间
    self.touseziAcTime = 5

    --- 出牌口
    self.cardDoor = GameObject.Find("majiang_fj/mjz_02")
    
    print("<color=yellow>------------------------------ MjDeskCenterManager3D ctor ----------------------------- </color>")
    --- 发每四张牌的间隔时间
    --self.faPaiDelayTime = 0.3

end

--- 设置麻将类型ui
function C:setMjTypeDeskUi(imgName)  
    self.mjTypeDeskUi.gameObject:SetActive(true)
    self.mjTypeDeskUi:GetComponent("Image").sprite = GetTexture(imgName)
end

---- 设置底分
function C:setBaseScore(score)
    self.mjBaseScoreDeskUi.gameObject:SetActive(true)
    self.mjBaseScoreDeskUi:GetComponent("Text").text = "底分："..  score
end

--- 设置房号
function C:setRoomNum(roomNum)
    self.roomNumTextDeskUi.gameObject:SetActive(true)
    self.roomNumTextDeskUi:GetComponent("Text").text = "房号："..  roomNum
end

--- 设置房号
function C:setRaceNum(raceNum , totalNum)
    self.raceNumTextDeskUi.gameObject:SetActive(true)
    self.raceNumTextDeskUi:GetComponent("Text").text = "第 "..  raceNum .. "/" .. totalNum .. " 局"
end


---- 设置庄家方位
function C:setZhuangjiaZhishideng( zhuangjiaUiPos )
    if zhuangjiaUiPos == 1 then
        self.zhiShiDeng3D[1] = self.tagDong3D
        self.zhiShiDeng3D[2] = self.tagNan3D
        self.zhiShiDeng3D[3] = self.tagXi3D
        self.zhiShiDeng3D[4] = self.tagBei3D

        self.jsq.transform.localEulerAngles = Vector3.New(0,-90,0)
    elseif zhuangjiaUiPos == 2 then
        self.zhiShiDeng3D[1] = self.tagBei3D 
        self.zhiShiDeng3D[2] = self.tagDong3D 
        self.zhiShiDeng3D[3] = self.tagNan3D 
        self.zhiShiDeng3D[4] = self.tagXi3D

        self.jsq.transform.localEulerAngles = Vector3.New(0,-180,0)
    elseif zhuangjiaUiPos == 3 then
        self.zhiShiDeng3D[1] = self.tagXi3D 
        self.zhiShiDeng3D[2] = self.tagBei3D   
        self.zhiShiDeng3D[3] = self.tagDong3D 
        self.zhiShiDeng3D[4] = self.tagNan3D 

        self.jsq.transform.localEulerAngles = Vector3.New(0,90,0)
    elseif zhuangjiaUiPos == 4 then
        self.zhiShiDeng3D[1] = self.tagNan3D  
        self.zhiShiDeng3D[2] = self.tagXi3D    
        self.zhiShiDeng3D[3] = self.tagBei3D 
        self.zhiShiDeng3D[4] = self.tagDong3D

        self.jsq.transform.localEulerAngles = Vector3.New(0,0,0)
    end

end

---- 刷新庄家的指示灯并旋转
function C:refreshZhuangjiaZhishideng( Model )

    --[[if MjXzModel.data.cur_race == 1 or not MjXzModel.data.cur_race then
        self:setZhuangjiaZhishideng( MjXzModel.GetSeatnoToPos(MjXzModel.data.zjSeatno) )
    end--]]

    --if Model.data.cur_race == 1 or not Model.data.cur_race then
        self:setZhuangjiaZhishideng( Model.GetSeatnoToPos(Model.data.zjSeatno) )
    --end
end

---- 刷新庄家的指示灯并旋转,二人麻将使用
function C:refreshZhuangjiaZhishideng_erRen( Model )

    --[[if MjXzModel.data.cur_race == 1 or not MjXzModel.data.cur_race then
        self:setZhuangjiaZhishideng( MjXzModel.GetSeatnoToPos(MjXzModel.data.zjSeatno) )
    end--]]

    --if Model.data.cur_race == 1 or not Model.data.cur_race then
        self:setZhuangjiaZhishideng( Model.GetSeatnoToPos(Model.data.zjSeatno) )
    --end
end

---- 骰子动画 ( 废掉了，没用 )
function C:shaiziAnimation()
    --print("<color=yellow> player shaiziAnimation </color>")
    self.operTime3D:SetActive(false)
    --self.shaiziAnimator:SetActive(true)
    self.shaizi1.transform.localRotation = Vector3.New(-90,90,0)

    self.shaiziAnimator:SetBool("isTakeShaizi" , true)
    local closeTimer = Timer.New( function() 
        self.shaiziAnimator:SetBool("isTakeShaizi" , false)
    end , 0.02 , 1 )
    closeTimer:Start()
    
    local time = 4 -- self.shaiziAnimator:GetCurrentAnimatorClipInfo(0).clip.length
    local delayTimer = Timer.New( function() 
        --self.shaiziAnimator:SetActive(false)
        self.operTime3D:SetActive(true)
    end , time , 1 )
    delayTimer:Start()

    ----

end

------ 测试骰子动画
function C:testShaiziAnimation( Model , passTime )
    if not Model or not Model.data or not Model.data.sezi_value1 or not Model.data.sezi_value2 then
        return
    end

    self.operTime3D:SetActive(false)

    local passTimeTem = passTime or 0
    local dtTime = 0.016
    local time = 0
    local rotateSpeed = 0
    local upSpeedAcc = 60
    local downSpeedTime = 1.2
    local targetMaxRotateSpeed = 70    --- 最大的值可能不是这个值
    local maxRotateSpeed = targetMaxRotateSpeed > upSpeedAcc * downSpeedTime and upSpeedAcc * downSpeedTime or targetMaxRotateSpeed
    local downSpeedAcc = 40
    local totalTime = downSpeedTime + maxRotateSpeed / downSpeedAcc - passTimeTem

    local deal = function() 
        local dtTimeTem = Time.deltaTime

        time = time + dtTimeTem
        if time < downSpeedTime then
            if rotateSpeed < maxRotateSpeed then
                rotateSpeed = rotateSpeed + upSpeedAcc*dtTimeTem
            else
                rotateSpeed = maxRotateSpeed
            end
        else
            if rotateSpeed > 0 then
                rotateSpeed = rotateSpeed - downSpeedAcc*dtTimeTem
            else
                rotateSpeed = 0
            end
        end
        local parentNodeRotation = self.shaiziParentNode.transform.localEulerAngles
        parentNodeRotation.y = parentNodeRotation.y + rotateSpeed
        --print("<color=yellow>testShaiziAnimation --- update rotateSpeed: </color>",rotateSpeed)
        --print(string.format("<color>testShaiziAnimation --- update parentNodeRotation:%d,%d,%d, </color>",parentNodeRotation.x,parentNodeRotation.y,parentNodeRotation.z))
        self.shaiziParentNode.transform.localEulerAngles = Vector3.New(parentNodeRotation.x,parentNodeRotation.y,parentNodeRotation.z)
    end

    local timeTem = 0 
    while timeTem < passTimeTem do
        timeTem = timeTem + Time.deltaTime
        deal()
    end

    self.updateTimer = Timer.New( function() 
        deal()
    end , dtTime , -1 )
    self.updateTimer:Start()


    local shaiziRotationVec = {
        [1] = Vector3.New(90,0,0),
        [2] = Vector3.New(180,0,0),
        [3] = Vector3.New(180,0,90),
        [4] = Vector3.New(-90,0,0),
        [5] = Vector3.New(0,0,90),
        [6] = Vector3.New(0,0,0),
    }

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey1 = DOTweenManager.AddTweenToStop(seq)
    local seq2 = DG.Tweening.DOTween.Sequence()
    local tweenKey2 = DOTweenManager.AddTweenToStop(seq2)
    local rotateNum = 5
    local shaizitime = totalTime - 0.2
    for i=1,rotateNum do
        local index1 = 1
        local index2 = 1
        if i~=rotateNum then
            index1 = math.random(1,#shaiziRotationVec)
            index2 = math.random(1,#shaiziRotationVec)
        else
            index1 = Model.data.sezi_value1
            index2 = Model.data.sezi_value2
        end

        local rotateTo = self.shaizi1.transform:DOLocalRotate( shaiziRotationVec[ index1 ] , shaizitime / rotateNum )
        local rotateTo2 = self.shaizi2.transform:DOLocalRotate( shaiziRotationVec[ index2 ] , shaizitime / rotateNum )
        seq:Append(rotateTo)
        seq2:Append(rotateTo2)
    end
    seq:OnKill(function ()
        SafaSetTransformPeoperty(self.shaizi1 , "localEulerAngles" , shaiziRotationVec[ Model.data and Model.data.sezi_value1 or 1 ] )

        DOTweenManager.RemoveStopTween(tweenKey1)
    end)
    seq2:OnKill(function ()
        SafaSetTransformPeoperty(self.shaizi2 , "localEulerAngles" , shaiziRotationVec[ Model.data and Model.data.sezi_value2 or 1 ] )

        DOTweenManager.RemoveStopTween(tweenKey2)
    end)



    local closeTime = self.touseziAcTime - time + 2
    self.closeTimer = Timer.New( function() 
        self.operTime3D:SetActive(true)
        if self.updateTimer then
            self.updateTimer:Stop()
            self.updateTimer = nil
        end
        self.closeTimer = nil
    end , closeTime , 1 )
    self.closeTimer:Start()

end


----- 出牌口动画
function C:cardDoorAnimation(Model)
    self:createAllRemainCard(Model) 
    self:showOrHideAllReaminCard(false)
    --print("<color=yellow> deskCenterMgr do cardDoorAnimation  </color>")
    MjAnimation.CardDoorDownAndUp( self.cardDoor , function() 
        self:showOrHideAllReaminCard(true)
    end )
end

----- 出牌口动画
function C:cardDoorAnimation_erRen(Model)
    self:createAllRemainCard_erRen(Model) 
    self:showOrHideAllReaminCard(false)
    --print("<color=yellow> deskCenterMgr do cardDoorAnimation  </color>")
    MjAnimation.CardDoorDownAndUp( self.cardDoor , function() 
        self:showOrHideAllReaminCard(true)
    end )
end

---- 某个指示灯显示or隐藏
function C:showOrHideOneZhishideng(pos , status)
    if pos > 0 and pos < 5 then
        if status then
            self.zhiShiDeng3D[pos]:GetComponent("MeshRenderer").material.mainTexture = Get3DTexture( "tex_jsq_on" ) 
            -- 播放动画
            self.zhiShiDeng3DBlinkTweenKey[pos] = MjAnimation.BlinkZhiShiDeng( self.zhiShiDeng3D[pos] , self.zhiShiDengDarkColor , self.zhiShiDeng3DBlinkTweenKey[pos] )
        else
            self.zhiShiDeng3D[pos]:GetComponent("MeshRenderer").material.mainTexture = Get3DTexture( "tex_jsq_off" ) 
            -- 还原颜色并杀掉动画
            self.zhiShiDeng3D[pos]:GetComponent("MeshRenderer").material.color = self.zhiShiDengDarkColor
            local oldTween = DOTweenManager.GetKeyToTween (self.zhiShiDeng3DBlinkTweenKey[pos])
            if oldTween then
                oldTween:Kill()
            end
            self.zhiShiDeng3DBlinkTweenKey[pos] = 0
        end
    end
end

---- 设置中间的3D倒计时
function C:set3DOperTimeTexOffset( timeNum )
    local nowOperTimeTexOffset = self:get3DOperTimeTextureOffset( timeNum )
    self.operTime3D:GetComponent("MeshRenderer").material.mainTextureOffset = nowOperTimeTexOffset
end

---- 重新显示所有的待摸牌
function C:showOrHideAllReaminCard(boolvalue)
    if self.remaindCardVec and type(self.remaindCardVec) == "table" then
        for _,cardTable in ipairs(self.remaindCardVec) do
            for key,card in ipairs(cardTable) do
                card.gameObject:SetActive(boolvalue)
            end
        end
    end
end

---- 创建出所有的待摸牌
function C:createAllRemainCard(Model)
    if not self.remaindCardVec then
        self.remaindCardVec = {}
        -- 创建
        for i=1,4 do
            self.remaindCardVec[Model.GetPosToSeatno(i)] = {}
            
            for j=1, (i-1)%2 * 2 + 13 * 2 do  -- 有两个方向是26张，两个方向是28张
                local remaindCardPos = self.remaindCardPosVec[ Model.GetPosToSeatno(i) ].transform
                local card = GameObject.Instantiate( self.cardPerfab[11] , remaindCardPos )
                card.gameObject:GetComponent("MeshRenderer").material = GetMaterial("mj_02")
                local cardTran = card.transform

                if i == 2 then
                    card.transform.gameObject.layer = LayerMask.NameToLayer("rightCard")
                elseif i == 4 then
                    card.transform.gameObject.layer = LayerMask.NameToLayer("leftCard")
                end

                cardTran.localEulerAngles = Vector3.New(90,0,0)
                cardTran.localPosition = Vector3.New( math.floor((j-1) / 2) * - MjCard3D.size.x , 0 , MjCard3D.size.z - (j-1)%2 )
                cardTran.localScale = Vector3.New( MjCard3D.sizeScale / remaindCardPos.localScale.x , MjCard3D.sizeScale / remaindCardPos.localScale.y , MjCard3D.sizeScale / remaindCardPos.localScale.z )

                self.remaindCardVec[Model.GetPosToSeatno(i)][j] = card
                card.gameObject:SetActive(false)
            end
        end
    end
end

----刷新待摸牌
function C:refreshRemainCard( Model , isDoEffect )
    self:createAllRemainCard(Model)
    -- self:showOrHideAllReaminCard(false)
    local sezi_value1 = Model.data.sezi_value1
    local sezi_value2 = Model.data.sezi_value2
    local zjSeatno = Model.data.zjSeatno
    if not sezi_value1 or not sezi_value2 or not zjSeatno then
        print("<color=yellow>---------------------------- showOrHideAllReaminCard false !!!! </color>")
        self:showOrHideAllReaminCard(false)
        return
    end
    --- 先找到从哪里开始摸的
    local remainCardNum = Model.data.remain_card
    
    local totalSeziValue = sezi_value1 + sezi_value2
    local minSeziValue = math.min(sezi_value1 , sezi_value2)
    -- 获得开始摸牌的座位虚号
    local startGetCardSeatNo = ( (zjSeatno - 1) + totalSeziValue - 1) % 4 + 1
    local startGetCardSeatVirtualNo = Model.GetSeatnoToPos(startGetCardSeatNo) 
    -- 开始根据剩余的牌来隐藏
    local nowGetCardNum = 0
    ---- 这里要作5次循环
    for i=1,5 do
        local realIndex = startGetCardSeatVirtualNo - (i-1)
        if realIndex <= 0 then
            realIndex = realIndex + 4
        end

        --- 第一次开始的点是拿牌处，其余的都是1开始
        local startDirIndex = (i == 1) and (minSeziValue * 2+1) or 1
        self.remaindCardVec[realIndex] = self.remaindCardVec[realIndex] or {}
        for j=startDirIndex , #self.remaindCardVec[realIndex] do
            local card = self.remaindCardVec[realIndex][j]
            nowGetCardNum = nowGetCardNum + 1
            if nowGetCardNum > 108 then
                break
            end
            if nowGetCardNum <= 108 - remainCardNum then
                if isDoEffect then
                    ---- 发牌的时候延迟效果
                    MjAnimation.DelayTimeAction(function() 
                        if IsEquals(card) and IsEquals(card.gameObject) then
                            card.gameObject:SetActive(false)
                        end
                    end , Model.data.faPaiDelayTime * math.floor((nowGetCardNum - 1)/4))

                else
                    card.gameObject:SetActive(false)
                end

            else
                card.gameObject:SetActive(true)
            end

        end
    end
end

------------
---- 创建出所有的待摸牌，给二人麻将用的
function C:createAllRemainCard_erRen()
    if not self.remaindCardVec then
        self.remaindCardVec = {}
        local scale = 0.8
        -- 创建
        for i=1,2 do
            self.remaindCardVec[i] = {}
            
            for j=1, 36 do  -- 有两个方向是26张，两个方向是28张
                local remaindCardPosVec = self.remaindCardPosVec[i==1 and 2 or 4]
                local card = GameObject.Instantiate( self.cardPerfab[11] , remaindCardPosVec.transform )
                card.gameObject:GetComponent("MeshRenderer").material = GetMaterial("mj_02")
                local cardTran = card.transform

                if i == 1 then
                    card.transform.gameObject.layer = LayerMask.NameToLayer("rightCard")
                elseif i == 2 then
                    card.transform.gameObject.layer = LayerMask.NameToLayer("leftCard")
                end

                cardTran.localEulerAngles = Vector3.New(90,0,0)
                cardTran.localPosition = Vector3.New( math.floor((j-1) / 2) * - scale*MjCard3D.origSize.x , 0 , scale*MjCard3D.origSize.z - (j-1)%2 )
                cardTran.localScale = Vector3.New( scale / remaindCardPosVec.transform.localScale.x , scale / remaindCardPosVec.transform.localScale.y , scale / remaindCardPosVec.transform.localScale.z )

                self.remaindCardVec[i][j] = card
                card.gameObject:SetActive(false)
            end
        end
    end
end

----刷新待摸牌，给二人麻将用的
function C:refreshRemainCard_erRen( Model , isDoEffect )
    print("<color=yellow>------------------- refreshRemainCard_erRen:</color>")
    self:createAllRemainCard_erRen()
    -- self:showOrHideAllReaminCard(false)
    local sezi_value1 = Model.data.sezi_value1
    local sezi_value2 = Model.data.sezi_value2
    local zjSeatno = Model.data.zjSeatno
    if not sezi_value1 or not sezi_value2 or not zjSeatno then
        print("<color=yellow>---------------------------- showOrHideAllReaminCard false !!!! </color>")
        self:showOrHideAllReaminCard(false)
        return
    end
    --- 先找到从哪里开始摸的
    local remainCardNum = Model.data.remain_card
    
    local totalSeziValue = sezi_value1 + sezi_value2
    local minSeziValue = math.min(sezi_value1 , sezi_value2)
    -- 获得开始摸牌的座位虚号
    --local startGetCardSeatNo = ( (zjSeatno - 1) + totalSeziValue - 1) % 4 + 1
    local startGetCardSeatVirtualNo = totalSeziValue % 2 == 0 and 1 or 2  --Model.GetSeatnoToPos(startGetCardSeatNo) 

    if zjSeatno == Model.data.seat_num then
        startGetCardSeatVirtualNo = totalSeziValue % 2 == 0 and 1 or 2
    else
        startGetCardSeatVirtualNo = totalSeziValue % 2 == 0 and 2 or 1
    end

    -- 开始根据剩余的牌来隐藏
    local nowGetCardNum = 0
    ---- 这里要作3次循环
    local maxPlayerNum = 2
    for i=1,maxPlayerNum+1 do
        local realIndex = startGetCardSeatVirtualNo - (i-1)
        if realIndex <= 0 then
            realIndex = realIndex + maxPlayerNum
        end
        --- 第一次开始的点是拿牌处，其余的都是1开始
        local startDirIndex = (i == 1) and (minSeziValue * 2+1) or 1
        for j=startDirIndex , #self.remaindCardVec[realIndex] do
            local card = self.remaindCardVec[realIndex][j]
            nowGetCardNum = nowGetCardNum + 1
            if nowGetCardNum > 72 then
                break
            end
            if nowGetCardNum <= 72 - remainCardNum then
                if isDoEffect then
                    ---- 发牌的时候延迟效果
                    MjAnimation.DelayTimeAction(function() 
                        if IsEquals(card) and IsEquals(card.gameObject) then
                            card.gameObject:SetActive(false)
                        end
                    end , Model.data.faPaiDelayTime * math.floor((nowGetCardNum - 1)/maxPlayerNum))

                else
                    card.gameObject:SetActive(false)
                end

            else
                card.gameObject:SetActive(true)
            end

        end
    end
end


----- 获得中间3D倒计时的纹理偏移值,timeNum 0~15
function C:get3DOperTimeTextureOffset( timeNum )
    return Vector2.New( (timeNum % 4) * 0.25 , math.floor(timeNum / 4) * -0.25 )
end


---- 退出，清理
function C:MyExit()
    if self.updateTimer then
        self.updateTimer:Stop()
        self.updateTimer = nil
    end

    if self.closeTimer then
        self.closeTimer:Stop()
        self.closeTimer = nil
    end

    if self.remaindCardVec and type(self.remaindCardVec) == "table" then
        for k,cardVec in pairs(self.remaindCardVec) do
            for _,card in pairs(cardVec) do
                GameObject.Destroy( card )
            end
        end
        self.remaindCardVec = nil
    end
    self.cardPerfab = {}

    self:set3DOperTimeTexOffset( 0 )
end

function C:SetGameName(order)
    local gameName = GameObject.Find("majiang_fj/mjz_01/tableCanvas/gameName")
    --gameName:GetComponent("Text").text = name
    local roomName = {
        "mj_game_imgf_xsc",
        "mj_game_imgf_sxc",
        "mj_game_imgf_sixc",
        "mj_game_imgf_wxc"
    }

    if order and order > 0 and order <= #roomName then
        local img = gameName:GetComponent("Image")
        img.sprite = GetTexture(roomName[order])
        img:SetNativeSize()
        gameName:SetActive(true)
    end
end
