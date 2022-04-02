-- 创建时间:2018-05-30
--ganshuangfeng 斗地主牌

local basefunc = require "Game.Common.basefunc"
local nor_ddz_base_lib = require "Game.normal_ddz_common.Lua.nor_ddz_base_lib"

local onClick=false
DdzCard = basefunc.class()

--生成牌 obj牌的预制体，parent父节点，num牌编号，weights权重，status状态（0在下 1 在上）, isCardOut是否是出出去的牌
--gameType -- 斗地主比赛类型 0比赛场 1自由场 2百万场 3赖子场 4听用场
function DdzCard:ctor(obj , parent, no, weight, posStatus, isCardOut)
    
    local go = GameObject.Instantiate(obj, parent)
    go.name = no
    self.transform = go.transform
    self.gameObject = go.gameObject
    LuaHelper.GeneratingVar(self.transform, self)

    self.no = no
    self.weight = weight
    
     --如果是出出去的牌的话只需要把牌设置好即可
    if not isCardOut then isCardOut = false end
    if isCardOut then
        self:SetCard()
        return
    end

    --0在下 1 在上 2 最上
    self.posStatus =nil 
    posStatus=posStatus or 0
    self:ChangePosStatus(posStatus)
    
    --0正常 1 变灰
    self.colorStatus=0
    --动画
    self.ani=nil

    --可点击状态
    self.clickStatus=0

    self:Init()    
end

function DdzCard:Init()
    self:SetCard()
    self:ChangeToClickCard()
end

function DdzCard:Destroy()
    GameObject.Destroy(self.gameObject)
    self = nil
end

--设置牌面
function DdzCard:SetCard()
    self.card_num.gameObject:SetActive(false)
    self.card_jok.gameObject:SetActive(false)
    self.card_bg.gameObject:SetActive(false)
    if self.no <= 0 then
        --背面的牌
        self.card_bg.gameObject:SetActive(true)
    elseif self.no == 53 or self.no == 54 then
        --王牌
        local icon = "poker_icon_joker_"
        if self.no == 53 then
            icon = icon .. "b"
        else
            icon = icon .. "a"
        end
        self.jok_num_img.sprite = GetTexture(icon)
        -- self.jok_num_img:SetNativeSize()
        self.jok_type_big_img.sprite = GetTexture(icon .. "1")
        -- self.jok_type_big_img:SetNativeSize()
        self.card_jok.gameObject:SetActive(true)
    elseif self.no >= 60  then
        print("DdzCard:SetCard Laizi: " .. self.no)
        local pai = nor_ddz_base_lib.get_pai_info(self.no)
        local typeIcon = "poker_laizi"
        local noIcon = "poker_icon_laizi" .. pai.type

        self.num_img.sprite = GetTexture(noIcon)
        -- self.num_img:SetNativeSize()
        self.type_img.sprite = GetTexture(typeIcon)
        -- self.type_img:SetNativeSize()
        self.type_big_img.sprite = GetTexture(typeIcon)
        -- self.type_big_img:SetNativeSize()
        self.card_num.gameObject:SetActive(true)
    else
        --数字牌
        local noIcon = "poker_icon_"
        local typeIcon = "poker_"
        local typeNumIcon = ""
        local pai = nor_ddz_base_lib.get_pai_info(self.no)
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
        if IsEquals(self.num_img) then
            self.num_img.sprite = GetTexture(noIcon)
            -- self.num_img:SetNativeSize()    
        end
        if IsEquals(self.type_img) then
            self.type_img.sprite = GetTexture(typeIcon)
            -- self.type_img:SetNativeSize()
        end
        if IsEquals(self.type_big_img) then
            self.type_big_img.sprite = GetTexture(typeIcon)
            -- self.type_big_img:SetNativeSize()
        end
        self.card_num.gameObject:SetActive(true)
    end
end

function DdzCard:ChangePosStatus(posStatus)
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
            self.ani =  self.card_img.transform:DOLocalMove(Vector3.New(0,0,0),1):OnKill(function()
                DOTweenManager.RemoveStopTween(tweenKey)
                if IsEquals(self.card_img) then
                    self.card_img.transform.localPosition=Vector3.New(0,0,0)
                end
                self.ani=nil
            end)
            tweenKey = DOTweenManager.AddTweenToStop(self.ani)
            self.posStatus = posStatus
        else
            self.posStatus = posStatus
            if posStatus == 0 then
                self.is_ready = false
                if IsEquals(self.gameObject) then
                    self.card_img.transform.localPosition = Vector3.New(0,0,0)
                end
            elseif posStatus == 1 then
                self.is_ready = true
                if IsEquals(self.gameObject) then
                    self.card_img.transform.localPosition = Vector3.New(0,40,0)
                end
            elseif posStatus == 2 then
                self.is_ready = true
                if IsEquals(self.gameObject) then
                    self.card_img.transform.localPosition = Vector3.New(0,200,0)
                end
            end
        end
    end

    if not posStatus then
        if self.posStatus==0 then
            changeStatus(1)
        else
            changeStatus(0)
        end
    else
        changeStatus(posStatus)
    end
end
function DdzCard:changeColorStaus(status)
    if status then 
        if  self.colorStatus==status then
            return 
        else
            self.colorStatus=status
        end
    else
        if self.colorStatus==0 then 
            self.colorStatus=1
        else
            self.colorStatus=0
        end
    end
    if self.colorStatus==1 then
        local hei = Color.New(128/255, 128/255, 128/255)
        if IsEquals(self.gameObject) then
            self.card_img.color = hei
            self.num_img.color = hei
            self.type_img.color = hei
            self.type_big_img.color = hei
            self.jok_type_big_img.color = hei
            self.jok_num_img.color = hei
            local tag = self.tag.transform:Find("DdzCardTag")
            if tag then
                local tag_img = tag.transform:GetComponent("Image")
                tag_img.color = hei
            end
        end
    elseif self.colorStatus==0 then
        if IsEquals(self.gameObject) then
            self.card_img.color = UnityEngine.Color.white
            self.num_img.color = UnityEngine.Color.white
            self.type_img.color = UnityEngine.Color.white
            self.type_big_img.color = UnityEngine.Color.white
            self.jok_type_big_img.color = UnityEngine.Color.white
            self.jok_num_img.color = UnityEngine.Color.white
            local tag = self.tag.transform:Find("DdzCardTag")
            if tag then
                local tag_img = tag.transform:GetComponent("Image")
                tag_img.color = UnityEngine.Color.white
            end
        end
    end 
end

function DdzCard:ChangeClickStatus(status)
    if status then 
        if  self.clickStatus==status then
            return
        else
            self.clickStatus=status
        end
    else
        if self.clickStatus==0 then 
            self.clickStatus=1
        else
            self.clickStatus=0
        end
    end
end

--出牌
function DdzCard:CardOut(outContentGo)
	self.transform:SetParent(outContentGo);
	self.transform.localScale = Vector3.one;
	self.transform.localPosition = Vector3.zero;
	self.card_bg.localPosition = Vector3.zero;

	for i, v in pairs( DDZLogic.cards_data ) do
	    if v == self.card_id then
	        table.remove(DDZLogic.cards_data, i);
	    end
	end
end

function DdzCard:ChangeToNotClickCard()
    self:ChangePosStatus(0)
    self:changeColorStaus(1)
    -- self:ChangeClickStatus(1)
end

function DdzCard:ChangeToClickCard()
    self:ChangePosStatus(0)
    self:changeColorStaus(0)
    -- self:ChangeClickStatus(0)
end
