-- 创建时间:2020-03-09
-- Panel:BYKJBagPanel
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


local basefunc = require "Game.Common.basefunc"
ext_require("Game.normal_fishing_common.Lua.BYKJBagPrefab")

BYKJBagPanel = basefunc.class()

local C = BYKJBagPanel

C.name = "BYKJBagPanel"

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

    self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
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
	self.panelSelf = panelSelf
	local obj = newObject("by_kj_bag_panel", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero

	self:MakeLister()
    self:AddMsgListener()

    self.scr = self.ScrollView:GetComponent("RectTransform")

    -- 购买道具的花费
    self.buy_item_hf = {
    	-- prop_fish_secondary_bomb_1 = 20000,
    	-- prop_fish_super_bomb_1 = 50000,
    	prop_fish_secondary_bomb_2 = 100000,
    	prop_fish_super_bomb_2 = 500000,
    	prop_fish_secondary_bomb_3 = 1000000,
    	prop_fish_super_bomb_3 = 3000000,
    }
    self.buy_item_hf_cd = 3 * 60 -- 3分钟

    self.bag_jt_btn.onClick:AddListener(function ()
    	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnJTClick()
	end)
    self.is_tc_st = false

    self:MyRefresh()
end
function C:RefreshTC()
	if self.is_tc_st then
		self.scr.sizeDelta = {x = 758, y = 168}
		self.bag_jt_btn.transform.localPosition = Vector3.New(-894, 0, 0)
		self.bag_jt_node.transform.localPosition = Vector3.New(88, 0, 0)
		self.bag_jt_node.localScale = Vector3.one
	else
		self.kjContent.localPosition = Vector3.zero
		self.scr.sizeDelta = {x = 160, y = 168}
		self.bag_jt_btn.transform.localPosition = Vector3.New(-140, 0, 0)
		self.bag_jt_node.transform.localPosition = Vector3.New(-88, 0, 0)
		self.bag_jt_node.localScale = Vector3.New(-1, 1, 1)
	end
end
function C:MyRefresh()
    -- 锁头(强制显示在前面，不管有没有这个道具)
    self.lock_head = {}
    self.lock_head_map = {}
    self.min_len = 0
    -- 浅水湾 体验场 没有常驻原子弹
    if FishingModel.data.game_id ~= 4 and FishingModel.data.game_id ~= 1 then
    	local key = "prop_fish_super_bomb_" .. FishingModel.data.game_id
    	self.lock_head[#self.lock_head + 1] = key
    	self.lock_head_map[key] = 1
    	key = "prop_fish_secondary_bomb_" .. FishingModel.data.game_id
    	self.lock_head[#self.lock_head + 1] = key
    	self.lock_head_map[key] = 2
    	self.min_len = 2
    end

	self.data = {}
	for k,v in ipairs(self.lock_head) do
		self.data[#self.data + 1] = {item_key = v, num=0}
	end
	local buf = GameItemModel.GetFishingBagItem(FishingModel.data.game_id)
	dump(buf, "<color=red>EE 捕鱼背包数据</color>")
	for k,v in ipairs(buf) do
		if not v.game_id or v.game_id == FishingModel.data.game_id then
			if self.lock_head_map[v.item_key] then
				self.data[ self.lock_head_map[v.item_key] ].num = v.num
			else
				self.data[#self.data + 1] = v
			end
		end
	end
    self.kjContent.transform.localPosition = Vector3.zero

	self:ClearNilCellList()
	for i = 1, self.min_len do
		local pre = BYKJBagPrefab.Create(self.kjNoContent, nil, nil, self)
		pre:RunShow()
		self.NilCellList[#self.NilCellList + 1] = pre
	end

	self:ClearCellList()
	for i = 1, #self.data do
		local v = self.data[i]
		local pre = BYKJBagPrefab.Create(self.kjYesContent, v, C.OnToggleClick, self)
		pre:RunShow()
		self.CellList[#self.CellList + 1] = pre
	end
	self:RefreshNillCell()
	self:RefreshTC()
end
function C:RefreshNillCell()
	local nn = #self.data
	for i = 1, self.min_len do
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

function C:OnJTClick()
	self.is_tc_st = not self.is_tc_st
	self:RefreshTC()
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
    elseif it_type == GameItemModel.ItemType.skill then
    	is_can = FishingModel.CheckIsCanUseSkill(item_key)
    end
    return is_can
end
function C:OnToggleClick(cell_self)
	dump(cell_self.config, "<color=red>OnToggleClick</color>")
	dump(cell_self.item_cfg, "<color=red>OnToggleClick</color>")
	local item_key = cell_self.item_cfg.item_key
	local nn = GameItemModel.GetItemCount(item_key)
	dump(nn)
	if self:CheckIsCurUse(item_key) then
		local userdata = FishingModel.GetPlayerData()
		if nn > 0 or (self.buy_item_hf[item_key] and self.buy_item_hf[item_key] <= userdata.base.score) then
			local data = {}
			data.msg_type = "tool"
			if cell_self.config.id then -- obj道具
				data.item_key = cell_self.config.id
			else
				data.item_key = item_key
			end
			Event.Brocast("model_use_skill_msg", data)
		else
			if self.buy_item_hf[item_key] and self.buy_item_hf[item_key] > userdata.base.score then
				Event.Brocast("show_gift_panel")
			else
				LittleTips.Create("道具不存在")
				self:MyRefresh()
			end
		end
	else
		LittleTips.Create("当前不能使用该道具")
	end
end

function C:GetSkillNode()
	return self.skill_node.transform.position
end

function C:ui_get_skill_msg(data)
	if data.type == FishingSkillManager.FishDeadAppendType.ppc_cjzd then
		data.item_key = self.lock_head[2]
	elseif data.type == FishingSkillManager.FishDeadAppendType.ppc_gjzd then
		data.item_key = self.lock_head[1]
	end
	dump(data, "<color=red>ui_get_skill_msg 11</color>")
	if data.item_key and data.item_key ~= "" then
		self:MyRefresh()
	end
end
function C:ui_use_skill_call_msg(data)
	self:MyRefresh()
end

function C:on_use_obj_prop(data)
	if data.result == 0 then
		for k,v in ipairs(self.CellList) do
			if v.config.id and v.config.id == data.item then
				table.remove(self.CellList, k)
				table.remove(self.data, k)
			    v:OnDestroy()
				return
			elseif not v.config.id and v.config.item_key == data.item then
				if self.data[k].num > 0 then
					self.data[k].num = self.data[k].num - 1
				end
				if self.data[k].num == 0 and not self.buy_item_hf[data.item] then
					table.remove(self.CellList, k)
					table.remove(self.data, k)
				    v:OnDestroy()					
				else
					if self.buy_item_hf[data.item] then
						PlayerPrefs.SetInt(MainModel.UserInfo.user_id .. data.item, os.time())
					    v:UpdateData(self.data[k])
					else
					    v:UpdateData(self.data[k])
					end
				end
			    return
			end
		end
		self:MyRefresh()
	else
		if self.buy_item_hf[data.item] then
			Event.Brocast("show_gift_panel")
		else
			LittleTips.Create("使用失败")
			self:MyRefresh()
		end
	end
end
function C:OnAssetChange(data)
	local is_up = false
	if data.change_type == "task_p_cumulative_recharge" and data.data then
        for k,v in ipairs(data.data) do
        	if self.lock_head_map[v.asset_type] then
        		is_up = true
        		break
        	end
        end
	end
	if is_up then
		self:MyRefresh()
	end
end