-- 创建时间:2020-02-19
-- Panel:Fishing3DActCaijinBoxPrefab
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

Fishing3DActCaijinBoxPrefab = basefunc.class()
local C = Fishing3DActCaijinBoxPrefab
C.name = "Fishing3DActCaijinBoxPrefab"
local M = BY3DActCaijinManager

function C.Create(panelSelf, parent, index)
	return C.New(panelSelf, parent, index)
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

function C:ctor(panelSelf, parent, index)
	self.panelSelf = panelSelf
	self.index = index
	local obj = newObject("fish3d_act_caijin_box_prefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	tran.localPosition = Vector3.zero
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()

	
end

function C:setVisible(visible)
	self.gameObject:SetActive(visible)
end

function C:setIcon(icon_name)
	self.icon_img.sprite = GetTexture(icon_name)
end

function C:setName(name)
	self.item_name_txt.text = name
end

function C:setChoosed(choosed)
	self.choose_node.gameObject:SetActive(choosed)
end