-- 创建时间:2021-01-04
-- Panel:Act_Ty_Collect_WordsPanel
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

Act_Ty_Collect_WordsPanel = basefunc.class()
local C = Act_Ty_Collect_WordsPanel
C.name = "Act_Ty_Collect_WordsPanel"
local M = Act_Ty_Collect_WordsManager

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["ty_collect_activity_exchange_response_msg"] = basefunc.handler(self,self.on_ty_collect_activity_exchange_response_msg)
    self.lister["ty_collect_finish_gift_shop_msg"] = basefunc.handler(self,self.on_ty_collect_finish_gift_shop_msg)
    self.lister["ty_collect_day_is_change_msg"] = basefunc.handler(self,self.on_ty_collect_day_is_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:CloseCollectPanel()
	self:CloseBottomItem()
	self:CloseGiftPanel()
	self:ClosePagePrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	local sta_t = M.GetStart_t()
	local end_t = M.GetEnd_t()
	self.hint_time_txt.text = "活动时间：".. sta_t .."-".. end_t
	self.cur_txt.text = "当前拥有"..M.config.other_data[1].item_name..":"
	self:MyRefresh()
end


function C:MyRefresh()
	self:CreatePagePrefab()
	self:RefreshSelet()
	self:CreateGiftPanel()
	self:CreateBottomItem()
	self:CreateCollectPanel()
end

function C:OnBackClick()
	self:MyExit()
end

function C:CreatePagePrefab()
	self:ClosePagePrefab()
	self.GiftCfg = M.GetGiftCfg()
	dump(self.GiftCfg,"<color=yellow><size=15>++++++++++self.GiftCfg++++++++++</size></color>")
	for i=10437,10440 do
		dump({data = MainModel.GetGiftDataByID(i),id = i},"<color=yellow><size=15>++++++++++status++++++++++</size></color>")
	end
	
	for i=1,#self.GiftCfg do
		local pre = Act_Ty_Collect_WordsLeftPage.Create(self,self.left_content.transform,i,self.GiftCfg[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:ClosePagePrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:Selet(index)
	if index > #self.GiftCfg then
		index = 1
	end
	self:RefreshSelet(index)
	self:CreateGiftPanel(index)
end

function C:RefreshSelet(index)
	local index = index or 1
	for k,v in pairs(self.spawn_cell_list) do
		v:RefreshSelet(index)	
	end
end

function C:CreateGiftPanel(index)
	local index = index or 1
	self:CloseGiftPanel()
	self.gift_pre = Act_Ty_Collect_WordsGiftPanel.Create(self.node_gift.transform,self.GiftCfg[index])
end

function C:CloseGiftPanel()
	if self.gift_pre then
		self.gift_pre:MyExit()
		self.gift_pre = nil
	end
end

function C:CreateBottomItem()
	self:CloseBottomItem()
	for i=1,#M.config.other_data[1].item_key do
		local pre = GameObject.Instantiate(self.item,self.cur_item_node.transform)
		pre.gameObject:SetActive(true)
		pre.transform:Find("@item_img").transform:GetComponent("Image").sprite = GetTexture(GameItemModel.GetItemToKey(M.config.other_data[1].item_key[i]).image)
		pre.transform:Find("@item_txt").transform:GetComponent("Text").text = "x"..GameItemModel.GetItemCount(M.config.other_data[1].item_key[i])
		self.bottom_pre_list[#self.bottom_pre_list + 1] = pre
	end
end

function C:CloseBottomItem()
	if self.bottom_pre_list then
		for k,v in pairs(self.bottom_pre_list) do
			Destroy(v.gameObject)
		end
	end
	self.bottom_pre_list = {}
end

function C:CreateCollectPanel()
	self:CloseCollectPanel()
	self.collect_pre = Act_Ty_Collect_WordsCollectPanel.Create(self.node_collect.transform)
end

function C:CloseCollectPanel()
	if self.collect_pre then
		self.collect_pre:MyExit()
		self.collect_pre = nil
	end
end

function C:on_ty_collect_activity_exchange_response_msg()
	self:CreateBottomItem()
	self:CreateCollectPanel()
end

function C:on_ty_collect_finish_gift_shop_msg()
	self:MyRefresh()
end

function C:on_ty_collect_day_is_change_msg()
	self:MyRefresh()
end