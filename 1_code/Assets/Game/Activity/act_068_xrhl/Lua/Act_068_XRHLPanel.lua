-- 创建时间:2021-09-18
-- Panel:Act_068_XRHLPanel
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

Act_068_XRHLPanel = basefunc.class()
local C = Act_068_XRHLPanel
C.name = "Act_068_XRHLPanel"
local M = Act_068_XRHLManager


function C.Create(backcall)
	return C.New(backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["act_068_xrhl_task_change"] = basefunc.handler(self, self.on_act_068_xrhl_task_change)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end
	if self.checkOutTimeTimer then
		self.checkOutTimeTimer:Stop()
		self.checkOutTimeTimer = nil
	end

	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(backcall)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self.taskPre = {}
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:SelctPage(1)
	self:MakeCheckOutTimeTimer()
end

function C:InitUI()
	self.back_btn.onClick:AddListener(function()
		self:MyExit()
		GuideLogic.CheckRunGuide("xrhl_panel_exit")
	end)
	self.help_btn.onClick:AddListener(function()
		self:OnClickHelp()
	end)
	self:InitPageBtnUI()
	self.contentSV = self.transform:Find("TaskNodeSV"):GetComponent("ScrollRect")
	self:MyRefresh()
	CommonTimeManager.GetCutDownTimer(M.GetActEndTime(),self.remain_time_txt)
    GuideLogic.CheckRunGuide("xrhl_panel")
	self.back_btn.gameObject.name = "xrhl_btn_back"
	Event.Brocast("WQP_Guide_Check",{guide = 3 ,guide_step = 2})
end

function C:InitPageBtnUI()
	self.pageBtn = {}
	for i = 1,self.btn_node.childCount do
		local child = self.btn_node:GetChild(i - 1)
		local d = {}
		d.btn = child:GetComponent("Button")
		d.selected = child.transform:Find("Selected")
		d.lfl = child.transform:Find("Hint")
		self.pageBtn[#self.pageBtn + 1] = d
	end

	for i = 1,#self.pageBtn do
		self.pageBtn[i].btn.onClick:AddListener(function()
			self:SelctPage(i)
		end)
	end
end

function C:MyRefresh()

end

function C:SelctPage(index)
	if index == self.pageIndex then
		return
	end
	dump(index, "<color=white>选择页面</color>")
	self.pageIndex = index
	if self.pageBtn[self.pageIndex] then
		self.pageBtn[self.pageIndex].selected.gameObject:SetActive(true)
	end
	if self.lastPageIndex then
		self.pageBtn[self.lastPageIndex].selected.gameObject:SetActive(false)
	end
	self:RefreshTaskUI()
	self.contentSV.verticalNormalizedPosition = 1
	self.lastPageIndex = self.pageIndex
end

function C:RefreshTaskUI()
	self.cfg = M.GetConfigFromPageIndex(self.pageIndex)
	dump(self.cfg, "<color=white>self.cfg</color>")
	self:RefreshTaskPrefab()
	self:RefreshTaskContent()
	self:RefreshPageSelHint()
end

function C:RefreshTaskPrefab()
	local preNum = self.task_node.transform.childCount or 0
	local taskNum = #self.cfg
	dump(taskNum, "<color=white>taskNum</color>")
	dump(preNum, "<color=white>preNum</color>")

	if preNum < taskNum then
		self:AddTaskPrefab(taskNum - preNum)
	elseif preNum > taskNum then
		self:DeleTaskPrefab(preNum - taskNum)
	end
end

function C:AddTaskPrefab(num)
	-- dump(num, "<color=white>增加prefab</color>")
	for i = 1, num do
		local b = newObject("Act_068_XRHLTaskItem", self.task_node)
		local b_ui = {}
		LuaHelper.GeneratingVar(b.transform, b_ui)
		b_ui.obj = b
		self.taskPre[#self.taskPre + 1] = b_ui
	end
end

function C:DeleTaskPrefab(num)
	-- dump(num, "<color=white>删除prefab</color>")
	for i = 1, num do
		local b = self.taskPre[#self.taskPre]
		destroy(b.obj.gameObject)
		self.taskPre[#self.taskPre] = nil
	end
end

function C:RefreshTaskContent()
	-- dump(#self.cfg, "<color=white>11111111111111111</color>")
	for i = 1, #self.cfg do
		local taskItem = self.taskPre[i]
		local cfg = self.cfg[i]
		local data = M.GetTaskData(cfg.task_id)
		taskItem.task_info_txt.text = cfg.content
		taskItem.item_icon_txt.text = StringHelper.ToCash(cfg.award_num / 100)
		local state 
		if cfg.task_lv then
			state = data.state[cfg.task_lv]
		else
			state = data.state
		end
		taskItem.get_btn.gameObject:SetActive(state == 1)
		taskItem.geted_btn.gameObject:SetActive(state == 2)
		taskItem.goto_btn.gameObject:SetActive(state == 0)
		if state == 1 then
			taskItem.get_btn.onClick:RemoveAllListeners()
			if cfg.task_lv then
				taskItem.get_btn.onClick:AddListener(function()
					Network.SendRequest("get_task_award_new", { id = cfg.task_id, award_progress_lv = cfg.task_lv })
				end)
			else
				taskItem.get_btn.onClick:AddListener(function()
					Network.SendRequest("get_task_award", { id = cfg.task_id})
				end)
			end
		elseif state == 0 and cfg.gotoUI then
			taskItem.goto_btn.onClick:RemoveAllListeners()
			taskItem.goto_btn.onClick:AddListener(function()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				if type(cfg.gotoUI) == "table" then
					GameManager.GotoUI({gotoui = cfg.gotoUI[1],goto_scene_parm = cfg.gotoUI[2]})
				else
					GameManager.GotoUI({gotoui = cfg.gotoUI})
				end
				self:MyExit()
			end)
		end
		local need_process
		if cfg.task_lv then
			need_process = cfg.task_total
		else
			need_process = data.need_process
		end

		local show_total_process
		if self.pageIndex == 1 then
			show_total_process = data.now_total_process
		else
			show_total_process = data.now_total_process / 100
		end

		if show_total_process > need_process then
			show_total_process = need_process
		end

		taskItem.progress_txt.text = show_total_process .. "/" .. need_process
		local process = show_total_process / need_process
		local slider = taskItem.Slider:GetComponent("Slider")


		if process > 0.99 and process < 1 then
			slider.value = 0.99
		else
			slider.value = process
		end

		--新手引导特殊处理
		if cfg.task_id == 100035 then
			taskItem.get_btn.gameObject.name = "xrhl_btn_100035"
		end
	end
end

function C:on_act_068_xrhl_task_change()
	dump("<color=red>WWWWWWWWWWWWWWWWWWWWWWWW</color>")
	self.cfg = M.GetConfigFromPageIndex(self.pageIndex)
	self:RefreshTaskContent()
	self:RefreshPageSelHint()
end

function C:MakeCheckOutTimeTimer()
	self.checkOutTimeTimer = Timer.New(function()
		if not M.IsActInTime() then
			LittleTips.Create("活动结束")
			self:MyExit()
		end
	end, 1, -1)
	self.checkOutTimeTimer:Start()
end

function C:OnClickHelp()
	local str =""
	local help_info = M.rules
    for i = 1, #help_info do
        str = str .. "\n" .. help_info[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

function C:RefreshPageSelHint()

	dump(M.IsHintYj(), "<color=white>M.IsHintYj()</color>")
	dump(M.IsHintCz(), "<color=white>M.IsHintCz()</color>")

	self.pageBtn[1].lfl.gameObject:SetActive(not not M.IsHintYj())
	self.pageBtn[2].lfl.gameObject:SetActive(not not M.IsHintCz())
end