-- 创建时间:2020-02-17
-- Panel:New Lua
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

ACT_001YJWDPanel = basefunc.class()
local C = ACT_001YJWDPanel
C.name = "ACT_001YJWDPanel"
local M = ACT_001YJWDManager
local config
local curr_right_index
local player_choose_index
local ABCD =  {"A.","B.","C.","D."}
local Q_index = 1
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
	self.lister["global_hint_state_set_msg"] = basefunc.handler(self,self.on_global_hint_state_set_msg)
	self.lister["common_question_answer_reduce_answer_num_response"] = basefunc.handler(self,self.on_common_question_answer_reduce_answer_num_response)
	self.lister["common_question_answer_topic_response"] = basefunc.handler(self,self.on_common_question_answer_topic_response)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	PlayerPrefs.SetInt(C.name..MainModel.UserInfo.user_id,Q_index)
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.option_tges = {}
	LuaHelper.GeneratingVar(self.transform, self)
	config = ACT_001YJWDManager.GetFAQConfig()
	Q_index = PlayerPrefs.GetInt(C.name..MainModel.UserInfo.user_id,1)
	self.TG = self.Q_Content.transform:GetComponent("ToggleGroup")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:RefreshUI()
	local data = GameTaskModel.GetTaskDataByID(M.task_id)
    if Q_index > 6 and M.Is_Can_GetAward() then 
        HintPanel.Create(1,"恭喜你，已经全部答对",function ()
			self:GetAward()
		end)
	end
end

function C:InitUI()
	self:MyRefresh()
	self.confirm_btn.onClick:AddListener(
		function ()
			self:SentQ()
		end
	)
	self.share_btn.onClick:AddListener(
		function ()
			self:GoShare()
		end
	)
	self.open_gift_btn.onClick:AddListener(
		function ()
			self:Go_QFLB()
		end
	)
	self.open_gift_btn.gameObject:SetActive(not(not MoneyCenterQFLBManager.is_show())) --双 not 转 nil 为 false
end

function C:GoShare()
	GameManager.GotoUI({gotoui = "share_hall"})
end

function C:MyRefresh()

end

function C:on_global_hint_state_set_msg(parm)
	if parm and parm.key then 
		self:MyRefresh()
	end 
end

function C:SentQ()
	if not M.Is_Can_GetAward() then 
		HintPanel.Create(1,"恭喜您，已经答对所有题目！")
		return 
	end
	--有可能全部答对，但是没有领取奖励
	if M.GetAnswerNum() >= 1 then 
		if player_choose_index == nil then 
			HintPanel.Create(1,"您还没有选择答案哦")
		else
			if player_choose_index == curr_right_index then
				print("<color=red>答对了</color>")
				Q_index = Q_index + 1
				PlayerPrefs.SetInt(C.name..MainModel.UserInfo.user_id,Q_index)				
				if Q_index > #config.question then
					HintPanel.Create(1,"恭喜你，已经全部答对",function ()
						self:GetAward()
					end)
				else
					HintPanel.Create(1,"恭喜你，答对了,进入下一题")
				end 
				self:RefreshUI()
			else
				print("<color=red>答错了</color>")
				Network.SendRequest("common_question_answer_reduce_answer_num",{act_type = M.answer_type})
				HintPanel.Create(1,"很遗憾，答错了,每次分享可获得一次答题机会",function ()
					self:GoShare()
				end)
			end 
		end
		return 
	end
	if M.GetAnswerNum() <= 0 then 
		HintPanel.Create(1,"答题次数不足，,每次分享可获得一次答题机会哦！")
		return 
	end
end

function C:OnAssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "cai_dengmi_award" then
		self.Award = data
	end
end

function C:InitQ(qustion)
	self.question_txt.text = qustion.ask
end

function C:InitA(option)
	local temp_ui = {}
	self.TG.allowSwitchOff = true
	for i=1,#option do
		local b
		if IsEquals(self.option_tges[i]) then 
			b = self.option_tges[i]
		else
			b = GameObject.Instantiate(self.option,self.Q_Content)
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			self.option_tges[#self.option_tges + 1] = b
			b.gameObject:SetActive(true)
			temp_ui.option_tge.group = self.Q_Content:GetComponent("ToggleGroup")
			temp_ui.option_tge.onValueChanged:AddListener(
			function (val)
				self:PlayerChooseOption(val,i)
			end
			)	
		end	
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.option_tge.isOn = false
		player_choose_index = nil
		temp_ui.answer_txt.text = ABCD[i]..option[i]		
	end
	self.TG.allowSwitchOff = false
end

function C:RefreshUI()
	if M.Is_Can_GetAward() == false or Q_index > #config.question then 
		self.buttoncontent.gameObject:SetActive(false)
		self.tips_txt.text = "恭喜您，已经答对所有题目！"
		self.tips_txt.gameObject:SetActive(true)
		self.num_txt.gameObject:SetActive(false)
		self.question_txt.gameObject:SetActive(false)
		self.Q_Content.gameObject:SetActive(false)
		return 
	end
	self.confirm_btn.gameObject:SetActive(M.GetAnswerNum() >= 1)
	self.share_btn.gameObject:SetActive(not (M.GetAnswerNum() >= 1))
	self.num_txt.text = "第"..Q_index.."题（共6题）"
	self:InitQ(config.question[Q_index])
	self:InitA(config.question[Q_index].option)
	curr_right_index = config.question[Q_index].answer
end

function C:OnDestroy()
	self:MyExit()
end

function C:PlayerChooseOption(val,i)
	if val then 
		player_choose_index = i
	else
		
	end 
end

function C:on_global_hint_state_set_msg(parm)
	if parm and parm.gotoui == M.key then 
		self:RefreshUI()
	end
end

function C:GetAward()
	local common_question_answer_topic_data = {}
	for i = 1,#config.question do
		local data = {topic_id = i,answer_id = config.question[i].answer,is_right = 1}
		common_question_answer_topic_data[#common_question_answer_topic_data + 1] = data
	end 
	Network.SendRequest("common_question_answer_topic",{act_type = M.answer_type,is_all_right = 1,topic_data =common_question_answer_topic_data})
end

function C:on_common_question_answer_reduce_answer_num_response(_,data)
	if data then 
		if data.result ~= 0 then 
			HintPanel.ErrorMsg(data.result)
		end
	end
end

function C:on_common_question_answer_topic_response(_,data)
	dump(data,"<color>答题返回</color>")
	if data and data.act_type == M.answer_type then 
		Network.SendRequest("get_task_award", {id = M.task_id})
	end
end

function C:AssetsGetPanelConfirmCallback()
	self:Go_QFLB()
	self:RefreshUI()
end

function C:Go_QFLB()
	if MoneyCenterQFLBManager.is_show() then 
		GameManager.GotoUI({gotoui = MoneyCenterQFLBManager.key, goto_scene_parm="panel"})
	end 
end