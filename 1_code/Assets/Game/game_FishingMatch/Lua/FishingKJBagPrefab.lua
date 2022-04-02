-- 创建时间:2019-08-05
-- Panel:FishingKJBagPrefab
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
 --]]

local basefunc = require "Game/Common/basefunc"

FishingKJBagPrefab = basefunc.class()
local C = FishingKJBagPrefab
C.name = "FishingKJBagPrefab"

function C.Create(parent_transform, config, call, panelSelf)
	return C.New(parent_transform, config, call, panelSelf)
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

function C:MyExit()
	if self.run_time then
		self.run_time:Stop()
		self.run_time = nil
	end
	self:RemoveListener()
end

function C:ctor(parent_transform, config, call, panelSelf)
	self.config = config
	self.call = call
	self.panelSelf = panelSelf

	local obj = newObject(C.name, parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.rect_tr = tran:GetComponent("RectTransform")
	self.skill_btn.onClick:AddListener(function ()
		self:OnClick()
	end)
	self.max_w = 152
	self.transform.localScale = Vector3.New(0, 1, 1)
	self.rect_tr.sizeDelta = {x=0, y=0}
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	if self.config.item_key then
		self.nilImage.gameObject:SetActive(false)
		self.icon_img.gameObject:SetActive(true)
		local item_cfg = GameItemModel.GetItemToKey(self.config.item_key)
		GetTextureExtend(self.icon_img, item_cfg.image, item_cfg.is_local_icon)
		if self.config.bullet_index then
		    local gun_config = FishingModel.GetGunCfg(self.config.bullet_index)
		    if gun_config then
		    	self.DescRect.gameObject:SetActive(true)
		    	self.desc_txt.text = gun_config.gun_rate .. "倍"
		    else
		    	self.DescRect.gameObject:SetActive(false)
		    end
		elseif self.config.fish_rate then
			self.DescRect.gameObject:SetActive(true)
	    	self.desc_txt.text = self.config.fish_rate .. "倍"
		else
			self.DescRect.gameObject:SetActive(false)
		end
	else
		self.nilImage.gameObject:SetActive(true)
		self.icon_img.gameObject:SetActive(false)
		self.DescRect.gameObject:SetActive(false)
	end
end

function C:OnDestroy()
	self:MyExit()
	destroy(self.gameObject)
end

function C:SetSiblingIndex(index)
	if IsEquals(self.gameObject) then
		self.transform:SetSiblingIndex(index)
	end
end
function C:GetSiblingIndex()
	if IsEquals(self.gameObject) then
		return self.transform:GetSiblingIndex()
	end
	return 1
end
function C:SetActive(b)
	return self.gameObject:SetActive(b)
end

-- 是否带动画
function C:RunShow(isanim)
	self.is_anim_finish = false
	if isanim then
		if self.run_time then
			self.run_time:Stop()
			self.run_time = nil
		end

		self.rr = 0
		self.scale = {x=self.rr, y=1, z=1}
		self.run_time = Timer.New(function ()
			self.rr = self.rr + 0.1
			if self.rr >= 1 then
				self.rr = 1
				self.run_time:Stop()
				self.run_time = nil
				self:RunFinish()
			end
			self.scale.x = self.rr
			self.transform.localScale = self.scale
			self.rect_tr.sizeDelta = {x=self.max_w * self.rr, y=0}
		end, 0.03, -1)
		self.run_time:Start()
	else
		self.transform.localScale = Vector3.New(1, 1, 1)
		self.rect_tr.sizeDelta = {x=self.max_w, y=0}
		self:RunFinish()
	end
end
function C:RunFinish()
	self.is_anim_finish = true
end

function C:OnClick()
	if self.call then
		self.call(self.panelSelf, self)
	end
end
function C:SetCellIndex(cell_index)
	self.cell_index = cell_index
end
