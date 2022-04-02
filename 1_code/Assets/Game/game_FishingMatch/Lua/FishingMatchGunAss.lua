-- 创建时间:2019-06-27
-- 副手的抢

local basefunc = require "Game.Common.basefunc"

FishingGunAss = basefunc.class()

local C = FishingGunAss

C.name = "FishingGunAss"

-- 数据
local RotateSpeed = 60-- 角度/秒
local RotateRange = 180-- 角度
local RotateState = { }-- 枪的旋转状态
RotateState.Idle = 0-- 不转
RotateState.Left = 1-- 左转
RotateState.Right = 2-- 右转
local ControlMode = { }-- 枪的瞄准状态
ControlMode.Manual = 0-- 手动
ControlMode.Auto = 1-- 自动

function C.Create(panelSelf, i, ui)
	return C.New(panelSelf, i, ui)
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

function C:ctor(panelSelf, i, ui)
    self.cooldown_coefficient = 1
    self.ks_rate = 1
    self.Cooldown = FishingMatchModel.Defines.nor_bullet_cooldown or 0.15-- 发射冷却
    self.NumBulletLimit = FishingMatchModel.Defines.bullet_num_limit or 10-- 子弹限制
	self.panelSelf = panelSelf
    self.seat_num = i or -1 -- 枪的拥有者座位号

    self.mRotateState = RotateState.Idle-- 当前状态
	self.mControlMode = ControlMode.Manual-- 当前枪的瞄准状态
	self.isUse = true-- 是否可以使用(目前仅自己可用)
	self.mLastFireTime = 0-- 最后一次发炮的时间
	self.isFinishShoot = false-- 上一发炮弹是否发射完成

	self.gameObject = ui.gameObject
	self.transform = ui.transform

	self:MakeLister()
    self:AddMsgListener()

    self.GunAnim = self.transform:Find("GunAnim")
    self.Gun = self.transform:Find("GunAnim/Gun")
    self.GunOpen = self.transform:Find("GunAnim/Gun/GunOpen")
    self.GunAnim.transform.localRotation = Quaternion.Euler(0, 0, 0)
end

function C:FrameUpdate()
    if not FishingMatchModel.IsCanUseGun(self.seat_num) then
        return
    end
    local user = FishingMatchModel.GetPlayerData()
    -- 自动锁定
    if user.lock_fish_id > 0 then
        local fish = FishManager.GetFishByID(user.lock_fish_id)
        if not fish then
            user.lock_fish_id = -1
            return
        end
        local d = { }
        d.Fish = fish
        d.ID = user.lock_fish_id
        -- 锁定就自动攻击
        self:LockShoot(d)
    elseif self.mControlMode == ControlMode.Auto then
        self:AutoShoot()
    end
end
-- 自动开枪
function C:AutoShoot()
    local rr = self.GunAnim.transform.localEulerAngles.z + 90

    if self.seat_num > 2 then
        rr = rr + 180
    end

    local Deg2Rad = (3.1415926 * 2) / 360
    local vec = Vector3(math.cos(rr * Deg2Rad), math.sin(rr * Deg2Rad), 0)
    local dirVec = vec
    self:SendShoot(dirVec, true)
end
-- 手动开枪
function C:ManualShoot(vec)
    local dirVec
    local gunP = self.Gun.transform.position
 
    if self.seat_num == FishingMatchModel.data.seat_num then
        if self.seat_num > 2 then
            if vec.y > gunP.y then
                vec.y = gunP.y
            end
        else
            if vec.y < gunP.y then
                vec.y = gunP.y
            end
        end
    end

    local p =(vec - gunP)
    dirVec = p.normalized
    self:SendShoot(dirVec, false)
end
-- 锁定攻击
function C:LockShoot(data)
    local gunP = self.Gun.transform.position
    local p = data.Fish:GetLockPos() - gunP
    local dirVec = p.normalized

    self:SendShoot(dirVec, true, data.ID)
