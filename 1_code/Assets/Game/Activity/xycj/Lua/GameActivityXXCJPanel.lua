-- 创建时间:2019-06-04
-- Panel:GameActivityXXCJPanel
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


GameActivityXXCJPanel = basefunc.class()
local C = GameActivityXXCJPanel
C.name = "GameActivityXXCJPanel"
local M = XYCJActivityManager

local activity_xycj_config = GameButtonManager.ExtLoadLua("xycj", "activity_xycj_config")

local instance
function C.Create(parm)
	if instance and IsEquals(instance.gameObject) then
		instance.parm = parm
		instance:MyRefresh()
	else
		DSM.PushAct({panel = C.name})
		instance = C.New(parm)
	end
	return instance
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["xycj_change_ui_msg"] = basefunc.handler(self, self.on_xycj_change_ui_msg)
	self.lister["model_vip_upgrade_change_msg"]=basefunc.handler(self, self.on_model_vip_upgrade_change_msg)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.hbdzp_pre then
		self.hbdzp_pre:MyExit()
		self.hbdzp_pre = nil
	end
	self:RemoveListener()
	DSM.PopAct()
	destroy(self.gameObject)
	instance = nil
end
function C:MyClose()
	self:MyExit()
end
function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	XYCJActivityManager.SetHintState()
 
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()
	LuaHelper.GeneratingVar(obj.transform, self)

	self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)
	self.parm = parm
	self:InitConfig()
	self:InitUI()
end
function C:InitConfig()
	self.Config = {}
	self.Config.award_map = {}
	self.Config.award_parm = {}
	for k,v in ipairs(activity_xycj_config.config) do
		if not self.Config.award_map[v.type] then
			self.Config.award_map[v.type] = {}
		end
	self.Config.award_map[v.type][#self.Config.award_map[v.type] + 1] = v
	end
	for k,v in ipairs(activity_xycj_config.parm) do
		self.Config.award_parm[v.type] = v
	end
end
 
function C:InitUI()
	if self.parm and self.parm.type then
		if self.parm.type == 1 then
			self.is_goto_open = true
		end
	else
		if (M.m_data.ptcj_num and M.m_data.ptcj_num > 0) or (M.sxsj and M.sxsj > MainModel.FirstLoginTime()) then
			self.is_goto_open = false
		else
			self.is_goto_open = true
		end
	end
 	self:MyRefresh()
 	Network.SendRequest("query_luck_lottery_data")
end

function C:MyRefresh()
	if self.hbdzp_pre then
		self.hbdzp_pre:MyClose()
	end
	if self.parm and self.parm.type then
		self.hbdzp_pre = HBDZPPrefab.Create(self.center, self.parm.type, self)
	else
		local chargeData = VIPManager.get_vip_data()
		if (M.m_data.ptcj_num and M.m_data.ptcj_num > 0) or (M.sxsj and M.sxsj > MainModel.FirstLoginTime()) or (GameItemModel.GetItemCount("prop_xycj_coin") <= 0 and chargeData and chargeData.now_charge_sum > 0) then
			self.hbdzp_pre = HBDZPPrefab.Create(self.center, 2, self)
		else
			self.hbdzp_pre = HBDZPPrefab.Create(self.center, 1, self)
		end
	end

	if self.hbdzp_pre then
		self.hbdzp_pre:MyRefresh()
	end
end
 
function C:OnExitScene()
	self:MyExit()
end
function C:OnBackClick()
	self:MyClose()
end

function C:on_xycj_change_ui_msg(parm)
	if self.hbdzp_pre then
		self.hbdzp_pre:MyClose()
	end

	self.hbdzp_pre = HBDZPPrefab.Create(self.center, parm.type, self)
end
function C:on_model_vip_upgrade_change_msg()
	Network.SendRequest("query_luck_lottery_data")
end


--[[
	GetTexture("com_award_icon_hfk")
	GetTexture("com_award_icon_jdk")
]]