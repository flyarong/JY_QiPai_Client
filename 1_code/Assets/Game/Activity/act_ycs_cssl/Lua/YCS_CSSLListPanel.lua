local basefunc = require "Game/Common/basefunc"

YCS_CSSLListPanel = basefunc.class()
local C = YCS_CSSLListPanel
C.name = "YCS_CSSLListPanel"
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
	self.lister["common_lottery_query_award_logs_response"] = basefunc.handler(self,self.onGetInfo)
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
	Network.SendRequest("common_lottery_query_award_logs",{page_index = Page_Index,lottery_type = "box_exchange_11"})
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.my_list_btn.onClick:AddListener(
		function ()
			self:MyExit()
			YCS_CSSLMyListPanel.Create()
		end
	)
	self.sv = self.sc:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition  
		if VNP <= 0 then 
			Network.SendRequest("common_lottery_query_award_logs",{page_index = Page_Index,lottery_type = "box_exchange_11"})		
		end
	end
	self:MyRefresh()
end
 
function C:onGetInfo(_,data)
	dump(data,"<color=red>获奖名单</color>")
	if data and data.result == 0 then 
		Page_Index = Page_Index + 1
		for i=1,#data.award_logs do
			local b = GameObject.Instantiate(self.item,self.content)
			b.gameObject:SetActive(true)
			local temp_ui = {}
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			temp_ui.time_txt.text = os.date("%Y-%m-%d  %X",data.award_logs[i].time)
			temp_ui.award_txt.text = data.award_logs[i].award_name 
			temp_ui.name_txt.text = data.award_logs[i].player_name  
		end
		if table_is_null(data.award_logs) then 
			LittleTips.Create("暂无新数据")
		end 
	end 
end
 
function C:MyRefresh()
end