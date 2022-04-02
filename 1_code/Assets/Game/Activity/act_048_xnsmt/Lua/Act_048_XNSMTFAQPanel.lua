-- 创建时间:2021-01-20
-- Panel:Act_048_XNSMTFAQPanel
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

Act_048_XNSMTFAQPanel = basefunc.class()
local C = Act_048_XNSMTFAQPanel
local M = Act_048_XNSMTManager
C.name = "Act_048_XNSMTFAQPanel"

local option_tit = {"a.","b.","c."}

local option_state = {
    no_chooose = 0,
    true_choose = 1,
    false_choose = 2
}

local answer_state = {
    no_chooose = 0,
    true_choose = 1,
    false_choose = 2
}

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["common_question_answer_topic_response"] = basefunc.handler(self,self.on_common_question_answer_topic_response)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitCfg()
	self:InitData()
	self:InitUI()
end

function C:InitCfg()
	self.cfg = M.GetQuestionCfg()
end

function C:InitData()
	self.data = {}
	for i = 1, #self.cfg do
		self.data[i] = 0
	end
end

function C:UpdateData(que_index,opt_index)
	self.data[que_index] = opt_index
end

function C:UpdataAnswer()
	
end

function C:InitUI()

	self.finish_btn.onClick:AddListener(function ()
		self:Check()
	end)

	self.close_btn.onClick:AddListener(function ()
		self:MyExit()
	end)
	self:InitQuesLisUI()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:InitQuesLisUI()
	self.ques_lis_ui = {}
	for i = 1, #self.cfg do
		local ques_obj = GameObject.Instantiate(self.question_item, self.content)
		ques_obj.gameObject:SetActive(true)
		local ques_ui = {}
		LuaHelper.GeneratingVar(ques_obj.transform,ques_ui)
		ques_ui.question_txt.text = self.cfg[i].content
		self.ques_lis_ui[i] = ques_ui
		self:InitOptLisUI(i,ques_ui)
	end
end

function C:InitOptLisUI(que_index,parent_ui)
	for i = 1, #self.cfg[que_index].choose do
		local opt_obj = GameObject.Instantiate(self.option_tge, parent_ui.q_content)
		opt_obj.gameObject:SetActive(true)
		local _toggle = opt_obj:GetComponent("Toggle")
		_toggle.onValueChanged:AddListener(
			function(val)
				if val then
					self:UpdateData(que_index,i)
				end
			end)
		_toggle.group = parent_ui.q_content:GetComponent("ToggleGroup")
		local option_ui = {}
		LuaHelper.GeneratingVar(opt_obj.transform,option_ui)
		local opt_content = self.cfg[que_index].choose[i]
		option_ui.answer_txt.text = option_tit[i] .. opt_content
	end
end

function C:Check()
	local state = self:CheckAnswer()
	if state == answer_state.true_choose then
		self:HandleAnswerTrue()
	elseif state == answer_state.false_choose then
		self:HandleAnswerFalse()
	elseif state == answer_state.no_choose then
		LittleTips.Create("有未选择选项!!!")
	else
		dump("<color=red>Error:未正确获得问卷答案信息</color>")
	end
end

function C:MakeAnswerLis()
	local _data = {}
	for i = 1, #self.data do
		local state
		if self.data[i] == 0 then
			state = option_state.no_chooose
		else
			if self.data[i] == self.cfg[i].answer then
				state = option_state.true_choose
			else
				state = option_state.false_choose
			end
		end
		_data[i] = state
	end
	return _data
end

function C:CheckAnswer()
	local answer_lis = self:MakeAnswerLis()

	for i = 1, #answer_lis do
		if answer_lis[i] == option_state.no_chooose then
			return  answer_state.no_choose --有未选择的选项
		end
	end
	for i = 1, #answer_lis do
		if answer_lis[i] == option_state.false_choose then
			return  answer_state.false_choose --有选择错误的选项
		end
	end
	return answer_state.true_choose --全部正确
end

function C:HandleAnswerTrue()
	local net_lis = self:GetToNetData()
	dump(net_lis,"<color=red>----net_lis------</color>")
	Network.SendRequest("common_question_answer_topic",{act_type = M.answer_type,is_all_right = 1,topic_data = net_lis}, "")
	LittleTips.Create("恭喜您，通过考核！")
	self:MyExit()
end

function C:HandleAnswerFalse()
	local answer_lis = self:MakeAnswerLis()
	for i = 1, #answer_lis do
		if answer_lis[i] == option_state.false_choose then
			self.ques_lis_ui[i].question_txt.color = Color.red
		else
			self.ques_lis_ui[i].question_txt.color = Color.New(237 / 255, 136 / 255, 19 / 255)
		end
	end
	local net_lis = self:GetToNetData()
	Network.SendRequest("common_question_answer_topic",{act_type = M.answer_type,is_all_right = 0,topic_data = net_lis}, "")
	LittleTips.Create("很遗憾，未通过考核!!!")
end

function C:on_common_question_answer_topic_response(_,data)
	dump(data,"<color=white>+++++on_common_question_answer_topic_response+++++</color>")
	if not data then
		return
	end

	if data.result and data.result ~= 0 then
		HintPanel.ErrorMsg(data.result)
	end
end

function C:GetToNetData()
	local re_lis ={}
	for i = 1, #self.data do
		re_lis[i] = {}
		re_lis[i].topic_id = i
		re_lis[i].answer_id  = self.data[i]
		if self.data[i] == self.cfg[i].answer then
			re_lis[i].is_right = 1
		else
			re_lis[i].is_right = 0
		end
	end
	return re_lis
end