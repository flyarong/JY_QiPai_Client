-- 创建时间:2019-06-27
-- 玩家的副手

local basefunc = require "Game.Common.basefunc"

FishingPlayerAss = basefunc.class()

local C = FishingPlayerAss

C.name = "FishingPlayerAss"

function C.Create(panelSelf, i, ui, ui_2D)
	return C.New(panelSelf, i, ui, ui_2D)
end
function C:FrameUpdate(time_elapsed)
	if self.gun then
        self.gun:FrameUpdate()
    end
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["set_gun_rate"] = basefunc.handler(self, self.set_gun_rate)
    self.lister["auto_state_change_msg"] = basefunc.handler(self, self.on_auto_state_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:RemoveListener()
    if self.down_lock_time then
        self.down_lock_time:Stop()
        self.down_lock_time = nil
    end
    if self.update_time then
        self.update_time:Stop()
        self.update_time = nil
    end
end

function C:ctor(panelSelf, i, ui, ui_2D)
	self.panelSelf = panelSelf
	self.uipos = i
	self.gameObject = ui.gameObject
	self.transform = ui.transform
	self.gameObject_2D = ui_2D.gameObject
	self.transform_2D = ui_2D.transform

	self:MakeLister()
    self:AddMsgListener()

    self.YesNode = self.transform:Find("YesNode")
    self.NoNode = self.transform:Find("NoNode")
    self.MBImage = self.transform:Find("YesNode/Image")
    self.GunBG = self.transform_2D:Find("GunF"):GetComponent("SpriteRenderer")
    self.Gun = self.transform_2D:Find("GunAnim/Gun"):GetComponent("SpriteRenderer")
    self.GunAnim = self.transform_2D:Find("GunAnim")
    self.GunOpen = self.transform_2D:Find("GunAnim/Gun/GunOpen")
    self.CaiHongNode = self.transform_2D:Find("CaiHongNode")
    self.CaiHongPrefab = newObject("CaiHongPrefab", self.CaiHongNode)
    self.CaiHongAnim = self.CaiHongPrefab:GetComponent("Animator")
    self.CaiHongHI = self.CaiHongPrefab.transform:Find("CaiHongHI")
    self.JDNode = self.CaiHongPrefab.transform:Find("JDNode")

    self.FXNode = self.transform:Find("YesNode/FXNode")
    self.MuzzleNode = self.transform:Find("YesNode/FXNode/MuzzleNode")
    self.shootAnim = self.Gun.gameObject:GetComponent("Animator")
    self.RateRect = self.transform:Find("YesNode/RateRect")
    self.RateText = self.transform:Find("YesNode/RateRect/RateText"):GetComponent("Text")
    self.PlayerFXNode = self.transform:Find("YesNode/RateRect/PlayerFXNode")

    self.CDNode = self.transform:Find("YesNode/RateRect/CDNode")
    self.CDText = self.transform:Find("YesNode/RateRect/CDNode/CDText"):GetComponent("Text")
    self.LockButton = self.transform:Find("YesNode/RateRect/CDNode/LockButton"):GetComponent("Button")
    self.LockButton.onClick:AddListener(function ()
        self:OnUnlockClick()
    end)
    self.MaskNode = self.transform:Find("YesNode/RateRect/MaskNode")
    self.by_fengsuo = self.transform:Find("YesNode/RateRect/MaskNode/by_fengsuo"):GetComponent("Animator")
    self.MaskText = self.transform:Find("YesNode/RateRect/MaskNode/MaskText"):GetComponent("Text")

    self.CaiHongNode.gameObject:SetActive(false)
    self.isChangeGunLevelFinish = true
    self.gun = FishingGunAss.Create(self, FishingMatchModel.GetPosToSeatno(self.uipos), ui_2D)

    local pos1 = self.RateRect.transform.position
    local pos2d = FishingMatchModel.GetUITo2DPoint(pos1)
    self.transform_2D.position = Vector3.New(pos2d.x, self.transform_2D.position.y, self.transform_2D.position.z)
    local pos = FishingMatchModel.Get2DToUIPoint(self.GunAnim.transform.position)
    self.FXNode.transform.position = pos

    self.time_call_map = {}
    self.update_time = Timer.New(function ()
        self:Update()
    end, 1, -1, nil, true)
    self.update_time:Start()
    
    self:MyRefresh()
end
function C:GetCall(t)
    local tt = t
    local cur = 0
    return function (st)
        cur = cur + st
        if cur >= tt then
            cur = cur - tt
            return true
        end
        return false
    end
end
function C:Update()
    for k,v in pairs(self.time_call_map) do
        if v.time_call(1) then
            v.run_call()
        end
    end

end
function C:GetUnlockMoney()
    local unlock_money = FishingMatchModel.Config.fish_parm_map.unlock_price_per_second
    local interval = 4
    local dt = self.userdata.gun_info.lock_time or 0
    local ps = unlock_money[self.uipos]
    local dt = math.ceil(dt / interval)*interval
    local money = math.ceil(dt * ps)
    money = math.max(0, money)
    return money
end
function C:UpdateLockTime(b)
    if not b then
        if self.userdata.gun_info and self.userdata.gun_info.lock_time then
            self.userdata.gun_info.lock_time = self.userdata.gun_info.lock_time - 1
        end
    end
    if not (self.userdata.gun_info and self.userdata.gun_info.lock_time) then
        self.time_txt.text = "--:--:--"
    else
        local mm = math.floor(self.userdata.gun_info.lock_time / 60)
        local ss = self.userdata.gun_info.lock_time % 60
        
        self.CDText.text = "解锁倒计时：" .. string.format("%02d:%02d", mm, ss)
        if self.userdata.gun_info.lock_time <= 0 then
            self.CDNode.gameObject:SetActive(false)
            self.time_call_map["down_lock_time"] = nil
        end

        if self.unlock_pre then
            local money = self:GetUnlockMoney()
            local desc = "" .. money
            
            if not self.unlock_pre:SetDesc(desc) then
                self.unlock_pre = nil
            end
        end
    end
end
-- 封禁炮台
function C:UpdateBlockTime(b)
    if not b then
        if self.userdata.gun_info and self.userdata.gun_info.block_time then
            self.userdata.gun_info.block_time = self.userdata.gun_info.block_time - 1
        end
    end
    if not (self.userdata.gun_info and self.userdata.gun_info.block_time) then
        self.MaskText.text = ""
    else
        local mm = self.userdata.gun_info.block_time
        
        self.MaskText.text = "" .. mm
        if self.userdata.gun_info.block_time <= 0 then
            self.time_call_map["down_block_time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.HideBlock)}
            self.Gun.color = Color.New(1, 1, 1, 1)
            self.by_fengsuo:Play("by_jiesuo", -1, 0)
        end
    end
end
function C:HideBlock()
    self.MaskNode.gameObject:SetActive(false)
    self.time_call_map["down_block_time"] = nil
end

function C:MyRefresh(type)
    self.userdata = self:GetUser()
	
    if self.userdata.gun_info and self.userdata.gun_info.show == 1 then
        local pos1 = self.RateRect.transform.position
        local pos2d = FishingMatchModel.GetUITo2DPoint(pos1)
        self.transform_2D.position = Vector3.New(pos2d.x, self.transform_2D.position.y, self.transform_2D.position.z)
        local pos = FishingMatchModel.Get2DToUIPoint(self.GunAnim.transform.position)
        self.FXNode.transform.position = pos
        self.YesNode.gameObject:SetActive(true)
        self.NoNode.gameObject:SetActive(false)
        self.gameObject_2D:SetActive(true)

        if self.userdata.gun_info.lock_time <= 0 then
            self:RefreshGun()
        else
            self.Gun.color = Color.New(1, 1, 1, 1)
            self.CDNode.gameObject:SetActive(true)
            self.time_call_map["down_lock_time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateLockTime)}
            self:UpdateLockTime(true)
        end
        if not self.userdata.gun_info.block_time or self.userdata.gun_info.block_time <= 0 then
            self:RefreshGun()
        else
            self.MaskNode.gameObject:SetActive(true)
            self.time_call_map["down_block_time"] = {time_call = self:GetCall(1), run_call = basefunc.handler(self, self.UpdateBlockTime)}
            self:UpdateBlockTime(true)
            self.Gun.color = Color.New(116/255, 116/255, 116/255, 1)
            if type and type == "stop_gun" then
                self.by_fengsuo:Play("by_fengsuo", -1, 0)
            end
        end

        local user = FishingMatchModel.GetPlayerData()
        if user.is_auto then
            self:SetAuto(true)
        else
            self:SetAuto(false)
        end

	else
        if self.down_lock_time then
            self.down_lock_time:Stop()
            self.down_lock_time = nil
        end

        self.YesNode.gameObject:SetActive(true)
        self.NoNode.gameObject:SetActive(true)
        self.Gun.color = Color.New(116/255, 116/255, 116/255, 1)
        self.gameObject_2D:SetActive(true)
	end
end
-- 玩家数据
function C:GetUser()
    local i = FishingMatchModel.GetPosToSeatno(self.uipos)
    return FishingMatchModel.GetSeatnoToUser(i)
end

-- 设置玩家进入
function C:SetPlayerEnter()
    self.userdata = self:GetUser()
	self:MyRefresh()
end
-- 设置玩家离开
function C:SetPlayerExit()
	self:MyRefresh()
end

function C:set_gun_rate(seat_num)
    if self.userdata and self.userdata.seat_num == seat_num then
        self:RefreshGun()
    end
end
function C:on_auto_state_change_msg(seat_num)
    local user = FishingMatchModel.GetPlayerData()
    if user.is_auto then
        self:SetAuto(true)
    else
        self:SetAuto(false)
    end
end

-- 刷新枪
function C:RefreshGun()
    local gun_config = FishingMatchModel.GetGunCfg(self.userdata.gun_info.show_bullet_index, self.userdata.seat_num)
    -- self.Gun.sprite = GetTexture(gun_config.gun_icon)
    self.RateText.text = gun_config.gun_rate
    self.gun:RefreshGun()
    if self.userdata then
        Event.Brocast("refresh_gun",{seat_num = self.userdata.seat_num, gun_rate = gun_config.gun_rate})
    end
    self.MaskNode.gameObject:SetActive(false)
end
function C:SetQuickShoot(data)
    self.gun:SetQuickShoot(data)
end
function C:SetGunLevel(target_index)
    if not self.userdata or not self.userdata.gun_info.show_bullet_index then
        self.userdata = self:GetUser()
    end
    if not self.userdata or not self.userdata.gun_info then
        return
    end
    dump(self.userdata, "<color=yellow>self.userdata>>>>>>></color>")
    local offsect = target_index - self.userdata.gun_info.show_bullet_index
    local index = FishingMatchModel.GetChangeRate(self.userdata.gun_info.show_bullet_index, offsect)
    if index then
        self.userdata.gun_info.show_bullet_index = index
        self:RefreshGun()
        self:SetDownGunLevel()
        if self.userdata and my_seat_num == self.userdata.seat_num then
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jianbei.audio_name)
        end
    end
end

-- 手动开枪
function C:ManualShoot(vec)
    if FishingMatchModel.IsCanUseGun(self.uipos) then
       self.gun:ManualShoot(vec)
    end
end

-- 执行开枪
function C:RunShoot(data)
    self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, data.angle)
    BulletManager.CreateBullet(data)

    self.shootAnim:Play("by_pao_shayu", -1, 0)

    local my_seat_num = FishingMatchModel.GetPlayerSeat()
    if self.userdata and my_seat_num == self.userdata.seat_num then
        local isAct = FishingActivityManager.CheckIsActivityTime(self.userdata.seat_num)
        if isAct then
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zidan2.audio_name)
        else
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zidan.audio_name)
        end
    end

    local pos = FishingMatchModel.Get2DToUIPoint(self.GunOpen.transform.position)
    self.MuzzleNode.transform.position = pos
    self.MuzzleNode.transform.rotation = self.GunOpen.transform.rotation
    FishingAnimManager.PlayShootFX(self.MuzzleNode.transform, data)

    return self.gun:RunShoot(data)
