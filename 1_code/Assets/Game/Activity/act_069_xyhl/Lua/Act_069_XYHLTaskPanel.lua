-- 创建时间:2021-11-09
-- Panel:Act_069_XYHLTaskPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

Act_069_XYHLTaskPanel = basefunc.class()
local C = Act_069_XYHLTaskPanel
C.name = "Act_069_XYHLTaskPanel"
local M = Act_069_XYHLManager

function C.Create(parent, cfgIndex)
	return C.New(parent, cfgIndex)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_xyhl_task_change_msg"] = basefunc.handler(self,self.on_model_xyhl_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	-- dump("<color=white>SSSSSSSSSSSSSSSSSSSS</color>")
	for i = 1, #self.taskItems do
		destroy(self.taskItems[i].obj.gameObject)
	end
	self.taskItems = nil
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent, cfgIndex)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.key = M.panel_cfg[cfgIndex].key
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:InitTaskContent()
	self:RefreshTaskContent()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:InitTaskContent()
	dump(self.task_cfg, "task_cfg")
	dump(self.key, "key")
	self.task_cfg = M.GetTaskConfig(self.key)
	self.taskItems = {}
	for i = 1, #self.task_cfg do
		local _obj = GameObject.Instantiate(self.task_item, self.t_content)
		local _ui = {}
		_obj.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(_obj.transform, _ui)
		_ui.task_slider = _ui.task_slider:GetComponent("Slider")
		self.taskItems[#self.taskItems + 1] = {obj = _obj, ui = _ui}
	end
end

function C:RefreshTaskContent()
	self.task_cfg = M.GetTaskConfig(self.key)
	for i = 1, #self.task_cfg do
		local cfg = self.task_cfg[i]
		local taskItem = self.taskItems[i]
		local data = M.GetTaskData(cfg.task_id)
		local state 
		local need_process
		taskItem.ui.get_btn.onClick:RemoveAllListeners()
		if cfg.task_lv then
			state = data.state[cfg.task_lv]
			need_process = cfg.task_total
			taskItem.ui.get_btn.onClick:AddListener(function()
				Network.SendRequest("get_task_award_new", {id = cfg.task_id, award_progress_lv = cfg.task_lv})
			end)
		else
			state = data.state
			need_process = data.need_process
			taskItem.ui.get_btn.onClick:AddListener(function()
				Network.SendRequest("get_task_award", {id = cfg.task_id})
			end)
		end

		taskItem.ui.task_desc_txt.text = cfg.task_desc
		taskItem.ui.task_award_img.sprite = GetTexture(cfg.award_img)
		taskItem.ui.task_award_txt.text = "x" .. cfg.award_txt
 		taskItem.ui.get_btn.gameObject:SetActive(state == 1)
		taskItem.ui.geted.gameObject:SetActive(state == 2)
		taskItem.ui.in_task.gameObject:SetActive(state == 0)
		local show_total_process = data.now_total_process
		if self.key == "czfl" then
			show_total_process = show_total_process / 100
		end

		if cfg.task_id == 100038 then
			taskItem.ui.contact_kf.gameObject:SetActive(true)
		end

		if show_total_process > need_process then
			show_total_process = need_process
		end
		taskItem.ui.progress_txt.text = show_total_process .. "/" .. need_process
		local process = show_total_process / need_process
		if process > 0.99 and process < 1 then
			taskItem.ui.task_slider.value = 0.99
		else
			taskItem.ui.task_slider.value = process
		end
	end
end

function C:on_model_xyhl_task_change_msg()
	self:RefreshTaskContent()
end