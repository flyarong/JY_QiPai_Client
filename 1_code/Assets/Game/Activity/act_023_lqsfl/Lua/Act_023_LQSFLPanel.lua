-- 创建时间:2020-07-21
-- Panel:Act_023_LQSFLPanel
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

Act_023_LQSFLPanel = basefunc.class()
local C = Act_023_LQSFLPanel
C.name = "Act_023_LQSFLPanel"
local M = Act_023_LQSFLManager
local Task_Config
local Help_Info = {
	"1.活动时间：8月4日7:30~8月10日23:59:59",
	"2.所有任务奖励必须先领取前一个任务的奖励后才能领取",
	"3.累计充值数据只记录充值商城中的充值（不记录活动标签及推荐必买商品）",
	"4.累计赢金任务中街机捕鱼和苹果大战游戏中的赢金数据只记录50%",
	"5.每日0点重置所有任务，未领取的奖励视为自动放弃",
}
local CPL_Help_Info = {
	"1.活动时间：8月4日7:30~8月10日23:59:59",
	"2.所有任务奖励必须先领取前一个任务的奖励后才能领取",
	"3.累计充值数据只记录充值商城中的充值（不记录活动标签及推荐必买商品）",
	"4.累计赢金任务中街机捕鱼和苹果大战游戏中的赢金数据只记录25%，其他小游戏的赢金数据记录50%",
	"5.每日0点重置所有任务，未领取的奖励视为自动放弃",
}


function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.AnimTimer then
		self.AnimTimer:Stop()
	end
	if self.backcall then
		self.backcall()	
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	Task_Config = {
		[1] = {task_id = M.GetCurrTaskID(),task_level = 1,task_name = "累计赢金10万",award = {image = "pay_icon_gold2",text = "1000鲸币"}},
		[2] = {task_id = M.GetCurrTaskID(),task_level = 2,task_name = "累计赢金30万",award = {image = "pay_icon_gold2",text = "2000鲸币"}},
		[3] = {task_id = M.cz_task_id,task_level = 1,task_name = "累计充值48元",award = {image = "matchpop_icon_3",text = "1福卡"}},
		[4] = {task_id = M.GetCurrTaskID(),task_level = 3,task_name = "累计赢金80万",award = {image = "pay_icon_gold2",text = "5000鲸币"}},
		[5] = {task_id = M.GetCurrTaskID(),task_level = 4,task_name = "累计赢金200万",award = {image = "matchpop_icon_3",text = "1福卡"}},
		[6] = {task_id = M.cz_task_id,task_level = 2,task_name = "累计充值98元",award = {image = "matchpop_icon_3",text = "1.5福卡"}},
		[7] = {task_id = M.GetCurrTaskID(),task_level = 5,task_name = "累计赢金500万",award = {image = "matchpop_icon_3",text = "1.5福卡"}},
		[8] = {task_id = M.GetCurrTaskID(),task_level = 6,task_name = "累计赢金1000万",award = {image = "matchpop_icon_3",text = "2.5福卡"}},
		[9] = {task_id = M.GetCurrTaskID(),task_level = 7,task_name = "累计赢金3000万",award = {image = "matchpop_icon_3",text = "10福卡"}},
		[10] = {task_id = M.cz_task_id,task_level = 3,task_name = "累计充值498元",award = {image = "matchpop_icon_3",text = "10福卡"}},
		[11] = {task_id = M.GetCurrTaskID(),task_level = 8,task_name = "累计赢金5000万",award = {image = "matchpop_icon_3",text = "10福卡"}},
		[12] = {task_id = M.GetCurrTaskID(),task_level = 9,task_name = "累计赢金7000万",award = {image = "matchpop_icon_3",text = "10福卡"}},
		[13] = {task_id = M.cz_task_id,task_level = 4,task_name = "累计充值998元",award = {image = "matchpop_icon_3",text = "15福卡"}},
		[14] = {task_id = M.GetCurrTaskID(),task_level = 10,task_name = "累计赢金1亿",award = {image = "matchpop_icon_3",text = "15福卡"}},
		[15] = {task_id = M.GetCurrTaskID(),task_level = 11,task_name = "累计赢金1.2亿",award = {image = "matchpop_icon_3",text = "10福卡"}},
		[16] = {task_id = M.GetCurrTaskID(),task_level = 12,task_name = "累计赢金1.5亿",award = {image = "matchpop_icon_3",text = "15福卡"}},
		[17] = {task_id = M.cz_task_id,task_level = 5,task_name = "累计充值2498元",award = {image = "matchpop_icon_3",text = "30福卡"}},
		[18] = {task_id = M.GetCurrTaskID(),task_level = 13,task_name = "累计赢金2亿",award = {image = "matchpop_icon_3",text = "25福卡"}},
		[19] = {task_id = M.GetCurrTaskID(),task_level = 14,task_name = "累计赢金3亿",award = {image = "matchpop_icon_3",text = "50福卡"}},
	}
	
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.task_len_map = self:GetTaskLenMap()
	self.SV = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.anim_value = 0
	self:MainAnim()
	self.backcall = backcall
	self:AutoGoCanGetAwardItem(self:GetBestIndex())
