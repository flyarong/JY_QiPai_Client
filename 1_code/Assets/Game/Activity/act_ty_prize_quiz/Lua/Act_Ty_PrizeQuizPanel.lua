-- 创建时间:2021-01-20
-- Panel:Act_Ty_PrizeQuizPanel
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

Act_Ty_PrizeQuizPanel = basefunc.class()
local C = Act_Ty_PrizeQuizPanel
C.name = "Act_Ty_PrizeQuizPanel"
local M = Act_Ty_PrizeQuizManager

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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["prize_quiz_had_tj_msg"] = basefunc.handler(self,self.on_prize_quiz_had_tj_msg)
    self.lister["prize_quiz_had_got_msg"] = basefunc.handler(self,self.on_prize_quiz_had_got_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.huxi then
		self.huxi.Stop()
	end
	self:CloseTopicPrefab()
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
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	M.InitUIConfig()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.tj_btn.gameObject).onClick = basefunc.handler(self, self.OnTJClick)
	EventTriggerListener.Get(self.bx_btn.gameObject).onClick = basefunc.handler(self, self.OnBXClick)

	CommonTimeManager.GetCutDownTimer(M.end_time,self.T1_txt)

	self.tip_txt.text = "最高50万鲸币"
	self:MyRefresh()

	
end

function C:MyRefresh()
	self:CreateTopicPrefab()
	self:RefreshButton()

	if M.CheckIsAlreadyTJ() then
		self.tj_btn_gray.gameObject:SetActive(true)
	else
		self.tj_btn_gray.gameObject:SetActive(false)
	end

	self:RefreshBoxUI()
end


function C:OnTJClick()
	if M.CheckIsAllTopicFinish() then
		M.TopicTJ()
	else
		LittleTips.Create("请完成所有题目后再提交～")
	end
end

function C:OnBXClick()
	if M.CheckIsAlreadyTJ() then
		M.GetAward()
	else
		LittleTips.Create("请提交后再领～")
	end
end

function C:RefreshButton()
	self.ylq_img.gameObject:SetActive(M.CheckIsAlreadyGet())
end

function C:RefreshBoxUI()
	if M.CheckIsAlreadyGet() then
		self.bx_qp.gameObject:SetActive(false)
	end

	if self.huxi then
		self.huxi.Stop()
	end
	if M.CheckIsAlreadyTJ() and not  M.CheckIsAlreadyGet() then
		self.huxi =  CommonHuxiAnim.Go(self.bx_btn.gameObject,1)
		self.huxi.Start()
		self.tip_txt.text = "领福利"
	end
end

function C:CreateTopicPrefab()
	self:CloseTopicPrefab()
	local topic_tab = M.GetTopicTotal()
	local topic_bank = M.GetTopicBank()
	for i=1,#topic_tab do
		local topic = topic_bank[topic_tab[i]]
		local panelName = "Act_Ty_PrizeQuizItemBase_" .. topic.type
		if _G[panelName] then
			if _G[panelName].Create then 
				local pre = _G[panelName].Create(self,self.Content.transform,topic,i)
				self.topic_cell[#self.topic_cell + 1] = pre
			else
				dump("<color=red>该脚本没有实现Create</color>")
			end
		else
			dump("<color=red>该脚本没有载入</color>")
		end
	end
end

function C:CloseTopicPrefab()
	if self.topic_cell then
		for k,v in pairs(self.topic_cell) do
			v:MyExit()
		end
	end
	self.topic_cell = {}
end

function C:on_prize_quiz_had_tj_msg()
	self:MyRefresh()
end

function C:on_prize_quiz_had_got_msg()
	self:RefreshButton()
	self:RefreshBoxUI()
end