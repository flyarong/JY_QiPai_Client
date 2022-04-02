-- 创建时间:2021-08-11
-- Panel:Act_064_Year3rdPanel
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

Act_064_Year3rdPanel = basefunc.class()
local C = Act_064_Year3rdPanel
C.name = "Act_064_Year3rdPanel"
local M = Act_064_Year3rdManager

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
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.huxiMrlb then
		self.huxiMrlb:Stop()
		self.huxiMrlb = nil
	end
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
	self.lv = M.CurLv()
	self.task_id = M.GetData(self.lv).task_id
	if self.lv < 7 then
		self.cur_lv = self.lv + 1
	else
		self.cur_lv = self.lv
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.get_btn.onClick:AddListener(function()
		--LittleTips.Create("8月31日7:30后可领")
		self:GetAward()
	end)
	self.l_btn.onClick:AddListener(function()
		self:OnClickLeft()
	end)
	self.r_btn.onClick:AddListener(function()
		self:OnClickRight()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefrehAward()
	--self:RefreshMrlb()
end

function C:ClearContent()
	local len = self.content.transform.childCount
	if len < 1 then
		return
	end
	for i = 1, len do
		local b = self.content.transform:GetChild(i - 1)
		destroy(b.gameObject)
		b = nil
	end
	len = nil
end

function C:GetAward()
	GameManager.GotoUI({gotoui = "act_065_znfk", goto_scene_parm = "begin"})
end

function C:RefrehAward()
	self:ClearContent()
	local data = M.GetData(self.cur_lv)
	self.vip_img.sprite = GetTexture(data.vip_icon)
	self.vip_img:SetNativeSize()
	for i = 1, #data.awardData do
		local b = newObject("Act_064_Year3rdItem", self.content.transform)
		local b_ui = {}
		LuaHelper.GeneratingVar(b.transform, b_ui)
		b_ui.icon_img.sprite = GetTexture(data.awardData[i].icon)
		b_ui.name_txt.text = data.awardData[i].tips[1]
		b_ui.tip_btn.onClick:AddListener(function()
			LTTipsPrefab.Show2(b_ui.tip_btn.transform,data.awardData[i].tips[1],data.awardData[i].tips[2])
		end)
	end
end

function C:OnClickLeft()
	if self.cur_lv == 1 then
		return
	end
	self.cur_lv = self.cur_lv - 1
	self:RefrehAward()
end

function C:OnClickRight()
	if self.cur_lv == 7 then
		return
	end
	self.cur_lv = self.cur_lv + 1
	self:RefrehAward()
end

--明日礼包
-- function C:RefreshMrlb()
-- 	local taskData = GameTaskModel.GetTaskDataByID(M.mrlb_task)
-- 	if taskData then
-- 		self.mrlb_gray.gameObject:SetActive(taskData.award_status ~= 1)
-- 		self.mrlb_btn.gameObject:SetActive(taskData.award_status == 1)
-- 		if taskData.award_status == 1 then
-- 			self.huxiMrlb = CommonHuxiAnim.Go(self.mrlb_img.gameObject)
-- 			self.huxiMrlb:Start()
-- 		end

-- 		if taskData.award_status ~= 1 and self.huxiMrlb then
-- 			self.huxiMrlb:Stop()
-- 			self.huxiMrlb = nil
-- 		end
-- 	end
-- end

function C:on_model_task_change_msg(data)
	if data and data.id == self.task_id then
		--self:RefreshMrlb()
		--self:RefrehAward()
		Event.Brocast("global_hint_state_change_msg",{gotoui = M.key })
	end
end
