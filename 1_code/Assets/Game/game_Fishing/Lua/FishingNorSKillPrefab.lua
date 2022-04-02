-- 创建时间:2019-03-26
-- 常规技能

local basefunc = require "Game.Common.basefunc"

FishingNorSKillPrefab = basefunc.class()

local C = FishingNorSKillPrefab

C.name = "FishingNorSKillPrefab"

local EnterState = {
    hide = "hide",
    hide_ing = "hide_ing",
    show = "show",
    show_ing = "show_ing",
}

function C.Create(tran, panelSelf)
	return C.New(tran, panelSelf)
end
function C:FrameUpdate(time_elapsed)
    local userdata = FishingModel.GetPlayerData()
    if userdata and userdata.base then
        for k,v in ipairs(FishingModel.TimeSkill) do
            if userdata[v.type .. "_state"] ~= "nor" then
                self[v.type .. "_cd_img"].fillAmount = userdata[v.type .. "_cd"] / userdata[v.type .. "_max_cd"]
            end
        end

        if self.zh_map then
            local cur_t = os.time()
            for k,v in pairs(self.zh_map) do
                if (self.zh_xz_time + v) <= cur_t then
                    self.zh_map[k] = nil
                    self.zh_count = self.zh_count - 1
                end
            end
        end
        if self.zh_cd and self.zh_cd > 0 then
            self.zh_cd = self.zh_cd - time_elapsed
            if self.zh_cd < 0 then
                self.zh_cd = 0
                self.zh_cd_img.gameObject:SetActive(false)
            end
            self.zh_cd_img.fillAmount = self.zh_cd / self.zh_cd_val
        end
    end
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_time_skill_change_msg"] = basefunc.handler(self, self.model_time_skill_change_msg)
    self.lister["model_player_money_msg"] = basefunc.handler(self, self.model_player_money_msg)

    self.lister["ui_zh_fly_finish_msg"] = basefunc.handler(self, self.ui_zh_fly_finish_msg)
    self.lister["ui_laser_state_change"] = basefunc.handler(self, self.ui_laser_state_change)
    self.lister["ui_timeskill_fly_finish_msg"] = basefunc.handler(self, self.ui_timeskill_fly_finish_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(tran, panelSelf)
	self.panelSelf = panelSelf
	self.gameObject = tran.gameObject
	self.transform = tran

	self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(tran, self)

    self.zh_image = self.zh_btn.transform:GetComponent("Image")

    self.jg_num_txt.gameObject:SetActive(false)

    self.BoomRect = tran:Find("BoomRect")
    self.BoomButton = tran:Find("BoomRect/BoomButton"):GetComponent("Button")
    self.BoomReadyNode = tran:Find("BoomRect/ReadyNode")
    self.BoomImage = {}
    for i = 1, 4 do
        self.BoomImage[i] = tran:Find("BoomRect/BoomImage" .. i):GetComponent("Image")
    end
    self.BoomRect.gameObject:SetActive(false)

    self.frozen_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnIceClick()
    end)
    self.lock_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnLockClick()
    end)
    self.zh_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnZHClick()
    end)
    self.jg_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnJGClick()
    end)
    self.BoomButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBoomClick()
    end)

    self.accelerate_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAccelerateClick()
    end)
    self.wild_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnWildClick()
    end)
    self.doubled_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnDoubledClick()
    end)

    self.jt_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnJTClick()
    end)

    newObject("UIkuang_glow", self.ZHReadyNode)
    newObject("UIkuang_glow", self.JGReadyNode)
    newObject("UIkuang_glow", self.BoomReadyNode)
    for k,v in ipairs(FishingModel.TimeSkill) do
        self[v.type .. "ReadyNode"].gameObject:SetActive(false)
        newObject("UIkuang_glow", self[v.type .. "ReadyNode"])
    end

    self.ZHReadyNode.gameObject:SetActive(false)
    self.JGReadyNode.gameObject:SetActive(false)
    self.BoomReadyNode.gameObject:SetActive(false)
    
    -- 召唤的CD
    self.zh_cd_val = 10
    -- self.zh_xz_time时间内召唤self.zh_xz_count次，进入CD
    self.zh_xz_time = 10
    self.zh_xz_count = 10

    self.isOnOffMF = true
    if self.isOnOffMF then
        self.zh_image.material = nil
    else
        self.zh_image.material = GetMaterial("imageGrey")
    end
    self:SetMaskShow(false)
    self:MyRefresh()
