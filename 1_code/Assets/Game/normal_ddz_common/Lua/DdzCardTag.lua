-- 创建时间:2018-05-30
--ganshuangfeng 斗地主牌标记

DdzCardTagType = {
    sp = "sp",  --手上的牌
    cp = "cp",  --出出去的牌
    fp = "fp",  --废牌
}

local basefunc = require "Game.Common.basefunc"
DdzCardTag = basefunc.class()
local spTag = {}
local cpTag = {}

--生成地主牌标记 parent: 父物体，地主牌上的@tag; type : 类型 sp , cp  ;isDel 1删除手牌tag, 2删除出牌tag
function DdzCardTag:ctor(parent, cardType, del)
    
    local go = newObject("DdzCardTag",parent.transform)
    if del == 1 then
        if spTag ~= nil then
            destroy(spTag.gameObject)
            spTag = nil
        end
    elseif del == 2 then
        if cpTag ~= nil then
            destroy(cpTag.gameObject)
            cpTag = nil
        end
    end

    if cardType == DdzCardTagType.sp then
        spTag = go
    elseif cardType == DdzCardTagType.cp then
        cpTag = go
    end
    self.tagImage = go:GetComponent("Image")
end
function DdzCardTag:SetTagImage(name)
    self.tagImage.sprite = GetTexture(name)
end