-- 创建时间:2021-01-20
-- Panel:Act_Ty_PrizeQuizItemBase_SingleChoice
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

Act_Ty_PrizeQuizItemBase_SingleChoice = basefunc.class()
local C = Act_Ty_PrizeQuizItemBase_SingleChoice
C.name = "Act_Ty_PrizeQuizItemBase_SingleChoice"
local M = Act_Ty_PrizeQuizManager

function C.Create(panelSelf,parent,config,index)
	return C.New(panelSelf,parent,config,index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["prize_quiz_had_tj_msg"] = basefunc.handler(self,self.RefreshOptions)
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

function C:ctor(panelSelf,parent,config,index)
	ExtPanel.ExtMsg(self)
	self.panelSelf = panelSelf
	self.config = config
	self.index = index
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.title_txt.text = self.index.."."..self.config.title
	self:CreateOptionsPrefab()
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshOptions()
	self:RefreshLayOut()
end

function C:CreateOptionsPrefab()
	self.Cell_list = {}
	for i=1,#self.config.choice do
		local pre = GameObject.Instantiate(self.choice, self.choice_node.transform)
		pre.gameObject:SetActive(true)
		pre.transform:Find("content_txt").transform:GetComponent("Text").text = self.config.choice[i]
		local selet_btn = pre.transform:Find("content_txt/selet_btn").transform:GetComponent("Button")
		selet_btn.onClick:AddListener(function ()
			self:SetAnswer(i)
			self:RefreshOptions()
		end)
		self.Cell_list[#self.Cell_list + 1] = pre
	end
end

--刷新选项
function C:RefreshOptions()
	for i=1,#self.Cell_list do
		self.Cell_list[i].transform:Find("content_txt/selet_btn").gameObject:SetActive(not (i == M.GetAnswer(self.index)))
		self.Cell_list[i].transform:Find("content_txt/selet_img").gameObject:SetActive(i == M.GetAnswer(self.index))
		if M.CheckIsAlreadyTJ() then
			local select_btn = self.Cell_list[i].transform:Find("content_txt/selet_btn").transform:GetComponent("Button")
			select_btn.enabled = false
		end
	end
end

function C:SetAnswer(answer)
	M.SetAnswer(self.index,answer)
end

--刷新布局
function C:RefreshLayOut()
	local options_hight = 0
	local h = 30 --空白(为了看上去更美观)
	local bg_img_rect = self.bg_img.gameObject:GetComponent("RectTransform")
	local title_txt_rect = self.title_txt.gameObject:GetComponent("RectTransform")
	local title_hight = self.title_txt.transform:GetComponent("Text").preferredHeight
	local choice_node_rect = self.choice_node.gameObject:GetComponent("RectTransform")
	title_txt_rect.sizeDelta = Vector2.New(title_txt_rect.sizeDelta.x,title_hight + h)
	for i=1,#self.Cell_list do
		local pre = self.Cell_list[i]
		local content_txt = pre.transform:Find("content_txt").gameObject
		local pre_rect = pre.gameObject:GetComponent("RectTransform")
		local content_txt_rect = content_txt.gameObject:GetComponent("RectTransform")
		local content_txt_hight = content_txt.transform:GetComponent("Text").preferredHeight
		content_txt_rect.sizeDelta = Vector2.New(780,content_txt_hight + h)
		pre_rect.sizeDelta = Vector2.New(0,content_txt_hight + h)
		options_hight = options_hight + content_txt_hight + h
	end
	self.choice_node.transform.localPosition = Vector3.New(-375, - (title_hight + h),0)
	bg_img_rect.sizeDelta = Vector2.New(851,title_txt_rect.sizeDelta.y + options_hight) 
	self.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New(850,title_txt_rect.sizeDelta.y + options_hight) 
end