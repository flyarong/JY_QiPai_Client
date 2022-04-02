-- 创建时间:2020-11-02
-- Panel:Act_051_YBWLGamePanel
--[[ *	  ┌─┐	   ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │				 │
 *   │	   ───	   │
 *   │  ─┬┘	   └┬─  │
 *   │				 │
 *   │	   ─┴─	   │
 *   │				 │
 *   └───┐		 ┌───┘
 *	   │		 │
 *	   │		 │
 *	   │		 │
 *	   │		 └──────────────┐
 *	   │						│
 *	   │						├─┐
 *	   │						┌─┘
 *	   │						│
 *	   └─┐  ┐  ┌───────┬──┐  ┌──┘
 *		 │ ─┤ ─┤	   │ ─┤ ─┤
 *		 └──┴──┘	   └──┴──┘
 *				神兽保佑
 *			   代码无BUG!
 --]]
local basefunc = require "Game/Common/basefunc"

Act_051_YBWLGamePanel = basefunc.class()
local C = Act_051_YBWLGamePanel
C.name = "Act_051_YBWLGamePanel"
local M = Act_051_YBWLManager
local help_info = {
	"1.购买礼包后激活任务，完成任务领取奖励",
	"2.购买礼包后立即获得礼包奖励，任务奖励需在10日内完成并领取，过期重置",
	"3.可同时购买多个礼包，激活多个消耗任务，可获得最大利益",
	"4.敲敲乐中换挡消耗鲸币不统计",
}

local order_data = {
	[1] = "canget_item",
	[2] = "cannot_item",
	[3] = "allready_item",
}
local index_data = {

}
function C.Create()
	return C.New()
end

function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["ybwl_gift_had_buy_msg"] = basefunc.handler(self, self.on_ybwl_gift_had_buy_msg)
	self.lister["ybwl_base_data_is_get_msg"] = basefunc.handler(self, self.on_ybwl_base_data_is_get_msg)
	self.lister["ybwl_task_has_change_msg"] = basefunc.handler(self, self.on_ybwl_task_has_change_msg)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:StopTimer()
	self:CloseItemPrefab()
	self:CloseRightPrefab()
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

	self.sv = self.right_node:GetComponent("ScrollRect")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	--M.QueryBaseTaskData()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OnHelpClick)
	EventTriggerListener.Get(self.buy_btn.gameObject).onClick = basefunc.handler(self, self.OnBuyClick)
	EventTriggerListener.Get(self.get_now_btn.gameObject).onClick = basefunc.handler(self, self.OnGetNowClick)
	self.BaseCfg = M.GetBaseCfg()
	self.index = 1
	self:CreateItemPrefab()

	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshSelet()
	self:RefreshBuyBtn()
	self:CreateRightPrefab()
	self:RefreshNow()
	self:CheckDJS()
	self:RefreshYG()
end

function C:OnBackClick()
	self:MyExit()
end

function C:OnHelpClick()
	self:OpenHelpPanel()
end

function C:OpenHelpPanel()
	local str = help_info[1]
	for i = 2, #help_info do
		str = str .. "\n" .. help_info[i]
	end
	self.introduce_txt.text = str
	IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

local m_sort1 = function(v1, v2)
	if v1.price < v2.price then
		return true
	end
end

function C:CreateItemPrefab()
	--if M.IsV5toV12() then
		--MathExtend.SortListCom(self.BaseCfg, m_sort1)
	--end
	self:CloseItemPrefab()
	for i = 1, #self.BaseCfg do
		local pre = Act_051_YBWLLeftPage.Create(self, self.Content_left.transform, i, self.BaseCfg[i])
		self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k, v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

function C:RefreshSelet()
	self.index = self.index or 1
	for k, v in pairs(self.spawn_cell_list) do
		v:RefreshSelet(self.index)
	end
end

function C:Selet(index)
	if index > #self.BaseCfg then
		index = 1
	end
	self.index = index

	self:MyRefresh()
	self.sv.verticalNormalizedPosition = 1
end

function C:AutoSetSibling(_type, obj)
	index_data[_type] = index_data[_type] or 0
	index_data[_type] = index_data[_type] + 1
	local index = 0
	for i = 1, #order_data do
		if _type == order_data[i] then
			obj.transform:SetSiblingIndex(index + index_data[_type] - 1)
			return
		else
			index = index + self:GetItemIndex(order_data[i])
		end
	end
end

function C:GetItemIndex(_type)
	index_data[_type] = index_data[_type] or 0
	return index_data[_type]
end

