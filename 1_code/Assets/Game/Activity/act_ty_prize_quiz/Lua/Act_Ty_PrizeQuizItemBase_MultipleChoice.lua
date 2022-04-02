-- 创建时间:2021-01-20
-- Panel:Act_Ty_PrizeQuizItemBase_MultipleChoice
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

Act_Ty_PrizeQuizItemBase_MultipleChoice = basefunc.class()
local C = Act_Ty_PrizeQuizItemBase_MultipleChoice
C.name = "Act_Ty_PrizeQuizItemBase_MultipleChoice"
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
		local cancel_btn = pre.transform:Find("content_txt/cancel_btn").transform:GetComponent("Button")
		selet_btn.onClick:AddListener(function ()	
			self:SetAnswer(true,i)
			self:RefreshOptions()
		end)
		cancel_btn.onClick:AddListener(function ()
			self:SetAnswer(false,i)
			self:RefreshOptions()
		end)
		self.Cell_list[#self.Cell_list + 1] = pre
	end
end

--刷新选项
function C:RefreshOptions()
	local answer = tostring(M.GetAnswer(self.index))
	for i=1,#self.Cell_list do
		for j=1,string.len(answer) do
			self.Cell_list[i].transform:Find("content_txt/selet_btn").gameObject:SetActive(not (i == tonumber(string.sub(answer,j,j))))
			self.Cell_list[i].transform:Find("content_txt/cancel_btn").gameObject:SetActive(i == tonumber(string.sub(answer,j,j)))
			if M.CheckIsAlreadyTJ() then
				local selet_btn = self.Cell_list[i].transform:Find("content_txt/selet_btn").transform:GetComponent("Button")
				local cancel_btn = self.Cell_list[i].transform:Find("content_txt/cancel_btn").transform:GetComponent("Button")
				selet_btn.enabled = false
				cancel_btn.enabled = false
			end
			if i == tonumber(string.sub(answer,j,j)) then
				break
			end
		end	
	end
end

function C:SetAnswer(is_add,index)
	self.Cell_list[index].transform:Find("content_txt/selet_btn").gameObject:SetActive(not is_add)
	self.Cell_list[index].transform:Find("content_txt/cancel_btn").gameObject:SetActive(is_add)
	local answer
	for i=1,#self.Cell_list do
		if not self.Cell_list[i].transform:Find("content_txt/selet_btn").gameObject.activeSelf and self.Cell_list[i].transform:Find("content_txt/cancel_btn").gameObject.activeSelf then
			if answer then
				answer = answer .. i
			else
				answer = i
			end
		end
	end
	--answer = tonumber(answer)
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
		content_txt_rect.sizeDelta = Vector2.New(800,content_txt_hight + h)
		pre_rect.sizeDelta = Vector2.New(0,content_txt_hight + h)
		options_hight = options_hight + content_txt_hight + h
	end
	self.choice_node.transform.localPosition = Vector3.New(-375, - (title_hight + h),0)
	bg_img_rect.sizeDelta = Vector2.New(851,title_txt_rect.sizeDelta.y + options_hight) 
	self.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New(850,title_txt_rect.sizeDelta.y + options_hight) 
end