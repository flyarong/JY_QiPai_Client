-- 创建时间:2019-08-22
-- Panel:ActivityYearJNBGetAwardListPanel
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

ActivityYearJNBGetAwardListPanel = basefunc.class()
local C = ActivityYearJNBGetAwardListPanel
C.name = "ActivityYearJNBGetAwardListPanel"

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
    self.lister["query_award_log_response"] = basefunc.handler(self, self.on_get_award_list)
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

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnCloseClick()
	end)
	self.sv = self.ScrollView:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			self:RefreshAwardLog()
		end
	end
	self.cfg_award = ActivityYearModel.UIConfig.jnb_config_award

	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self.query_index = 1
	self:RefreshAwardLog()
end

function C:CreateRankItems(data)
	if not data or not next(data) then return end
	for i,v in ipairs(data) do
		local obj = GameObject.Instantiate(self.prefab, self.content)
		local t = {}
		LuaHelper.GeneratingVar(obj.transform, t)
		
		t.name_txt.text = basefunc.deal_hide_player_name(v.player_name)
		if v.player_id == MainModel.UserInfo.user_id then
			t.name_txt.text = MainModel.UserInfo.name
		end
		if i % 2 == 0 then
			t.bg.gameObject:SetActive(false)
		else
			t.bg.gameObject:SetActive(true)
		end
		if self.cfg_award[v.award_id] then
			t.award_txt.text = self.cfg_award[v.award_id].name .. " x" .. v.award_num
		else
			t.award_txt.text = "--"
		end

		obj.gameObject:SetActive(true)
	end
end

function C:RefreshAwardLog()
	Network.SendRequest("query_award_log", {page_index = self.query_index}, "请求数据")
end
function C:on_get_award_list(_, data)
	dump(data, "<color=white>奖励列表数据</color>")
	if data.result == 0 then
		local list = data.log_data
		if not list or not next(list) then
			LittleTips.Create("暂无新数据")
			return
		end
		ActivityYearModel.CacheAwardListData(list, self.query_index)
		self.query_index = self.query_index + 1
		self:CreateRankItems(list)
	else
		local list = ActivityYearModel.GetAwardListData(self.query_index)
		if list then
			self.query_index = self.query_index + 1
			self:CreateRankItems(list)
		else
			LittleTips.Create("暂无新数据")
		end
	end
end

-- Btn
function C:OnCloseClick()
	self:MyExit()
end

