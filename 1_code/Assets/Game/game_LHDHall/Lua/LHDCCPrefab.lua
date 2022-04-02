-- 创建时间:2019-12-07
-- Panel:LHDCCPrefab
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

LHDCCPrefab = basefunc.class()
local C = LHDCCPrefab
C.name = "LHDCCPrefab"

function C.Create(obj, config, call, panelSelf, index)
	return C.New(obj, config, call, panelSelf, index)
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
end

function C:ctor(obj, config, call, panelSelf, index)
	ExtPanel.ExtMsg(self)

	self.config = config
	self.call = call
	self.panelSelf = panelSelf
    self.index = index
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj.gameObject
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.enter_btn.onClick:AddListener(function ()
		self:OnClick()
	end)
	self.xz_btn.onClick:AddListener(function ()
		self:OnXZClick()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	if self.config.enterMin < 0 and self.config.enterMax < 0 then
		self.enter_txt.text = "入场 无限制"
	elseif self.config.enterMin < 0 and self.config.enterMax > 0 then
		self.enter_txt.text = "入场 " .. StringHelper.ToCash(self.config.enterMax) .. "以下"
	elseif self.config.enterMin > 0 and self.config.enterMax < 0 then
		self.enter_txt.text = "入场 " .. StringHelper.ToCash(self.config.enterMin) .. "以上"
	else
		self.enter_txt.text = "入场 " .. StringHelper.ToCash(self.config.enterMin) .. "~" .. StringHelper.ToCash(self.config.enterMax)
	end

	self.base_txt.text = "底分: " .. self.config.base

	if self.config.isLock == 1 then
		self.lock_node.gameObject:SetActive(true)
		if IsEquals(self.fx_node) then
			self.fx_node.gameObject:SetActive(false)
		end
	else
		self.lock_node.gameObject:SetActive(false)
		if IsEquals(self.fx_node) then
			self.fx_node.gameObject:SetActive(true)
		end
	end
end
function C:OnDestroy()
	self:MyExit()
end

function C:OnClick()
	if self.call then
		self.call(self.panelSelf, {index=self.index, type="enter"})
	end
end
function C:OnXZClick()
	if self.call then
		self.call(self.panelSelf, {index=self.index, type="xz"})
	end
end
function C:SetActive(b)
	self.gameObject:SetActive(b)
end

