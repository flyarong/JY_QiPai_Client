-- 创建时间:2019-11-19
-- Panel:GuideToUpdatePanel
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

GuideToUpdatePanel = basefunc.class()
local C = GuideToUpdatePanel
C.name = "GuideToUpdatePanel"
function C.Create(backcall)
	return C.New(backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["visit_client_upgrade_act_response"] = basefunc.handler(self,self.OnGetInfo)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.backcall then 
		self.backcall()
	end 
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(backcall)

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.time_txt.text = "活动时间：12月21日23:59 - 12月28日23:59"
end

function C:InitUI()
	self.go_btn.onClick:AddListener(
		function ()
			local url = MainLogic.GetSYSUpURL()
			Network.SendRequest("visit_client_upgrade_act")
			Event.Brocast("sys_quit",url)
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnGetInfo(_,data)
	dump(data,"<color=red>系统升级任务----</color>")
end