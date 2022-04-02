-- 创建时间:2019-03-12
-- 渔网

local basefunc = require "Game/Common/basefunc"

FishingDRFishNetPrefab = basefunc.class()
local C = FishingDRFishNetPrefab
C.name = "FishingDRFishNetPrefab"

function C.Create(parent, data)
	return C.New(parent, data)
end

function C:MyExit()
    if self.anim_time then
        self.anim_time:Stop()
        self.anim_time = nil
    end
    CachePrefabManager.Back(self.prefab)
    self.data = nil
end

function C:ctor(parent, data)
	self.data = data
    self.prefab = CachePrefabManager.Take("FishNetPrefab_" .. self.data.type)
    self.prefab.prefab:SetParent(parent)
    self.transform = self.prefab.prefab.prefabObj.transform
	self.transform.position = FishingModel.Get2DToUIPoint(self.data.pos + self.data.up * self.data.offset)
	self:InitUI()
end

function C:InitUI()
    self.transform.localScale = Vector3.New(0.2, 0.2, 0.2)
    local ss = 1
    local seq = DoTweenSequence.Create()
    seq:Append(self.transform:DOScale(1.2*ss, 0.2))
    seq:Append(self.transform:DOScale(0.9*ss, 0.2))
    seq:Append(self.transform:DOScale(1*ss, 0.1))
    
    self.anim_time = Timer.New(function ()
        self:MyExit()
        self.anim_time = nil
    end, self.data.duration, 1)
    self.anim_time:Start()
end


