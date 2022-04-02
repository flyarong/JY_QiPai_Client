-- 创建时间:2019-12-27
-- Panel:CJS_GFJBPrefab
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

CJS_GFJBPrefab = basefunc.class()
local C = CJS_GFJBPrefab
C.name = "CJS_GFJBPrefab"
local task_id
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
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	print("<color=red>-------瓜分金币退出成功----</color>")
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	task_id = CJS_GFJBManager.GetGFTaskID()
	if task_id then 
		Network.SendRequest("query_one_task_data", {task_id = task_id})
	end
	self.Anim_huxi = self.get_award_btn.gameObject.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.list_btn.onClick:AddListener(
		function ()
			CJS_GFJBListPanel.Create()
		end
	)
	self.help_btn.onClick:AddListener(
		function ()
			CJS_GFJBHelpPanel.Create()
		end
	)
	self.get_award_btn.onClick:AddListener(
		function ()
			if task_id then 
				local data = GameTaskModel.GetTaskDataByID(task_id)
				if data then 
					if data.award_status == 1 then 
						Network.SendRequest("get_task_award", {id = task_id})
					elseif data.award_status == 2 then 
						HintPanel.Create(1,"今天的任务完成了，请明天再来看看吧")
					else
						HintPanel.Create(1,"完成4个任务后，即可瓜分鲸币，最高1000万！")
					end 
				else
					print(task_id,"<color=red>任务ID------</color>")
				end 
			else
				print("<color=red>EEE....瓜分金币领取异常，没有取得对应的等级标签</color>")
			end 
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	if task_id then 
		local data = GameTaskModel.GetTaskDataByID(task_id)
		if data then 
			if data.award_status == 1 then 
				self.get_award_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("gfjb_btn_gfjc_1")
				self.yan.gameObject:SetActive(true)
				self.Anim_huxi.enabled = true
			elseif data.award_status == 2 then 
				self.get_award_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("gfjb_btn_gfjc_2")
				self.yan.gameObject:SetActive(false)
				self.Anim_huxi.enabled = false
			else
				self.get_award_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture("gfjb_btn_gfjc_1")
				self.yan.gameObject:SetActive(false)
				self.Anim_huxi.enabled = false
			end 
		else
			print(task_id,"<color=red>任务ID------</color>")
		end 
	end 
end

function C:on_global_hint_state_change_msg(parm)
	if parm and parm.gotoui == CJS_GFJBManager.key then 
		self:MyRefresh()
	end 
end