function C:CreateRightPrefab()
	local data = M.GetBaseCfg()
	index_data = {}
	--dump(data, "<color=red>FFFFFFFFFFFFFFFFFFFFFFFFFF</color>")
	local tab = M.GetTaskAwardStatus(data[self.index].task_id, 7)
	if not table_is_null(tab) then
		data[self.index].award_status = {}
		for i = 1, #tab do
			data[self.index].award_status[#data[self.index].award_status + 1] = tab[i]
		end
	end
	self:CloseRightPrefab()
	--dump(data[self.index], "<color=yellow><size=15>++++++++++data++++++++++</size></color>")
	for i = 1, 7 do
		local pre = Act_051_YBWLItemBase.Create(self, self.Content_right.transform, i, data[self.index])
		self.spawn_right_list[#self.spawn_right_list + 1] = pre
		if not table_is_null(tab) then
			self:AutoSetSibling(pre:GetOrderType(), pre.gameObject)
		end
	end



	-- for i=1,#self.spawn_right_list do
	-- 	if self.spawn_right_list[i]:CheckStatusIs2() then
	-- 		self.spawn_right_list[i].transform:SetAsLastSibling()
	-- 	end
	-- end
end

function C:CloseRightPrefab()
	if self.spawn_right_list then
		for k, v in ipairs(self.spawn_right_list) do
			v:MyExit()
		end
	end
	self.spawn_right_list = {}
end

function C:RefreshBuyBtn()
	if M.CheckGiftWasBought(self.BaseCfg[self.index].gift_id) then--买过了
		self.price_txt.text = "本期已购"
	else
		self.price_txt.text = self.BaseCfg[self.index].price .. "元"
	end
end

function C:OnBuyClick()
	if M.CheckGiftWasBought(self.BaseCfg[self.index].gift_id) then--买过了
		LittleTips.Create("本期该礼包您已购买")
	else
		self:BuyShop(self.BaseCfg[self.index].gift_id)
	end
end

function C:BuyShop(shopid)
	--dump(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	--dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({ desc = "请前往公众号获取" })
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:RefreshNow()
	self.award_now_txt.text = StringHelper.ToCash(self.BaseCfg[self.index].award_now)
	if M.CheckGiftWasBought(self.BaseCfg[self.index].gift_id) then--买过了
		--[[if PlayerPrefs.GetInt("YBWL"..MainModel.UserInfo.user_id..self.BaseCfg[self.index].gift_id,0) == 0 then--0未手动领取,1已手动领取 
			self.get_now_btn.gameObject:SetActive(true)
			self.already_now_img.gameObject:SetActive(false)
		else
			self.get_now_btn.gameObject:SetActive(false)
			self.already_now_img.gameObject:SetActive(true)
		end--]]
		self.get_now_btn.gameObject:SetActive(false)
		self.already_now_img.gameObject:SetActive(true)
	else
		self.get_now_btn.gameObject:SetActive(true)
		self.already_now_img.gameObject:SetActive(false)
	end
end

function C:OnGetNowClick()
	if M.CheckGiftWasBought(self.BaseCfg[self.index].gift_id) then--买过了
		--奖励弹窗
		--[[		PlayerPrefs.SetInt("YBWL"..MainModel.UserInfo.user_id..self.BaseCfg[self.index].gift_id,1)
		local tab = {}
		tab.change_type = "buy_gift_bag_"..self.BaseCfg[self.index].gift_id
		tab.data = {}
		tab.data[1] = {}
		tab.data[1].asset_type = "jing_bi"
		tab.data[1].value = self.BaseCfg[self.index].award_now
		dump(tab,"<color=yellow><size=15>++++++++++data++++++++++</size></color>")
		Event.Brocast("AssetGet",tab)--]]
		self:MyRefresh()
	else
		self:OnBuyClick()
	end
end

function C:CheckDJS()
	if M.CheckGiftWasBought(self.BaseCfg[self.index].gift_id) and self.BaseCfg[self.index].gift_id ~= 10390 and self.BaseCfg[self.index].gift_id ~= 10391 then--买过了
		self.value_time = M.GetGiftValueTime(self.index) - os.time()
		self.djs_txt.gameObject:SetActive(true)
		self:StartDJSTimer(true)
	else
		self.djs_txt.gameObject:SetActive(false)
	end
end

function C:StartDJSTimer(b)
	self:StopTimer()
	if b then
		self:RefreshDJS()
		self.timer = Timer.New(function()
			self.value_time = self.value_time - 1
			self:RefreshDJS()
		end, 1, -1, false)
		self.timer:Start()
	end
end

function C:StopTimer()
	if self.timer then
		self.timer:Stop()
		self.timer = nil
	end
end

function C:RefreshDJS()
	local temp = 0
	local day = 0
	local hour = 0
	local minute = 0
	local second = 0
	temp = self.value_time
	day = math.floor(temp / 86400)
	hour = math.floor((temp - day * 86400) / 3600)
	minute = math.floor((temp - day * 86400 - hour * 3600) / 60)
	second = temp - day * 86400 - hour * 3600 - minute * 60
	--dump({temp = temp,hour = hour, minute = minute},"<color=red>--------////-----------</color>")
	if string.len(hour) == 1 then
		hour = "0" .. hour
	end
	if string.len(minute) == 1 then
		minute = "0" .. minute
	end
	if string.len(second) == 1 then
		second = "0" .. second
	end
	self.djs_txt.text = "本期剩余时间:   " .. day .. "天" .. hour .. ":" .. minute .. ":" .. second
end

function C:on_ybwl_gift_had_buy_msg()
	self:MyRefresh()
end

function C:on_ybwl_task_has_change_msg()
	dump("<color=red>-----on_ybwl_task_has_change_msg------</color>")
	self:MyRefresh()
end

function C:on_ybwl_base_data_is_get_msg()
	self:MyRefresh()
end

--刷新已购
function C:RefreshYG()
	local tab_bought = {}
	local tab_no_bought = {}
	local ids = M.GetGiftIdsList()
	for k, v in pairs(ids) do
		if M.CheckGiftWasBought(v) then
			tab_bought[#tab_bought + 1] = v
		else
			tab_no_bought[#tab_no_bought + 1] = v
		end
	end
	dump(tab_bought, "<color=yellow><size=15>++++++++++tab_bought++++++++++</size></color>")
	dump(tab_no_bought, "<color=yellow><size=15>++++++++++tab_no_bought++++++++++</size></color>")
	for i = 1, #tab_bought do
		for j = 1, #M.config.base_info do
			if tab_bought[i] == M.config.base_info[j].gift_id then
				self.spawn_cell_list[j].transform:Find("@yg").gameObject:SetActive(true)
			end
		end
	end
	for i = 1, #tab_no_bought do
		for j = 1, #M.config.base_info do
			if tab_no_bought[i] == M.config.base_info[j].gift_id then
				self.spawn_cell_list[j].transform:Find("@yg").gameObject:SetActive(false)
			end
		end
	end
end