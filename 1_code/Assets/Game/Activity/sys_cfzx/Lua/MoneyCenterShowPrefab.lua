-- 创建时间:2019-07-31
-- Panel:New Lua
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

MoneyCenterShowPrefab = basefunc.class()
local C = MoneyCenterShowPrefab
C.name = "MoneyCenterShowPrefab"

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
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    self.GR=self.transform:Find("GRShowPrefab")
	self.PR=self.transform:Find("PRShowPrefab")
	self.MR=self.transform:Find("MRShowPrefab")
	self.MR.transform:Find("ImgPopupPanel/close_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			self:HideAll()
		end
	)
	self.MR.transform:Find("ImgPopupPanel/confirm_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			self:HideAll()
		end
	)
	self.PR.transform:Find("ImgPopupPanel/close_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			self:HideAll()
		end
	)
	self.PR.transform:Find("ImgPopupPanel/confirm_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			self:HideAll()
		end
	)
	self.GR.transform:Find("ImgPopupPanel/close_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			self:HideAll()
		end
	)
	self.GR.transform:Find("ImgPopupPanel/confirm_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			self:HideAll()
		end
	)
	self:HideAll()
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end
function C:HideAll()
	self.GR.gameObject:SetActive(false)
	self.PR.gameObject:SetActive(false)
	self.MR.gameObject:SetActive(false)
end

function C:ShowGR()
	self:HideAll()
	self.GR.gameObject:SetActive(true)
end
function C:ShowPR()
	self:HideAll()
	self.PR.gameObject:SetActive(true)
end
function C:ShowMR()
	self:HideAll()
	self.MR.gameObject:SetActive(true)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end
