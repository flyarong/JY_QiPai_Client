local basefunc = require "Game.Common.basefunc"

ShatterGoldenEggHelp = basefunc.class()
ShatterGoldenEggHelp.name = "ShatterGoldenEggHelp"

local instance = nil

local lister = {}
function ShatterGoldenEggHelp:MakeLister()
	lister = {}

	lister["view_sge_close"] = basefunc.handler(self, self.handle_sge_close)
	lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

local PAGE_TBL = {
	"ZJDHelpPage1", "ZJDHelpPage2", "ZJDHelpPage3", "ZJDHelpPage4", "ZJDHelpPage5", "ZJDHelpPage6"
}

function ShatterGoldenEggHelp.Create(parent)
	if not instance then
		instance = ShatterGoldenEggHelp.New(parent)
	end
	return instance
end

function ShatterGoldenEggHelp:ctor(parent)
	local obj = newObject(ShatterGoldenEggHelp.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	ShatterGoldenEggLogic.setViewMsgRegister(lister, ShatterGoldenEggHelp.name)

	local page_count = #PAGE_TBL
	if page_count > 1 then
		local step = 1 / (page_count - 1)
		self.page_weights = {}
		for idx = 1, page_count, 1 do
			self.page_weights[idx] = (idx - 1) * step
		end
	else
		self.page_weights[1] = 0
	end
	self.page_index = 1
	self.dragPosition = 0

	self.pageList = {}
	self.dotList = {}

	self:InitRect()
end

function ShatterGoldenEggHelp.Close()
	if instance then
		ShatterGoldenEggLogic.clearViewMsgRegister(ShatterGoldenEggHelp.name)
		instance:ClearAll()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function ShatterGoldenEggHelp.IsShow()
	if not instance then return false end
	return instance.transform.gameObject.activeSelf
end

function ShatterGoldenEggHelp:InitRect()
	local transform = self.transform

	self.scrollView = transform:Find("CenterRect/Scroll View"):GetComponent("ScrollRect")
	EventTriggerListener.Get(self.scrollView.gameObject).onBeginDrag = basefunc.handler(self, self.OnBeginDrag)
	EventTriggerListener.Get(self.scrollView.gameObject).onEndDrag = basefunc.handler(self, self.OnEndDrag)

	self.hint_close_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		ShatterGoldenEggHelp.Close()
	end)

	self.scp_left_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		
		self.page_index = Mathf.Clamp(self.page_index - 1, 1, #PAGE_TBL);
		self:UpdatePageButtons()
		self.scrollView.horizontalNormalizedPosition = self.page_weights[self.page_index]
	end)
	self.scp_right_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		
		self.page_index = Mathf.Clamp(self.page_index + 1, 1, #PAGE_TBL);
		self:UpdatePageButtons()
		self.scrollView.horizontalNormalizedPosition = self.page_weights[self.page_index]
	end)

	self:Refresh()
end

function ShatterGoldenEggHelp:Refresh()
	self:ClearItemList(self.pageList)
	self.pageList = {}
	self:ClearItemList(self.dotList)
	self.dotList = {}

	self:FillItemList(PAGE_TBL)
	self:UpdatePageButtons()
end

function ShatterGoldenEggHelp:UpdatePageButtons()
	local page_count = #PAGE_TBL
	if page_count <= 1 then
		self.scp_left_btn.gameObject:SetActive(false)
		self.scp_right_btn.gameObject:SetActive(false)

		for _, v in ipairs(self.dotList) do
			v.gameObject:SetActive(false)
		end
	else
		self.scp_left_btn.gameObject:SetActive(true)
		self.scp_right_btn.gameObject:SetActive(true)
		if self.page_index <= 1 then
			self.scp_left_btn.gameObject:SetActive(false)
		end
		if self.page_index >= page_count then
			self.scp_right_btn.gameObject:SetActive(false)
		end

		for k, v in ipairs(self.dotList) do
			local image = v.transform:Find("icon"):GetComponent("Image")
			if k == self.page_index then
				image.color = Color.white
			else
				image.color = Color.New(1, 1, 1, 0.3)
			end
		end
	end
