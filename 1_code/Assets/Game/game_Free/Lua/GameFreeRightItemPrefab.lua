-- 创建时间:2018-12-05

local basefunc = require "Game.Common.basefunc"

GameFreeRightItemPrefab = basefunc.class()

local C = GameFreeRightItemPrefab

C.name = "GameFreeRightItemPrefab"

function C.Create(parent_transform, config, call, panelSelf, index)
	return C.New(parent_transform, config, call, panelSelf, index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parent_transform, config, call, panelSelf, index)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf
    self.index = index
	local obj = newObject(C.name, parent_transform)
	self.gameObject = obj
	self.transform = obj.transform

	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(obj.transform, self)

    self.xuanzhong = {}
    self.xuanzhong[#self.xuanzhong + 1] = self.xuanzhong1
    self.xuanzhong[#self.xuanzhong + 1] = self.xuanzhong2
    self.xuanzhong[#self.xuanzhong + 1] = self.xuanzhong3
    self.xuanzhong[#self.xuanzhong + 1] = self.xuanzhong4

    self.NodeCanvasGroup = self.UINode:GetComponent("CanvasGroup")

	self.BGImage_btn.onClick:AddListener(function ()
		self:OnClick()
	end)
    self.isopenfinish = false
	self:MyRefresh()
end
function C:MyRefresh()
	self.BGImage_img.sprite = GetTexture("pattern_pp_btn_" .. self.config.imageIndex .. self.config.imageIndex)
    if self.config.base <= 0 then
        self.Base_txt.text = "0"
        self["BS_" .. self.index .. "_txt"].text = "0"
    else
        self.Base_txt.text = self.config.base
        self["BS_" .. self.index .. "_txt"].text = self.config.base
    end
    self.Base_txt.font = GetFont("pp_" .. self.config.imageIndex .. "_1_game_free")

	if self.config.enterMin < 0 and self.config.enterMax < 0 then
		self.Enter_txt.text = "入场 无限制"
	elseif self.config.enterMin < 0 and self.config.enterMax > 0 then
		self.Enter_txt.text = "入场 " .. StringHelper.ToCash(self.config.enterMax) .. "以下"
	elseif self.config.enterMin > 0 and self.config.enterMax < 0 then
		self.Enter_txt.text = "入场 " .. StringHelper.ToCash(self.config.enterMin) .. "以上"
	else
		self.Enter_txt.text = "入场 " .. StringHelper.ToCash(self.config.enterMin) .. "~" .. StringHelper.ToCash(self.config.enterMax)
	end

    if self.config.isLock and self.config.isLock == 1 then
    	self.LockNode.gameObject:SetActive(true)
    else
    	self.LockNode.gameObject:SetActive(false)
    end
    
    if self.config.tag_image and self.config.tag_image ~= "" then
    	self.Tag_img.gameObject:SetActive(true)
    	self.Tag_img.sprite = GetTexture(self.config.tag_image)
    else
    	self.Tag_img.gameObject:SetActive(false)
    end

    if self.config.is_activity and self.config.is_activity == 1 then
    	self.ActivityRect.gameObject:SetActive(true)
    else
    	self.ActivityRect.gameObject:SetActive(false)
    end

    self:SetShowPlayType(false)
end

function C:SetShowPlayType(hide)
    if not hide and self.config.play_type and self.config.play_type ~= "" then
        self.playtype.gameObject:SetActive(true)
        self.play_txt.text = self.config.play_type
    else
        self.playtype.gameObject:SetActive(false)
    end
end

function C:PlayAnim(t)
    local scale = 0.75
    if self.selectIndex == self.index then
        scale = 1
    end
    self.UINode.transform.localScale = Vector3.New(0.7*scale, 0.7*scale, 0.7*scale)
    self.NodeCanvasGroup.alpha = 0.01

    self.openseq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(self.openseq)
    self.openseq:AppendInterval(t)
    self.openseq:Append(self.UINode.transform:DOScale(1*scale, 0.5):SetEase(DG.Tweening.Ease.OutBack))--OutBack
    self.openseq:Join(self.NodeCanvasGroup:DOFade(1, 0.5):SetEase(DG.Tweening.Ease.OutBack))
    self.openseq:OnKill(function()
        DOTweenManager.RemoveStopTween(tweenKey)
        if IsEquals(self.UINode) then
            self.NodeCanvasGroup.alpha = 1
            local us = 0.75
            if self.selectIndex == self.index then
                us = 1
            end
            self.UINode.transform.localScale = Vector3.New(us, us, 1)
        end
        self.openseq = nil
    end)
end

-- 设置选中状态
function C:SetSelectFX(selectIndex, isanim)
    if not IsEquals(self.Base_txt) then
        return
    end
    if self.index == selectIndex then
        self.Base_txt.gameObject:SetActive(false)
        self["nor_" .. self.index].gameObject:SetActive(false)
        self["sel_" .. self.index].gameObject:SetActive(true)
        self:SetShowPlayType(true)
    else
        self.Base_txt.gameObject:SetActive(true)
        self["nor_" .. self.index].gameObject:SetActive(true)
        self["sel_" .. self.index].gameObject:SetActive(false)
        self:SetShowPlayType(false)
    end

    if isanim then
        if self.openseq then
            self.openseq:Kill()
        end

        if not self.selectIndex then
        else
            self.xuanzhong[self.index].gameObject:SetActive(false)
            if self.selectseq then
                self.selectseq:Kill()
            end
            if self.selectIndex ~= selectIndex then
                if selectIndex == self.index then
                    local t = math.abs(1-self.UINode.transform.localScale.x)/0.25*0.5
                    self.selectseq = DG.Tweening.DOTween.Sequence()
                    local tweenKey = DOTweenManager.AddTweenToStop(self.selectseq)
                    self.selectseq:Append(self.UINode.transform:DOScale(1, t):SetEase(DG.Tweening.Ease.OutBack))--OutBack
                    self.selectseq:OnComplete(function ()
                        self.xuanzhong[self.index].gameObject:SetActive(true)
                    end)
                    self.selectseq:OnKill(
                    function()
                        DOTweenManager.RemoveStopTween(tweenKey)
                        self.selectseq = nil
                    end)

                elseif self.selectIndex == self.index then
                    local t = math.abs(0.75-self.UINode.transform.localScale.x)/0.25*0.5
                    self.selectseq = DG.Tweening.DOTween.Sequence()
                    local tweenKey = DOTweenManager.AddTweenToStop(self.selectseq)
                    self.selectseq:Append(self.UINode.transform:DOScale(0.75, t):SetEase(DG.Tweening.Ease.OutBack))--OutBack
                    self.selectseq:OnKill(
                    function()
                        DOTweenManager.RemoveStopTween(tweenKey)
                        self.selectseq = nil
                    end)

                end
            end
            self.selectIndex = selectIndex
        end
    else
        self.selectIndex = selectIndex
        if self.selectIndex == self.index then
            self.UINode.transform.localScale = Vector3.New(1, 1, 1)
            self.xuanzhong[self.index].gameObject:SetActive(true)
        else
            self.UINode.transform.localScale = Vector3.New(0.75, 0.75, 1)
            self.xuanzhong[self.index].gameObject:SetActive(false)
        end
    end
end

-- 设置gameObject名字
function C:SetObjName(name)
	self.gameObject.name = name
end

-- 点击
function C:OnClick()
    if IsEquals(self.gameObject) then
        self.call(self.panelSelf, self.index)
    end
end

function C:MyExit()
    if self.selectseq then
        self.selectseq:Kill()
    end

    self:RemoveListener()
end

function C:OnDestroy()
	self:MyExit()
	GameObject.Destroy(self.gameObject)
end




