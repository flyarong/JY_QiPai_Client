-- 创建时间:2021-01-20
-- Act_Ty_PrizeQuizManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_Ty_PrizeQuizManager = {}
local M = Act_Ty_PrizeQuizManager
M.key = "act_ty_prize_quiz"
M.config = GameButtonManager.ExtLoadLua(M.key,"act_ty_prize_quiz_config")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_PrizeQuizPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_PrizeQuizItemBase_SingleChoice")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_PrizeQuizItemBase_MultipleChoice")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_PrizeQuizItemBase_FillBlanks")

local this
local lister

M.end_time = 0

-- 是否有活动
function M.IsActive()
    return M.CheckPermissionToInit()
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    --dump(parm,"<color=red>PPPPPPPPPPPPPPPPPPPPPPPPPPParmQue</color>")
    if not M.CheckIsShow() then return end
    if parm.goto_scene_parm == "panel" then
        return Act_Ty_PrizeQuizPanel.Create(parm.parent,parm.backcall)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanGetAward() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function M.SetFAQIndex()
    SYSACTBASEManager.ForceToChangeIndex(M.key,6,function()
        if M.CheckIsAlreadyGet() then
            return true
        end
    end)
end


local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end

local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["common_question_answer_topic_response"] = this.on_common_question_answer_topic_response
    lister["model_get_task_award_response"] = this.on_model_get_task_award_response
end

function M.Init()
	M.Exit()

	this = Act_Ty_PrizeQuizManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    M.SetFAQIndex()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}

    if not M.CheckPermissionToInit() then return end
    M.InitAnswer()
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.CheckPermissionToInit()
    local cur_t = os.time()
    for i,v in ipairs(M.config.permission) do
        if cur_t >= v.beginTime and cur_t <= v.endTime then
            M.end_time = v.endTime
            M.topic = v.topic
            M.award_task_id = v.award_task_id
            M.act_type = v.act_type
            return true
            -- local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condi_key, is_on_hint = true}, "CheckCondition")
            -- if a and b then
            --     M.topic = v.topic
            --     M.award_task_id = v.award_task_id
            --     M.act_type = v.act_type
            --     return true
            -- end
        end
    end
    return false
end


--判断奖励是否已经领取
function M.CheckIsAlreadyGet()
    local data = GameTaskModel.GetTaskDataByID(M.award_task_id)
    if data and data.award_status and data.award_status == 2 then
        return true
    else
        return false
    end
end

--是否可以领奖
function M.IsCanGetAward()
    if M.CheckIsAlreadyTJ() and not M.CheckIsAlreadyGet() then
        return true
    end
    return false
end

--判断是否已经提交
function M.CheckIsAlreadyTJ()
    return (PlayerPrefs.GetInt("prize_quiz"..MainModel.UserInfo.user_id.."topic_had_tj",0) == 1)
end

--判断是否所有题都完成了
function M.CheckIsAllTopicFinish()
    for k,v in pairs(this.m_data.answer) do
        if v == "no_answer" then
            return false
        end
    end
    return true
end

function M.InitAnswer()
    this.m_data.answer = {}
    for i=1,M.GetQuizTotalCount() do
        if PlayerPrefs.GetInt("prize_quiz"..MainModel.UserInfo.user_id.."topic"..i,0) ~= 0 then
            this.m_data.answer[#this.m_data.answer + 1] = PlayerPrefs.GetInt("prize_quiz"..MainModel.UserInfo.user_id.."topic"..i)
        elseif PlayerPrefs.GetString("prize_quiz"..MainModel.UserInfo.user_id.."topic"..i,"") ~= "" then
            this.m_data.answer[#this.m_data.answer + 1] = PlayerPrefs.GetString("prize_quiz"..MainModel.UserInfo.user_id.."topic"..i)
        else
            this.m_data.answer[#this.m_data.answer + 1] = "no_answer"
        end
    end
end

function M.DeletAnswer()
    for i=1,M.GetQuizTotalCount() do
        PlayerPrefs.DeleteKey("prize_quiz"..MainModel.UserInfo.user_id.."topic"..i)
    end
    M.InitAnswer()
end

--获取答案(主要用作刷新显示)
function M.GetAnswer(index)
    return this.m_data.answer[index]
end

--设置答案(1.以便检查题是否全答完  2.作为数据发给服务器)
--index是第几题
function M.SetAnswer(index,content)
    this.m_data.answer[index] = content
    if type(content) == "number" then
        PlayerPrefs.SetInt("prize_quiz"..MainModel.UserInfo.user_id.."topic"..index,content)
    elseif type(content) == "string" then
        PlayerPrefs.SetString("prize_quiz"..MainModel.UserInfo.user_id.."topic"..index,content)
    end
end

--获取题
function M.GetTopicTotal()
    return M.topic
end

--获取题库
function M.GetTopicBank()
    return M.config.topic_bank
end

--获取题目总数量
function M.GetQuizTotalCount()
    return #M.GetTopicTotal()
end

--提交
function M.TopicTJ()
    local tab = {}
    for i=1,#this.m_data.answer do
        if type(this.m_data.answer[i]) == "number" then
            tab[#tab + 1] = {topic_id = i,answer_id = this.m_data.answer[i],is_right = 1}
        elseif type(this.m_data.answer[i]) == "string" then
            tab[#tab + 1] = {topic_id = i,answer_str = this.m_data.answer[i],is_right = 1}
        end
    end
    --dump(tab,"<color=yellow><size=15>++++++++++tab++++++++++</size></color>")
    Network.SendRequest("common_question_answer_topic",{act_type = M.act_type,is_all_right = 1,topic_data = tab})
end

function M.on_common_question_answer_topic_response(_,data)
    --dump(data,"<color=yellow><size=15>++++++++++on_common_question_answer_topic_response++++++++++</size></color>")
    if data and data.result == 0 then
        if data.act_type == M.act_type then
            PlayerPrefs.SetInt("prize_quiz"..MainModel.UserInfo.user_id.."topic_had_tj",1)
            M.DeletAnswer()
            Event.Brocast("prize_quiz_had_tj_msg")
            M.SetHintState()
            LittleTips.Create("提交成功~")
        end
    end
end

function M.GetAward()
    Network.SendRequest("get_task_award",{id = M.award_task_id})
end

function M.on_model_get_task_award_response(data)
    if data and data.result == 0 then
        if data.id == M.award_task_id then
            Event.Brocast("prize_quiz_had_got_msg")
            Event.Brocast("ui_button_data_change_msg", { key = M.key })
            M.SetHintState()
        end
    end
end