end

function ShatterGoldenEggHelp:ClearAll()
	self:ClearItemList(self.pageList)
	self.pageList = {}
	self:ClearItemList(self.dotList)
	self.dotList = {}

	self.currentIndex = 0
	self.currentPage = 0
end

function ShatterGoldenEggHelp:CreateItem(parent, tmpl)
	local obj = GameObject.Instantiate(tmpl)

	obj.transform:SetParent(parent)
	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one
	obj.transform:SetAsLastSibling()

	obj.gameObject:SetActive(true)

	return obj
end

function ShatterGoldenEggHelp:FillItemList(data)
	local page_count = #PAGE_TBL

	for idx = 1, page_count, 1 do
		self.pageList[#self.pageList + 1] = self:CreateItem(self.scp_list, GetPrefab(PAGE_TBL[idx]))
		--self.pageList[#self.pageList + 1] = self:CreateItem(self.scp_list, self.page_tmpl)
	end

	for idx = 1, page_count, 1 do
		local btnNode = self:CreateItem(self.dot_list, self.dot_tmpl)
		local image = btnNode.transform:Find("icon"):GetComponent("Image")
		EventTriggerListener.Get(image.gameObject).onClick = function()
			self.page_index = idx
			self:UpdatePageButtons()
			self.scrollView.horizontalNormalizedPosition = self.page_weights[self.page_index]
		end

		self.dotList[#self.dotList + 1] = btnNode
	end
end

function ShatterGoldenEggHelp:ClearItemList(list)
	for k, v in ipairs(list) do
		GameObject.Destroy(v.gameObject)
		list[k] = nil
	end
end

function ShatterGoldenEggHelp:OnBeginDrag()
	local page_count = #PAGE_TBL
	if page_count <= 1 then return end

	self.dragPosition = self.scrollView.horizontalNormalizedPosition
end

function ShatterGoldenEggHelp:OnEndDrag()
	local page_count = #PAGE_TBL
	if page_count <= 1 then return end

	local currentPosition = self.scrollView.horizontalNormalizedPosition
	if currentPosition > self.dragPosition then
		currentPosition = currentPosition + 0.1
	else
		currentPosition = currentPosition - 0.1
	end

	local page_index = 1
	local offset = math.abs(self.page_weights[page_index] - currentPosition)
	for idx = 2, page_count, 1 do
		local tmp = math.abs(currentPosition - self.page_weights[idx])
		if tmp < offset then
			page_index = idx
			offset = tmp
		end
	end

	self.page_index = page_index
	self:UpdatePageButtons()

	--self.scrollView.horizontalNormalizedPosition = self.page_weights[self.page_index]
	self:AnimationScroll(self.page_weights[self.page_index])
end

function ShatterGoldenEggHelp:handle_sge_close()
	ShatterGoldenEggHelp.Close()
end

function ShatterGoldenEggHelp:OnExitScene()
	ShatterGoldenEggHelp.Close()
end

function ShatterGoldenEggHelp:AnimationScroll(dst)
	if not IsEquals(self.scrollView) then return end

	local callbacks = {}

	local CNT = 5
	local current = self.scrollView.horizontalNormalizedPosition
	local step = (dst - current) / CNT

	for idx = 1, CNT, 1 do
		callbacks[idx] = {}
		callbacks[idx].stamp = 0.025
		callbacks[idx].method = function()
			if IsEquals(self.scrollView) then
				self.scrollView.horizontalNormalizedPosition = current + step * idx
			end
		end
	end

	ShatterGoldenEggLogic.TweenDelay(callbacks, function()
		if IsEquals(self.scrollView) then
			self.scrollView.horizontalNormalizedPosition = dst
		end
	end)
end
