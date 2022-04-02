local basefunc = require "Game.Common.basefunc"
FishingDRGun = basefunc.class()
local C = FishingDRGun

-- 数据
local ControlMode = { }-- 枪的瞄准状态
ControlMode.Manual = 0-- 手动
ControlMode.Auto = 1-- 自动

function C.Create(data)
	return C.New(data)
end

function C:ctor(data)
    self.data = data
    self.last_fire_time = 0-- 最后一次发炮的时间
    
	self.transform = GameObject.Find("FishingDR2DUI/GunNode/Node" .. self.data.id).transform
    self.GunAnim = self.transform:Find("GunAnim")
    self.Gun = self.transform:Find("GunAnim/Gun")
    self.GunDz = self.transform:Find("GunDz")
    self.GunOpen = self.transform:Find("GunAnim/Gun/GunOpen")
    self.GunAnim.transform.localRotation = Quaternion.Euler(0, 0, -90)
    self.shootAnim = self.Gun.gameObject:GetComponent("Animator")
    self.shootNode = GameObject.Find("Canvas/GUIRoot/FishingDRGamePanel/UINode/GunShootSkillNode").transform

    self.level = 1
    self:RefreshGunLevel()
end

function C:MyExit()
    self.data = nil
    self.last_fire_time = 0-- 最后一次发炮的时间
	self.transform = nil
    self.GunAnim = nil
    self.Gun = nil
    self.GunOpen = nil

    self.level = nil
end

function C:FrameUpdate()

    self:RefreshGunLevel()

    if not self.data.is_use then
        return
    end
    if FishingDRModel.check_is_dead_or_flee(self.data.id) then
        return
    end
    if self.data.control_mode == ControlMode.Auto then
        self:AutoShoot()
    end
end

-- 自动开枪
function C:AutoShoot()
    self:Shoot(0, true)
end

-- 手动开枪
function C:ManualShoot(vec)
    local dirVec
    local gunP = self.Gun.transform.position
    if vec.x < gunP.x then
        vec.x = gunP.x
    end
    local p =(vec - gunP)
    dirVec = p.normalized
    local r = Vec2DAngle(dirVec)
    self:Shoot(r, false)
end

-- 发送开枪消息
function C:Shoot(r, auto)
    -- 射击指令来源与当前射击状态不一致
    if not auto and self.data.control_mode == ControlMode.Auto then
        self:RotateTo(r)
        return
    end
    if (UnityEngine.Time.realtimeSinceStartup - self.last_fire_time) < (self.data.cooldown / self.data.cooldown_coefficient) then
        self:RotateTo(r)
        return
    end
    if self.data.bullet_num_limit > 0 and FishingDRBulletManager.GetBulletNumberByGunID(self.data.id) >= self.data.bullet_num_limit then
        self:RotateTo(r)
        return
    end
    --先旋转炮台再开枪
    self:RotateTo(r)
    self.last_fire_time = UnityEngine.Time.realtimeSinceStartup
    if self.data and (self.data.id == 8 or self.data.id == FishingDRGunManager.GetFirstGunId()) then
        ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_by_zidan2.audio_name)
    end
    self.shootAnim:Play("open_gun_anim", -1, 0)
    
    local data = { }
    data.pos = self:GetBulletPos()
    data.angle = r - 90
    data.gun_id = self.data.id--枪的id
    data.player_id = self.data.player_id--枪的id
    data.level = self.data.level
    data.pos_ui = FishingDRModel.Get2DToUIPoint(self.Gun.transform.position)
    Event.Brocast("shoot","shoot",data)
end

function C:GetBulletPos()
    return self.GunOpen.transform.position
end
 
-- 旋转
function C:RotateTo(r)
    self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
end

-- 设置是否自动
function C:SetAuto(b)
    if b then
        self.data.control_mode = ControlMode.Auto
    else
        self.data.control_mode = ControlMode.Manual
    end
    self.data.cooldown_coefficient = 1
end

-- 设置是否自动
function C:CheckIsAutoShoot()
    return self.data.control_mode == ControlMode.Auto
end

-- 设置发射冷却系数
function C:SetAutoCoefficient(v)
    v = tonumber(v)
    self.data.cooldown_coefficient = v
end

function C:SetCooldown(v)
    self.data.cooldown = v
end

function C:SetUse(b)
    self.data.is_use = b
end

function C:RefreshGunLevel()
    if self.level ~= self.data.level then
        self.level = self.data.level

        local GunSp = self.Gun:GetComponent("SpriteRenderer")
        GunSp.sprite = GetTexture(string.format("fkby_pt%d_icon_2",self.level))

        local GunDzSp = self.GunDz:GetComponent("SpriteRenderer")
        GunDzSp.sprite = GetTexture(string.format("fkby_pt%d_icon_1",self.level))

    end
end

--[[
    GetTexture("fkby_pt2_icon_1")
    GetTexture("fkby_pt2_icon_2")
    GetTexture("fkby_pt3_icon_1")
    GetTexture("fkby_pt3_icon_2")
]]