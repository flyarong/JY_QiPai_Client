
local basefunc = require "Game.Common.basefunc"

LittleTips = basefunc.class()

--[[小提示

]]
local TipsType = {
    TT_Com = "TT_Com",
    TT_Award = "TT_Award",
    TT_Crit = "TT_Crit",
    TT_Joker = "TT_Joker",
    TT_SP = "TT_SP",
    TT_SP1 = "TT_SP1",
}
function LittleTips.Create(parm, pos, params)
    local p = {x = 0,y =150}
    if pos then p = pos end
    
    params = params or {}
    if not params.bg then
    	params.bg = "hint_bg_black"
    end

    return LittleTips.New(parm, p, TipsType.TT_Com, params)
end

function LittleTips.CreateAwardHint(parm, pos)
    local p = {x = 0,y =150}
    if pos then p = pos end
    return LittleTips.New(parm, p, TipsType.TT_Award, {})
end

function LittleTips.CreateCrit(parm, pos)
    local p = {x = 0,y =150}
    if pos then p = pos end
    return LittleTips.New(parm, p, TipsType.TT_Crit, {})
end
function LittleTips.CreateJoker(parm, pos)
    local p = {x = 0,y =150}
    if pos then p = pos end
    return LittleTips.New(parm, p, TipsType.TT_Joker, {})
end

-- 竖屏
function LittleTips.CreateSP(parm, pos)
    local p = {x = -400,y =0}
    if pos then p = pos end
    return LittleTips.New(parm, p, TipsType.TT_SP, {})
end

-- 竖屏
function LittleTips.CreateSP1(parm, pos)
    local p = {x = -400,y =0}
    if pos then p = pos end
    return LittleTips.New(parm, p, TipsType.TT_SP1, {})
end

--[[

]]
function LittleTips:ctor(parm, pos, hinttype, params)
    local x, y = pos.x, pos.y
    self.parm = parm

    local parent = AdaptLayerParent("Canvas/LayerLv50", params)
    if not IsEquals(parent) then return end
    self.parent = parent
    
    if hinttype == TipsType.TT_Crit then
        self.UIEntity = newObject("LittleTipsCrit", self.parent.transform)
    else
        self.UIEntity = newObject("LittleTips", self.parent.transform)
    end

    local tran = self.UIEntity.transform
    self.ComNode = tran:Find("ComNode")
    self.AwardNode = tran:Find("AwardNode")
    self.JokerNode = tran:Find("JokerNode")

    local layerOrder = params.layerOrder
    if layerOrder then
        local canvas = tran:GetComponent("Canvas")
        canvas.sortingOrder = layerOrder
    end

    if hinttype == TipsType.TT_Award then
        self.ComNode.gameObject:SetActive(false)
        self.AwardNode.gameObject:SetActive(true)
        self.JokerNode.gameObject:SetActive(false)
        self:InitComAward(params)
    elseif hinttype == TipsType.TT_Com then
        self.ComNode.gameObject:SetActive(true)
        self.AwardNode.gameObject:SetActive(false)
        self.JokerNode.gameObject:SetActive(false)
        self:InitComTips(params)
    elseif hinttype == TipsType.TT_Joker then
        self.ComNode.gameObject:SetActive(false)
        self.AwardNode.gameObject:SetActive(false)
        self.JokerNode.gameObject:SetActive(true)
        self:InitJokerTips()
    elseif hinttype == TipsType.TT_Crit then
        self.ComNode.gameObject:SetActive(true)
        self.AwardNode.gameObject:SetActive(false)
        self:InitComTips(params)
        self.ComNode = tran:Find("ComNode")
        local seqScale = DG.Tweening.DOTween.Sequence()
        local tweenScaleKey = DOTweenManager.AddTweenToExit(seqScale)
        seqScale:Append(self.ComNode.transform:DOScale(Vector3.one * 1.5,0.05))
        seqScale:AppendInterval(0.2)
        seqScale:Append(self.ComNode.transform:DOScale(Vector3.one * 1,0.1))
        seqScale:OnKill(function ()
            DOTweenManager.RemoveExitTween(tweenScaleKey)
        end)

        self.ComNode.transform.localScale = Vector3.New(2,2,1)
        self.text.color = Color.New(1,0,0,1)
    elseif hinttype == TipsType.TT_SP then
        self.ComNode.gameObject:SetActive(true)
        self.AwardNode.gameObject:SetActive(false)
        self.JokerNode.gameObject:SetActive(false)
        self:InitComTips(params)
        self.UIEntity.transform.localPosition=Vector3.New(x,y,0)
        self.UIEntity.transform.localRotation = Quaternion:SetEuler(0, 0, 90)

        local seqMove = DG.Tweening.DOTween.Sequence()
        local tweenKey = DOTweenManager.AddTweenToExit(seqMove)
        seqMove:Append(self.UIEntity.transform:DOLocalMoveX(x-100,0.4))
        seqMove:AppendInterval(3)
        seqMove:Append(self.UIEntity.transform:GetComponent("CanvasGroup"):DOFade(0,0.4))
        seqMove:OnKill(function ()
            DOTweenManager.RemoveExitTween(tweenKey)
            if IsEquals(tran) then
                tran:SetParent(nil)
            end
            destroy(self.UIEntity)
        end)
        return
    elseif hinttype == TipsType.TT_SP1 then
        self.ComNode.gameObject:SetActive(true)
        self.AwardNode.gameObject:SetActive(false)
        self.JokerNode.gameObject:SetActive(false)
        self:InitComTips(params)
        self.UIEntity.transform.localPosition=Vector3.New(x,y,0)
        self.UIEntity.transform.localRotation = Quaternion:SetEuler(0, 0, 90)

        local seqMove = DG.Tweening.DOTween.Sequence()
        local tweenKey = DOTweenManager.AddTweenToExit(seqMove)
        seqMove:Append(self.UIEntity.transform:DOLocalMoveX(x - 350,0.4))
        seqMove:AppendInterval(6)
        seqMove:Append(self.UIEntity.transform:GetComponent("CanvasGroup"):DOFade(0,0.4))
        seqMove:OnKill(function ()
            DOTweenManager.RemoveExitTween(tweenKey)
            if IsEquals(tran) then
                tran:SetParent(nil)
            end
            destroy(self.UIEntity)
        end)
        return
    end

    self.UIEntity.transform.localPosition=Vector3.New(x,y,0)

    local seqMove = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToExit(seqMove)
    seqMove:Append(self.UIEntity.transform:DOLocalMoveY(y+100,0.4))
    seqMove:AppendInterval(3)
    seqMove:Append(self.UIEntity.transform:GetComponent("CanvasGroup"):DOFade(0,0.4))
    seqMove:OnKill(function ()
        DOTweenManager.RemoveExitTween(tweenKey)
    	if IsEquals(tran) then
    		tran:SetParent(nil)
    	end
        destroy(self.UIEntity)
    end)