end
function C:MyRefresh()
    local userdata = FishingModel.GetPlayerData()
    if userdata and userdata.base then
        for k,v in ipairs(FishingModel.TimeSkill) do
            dump(v)
            dump(FishingModel.GetSkillMoney(v.tool_type))
            dump(self[v.type .. "_hf_txt"])
            self[v.type .. "_hf_txt"].text = "" .. FishingModel.GetSkillMoney(v.tool_type)
        end

        self.zh_hf_txt.text = "" .. FishingModel.GetSkillMoney("prop_fish_summon_fish")
        self:SetLaserHide()
        self:UpdateMissileState()
        for k,v in ipairs(FishingModel.TimeSkill) do
            self:RefreshTimeSkill(v.type)
        end
        self:RefreshMF()
    end
end

function C:RefreshMF()
    local nn = GameItemModel.GetItemCount("prop_fish_summon_fish")
    self.ZHReadyNode.gameObject:SetActive(false)
    self.zh_number_txt.text = nn
    if nn <= 0 then
        self.ZHPayRect.gameObject:SetActive(true)
    else
        self.ZHPayRect.gameObject:SetActive(false)
    end
end

function C:RefreshTimeSkill(tool_type)
    local userdata = FishingModel.GetPlayerData()
    self[tool_type .. "_number_txt"].text = "" .. (userdata["prop_fish_" .. tool_type] or 0)
    local state = userdata[tool_type .. "_state"]
    if state == "inuse" then
        self[tool_type .. "ReadyNode"].gameObject:SetActive(true)
    else
        self[tool_type .. "ReadyNode"].gameObject:SetActive(false)
    end
    
    if (userdata["prop_fish_" .. tool_type] or 0) <= 0 then
        self[tool_type .. "PayRect"].gameObject:SetActive(true)
    else
        self[tool_type .. "PayRect"].gameObject:SetActive(false)
    end

    if state == "inuse" then
        self[tool_type .. "_cd_img"].gameObject:SetActive(true)
        self[tool_type .. "_cd_img"].fillMethod = UnityEngine.UI.Image.FillMethod.Radial360
        self[tool_type .. "_cd_img"].fillOrigin = 2
    elseif state == "cooling" then
        self[tool_type .. "_cd_img"].gameObject:SetActive(true)
        self[tool_type .. "_cd_img"].fillMethod = UnityEngine.UI.Image.FillMethod.Vertical
        self[tool_type .. "_cd_img"].fillOrigin = 2
    else
        self[tool_type .. "_cd_img"].gameObject:SetActive(false)
    end
end

function C:MyExit()
    if self.laser_seq then
        self.laser_seq:Kill()
        self.laser_seq = nil
    end
    self:KillDotween()
    self:RemoveListener()
end

-- 
function C:UpdateMissileState()
    local userdata = FishingModel.GetPlayerData()

    for k,v in ipairs(userdata.missile_list) do
        if v == 0 then
            self.BoomImage[k].gameObject:SetActive(false)
        else
            self.BoomImage[k].gameObject:SetActive(true)
            if v == 1 then
                self.BoomImage[k].sprite = GetTexture("by_btn_hd" .. k)
            else
                self.BoomImage[k].sprite = GetTexture("by_btn_hdj" .. k)
            end
        end
    end
    if userdata.missile_index >= 4 then
        self.BoomButton.gameObject:SetActive(true)
    else
        self.BoomButton.gameObject:SetActive(false)
    end
    if FishingModel.GetPlayerMissileState(FishingModel.GetPlayerSeat()) == "ready" then
        self.BoomReadyNode.gameObject:SetActive(true)
    else
        self.BoomReadyNode.gameObject:SetActive(false)
    end
end

function C:SetLaserHide()
    if self.jg_xl_audio then
        soundMgr:CloseLoopSound(self.jg_xl_audio)
        self.jg_xl_audio = nil
    end
    self.JGReadyNode.gameObject:SetActive(false)
    self.JGRect.gameObject:SetActive(false)
    self.JGRect.transform.localPosition = Vector3.New(0, -40, 0)
    self:CloseJGXL()
end
function C:SetMissileHide()
    self.BoomReadyNode.gameObject:SetActive(false)
end

function C:model_time_skill_change_msg(seat_num, tool_type)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if seat_num == my_seat_num then
        self:RefreshTimeSkill(tool_type)
    end
end

function C:model_player_money_msg(data)
    for k,v in ipairs(FishingModel.TimeSkill) do
        self:RefreshTimeSkill(v.type)
    end
end

