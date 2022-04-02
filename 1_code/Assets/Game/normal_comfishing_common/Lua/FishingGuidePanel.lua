-- 创建时间:2018-07-23

FishingGuidePanel = {}

local basefunc = require "Game.Common.basefunc"

FishingGuidePanel = basefunc.class()

FishingGuidePanel.instance = nil

function FishingGuidePanel.Show(guideId, guideStep)
	if FishingGuidePanel.instance then
		FishingGuidePanel.instance:ShowUI(guideId, guideStep)
		return
	end
	FishingGuidePanel.Create(guideId, guideStep)
end
-- 显示
function FishingGuidePanel:ShowUI(guideId, guideStep)
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	if not IsEquals(parent) then
		print("FishingGuidePanel:ShowUI exception: parent is nil")
		return
	end

	self.transform:SetParent(parent)
	self.transform.localScale = Vector3.one
	self.guideId = guideId
	self.guideStep = guideStep
	self:InitRect()
end
function FishingGuidePanel.Exit()
	if FishingGuidePanel.instance then
		FishingGuidePanel.instance:HideUI()
		FishingGuidePanel.instance:MyExit()
	end
	FishingGuidePanel.instance = nil
end

-- 隐藏
function FishingGuidePanel:HideUI()
	if IsEquals(self.targetGameObject) then
		local bclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Button))
		for i = 0, bclick.Length - 1 do
			bclick[i].onClick:RemoveListener(self.callClick)
		end
		local pclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(PolygonClick))
		for i = 0, pclick.Length - 1 do
			pclick[i].PointerClick:RemoveListener(self.callClick)
		end

		self.targetGameObject.transform.parent = self.originalParent
		self.targetGameObject.transform:SetSiblingIndex(self.originalIndex)
		local meshs = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.MeshRenderer))
		for i = 0, meshs.Length - 1 do
			meshs[i].sortingOrder = meshs[i].sortingOrder - self.cha
		end
		local canvas = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.Canvas))
		for i = 0, canvas.Length - 1 do
			canvas[i].sortingOrder = canvas[i].sortingOrder - self.cha
		end
	end
	self.targetGameObject = nil

	self.transform:SetParent(FishingGuidePanel.HideParent)
	self.gameObject:SetActive(false)
end

function FishingGuidePanel.Create(guideId, guideStep)
	FishingGuidePanel.instance = FishingGuidePanel.New(guideId, guideStep)
    return FishingGuidePanel.instance
end

function FishingGuidePanel:ctor(guideId, guideStep)

	ExtPanel.ExtMsg(self)

	self.guideId = guideId
	self.guideStep = guideStep
    FishingGuidePanel.HideParent = GameObject.Find("GameManager").transform
    self.parent = GameObject.Find("Canvas/LayerLv50")
    self.gameObject = newObject("FishingGuidePanel", self.parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.GuideNode = tran:Find("GuideNode")
    self.Canvas = tran:Find("Canvas")
    self.BGImage = tran:Find("BGImage")
    self.BubbleNode = tran:Find("Canvas/BubbleNode")
    self.BubbleText = tran:Find("Canvas/BubbleNode/BubbleImage/Text"):GetComponent("Text")
    self.GuideStyle1 = tran:Find("GuideStyle1")
    self.TopRect = tran:Find("GuideStyle1/TopButton"):GetComponent("RectTransform")
    self.SZAnim1 = tran:Find("Canvas/SZAnim1"):GetComponent("Transform")
    self.LeftBG = tran:Find("GuideStyle1/TopButton/LeftBG"):GetComponent("RectTransform")
    self.RightBG = tran:Find("GuideStyle1/TopButton/RightBG"):GetComponent("RectTransform")
    self.TopButton = tran:Find("GuideStyle1/TopButton"):GetComponent("Button")
    self.TopButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnClick()
    end)

    self.SkipButton = tran:Find("SkipButton"):GetComponent("Button")
    self.SkipButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnSkipClick()
    end)

	self.callClick = function (obj)
		self:OnClick()
	end
    self:InitRect()
end
function FishingGuidePanel:MyExit()
	GameObject.Destroy(self.gameObject)

	 
end
function FishingGuidePanel:InitRect()
	self.gameObject:SetActive(true)
	local guide = FishingGuideConfig[self.guideId]

	local cfg = FishingGuideModel.GetStepConfig(self.guideId, self.guideStep)
	if cfg then
		if guide.isSkip == 1 then
			self.SkipButton.gameObject:SetActive(true)
		else
			self.SkipButton.gameObject:SetActive(false)
		end
		self.BubbleNode.gameObject:SetActive(false)
		self.SZAnim1.gameObject:SetActive(false)

		self:StepButton(cfg)
	else
		self:HideUI()
	end
