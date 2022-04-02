-- 创建时间:2019-08-05
-- 捕鱼快捷背包

local basefunc = require "Game.Common.basefunc"

FishingMatchKJBagPanel = basefunc.class()

local C = FishingMatchKJBagPanel

C.name = "FishingMatchKJBagPanel"

function C.Create(parent, panelSelf)
	return C.New(parent, panelSelf)
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ui_get_skill_msg"] = basefunc.handler(self, self.ui_get_skill_msg)
    self.lister["ui_use_skill_call_msg"] = basefunc.handler(self, self.ui_use_skill_call_msg)
    self.lister["model_use_obj_prop"] = basefunc.handler(self, self.on_use_obj_prop)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:ClearCellList()
	self:ClearNilCellList()
    self:RemoveListener()

	 
end

function C:ctor(parent, panelSelf)

	ExtPanel.ExtMsg(self)

	self.panelSelf = panelSelf
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(self.transform, self)
    self.beginPos = Vector3.New(0, 0, 0)
    self:MyRefresh()
end
function C:MyRefresh()
	self.data = GameItemModel.GetFishingMatchBagItem(FishingModel.data.game_id)
    self.kjContent.transform.localPosition = self.beginPos

	self:ClearNilCellList()
	for i = 1, 4 do
		local pre = FishingKJBagPrefab.Create(self.kjNoContent, {}, nil, self)
		pre:RunShow()
		self.NilCellList[#self.NilCellList + 1] = pre
	end

	self:ClearCellList()
	for i = #self.data, 1, -1 do
		local v = self.data[i]
		local pre = FishingKJBagPrefab.Create(self.kjYesContent, v, C.OnToggleClick, self)
		if #self.CellList > 0 then
			pre:SetSiblingIndex( self.CellList[#self.CellList]:GetSiblingIndex() )
		end
		pre:RunShow()
		self.CellList[#self.CellList + 1] = pre
	end
	self:RefreshNillCell()
end
function C:RefreshNillCell()
	local nn = #self.data
	for i = 1, 4 do
		if i <= nn then
			self.NilCellList[i]:SetActive(false)
		else
			self.NilCellList[i]:SetActive(true)
		end
	end
end
function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			v:OnDestroy()
		end
	end
	self.CellList = {}
end
function C:ClearNilCellList()
	if self.NilCellList then
		for k,v in ipairs(self.NilCellList) do
			v:OnDestroy()
		end
	end
	self.NilCellList = {}
end

--当前是否可用
function C:CheckIsCurUse(item_key)
    local m_seat = FishingModel.GetPlayerSeat()
    local is_can = false
    local it_type = GameItemModel.GetItemTypeExt(item_key)
    if it_type == GameItemModel.ItemType.act then
        is_can = not FishingActivityManager.CheckIsActivityTime(m_seat)
    elseif it_type == GameItemModel.ItemType.cf_skill then
        is_can = true 
    end
    return is_can
end
function C:OnToggleClick(cell_self)
	dump(cell_self.config, "<color=red>OnToggleClick</color>")
	local item_key = cell_self.config.item_key
	if self:CheckIsCurUse(item_key) then
		local dd = GameItemModel.GetFishingMatchBagItem(FishingModel.data.game_id)
		local is_b = false
		if dd and next(dd) then
			for k,v in ipairs(dd) do
				if v.id == cell_self.config.id then
					is_b = true
				end
			end
		end
		if is_b then
			local data = {}
			data.msg_type = "tool"
			if cell_self.config.id then
				data.item_key = cell_self.config.id
			else
				data.item_key = item_key
			end
			Event.Brocast("model_use_skill_msg", data)
		else
			LittleTips.Create("道具不存在")
			self:MyRefresh()
		end
	else
		LittleTips.Create("当前不能使用该道具")
	end
end

function C:GetSkillNode()
	return self.skill_node.transform.position
end

function C:ui_get_skill_msg(data)
	dump(data, "<color=red>ui_get_skill_msg 11</color>")
	if data.item_key and data.item_key ~= "" then
		-- 绕逻辑
		local ids = GameItemModel.GetItemIdsToKey(data.item_key, "matchstyle")
		if not ids then
			dump(data, "<color=red>ui_get_skill_msg 22</color>")
			return
		end
		local ids_map = {}
		for k, v in ipairs(ids) do
			ids_map[v] = 1
		end
		for k,v in ipairs(self.data) do
			if ids_map[v.id] then
				ids_map[v.id] = nil
			end
		end
		local new_id
		if ids_map then
			for k, v in ipairs(ids) do
				if ids_map[v] then
					new_id = v
					break
				end
			end
		end
		if new_id then
			local cfg = GameItemModel.GetToolDataByID(new_id)
			self.data[#self.data + 1] = cfg

			local pre = FishingKJBagPrefab.Create(self.kjYesContent, cfg, C.OnToggleClick, self)
			if #self.CellList > 0 then
				pre:SetSiblingIndex( self.CellList[#self.CellList]:GetSiblingIndex() )
			end
			pre:RunShow(true)
			self.CellList[#self.CellList + 1] = pre
			self:RefreshNillCell()

			FishingAnimManager.PlayShowAndHideFX(self.transform, "UIkuang_glow", self:GetSkillNode(), 1)
		else
			print("<color=red>EEE ui_get_skill_msg 动画做完后没有出现新道具</color>")
		end
	end
end
function C:ui_use_skill_call_msg(data)
	self:MyRefresh()
end

function C:on_use_obj_prop(data)
	if data.result == 0 then
		for k,v in ipairs(self.CellList) do
			if v.config.id == data.obj_id then
				table.remove(self.CellList, k)
				table.remove(self.data, k)
			    v:OnDestroy()
			    self:RefreshNillCell()
				return
			end
		end
		self:MyRefresh()
	else
		LittleTips.Create("使用失败")
		self:MyRefresh()
	end
end
