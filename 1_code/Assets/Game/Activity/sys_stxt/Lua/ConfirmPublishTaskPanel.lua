local basefunc = require "Game/Common/basefunc"

ConfirmPublishTaskPanel = basefunc.class()
local C = ConfirmPublishTaskPanel
C.name = "ConfirmPublishTaskPanel"

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
	self.lister["query_task_info_response"] = basefunc.handler(self,self.on_query_task_info_response)
	self.lister["dis_task_info_response"] = basefunc.handler(self,self.on_dis_task_info_response)
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

function C:ctor(parent,data)

	ExtPanel.ExtMsg(self)

	local parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.data = data
	LuaHelper.GeneratingVar(self.transform, self)
	self.CAN_PUbLISH = false
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("query_task_info",{apprentice_id = self.data})
end

function C:InitUI()
	self.refuse_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.confirm_btn.onClick:AddListener(
		function ()
			if self.CAN_PUbLISH then 
				Network.SendRequest("dis_task_info",{apprentice_id = self.data})
				Event.Brocast("tp_CloseTHENOpen")
			else
			
			end 
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_query_task_info_response(_,data)
	self.CAN_PUbLISH = true
end

function C:on_dis_task_info_response(_,data)
	dump(data,"<color=red>on_dis_task_info_response</color>")
	if data and data.result == 0 and  data.task_data then 
		TpTaskPanel.Create(nil,data.task_data,"Teacher",self.data)
		self:MyExit()
	else
		HintPanel.Create(1,"发布任务失败")
	end 
end