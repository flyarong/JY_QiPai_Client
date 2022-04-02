local basefunc = require "Game.Common.basefunc"

FishingDRBetPopMenu = basefunc.class()
FishingDRBetPopMenu.name = "FishingDRBetPopMenu"

local instance = nil

local lister = {}
function FishingDRBetPopMenu:MakeLister()
	lister = {}
end

function FishingDRBetPopMenu:AddMsgListener()
	for proto_name,func in pairs(lister) do
		Event.AddListener(proto_name, func)
	end
end

function FishingDRBetPopMenu:RemoveListener()
	for proto_name,func in pairs(lister) do
		Event.RemoveListener(proto_name, func)
	end
	lister = {}
end

function FishingDRBetPopMenu.Create(parent, key, list)
	if instance then
		FishingDRBetPopMenu.Close()
	end
	instance = FishingDRBetPopMenu.New(parent, key, list)

	return instance

	--[[if not instance then
		instance = FishingDRBetPopMenu.New(parent, key, list)
	else
		instance:Refresh(key, list)
	end
	return instance]]--
end

function FishingDRBetPopMenu:ctor(parent, key, list)
	local obj = newObject(FishingDRBetPopMenu.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()

	self.itemList = {}
	self:InitRect(key, list)
end

function FishingDRBetPopMenu.Close()
	if instance then
		instance:ClearAll()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function FishingDRBetPopMenu:InitRect(key, list)
	local transform = self.transform

	self.mask = transform:Find("mask")
	EventTriggerListener.Get(self.mask.gameObject).onClick = function()
		FishingDRBetPopMenu.Close()
	end

	self.item_tmpl = transform:Find("item_tmpl")
	--self.list_node = transform:Find("Scroll View/Viewport/list_node")
	self.list_node = transform:Find("list_node")

	self:Refresh(key, list)
end

function FishingDRBetPopMenu:ClearAll()
	self:ClearItemList(self.itemList)
	self.itemList = {}

	self.mask = nil
	self.item_tmpl = nil
	self.list_node = nil
end

function FishingDRBetPopMenu:Refresh(key, list)
	self:ClearItemList(self.itemList)
	self.itemList = {}

	for k, v in ipairs(list) do
		local idx = k
		local item = self:CreateItem(self.list_node, self.item_tmpl)
		local mask_img = item.transform:Find("mask_img")
		EventTriggerListener.Get(mask_img.gameObject).onClick = function()
			Event.Brocast("bydr_bet_pop_menu_click", {key, idx})
			FishingDRBetPopMenu.Close()
		end
		local title_txt = item.transform:Find("title_txt"):GetComponent("Text")
		title_txt.text = v

		self.itemList[idx] = item
	end
end

function FishingDRBetPopMenu:CreateItem(parent, tmpl)
	local obj = GameObject.Instantiate(tmpl, parent)

	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one
	obj.transform:SetAsLastSibling()

	obj.gameObject:SetActive(true)

	return obj
end

function FishingDRBetPopMenu:ClearItemList(list)
	for k, v in ipairs(list) do
		destroy(v.gameObject)
	end
end

function FishingDRBetPopMenu:OnExitScene()
	FishingDRBetPopMenu.Close()
end
