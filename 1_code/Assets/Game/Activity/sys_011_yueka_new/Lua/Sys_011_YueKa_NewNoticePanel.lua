-- 创建时间:2020-04-29
-- Panel:Sys_011_YueKa_NewNoticePanel
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

Sys_011_YueKa_NewNoticePanel = basefunc.class()
local C = Sys_011_YueKa_NewNoticePanel
C.name = "Sys_011_YueKa_NewNoticePanel"

local vip_jjj_award = {
	4000,5000,6000,7000,8000,9000,10000,12000,14000,20000,20000,20000
}

local instance
function C.Create()
	if instance then
		instance:MyExit()
	end
	instance = C.New()
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
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
	if instance then
		instance = nil
	end
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform

	if MainModel.UserInfo.xsyd_status == 0 then
		parent = GameObject.Find("Canvas/LayerLv4").transform
	end

	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	local v_l = VIPManager.get_vip_level()
	self.normal_txt.text = (vip_jjj_award[v_l] or 3000).."鲸币"
	self.yueka_txt.text = (8888+(vip_jjj_award[v_l] or 3000)).."鲸币"
	self.backcall = backcall
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	HandleLoadChannelLua(self.name,self)
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function()
			self:MyExit()
		end
	)
	self.award_yes_btn.onClick:AddListener(
		function ()
			Sys_011_YueKaPanel.Create(nil,true)
			self:MyExit()
		end
	)
	self.award_no_btn.onClick:AddListener(
		function ()
			self:MyExit()
			OneYuanGift.GetBrokeAward()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end