end

function LittleTips:InitComTips(params)
    local tran = self.UIEntity.transform

    self.text = tran:Find("ComNode/info_txt"):GetComponent("Text")
    self.text.text = self.parm

    params = params or {}
    local bg = params.bg
    if bg then
    	local image = self.ComNode.transform:GetComponent("Image")
	image.sprite = GetTexture(bg)
    end
end
function LittleTips:InitComAward(params)
    local tran = self.UIEntity.transform
    local Text1 = tran:Find("AwardNode/Text1"):GetComponent("Text")
    local Icon = tran:Find("AwardNode/IconNode/Icon"):GetComponent("Image")
    local Text2 = tran:Find("AwardNode/Text2"):GetComponent("Text")

    if self.parm.awardtype == "shop_gold_sum" or self.parm.awardtype == "cash" then
        Text2.text = "x" .. StringHelper.ToCash(self.parm.award / 100)
    else
        Text2.text = "x" .. self.parm.award
    end
    local item = GameItemModel.GetItemToKey(self.parm.awardtype)
    Icon.sprite = GetTexture(item.image)
end
function LittleTips:InitJokerTips()
    local tran = self.UIEntity.transform
    local textT = self.JokerNode:Find("Text1")
    local iconT = self.JokerNode:Find("Icon")
    for k,v in ipairs(self.parm) do
        if v.isImg == 1 then
            local obj = GameObject.Instantiate(iconT, self.JokerNode).gameObject
            obj:SetActive(true)
            local icon = obj:GetComponent("Image")
            icon.sprite = GetTexture(v.value)
        else
            local obj = GameObject.Instantiate(textT, self.JokerNode).gameObject
            obj:SetActive(true)
            local txt = obj:GetComponent("Text")
            txt.text = v.value
        end
    end
end