function C:ui_zh_fly_finish_msg(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if seat_num == my_seat_num then
        FishingAnimManager.PlayShowAndHideFX(self.MFRect, "jineng_glow", self.MFRect.transform.position, 2)
    end
end

function C:ui_timeskill_fly_finish_msg(seat_num, num, tool_type)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if seat_num == my_seat_num then
        FishingAnimManager.PlayShowAndHideFX(self[tool_type .. "Rect"], "jineng_glow", self[tool_type .. "Rect"].transform.position, 2)
    end
end

function C:GetBoomPos()
    return self.BoomRect.transform.position
end

-- ********************************
--    Button
-- ********************************
function C:OnLockClick()
    ExtendSoundManager.PlaySound(audio_config.by.bgm_by_suoding.audio_name)

    local userdata = FishingModel.GetPlayerData()
    local mm = userdata.base.score + userdata.base.fish_coin

    local nn = GameItemModel.GetItemCount("prop_fish_lock")
    if nn > 0 or mm >= FishingModel.GetSkillMoney("prop_fish_lock") then
        FishingModel.UseItem("prop_fish_lock")
    else
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end
end


function C:OnIceClick()
    ExtendSoundManager.PlaySound(audio_config.by.bgm_by_bingfeng.audio_name)

    local userdata = FishingModel.GetPlayerData()
    local mm = userdata.base.score + userdata.base.fish_coin

    local nn = GameItemModel.GetItemCount("prop_fish_frozen")
    if nn > 0 or mm >= FishingModel.GetSkillMoney("prop_fish_frozen") then
        FishingModel.UseItem("prop_fish_frozen")
    else
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end
end

local local_zh_id = -1
local function GetZHID()
    local id = local_zh_id
    local_zh_id = local_zh_id - 1
    if local_zh_id < -10000000 then
        local_zh_id = -1
    end
    return id
end
function C:OnZHClick()
    if not self.isOnOffMF then
        return
    end
    ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zhaohuan.audio_name)

    if self.zh_cd and self.zh_cd > 0 then
        LittleTips.Create("召唤技能正在CD中")
        return
    end

    local nn = GameItemModel.GetItemCount("prop_fish_summon_fish")
    local userdata = FishingModel.GetPlayerData()
    if userdata.base.score >= FishingModel.GetSkillMoney("prop_fish_summon_fish") or nn > 0 then
        self.zh_map = self.zh_map or {}
        self.zh_count = self.zh_count or 0
        self.zh_count = self.zh_count + 1
        self.zh_map[GetZHID()] = os.time()

        -- X秒Y次 加CD
        if self.zh_count and self.zh_count >= self.zh_xz_count then
            self.zh_cd = self.zh_cd_val
            self.zh_cd_img.gameObject:SetActive(true)
        end

        FishingModel.UseItem("prop_fish_summon_fish", function ()
            self:RefreshMF()
        end)
    else
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end
end

function C:CloseJGXL()
    if IsEquals(self.jg_xl_fx) then
        CachePrefabManager.Back(self.jg_xl_fx)
    end
end

function C:CreateJGXL()
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    local gunP = self.panelSelf.PlayerClass[uipos]:GetBulletPos()
    local pos = FishingModel.Get2DToUIPoint(gunP)

    self.jg_xl_fx = CachePrefabManager.Take("jiguang_attack_node_1")
    self.jg_xl_fx.prefab:SetParent(self.panelSelf.FXNode)
    local tran = self.jg_xl_fx.prefab.prefabObj.transform
    tran.position = pos
    tran.rotation = self.panelSelf.PlayerClass[uipos]:GetGunRotation()
end

function C:OnJGClick()
    if FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "nor" then
        FishingModel.SetPlayerLaserState(FishingModel.GetPlayerSeat(), "ready")
        self.JGReadyNode.gameObject:SetActive(true)
        self.panelSelf.LockHintImage.gameObject:SetActive(false)

        if self.jg_xl_audio then
            soundMgr:CloseLoopSound(self.jg_xl_audio)
            self.jg_xl_audio = nil
        end
        self.jg_xl_audio = ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiguang1.audio_name, -1)
        self:CloseJGXL()
        self:CreateJGXL()
    elseif FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "ready" then
        FishingModel.SetPlayerLaserState(FishingModel.GetPlayerSeat(), "nor")
        self.JGReadyNode.gameObject:SetActive(false)
        self.jg_xl_audio = ExtendSoundManager.CloseSound(self.jg_xl_audio)
        self:CloseJGXL()
    end
end

function C:OnBoomClick()
    if FishingModel.GetPlayerMissileState(FishingModel.GetPlayerSeat()) == "nor" then
        FishingModel.SetPlayerMissileState(FishingModel.GetPlayerSeat(), "ready")
        self.BoomReadyNode.gameObject:SetActive(true)
    elseif FishingModel.GetPlayerMissileState(FishingModel.GetPlayerSeat()) == "ready" then
        FishingModel.SetPlayerMissileState(FishingModel.GetPlayerSeat(), "nor")
        self.BoomReadyNode.gameObject:SetActive(false)
    end
end

function C:RefreshAssets()
    local userdata = FishingModel.GetPlayerData()
    for k,v in ipairs(FishingModel.TimeSkill) do
        self[v.type .. "_number_txt"].text = "" .. (userdata["prop_fish_" .. v.type] or 0)
    end

    local nn = GameItemModel.GetItemCount("prop_fish_summon_fish")
    self.zh_number_txt.text = nn
