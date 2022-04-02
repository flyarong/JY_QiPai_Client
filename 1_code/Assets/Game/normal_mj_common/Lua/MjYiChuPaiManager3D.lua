---- 3D 已出牌的管理器
local basefunc = require "Game.Common.basefunc"

MjYiChuPaiManager3D = basefunc.class()
local C = MjYiChuPaiManager3D



---- 3D麻将的宽度

--- 创建
function C:ctor( players , model )
	--- 当前已打麻将的位置的标志
	self.currMjHint = GameObject.Find( "majiang_fj/mjz_01/mj_triangle" )
	self.currMjHintTweenKey = 0
	--- 当前出牌的玩家
	self.currPlayer = 0

	self.players = players

	--- 单排最多个数
	self.MAX_LINE = 6

	self.lastChuPaiHint = nil

	for i,v in ipairs(self.players) do
		v.CPObjList = {}
		v.CPPosObj = GameObject.Find( "majiang_fj/mjz_01/chuPaiPos" .. i )
		v.CPPosObjOriPos = v.CPPosObj.transform.localPosition
		v.CPNode = v.transform:Find("CPNode")
	end

	self.model = model
end

--- p玩家座位号， pai 需要刷新的牌
function C:Refresh(p,pai,curPai)
	print("<color=yellow>----------------- MjYiChuPaiManager3D , p ,</color>",p )
	dump(pai , "<color=yellow>----------------- MjYiChuPaiManager3D , p ,</color>" )
	local player = self.players[p]
	local paiType = self.model.PaiType.cp

	--- 来就隐藏
	--self:restoreMjHint()

	if pai then
		for k,v in pairs(pai) do
			--- 没有就创建，有就重新创
			if player.CPObjList[k] == nil then
				player.CPObjList[k] = MjCard3D.Create( player.CPPosObj.transform , paiType, v)
			elseif player.CPObjList[k].card ~= v then
				player.CPObjList[k]:OnDestroy()
				player.CPObjList[k] = MjCard3D.Create( player.CPPosObj.transform , paiType, v)
			end

			--- 设置位置
			self:setChuPaiPos( player.CPObjList[k] , k )
		end
		--- 删掉多余的
		for idx = #pai + 1, #player.CPObjList, 1 do
			player.CPObjList[idx]:OnDestroy()
			player.CPObjList[idx] = nil
		end

		for i=1 , player.CPNode.transform.childCount do
			local obj = player.CPNode.transform:GetChild(i-1).gameObject
			if obj.activeInHierarchy then
				GameObject.Destroy( obj )
			end
		end

	else
		for k, v in pairs(player.CPObjList) do
			v:OnDestroy()
		end
		player.CPObjList = {}
		
	end
	

	--[[if #player.CPObjList == 0 then
		---- 指针位置式隐藏
		self:restoreMjHint()
	else
		local curMjObj = player.CPObjList[#player.CPObjList]
		local globalPos = curMjObj.transform.position
		self.currMjHintTweenKey = MjAnimation.nowChuPaiUpDownAni( self.currMjHint , globalPos , self.currMjHintTweenKey )
	end--]]

	if self.lastChuPaiHint then
		GameObject.Destroy(self.lastChuPaiHint.gameObject) 
		self.lastChuPaiHint = nil
	end


	if curPai then
		self:RefreshCurrPai(curPai)
	end

	if #player.CPObjList == 0 then
		---- 指针位置式隐藏
		self:restoreMjHint()
	end
	
end

function C:addChuPaiPosOffsetX(offset)
	for i,v in ipairs(self.players) do
		local oldPos = v.CPPosObjOriPos

		if i==1 then
			v.CPPosObj.transform.localPosition = Vector3.New( oldPos.x + offset , oldPos.y , oldPos.z )
		elseif i==2 then
			v.CPPosObj.transform.localPosition = Vector3.New( oldPos.x , oldPos.y - offset, oldPos.z )
		elseif i==3 then
			v.CPPosObj.transform.localPosition = Vector3.New( oldPos.x - offset , oldPos.y , oldPos.z )
		elseif i==4 then
			v.CPPosObj.transform.localPosition = Vector3.New( oldPos.x , oldPos.y , oldPos.z + offset )
		end

		
	end
end


function C:setMaxLine(maxLine)	
	self.MAX_LINE = maxLine
end

function C:getChuPaiPos(index)
	return Vector3.New( ((index-1) % self.MAX_LINE) * MjCard3D.size.x , math.floor((index-1) / self.MAX_LINE) * MjCard3D.size.y , 0 )
end

---- 根据索引位置来设置 出牌3D麻将的位置
function C:setChuPaiPos( mjNode , index )
	mjNode.transform.localPosition = self:getChuPaiPos(index)
end

---- 加一张牌到出牌区
function C:AddChupai(p,pai,isNObiaoxian , aniStartPos )
	local player = self.players[p]
	local idx = #player.CPObjList + 1

	--- 音效
	if not isNObiaoxian then
		ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_outcard.audio_name)
	end
	if not isNObiaoxian then
		player:PlayMusicEffect(pai)
	end
	-- 创建一张3D牌
	local curMjObj = MjCard3D.Create( player.CPPosObj.transform , self.model.PaiType.cp, pai) 
	player.CPObjList[idx] = curMjObj



	----- ui上的出牌标识
	local cpPaiObj = MjCard.Create(player.CPNode, self.model.PaiType.cp, pai)
	--MjAnimation.ChuPai(cpPaiObj)
	
	if self.lastChuPaiHint then
		GameObject.Destroy(self.lastChuPaiHint.gameObject) 
		self.lastChuPaiHint = nil
	end

	self.lastChuPaiHint = cpPaiObj

	self.currPlayer = p

	self:setChuPaiPos( curMjObj , idx )
	local globalPos = curMjObj.transform.position

	--- 设置位置
	if not isNObiaoxian then
		if player.uiPos == self.model.GetPlayerUIPos() then
			MjAnimation.ChuPai3D( curMjObj , self:getChuPaiPos(idx) , aniStartPos , true )
		else
			MjAnimation.ChuPai3D( curMjObj , self:getChuPaiPos(idx) , aniStartPos , false )
		end
		
	else
		self:setChuPaiPos( curMjObj , idx )
	end
	--- 3D麻将指针
	self.currMjHintTweenKey = MjAnimation.nowChuPaiUpDownAni( self.currMjHint , globalPos , self.currMjHintTweenKey )
	
