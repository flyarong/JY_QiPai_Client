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

SYSACTBASEEnterPrefab = basefunc.class()
local C = SYSACTBASEEnterPrefab
C.name = "SYSACTBASEEnterPrefab"

local M = SYSACTBASEManager

function C.Create(parent, goto_type)
    return C.New(parent, goto_type)
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["UpdateHallActivityYearRedHint"] = basefunc.handler(self, self.RefreshStatus)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self.huxi.Stop()
    self:RemoveListener()
    destroy(self.gameObject)
end

function C:OnDestroy()
    self:MyExit()
end

function C:ctor(parent, goto_type)
    ExtPanel.ExtMsg(self)

    self.goto_type = goto_type
    self.style_config = M.GetStyleConfig(self.goto_type)
    self.prefab_name = "SYSACTBASEEnterPrefab_" .. self.style_config.style_type
    if not self.style_config.prefab_map[self.prefab_name] or not GetPrefab(self.prefab_name) then
        self.prefab_name = "SYSACTBASEEnterPrefab"
    end
    local obj = newObject(self.prefab_name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
    -- self.transform.localScale = Vector3.New(0.9,0.9,0.9)
    self.huxi = CommonHuxiAnim.Go(self.gameObject, 1, 0.95, 1.05)
    self.huxi.Start()
    Event.Brocast("year_btn_created",{enterSelf = self})
    
    if self.prefab_name == "SYSACTBASEEnterPrefab_weekly_036" then
        if MainModel.myLocation == "game_EliminateBS" then
            self.skeletonAnim = self.skeleton:GetComponent("SkeletonAnimation")
            self.skeletonMr = self.skeletonAnim:GetComponent("MeshRenderer")
            self.skeletonMr.sortingOrder = 3
            local canvas = self.tit_img.transform:GetComponent("Canvas")
            canvas.sortingOrder = 3
        end
    end
end

function C:InitUI()
    if self.prefab_name == "SYSACTBASEEnterPrefab" then
        local image = self.enter_btn.transform:GetComponent("Image")
        image.sprite = GetTexture("sys_act_base_enter_" .. self.style_config.style_type)
        --image:SetNativeSize()
    end
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
    local parm = {gotoui = M.key, goto_type = self.goto_type, goto_scene_parm = "panel"}
    Event.Brocast("global_hint_state_set_msg", parm)
    self:RefreshStatus()
    GameManager.GotoUI(parm)
end

function C:global_hint_state_change_msg(parm)
    if parm.gotoui == M.key
        and parm.goto_type == self.goto_type then
        self:RefreshStatus()
    end
end

function C:RefreshStatus()
    local st = M.GetHintState({gotoui = M.key, goto_type = self.goto_type})
    if st ~= ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        local btnNodeSt = M.GetBtnNodeHint()
        if  btnNodeSt ~= ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
            st = btnNodeSt
        end
    end
    self.get_img.gameObject:SetActive(false)
    self.red_img.gameObject:SetActive(false)
    if st == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
        self.red_img.gameObject:SetActive(true)
    elseif st == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        self.get_img.gameObject:SetActive(true)
    end
end