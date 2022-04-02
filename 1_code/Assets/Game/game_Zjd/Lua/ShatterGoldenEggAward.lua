local basefunc = require "Game.Common.basefunc"

ShatterGoldenEggAward = basefunc.class()
ShatterGoldenEggAward.name = "ShatterGoldenEggAward"

local instance = nil
local MAX_PAGE_ITEM = 10

local lister = {}
function ShatterGoldenEggAward:MakeLister()
	lister = {}

	lister["view_sge_refresh"] = basefunc.handler(self, self.Refresh)

	lister["view_sge_close"] = basefunc.handler(self, self.handle_sge_close)
	lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function ShatterGoldenEggAward.Create(parent)
	if not instance then
		instance = ShatterGoldenEggAward.New(parent)
	end
	return instance
end

function ShatterGoldenEggAward:ctor(parent)
	local obj = newObject(ShatterGoldenEggAward.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	ShatterGoldenEggLogic.setViewMsgRegister(lister, ShatterGoldenEggAward.name)

	self.itemList = {}

	self:InitRect()
	--ShatterGoldenEggLogic.TweenLocalMove(self.transform, -451.5, true, 0.3)
end

function ShatterGoldenEggAward.Close()
	if instance then
		ShatterGoldenEggLogic.clearViewMsgRegister(ShatterGoldenEggAward.name)
		instance:ClearAll()
		GameObject.Destroy(instance.transform.gameObject)
		instance = nil
	end
end

function ShatterGoldenEggAward.IsShow()
	if not instance then return false end
	if IsEquals(instance.transform) then
		return instance.transform.gameObject.activeSelf
	end
	return false
end

function ShatterGoldenEggAward:InitRect()
	local transform = self.transform

	EventTriggerListener.Get(self.check_click.gameObject).onClick = basefunc.handler(self, self.handle_click)

	self:Refresh()
end

function ShatterGoldenEggAward:Refresh()
	self:ClearItemList()

	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local award = ShatterGoldenEggModel.getAward(hammer_idx)
	if not award or #award <= 0 then
		print("[SGE] award refresh getAward is invalid:" .. hammer_idx)
		return
	end

	self:FillItemList(award)
end

function ShatterGoldenEggAward:ClearAll()
	self:ClearItemList()
	self.currentIndex = 0
	self.currentPage = 0
end

function ShatterGoldenEggAward:CreateItem(parent, tmpl)
	local obj = GameObject.Instantiate(tmpl)

	obj.transform:SetParent(parent)
	obj.transform.localPosition = Vector3.zero
	obj.transform.localScale = Vector3.one
	obj.transform:SetAsLastSibling()

	obj.gameObject:SetActive(true)

	return obj
end

local function copy_tbl(tbl)
	local new_tbl = {}

	for k, v in ipairs(tbl) do
		new_tbl[k] = v
	end
	table.sort(new_tbl, function(a,b) return a < b end)

	return new_tbl
end
function ShatterGoldenEggAward:FillItemList(data)
	if not IsEquals(self.number_txt) then return end

	local config = ShatterGoldenEggModel.getAwardConfig()
	local new_data = copy_tbl(data)
	dump(ShatterGoldenEggLogic.GetPlayMode(),"<color=red>---------new_data--------</color>")
	local tmpl = self.item_tmpl
	for k, v in ipairs(new_data) do
		local item = self:CreateItem(self.list_node, tmpl)
		self.itemList[#self.itemList + 1] = item

		local icon = item.transform:Find("Icon")
		local image = icon.transform:GetComponent("Image")
		
		if ShatterGoldenEggLogic.GetPlayMode()==0 and config[v].image_normal then
			image.sprite = GetTexture(config[v].image_normal)
		else
			image.sprite = GetTexture(config[v].image)
		end

		if 	ShatterGoldenEggLogic.GetPlayMode()==1 and config[v].image=="zjd_icon20" then
			Event.Brocast("act_ns_sprite_change",{sprite = image})
		end 
		if v == 1 then
			icon.transform.localPosition = Vector3.New(0, 10, 0)
			icon.transform.localScale = Vector3.New(0.55, 0.55, 1)
		else
			icon.transform.localPosition = Vector3.zero
			icon.transform.localScale = Vector3.New(0.45, 0.45, 1)
		end
	end

	local hammer_idx = ShatterGoldenEggLogic.GetHammer()
	local logic = ShatterGoldenEggModel.getLogicConfig(hammer_idx)
	if not logic then
		print("[SGE] FillItemList failed, getLogicConfig is invalid:" .. hammer_idx)
		return
	end
	local broken_count = ShatterGoldenEggLogic.GetBrokenCount(hammer_idx)
	--self.number_txt.text = string.format("%d 个", Mathf.Clamp(logic.respawn - broken_count, 0, logic.respawn))
	local r_count = logic.respawn-broken_count
	if r_count < 0 then
		r_count = 0
	end
	self.number_txt.text = string.format("%d/%d",r_count, logic.respawn)
end

function ShatterGoldenEggAward:ClearItemList()
	for k, v in ipairs(self.itemList) do
		if v.gameObject and IsEquals(v.gameObject) then
			GameObject.Destroy(v.gameObject)
		end
	end
	self.itemList = {}
end

function ShatterGoldenEggAward:handle_click()
	ShatterGoldenEggAward.Close()
end

function ShatterGoldenEggAward:handle_sge_close()
	ShatterGoldenEggAward.Close()
end

function ShatterGoldenEggAward:OnExitScene()
	ShatterGoldenEggAward.Close()
end
