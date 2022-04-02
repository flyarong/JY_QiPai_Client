-- 创建时间:2019-12-09
-- Panel:LHDPagePrefab
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

LHDPagePrefab = basefunc.class()
local C = LHDPagePrefab
C.name = "LHDPagePrefab"

function C.Create(parent_transform, call, panelSelf, index)
	return C.New(parent_transform, call, panelSelf, index)
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
function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent_transform, call, panelSelf, index)
	self.call = call
	self.panelSelf = panelSelf
    self.index = index

	local obj = newObject("page_prefab", parent_transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.BG_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnClick()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.page_txt.text = self.index
	self:SetSelect(false)
end

function C:SetSelect(b)
	self.select.gameObject:SetActive(b)
	if b then
		self.page_txt.font = GetFont("dld_font_2")
	else
		self.page_txt.font = GetFont("dld_font_1")
	end
end

function C:OnClick()
	if self.call then
		self.call(self.panelSelf, self.index)
	end
end

