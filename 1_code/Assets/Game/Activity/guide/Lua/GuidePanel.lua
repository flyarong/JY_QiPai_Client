-- 创建时间:2018-07-23

GuidePanel = {}

local basefunc = require "Game.Common.basefunc"

GuidePanel = basefunc.class()

GuidePanel.instance = nil

function GuidePanel.Show(guideId, guideStep)
	if GuidePanel.instance and GuidePanel.instance.transform and IsEquals(GuidePanel.instance.transform) then
		GuidePanel.instance:ShowUI(guideId, guideStep)
		return
	end
	GuidePanel.Create(guideId, guideStep)
end
-- 显示
function GuidePanel:ShowUI(guideId, guideStep)
	if self.guideId and self.guideStep and self.guideId == guideId and self.guideStep == guideStep then
		print("<color=red>EEE 相同步骤正在执行 " .. self.guideId .. "  " .. self.guideStep .. "</color>")
		--return
		self:HideUI()
	end
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	if not IsEquals(parent) then
		print("GuidePanel:ShowUI exception: parent is nil")
		return
	end

	self.transform:SetParent(parent)
	self.transform.localScale = Vector3.one
	self.guideId = guideId
	self.guideStep = guideStep
	self:InitRect()
end
function GuidePanel.Exit()
	if GuidePanel.instance then
		GuidePanel.instance:HideUI()
		GuidePanel.instance:MyExit()
	end
	GuidePanel.instance = nil
end

-- 隐藏
function GuidePanel:HideUI()
	if IsEquals(self.targetGameObject) then
		local bclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Button))
		for i = 0, bclick.Length - 1 do
			bclick[i].onClick:RemoveListener(self.callClick)
		end
		local pclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(PolygonClick))
		for i = 0, pclick.Length - 1 do
			pclick[i].PointerClick:RemoveListener(self.callClick2)
		end

		local cfg = GuideModel.GetStepConfig(self.guideId, self.guideStep)
		if cfg and cfg.type ~= "unforce" and cfg.type ~= "GuideStyle2" then
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
	end
	self.targetGameObject = nil
	self.guideId = nil
	self.guideStep = nil
	if IsEquals(self.gameObject) then
		self.transform:SetParent(GuidePanel.HideParent)
		self.gameObject:SetActive(false)
	end

	if self.sz_dianji then
		destroy(self.sz_dianji.gameObject)
		self.sz_dianji = nil
	end
end

function GuidePanel.Create(guideId, guideStep)
	GuidePanel.instance = GuidePanel.New(guideId, guideStep)
    return GuidePanel.instance
end

function GuidePanel:ctor(guideId, guideStep)

	self.guideId = guideId
	self.guideStep = guideStep
    GuidePanel.HideParent = GameObject.Find("GameManager").transform
    self.parent = GameObject.Find("Canvas/LayerLv50")
    self.gameObject = newObject("GuidePanel", self.parent.transform)
    self.transform = self.gameObject.transform
    local tran = self.transform

    self.GuideNode = tran:Find("GuideNode")
    self.DebugText = tran:Find("DebugText"):GetComponent("Text")
    self.Canvas = tran:Find("Canvas")
    self.BGImage = tran:Find("BGImage")
    self.BubbleNode = tran:Find("Canvas/BubbleNode")
    self.BubbleText = tran:Find("Canvas/BubbleNode/BubbleImage/Text"):GetComponent("Text")
	--self.CaiShen = tran:Find("Canvas/CaiShen")
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
	self.Touch = tran:Find("touch")

	local sz = GameObject.Find("Canvas/SZAnim1/SZAnim1")
	sz.transform.localPosition = Vector3.zero
	self.callClick = function (obj)
		self:OnClick(obj)
	end
	self.callClick2 = function (obj)
		self:OnClick(obj)
	end
    self:InitRect()
end
function GuidePanel:MyExit()
	destroy(self.gameObject)
end
function GuidePanel:InitRect()
	self.gameObject:SetActive(true)
	local guide = GuideConfig[self.guideId]
	local cfg = GuideModel.GetStepConfig(self.guideId, self.guideStep)
	if cfg then
		if guide.isSkip == 1 then
			self.SkipButton.gameObject:SetActive(true)
		else
			self.SkipButton.gameObject:SetActive(false)
		end
		self.BubbleNode.gameObject:SetActive(false)
		self.SZAnim1.gameObject:SetActive(false)
		self.GuideStyle1.gameObject:SetActive(false)
		self.Touch.gameObject:SetActive(true)

		self:StepButton()
	else
		self:HideUI()
	end