end

----删除已出牌的尾部的牌
function C:DelTail()
	local player = self.players[self.currPlayer]
	if player then
		local idx = #player.CPObjList
		if player.CPObjList[idx] then
			--GameObject.Destroy(player.CPObjList[idx].gameObject)
			player.CPObjList[idx]:OnDestroy()

			table.remove(player.CPObjList, idx)
		end
	end
	---- 指针位置式隐藏
	self:restoreMjHint()

end

---- 指针位置还原
function C:restoreMjHint()
	if self.currMjHint then
		DOTweenManager.KillAndRemoveTween( self.currMjHintTweenKey )
		
		-- self.currMjHint.transform.localPosition = Vector3.New(0,0,0)
		self.currMjHint.transform.position = Vector3.New(0,-10,0)


	end
end

------ 刷新最新出的牌
function C:RefreshCurrPai(data)
	--print("<color=yellow>----------------- MjYiChuPaiManager3D , RefreshCurrPai 1 </color>")
	if data == nil or data.p == nil or data.p == 0 then
		--print("<color=yellow>----------------- MjYiChuPaiManager3D , RefreshCurrPai 2 </color>")
		return
	end
	local UIP = self.model.GetSeatnoToPos(data.p)
	local player = self.players[UIP]
	---- 指标先还原
	if self.currMjHint then
		self.currMjHint.transform.localPosition = Vector3.New(0,0,0)
	end

	if player then
		local idx = #player.CPObjList
		local curMjObj = player.CPObjList[idx]
		if IsEquals(curMjObj) then
			if curMjObj.card == data.pai then
				-- self.currMjHint = MjAnimation.CurrMjHint(curMjObj.transform,UIP)
				--=print("<color=yellow>----------------- MjYiChuPaiManager3D , RefreshCurrPai 3 </color>",data.p , data.pai)
				---- 指标指到对应的出牌上面&做上下动作
				MjAnimation.DelayTimeAction( function() 
					if IsEquals(curMjObj) and IsEquals(curMjObj.transform) then
						self.currMjHintTweenKey = MjAnimation.nowChuPaiUpDownAni( self.currMjHint , curMjObj.transform.position , self.currMjHintTweenKey )
					end
				end , 0.05 )
				
				--print( "<color=red> --------------------- self.currMjHintTweenKey " .. self.currMjHintTweenKey .. " </color>" )
			else
				self:AddChupai(UIP,data.pai, true)
			end
		else
			self:AddChupai(UIP,data.pai, true)
		end


		---- 显示标志
		local cpPaiObj = MjCard.Create(player.CPNode, self.model.PaiType.cp, data.pai)
		self.lastChuPaiHint = cpPaiObj
	
	end

end

function C:ClearCards()
	if self.players and type(self.players) == "table" then
		for i,v in pairs(self.players) do
			for _,card in pairs(v.CPObjList) do
				card:OnDestroy()
			end
			v.CPObjList = {}
		end
	end
	if self.lastChuPaiHint then
		GameObject.Destroy(self.lastChuPaiHint.gameObject) 
		self.lastChuPaiHint = nil
	end
	
	self:restoreMjHint()
end

---- 退出，清理
function C:MyExit()
	self:ClearCards()
end


