-- 创建时间:2018-06-11

local basefunc = require "Game.Common.basefunc"

MjCard = basefunc.class()

--[[
	parent_transform 父亲节点
	cardType = "cp" 出牌; "pp" 碰; zg 直杠,ag 暗杠,wg 弯杠; "hu" 胡; "sp" 手牌 ,zp 抓牌
	card 牌的id
--]]
MjCard.PaiType =
{
    sp = "sp", -- 手牌
    cp = "cp", -- 出牌
    pp = "peng", -- 碰牌
    hp = "hp", -- 胡牌
    ag = "ag", -- 暗杠
    zg = "zg", -- 直杠
    wg = "wg", -- 弯杠
    zp = "zp", -- 抓牌
}
function MjCard.Create(parent_transform, cardType, card, callbackClick)
	return MjCard.New(parent_transform, cardType, card, callbackClick)
end

function MjCard:ctor(parent_transform, cardType, card, callbackClick,posStatus)
	self.parent_transform = parent_transform
	self.cardType = cardType
	self.card = card
	self.color = color
	self.callbackClick = callbackClick
	self.posStatus=posStatus or 0


	local childName = "MjCard"
	if cardType == MjCard.PaiType.zg or cardType == MjCard.PaiType.wg then
		childName = "MjMGCard"
	elseif cardType == MjCard.PaiType.ag then
		childName = "MjAGCard"
	elseif cardType == MjCard.PaiType.pp then
		childName = "MjPPCard"
	end

	local objTmpl = parent_transform.transform:Find(childName)
	if objTmpl == nil then
		print(string.format("[MJ] Create Card(%d) failed: cardType(%s) can't find node(%s) parentName(%s)", card, cardType, childName, parent_transform.name))
	end

	local obj =GameObject.Instantiate(parent_transform.transform:Find(childName).gameObject, parent_transform)
	self.transform = obj.transform
	self.gameObject = obj
	obj.name = card
	if cardType == MjCard.PaiType.zg or cardType == MjCard.PaiType.wg then
		for i=1,4 do
			local mj_img = obj.transform:Find("MjCard".. i .."/@mj_bg_img/@mj_img"):GetComponent("Image")
			if card ~= 1 then
				mj_img.sprite = GetTexture("majiang_"..card)
			end
		end
	elseif cardType == MjCard.PaiType.ag then
		local mj_img = obj.transform:Find("MjCard".. 4 .."/@mj_bg_img/@mj_img"):GetComponent("Image")
		if card ~= 1 then
			mj_img.sprite = GetTexture("majiang_"..card)
		end
	elseif cardType == MjCard.PaiType.pp then
		for i=1,3 do
			local mj_img = obj.transform:Find("MjCard".. i .."/@mj_bg_img/@mj_img"):GetComponent("Image")
			if card ~= 1 then
				mj_img.sprite = GetTexture("majiang_"..card)
			end
		end
	else
		LuaHelper.GeneratingVar(obj.transform, self)
		EventTriggerListener.Get(self.mj_bg_img.gameObject).onDown =basefunc.handler(self,self.OnDown)
		if card ~= 1 then
			self.mj_img.sprite = GetTexture("majiang_"..card)
		end
	end
	self.gameObject:SetActive(true)
	return self
end
function MjCard:OnDown()
	if self.callbackClick then
		self.callbackClick(self)
	end
end
function MjCard:OnDestroy()
	GameObject.Destroy(self.gameObject)
end

function MjCard:SetMark(b)
	if b==true then
		b=Color.gray
	end
	local cardType=self.cardType
	if cardType == MjCard.PaiType.zg or cardType == MjCard.PaiType.wg or cardType == MjCard.PaiType.ag or cardType == MjCard.PaiType.pp then
		local len=4
		if cardType == MjCard.PaiType.pp then
			len=3
		end 
		local obj=self.gameObject
		for i=1,len do
			local mj_bg_img = obj.transform:Find("MjCard".. i .."/@mj_bg_img"):GetComponent("Image")
			local mj_img = obj.transform:Find("MjCard".. i .."/@mj_bg_img/@mj_img"):GetComponent("Image")
			mj_bg_img.color = b  or Color.white
			mj_img.color = b  or Color.white
		end
	else
		self.mj_bg_img.color = b  or Color.white
		self.mj_img.color = b  or Color.white
	end
end

--玩家点出牌时 已出的或者碰杠的牌需要改变颜色提示
function MjCard:SetHintMark()
	print("<color=red>SetHintMarkSetHintMark </color>")
	self:SetMark(Color.New(0.6235,0.8235,0.9019,1))
end
function MjCard:CancelHintMark()
	print("<color=red>CancelHintMarkCancelHintMark </color>")
	self:SetMark(Color.white)
end

function MjCard:ChangePosStatus(posStatus)
    local changeStatus = function (posStatus)
        if  self.posStatus == posStatus then
            return 
        end
        if  self.ani then
            self.ani:Kill()
            self.ani=nil
        end
        if self.posStatus==2 and posStatus==0 then
            local tweenKey
            self.ani =  self.mj_bg_img.transform:DOLocalMove(Vector3.New(0,0,0),1):OnKill(function()
                DOTweenManager.RemoveStopTween(tweenKey)
                if IsEquals(self.mj_bg_img) then
    	            self.mj_bg_img.transform.localPosition=Vector3.New(0,0,0)
	            end
                self.ani=nil
            end)
            tweenKey = DOTweenManager.AddTweenToStop(self.ani)

            self.posStatus = posStatus
        else
            self.posStatus = posStatus
            if posStatus == 0 then
                self.is_ready = false
                self.mj_bg_img.transform.localPosition = Vector3.New(0,0,0)
            elseif posStatus == 1 then
                self.is_ready = true
                self.mj_bg_img.transform.localPosition = Vector3.New(0,50,0)
            elseif posStatus == 2 then
                self.is_ready = true
                self.mj_bg_img.transform.localPosition = Vector3.New(0,200,0)
            end
        end
    end

    if not posStatus then
        if self.posStatus==0 or not self.posStatus then
            changeStatus(1)
        else
            changeStatus(0)
        end
    else
        changeStatus(posStatus)
    end
end



