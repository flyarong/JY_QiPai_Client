-- 创建时间:2020-12-08
-- Panel:Template_NAME
--[[ *      ┌─┐       ┌─┐
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

Act_042_XYZZLEnterPrefab = basefunc.class()
local C = Act_042_XYZZLEnterPrefab
C.name = "Act_042_XYZZLEnterPrefab"
local M = Act_042_XYZZLManager

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
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
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
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor(parent)
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
    self.transform:GetComponent("Button").onClick:AddListener(function()
        Act_042_XYZZLPanel.Create()
    end)
    self:MyRefresh()
end

function C:MyRefresh()
    self.LFL.gameObject:SetActive(M.IsHint())
    SYSACTBASEManager.SetOtherRedHintByForce(M.key,M.GetHintState())
end

function C:on_global_hint_state_change_msg(parm)
    if parm.gotoui == M.key then
        self:MyRefresh()
    end
end