-- 创建时间:2019-09-25
-- Panel:SYSKXXXLEnterPrefab
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

SYSKXXXLEnterPrefab = basefunc.class()
local M = SYSKXXXLEnterPrefab
M.name = "SYSKXXXLEnterPrefab"

function M.Create(parent, cfg)
	return M.New(parent, cfg)
end

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function M:ctor(parent, cfg)
	self.config = cfg

	local obj = newObject("SYSKXXXLEnterPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.transform.localPosition = Vector3.zero

	self:InitUI()
end

function M:OnDestroy(  )
	self:MyExit()
end

function M:InitUI()
	local cur_scene = MainLogic.GetCurSceneName() --根据场景进行不同设置
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
		self:OnEnterClick()
	end)
	self:MyRefresh()
end

function M:MyRefresh()
	
end

function M:OnEnterClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
end

function M:OnDestroy()
	self:MyExit()
end