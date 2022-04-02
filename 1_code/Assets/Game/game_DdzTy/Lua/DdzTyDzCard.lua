-- 创建时间:2018-05-30
--ganshuangfeng 斗地主牌

local basefunc = require "Game.Common.basefunc"
local tingyong_ddz_func = require "Game.normal_ddz_common.Lua.tingyong_ddz_func"

local onClick=false
local change_map={}
DdzTyDzCard = basefunc.class()

--生成牌 obj牌的预制体，parent父节点，num牌编号，weights权重，status状态（0在下 1 在上）, isCardOut是否是出出去的牌
function DdzTyDzCard:ctor(obj , parent, no, weight)
    
    local go = GameObject.Instantiate(obj, parent)
    go.name = no
    self.transform = go.transform
    self.gameObject = go.gameObject
    LuaHelper.GeneratingVar(self.transform, self)

    self.no = no
    self.weight = weight
    self:SetCard()
end

function DdzTyDzCard:Destroy()
    GameObject.Destroy(self.gameObject)
    self = nil
end

--设置牌面
function DdzTyDzCard:SetCard()
    self.card_num.gameObject:SetActive(false)
    self.card_jok.gameObject:SetActive(false)
    self.card_ty.gameObject:SetActive(false)
    self.card_bg.gameObject:SetActive(false)
    if self.no == 0 then
        --背面的牌
        self.card_bg.gameObject:SetActive(true)
    elseif self.no == 55 then
        self.card_ty.gameObject:SetActive(true)
    elseif self.no == 53 or self.no == 54 then
        --王牌
        local icon = "poker_icon_joker_"
        if self.no == 53 then
            icon = icon .. "b"
        else
            icon = icon .. "a"
        end
        self.jok_num_img.sprite = GetTexture(icon .. "2")
        -- self.jok_num_img:SetNativeSize()
        self.jok_type_big_img.sprite = GetTexture(icon .. "1")
        -- self.jok_type_big_img:SetNativeSize()
        self.card_jok.gameObject:SetActive(true)
    elseif self.no >= 60  then
    	-- print("DdzTyDzCard:SetCard Laizi: " .. self.no)
        -- local pai = nDdzLaiziFunc.get_pai_info(self.no)
        -- local typeIcon = "poker_laizi"
        -- local noIcon = "poker_icon_laizi" .. pai.type

        -- self.num_img.sprite = GetTexture(noIcon)
        -- self.num_img:SetNativeSize()
        -- self.type_img.sprite = GetTexture(typeIcon)
        -- self.type_img:SetNativeSize()
        -- self.card_num.gameObject:SetActive(true)
        self.card_ty.gameObject:SetActive(true)
    else
        --数字牌
        local noIcon = "poker_icon_"
        local typeIcon = "poker_"
        local typeNumIcon = ""
        local pai = tingyong_ddz_func.get_pai_info(self.no)
        local paiType = pai.type
        local color = pai.color
        typeNumIcon = color
        --红黑梅方 0，1，2，3
        if color == 1 then
            noIcon = noIcon .. "nr" .. paiType
            typeIcon = typeIcon .. "heart"
        elseif color == 2 then
            noIcon = noIcon .. "nb" .. paiType
            typeIcon = typeIcon .. "spade"
        elseif color == 3 then
            noIcon = noIcon .. "nb" .. paiType
            typeIcon = typeIcon .. "plum"
        elseif color == 4 then
            noIcon = noIcon .. "nr" .. paiType
            typeIcon = typeIcon .. "block"
        end
        self.num_img.sprite = GetTexture(noIcon)
        self.num_img:SetNativeSize()
        self.type_img.sprite = GetTexture(typeIcon)
        self.type_img:SetNativeSize()
        self.card_num.gameObject:SetActive(true)
    end
end

