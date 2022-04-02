local basefunc = require "Game/Common/basefunc"
MoneyCenterQFLBEnterPrefab = basefunc.class()
local C = MoneyCenterQFLBEnterPrefab
local M = MoneyCenterQFLBManager

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
    self.lister["module_global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
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

function C:ctor(parent)
    local obj = newObject("MoneyCenterQFLBEnterPrefab", parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self:MakeLister()
    self:AddMsgListener()

    -- self.transform.localPosition = Vector3.zero

    self:InitUI()
end

function C:InitUI()
    self.enter_btn = self.transform:GetComponent("Button")
    self.enter_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnEnterClick()
            PlayerPrefs.SetInt(MainModel.UserInfo.user_id.."QFLB",1)
            self:MyRefresh()
        end
    )
    self:MyRefresh()
end

function C:MyRefresh()
    Event.Brocast("global_hint_state_change_msg", {gotoui = MoneyCenterQFLBManager.key})
end

function C:OnEnterClick()
    local cur_state = MoneyCenterQFLBManager.GetHintState()
    if cur_state == ACTIVITY_HINT_STATUS_ENUM.AT_Mission then
        Event.Brocast("MoneyCenterQFLBManager_enter_click")
        self.mission_hint.gameObject:SetActive(false)
    end
    self.red.gameObject:SetActive(false)
    GameManager.GotoUI({gotoui = MoneyCenterQFLBManager.key, goto_scene_parm="panel"})
end

function C:OnDestroy()
    self:MyExit()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui ~= MoneyCenterQFLBManager.key then return end
    local cur_state = MoneyCenterQFLBManager.GetHintState()
    if cur_state == ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
        if IsEquals(self.get_hint) and IsEquals(self.mission_hint) then
            self.get_hint.gameObject:SetActive(false)
            self.mission_hint.gameObject:SetActive(false)
        end
    elseif cur_state == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        if IsEquals(self.get_hint) then
            self.get_hint.gameObject:SetActive(true)
            if IsEquals(self.mission_hint) then
                self.mission_hint.gameObject:SetActive(false)
            end
        end
    elseif cur_state == ACTIVITY_HINT_STATUS_ENUM.AT_Mission and M.GetEnterCount() then
        if IsEquals(self.get_hint) and IsEquals(self.mission_hint) then
            self.get_hint.gameObject:SetActive(false)
            if IsEquals(self.mission_hint) then
                self.mission_hint.gameObject:SetActive(true)
            end
        end
    elseif cur_state == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
        if IsEquals(self.red) then
            self.red.gameObject:SetActive(true)
            if IsEquals(self.mission_hint) then
                self.mission_hint.gameObject:SetActive(false)
            end
        end

    end
end
