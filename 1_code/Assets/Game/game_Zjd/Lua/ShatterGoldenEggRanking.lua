local basefunc = require "Game.Common.basefunc"

ShatterGoldenEggRanking = basefunc.class()
ShatterGoldenEggRanking.name = "ShatterGoldenEggRanking"

local instance = nil
local MAX_PAGE_ITEM = 10

local lister = {}
function ShatterGoldenEggRanking:MakeLister()
	lister = {}
	lister["view_sge_ranking"] = basefunc.handler(self, self.handle_sge_ranking)

	lister["view_sge_close"] = basefunc.handler(self, self.handle_sge_close)
	lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function ShatterGoldenEggRanking.Create(parent)
	if not instance then
		instance = ShatterGoldenEggRanking.New(parent)
	end
	return instance
end

function ShatterGoldenEggRanking:ctor(parent)
	local obj = newObject(ShatterGoldenEggRanking.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	ShatterGoldenEggLogic.setViewMsgRegister(lister, ShatterGoldenEggRanking.name)

	self.currentIndex = 0
	self.currentPage = 0
	self.itemList = {}

	self:InitRect()
	ShatterGoldenEggLogic.TweenLocalMove(self.transform, -451.5, true, 0.3)
end

function ShatterGoldenEggRanking.Close()
	if instance then
		ShatterGoldenEggLogic.clearViewMsgRegister(ShatterGoldenEggRanking.name)
		instance:ClearAll()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function ShatterGoldenEggRanking:InitRect()
	local transform = self.transform

	self.tab1_btn.onClick:AddListener(function()
		if self.currentIndex == 1 then return end

		self.tab1_btn.gameObject:SetActive(false)
		self.tab1_img.gameObject:SetActive(true)
		self.tab2_btn.gameObject:SetActive(true)
		self.tab2_img.gameObject:SetActive(false)

		self.currentIndex = 1
		self:Refresh()
	end)

	self.tab2_btn.onClick:AddListener(function()
		if self.currentIndex == 2 then return end

		self.tab2_btn.gameObject:SetActive(false)
		self.tab2_img.gameObject:SetActive(true)
		self.tab1_btn.gameObject:SetActive(true)
		self.tab1_img.gameObject:SetActive(false)

		self.currentIndex = 2
		self:Refresh()
	end)

	self.ranking_btn.onClick:AddListener(function()
		ShatterGoldenEggLogic.TweenLocalMove(self.transform, -451.5, false, 0.3, function()
			ShatterGoldenEggRanking.Close()
		end)
	end)

	self.scroll_rect = transform:Find("Center/Scroll View"):GetComponent("ScrollRect")
	EventTriggerListener.Get(self.scroll_rect.gameObject).onEndDrag = basefunc.handler(self, self.OnEndDrag)

	self.currentIndex = 1
	self.currentPage = 1
	self:Refresh()
end

function ShatterGoldenEggRanking:Refresh()
	self:ClearItemList()
	
	local currentIndex = self.currentIndex or 0
	if currentIndex ~= 1 and currentIndex ~= 2 then
		print("[SGE] ranking refresh currentIndex is invalid:" .. currentIndex)
		return
	end

	local page = self.currentPage or 0
	if page <= 0 then
		print("[SGE] ranking refresh page is invalid:" .. page)
		return
	end

	local ret, data = ShatterGoldenEggModel.checkRanking(currentIndex, page, 0)
	if not ret then
		page = 1
		self.currentPage = page
		ShatterGoldenEggLogic.SendRanking(currentIndex, page, MAX_PAGE_ITEM)
		return
	end

	self:FillItemList(self.currentIndex, data)
end

function ShatterGoldenEggRanking:OnEndDrag()
	local currentIndex = self.currentIndex or 0
	if currentIndex ~= 1 and currentIndex ~= 2 then
		print("[SGE] ranking OnEndDrag currentIndex is invalid:" .. currentIndex)
		return
	end

	local page = self.currentPage or 0
	if page <= 0 then
		print("[SGE] ranking OnEndDrag page is invalid:" .. page)
		return
	end

	if self.scroll_rect.verticalNormalizedPosition <= 0 then
		page = math.max(1, math.floor(#self.itemList / MAX_PAGE_ITEM + 0.5))
		self.currentPage = page
		ShatterGoldenEggLogic.SendRanking(currentIndex, page, MAX_PAGE_ITEM)
	end
end

function ShatterGoldenEggRanking:ClearAll()
	self:ClearItemList()
	self.currentIndex = 0
	self.currentPage = 0
end

function ShatterGoldenEggRanking:CreateItem(parent, tmpl)
	local obj = GameObject.Instantiate(tmpl)

	obj.transform:SetParent(parent)
	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one
	obj.transform:SetAsLastSibling()

	obj.gameObject:SetActive(true)

	return obj
end

function ShatterGoldenEggRanking:FillItemList(index, data)
	local tmpl = nil
	if index == 1 then
		tmpl = self.rank_tmpl

		for k, v in ipairs(data) do
			local item = self:CreateItem(self.list_node, tmpl)
			self.itemList[#self.itemList + 1] = item

			--ranking
			if k >= 1 and k <= 3 then
				local icon = item.transform:Find("icon"):GetComponent("Image")
				icon.sprite = GetTexture("localpop_icon_" .. k)
				icon.gameObject:SetActive(true)
			else
				local number = item.transform:Find("number"):GetComponent("Text")
				number.text = k
				number.gameObject:SetActive(true)
			end
			local name = item.transform:Find("name"):GetComponent("Text")
			name.text = v.name
			local detail = item.transform:Find("detail"):GetComponent("Text")
			detail.text = string.format("获得 %d 个福卡", v.count)
		end

	elseif index == 2 then
		tmpl = self.record_tmpl

		for k, v in ipairs(data) do
			local item = self:CreateItem(self.list_node, tmpl)
			self.itemList[#self.itemList + 1] = item

			--record
			local detail = item.transform:Find("detail"):GetComponent("Text")
			detail.text = string.format("获得 %d 个福卡", v.count)
		end
	else
		print("[SGE] ranking FillItemList tab is invalid:" .. index)
	end
end

function ShatterGoldenEggRanking:ClearItemList()
	for k, v in ipairs(self.itemList) do
		GameObject.Destroy(v.gameObject)
	end
	self.itemList = {}
end

function ShatterGoldenEggRanking:handle_sge_ranking(result)
	local tab_idx = result.tab_idx
	local page_idx = result.page_idx
	local count = result.count
	local data = result.data

	if tab_idx ~= self.currentIndex then return end

	self:FillItemList(self.currentIndex, data)

	self.scroll_rect.verticalNormalizedPosition = 0
end

function ShatterGoldenEggRanking:handle_sge_close()
	ShatterGoldenEggRanking.Close()
end

function ShatterGoldenEggRanking:OnExitScene()
	ShatterGoldenEggRanking.Close()
end
