-- 创建时间:2020-07-16
-- Panel:BY3DTopQHPanel
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

BY3DTopQHPanel = basefunc.class()
local C = BY3DTopQHPanel
C.name = "BY3DTopQHPanel"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ui_button_state_change_msg"] = basefunc.handler(self, self.ui_button_state_change_msg)
    self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.global_hint_state_change_msg)
    self.lister["global_select_top_index_msg"] = basefunc.handler(self, self.global_select_top_index_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:ClearCell()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
    self.transform.localPosition = Vector3.zero
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:GetBtnList()
    local btn_list = {}
    local cfg = BY3DTopQHManager.GetConfig()
    for k, v in pairs(cfg) do
        local module_cc = GameButtonManager.GetModuleByKey(v.gotoui[1])
        if module_cc then
            if module_cc.lua and _G[module_cc.lua] then
                local cclua = _G[module_cc.lua]
                local parm = {}
                parm.gotoui = v.gotoui[1]
                parm.goto_scene_parm = v.gotoui[2] or "bytop_area"
                if not cclua.CheckIsShow or cclua.CheckIsShow(parm) then
                    btn_list[#btn_list + 1] = v
                end
            end
        end
    end
    return btn_list
end

function C:InitUI()
    self.cell_map = {}
    self.select_index = 1
    self.left_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnSelectClick(-1)
    end)
    self.right_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnSelectClick(1)
    end)
    self.LayerLv3 = GameObject.Find("Canvas/LayerLv3").transform
    self:MyRefresh()
end
function C:ClearCell()
    if self.cell_map then
        for k, v in pairs(self.cell_map) do
            v.prefab:OnDestroy()
        end
    end
    self.cell_map = {}
end

function C:MyRefresh()
    self.act_cfg = self:GetBtnList()
    self.act_map = {}
    for k,v in ipairs(self.act_cfg) do
        self.act_map[ v.gotoui[1] ] = v
    end
    for k,v in ipairs(self.act_cfg) do
        local key = v.gotoui[1]
        local pp = v.gotoui[2] or "bytop_area"
        if not self.cell_map[key] then
            local pre = GameManager.GotoUI({gotoui=key, goto_scene_parm=pp, parm=v.parm, parent=self.content})
            if pre then
                self.cell_map[key] = {prefab = pre, key = key, cfg=v}
                if self.is_change then
                    self.select_index = k
                end
            else
                dump(v, "<color=red>[Debug] v</color>")
                if AppDefine.IsEDITOR() then
                    HintPanel.Create(1, "没有 创建成功，可能是条件不一致")
                end
            end
        end
    end
    for k,v in pairs(self.cell_map) do
        if not self.act_map[k] then
            if v.prefab.OnDestroy then
                v.prefab:OnDestroy()
                self.cell_map[k] = nil
            else
                if AppDefine.IsEDITOR() then
                    dump(self.act_map)
                    dump(self.cell_map)
                    HintPanel.Create(1, "没有 OnDestroy")
                end
            end
        end
    end
    self.is_change = false

    --如果在新手引导中,就选中开炮送红包,以免遮罩卡死
    if GuideModel.is_guide_ing then
        for k,v in pairs(self.act_cfg) do
            if v.gotoui[1] == "by3d_kpshb" then
                self.select_index = k
                break
            end
        end
    end

    self:RefreshSelect()
    self:RefreshHint()

    if self.cell_map and next(self.cell_map) then
        self.gameObject:SetActive(true)
        for k,v in pairs(self.cell_map) do
            v.prefab:MyRefresh()
        end
    else
        self.gameObject:SetActive(false)
    end
end
function C:RefreshSelect()
    if not self.act_cfg or #self.act_cfg == 0 then
        return
    end
    if self.select_index > #self.act_cfg then
        self.select_index = 1
    end
    for k,v in ipairs(self.act_cfg) do
        if k == self.select_index then
            if self.cell_map[ v.gotoui[1] ] then
                self.cell_map[ v.gotoui[1] ].prefab.transform.localPosition = Vector3.zero
            end
        else
            if self.cell_map[ v.gotoui[1] ] then
                self.cell_map[ v.gotoui[1] ].prefab.transform.localPosition = Vector3.New(0, 1000, 0)
            end
        end
    end
end

function C:RefreshHint()
    if not self.act_cfg or #self.act_cfg == 0 then
        return
    end

    self.left_get_hint.gameObject:SetActive(false)
    self.right_get_hint.gameObject:SetActive(false)
    if #self.act_cfg == 1 then
        self.left_node.gameObject:SetActive(false)
        self.right_node.gameObject:SetActive(false)
    else
        self.left_node.gameObject:SetActive(true)
        self.right_node.gameObject:SetActive(true)
    end

    if l then
        local key = self.act_cfg[self.select_index-1].gotoui[1]
        local module_cc = GameButtonManager.GetModuleByKey(key)
        if module_cc and module_cc.lua and _G[module_cc.lua] and _G[module_cc.lua].GetHintState then
            local state = _G[module_cc.lua].GetHintState()
            if state and state == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
                self.left_get_hint.gameObject:SetActive(true)
            end
        end
    end
    if r then
        local key = self.act_cfg[self.select_index+1].gotoui[1]
        local module_cc = GameButtonManager.GetModuleByKey(key)
        if module_cc and module_cc.lua and _G[module_cc.lua] and _G[module_cc.lua].GetHintState then
            local state = _G[module_cc.lua].GetHintState()
            if state and state == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
                self.right_get_hint.gameObject:SetActive(true)
            end
        end
    end
end

function C:OnSelectClick(cha)
    GameComAnimTool.PlayShowAndHideAndCall(self.LayerLv3, "BY3DKPSHBEnterPanel_guang", self.transform.position, 1)

    self.select_index = self.select_index + cha
    if self.select_index < 1 then
        self.select_index = #self.act_cfg
    end
    if self.select_index > #self.act_cfg then
        self.select_index = 1
    end
    self:RefreshSelect()
    self:RefreshHint()
end

function C:ui_button_state_change_msg()
    self.is_change = true
    self:MyRefresh()
end
function C:global_hint_state_change_msg(parm)
    if self.cell_map[parm.gotoui] then

        local key = parm.gotoui
        local module_cc = GameButtonManager.GetModuleByKey(key)
        if module_cc and module_cc.lua and _G[module_cc.lua] and _G[module_cc.lua].GetHintState then
            local state = _G[module_cc.lua].GetHintState()
            if state and state == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
                for k,v in ipairs(self.act_cfg) do
                    if v.gotoui[1] == key then
                        self.select_index = k
                        self:RefreshSelect()
                        break
                    end
                end
            end
        end
    end
end

function C:global_select_top_index_msg(parm)
    if self.cell_map[parm.gotoui] then
        local key = parm.gotoui
        for k,v in ipairs(self.act_cfg) do
            if v.gotoui[1] == key then
                self.select_index = k
                self:RefreshSelect()
                break
            end
        end
    end
end