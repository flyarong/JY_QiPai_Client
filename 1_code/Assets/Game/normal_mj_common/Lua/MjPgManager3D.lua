--- 3D碰杠管理
local basefunc = require "Game.Common.basefunc"

MjPgManager3D = basefunc.class()
local C = MjPgManager3D

function C:ctor(players , model)
    self.currMj = {}
    self.currPlayer = 0
    self.players = players
    for i,v in ipairs(self.players) do
        v.PPObjList = {}
        v.PPPosObject = GameObject.Find( "majiang_fj/mjz_01/PengGangPaiPos" .. i )
    end

    ---- 每个碰杠牌的间隔
    self.pengGangSpace = 0.5

    self.model = model
end

--[[
pgList    
    data 
        type  -- peng ag zg wg
        pai
--]]
function C:Refresh(p,pgList)
	local player = self.players[p]
    self.currPlayer = p

    ---- 直接Clear一次
    self:Clear(p)

    if pgList then
    	for k,v in pairs(pgList) do
    		--- 没有就创建，有就重新创
    		self:createPengGangPaiProxy( p , v.type , v.pai , true )
    		self.currMj = player.PPObjList[#player.PPObjList + 1]

    	end
    end

end

function C:Clear(p)
	local player = self.players[p]
    self.currPlayer = p

    for k, v in pairs(player.PPObjList) do
    	if IsEquals(v) then
			v:OnDestroy()
		end
	end
	player.PPObjList = {}
end

----
--[[function C:AddPg(p , data)
	local player = self.players[p]
	self.currPlayer = p
	local idx = #player.PPObjList + 1


end--]]

--- 获得碰杠的个数
function C:getPengGangNum(p)
	local player = self.players[p]

	local vec = {}
	local num = 0
	for key,value in ipairs(player.PPObjList) do
		if not vec[key] then
			vec[key] = true
			num = num + 1
		end
	end

	return num
end

---- 设置碰杠牌的位置
function C:setPengGangPaiPos( p , paiVec , isDoEffect)
	local player = self.players[p]
	--- 找到起始位置
	local startPos = 0
	if #player.PPObjList > #paiVec then
		-- startPos = player.PPObjList[#player.PPObjList].transform.localPosition.x - MjCard3D.size.x - self.pengGangSpace

		----- 找x最小的
		for key,value in pairs(player.PPObjList) do
			if value.transform.localPosition.x < startPos then
				startPos = value.transform.localPosition.x
			end
		end

		startPos = startPos - MjCard3D.size.x - self.pengGangSpace
	end

	---- 创建一个烟雾粒子效果
	if isDoEffect and paiVec and type(paiVec) == "table" and #paiVec > 0 then
		local pgSmoke = GameObject.Instantiate( GetPrefab( "peng_1" ) , paiVec[math.ceil(#paiVec/2)].transform )
	end

	--- 设置位置
	for key,card in ipairs(paiVec) do
		local targetPos = Vector3.New( startPos - (key-1) * MjCard3D.size.x , 0,0 )
		
		if key == 4 then
			local targetPosIndex2 = Vector3.New( startPos - (2-1) * MjCard3D.size.x , 0,0 )
			targetPos = Vector3.New( targetPosIndex2.x , targetPosIndex2.y , targetPosIndex2.z + MjCard3D.size.z )
		end

		if isDoEffect then
			local penggangData = {}
			if #paiVec == 3 and key == 3 then
				penggangData.isPengLastCard = true
			end
			if #paiVec == 4 and key == 4 then
				penggangData.isGangLastCard = true
			end

			MjAnimation.PengGangAnimation( card , targetPos , penggangData )
		else
			card.transform.localPosition = targetPos
		end

		if key == 4 then
			local cPos = card.transform.localPosition
			card.transform.localPosition = targetPos
			self:DrawZhuanYuArrow(p, card.transform.position, card:GetCard())
			card.transform.localPosition = cPos
		end
	end

end

----- 创建碰牌还是杠牌的代理
function C:createPengGangPaiProxy( p , paiType , pai , isNotDoEffect )
	if paiType == self.model.PaiType.pp then
		self:create3DPengPai( p , paiType , pai , isNotDoEffect )
	elseif paiType == self.model.PaiType.zg then
		self:create3DZhiGang( p , paiType , pai , isNotDoEffect )
	elseif paiType == self.model.PaiType.ag then
		self:create3DAnGang( p , paiType , pai , isNotDoEffect )
	elseif paiType == self.model.PaiType.wg then
		self:create3DWanGang( p , paiType , pai , isNotDoEffect )
	end
end

----- 创建碰牌,根据数据创建3张牌
function C:create3DPengPai(p , paiType , pai , isNotDoEffect)
	local player = self.players[p]
	local paiVec = {}
	for i=1,3 do
		local mjCard3D = MjCard3D.Create( player.PPPosObject.transform , paiType , pai )
		player.PPObjList[#player.PPObjList + 1] = mjCard3D
		paiVec[#paiVec + 1] = mjCard3D
	end

	--- 设置位置
	self:setPengGangPaiPos( p, paiVec , not isNotDoEffect)

	--- 是否不做效果
	if not isNotDoEffect then
		player:PlayMusicEffect("peng")
		ExtendSoundManager.PlaySound(audio_config.mj.majiang_peng_peng.audio_name)
		MJParticleManager.MJPGH(p , paiType)
	end
end

----- 创建直杠牌，根据数据创4张
function C:create3DZhiGang(p , paiType , pai , isNotDoEffect)
	local player = self.players[p]

	local paiVec = {}
	for i=1,4 do
		local mjCard3D = MjCard3D.Create( player.PPPosObject.transform , paiType , pai )
		player.PPObjList[#player.PPObjList + 1] = mjCard3D
		paiVec[#paiVec + 1] = mjCard3D
	end

	--- 设置位置
	self:setPengGangPaiPos( p, paiVec , not isNotDoEffect)


	--- 是否不做效果
	if not isNotDoEffect then
		MJParticleManager.MJXY(self.model.GetSeatnoToPos(self.model.data.cur_chupai.p))
		player:PlayMusicEffect("gang")
		ExtendSoundManager.PlaySound(audio_config.mj.majiang_gang_gang.audio_name)
		MJParticleManager.MJPGH(p , paiType)
	end
end

----- 创建暗杠牌，根据数据创4张
function C:create3DAnGang(p , paiType , pai , isNotDoEffect)
	local player = self.players[p]

	local paiVec = {}
	for i=1,4 do
		local mjCard3D = MjCard3D.Create( player.PPPosObject.transform , paiType , pai )
		player.PPObjList[#player.PPObjList + 1] = mjCard3D
		paiVec[#paiVec + 1] = mjCard3D

		--- 第4张朝上
		if i==4 then
			mjCard3D:setRotationGangUpPai()
		end
	end

	--- 设置位置
	self:setPengGangPaiPos(p, paiVec , not isNotDoEffect)


	--- 是否不做效果
	if not isNotDoEffect then
		local cur_p = self.model.data.cur_p
        local mySeatno = self.model.GetRealPlayerSeat()  -- self.model.data.mySeatno
        print("<color=yellow>----------- 挂风: </color>",cur_p , mySeatno)
        if cur_p and mySeatno then
            if cur_p == mySeatno then
                MJParticleManager.MJLJF()
            else
                MJParticleManager.MJLJFOther(self.model.GetSeatnoToPos(cur_p))
            end
        end

		player:PlayMusicEffect("angang")
		ExtendSoundManager.PlaySound(audio_config.mj.majiang_gang_gang.audio_name)
		MJParticleManager.MJPGH(p , paiType)
	end
end

----- 创建弯杠牌，根据数据创4张
function C:create3DWanGang(p , paiType , pai , isNotDoEffect)
	local player = self.players[p]

	local paiVec = {}
	for i=1,4 do
		local mjCard3D = MjCard3D.Create( player.PPPosObject.transform , paiType , pai )
		player.PPObjList[#player.PPObjList + 1] = mjCard3D
		paiVec[#paiVec + 1] = mjCard3D
	end

	--- 设置位置
	self:setPengGangPaiPos(p, paiVec , not isNotDoEffect)

	--- 是否不做效果
	if not isNotDoEffect then
		local cur_p = self.model.data.cur_p
        local mySeatno = self.model.GetRealPlayerSeat() -- self.model.data.mySeatno
        print("<color=yellow>----------- 挂风: </color>",cur_p , mySeatno)
        if cur_p and mySeatno then
            if cur_p == mySeatno then
                MJParticleManager.MJLJF()
            else
                MJParticleManager.MJLJFOther(self.model.GetSeatnoToPos(cur_p))
            end
        end
        
		player:PlayMusicEffect("gang")
		ExtendSoundManager.PlaySound(audio_config.mj.majiang_gang_gang.audio_name)
		MJParticleManager.MJPGH(p , paiType)
	end
end

-------------------------------------------------------------------------------------------------------------------------------------
--[[
data 
   type  -- peng ag zg wgs
   pai
--]]
function C:AddPg(p,data)
    local player = self.players[p]
    self.currPlayer = p

    self:createPengGangPaiProxy( p , data.type , data.pai , false )

   
end


--改变弯杠
function C:ChangeWG(p, pai)
    local player = self.players[p]
    self.currPlayer = p

    local ppVec = {}
    for k,v in ipairs(player.PPObjList) do
    	
        if player.PPObjList[k].card == pai then
            ppVec[#ppVec + 1] = player.PPObjList[k]
        end
    end

    if ppVec and #ppVec == 3 then
    	local mjCard3D = MjCard3D.Create( player.PPPosObject.transform , self.model.PaiType.wg , pai )
    	player.PPObjList[#player.PPObjList + 1] = mjCard3D
    	self.currMj = mjCard3D

    	---- 设置位置
    	mjCard3D.transform.localPosition = Vector3.New( ppVec[2].transform.localPosition.x , ppVec[2].transform.localPosition.y , ppVec[2].transform.localPosition.z + MjCard3D.size.z )

    	local cur_p = self.model.data.cur_p
        local mySeatno = self.model.GetRealPlayerSeat() -- self.model.data.mySeatno
        print("<color=yellow>----------- 挂风: </color>",cur_p , mySeatno)
        if cur_p and mySeatno then
            if cur_p == mySeatno then
                MJParticleManager.MJLJF()
            else
                MJParticleManager.MJLJFOther(self.model.GetSeatnoToPos(cur_p))
            end
        end
		player:PlayMusicEffect("gang")
		ExtendSoundManager.PlaySound(audio_config.mj.majiang_gang_gang.audio_name)
    end

    --  MjAnimation.AniItemMjPGH(p, self.model.PaiType.wg)
     MJParticleManager.MJPGH(p,self.model.PaiType.wg)
end

----- 删掉尾部的牌
function C:DelTail()
	local player = self.players[self.currPlayer]
	if player then
        local idx = #player.PPObjList
        if player.PPObjList[idx] then
            --GameObject.Destroy(player.PPObjList[idx].gameObject)
            player.PPObjList[idx]:OnDestroy()
            table.remove(player.PPObjList, idx)
        end
    end
    
    if self.currMj and self.currMj.gameObject then
		GameObject.Destroy(self.currMj.gameObject)
	end
end

----- 
--改变碰为杠
function C:ChangePeng()
	local paiId
	if self.currMj and self.currMj.card then
		paiId = self.currMj.card
	end
    self:DelTail()
end

function C:ClearCards()
	if self.players and type(self.players) == "table" then
		for i,v in ipairs(self.players) do
			for _,card in pairs(v.PPObjList) do
				card:OnDestroy()
			end
	        v.PPObjList = {}
	        v.PPPosObject = GameObject.Find( "majiang_fj/mjz_01/PengGangPaiPos" .. i )
	    end
	end
end

--- 退出，清理
function C:MyExit()
	self:ClearCards()
	self:ClearZhuanYuArrows()
end

function C:AddZhuanYuPai(hPos, gPos, pai)
	if not self.zhuanyu then
		self.zhuanyu = {}
		for i = 1, 4 do
			self.zhuanyu[i] = {}
		end
	end

	self.zhuanyu[gPos][#self.zhuanyu[gPos] + 1] = {hPos = hPos, gPos = gPos, pai = pai}
end

function C:DrawZhuanYuArrow(uiPos, mjPos, pai)
	if not self.zy_arrows then
		self.zy_arrows = {}
	end

	if self.zhuanyu and self.zhuanyu[uiPos] then
		local scrPos = UnityEngine.Camera.main:WorldToScreenPoint(mjPos)
		for i, v in ipairs(self.zhuanyu[uiPos]) do
			if v.pai == pai then
				local canvas = GameObject.Find("Canvas")
				local arrow = newObject("ZhuanYuArrow", canvas.transform:Find("GUIRoot/MjXzGamePanel3D").transform)
				local scale = canvas.transform:GetComponent("RectTransform").localScale
				arrow.transform.position = (scrPos - Vector3.New(Screen.width/2, Screen.height/2, 0)) * scale.x
				self.zy_arrows[#self.zy_arrows + 1] = arrow.gameObject

				arrow.transform:Find("left").gameObject:SetActive(uiPos == v.hPos + 1 or uiPos == v.hPos - 3)
				arrow.transform:Find("right").gameObject:SetActive(uiPos == v.hPos - 1 or uiPos == v.hPos + 3)
				arrow.transform:Find("opp").gameObject:SetActive(uiPos == v.hPos + 2 or uiPos == v.hPos - 2)

				local rotDegree = 0
				if uiPos == 2 then
					rotDegree = #self.players == 2 and 180 or 90
				elseif uiPos == 3 then
					rotDegree = 180
				elseif uiPos == 4 then
					rotDegree = -90
				end

				if rotDegree ~= 0 then
					arrow.transform:RotateAround(arrow.transform.position, Vector3.forward, rotDegree)
					local zhuan = arrow.transform:Find("Image")
					zhuan:RotateAround(zhuan.position, Vector3.forward, -rotDegree)
				end
				break
			end
		end
	--[[elseif true then
		local scrPos = UnityEngine.Camera.main:WorldToScreenPoint(mjPos)
		local canvas = GameObject.Find("Canvas")
		local arrow = newObject("ZhuanYuArrow", canvas.transform:Find("GUIRoot/MjXzGamePanel3D").transform)
		local scale = canvas.transform:GetComponent("RectTransform").localScale
		arrow.transform.position = (scrPos - Vector3.New(Screen.width/2, Screen.height/2, 0)) * scale.x
		self.zy_arrows[#self.zy_arrows + 1] = arrow.gameObject

		arrow.transform:Find("left").gameObject:SetActive(uiPos == 2)
		arrow.transform:Find("right").gameObject:SetActive(uiPos == 4)
		arrow.transform:Find("opp").gameObject:SetActive(uiPos == 3)

		local rotDegree = 0
		if uiPos == 2 then
			rotDegree = #self.players == 2 and 180 or 90
		elseif uiPos == 3 then
			rotDegree = 180
		elseif uiPos == 4 then
			rotDegree = -90
		end

		if rotDegree ~= 0 then
			arrow.transform:RotateAround(arrow.transform.position, Vector3.forward, rotDegree)
			local zhuan = arrow.transform:Find("Image")
			zhuan:RotateAround(zhuan.position, Vector3.forward, -rotDegree)
		end]]
	end
end

function C:ClearZhuanYuArrows()
	log("<color=yellow>--->>>ClearZhuanYuArrows</color>")
	if self.zy_arrows then
		for i, o in ipairs(self.zy_arrows) do
			GameObject.Destroy(o)
		end
	end

	self.zy_arrows = nil
	self.zhuanyu = nil
end