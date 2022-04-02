-- 创建时间:2019-10-30
-- Panel:FixAwardPopM
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

MixAwardPopManager = basefunc.class()
local C = MixAwardPopManager
C.name = "MixAwardPopManager"
MixAwardPopManager.Type = {
	fk = 1, --分开创建
	hb = 2, --合并创建
}
-- Count  指监测AssetsGetPanel关闭的次数。
function C.Create(award_data,Count,type,WXorQQ)
	return C.New(award_data,Count,type,WXorQQ)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.AGP_Close)
	self.lister["AssetsGetPanelCreating"] = basefunc.handler(self,self.AGP_Open)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.Destroy_Timer then 
		self.Destroy_Timer:Stop()
	end 
	self.Destroy_Timer = nil
	self:RemoveListener()
end

function C:ctor(award_data,Count,Type,WXorQQ)
	self:MakeLister()
	self:AddMsgListener()
	self.Count = Count or 1
	self.Type = Type or MixAwardPopManager.Type.fk
	self.Parm = award_data
	self.WXorQQ = WXorQQ
	self:InitDestroyTimer()
end

function C:AGP_Close(data)
	if self.Type == MixAwardPopManager.Type.fk then
		self.Count = self.Count - 1
		if self.Count == 0 then 
			RealAwardPanel.Create(self.Parm)
		end 
	end
	self:MyExit()
end
--注意：AssetsGetPanel面板的创建一定要在此方法的调用前！可参考ActivityFKSSEPanel中的使用方法
function C:AGP_Open(data)
	if self.Type == MixAwardPopManager.Type.hb then
		AssetsGetPanel.CreatRealAwardItem({desc = self.Parm.text,image = self.Parm.image},self.WXorQQ)
	end 
	self:MyExit()
end
--超过一定时间，没有创建ASP面板，则关闭监听
function C:InitDestroyTimer()
	self.Destroy_Timer = Timer.New(function ()
		print("<color=red>没有等待到面板创建，已经关闭监听</color>")
		self:MyExit()
	end,3,1)
	self.Destroy_Timer:Start()
end