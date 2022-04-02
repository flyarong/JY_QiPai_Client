local basefunc = require "Game/Common/basefunc"
Act_017_HYZHPanel = basefunc.class()
local M = Act_017_HYZHPanel
M.name = "Act_017_HYZHPanel"
local Mgr = Act_017_HYZHManager

local instance
function M.Create(parent)
	if instance then
		instance:MyExit()
	end
	instance = M.New(parent)
	return instance
end

function M.Refresh()
	if instance then
		instance:MyRefresh()
	end
end

function M:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function M:MakeLister()
	self.lister = {}
end

function M:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function M:MyExit()
	if self.timer then 
		self.timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil

	 
end

function M:ctor(parent)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function M:InitUI()
	local v = Mgr.config.tge1[1]
	self.task_item = ActivityTaskItem.Create(self.task_node,v)
	dump(self.task_item,"<color>+++++++++++++++++++++++++++</color>")
	if not table_is_null(Mgr.children_list) then
		for i,vv in ipairs(Mgr.children_list) do
			dump(vv,"<color=white>？？？？？？？？？？？？？？？？？？？？</color>")
			self.cld_item = self.cld_item or {}
			local obj = newObject("Act_017_HYZHPlayerItem", self.sv_content)
			self.cld_item[i] = {}
			self.cld_item[i].gameObject = obj
			self.cld_item[i].transform = obj.transform
			LuaHelper.GeneratingVar(obj.transform, self.cld_item[i])
			self.cld_item[i].name_txt.text = vv.name
			self.cld_item[i].name_txt.fontSize = 28
			URLImageManager.UpdateHeadImage(vv.head_image,self.cld_item[i].head_img)
			self.cld_item[i].zh_btn.onClick:AddListener(function()
				local goto_ui
				if not table_is_null(v.gotoUI)  then
					goto_ui = v.gotoUI[1]
					if self.goto_scene_call and type(self.goto_scene_call) == "function" and GameManager.GotoSceneMap[goto_ui] then
						if GameManager.CheckActivityYear() then
							ActivityYearPanel.Close()
						else
							Event.Brocast("ui_button_data_change_msg",{key = M.key})
						end
						self.goto_scene_call()
					else
						GameManager.GotoUI({gotoui=goto_ui, goto_scene_parm=v.gotoUI[2]})
					end
				else
					LittleTips.Create("参数错误")
				end
			end)
		end
	end
	self:MyRefresh()
end

function M:MyRefresh()
	if not table_is_null(Mgr.children_list) then
		local tbl
		for i,v in ipairs(Mgr.children_list) do
			if self.cld_item[i] then
				tbl = self.cld_item[i]
				tbl.zh_btn.gameObject:SetActive(v.is_recall == 0)
				tbl.over_img.gameObject:SetActive(v.is_recall == 1)
			end
		end
	end
	if not table_is_null(Mgr.task_data) and self.task_item then
		self.task_item:MyRefresh(Mgr.task_data,20,1)
	end
end

function M:OnDestroy()
	self:MyExit()
end