end
function GuidePanel:StepButton()
	-- coroutine.start(function()
	-- 	Yield(0)

		local cfg = GuideModel.GetStepConfig(self.guideId, self.guideStep)

		if IsEquals(self.DebugText) and self.DebugText.text then
			local id = cfg.id or ""
			self.DebugText.text = self.DebugText.text .. id .. "\n"
		end
		self.targetGameObject = self:getFindObject(cfg.name)
		--self.CaiShen.gameObject:SetActive(false)
		if cfg.type == "GuideStyle2" then
			--self.targetGameObject = self:getFindObject(cfg.name)
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
			self:LoadDesc(cfg)
			self:LoadSz(cfg)
			self:LoadImageBg(cfg)
		elseif cfg.type == "unforce" then
			self.Touch.gameObject:SetActive(false)
			self.BGImage.gameObject:SetActive(false)
			if IsEquals(self.targetGameObject) then
				self.sz_dianji = newObject("dianji_guide",self.targetGameObject.transform)
				self:AddListenerClickToBtn()
			end
		else
			--self.targetGameObject = self:getFindObject(cfg.name)
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
				if IsEquals(self.Canvas) then
					self.Canvas.transform.position = Vector3.New(gpos.x + cfg.headPos.x, gpos.y + cfg.headPos.y, gpos.z)
				end
				self:LoadDesc(cfg)
				self:LoadSz(cfg)
				self:LoadImageBg(cfg)

				if cfg.type == "button" then
					self:AddListenerClickToBtn()
				elseif cfg.type == "GuideStyle1" then
					self.BGImage.gameObject:SetActive(false)
					self.GuideStyle1.gameObject:SetActive(true)

					if IsEquals(self.GuideStyle1) then
						self.GuideStyle1.transform.position = Vector3.New(gpos.x + cfg.headPos.x, gpos.y + cfg.headPos.y, gpos.z)
					end
					local size = self.targetGameObject:GetComponent("RectTransform").sizeDelta
					self.TopRect.sizeDelta = size
					self.LeftBG.sizeDelta = {x=3000, y=size.y}
					self.RightBG.sizeDelta = {x=3000, y=size.y}
				else
					print("<color=red>错误的引导类型 type=" .. cfg.type .. "</color>")
					self:HideUI()
				end
			else
				print(debug.traceback())
				self:HideUI()
				print("<color=red>查找失败</color>")
			end
		end
	--end)
end

--给要点击的对象添加点击监听
function GuidePanel:AddListenerClickToBtn()
	if IsEquals(self.targetGameObject) then
		-- print(debug.traceback())
		-- print("<color=red>AddListenerClickToBtn ==  " .. self.targetGameObject.name .. "</color>")

		local bclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(UnityEngine.UI.Button))
		for i = 0, bclick.Length - 1 do
		bclick[i].onClick:AddListener(self.callClick)--function()
			--self:OnClick(bclick[i].gameObject)
		--end) 
		end
		local pclick = self.targetGameObject.gameObject:GetComponentsInChildren(typeof(PolygonClick))
		for i = 0, pclick.Length - 1 do
			pclick[i].PointerClick:AddListener(self.callClick2)
		end
	else
		dump("<color=red>未找到目标对象</color>")
	end
end

--描述
function GuidePanel:LoadDesc(cfg)
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
end

--手指
function GuidePanel:LoadSz(cfg)
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
end

--黑色背景
function GuidePanel:LoadImageBg(cfg)
	if cfg.isHideBG then
		self.BGImage.gameObject:SetActive(false)
	else
		self.BGImage.gameObject:SetActive(true)
	end
end

--查找name对应的对象
function GuidePanel:getFindObject(name)
	local obj = GameObject.Find(name)
	return obj
end

function GuidePanel:OnClick(obj)

	print(Time.frameCount,"<color=red>新手引导点击</color>")
	dump({guideId = self.guideId , guideStep = self.guideStep},"<color=red>0</color>")
	if self.guideId and self.guideStep then
		local cfg = GuideModel.GetStepConfig(self.guideId, self.guideStep)
		if cfg and cfg.bsdsmName then
			dump(cfg.bsdsmName , "<color=red>新手引导埋点:</color>")
			Event.Brocast("bsds_send_power",{key = cfg.bsdsmName})
		end
	end

	if self.sz_dianji then
		destroy(self.sz_dianji.gameObject)
		self.sz_dianji = nil
	end
	-- dump(obj)
	-- if IsEquals(obj) then
	-- 	print(obj.name)
	-- end
	-- print(debug.traceback())
	self:HideUI()
	GuideLogic.StepFinish()
end
function GuidePanel:OnBackClick()
    GameObject.Destroy(self.gameObject)
end

function GuidePanel:OnSkipClick()
    GuideLogic.GuideSkip()
    self:HideUI()
end

