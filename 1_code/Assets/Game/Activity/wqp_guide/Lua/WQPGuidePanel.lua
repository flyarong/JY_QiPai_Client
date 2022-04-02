-- 创建时间:2020-11-15
-- Panel:Template_NAME
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

 WQPGuidePanel = {}
 local basefunc = require "Game.Common.basefunc"
 WQPGuidePanel = basefunc.class()

local C = WQPGuidePanel
C.name = "WQPGuidePanel"

WQPGuidePanel.instance = nil

function WQPGuidePanel.Show(guideId, guideStep)
	if WQPGuidePanel.instance and WQPGuidePanel.instance.transform and IsEquals(WQPGuidePanel.instance.transform) then
		WQPGuidePanel.instance:ShowUI(guideId, guideStep)
		return
	end
	WQPGuidePanel.Create(guideId, guideStep)
end

function WQPGuidePanel:ShowUI(guideId, guideStep)
	if self.guideId and self.guideStep and self.guideId == guideId and self.guideStep == guideStep then
		print("<color=red>EEE 相同步骤正在执行 " .. self.guideId .. "  " .. self.guideStep .. "</color>")
		return
	end
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	if not IsEquals(parent) then
		print("WQPGuidePanel:ShowUI exception: parent is nil")
		return
	end

	self.transform:SetParent(parent)
	self.transform.localScale = Vector3.one
	self.guideId = guideId
	self.guideStep = guideStep
	self:InitRect()
end
function WQPGuidePanel.Exit()
	if WQPGuidePanel.instance then
		WQPGuidePanel.instance:HideUI()
		WQPGuidePanel.instance:MyExit()
	end
	WQPGuidePanel.instance = nil
end

function WQPGuidePanel:HideUI()
	if IsEquals(self.targetGameObject) then
		local bclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Button))
		for i = 0, bclick.Length - 1 do
			bclick[i].onClick:RemoveListener(function ()
				self:OnClick()
			end)
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

	self.guideId = nil
	self.guideStep = nil
	if IsEquals(self.gameObject) then
		self.transform:SetParent(WQPGuidePanel.HideParent)
		self.gameObject:SetActive(false)
	end
end

function WQPGuidePanel.Create(guideId, guideStep)
	WQPGuidePanel.instance = WQPGuidePanel.New(guideId, guideStep)
    return WQPGuidePanel.instance
end

function WQPGuidePanel:ctor(guideId, guideStep)

	self.guideId = guideId
	self.guideStep = guideStep
    WQPGuidePanel.HideParent = GameObject.Find("GameManager").transform
    self.parent = GameObject.Find("Canvas/LayerLv50")
    self.gameObject = newObject("WQPGuidePanel", self.parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.GuideNode = tran:Find("GuideNode")
    self.DebugText = tran:Find("DebugText"):GetComponent("Text")
    self.Canvas = tran:Find("Canvas")
    self.BGImage = tran:Find("BGImage")
    self.BubbleNode = tran:Find("Canvas/BubbleNode")
	self.BubbleText = tran:Find("Canvas/BubbleNode/BubbleImage/Text"):GetComponent("Text")
	self.RwImage = tran:Find("Canvas/Guide_RW")
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
	
	self.AllAreaButton = tran:Find("AllAreaButton"):GetComponent("Button")
	self.AllAreaButton.onClick:AddListener(function ()
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
    self:InitRect()
end
function WQPGuidePanel:MyExit()
	destroy(self.gameObject)

	 
end
function WQPGuidePanel:InitRect()
	self.gameObject:SetActive(true)
	local guide = WQPGuideConfig[self.guideId]
	local cfg = WQPGuideModel.GetCurStepCfg()
	dump(cfg,"<color=white>---------WQPGuidePanel:InitRect------------</color>")

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
function WQPGuidePanel:StepButton(cfg)
	--dump("<color=white>WQPGuidePanel:StepButton</color>")
	-- coroutine.start(function ( )
	-- 	Yield(0)
		if IsEquals(self.DebugText) and self.DebugText.text then
			local id = cfg.id or ""
			 self.DebugText.text = self.DebugText.text .. id .. "\n"
		end
		if cfg.type == "GuideStyle2" then
			self.targetGameObject = self:getFindObject(cfg.name)
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
			--dump(self.TopRect,"<color=white>SSSSSTopRectSSSSS</color>")
			self.TopRect.sizeDelta = cfg.topsizeDelta
			self.TopRect.localPosition = cfg.trPos
			self.LeftBG.sizeDelta = { x = 3000, y = cfg.topsizeDelta.y }
			self.RightBG.sizeDelta = { x = 3000, y = cfg.topsizeDelta.y }


			if cfg.allTouchNext and cfg.allTouchNext == true then
				self.AllAreaButton.gameObject:SetActive(true)
			else
				self.AllAreaButton.gameObject:SetActive(false)
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
		else
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

				local cha = 86 - min_ceng
				self.cha = cha
				for i = 0, meshs.Length - 1 do
					meshs[i].sortingOrder = meshs[i].sortingOrder + cha
				end
				for i = 0, canvas.Length - 1 do
					canvas[i].sortingOrder = canvas[i].sortingOrder + cha
				end
				
				self.targetGameObject.transform:SetParent(self.GuideNode)
				--self.AllAreaButton.gameObject:SetActive(false)
				local gpos = self.targetGameObject.transform.position
				local size = self.targetGameObject:GetComponent("RectTransform").sizeDelta

				if IsEquals(self.Canvas) then
					self.Canvas.transform.position = Vector3.New(gpos.x, gpos.y, gpos.z)
				end
				if IsEquals(self.GuideStyle1) then
					self.GuideStyle1.transform.position = Vector3.New(gpos.x, gpos.y, gpos.z)
				end
				if cfg.trPos then
					self.TopRect.localPosition = cfg.trPos
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
						-- dump(bclick[i].name,"<color=white>bclick</color>")
						-- dump(self.callClick,"<color=white>self.callClick</color>")
						bclick[i].onClick:AddListener(
							function ()
								self:OnClick()
							end
						)
						--self.callClick)
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
		end
	-- end)
end

--查找name对应的对象
function WQPGuidePanel:getFindObject(name)
	dump(name, "<color=white>查找对象</color>")
	local obj = GameObject.Find(name)
	return obj
end

function WQPGuidePanel:OnClick(obj)
	print("<color=red>引导点击</color>")
	local cfg = WQPGuideModel.GetCurStepCfg()
	if cfg and cfg.bsdsmName then
		dump(cfg.bsdsmName , "<color=red>新手引导埋点:</color>")
		Event.Brocast("bsds_send_power",{key = cfg.bsdsmName})
	end
	self:HideUI()
	WQPGuideLogic.NextStep()
end

function WQPGuidePanel:OnBackClick()
    GameObject.Destroy(self.gameObject)
end

function WQPGuidePanel:OnSkipClick()
	print("<color=red>引导跳过</color>")
    self:HideUI()
	WQPGuideLogic.SkipGuide()
end
