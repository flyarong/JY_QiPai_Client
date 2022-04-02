-- 创建时间:2019-05-30
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

EliminateHelpPanel = basefunc.class()
local C = EliminateHelpPanel
C.name = "EliminateHelpPanel"

local instance
function C.Create()
	if not instance then
		instance = C.New()
	else
		instance:MyRefresh()
	end
	return instance
end
function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
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
function C:Close()
	C:MyExit()
end
function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.gameObject:SetActive(false)
	self.Active=self.transform:Find("CenterRect/Top/BG/ActivityButton")
	self.Notice=self.transform:Find("CenterRect/Top/BG/NoticeButton")
	self.js=self.transform:Find("CenterRect/RightBG/ScrollView/Viewport/Content/js")
	self.wf=self.transform:Find("CenterRect/RightBG/ScrollView/Viewport/Content/wf")
	self.content=self.transform:Find("CenterRect/RightBG/ScrollView/Viewport/Content")
	local  CloseButton=self.transform:Find("CenterRect/Top/BackButton"):GetComponent("Button")
	CloseButton.onClick:AddListener(
		function ()
			self.gameObject:SetActive(false)
		end
	)
	local jsButton=self.transform:Find("CenterRect/Top/BG/ActivityButton"):GetComponent("Button")
	jsButton.onClick:AddListener(
		function ()
			self.Active.gameObject:SetActive(false)
			self.Notice.gameObject:SetActive(true)
			self.js.gameObject:SetActive(true)
			self.wf.gameObject:SetActive(false)
			self.content.gameObject.transform.localPosition=Vector3.zero
		end
	)
	local wfButton=self.transform:Find("CenterRect/Top/BG/NoticeButton"):GetComponent("Button")
	wfButton.onClick:AddListener(
		function ()
			self.Active.gameObject:SetActive(true)
			self.Notice.gameObject:SetActive(false)
			self.js.gameObject:SetActive(false)
			self.wf.gameObject:SetActive(true)
			self.content.gameObject.transform.localPosition=Vector3.zero
		end
	)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end
function C.ShowPanel()
	        instance.gameObject:SetActive(true)
	        instance.Active.gameObject:SetActive(false)
			instance.Notice.gameObject:SetActive(true)
			instance.js.gameObject:SetActive(true)
			instance.wf.gameObject:SetActive(false)
			instance.content.gameObject.transform.localPosition=Vector3.zero
end
function C:InitUI()
end

function C:MyRefresh()
end
