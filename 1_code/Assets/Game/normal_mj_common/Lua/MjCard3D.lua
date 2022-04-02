--- 3D麻將，就是单一的一个

local basefunc = require "Game.Common.basefunc"

MjCard3D = basefunc.class()
local C = MjCard3D 

C.PaiType =
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

C.parent_scale = Vector3.New( 0.2 , 0.2 , 0.2 )
C.parent_position = Vector3.New( -2.044 , 5.14 , 11.9 )

C.sizeScale = 1.05
---- 麻将模型里，边最短的是Z，第二短的是X，最长边是Y
C.origSize = Vector3.New( 1.45 , 1.95 , 1 )
C.size = Vector3.New( C.sizeScale * C.origSize.x , C.sizeScale * C.origSize.y , C.sizeScale * C.origSize.z )

function C.Create(parent_transform, cardType, card, callbackClick)
	return C.New(parent_transform, cardType, card, callbackClick)
end

function C:ctor(parent_transform, cardType, card, callbackClick,posStatus)
	self.parent_transform = parent_transform
	self.cardType = cardType
	self.card = card
	self.callbackClick = callbackClick
	self.posStatus=posStatus or 0

	---- 实例化一个实体
	local obj = GameObject.Instantiate( GetPrefab( string.format( "mj_%d" , card ) ) , self.parent_transform )
	self.transform = obj.transform
	self.transform.localScale = Vector3.New( C.sizeScale / 0.2 , C.sizeScale / 0.2 , C.sizeScale / 0.2 )


	self.gameObject = obj
	obj.name = card

	---- 原始的牌的材质
	self.oriMaterialName = "mj_02"
	

	---- 创建的时候会有一个默认的设置旋转角度，如果是暗杠的第4个要在外部重新设置一下正面朝上
	if cardType == C.PaiType.sp then
		self:setRotationShouPai()
	elseif cardType == C.PaiType.cp then
		--self.oriMaterialName = "mj_01"
		self:setRotationChuPai()
	elseif cardType == C.PaiType.pp then
		self:setRotationPengPai()
	elseif cardType == C.PaiType.hp then
		--self.oriMaterialName = "mj_01"
		self:setRotationChuPai()
	elseif cardType == C.PaiType.ag then
		self:setRotationGangDownPai()
	elseif cardType == C.PaiType.zg then
		self:setRotationGangUpPai()
	elseif cardType == C.PaiType.wg then
		self:setRotationGangUpPai()
	elseif cardType == C.PaiType.zp then
		self:setRotationShouPai()
	end

	----
	self.gameObject:GetComponent("MeshRenderer").material = GetMaterial(self.oriMaterialName)

	return self
end

function C:setOriMaterialName(name)
	self.oriMaterialName = name
	self.gameObject:GetComponent("MeshRenderer").material = GetMaterial(self.oriMaterialName)
end

---- 当3D麻将按下
function C:OnDown()
	if self.callbackClick then
		self:callbackClick()
	end
end

---- 销毁
function C:OnDestroy()
	GameObject.Destroy( self.gameObject )
	--self.callbackClick = nil
	self.card = nil
	self.gameObject = nil
end

---- mask 相同提示的mask , b 代表是否mask
function C:SetMark(b)
	if not self.gameObject or not self.gameObject.GetComponent then
		return
	end
	if b then
		self.gameObject:GetComponent("MeshRenderer").material = GetMaterial("myCard_off")   -- mj_TargetFlag
	else
		self.gameObject:GetComponent("MeshRenderer").material = GetMaterial(self.oriMaterialName)
	end

end

--玩家点出牌时 已出的或者碰杠的牌需要改变颜色提示
function C:SetHintMark()
	--print("<color=red>SetHintMarkSetHintMark </color>")
	self:SetMark( true )
end
function C:CancelHintMark()
	--print("<color=red>CancelHintMarkCancelHintMark </color>")
	self:SetMark( false )
end

----- 改变位置状态
function C:ChangePosStatus(posStatus)
	if not self.gameObject then
		return
	end
	local changeStatus = function (posStatus)
		--print("<color=yellow> ChangePosStatus state = " .. posStatus .. " </color>")
        if  self.posStatus == posStatus then
        	--print("<color=yellow> ---- MjCard3D 牌的状态一致： </color>",posStatus , self.card)
            return 
        end
        if  self.ani then
            self.ani:Kill()
            self.ani=nil
        end
        if self.posStatus==2 and posStatus==0 then
            local tweenKey
            self.ani =  self.transform:DOLocalMoveZ( 0 + 0.5*MjCard3D.size.z ,1):OnKill(function()
                DOTweenManager.RemoveStopTween(tweenKey)
                if IsEquals(self.transform) then
    	            self.transform.localPosition = Vector3.New( self.transform.localPosition.x , self.transform.localPosition.y , 0 ) 
	            end
                self.ani=nil
            end)
            tweenKey = DOTweenManager.AddTweenToStop(self.ani)

            self.posStatus = posStatus
        else
            self.posStatus = posStatus
            if posStatus == 0 then
                self.is_ready = false
                self.transform.localPosition = Vector3.New( self.transform.localPosition.x , self.transform.localPosition.y , 0 ) 
            elseif posStatus == 1 then
                self.is_ready = true
                self.transform.localPosition = Vector3.New( self.transform.localPosition.x , self.transform.localPosition.y , 0.5*MjCard3D.size.z ) 
            elseif posStatus == 2 then
                self.is_ready = true
                self.transform.localPosition = Vector3.New( self.transform.localPosition.x , self.transform.localPosition.y , 2*MjCard3D.size.z ) 
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

----- 设置层
function C:setLayer(layerName)
	self.transform.gameObject.layer = LayerMask.NameToLayer( layerName )
end

----------------------------------------- 
---- 设置 手牌 的 3D麻将的旋转角度 
function C:setRotationShouPai()
	self.transform.localEulerAngles = Vector3.New( 180 , -180 , 0 )
end


---- 设置 出牌 的 3D麻将的旋转角度 
function C:setRotationChuPai()
	self.transform.localEulerAngles = Vector3.New( -270 , -90 , 90 )
end

---- 设置 碰牌 的 3D麻将的旋转角度 
function C:setRotationPengPai()
	self.transform.localEulerAngles = Vector3.New( -270 , -90 , 90 )
end

---- 设置 杠牌 朝上的 3D麻将的旋转角度 
function C:setRotationGangUpPai()
	self.transform.localEulerAngles = Vector3.New( -270 , -90 , 90 )
end

---- 设置 杠牌 朝下的 3D麻将的旋转角度 
function C:setRotationGangDownPai()
	self.transform.localEulerAngles = Vector3.New( -270 , 90 , 90 )
end

function C:GetCard()
	return self.card
end
