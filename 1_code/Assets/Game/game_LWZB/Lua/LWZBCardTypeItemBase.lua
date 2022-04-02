-- 创建时间:2020-08-31
-- Panel:LWZBCardTypeItemBase
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

LWZBCardTypeItemBase = basefunc.class()
local C = LWZBCardTypeItemBase
C.name = "LWZBCardTypeItemBase"

function C.Create(parent,data)
	return C.New(parent,data)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,data)
	self.data = data
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
	self:MyRefresh()
end

function C:MyRefresh()
	if self.data.type == 1 then
		self.px_img.sprite = GetTexture(self.data.px_name)
		self.px_img.gameObject:SetActive(true)
	elseif self.data.type == 2 then
		self.px_txt.text = self.data.px_name
		self.px_txt.gameObject:SetActive(true)
	end
	if self.data.line >= 4 and self.data.line <= 11 then
		self.px_img.transform.localScale = Vector3.New(0.3,0.3,1)
	else
		self.px_img.transform.localScale = Vector3.New(0.8,0.8,1)
	end
	self.rate_txt.text = self.data.rate.."倍"
	for i=1,#self.data.px do
		self["pai"..i.."_img"].sprite = GetTexture("lwzb_imgf_"..self.data.px[i])
	end
end
