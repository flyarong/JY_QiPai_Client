-- 创建时间:2020-04-27
-- Panel:Sys_011_YueKaPanel
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

Sys_011_YueKaPanel = basefunc.class()
local C = Sys_011_YueKaPanel
C.name = "Sys_011_YueKaPanel"
local M  = Sys_011_YuekaManager
function C.Create(parent,isbig)
	return C.New(parent,isbig)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["YueKa_Got_New_Info"] = basefunc.handler(self, self.On_YueKa_Got_New_Info)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,isbig)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.black.gameObject:SetActive(not(not isbig))
	self.close_btn.gameObject:SetActive(not(not isbig))
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:On_YueKa_Got_New_Info()
	Network.SendRequest("query_new_yueka_base_info")
end

function C:InitUI()
	self.bug_small_btn.onClick:AddListener(
		function()
			M.BuySmallYueKa()
		end
	)
	self.bug_big_btn.onClick:AddListener(
		function()
			M.BuyBigYueKa()
		end
	)
	self.get_award_btn.onClick:AddListener(
		function ()
			M.GetBigYueKaAward()
		end
	)
	self.get2_award_btn.onClick:AddListener(
		function ()
			M.GetBigYueKaAward()
		end
	)
	self.close_btn.onClick:AddListener(function ()
		self:MyExit()
	end)
	self.help_btn.onClick:AddListener(
		function ()
			LTTipsPrefab.Show(self.help_btn.gameObject.transform,1,"每日首次救济金多领8888鲸币")
		end
	)
	self.jika_btn.onClick:AddListener(function ()
		Act_004JIKAPanel.Create()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	local data = M.GetMainData()
	if (not data) or (not IsEquals(self.gameObject)) then return end
	if data.total_remain_num_2 >= 1  then
		if IsEquals(self.jika_node) then
			self.jika_node.gameObject:SetActive(true)
		end
		if IsEquals(self.Big) then
			self.Big.gameObject:SetActive(false)
		end
	else
		if IsEquals(self.jika_node) then
			self.jika_node.gameObject:SetActive(false)
		end
		if IsEquals(self.Big) then
			self.Big.gameObject:SetActive(true)
		end
	end
	self.Big.gameObject:SetActive(true)
	self.jika_node.gameObject:SetActive(false)
end

function C:OnDestroy()
	self:MyExit()
end

function C:On_YueKa_Got_New_Info()
	local data = M.GetMainData()
	dump(data,"<color=red>新版月卡数据</color>")
	if data and IsEquals(self.gameObject) then
		if IsEquals(self.s_remain_txt) then
			self.s_remain_txt.text = data.total_remain_num_1
		end
		self.b_remain_txt.text = data.total_remain_num_2
		self.b2_remain_txt.text = data.total_remain_num_2
		if data.total_remain_num_1 == 0 then
			self.s_remain_txt.text = 30 -- 用完了就重置为30次
			self.s_mask.gameObject:SetActive(false)
			self.bug_small_btn.gameObject:SetActive(true)
		else
			self.s_mask.gameObject:SetActive(true)
			self.bug_small_btn.gameObject:SetActive(false)
		end
		if data.total_remain_num_2 == 0 then
			self.b_remain_txt.text = 30 -- 用完了就重置为30次
			self.b2_remain_txt.text = 30
			self.b_mask.gameObject:SetActive(false)
			self.bug_big_btn.gameObject:SetActive(true)
			self.get_award_btn.gameObject:SetActive(false)
		else
			self.bug_big_btn.gameObject:SetActive(false)
			if data.is_receive_2  == 1 then
				self.b_mask.gameObject:SetActive(true)
				self.get_award_btn.gameObject:SetActive(false)
				self.mask2.gameObject:SetActive(true)
			else
				self.b_mask.gameObject:SetActive(false)
				self.get_award_btn.gameObject:SetActive(true)
				self.mask2.gameObject:SetActive(false)
			end
		end
	
	end
end

function C:AssetsGetPanelConfirmCallback()
	self:MyRefresh()
end