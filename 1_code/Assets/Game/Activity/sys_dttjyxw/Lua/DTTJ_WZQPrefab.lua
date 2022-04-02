-- 创建时间:2020-02-12
-- Panel:DTTJ_WZQPrefab
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

DTTJ_WZQPrefab = basefunc.class()
local C = DTTJ_WZQPrefab
C.name = "DTTJ_WZQPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
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

function C:ctor(parent, cfg)
	local obj = newObject(cfg.prefab, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.WZQBox = self.WZQBox:GetComponent("PolygonClick")
	self.transform.localPosition = Vector3.zero

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.WZQBox.PointerClick:AddListener(function (obj)
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnClick()
	end)

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnClick()
	GameManager.GotoUI({gotoui = "game_Free",goto_scene_parm ="nor_gobang_nor"})
end

