-- 创建时间:2019-09-28
-- Panel:Achievement
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
AchievementTGTestPanel = basefunc.class()
local C = AchievementTGTestPanel
C.name = "AchievementTGTestPanel"
local PlayerAnswer = {}
local ABCD =  {"A.","B.","C.","D."}
local MaxScore = 100
local Error_Topic_Info = {} 
function C.Create()
	--return 
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
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
	PlayerAnswer = {} 
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject("FAQPanel", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.sv = self.transform:Find("Scroll View"):GetComponent("ScrollRect")
	self:MakeLister()
	self:AddMsgListener()
	local Q =  self:GetQuestions()
	self.Question = self:ReformOption(Q)
 	self._Right_Answer_Map = self:InitFaqUI(self.Question)
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.finsh_btn.onClick:AddListener(
		function ()
			local _score = self:CountScore(self._Right_Answer_Map)
			if _score then 
				self:ShowScore(_score)
				if _score < MaxScore  then
					Network.SendRequest("answer_sczs_achievement_test_paper",{score = _score , error_topic_info  = self.UnRight_Answer })
				elseif 	AchievementTGManager.GetFAQStatus() ~= 2 then
					Network.SendRequest("answer_sczs_achievement_test_paper",{score = _score})
				end 
			end			
		end
	)
	self.close_show_btn.onClick:AddListener(
		function ()
			self:MyExit()
			self.ShowScorePanel.gameObject:SetActive(false)
		end
	)
	self.close2_show_btn.onClick:AddListener(
		function ()
			self:MyExit()
			self.ShowScorePanel.gameObject:SetActive(false)
		end
	)
	self.try_again_btn.onClick:AddListener(
		function ()
			self:MyExit()
			AchievementTGTestPanel.Create()
		end
	)	
	self:MyRefresh()
end

function C:MyRefresh()

end
--随机获取问题列表  
function C:GetQuestions()
	local _config = AchievementTGManager.InitCfg()
	local config = basefunc.deepcopy(_config)
	local _random_list = AchievementTGManager.GetRandomList(config.set[4].set, #config.question,true)
	self.random_list = _random_list
	local question = {}
	local maxscore = 0
	for i=1,#_random_list do
		question[i] = config.question[_random_list[i]]
		question[i].answer = question[i].option[question[i].answer]
		maxscore = maxscore + question[i].score
	end
	MaxScore = maxscore
	return question
end
--打乱答案选项
function C:ReformOption(question)
	self.Random_Options = {}
	for i=1,#question do
		math.randomseed(os.time() * 1)
		local _random_list 
		if false then 
			for i=1,#question[i].option do
				_random_list[i] = i
			end
		else		
			_random_list = AchievementTGManager.GetRandomList(#question[i].option, #question[i].option)	
		end		
		local temp_option = basefunc.deepcopy(question[i].option)
		for j=1,#question[i].option do			
			question[i].option[j] = temp_option[_random_list[j]]
		end
		self.Random_Options[i] = _random_list
	end
	return question
end
--计算分数
function C:CountScore(_Right_Answer_Map)
	self.UnRight_Answer = {}	
	local all_score = 0
	for i=1,#_Right_Answer_Map do
		if PlayerAnswer[i] == nil  then
			HintPanel.Create(1,"你第"..i.."题还没有完成哟")
			self:JumpTo(i)
			return 
		else
			if PlayerAnswer[i] == _Right_Answer_Map[i].right then 
				all_score = all_score + _Right_Answer_Map[i].score
			else
				local sczd_achievement_topic_data  = {
					topic_id = self.random_list[i],
					answer_id = self.Random_Options[i][PlayerAnswer[i]] 
				}
				self.UnRight_Answer[#self.UnRight_Answer + 1] =  sczd_achievement_topic_data
			end
		end 
	end
	return all_score
end
--初始化问答面板的UI相关,返回一个正确答案的列表
function C:InitFaqUI(question)
	local _RightMap = {}
	self.Question_UI = {}
	for i=1,#question do
		local temp = {}
		local b = GameObject.Instantiate(self.QuestionItem,self.Content)
		b.gameObject:SetActive(true)
		self.Question_UI[i] = b
		LuaHelper.GeneratingVar(b.transform, temp)
		temp.question_txt.text = "问题"..i..". "..question[i].ask
		local _right = self:InitOptionUI(i,question[i].option,temp.Q_Content,question[i].answer)
		_RightMap[i] = {right = _right,score = question[i].score}
	end
	return _RightMap
end
--初始化选项，并且返回一个正确答案
function C:InitOptionUI(question_no,option,content,answer)
	local _Right
	local Option_Items_UI = {}
	for i=1,#option do
		local temp = {}
		local b = GameObject.Instantiate(self.option,content)
		b.gameObject:SetActive(true)
		Option_Items_UI[i] = b
		LuaHelper.GeneratingVar(b.transform, temp)
		temp.answer_txt.text = ABCD[i]..option[i]
		temp.option_tge.group = content:GetComponent("ToggleGroup")
		temp.option_tge.onValueChanged:AddListener(
			function (val)
				self:PlayerChooseOption(val,question_no,i)
			end
		)
		if answer == option[i] then _Right = i end
	end
	return _Right
end
--玩家选择答案
function C:PlayerChooseOption(val,question_no,choose_no)
	if val then 
		PlayerAnswer[question_no] = choose_no
	else
		PlayerAnswer[question_no] = nil
	end
end

function C:ShowScore(score)
	local str = ""
	local config = AchievementTGManager.InitCfg()
	for i=1,3 do
		if score >= config.set[i].set[1] and score <= config.set[i].set[2] then
			self.score_txt.text = "本次获得分数: "..score
			self.show_txt.text = string.format(config.set[i].text,MaxScore - score)
			self.ShowScorePanel.gameObject:SetActive(true)
			return 
		end 
	end
end
--verticalNormalizedPosition
function C:JumpTo(question_no)
	local h = self.Question_UI[question_no].transform.localPosition.y 
	self.Content.transform.localPosition = Vector2.New(self.Content.transform.localPosition.x,-h)
end

--获取玩家的答案，答案的顺序按照配置表随机打乱前
function C:GetPlayerAnswerIDInConfig(Question_UI,Index)
	for	i = 1,Question_UI.transform.childCount do 
		Question_UI.transform:GetChild(i)
	end 	
end

