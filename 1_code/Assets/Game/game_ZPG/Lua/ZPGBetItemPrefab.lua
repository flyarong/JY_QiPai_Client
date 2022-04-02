-- 创建时间:2020-04-01

--指针进度条预制体
local basefunc = require "Game.Common.basefunc"

ZPGBetItemPrefab = basefunc.class()

local C = ZPGBetItemPrefab
C.name = "ZPGBetItemPrefab"

function C.Create(index,pos,parent)
    return C.New(index,pos,parent)
end

function C:ctor(index,pos,parent)
    -- self.gameObject = newObject("ZPGBetItemPrefab_" .. index,parent)
    --以后换成缓存池
    self.prefab = CachePrefabManager.Take("ZPGBetItemPrefab_" .. index,parent)
    self.prefab.prefab:SetParent(parent)
    self.gameObject = self.prefab.prefab.prefabObj
    --用于生成
    self.rect = parent.gameObject:GetComponent("RectTransform").rect
    self.transform = self.prefab.prefab.prefabObj.transform
    self.index = index
    if pos then
        self.transform.position = pos
    end
    self:InitUI()
end

function C:InitUI()
end

function C:PlayFlyToRect(need_destroy)
    --随机在parent的rect中生成一个随机点,然后向那里移动

    local targetVec = self:CalculateRandomPos()
    local interval = math.random() * 0.2 + 0.2

    local seq = DoTweenSequence.Create()
    seq:Append(self.transform:DOLocalMove(targetVec,interval))
    if need_destroy then 
        seq:OnForceKill(function()
            self:MyExit()
        end)
    end
end

function C:SetPosToRect()
    --直接选到随机位置
    local pos = self:CalculateRandomPos()
    self.transform.localPosition = pos
end

function C:PlayFlyToPlayer(pos,time)
    --飞回玩家的位置
    local interval = time or math.random() * 0.5 + 0.4
    local seq = DoTweenSequence.Create()
    seq:Append(self.transform:DOMove(pos,interval))
    seq:OnForceKill(function() 
        self:MyExit()
    end)
end

function C:CalculateRandomPos()
    local xMax = tls.rectGetMaxX(self.rect)
    local xMin = tls.rectGetMinX(self.rect)
    local yMax = tls.rectGetMaxY(self.rect)
    local yMin = tls.rectGetMinY(self.rect)
    local posX = math.random(xMin,xMax)
    local posY = math.random(yMin,yMax)

    local targetVec = Vector3.New(posX,posY,0)
    return targetVec
end

function C:MyExit()
    CachePrefabManager.Back(self.prefab)
    -- Destroy(self.gameObject)
end