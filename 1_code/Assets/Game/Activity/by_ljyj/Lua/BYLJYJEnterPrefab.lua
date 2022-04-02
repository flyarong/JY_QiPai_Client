-- 创建时间:2019-09-25
-- Panel:BYLJYJEnterPrefab
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

BYLJYJEnterPrefab = basefunc.class()
local M = BYLJYJEnterPrefab
M.name = "BYLJYJEnterPrefab"

function M.Create(parent, cfg)
	return M.New(parent, cfg)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
	self.lister = {}
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.handle_task_change)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function M:OnDestroy(  )
	self:MyExit()
end

function M:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("BYLJYJEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function M:InitUI()
	self:SetEnterBtn()
	self:MyRefresh()
end

function M:MyRefresh()
	
end

function M:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	FishingEventAddGlod.Create()
end

function M:OnDestroy()
	self:MyExit()
end

function M:handle_one_task_data_response(_, data)
	if data.id ~= BYLJYJManager.GetTask() then return end
	--累计赢金
	local cfg = BYLJYJManager.GetConfig()
	local count = #cfg.stage or 6
	local task_data = {}
	task_data = data
	task_data.award_status_all = basefunc.decode_task_award_status(task_data.award_get_status)
	task_data.award_status_all = basefunc.decode_all_task_award_status(task_data.award_status_all,task_data,count)
	self:RefreshEnterBtn(task_data)
end

function M:handle_task_change(_, data)
	if data.id ~= BYLJYJManager.GetTask() then return end
	local cfg =  BYLJYJManager.GetConfig()
	local count = #cfg.stage or 6
	local task_data = {}
	task_data = data
	task_data.award_status_all = basefunc.decode_task_award_status(task_data.award_get_status)
	task_data.award_status_all = basefunc.decode_all_task_award_status(task_data.award_status_all,task_data,count)
	self:RefreshEnterBtn(task_data)
end

function M:SetEnterBtn()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
		self:OnEnterClick()
	end)

	local cur_scene = MainLogic.GetCurSceneName() --根据场景进行不同设置
	if cur_scene == GameConfigToSceneCfg.game_FishingHall.SceneName then
		
	elseif cur_scene == GameConfigToSceneCfg.game_Fishing.SceneName then
		
	end
	self.add_gold_can_get = self.enter_btn.transform:Find("can_get")
	Network.SendRequest("query_one_task_data", {task_id = BYLJYJManager.GetConfig()})
	self.enter_btn.gameObject:SetActive(true)
end

function M:RefreshEnterBtn(data)
	if not IsEquals(self.enter_btn) then return end
	for i,v in ipairs(data.award_status_all) do
		if v == 1 then
			--有可领取奖励
			if not IsEquals(self.add_gold_can_get) then
				self.add_gold_can_get = self.enter_btn.transform:Find("can_get")
			end
			if IsEquals(self.add_gold_can_get) then
			self.add_gold_can_get.gameObject:SetActive(true)
			end
			return
		end
	end
	if not IsEquals(self.add_gold_can_get) then
		self.add_gold_can_get = self.enter_btn.transform:Find("can_get")
	end
	if IsEquals(self.add_gold_can_get) then
		self.add_gold_can_get.gameObject:SetActive(false)
	end
end