-- 创建时间:2020-03-05
-- Panel:Fishing3DActZhuanpanEnterPrefab
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

Fishing3DActXZhuanpanEnterPrefab = basefunc.class()
local C = Fishing3DActXZhuanpanEnterPrefab
C.name = "Fishing3DActXZhuanpanEnterPrefab"

function C.Create(parent)
	return C.New(parent)
end
function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_by3d_act_zhuanpan_start"] = basefunc.handler(self, self.on_zhuanpan_start)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
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


function C:ctor(parent)
	-- local obj = newObject(C.name, parent)
	-- local tran = obj.transform
	-- self.transform = tran
	-- self.gameObject = obj
	-- LuaHelper.GeneratingVar(self.transform, self) 
	-- self.transform.localPosition = Vector3.zero
	-- self:MakeLister()
	-- self:AddMsgListener()
	-- self:InitUI()
end

function C:InitUI()
	self.enter_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self:MyRefresh()
end

function C:OnEnterClick()
	Fishing3DActZhuanpanPanel.Create()
end

function C:MyRefresh()
end

function C:on_zhuanpan_start()
	dump(data, "<color=red>on_zhuanpan_start</color>")

	Fishing3DActZhuanpanPanel.Create()
end