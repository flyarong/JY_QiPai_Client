local basefunc = require "Game/Common/basefunc"

Act_003ZSHMMyListPanel = basefunc.class()
local C = Act_003ZSHMMyListPanel
C.name = "Act_003ZSHMMyListPanel"
local Page_Index  =  1
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
	self.lister["common_lottery_query_my_award_logs_response"] = basefunc.handler(self,self.onGetInfo)
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

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	Page_Index  =  1
	LuaHelper.GeneratingVar(self.transform, self)	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("common_lottery_query_my_award_logs",{lottery_type = "box_exchange_14",is_shiwu = 1})
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self:MyRefresh()
end
 
function C:onGetInfo(_,data)
	dump(data,"<color=red>我的获奖</color>")
	if data and data.result == 0 then
		local task_data = GameTaskModel.GetTaskDataByID(Act_003ZSHMManager.task_id)
		if task_data then 
			if task_data.award_status == 2 then 
				data.award_logs[#data.award_logs + 1] = {award_name = "零食礼包",count = 1}
			end 
		end  
		Page_Index = Page_Index + 1
		for i=1,#data.award_logs do
			local b = GameObject.Instantiate(self.item,self.content)
			b.gameObject:SetActive(true)
			local temp_ui = {}
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			temp_ui.time_txt.text = os.date("%Y-%m-%d  %X",data.award_logs[i].time)
			temp_ui.count_txt.text = data.award_logs[i].count 
			temp_ui.award_name_txt.text = data.award_logs[i].award_name  
		end
		if table_is_null(data.award_logs) then 
			LittleTips.Create("暂无新数据")
		end
	end 
end
 
function C:MyRefresh()
end