end

-- 快速射击
function C:OnAccelerateClick()
    local userdata = FishingModel.GetPlayerData()
    local mm = userdata.base.score + userdata.base.fish_coin

    local tool = "prop_fish_accelerate"
    local nn = GameItemModel.GetItemCount(tool)
    if nn > 0 or mm >= FishingModel.GetSkillMoney(tool) then
        FishingModel.UseItem(tool)
    else
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end
end

-- 提升命中
function C:OnWildClick()
    local userdata = FishingModel.GetPlayerData()
    if userdata.doubled_state ~= "nor" then
        LittleTips.Create("不能与双倍奖励同时使用")
        return
    end

    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="xshb_042_deblocking_v1", is_on_hint = true}, "CheckCondition")
    if a and not b then
        LittleTips.Create("VIP1及以上等级才可使用")
        return
	end

    local mm = userdata.base.score + userdata.base.fish_coin

    local tool = "prop_fish_wild"
    local nn = GameItemModel.GetItemCount(tool)
    if nn > 0 or mm >= FishingModel.GetSkillMoney(tool) then
        FishingModel.UseItem(tool)
    else
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end
end

-- 双倍
function C:OnDoubledClick()
    local userdata = FishingModel.GetPlayerData()
    if userdata.wild_state ~= "nor" then
        LittleTips.Create("不能与超级火力同时使用")
        return
    end

    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="xshb_042_deblocking_v1", is_on_hint = true}, "CheckCondition")
    if a and not b then
        LittleTips.Create("VIP1及以上等级才可使用")
        return
	end

    local mm = userdata.base.score + userdata.base.fish_coin

    local tool = "prop_fish_doubled"
    local nn = GameItemModel.GetItemCount(tool)
    if nn > 0 or mm >= FishingModel.GetSkillMoney(tool) then
        FishingModel.UseItem(tool)
    else
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end
end

-- 箭头
function C:OnJTClick()
    if self.EnterState == EnterState.show or self.EnterState == EnterState.show_ing then
        self:hide()
    else
        self:show()
    end
end

function C:ui_laser_state_change(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if seat_num == my_seat_num then
        if FishingModel.GetPlayerLaserState(seat_num) == "inuse" then
            return
        end
        local userdata = FishingModel.GetPlayerData()
        if userdata and userdata.base then
            local bullet_cfg = FishingModel.GetGunCfg(userdata.index)
            local cur = userdata.laser_rate or 0
            local max = bullet_cfg.laser_max_rate
            if self.laser_seq then
                self.laser_seq:Kill()
                self.laser_seq = nil
            end
            self:CloseJGXL()
            FishingModel.SetPlayerLaserState(FishingModel.GetPlayerSeat(), "nor")
            self.JGReadyNode.gameObject:SetActive(false)
            if cur < max then
                self.JGRect.gameObject:SetActive(false)
                self.JGRect.transform.localPosition = Vector3.New(0, -40, 0)
            else
                self.JGRect.gameObject:SetActive(true)
                self.JGRect.transform.localPosition = Vector3.New(0, -40, 0)
                self.laser_seq = DoTweenSequence.Create()
                self.laser_seq:Append(self.JGRect.transform:DOLocalMove(Vector3.New(0, 120, 0), 0.2))
            end
            if FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "ready" then
                self.JGReadyNode.gameObject:SetActive(true)
            else
                self.JGReadyNode.gameObject:SetActive(false)
            end
        end
    end
end


function C:SetMaskShow(b)
    if b then
        self.EnterState = EnterState.show
        self.move_skill_node.transform.localPosition = Vector3.New(0, 150, 0)
    else
        self.EnterState = EnterState.hide
        self.move_skill_node.transform.localPosition = Vector3.New(0, 16, 0)
    end
    self.jt1_img.gameObject:SetActive(b)
    self.jt2_img.gameObject:SetActive(not b)
end
function C:show()
    self.EnterState = EnterState.show_ing
    self:KillDotween()
    self.seq1 = DoTweenSequence.Create()
    self.seq1:Append(self.move_skill_node.transform:DOLocalMoveY(150, 0.3))
    self.seq1:OnKill(function ()
        self:SetMaskShow(true)
    end)
end

function C:hide()
    self.EnterState = EnterState.hide_ing
    self:KillDotween()
    self.seq1 = DoTweenSequence.Create()
    self.seq1:Append(self.move_skill_node.transform:DOLocalMoveY(16, 0.3))
    self.seq1:OnKill(function ()
        self:SetMaskShow(false)
    end)
end
function C:KillDotween()
    if self.seq1 then
        self.seq1:Kill()
        self.seq1 = nil
    end
end