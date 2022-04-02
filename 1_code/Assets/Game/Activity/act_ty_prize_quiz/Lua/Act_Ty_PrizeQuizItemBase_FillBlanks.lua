-- 创建时间:2021-01-20
-- Panel:Act_Ty_PrizeQuizItemBase_FillBlanks
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

Act_Ty_PrizeQuizItemBase_FillBlanks = basefunc.class()
local C = Act_Ty_PrizeQuizItemBase_FillBlanks
C.name = "Act_Ty_PrizeQuizItemBase_FillBlanks"
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
    self.lister["prize_quiz_had_tj_msg"] = basefunc.handler(self,self.RefreshInput)
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
	
	self.inputField = self.InputField.transform:GetComponent("InputField")

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.title_txt.text = self.index.."."..self.config.title
	self.inputField.characterLimit = self.config.limit or 1000--1000是为了保险,防止策划忘记配字数限制而向服务器传一本小说
	self.Placeholder_txt.text = self.config.placeholder_desc
	self.inputField.onEndEdit:AddListener(function ()
		self:SetAnswer(self.content_txt.text)
	end)
	self.inputField.onValueChanged:AddListener(function (val)
		local _,count = string.gsub(val, "[^\128-\193]", "")
		--if string.len(val) >= self.config.limit then
		if count >= self.config.limit then
			LittleTips.Create("字数已达上限～")
		end
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	if M.GetAnswer(self.index) ~= "no_answer" then
		self.content_txt.text = M.GetAnswer(self.index)
	else
		self.content_txt.text = nil
	end
	self:RefreshLayOut()
	self:RefreshInput()
end

function C:RefreshInput()
	self.inputField.enabled = not M.CheckIsAlreadyTJ()
end

function C:SetAnswer(answer)
	local answer = basefunc.string.trim(answer)
	M.SetAnswer(self.index,answer)
end

--刷新布局
function C:RefreshLayOut()
	local blanks_hight = 240
	local h = 30 --空白(为了看上去更美观)
	local bg_img_rect = self.bg_img.gameObject:GetComponent("RectTransform")
	local title_txt_rect = self.title_txt.gameObject:GetComponent("RectTransform")
	local title_hight = self.title_txt.transform:GetComponent("Text").preferredHeight
	local InputField_rect = self.InputField.gameObject:GetComponent("RectTransform")
	title_txt_rect.sizeDelta = Vector2.New(title_txt_rect.sizeDelta.x,title_hight + h)
	self.InputField.transform.localPosition = Vector3.New(0, - (title_hight),0)
	InputField_rect.sizeDelta = Vector2.New(850,blanks_hight)
	bg_img_rect.sizeDelta = Vector2.New(851,title_txt_rect.sizeDelta.y + blanks_hight) 
	self.gameObject:GetComponent("RectTransform").sizeDelta = Vector2.New(850,title_txt_rect.sizeDelta.y + blanks_hight) 
end