end

function C:InitUI()
	self.ui_items = {}
	for i = 1,#Task_Config do
		local temp_ui = {}
		local b = GameObject.Instantiate(self.item,self.Content)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform,temp_ui)
		temp_ui.task_name_txt.text = Task_Config[i].task_name
		temp_ui.award_txt.text = Task_Config[i].award.text
		temp_ui.award_img.sprite = GetTexture(Task_Config[i].award.image)
		if (i%2) == 1 then
			temp_ui.award.transform.parent = temp_ui.node1
			temp_ui.award.transform.localPosition = Vector2.zero
		else
			temp_ui.tiao1.gameObject:SetActive(false)
			temp_ui.tiao2.gameObject:SetActive(false)
			temp_ui.award.transform.parent = temp_ui.node2
			temp_ui.award.transform.localPosition = Vector2.zero
		end
		if i == 1 then
			temp_ui.tiao2.gameObject:SetActive(false)
		end
		if i == #Task_Config then
			temp_ui.tiao1.gameObject:SetActive(false)
		end
		temp_ui.get_award_btn.onClick:AddListener(
			function ()
				self:GetAward(i)
			end
		)
		self.ui_items[#self.ui_items + 1] = temp_ui
	end
	self.close_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.help_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:OpenHelpPanel()
		end
	)
	self.go_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			GameManager.GotoUI({gotoui = "game_MiniGame"})
		end
	)
	self.pay_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
		end
	)
	EventTriggerListener.Get(self.left_btn_.gameObject).onDown = basefunc.handler(self,self.LeftAnim)
	EventTriggerListener.Get(self.right_btn_.gameObject).onDown = basefunc.handler(self,self.RightAnim)
	EventTriggerListener.Get(self.left_btn_.gameObject).onUp = basefunc.handler(self,self.ButtonUp)
	EventTriggerListener.Get(self.right_btn_.gameObject).onUp = basefunc.handler(self,self.ButtonUp)
	self:MyRefresh()
end

function C:MyRefresh()
	if IsEquals(self.gameObject) then
		for i = 1,#self.ui_items do
			local data = GameTaskModel.GetTaskDataByID(Task_Config[i].task_id)
			--dump(data,"任务..."..i)
			if data then
				local b = basefunc.decode_task_award_status(data.award_get_status)
				b = basefunc.decode_all_task_award_status2(b, data, self.task_len_map[Task_Config[i].task_id])
				if b[Task_Config[i].task_level] == 1 then
					self.ui_items[i].ylq.gameObject:SetActive(false)
					self.ui_items[i].get_award_btn.gameObject:SetActive(true)
				elseif b[Task_Config[i].task_level] == 2 then
					self.ui_items[i].ylq.gameObject:SetActive(true)
					self.ui_items[i].get_award_btn.gameObject:SetActive(false)
				else
					self.ui_items[i].ylq.gameObject:SetActive(false)
					self.ui_items[i].get_award_btn.gameObject:SetActive(false)
				end
			end
		end
		self:RefreshLJCZ()
		self:RefreshLJYJ()
	end
end

function C:OpenHelpPanel()
	local DESCRIBE_TEXT
	if M.Curr_Per == M.cpl_ljyj_permiss then
		DESCRIBE_TEXT = CPL_Help_Info
	else
		DESCRIBE_TEXT = Help_Info
	end
    local str = DESCRIBE_TEXT[1]
    for i = 2, #DESCRIBE_TEXT do
        str = str .. "\n" .. DESCRIBE_TEXT[i]
    end
    self.introduce_txt.text = str
    IllustratePanel.Create({ self.introduce_txt.gameObject }, GameObject.Find("Canvas/LayerLv5").transform)
