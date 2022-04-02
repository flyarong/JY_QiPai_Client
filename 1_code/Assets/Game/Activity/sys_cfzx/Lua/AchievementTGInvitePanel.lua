-- 创建时间:2019-10-15
-- Panel:AchievementTGInvitePanel
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

AchievementTGInvitePanel = basefunc.class()
local C = AchievementTGInvitePanel
C.name = "AchievementTGInvitePanel"
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
	self.lister["query_sczd_achievement_invite_player_log_response"] = basefunc.handler(self,self.onGetInfo)
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
	Network.SendRequest("query_sczd_achievement_invite_player_log",{page_index = Page_Index })
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.sv = self.sc:GetComponent("ScrollRect")
	EventTriggerListener.Get(self.sv.gameObject).onEndDrag = function()
		local VNP = self.sv.verticalNormalizedPosition
		if VNP <= 0 then
			Network.SendRequest("query_sczd_achievement_invite_player_log",{page_index = Page_Index })		
		end
	end
	self:MyRefresh()
end

function C:onGetInfo(_,data)
	if data and data.result == 0 then 
		Page_Index = Page_Index + 1
		for i=1,#data.log_data do
			local b = GameObject.Instantiate(self.item,self.content)
			b.gameObject:SetActive(true)
			local temp_ui = {}
			LuaHelper.GeneratingVar(b.transform, temp_ui)
			temp_ui.time_txt.text = os.date("%Y-%m-%d  %X",data.log_data[i].time)
			temp_ui.info_txt.text = "成功邀请好友【"..data.log_data[i].gx_player.."】".."  +"..data.log_data[i].add_num.."点成就"
		end
		if table_is_null(data.log_data) then 
			LittleTips.Create("暂无新数据")
		end 
	end 
end

function C:MyRefresh()
end
