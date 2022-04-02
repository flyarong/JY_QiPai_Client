-- 创建时间:2019-09-25
-- Panel:JYFLEnterPrefab
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
 --]]
local basefunc = require "Game/Common/basefunc"

SYSYKEnterPrefab = basefunc.class()
local C = SYSYKEnterPrefab
C.name = "SYSYKEnterPrefab"

function C.Create(parent, cfg)
    return C.New(parent, cfg)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["sys_yk_manager_yueka_base_info"] = basefunc.handler(self, self.RefreshStatus)
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.RefreshStatus)
    self.lister["sys_yk_manager_task_change"] = basefunc.handler(self, self.RefreshStatus)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:RemoveListener()
    if self.main_timer then
        self.main_timer:Stop()
        self.main_timer = nil
    end
    destroy(self.gameObject)
end

function C:ctor(parent, cfg)
    self.config = cfg
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self:MakeLister()
    self:AddMsgListener()
    self.transform.localPosition = Vector3.zero
    self:InitUI()
end

function C:InitUI()
    self.enter_btn = self.transform:GetComponent("Button")
    self.enter_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnEnterClick()
    end)

    self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshStatus()
end

function C:OnEnterClick()
    Event.Brocast("global_hint_state_set_msg", {gotoui = SYSYKManager.key})
    self:RefreshStatus()
   	ShopYueKaPanel.Create()
end

function C:OnDestroy()
    self:MyExit()
end

function C:RefreshStatus()
    local st = SYSYKManager.GetHintState()
    self.get_img.gameObject:SetActive(false)
    self.red_img.gameObject:SetActive(false)
    if st == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
        self.red_img.gameObject:SetActive(true)
    elseif st == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        self.get_img.gameObject:SetActive(true)
    end
end