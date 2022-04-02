-- 创建时间:2019-03-26
-- 常规技能

local basefunc = require "Game.Common.basefunc"

FishingNorSKillPrefab = basefunc.class()

local C = FishingNorSKillPrefab

C.name = "FishingNorSKillPrefab"

function C.Create(tran, panelSelf)
	return C.New(tran, panelSelf)
end
function C:FrameUpdate(time_elapsed)
    local userdata = FishingModel.GetPlayerData()
    if userdata and userdata.base then
        if userdata.lock_state ~= "nor" then
            self.lock_cd_img.fillAmount = userdata.lock_cd / userdata.lock_max_cd
        end

        if userdata.frozen_state ~= "nor" then
            self.ice_cd_img.fillAmount = userdata.frozen_cd / userdata.frozen_max_cd
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
    self.lister["model_ice_skill_change_msg"] = basefunc.handler(self, self.model_ice_skill_change_msg)
    self.lister["model_lock_skill_change_msg"] = basefunc.handler(self, self.model_lock_skill_change_msg)
    -- self.lister["ui_laser_state_change"] = basefunc.handler(self, self.ui_laser_state_change)
    self.lister["ui_lock_fly_finish_msg"] = basefunc.handler(self, self.ui_lock_fly_finish_msg)
    self.lister["ui_ice_fly_finish_msg"] = basefunc.handler(self, self.ui_ice_fly_finish_msg)
    self.lister["ui_zh_fly_finish_msg"] = basefunc.handler(self, self.ui_zh_fly_finish_msg)
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

    self.Lockpart = self.lock_jineng_glow:GetComponent("ParticleSystem")

    self.Icepart = self.ice_jineng_glow:GetComponent("ParticleSystem")

    self.MFpart = self.zh_jineng_glow:GetComponent("ParticleSystem")
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
    
    self.ice_btn.onClick:AddListener(function ()
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

    newObject("UIkuang_glow", self.LockReadyNode)
    newObject("UIkuang_glow", self.IceReadyNode)
    newObject("UIkuang_glow", self.ZHReadyNode)
    newObject("UIkuang_glow", self.JGReadyNode)
    newObject("UIkuang_glow", self.BoomReadyNode)
    self.LockReadyNode.gameObject:SetActive(false)
    self.IceReadyNode.gameObject:SetActive(false)
    self.ZHReadyNode.gameObject:SetActive(false)
    self.JGReadyNode.gameObject:SetActive(false)
    self.BoomReadyNode.gameObject:SetActive(false)

    self.isOnOffMF = true
    if self.isOnOffMF then
        self.zh_image.material = nil
    else
        self.zh_image.material = GetMaterial("imageGrey")
    end

    self:MyRefresh()
end
function C:MyRefresh()
    local userdata = FishingModel.GetPlayerData()
    if userdata and userdata.base then
        self.lock_hf_txt.text = "500"
        self.ice_hf_txt.text = "500"
        self.zh_hf_txt.text = "10000"
        self:SetLaserHide()
        -- self:RefreshLaser()
        self:UpdateMissileState()
        self:RefreshLock()
        self:RefreshIce()
        self:RefreshMF()
    end
end

function C:RefreshLaser()
    local userdata = FishingModel.GetPlayerData()
    local bullet_cfg = FishingModel.GetGunCfg(userdata.index)
    local cur = userdata.laser_rate or 0
    local max = bullet_cfg.laser_max_rate

    if cur < max then
        self.JGRect.gameObject:SetActive(false)
        self.JGRect.transform.localPosition = Vector3.New(0, -40, 0)
    else
        self.JGRect.gameObject:SetActive(true)
        self.JGRect.transform.localPosition = Vector3.New(0, 120, 0)
    end

    if FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "ready" then
        self.JGReadyNode.gameObject:SetActive(true)
    else
        self.JGReadyNode.gameObject:SetActive(false)
    end
end

function C:RefreshLock()
    local userdata = FishingModel.GetPlayerData()
    self.lock_number_txt.text = "" .. (userdata.prop_fish_lock or 0)
    if userdata.lock_state == "inuse" then
        self.LockReadyNode.gameObject:SetActive(true)
    else
        self.LockReadyNode.gameObject:SetActive(false)
    end

    if (userdata.prop_fish_lock or 0) <= 0 then
        self.LockPayRect.gameObject:SetActive(true)
    else
        self.LockPayRect.gameObject:SetActive(false)
    end

    if userdata.lock_state == "inuse" then
        self.lock_cd_img.gameObject:SetActive(true)
        self.LockReadyNode.gameObject:SetActive(true)
        self.lock_cd_img.fillMethod = UnityEngine.UI.Image.FillMethod.Radial360
        self.lock_cd_img.fillOrigin = 2
    elseif userdata.lock_state == "cooling" then
        self.lock_cd_img.gameObject:SetActive(true)
        self.LockReadyNode.gameObject:SetActive(false)
        self.lock_cd_img.fillMethod = UnityEngine.UI.Image.FillMethod.Vertical
        self.lock_cd_img.fillOrigin = 2
    else
        self.lock_cd_img.gameObject:SetActive(false)
    end
end
function C:RefreshIce()
    local userdata = FishingModel.GetPlayerData()
    self.ice_number_txt.text = "" .. (userdata.prop_fish_frozen or 0)
    if userdata.frozen_state == "inuse" then
        self.IceReadyNode.gameObject:SetActive(true)
    else
        self.IceReadyNode.gameObject:SetActive(false)
    end
    
    if (userdata.prop_fish_frozen or 0) <= 0 then
        self.IcePayRect.gameObject:SetActive(true)
    else
        self.IcePayRect.gameObject:SetActive(false)
    end

    if userdata.frozen_state == "inuse" then
        self.ice_cd_img.gameObject:SetActive(true)
        self.IceReadyNode.gameObject:SetActive(true)
        self.ice_cd_img.fillMethod = UnityEngine.UI.Image.FillMethod.Radial360
        self.ice_cd_img.fillOrigin = 2
    elseif userdata.frozen_state == "cooling" then
        self.ice_cd_img.gameObject:SetActive(true)
        self.IceReadyNode.gameObject:SetActive(false)
        self.ice_cd_img.fillMethod = UnityEngine.UI.Image.FillMethod.Vertical
        self.ice_cd_img.fillOrigin = 2
    else
        self.ice_cd_img.gameObject:SetActive(false)
    end
end
function C:RefreshMF()
    local nn = GameItemModel.GetItemCount("prop_3d_fish_summon_fish")
    self.ZHReadyNode.gameObject:SetActive(false)
    self.zh_number_txt.text = nn
    if nn <= 0 then
        self.ZHPayRect.gameObject:SetActive(true)
    else
        self.ZHPayRect.gameObject:SetActive(false)
    end
end

function C:MyExit()
    if self.laser_seq then
        self.laser_seq:Kill()
        self.laser_seq = nil
    end
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

-- 冰冻技能状态改变
function C:model_ice_skill_change_msg(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if seat_num == my_seat_num then
        self:RefreshIce()
    end
end
-- 锁定技能状态改变
function C:model_lock_skill_change_msg(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if seat_num == my_seat_num then
        self:RefreshLock()
    end
end

function C:ui_lock_fly_finish_msg(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if seat_num == my_seat_num then
        if self.Lockpart then
            self.Lockpart:Play()
        end
    end
end

function C:ui_ice_fly_finish_msg(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if seat_num == my_seat_num then
        if self.Icepart then
            self.Icepart:Play()
        end
    end
end

function C:ui_zh_fly_finish_msg(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if seat_num == my_seat_num then
        if self.MFpart then
            self.MFpart:Play()
        end
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
        end
    end
end

function C:GetBoomPos()
    return self.BoomRect.transform.position
end

-- ********************************
--    Button
-- ********************************
function C:OnLockClick()
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_suoding.audio_name)
    if FishingModel.UseSkill("prop_fish_lock") then
    end
end


function C:OnIceClick()
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_bingfeng.audio_name)
    if FishingModel.UseSkill("prop_fish_frozen") then
    end
end

function C:OnZHClick()
    if not self.isOnOffMF then
        return
    end
    ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_zhaohuan.audio_name)

    local nn = GameItemModel.GetItemCount("prop_3d_fish_summon_fish")
    local userdata = FishingModel.GetPlayerData()
    if userdata.base.score >= 10000 or nn > 0 then
        FishingModel.UseItem("prop_3d_fish_summon_fish", function ()
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
        self.jg_xl_audio = ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiguang1.audio_name, -1)
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
    self.lock_number_txt.text = "" .. (userdata.prop_fish_lock or 0)
    self.ice_number_txt.text = "" .. (userdata.prop_fish_frozen or 0)
    local nn = GameItemModel.GetItemCount("prop_3d_fish_summon_fish")
    self.zh_number_txt.text = nn
end