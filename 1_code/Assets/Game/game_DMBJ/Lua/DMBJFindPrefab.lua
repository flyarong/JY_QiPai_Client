-- 创建时间:2020-12-02
-- Panel:DMBJFindPrefab
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

DMBJFindPrefab = basefunc.class()
local C = DMBJFindPrefab
C.name = "DMBJFindPrefab"

function C.Create(backcall,cut_time)
	return C.New(backcall,cut_time)
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
	if self.timer then
		self.timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(backcall,cut_time)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.backcall = backcall
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self.timer = Timer.New(
		function()
			if IsEquals(self.gameObject) then
				if backcall then
					backcall()
				end
				self:MyExit()
			end
		end
	,cut_time,1)
	self.timer:Start()
	DMBJAnimManager.IsInAnim = true
	ExtendSoundManager.PlaySound(audio_config.dmbj.dmbj_kaishi.audio_name)
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

end