end


-- 枪的旋转
function C:GetGunRotation()
    return self.GunOpen.transform.rotation
end

-- 子弹生成的坐标点
function C:GetBulletPos()
    return self.gun:GetBulletPos()
end
-- 飞金币的坐标点
function C:GetFlyGoldPos()
    return self.PlayerFXNode.transform.position
end
-- 飞累计赢金的坐标点
function C:GetFlyGradesPos()
    return self.PlayerFXNode.transform.position
end

-- 玩家特效的坐标点
function C:GetPlayerFXPos()
    return self.PlayerFXNode.transform.position
end
-- 极光特效点
function C:GetLaserFXPos()
    return self.GunBG.transform.position
end
-- 玩家面板的坐标
function C:GetMBPos()
    return self.PlayerFXNode.transform.position
end

-- 玩家面板的坐标
function C:GetPlayerPos()
    return self.RateRect.transform.position
end

-- 枪的坐标
function C:GetGunPos()
    return self.GunAnim.transform.position
end

function C:RotateTo(r)
    self.gun:RotateTo(r)
end

function C:GetCurGunLevel()
    return self.userdata.gun_info.show_bullet_index
end

function C:SetAuto(b)
    self.gun:SetAuto(b)
end
-- 设置发射冷却系数
function C:SetAutoCoefficient(v)
    self.gun:SetAutoCoefficient(v)
