-- 创建时间:2020-03-03
-- Panel:Act_003ZSLWPanel
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

Act_003ZSLWPanel = basefunc.class()
local C = Act_003ZSLWPanel
C.name = "Act_003ZSLWPanel"
local M = Act_003ZSLWManager
local award_data = {
	[1] = {[1] = {info = "李逵出现1次",award_img = "pay_icon_gold2",not_award_img = "hhsl_icon_gold1",award_txt = "1000鲸币"},
		 [2] =	{info = "李逵出现3次",award_img = "pay_icon_gold3",not_award_img = "hhsl_icon_gold2",award_txt = "3000鲸币"}	
	},
	[2] = {[1] = {info = "武松出现1次",award_img = "pay_icon_gold2",not_award_img = "hhsl_icon_gold1",award_txt = "1000鲸币"},
		 [2] =	{info = "武松出现3次",award_img = "pay_icon_gold3",not_award_img = "hhsl_icon_gold2",award_txt = "3000鲸币"}	
	},
	[3] = {[1] = {info = "宋江出现1次",award_img = "pay_icon_gold2",not_award_img = "hhsl_icon_gold1",award_txt = "1000鲸币"},
		 [2] =	{info = "宋江出现3次",award_img = "pay_icon_gold3",not_award_img = "hhsl_icon_gold2",award_txt = "3000鲸币"}	
	},
	[4] = {[1] = {info = "鲁智深出现1次",award_img = "pay_icon_gold2",not_award_img = "hhsl_icon_gold1",award_txt = "1000鲸币"},
		 [2] =	{info = "鲁智深出现3次",award_img = "pay_icon_gold3",not_award_img = "hhsl_icon_gold2",award_txt = "3000鲸币"}	
	}
}
local left = -364.87
local right = -1095
function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	--self.lister["model_task_change_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AssetsGetPanelConfirmCallback)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
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
	if self.seq then
		self.seq:OnKill()
	end

	 
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local temp_ui = {}
	self.taskitem_Node = {}
	self.award_items = {}
	for i = 1,4 do
		local b = GameObject.Instantiate(self.taskitem,self.Node)
		b.gameObject:SetActive(true)
		self.taskitem_Node[#self.taskitem_Node + 1] = b.transform:Find("Viewport/@task_node")
		b.gameObject:AddComponent(typeof(UnityEngine.UI.Button))
		b.gameObject.transform:GetComponent("Button").onClick:AddListener(
			function ()
				for j = 1 ,2 do
					local data = GameTaskModel.GetTaskDataByID(M.task_ids[i][j])
					if data.award_status == 1 then 
						Network.SendRequest("get_task_award",{id = M.task_ids[i][j]})
						if j == 1 then
							self.WillMoveNode = self.taskitem_Node[i]
						end
						return
					end
				end
			end
		)
		self.ywc.gameObject:SetActive(false)
		for j = 1 ,2 do 
			local b1 = GameObject.Instantiate(self.award_item,self.taskitem_Node[i])
			b1.gameObject:SetActive(true)
			LuaHelper.GeneratingVar(b1.transform, temp_ui)
			dump(award_data[i][j])
			self.award_items[M.task_ids[i][j]] = b1
			b1.name = M.task_ids[i][j]
			temp_ui.award_task_txt.text = award_data[i][j].info
			temp_ui.gray_award_img.sprite = GetTexture(award_data[i][j].not_award_img) 
			temp_ui.award_img.sprite = GetTexture(award_data[i][j].award_img) 
			temp_ui.award_txt.text = award_data[i][j].award_txt
			temp_ui.gray_award_txt.text = award_data[i][j].award_txt
			temp_ui.get_award_btn.onClick:AddListener(
				function ()
					Network.SendRequest("get_task_award",{id = M.task_ids[i][j]})
					if j == 1 then
						self.WillMoveNode = self.taskitem_Node[i]
					end
				end
			)
		end 
	end
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.go_btn.onClick:AddListener(
		function()
			GameManager.CommonGotoScence({gotoui="game_EliminateSH"})
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	local temp_ui = {}
	for i = 1,4 do
		local total_data =  GameTaskModel.GetTaskDataByID(M.only_show_task_ids[i])
		if total_data then 
			self["hero_"..i.."_txt"].text = "("..total_data.now_total_process..")"
		end
		for j = 1,2 do 
			local data = GameTaskModel.GetTaskDataByID(M.task_ids[i][j])
			dump(M.task_ids[i][j],"<color=red>任务ID</color>")
			dump(data,"<color=red>任务数据</color>")
			if data then
				LuaHelper.GeneratingVar(self.award_items[M.task_ids[i][j]].transform, temp_ui)
				if data.award_status == 1 then	
					temp_ui.get_award_btn.gameObject:SetActive(true)
				elseif data.award_status == 0 then 
					temp_ui.get_award_btn.gameObject:SetActive(false)
				else
					temp_ui.get_award_btn.gameObject:SetActive(false)
					temp_ui.ywc.gameObject:SetActive(true)
					--如果是左边的完成了
					if j == 1 then 
						self.taskitem_Node[i].gameObject.transform.localPosition = Vector2.New((right - left),self.taskitem_Node[i].gameObject.transform.localPosition.y)
					end
				end
			end 
		end 
	end 
end

function C:MoveAnim(obj)
	local v = obj.transform.localPosition.x + (right - left)
	self.seq = DoTweenSequence.Create()
	self.seq:Append(obj.transform:DOLocalMoveX(v, 0.6))
	self.seq:OnKill(function ()
		self:MyRefresh()
		self.seq = nil
	end)
end

function C:AssetsGetPanelConfirmCallback()
	if self.WillMoveNode then
		self:MoveAnim(self.WillMoveNode)
		self.WillMoveNode = nil
	else
		self:MyRefresh()
	end
end