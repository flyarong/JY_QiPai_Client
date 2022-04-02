-- 创建时间:2019-03-11
-- 抢

local basefunc = require "Game.Common.basefunc"

FishingGun = basefunc.class()

local C = FishingGun

C.name = "FishingGun"

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
    self.Cooldown = FishingModel.Defines.nor_bullet_cooldown or 0.15-- 发射冷却
    self.NumBulletLimit = FishingModel.Defines.bullet_num_limit or 10-- 子弹限制
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

end

function C:FrameUpdate()
    if not self.isUse then
        return
    end
    local user = FishingModel.GetPosToPlayer(self.seat_num)
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
-- 强制开抢
function C:ForceShoot(parm)
    local dirVec
    if parm and parm.vec then
        local gunP = self.GunAnim.transform.position
        local p =(parm.vec - gunP)
        dirVec = p.normalized
    else
        local rr = self.GunAnim.transform.localEulerAngles.z + 90

        if self.seat_num == 3 or self.seat_num == 4 then
            rr = rr + 180
        end

        local Deg2Rad = (3.1415926 * 2) / 360
        local vec = Vector3(math.cos(rr * Deg2Rad), math.sin(rr * Deg2Rad), 0)
        dirVec = vec
    end
    if parm and parm.type then
        self:SendRunShoot(dirVec, nil, nil, parm.type)
    else
        self:SendRunShoot(dirVec, nil, nil, 5)
    end
end
-- 自动开枪
function C:AutoShoot()
    local rr = self.GunAnim.transform.localEulerAngles.z + 90

    if FishingModel.IsRotationPlayer() then
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
    local gunP = self.GunAnim.transform.position
 
    if self.seat_num == FishingModel.data.seat_num then
        if FishingModel.IsRotationPlayer() then
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
    local gunP = self.GunAnim.transform.position
    local p = data.Fish:GetLockPos() - gunP
    local dirVec = p.normalized

    self:SendShoot(dirVec, true, data.ID)
end
-- 发送开枪消息
function C:SendShoot(vec, auto, FishID)
    if self.isFinishShoot then
        return
    end
    local user = FishingModel.GetPosToPlayer(self.seat_num)
    local dirVec = vec
    -- 射击指令来源与当前射击状态不一致
    if not auto and self.mControlMode == ControlMode.Auto then
        if self.seat_num == FishingModel.data.seat_num then
            local r = Vec2DAngle(dirVec)
            self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
            Event.Brocast("activity_fish_gun_rotation",{angle = r - 90,seat_num = self.seat_num})
        end
        return
    end
    if (UnityEngine.Time.realtimeSinceStartup - self.mLastFireTime) < (self.Cooldown / self.cooldown_coefficient) then
        if self.seat_num == FishingModel.data.seat_num then
            local r = Vec2DAngle(dirVec)
            self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
            Event.Brocast("activity_fish_gun_rotation",{angle = r - 90,seat_num = self.seat_num})
        end
        return
    end
    if self.NumBulletLimit > 0 and BulletManager.GetBulletNumber(self.seat_num) >= self.NumBulletLimit then
        if self.seat_num == FishingModel.data.seat_num then
            local r = Vec2DAngle(dirVec)
            self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
            Event.Brocast("activity_fish_gun_rotation",{angle = r - 90,seat_num = self.seat_num})
        end
        return
    end

    -- 锁定状态 枪都会旋转
    if FishID then
        local r = Vec2DAngle(dirVec)
        self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
    end

    local show_score = user.base.score + user.base.fish_coin
    local all_score = user.base.score + user.base.fish_coin + user.wait_add_score
    local cur_gun_rate = FishingModel.GetGunCfg(user.index).gun_rate
    local min_gun_rate = FishingModel.GetMinGunCfg().gun_rate
    local bullet_num = BulletManager.GetBulletNumber(self.seat_num)
    -- 是否破产
    local isPC = false
    if not FishingActivityManager.CheckHaveBullet(self.seat_num) then
        if bullet_num <= 0 and all_score < min_gun_rate then
            if user.isPC and (FishID or self.mControlMode == ControlMode.Auto) then
                return
            end
            isPC = true
            user.isPC = true
            Event.Brocast("model_player_PC", user.base.seat_num)
            return
        end

        if show_score < cur_gun_rate then
            -- 等待金币动画完成后把钱加上
            if all_score ~= show_score then
                return
            end
            -- user.index 不可能为1
            -- 降低倍率
            local is_down_gun = false
            local min = FishingModel.GetMinGunIndex()
            for i = user.index-1, min, -1 do
                local rate = FishingModel.GetGunCfg(i).gun_rate
                if rate <= show_score then
                    user.index = i
                    Event.Brocast("set_gun_rate", user.base.seat_num)
                    is_down_gun = true
                    break
                end
            end
            if not is_down_gun then
                return
            end
        end
    end    
    
    if self.seat_num == FishingModel.data.seat_num then
        if not FishingModel.IsMoneyBeyond() then
            if not user.is_hint_goto then
                local pre = HintPanel.Create(1, "您太富有了，更高级的场次才适合您！", function ()
                    local id = FishingModel.GetCanEnterID()
                    FishingModel.GotoFishingByID(id)
                end)
                pre:SetButtonText(nil, "前往")
            end
            user.is_hint_goto = true
            return
        end
    end
    
    self:SendRunShoot(vec, auto, FishID)
end

-- 开始开枪
function C:SendRunShoot(vec, auto, FishID, act_type)
    local dirVec = vec
    --先旋转炮台在开枪
    local r = Vec2DAngle(dirVec)
    self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
    Event.Brocast("activity_fish_gun_rotation",{angle = r - 90,seat_num = self.seat_num})
    self.isFinishShoot = true
    local data = { }
    data.x = dirVec.x
    data.y = dirVec.y
    if FishID then
        data.lock_fish_id = FishID
    end
    data.seat_num = self.seat_num
    if act_type then
        data.act_type = act_type
    else
        data.act_type = FishingActivityManager.GetCurActivityBulletType(self.seat_num)
    end
    FishingModel.SendShoot(data, isPC)
end

-- 开枪
function C:RunShoot(data)
    self.isFinishShoot = false
    self.mLastFireTime = UnityEngine.Time.realtimeSinceStartup
end

function C:GetBulletPos()
    if IsEquals(self.GunOpen) then
        return self.GunOpen.transform.position
    end
    return Vector3.zero
end
 
-- 停止旋转
function C:StopRotate()
    self.mRotateState = RotateState.Idle
end
-- 旋转
function C:RotateTo(r)
    self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
end
function C:RotateToPos(vec)
    local gunP = self.GunAnim.transform.position
 
    if self.seat_num == FishingModel.data.seat_num then
        if FishingModel.IsRotationPlayer() then
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

    local r = Vec2DAngle(dirVec)
    self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, r - 90)
    Event.Brocast("activity_fish_gun_rotation",{angle = r - 90,seat_num = self.seat_num})
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

function C:UpdateGunCfg()
    local user = FishingModel.GetPosToPlayer(self.seat_num)
    local n_g = FishingModel.GetGunSkinCfg(self.seat_num, user.index)
    if user and user.base and n_g then
        self.Cooldown = n_g.fire_speed or 0.15-- 发射冷却
    end
end