end

function C:RefreshJG()
    
end
function C:RefreshLock()
    
end
function C:RefreshPC()
    
end
function C:AddMoneyNumber()
    
end
function C:DecMoneyNumber()
    
end
function C:SetPC()
end
function C:SetUpGunLevel()
    
end
function C:SetDownGunLevel()
    
end

function C:OnUnlockClick()
    local money = self:GetUnlockMoney()
    local desc = "" .. money
    self.unlock_pre = HintUnlockPanel.Create(2, desc,function ()
        self.unlock_pre = nil
        local cur_money = self:GetUnlockMoney()
        if FishingMatchModel.data.score >= cur_money then
            Network.SendRequest("fsmg_unlock_barbette", {seat_num=self.uipos}, "", function (data)
                dump(data, "<color=red>fsmg_unlock_barbette EEE </color>")
                if data.result == 0 then
                    FishingMatchModel.data.score = FishingMatchModel.data.score - data.money
                    Event.Brocast("ui_refresh_player_money")
                else
                    HintPanel.ErrorMsg(data.result)
                end
            end)
        else
            local parm = {{isImg=1, value="bymatch_game_icon_fen2"}, {value="不足"}}
            LittleTips.CreateJoker(parm)
        end

    end, function ()
        self.unlock_pre = nil
    end)
end