end
function FishingGuidePanel:StepButton(cfg)
	coroutine.start(function ( )
		Yield(0)

		self.targetGameObject = self:getFindObject(cfg.name)
		if IsEquals(self.targetGameObject) then
			self.originalIndex = self.targetGameObject.transform:GetSiblingIndex()
			self.originalParent = self.targetGameObject.transform.parent
			local meshs = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.MeshRenderer))
			local canvas = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.Canvas))
			local min_ceng = 10000
			for i = 0, meshs.Length - 1 do
				if min_ceng > meshs[i].sortingOrder then
					min_ceng = meshs[i].sortingOrder
				end
			end
			for i = 0, canvas.Length - 1 do
				if min_ceng > canvas[i].sortingOrder then
					min_ceng = canvas[i].sortingOrder
				end
			end

			local cha = 56 - min_ceng
			self.cha = cha
			for i = 0, meshs.Length - 1 do
				meshs[i].sortingOrder = meshs[i].sortingOrder + cha
			end
			for i = 0, canvas.Length - 1 do
				canvas[i].sortingOrder = canvas[i].sortingOrder + cha
			end
			
			self.targetGameObject.transform:SetParent(self.GuideNode)

			local gpos = self.targetGameObject.transform.position
			local size = self.targetGameObject:GetComponent("RectTransform").sizeDelta
			self.Canvas.transform.position = Vector3.New(gpos.x + cfg.headPos.x, gpos.y + cfg.headPos.y, gpos.z)
			self.GuideStyle1.transform.position = Vector3.New(gpos.x + cfg.headPos.x, gpos.y + cfg.headPos.y, gpos.z)

			if cfg.desc and cfg.desc ~= "" then
				self.BubbleNode.localPosition = cfg.descPos
				self.BubbleText.text = cfg.desc
				self.BubbleNode.gameObject:SetActive(true)
			else
				self.BubbleNode.gameObject:SetActive(false)
			end

			if cfg.descRot then
				self.BubbleNode.transform.localRotation = Quaternion:SetEuler(cfg.descRot.x, cfg.descRot.y, cfg.descRot.z)
				self.BubbleText.transform.localRotation = Quaternion:SetEuler(cfg.descRot.x, cfg.descRot.y, cfg.descRot.z)
			else
				self.BubbleNode.transform.localRotation = Quaternion:SetEuler(0, 0, 0)
				self.BubbleText.transform.localRotation = Quaternion:SetEuler(0, 0, 0)
			end

			if cfg.szPos then
				self.SZAnim1.localPosition = cfg.szPos
			else
				self.SZAnim1.localPosition = Vector3.New(0,0,0)
			end
			if cfg.isHideSZ then
				self.SZAnim1.gameObject:SetActive(false)
			else
				self.SZAnim1.gameObject:SetActive(true)
			end

			if cfg.type == "button" then
				self.GuideStyle1.gameObject:SetActive(false)
				if cfg.isHideBG then
					self.BGImage.gameObject:SetActive(false)
				else
					self.BGImage.gameObject:SetActive(true)
				end

				local bclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Button))
				for i = 0, bclick.Length - 1 do
					bclick[i].onClick:AddListener(self.callClick)
				end
				local pclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(PolygonClick))
				for i = 0, pclick.Length - 1 do
					pclick[i].PointerClick:AddListener(self.callClick)
				end
			elseif cfg.type == "GuideStyle1" then
				self.BGImage.gameObject:SetActive(false)
				self.GuideStyle1.gameObject:SetActive(true)
				self.TopRect.sizeDelta = size
				self.LeftBG.sizeDelta = {x=3000, y=size.y}
				self.RightBG.sizeDelta = {x=3000, y=size.y}
			else
				print("<color=red>错误的引导类型 type=" .. cfg.type .. "</color>")
				self:HideUI()
			end
		else
			self:HideUI()
			print("<color=red>查找失败</color>")
		end

	end)
end

--查找name对应的对象
function FishingGuidePanel:getFindObject(name)
	local obj = GameObject.Find(name)
	return obj
end

function FishingGuidePanel:OnClick(obj)
	print("<color=red>引导点击</color>")
	self:HideUI()
	FishingGuideLogic.StepFinish()
end
function FishingGuidePanel:OnBackClick()
    GameObject.Destroy(self.gameObject)
end

function FishingGuidePanel:OnSkipClick()
    FishingGuideLogic.GuideSkip()
    self:HideUI()
end

