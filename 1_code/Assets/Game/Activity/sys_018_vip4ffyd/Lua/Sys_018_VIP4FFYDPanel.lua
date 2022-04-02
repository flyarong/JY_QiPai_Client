-- 创建时间:2020-06-15
-- Panel:Sys_018_VIP4FFYDPanel
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

Sys_018_VIP4FFYDPanel = basefunc.class()
local C = Sys_018_VIP4FFYDPanel
C.name = "Sys_018_VIP4FFYDPanel"
local M = Sys_018_VIP4FFYDManager
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
	self.lister["shop_info_get"] = basefunc.handler(self,self.vip4_ffyd_refresh)
	self.lister["vip4_ffyd_refresh"] = basefunc.handler(self,self.vip4_ffyd_refresh)
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
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	for i = 1,4 do
		self["buy"..i.."_btn"].onClick:AddListener(
			function ()
				M.BuyShop(M.shop_ids[i])
			end
		)
	end
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:vip4_ffyd_refresh()
	for i = 1,#M.shop_ids do
		Network.SendRequest("query_gift_bag_status",{gift_bag_id = M.shop_ids[i]})
	end
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:vip4_ffyd_refresh()
	if M.GetCanBuyShopIDIndex() and VIPManager.get_vip_level() == 4 and IsEquals(self.gameObject) then
		for i = 1,4 do
			self["node_"..i].gameObject:SetActive(false)
		end
		self["node_"..M.GetCanBuyShopIDIndex()].gameObject:SetActive(true)
	end
end

function C:OnDestroy()
	self:MyExit()
end