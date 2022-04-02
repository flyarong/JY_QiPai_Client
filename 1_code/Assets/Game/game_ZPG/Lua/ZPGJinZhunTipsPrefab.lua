-- 创建时间:2020-04-08

--指针进度条预制体
local basefunc = require "Game.Common.basefunc"

ZPGJinZhunTipsPrefab = basefunc.class()

local C = ZPGJinZhunTipsPrefab
C.name = "ZPGJinZhunTipsPrefab"


function C.Create(parent)
    return C.New(parent)
end


function C:ctor(parent)
    self.isKill = false
    self.gameObject = newObject(C.name,parent)
    self.tran = self.gameObject.transform
    self.delayTime = DoTweenSequence.Create()
    self.delayTime:AppendInterval(1)
    self.delayTime:AppendCallback(function()
        self:MyExit()
    end)
end

function C:MyExit()
    if self.isKill then return end
    if self.delayTime then
        self.delayTime:Kill()
    end
    local seq = DoTweenSequence.Create()
    seq:Append(self.tran:DOLocalMoveY(100,0.5))
    seq:OnKill(function ()
        Destroy(self.gameObject)
        self.isKill = true
    end)
end