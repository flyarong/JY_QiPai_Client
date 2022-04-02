-- 创建时间:2020-02-19
-- Panel:Fishing3DActZhuanpanBoxPrefab
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

Fishing3DActZhuanpanBoxPrefab = basefunc.class()
local C = Fishing3DActZhuanpanBoxPrefab
C.name = "Fishing3DActZhuanpanBoxPrefab"
local M = BY3DActZhuanpanManager

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
	local obj = newObject("fish3d_act_zhuanpan_box_prefab", parent)
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

function C:setIndex(index)
	self.index = index

	local config = M.getConfig()

	assert(index >= 1 and index <= #config)

	self.icon_img.sprite = GetTexture(config[index].icon)

	local d = M.GetZhuanpanData()
	local num = d.bullet_stake * config[index].num
	--dump(num,"<color=red>NNNNNNNNNNNNNNNNNNNNNNNNum</color>")
	--dump(d.bullet_stake,"<color=red>bullet_stake</color>")
	--dump(config[index].num,"<color=red>config[index].num</color>")

	local str = string.format("鲸币%s", StringHelper.ToCash(num))
	--dump(str,"<color=red>SSSSSSSSStr</color>")
	self.name_txt.text = str
end

function C:getIndex()
	return self.index
end