end

--充值任务长度5
--累计赢金任务长度14
function C:GetAward(index)
	local task_len_map = self.task_len_map
	dump(task_len_map,"<color=red> 任务长度----- </color>")
	if index > 1 then
		local last_taskid = Task_Config[index - 1].task_id
		local data = GameTaskModel.GetTaskDataByID(last_taskid)
		dump(data,"上一个任务数据")
		if data then
			local b = basefunc.decode_task_award_status(data.award_get_status)
			b = basefunc.decode_all_task_award_status2(b, data, task_len_map[last_taskid])
			if b[Task_Config[index - 1].task_level] == 2 then
				Network.SendRequest("get_task_award",{id = Task_Config[index].task_id})
			else
				HintPanel.Create(1,"请先领取前一个任务的奖励!")
			end
		end
	else
		Network.SendRequest("get_task_award",{id = Task_Config[index].task_id})
	end
end

function C:GetTaskLenMap()
	local task_len_map = {}
	for i = 1,#Task_Config do
		task_len_map[Task_Config[i].task_id] = task_len_map[Task_Config[i].task_id] and (task_len_map[Task_Config[i].task_id] + 1) or 1
	end
	return task_len_map
end

function C:on_model_task_change_msg(data) 
	if data and self.task_len_map[data.id] then
		self:MyRefresh()
	end
end

function C:LeftAnim()
	self.anim_value = - 1
end

function C:RightAnim()
	self.anim_value =  1
end

function C:ButtonUp()
	self.anim_value = 0	 
end

function C:MainAnim()
	if self.AnimTimer then
		self.AnimTimer:Stop()
	end
	self.AnimTimer = Timer.New(
		function()
			self.SV.horizontalNormalizedPosition = self.SV.horizontalNormalizedPosition + 0.01 * self.anim_value
			if self.SV.horizontalNormalizedPosition >= 0.999 then
				self.right_btn_.gameObject:SetActive(false)
				self.anim_value = 0	 
			else
				self.right_btn_.gameObject:SetActive(true)
			end
			if self.SV.horizontalNormalizedPosition <= 0.001 then
				self.left_btn_.gameObject:SetActive(false)
				self.anim_value = 0	 
			else
				self.left_btn_.gameObject:SetActive(true)
			end			
		end
	,0.02,-1)
	self.AnimTimer:Start()
end

function C:AutoGoCanGetAwardItem(index)
	self.MMM.gameObject:SetActive(true)
	local go_anim = function(val)
		local t 
		t = Timer.New(
			function()
				if IsEquals(self.gameObject) then
					self.SV.horizontalNormalizedPosition = Mathf.Lerp(self.SV.horizontalNormalizedPosition,val,0.1)
					if math.abs(self.SV.horizontalNormalizedPosition - val) <= 0.006 then 
						self.MMM.gameObject:SetActive(false)
						t:Stop()
						t = nil
					end
				end
			end
		,0.02,-1)
		t:Start()
	end
	if index <= 3 then
		go_anim(0)
	elseif index >= #Task_Config - 3 then
		go_anim(1)
	else
		go_anim(1/#Task_Config * (index) + 0.015)
	end
end


function C:GetBestIndex()
	for i = #Task_Config,1,-1 do
		local data = GameTaskModel.GetTaskDataByID(Task_Config[i].task_id)
		if data then
			local b = basefunc.decode_task_award_status(data.award_get_status)
			b = basefunc.decode_all_task_award_status2(b, data, self.task_len_map[Task_Config[i].task_id])
			if b[Task_Config[i].task_level] == 2 then
				return i + 1
			end
		end
	end
	return 1
end

function C:RefreshLJYJ()
	local data = GameTaskModel.GetTaskDataByID(M.GetCurrTaskID())
	if data then
		self.all_ljyj_txt.text = StringHelper.ToCash(data.now_total_process)
	else
		self.all_ljyj_txt.text = 0
	end
end

function C:RefreshLJCZ()
	local data = GameTaskModel.GetTaskDataByID(M.cz_task_id)
	if data then
		self.all_pay_txt.text = StringHelper.ToCash(data.now_total_process/100)
	else
		self.all_pay_txt.text = 0 
	end
end
