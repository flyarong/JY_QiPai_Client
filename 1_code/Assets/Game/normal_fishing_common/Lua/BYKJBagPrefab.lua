-- 创建时间:2020-03-09
-- Panel:BYKJBagPrefab
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

BYKJBagPrefab = basefunc.class()
local C = BYKJBagPrefab
C.name = "BYKJBagPrefab"

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
	self:StopDJS()
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

	local obj = newObject("by_kj_bag_prefab", parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.rect_tr = tran:GetComponent("RectTransform")
	self.skill_btn = self.icon_img.transform:GetComponent("Button")
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
function C:UpdateData(data)
	self.config = data
	self.cur_cd = cd
	self.max_cd = cd
	self:MyRefresh()
end
function C:MyRefresh()
	if self.config then
		self.icon_img.gameObject:SetActive(true)
		self.item_cfg = GameItemModel.GetItemToKey(self.config.item_key)
		if self.config.num <= 0 and self.panelSelf.buy_item_hf[self.config.item_key] then
			self.desc_txt.text = StringHelper.ToCash( self.panelSelf.buy_item_hf[self.config.item_key] )
		else
			self.desc_txt.text = self.config.num
		end
		if self.item_cfg then
			GetTextureExtend(self.icon_img, self.item_cfg.image, self.item_cfg.is_local_icon)
		else
			dump(self.config, "<color=red>道具不存在</color>")
		end
	else
		self.icon_img.gameObject:SetActive(false)
		self.DescRect.gameObject:SetActive(false)
	end
	self:RefreshCD()
end
function C:RefreshCD()
	self.cur_cd = nil
	self.max_cd = self.panelSelf.buy_item_hf_cd
	if self.config then
		local s = PlayerPrefs.GetInt(MainModel.UserInfo.user_id .. self.config.item_key, 0)
		if s > 0 and (s + self.max_cd) > os.time() then
			self.cur_cd = (s + self.max_cd) - os.time()
		end
	end

	self:StopDJS()
	if self.cur_cd then
		self.cd_img.gameObject:SetActive(true)
		self.update_time = Timer.New(function ()
	    	self:UpdateTime()
	    end, 1, -1, nil, true)
	    self:UpdateTime(true)
	    self.update_time:Start()
	else
		self.cd_img.gameObject:SetActive(false)
		self:StopDJS()
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

function C:StopDJS()
	if self.update_time then
		self.update_time:Stop()
	end
	self.update_time = nil
end
function C:UpdateTime(b)
	if not b then
		if self.cur_cd then
			self.cur_cd = self.cur_cd - 1
		end
	end
	if not self.cur_cd or self.cur_cd <= 0 then
		self:MyRefresh()
	else
	    self.cd_img.fillAmount = self.cur_cd / self.max_cd
	end
end