end
-- 发送开枪消息
function C:SendShoot(vec, auto, FishID)
    if self.isFinishShoot then
        return
    end
    local dirVec = vec
    -- 射击指令来源与当前射击状态不一致
    if not auto and self.mControlMode == ControlMode.Auto then
        local r = Vec2DAngle(dirVec)
        self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
        return
    end
    if (UnityEngine.Time.realtimeSinceStartup - self.mLastFireTime) < (self.Cooldown / (self.cooldown_coefficient * self.ks_rate)) then
        local r = Vec2DAngle(dirVec)
        self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
        return
    end
    if self.NumBulletLimit > 0 and BulletManager.GetBulletNumber(self.seat_num) >= self.NumBulletLimit then
        local r = Vec2DAngle(dirVec)
        self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
        return
    end

    -- 锁定状态 枪都会旋转
    if FishID then
        local r = Vec2DAngle(dirVec)
        self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
    end

    local show_score = FishingMatchModel.data.score
    local myuser = FishingMatchModel.GetPlayerData()
    local cur_gun_rate = FishingMatchModel.GetGunCfg(myuser.gun_info.show_bullet_index, 1).gun_rate
    if show_score < cur_gun_rate then
        return
    end

    --先旋转炮台在开枪
    local r = Vec2DAngle(dirVec)
    self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
    self.isFinishShoot = true
    local data = { }
    data.x = dirVec.x
    data.y = dirVec.y
    -- 锁定是否跟主炮一样
    if true and FishID then
        data.lock_fish_id = FishID
    end

    data.seat_num = self.seat_num
    data.ks_rate = self.ks_rate
    data.act_type = FishingActivityManager.GetCurActivityBulletType(self.seat_num)
    FishingMatchModel.SendShoot(data, isPC)
end
-- 开枪
function C:RunShoot(data)
    self.isFinishShoot = false
    self.mLastFireTime = UnityEngine.Time.realtimeSinceStartup
end

function C:GetBulletPos()
    return self.GunOpen.transform.position
end
 
-- 停止旋转
function C:StopRotate()
    self.mRotateState = RotateState.Idle
end
-- 旋转
function C:RotateTo(r)
    self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
end
-- 转向
function C:Rotate(isLeft)
    local direct = -1
    if isLeft then
        direct = 1
    end
    local rotateRrangeHalf = RotateRange * 0.5
    self.GunAnim.transform:Rotate(Vector3.forward, direct * Time.deltaTime * RotateSpeed)
    if self.GunAnim.transform.localEulerAngles.z > rotateRrangeHalf and self.GunAnim.transform.localEulerAngles.z <(360 - rotateRrangeHalf) then
        if direct > 0 then
            self.GunAnim.transform:Rotate(Vector3.forward, -1 *(self.GunAnim.transform.localEulerAngles.z - rotateRrangeHalf))
        else
            self.GunAnim.transform:Rotate(Vector3.forward,(360 - rotateRrangeHalf - self.GunAnim.transform.localEulerAngles.z))
        end
    end
end
-- 设置是否自动
function C:SetAuto(b)
    if b then
        self.mControlMode = ControlMode.Auto
    else
        self.mControlMode = ControlMode.Manual
    end
    self.cooldown_coefficient = 1
end
-- 设置发射冷却系数
function C:SetAutoCoefficient(v)
    v = tonumber(v)
    self.cooldown_coefficient = v
end

function C:SetCooldown(v)
    self.Cooldown = v
end

-- 设置快速
function C:SetQuickShoot(data)
    if data and data.num > 0 then
        self.ks_rate = data.rate
    else
        self.ks_rate = 1
    end
end

-- 枪改变 刷新
function C:RefreshGun()
    local user = FishingMatchModel.GetPosToPlayer(self.seat_num)
    local gun_config = FishingMatchModel.GetGunCfg(user.gun_info.show_bullet_index, user.seat_num)
    self.Cooldown = 1 / gun_config.fire_speed
    self.NumBulletLimit = gun_config.bullet_num_limit
end