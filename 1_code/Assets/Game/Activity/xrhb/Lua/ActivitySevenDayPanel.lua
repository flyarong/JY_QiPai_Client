-- 创建时间:2018-12-12
local basefunc = require "Game.Common.basefunc"

ActivitySevenDayPanel = basefunc.class()

local C = ActivitySevenDayPanel

C.name = "ActivitySevenDayPanel"

function C.Create(parent, backcall)
	if ActivitySevenDayModel.IsNewVersion() then
		return ActivitySevenDayNewPanel.Create(parent, backcall)
	else
		return C.New(parent, backcall)
	end
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_query_stepstep_money_big_step_data"] = basefunc.handler(self, self.on_query_stepstep_money_big_step_data)
	self.lister["ExitScene"] = basefunc.handler(self, self.ExitScene)
	self.lister["model_get_stepstep_money_task_award_response"] = basefunc.handler(self, self.on_model_get_stepstep_money_task_award_response)
	self.lister["model_stepstep_money_task_change_msg"] = basefunc.handler(self, self.on_model_stepstep_money_task_change_msg)
	self.lister["model_task_finished"] = basefunc.handler(self, self.MyExit)
	self.lister["all_seven_day_task_completed"] = basefunc.handler(self, self.OnBackClick)
	self.lister["seven_day_task_countdown_time"] = basefunc.handler(self, self.handle_countdown_time)
	self.lister["seven_day_task_over"] = basefunc.handler(self, self.handle_seven_day_task_over)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
	self:AddMsgListener()
	self.gameObject:SetActive(false)

    LuaHelper.GeneratingVar(obj.transform, self)
	self.activity_config = ActivitySevenDayModel.GetActivity()

	self.back_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
	end)
	
	self.share_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        MoneyCenterShareHintPanel.Create("moneycenter",nil,nil,"activity_seven_day")
	end)

	self.wyhb_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		GameManager.GotoUI({gotoui = "sys_wyhb",goto_scene_parm = "panel",data = GameMoneyCenterModel.GetWyhbData()})
	end)
	self.share_desc_txt.text = string.format("每邀请一位好友完成新人福卡奖 <color=#ca1919ff><size=45>%.0f</size></color> 元",5)
	self:InitUI()
end

function C:InitUI()
	self:UpdateTop()
end

function C:MyExit()
	self:RemoveListener()
	self:ClearDayCellList()
	self:ClearTaskCellList()
	GameObject.Destroy(self.gameObject)

	 
end

function C:on_query_stepstep_money_big_step_data(day)
	if not self.selectDay then
		self.selectDay = day
		self.DayCellList[self.selectDay]:SetSelect(true)
		self:UpdateTask()
		self:UpdateTopPrefab()
		ActivitySevenDayModel.data.total_hongbao_num = ActivitySevenDayModel.data.total_hongbao_num or 0
		self.total_hb_txt.text = string.format("%.1f",ActivitySevenDayModel.data.total_hongbao_num / 100)
		self.now_get_hb_txt.text = string.format("已领取    <color=#c02d1fff><size=44>%.2f</size></color>    福卡",ActivitySevenDayModel.data.now_get_hongbao_num / 100)
	else
		self:CallDayClick(day)
	end
	
	self.gameObject:SetActive(true)
	if GuideLogic then
		GuideLogic.CheckRunGuide("bbsc")
	end
end

function C:UpdateTopPrefab()
	for k,v in ipairs(self.DayCellList) do
		v:UpdateUI()
	end
end

function C:UpdateTop()
	self:ClearDayCellList()
	for k,v in ipairs(self.activity_config) do
		local pre = SevenDayTopPrefab.Create(self.TopNode.transform, v, C.OnDayClick, self)
		self.DayCellList[#self.DayCellList  + 1] = pre
	end
	ActivitySevenDayModel.ReqCurrTaskData()
end

function C:UpdateTask()
	self:ClearTaskCellList()
	self.task_list = self.activity_config[self.selectDay].task_list
	local i_name = 1
	for k,v in ipairs(self.task_list) do
		local pre = SevenDayTaskPrefab.Create(self.TaskNode.transform, v, nil, nil)
		self.TaskCellList[#self.TaskCellList  + 1] = pre
		pre.gameObject.name  = "SevenDayTaskPrefab" ..  i_name
		i_name = i_name + 1
	end
	if self.TaskCellList and next(self.TaskCellList) then
		local i = 0
		local tt = 0.1
		for k,v in ipairs(self.TaskCellList) do
			v:PlayAnimIn(tt * i)
			i = i + 1
		end
	end
	self.day_txt.text = string.format( "第%d天",self.selectDay)
end

function C:ClearDayCellList()
	if self.DayCellList then
		for k,v in ipairs(self.DayCellList) do
			v:OnDestroy()
		end
	end
	self.DayCellList = {}
end
function C:ClearTaskCellList()
	if self.TaskCellList then
		for k,v in ipairs(self.TaskCellList) do
			v:OnDestroy()
		end
	end
	self.TaskCellList = {}
end

function C:CallDayClick(i)
	self.DayCellList[self.selectDay]:SetSelect(false)
	self.selectDay = i
	self.DayCellList[self.selectDay]:SetSelect(true)
	self:UpdateTask()
	self:UpdateTopPrefab()
end
function C:OnDayClick(i)
	if ActivitySevenDayModel.data.now_big_step then
		if i <= (ActivitySevenDayModel.data.now_big_step + 1) then
			if self.selectDay ~= i then
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				ActivitySevenDayModel.ReqTaskByDay(i)
			end
		else
			LittleTips.Create("只能查看当天及下一天")
		end
	else
		LittleTips.Create("正在初始化数据")
	end
end

function C:OnBackClick()
	self:MyExit()
	if self.backcall then
		self.backcall()
	end
end

function C:ExitScene()
	self:MyExit()
end

function C:on_model_get_stepstep_money_task_award_response(_,now_get_hongbao_num)
	dump(now_get_hongbao_num, "<color=green>on_model_get_stepstep_money_task_award_response</color>")
	self.now_get_hb_txt.text = string.format("已领取 <color=#c02d1fff><size=35>%.2f</size></color> 福卡",ActivitySevenDayModel.data.now_get_hongbao_num / 100)
end

function C:on_model_stepstep_money_task_change_msg(_,id)
	dump(id, "<color=green>on_model_get_stepstep_money_task_award_response</color>")
	self:UpdateTopPrefab()
end

function C:handle_countdown_time(data)
	if not IsEquals(self.countdown_txt) then return end

	local txt = data.timer
	self.countdown_txt.text = txt
end

function C:handle_seven_day_task_over(v)
	if v == 0 then
		self:OnBackClick()
	end
end
