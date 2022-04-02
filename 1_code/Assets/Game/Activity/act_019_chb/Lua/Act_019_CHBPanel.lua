-- 创建时间:2020-06-22
-- Panel:Act_019_CHBPanel
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

Act_019_CHBPanel = basefunc.class()
local C = Act_019_CHBPanel
C.name = "Act_019_CHBPanel"
local M = Act_019_CHBManager


function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["act_019_chb_close"] = basefunc.handler(self,self.MyExit)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["model_chb_unrealy_change_msg"] = basefunc.handler(self,self.on_model_chb_unrealy_change_msg)
    self.lister["model_chb_isOnefinish_msg"] = basefunc.handler(self,self.on_model_chb_isOnefinish_msg)--排序
    self.lister["model_chb_hb_status_msg"] = basefunc.handler(self,self.on_model_chb_hb_status_msg)
    self.lister["chb_hb_is_got_msg"] = basefunc.handler(self,self.on_chb_hb_is_got_msg)--领取回调
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
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
	M.update_time_UnrealyData(false)
	self:CloseItemPrefab()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self.task_ids = M.GetTaskIDs()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.On_BackClick)
	EventTriggerListener.Get(self.chb_btn.gameObject).onClick = basefunc.handler(self, self.On_ChbClick)
	EventTriggerListener.Get(self.more_btn.gameObject).onClick = basefunc.handler(self, self.On_MoreClick)
	
	M.update_time_UnrealyData(true)
	if M.GetHBAwardStatus() == 2 then
		self.AfterGetPanel.gameObject:SetActive(true)
		self.BeforeGetPanle.gameObject:SetActive(false)
		self.award_txt.text = M.GetAwardTXT().."福卡"
	elseif M.GetHBAwardStatus() == 1 or M.GetHBAwardStatus() == 0 then
		self.AfterGetPanel.gameObject:SetActive(false)
		self.BeforeGetPanle.gameObject:SetActive(true)
	end
	self:MyRefresh()
end

function C:MyRefresh()
	self:Sort()
	self:CreateItemPrefab()
end

function C:CreateItemPrefab()
	self:CloseItemPrefab()
	for i=1,#self.task_ids do
		local pre = Act_019_CHBTaskItem.Create(self.sv_content.transform,M.UIConfig[self.task_ids[i]])
		if pre then
			self.spawn_cell_list[#self.spawn_cell_list + 1] = pre
		end
	end
end

function C:CloseItemPrefab()
	if self.spawn_cell_list then
		for k,v in ipairs(self.spawn_cell_list) do
			v:MyExit()
		end
	end
	self.spawn_cell_list = {}
end

--虚假数据跑马灯
function C:on_model_chb_unrealy_change_msg()
	self.Lantern.gameObject:SetActive(true)
	self.Lantern2_txt.text = "恭喜<color=#e7ff62>"..(M.GetUnrealyPlayerName() or "").."</color>拆开福卡,获得<color=#ffc617>"..(M.GetUnrealyAwardName() or "").."福卡</color>"
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.Lantern.transform:DOLocalMoveY(57.7,1.5))
	self.seq:OnKill(function ()
		if IsEquals(self.gameObject) then
			self.Lantern1_txt.text = self.Lantern2_txt.text
			self.Lantern.transform.localPosition = Vector3.New(0,0,0)
		end
	end)
end

function C:On_BackClick()
	self:MyExit()
end

function C:on_model_chb_isOnefinish_msg()
	self:MyRefresh()
end

local m_sort = function(v1,v2)
	if M.GetTaskAwardStatus(v1) == 2 and M.GetTaskAwardStatus(v2) == 2 then
		if v1 < v2 then
			return false
		else
			return true
		end
	elseif M.GetTaskAwardStatus(v1) == 1 and M.GetTaskAwardStatus(v2) == 1 then
		if v1 < v2 then
			return false
		else
			return true
		end
	elseif M.GetTaskAwardStatus(v1) == 0 and M.GetTaskAwardStatus(v2) == 0 then
		if v1 < v2 then
			return false
		else
			return true
		end
	elseif  M.GetTaskAwardStatus(v1) == 1 and M.GetTaskAwardStatus(v2) == 2 then
		return false
	elseif  M.GetTaskAwardStatus(v1) == 2 and M.GetTaskAwardStatus(v2) == 1 then
		return true
	elseif  M.GetTaskAwardStatus(v1) == 1 and M.GetTaskAwardStatus(v2) == 0 then
		return false
	elseif  M.GetTaskAwardStatus(v1) == 0 and M.GetTaskAwardStatus(v2) == 1 then
		return true
	elseif  M.GetTaskAwardStatus(v1) == 0 and M.GetTaskAwardStatus(v2) == 2 then
		return false
	elseif  M.GetTaskAwardStatus(v1) == 2 and M.GetTaskAwardStatus(v2) == 0 then
		return true
	end
end

function C:Sort()
	MathExtend.SortListCom(self.task_ids, m_sort)
end

function C:On_ChbClick()
	if M.GetHBAwardStatus() == 1 then
		M.GetHBAward()
	elseif M.GetHBAwardStatus() == 0 then
		LittleTips.Create("完成当日所有任务可拆")
	end
end

function C:On_MoreClick()
	GameManager.GotoUI({gotoui = "game_MiniGame"})
end


function C:on_model_chb_hb_status_msg()
	dump(M.GetHBAwardStatus(),"<color=blue>+++++++++++++++++++++++++++++</color>")
	if M.GetHBAwardStatus() == 0 or M.GetHBAwardStatus() == 1 then
		self.BeforeGetPanle.gameObject:SetActive(true)
		self.AfterGetPanel.gameObject:SetActive(false)
	elseif M.GetHBAwardStatus() == 2 then
		self.BeforeGetPanle.gameObject:SetActive(false)
		self.AfterGetPanel.gameObject:SetActive(true)
		self.award_txt.text = M.GetAwardTXT().."福卡"
	end
end


function C:on_chb_hb_is_got_msg()
	self.BeforeGetPanle.gameObject:SetActive(false)
	self.AfterGetPanel.gameObject:SetActive(true)
end