-- 创建时间:2020-05-26
-- Panel:Sys_013_SYLBPanel
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

Sys_013_SYLBPanel = basefunc.class()
local C = Sys_013_SYLBPanel
C.name = "Sys_013_SYLBPanel"

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
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
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
	self.click_btn.onClick:AddListener(function ()
		GameShop1YuanPanel.Create()
	end)
	self.yueka_btn.onClick:AddListener(
		function ()
			Sys_011_YueKaPanel.Create(nil,true)
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	local status = MainModel.GetGiftShopStatusByID(10)
	if status == 1 then
		self.click_btn.gameObject:SetActive(true)
		self.yueka_node.gameObject:SetActive(false)
	else
		self.click_btn.gameObject:SetActive(false)
		self.yueka_node.gameObject:SetActive(true)
		local s1 = MainModel.GetGiftShopStatusByID(10235)
		local s2 = MainModel.GetGiftShopStatusByID(10236)
		local v = VIPManager.get_vip_level()
		if v == 0 then
			self.haohua.gameObject:SetActive(true)
			self.zunxiang.gameObject:SetActive(false)
		else
			self.haohua.gameObject:SetActive(false)
			self.zunxiang.gameObject:SetActive(true)
			if s1 == 1 and s2 == 0 then
				self.haohua.gameObject:SetActive(true)
				self.zunxiang.gameObject:SetActive(false)
			end
		end
		if s1 == 0 and s2 == 0 then
			self.click_btn.gameObject:SetActive(true)
			self.yueka_node.gameObject:SetActive(false)
		end
	end
end

function C:OnDestroy()
	self:MyExit()
end

function C:OnAssetChange()
	-- body
end