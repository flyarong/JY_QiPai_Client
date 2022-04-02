-- 创建时间:2019-12-31
-- Panel:YX_CDMPanel
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

YX_CDMPanel = basefunc.class()
local C = YX_CDMPanel
C.name = "YX_CDMPanel"
local M = YX_CDMManager
local config
local curr_right_index
local player_choose_index
local wrong_q_id
local day_index = 1
local ABCD =  {"A.","B.","C.","D."}
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
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["cai_dengmi_response"] = basefunc.handler(self,self.on_cai_dengmi_response)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
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

function C:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	config = YX_CDMManager.GetFAQConfig()
	player_choose_index = nil
	day_index = YX_CDMManager.GetDayIndex() + 1
	if day_index > 10 then 
		day_index = 10
	end 
	self:MakeLister()
	self:AddMsgListener()
	local q = self:GetQuestions()
	wrong_q_id = q[day_index].id
	local d = self:GetOptions(q[day_index])
	self:InitQ(q[day_index])
	self:InitA(d)
	self:InitUI()
	Network.SendRequest("query_cai_dengmi_status")
end

function C:InitUI()
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
	self:RefreshUI()
end

function C:MyRefresh()
	
end
--打乱问题顺序
function C:GetQuestions()
	local _config = basefunc.deepcopy(config)
	local _random_list = YX_CDMManager.GetRandomList(#_config.question, #_config.question,MainModel.UserInfo.user_id)
	self.random_list = _random_list
	local question = {}
	for i=1,#_random_list do
		question[i] = _config.question[_random_list[i]]
		question[i].answer = question[i].option[question[i].answer]
	end
	return question
end
--打乱答案顺序
function C:GetOptions(qustion)
	dump(qustion,"<color=red>qustionqustionqustion</color>")
	local _data = basefunc.deepcopy(qustion)
	local _random_list = YX_CDMManager.GetRandomList(#_data.option, #_data.option,MainModel.UserInfo.user_id)
	local func = function (qustion)
		for i=1,#qustion.option do
			if  qustion.option[i] == qustion.answer then 
				return i
			end  
		end
	end
	local _rr = {}
	_rr.option = {}
	_rr.answer = qustion.answer
	for i = 1,#_random_list do
		_rr.option[i] = _data.option[_random_list[i]]
	end
	curr_right_index = func(_rr)
	return _rr.option
end

function C:OnDestroy()
	self:MyExit()
end

function C:InitQ(qustion)
	self.question_txt.text = qustion.ask
end

function C:InitA(option)
	local temp_ui = {}
	self.option_tges = {}
	for i=1,#option do
		local b = GameObject.Instantiate(self.option,self.Q_Content)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.answer_txt.text = ABCD[i]..option[i]
		temp_ui.option_tge.group = self.Q_Content:GetComponent("ToggleGroup")
		temp_ui.option_tge.onValueChanged:AddListener(
			function (val)
				self:PlayerChooseOption(val,i)
			end
		)
		self.option_tges[#self.option_tges + 1] = b
	end
end

function C:PlayerChooseOption(val,i)
	if val then 
		player_choose_index = i
	else
		
	end 
end

function C:SentQ()
	if M.Get_Is_Award() == 1 then 
		HintPanel.Create(1,"恭喜你,已答对今天的灯谜！")
		return 
	end 
	if M.Get_Count() >= 1 then 
		if player_choose_index == nil then 
			HintPanel.Create(1,"您还没有选择答案哦")
		else
			if player_choose_index == curr_right_index then
				print("<color=red>答对了</color>")
				Network.SendRequest("cai_dengmi",{answer = 2,topic_id = wrong_q_id},"",function ()
					Network.SendRequest("query_cai_dengmi_status")
				end)
			else
				print("<color=red>答错了</color>")
				Network.SendRequest("cai_dengmi",{answer = 1,topic_id = wrong_q_id},"",function ()
					Network.SendRequest("query_cai_dengmi_status",nil,"",function (data)
						dump(data,"<color=red>CHB</color>")
						if data and data.result == 0 then 
							if data.my_cai_dengmi_data.is_share == 0 then
								HintPanel.Create(1,"您的答案不对哦，分享可以获得额外一次答题机会",function ()
									self:GoShare()
								end)
							else
								if data.my_cai_dengmi_data.count >= 1 then 
									HintPanel.Create(1,"回答错误,您还有一次答题机会")				
								else
									HintPanel.Create(1,"很遗憾,您未答对今日的灯谜。")					
								end 
							end 
						end 
					end)
				end)
				--再次请求是为了统治manager，没有change消息
				Network.SendRequest("query_cai_dengmi_status")
			end 
		end
		return 
	end

	if M.Get_Is_Guess() == 1 and M.Get_Is_Share() == 0 then 
		HintPanel.Create(1,"答题次数不足，每日分享可以获得一次额外答题次数哦！")
		return 
	end
end

function C:GoShare()
end

function C:OnAssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	if data.change_type and data.change_type == "cai_dengmi_award" then
		Event.Brocast("AssetGet",data)
	end
end

function C:on_cai_dengmi_response(_,data)
	dump(data,"<color=red>----on_cai_dengmi_response-----</color>")
end

function C:on_query_cai_dengmi_status_response(_,data)
	dump(data,"<color=red>on_query_cai_dengmi_status_response</color>")
	if data and data.result == 0 then 
	end 
end

function C:on_global_hint_state_change_msg(parm)
	if parm and parm.gotoui == YX_CDMManager.key then 
		self:RefreshUI()
	end
end

function C:RefreshUI()
	local temp_ui = {}
	if M.Get_Is_Award() == 1  then 
		self.tips_txt.text = "恭喜你,已答对今天的灯谜！"
		self.buttoncontent.gameObject:SetActive(false)
		LuaHelper.GeneratingVar(self.option_tges[curr_right_index].transform, temp_ui)
		temp_ui.option_tge.isOn = true
		for i = 1, #self.option_tges do 
			LuaHelper.GeneratingVar(self.option_tges[i].transform, temp_ui)
			temp_ui.option_tge.enabled = false
		end 
		return 
	end 
	if M.Get_Is_Guess() == 1 and M.Get_Is_Share() == 1 and M.Get_Count() < 1 then 
		self.tips_txt.text = "很遗憾,您未答对今日的灯谜。"
		self.buttoncontent.gameObject:SetActive(false)
		return 
	end
	self.tips_txt.text = ""
	self.buttoncontent.gameObject:SetActive(true)
	for i = 1, #self.option_tges do 
		LuaHelper.GeneratingVar(self.option_tges[i].transform, temp_ui)
		temp_ui.option_tge.enabled = true
	end 
end