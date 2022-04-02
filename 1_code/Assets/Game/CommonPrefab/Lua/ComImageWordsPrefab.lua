-- 创建时间:2020-01-09
-- Panel:ComImageWordsPrefab
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

ComImageWordsPrefab = basefunc.class()
local C = ComImageWordsPrefab
C.name = "ComImageWordsPrefab"

ComImageWordsStyle = {
	CIWS_LEFT = "left",
	CIWS_CENTER = "center",
	CIWS_RIGHT = "right",
}

function C.Create(parent, cell, str, style)
	return C.New(parent, cell, str, style)
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

function C:ctor(parent, cell, str, style)
	self.cell = cell
	self.str = str or ""
	self.style = style or ComImageWordsStyle.CIWS_CENTER
	local obj = newObject("com_ui_font", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.transform.localPosition = Vector3.zero

	self.layout = self.transform:GetComponent("HorizontalLayoutGroup")
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	self:ClearCellList()
	if self.str == "" then
		return
	end

	self:RefreshFont(self.str)
	self:RefreshStyle()
end

function C:RefreshFont(str)
	local list1 = basefunc.string.string_to_vec(str)
	for i = 1, #list1 do
	    local obj = GameObject.Instantiate(self.cell, self.transform)
	    obj.transform:GetComponent("Text").text = list1[i]
	    self.CellList[#self.CellList + 1] = obj
	end
end
function C:RefreshStyle()
	if self.style == ComImageWordsStyle.CIWS_LEFT then
		self.transform.pivot  = Vector2.New(0, 0.5)
	elseif self.style == ComImageWordsStyle.CIWS_CENTER then
		self.transform.pivot  = Vector2.New(0.5, 0.5)
	elseif self.style == ComImageWordsStyle.CIWS_RIGHT then
		self.transform.pivot  = Vector2.New(1, 0.5)
	end
end

function C:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			destroy(v)
		end
	end
	self.CellList = {}
end

function C:SetSpacing(spacing)
	self.layout.spacing = spacing
end
function C:AddStr(str)
	self.str = self.str .. str
	self:RefreshFont(str)
end
function C:SetStr(str)
	self.str = str or ""
	self:MyRefresh()
end
function C:SetPos(pos)
	self.transform.localPosition = pos
end
function C:SetStyle(style)
	self.style = style or ComImageWordsStyle.CIWS_CENTER
	self:RefreshStyle()
end