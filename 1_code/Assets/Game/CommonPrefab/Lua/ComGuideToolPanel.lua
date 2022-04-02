-- 创建时间:2020-01-15
-- 公用引导脚本

local basefunc = require "Game.Common.basefunc"

ComGuideToolPanel = basefunc.class()
local C = ComGuideToolPanel

function C.Create()
    return C.New()
end
function C:ctor()
    C.HideParent = GameObject.Find("GameManager").transform
    self.parent = GameObject.Find("Canvas/LayerLv50").transform
    self.gameObject = newObject("GuidePanel", self.parent)
    self.transform = self.gameObject.transform
    local tran = self.transform
    self.gameObject.name = "LHDGuidePanel"

    self.GuideNode = tran:Find("GuideNode")
    self.DebugText = tran:Find("DebugText"):GetComponent("Text")
    self.Canvas = tran:Find("Canvas")
    self.BGImage = tran:Find("BGImage")
    self.BubbleNode = tran:Find("Canvas/BubbleNode")
    self.BubbleText = tran:Find("Canvas/BubbleNode/BubbleImage/Text"):GetComponent("Text")
	self.CaiShen = tran:Find("Canvas/CaiShen")
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

	self.callClick = function ()
		self:OnClick()
	end
	self:CloseGuide()
end
function C:MyExit()
	C.HideParent = nil
	destroy(self.gameObject)
end

-- 关闭引导
function C:CloseGuide()
	if IsEquals(self.targetGameObject) then
		local bclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Button))
		for i = 0, bclick.Length - 1 do
			bclick[i].onClick:RemoveListener(self.callClick)
		end
		local pclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(PolygonClick))
		for i = 0, pclick.Length - 1 do
			pclick[i].PointerClick:RemoveListener(self.callClick)
		end

		self.targetGameObject.transform:SetParent(self.originalParent)
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

	if IsEquals(self.gameObject) then
		self.transform:SetParent(C.HideParent)
		self.gameObject:SetActive(false)
	end
end
-- 执行引导
function C:RunGuide(cfg, tobj)
	dump(cfg, "<color=red>执行引导</color>")
	dump(tobj)
	coroutine.start(function ()
		Yield(0)

		dump(self.transform)
		dump(self.parent)
		self.transform:SetParent(self.parent)
		self.gameObject:SetActive(true)

		self.DebugText.text = self.DebugText.text .. cfg.id .. "\n"
		if tobj then
			self.targetGameObject = tobj
		else
			self.targetGameObject = self:getFindObject(cfg.name)
		end
		if cfg.type == "GuideStyle2" then
			if IsEquals(self.targetGameObject) then
				self.Canvas.transform.position = self.targetGameObject.transform.position
			end
			self.targetGameObject = nil
			self.BGImage.gameObject:SetActive(false)
			self.GuideStyle1.gameObject:SetActive(true)
			if cfg.topPos then
				self.GuideStyle1.transform.localPosition = cfg.topPos
			else
				self.GuideStyle1.transform.localPosition = Vector3.zero
			end
			self.TopRect.sizeDelta = cfg.topsizeDelta
			self.LeftBG.sizeDelta = {x=3000, y=cfg.topsizeDelta.y}
			self.RightBG.sizeDelta = {x=3000, y=cfg.topsizeDelta.y}

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
		else
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

				local cha = 86 - min_ceng
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
				if IsEquals(self.Canvas) then
					self.Canvas.transform.position = Vector3.New(gpos.x + cfg.headPos.x, gpos.y + cfg.headPos.y, gpos.z)
				end
				if IsEquals(self.GuideStyle1) then
					self.GuideStyle1.transform.position = Vector3.New(gpos.x + cfg.headPos.x, gpos.y + cfg.headPos.y, gpos.z)
				end
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

				self.CaiShen.gameObject:SetActive(false)


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
					self:CloseGuide()
				end
			else
				dump(cfg)
				print(debug.traceback())
				self:CloseGuide()
				print("<color=red>查找失败</color>")
			end
		end
	end)
end

--查找name对应的对象
function C:getFindObject(name)
	local obj = GameObject.Find(name)
	return obj
end

function C:OnClick(obj)
	print("<color=red>引导点击完成</color>")
	self:CloseGuide()
	Event.Brocast("com_guide_step", {key="finish"})
end

function C:SetSkipButtonActive(b)
	self.SkipButton.gameObject:SetActive(b)
end

function C:OnSkipClick()
    self:CloseGuide()
    Event.Brocast("com_guide_step", {key="skip"})
end
