-- 创建时间:2019-12-31
-- Panel:SYSXBYYLB_JYFLEnterPrefab
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

SYSXBYYLB_JYFLEnterPrefab = basefunc.class()
local C = SYSXBYYLB_JYFLEnterPrefab
C.name = "SYSXBYYLB_JYFLEnterPrefab"

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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.get_btn.onClick:AddListener(
		function ()
			NewOneYuanPanel.Create()
		end
	)
	self.BG_btn.onClick:AddListener(
		function ()
			NewOneYuanPanel.Create()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	local shop_status = MainModel.GetGiftShopStatusByID(NewOneYuanManager.GetShopID())
	local task_data = GameTaskModel.GetTaskDataByID(NewOneYuanManager.GetTaskID())
	--(shop_status == 1 and MainModel.UserInfo.ui_config_id == 2)  or
	--没购买的玩家不再能够购买，买过但是没有领完的玩家继续显示  2020.1.15
    if  (shop_status == 0  and task_data and NewOneYuanManager.DisappearTime(task_data.create_time) > os.time()) then
        self.gameObject:SetActive(true)
	else
		self.gameObject:SetActive(false)
	end
	if NewOneYuanManager.GetHintState() == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
		if shop_status == 1 then 
			self.get_txt.text = "去 购 买"	
		else
			self.get_txt.text = "领  取"	
		end 
	else
		self.get_txt.text = "前  往"
	end 
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == NewOneYuanManager.key then
		self:MyRefresh()
	end
end

function C:OnDestroy()
	self:MyExit()
end

