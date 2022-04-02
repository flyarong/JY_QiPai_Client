-- 创建时间:2020-06-22
-- Panel:Act_019_CHBTaskItem
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

Act_019_CHBTaskItem = basefunc.class()
local C = Act_019_CHBTaskItem
C.name = "Act_019_CHBTaskItem"
local M = Act_019_CHBManager

function C.Create(parent,data)
	return C.New(parent,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_chb_task_change_msg"] = basefunc.handler(self,self.on_model_chb_task_change_msg)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent,data)
	self.data = data
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.slider = self.Slider.transform:GetComponent("Slider")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.go_btn.gameObject).onClick = basefunc.handler(self, self.On_GoClick)
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.On_GetClick)

	self.award_img.sprite = GetTexture(self.data.award_img)
	self.award_txt.text = self.data.award_txt
	self.mission_txt.text = self.data.task_name
	self.slider_txt.text = M.GetTaskNowProgress(self.data.task_id).."/"..M.GetTaskTotalProgress(self.data.task_id)
	self.slider.value = M.GetTaskNowProgress(self.data.task_id)/M.GetTaskTotalProgress(self.data.task_id)
	local status = M.GetTaskAwardStatus(self.data.task_id)
	if status == 1 then
		self.get_btn.gameObject:SetActive(true)
		self.go_btn.gameObject:SetActive(false)
		self.gray_img.gameObject:SetActive(false)
	elseif status == 0 then
		self.go_btn.gameObject:SetActive(true)
		self.get_btn.gameObject:SetActive(false)
		self.gray_img.gameObject:SetActive(false)
	elseif status == 2 then
		self.gray_img.gameObject:SetActive(true)
		self.go_btn.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(false)
	end
	self:MyRefresh()
end

function C:MyRefresh()
end


function C:on_model_chb_task_change_msg(id)
	dump({id = id ,data = self.data },"<color=green>**********************</color>")
	if id == self.data.task_id then
		self.slider_txt.text = M.GetTaskNowProgress(self.data.task_id).."/"..M.GetTaskTotalProgress(self.data.task_id)
		self.slider.value = M.GetTaskNowProgress(self.data.task_id)/M.GetTaskTotalProgress(self.data.task_id)
		local status = M.GetTaskAwardStatus(self.data.task_id)
		if status == 1 then
			self.get_btn.gameObject:SetActive(true)
			self.go_btn.gameObject:SetActive(false)
			self.gray_img.gameObject:SetActive(false)
		elseif status == 0 then
			self.go_btn.gameObject:SetActive(true)
			self.get_btn.gameObject:SetActive(false)
			self.gray_img.gameObject:SetActive(false)
		elseif status == 2 then
			self.gray_img.gameObject:SetActive(true)
			self.go_btn.gameObject:SetActive(false)
			self.get_btn.gameObject:SetActive(false)
		end
	end
end


function C:On_GoClick()
	GameManager.CommonGotoScence({gotoui = self.data.GotoUI}, function ()
		Event.Brocast("act_019_chb_close")
	end)
end

function C:On_GetClick()
	Network.SendRequest("get_task_award", {id = self.data.task_id})
end