-- 创建时间:2019-03-11
-- 玩家自己
-- 这个是玩家自己

local basefunc = require "Game.Common.basefunc"

FishingPlayer = basefunc.class()

local C = FishingPlayer

C.name = "FishingPlayer"

local M = FishingMatchModel
function C.Create(panelSelf, i, ui, ui_2D)
	return C.New(panelSelf, i, ui, ui_2D)
end
function C:FrameUpdate(time_elapsed)
    if FishingMatchModel.IsCanUseGun(self.uipos) then
        -- 激光技能状态是使用中或者是准备使用
        if self.userdata.use_laser_state ~= "nor" then
            return
        end
        -- 锁定
        local my_seat_num = FishingMatchModel.GetPlayerSeat()
        if self.userdata.lock_state == "inuse" then
            if self.userdata.lock_fish_id <= 0 then
                local fish = FishManager.GetMaxScorePoolFish(self.userdata.seat_num)
                if fish then
                    self.userdata.lock_fish_id = fish.data.fish_id
                end
            end
            if self.userdata.lock_fish_id > 0 then
                local fish = FishManager.GetFishByID(self.userdata.lock_fish_id)
                if fish then
                    local pos = FishingMatchModel.Get2DToUIPoint(fish:GetLockPos())
                    self.panelSelf.LockHintImage.gameObject:SetActive(true)
                    self.panelSelf.LockHintAnim.transform.position = pos

                    local b_pos = FishingMatchModel.Get2DToUIPoint(self.GunAnim.transform.position)
                    local e_pos = FishingMatchModel.Get2DToUIPoint(fish:GetLockPos())
                    self.panelSelf.DotLine.transform.position = b_pos
                    self.panelSelf.DotLine.transform.rotation = self.GunOpen.transform.rotation
                    local len = Vec2DLength({x=b_pos.x-e_pos.x, y=b_pos.y-e_pos.y})
                    self.panelSelf.DotLineLayout.spacing = (len-100-240) / 6
                else
                    self.userdata.lock_fish_id = -1
                end

                if self.userdata.is_first_lock then
                    self.panelSelf.LockHintAnim:Play("suoding", -1, 0)
                    self.userdata.is_first_lock = false
                    if self.suoding_time then
                        self.suoding_time:Stop()
                        self.suoding_time = nil
                    end
                    self.suoding_time = Timer.New(function ()
                        self.suoding_time = nil
                        self.panelSelf.LockHintAnim:Play("suoding_nor", -1, 0)
                    end, 1, 1)
                    self.suoding_time:Start()
                end
            else
                self.panelSelf.LockHintImage.gameObject:SetActive(false)
            end
        end

        if self.gun then
            self.gun:FrameUpdate()
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
    if self.suoding_time then
        self.suoding_time:Stop()
        self.suoding_time = nil
    end
    destroy(self.lock_obj)
    self.lock_obj = nil
    self:RemoveListener()
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
    self.GradesIconImage = self.transform:Find("YesNode/Image1/IconImage")
    self.IconImage = self.transform:Find("YesNode/Image2/IconImage")
    self.NameText = self.transform:Find("YesNode/NameText"):GetComponent("Text")
    self.YBText = self.transform:Find("YesNode/Image1/MoneyText"):GetComponent("Text")
    self.MoneyText = self.transform:Find("YesNode/Image2/MoneyText"):GetComponent("Text")
    self.GunBG = self.transform_2D:Find("GunF"):GetComponent("SpriteRenderer")
    self.Gun = self.transform_2D:Find("GunAnim/Gun"):GetComponent("SpriteRenderer")
    self.GunAnim = self.transform_2D:Find("GunAnim")
    self.GunAnim1 = self.transform_2D:Find("GunAnim1")
    self.GunOpen = self.transform_2D:Find("GunAnim/Gun/GunOpen")
    self.CaiHongNode = self.transform_2D:Find("CaiHongNode")
    self.CaiHongPrefab = newObject("CaiHongPrefab", self.CaiHongNode)
    self.CaiHongAnim = self.CaiHongPrefab:GetComponent("Animator")
    self.CaiHongHI = self.CaiHongPrefab.transform:Find("CaiHongHI")
    self.JDNode = self.CaiHongPrefab.transform:Find("JDNode")

    self.PCNode = self.transform:Find("YesNode/RateRect/PCNode")
    self.IceNode = self.transform:Find("YesNode/RateRect/IceNode")
    self.FXNode = self.transform:Find("YesNode/FXNode")
    self.MuzzleNode = self.transform:Find("YesNode/FXNode/MuzzleNode")
    self.shootAnim = self.Gun.gameObject:GetComponent("Animator")
    self.RateRect = self.transform:Find("YesNode/RateRect")
    self.AutoAnim = self.transform:Find("YesNode/RateRect/AutoAnim")
    self.RateText = self.transform:Find("YesNode/RateRect/RateText"):GetComponent("Text")
    self.PlayerFXNode = self.transform:Find("YesNode/RateRect/PlayerFXNode")
    self.SubButtonImage = self.transform:Find("YesNode/RateRect/SubButtonImage"):GetComponent("Button")
    self.AddButtonImage = self.transform:Find("YesNode/RateRect/AddButtonImage"):GetComponent("Button")
    self.AddMoneyRect = self.transform:Find("YesNode/AddMoneyRect")
    self.SubButtonImage.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnDownGunLevel()
    end)
    self.AddButtonImage.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnUpGunLevel()
    end)
    self.MaskNode = self.transform:Find("YesNode/RateRect/MaskNode")

    self.CaiHongNode.gameObject:SetActive(false)
    
    self.AutoAnim.gameObject:SetActive(false)
    self.isChangeGunLevelFinish = true
    self.gun = FishingGun.Create(self, FishingMatchModel.GetPosToSeatno(self.uipos), ui_2D)

    self.gunStageAnim = self.GunAnim1:GetComponent("Animator")

    local pos1 = self.RateRect.transform.position
    local pos2d = FishingMatchModel.GetUITo2DPoint(pos1)
    self.transform_2D.position = Vector3.New(pos2d.x, self.transform_2D.position.y, self.transform_2D.position.z)
    local pos = FishingMatchModel.Get2DToUIPoint(self.GunAnim.transform.position)
    self.FXNode.transform.position = pos

    self:MyRefresh()
end
function C:MyRefresh()
    self.userdata = self:GetUser()
    self:SetAuto(false)
    self.AutoAnim.gameObject:SetActive(false)
	
    if self.userdata and self.userdata.base then
        local pos1 = self.RateRect.transform.position
        local pos2d = FishingMatchModel.GetUITo2DPoint(pos1)
        self.transform_2D.position = Vector3.New(pos2d.x, self.transform_2D.position.y, self.transform_2D.position.z)
        local pos = FishingMatchModel.Get2DToUIPoint(self.GunAnim.transform.position)
        self.FXNode.transform.position = pos
		self.YesNode.gameObject:SetActive(true)
		self.NoNode.gameObject:SetActive(false)
        self.gameObject_2D:SetActive(true)

        if self.userdata.base.score == 0 then
            self.PCNode.gameObject:SetActive(true)
        else
            self.PCNode.gameObject:SetActive(false)
        end

        if self.userdata.frozen_state == "inuse" then
            self.IceNode.gameObject:SetActive(true)
        else
            self.IceNode.gameObject:SetActive(false)
        end

        self.NameText.text = self.userdata.base.name
        self:RefreshMoney()
        self:RefreshGun()
        self:RefreshJG()
        self:RefreshLock()
        self:ShowSubsidyPop()

        if self.userdata.is_auto then
            self:SetAuto(true)
        else
            self:SetAuto(false)
        end

        self.SubButtonImage.gameObject:SetActive(false)
        self.AddButtonImage.gameObject:SetActive(false)
        self.CaiHongPrefab.gameObject:SetActive(true)
	else
        if self.suoding_time then
            self.suoding_time:Stop()
            self.suoding_time = nil
        end
        if self.lock_obj then
            GameObject.Destroy(self.lock_obj)
            self.lock_obj = nil
        end

        self.YesNode.gameObject:SetActive(false)
        self.NoNode.gameObject:SetActive(false)
        self.gameObject_2D:SetActive(false)
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

-- 刷新钱
function C:RefreshMoney(change_type)
    self.YBText.text = StringHelper.ToCashAndBit(M.data.grades, 2)
    self.MoneyText.text = StringHelper.ToCashAndBit(M.data.score, 2)
    self:RefreshPC(change_type)
end

function C:set_gun_rate(seat_num)
    if self.userdata and self.userdata.seat_num == seat_num then
        self:RefreshGun()
        self:RefreshJG(true)
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
    self.Gun.sprite = GetTexture(gun_config.gun_icon)
    self.RateText.text = gun_config.gun_rate
    self.gun:RefreshGun()
    if self.userdata then
        Event.Brocast("refresh_gun",{seat_num = self.userdata.seat_num, gun_rate = gun_config.gun_rate})
    end
    local s_inx = FishingMatchModel.GetGunStageIndex(self.userdata.seat_num)
    if s_inx == 1 then
        self.gunStageAnim:Play("gunanim_paotai1", -1, 0)
    elseif s_inx == 2 then
        self.gunStageAnim:Play("gunanim_paotai2", -1, 0)
    elseif s_inx == 3 then
        self.gunStageAnim:Play("gunanim_paotai3", -1, 0)
    else
        self.gunStageAnim:Play("gunanim_paotai4", -1, 0)
    end
end
function C:SetQuickShoot(data)
    self.gun:SetQuickShoot(data)
end

-- 刷新激光进度
function C:RefreshJG(isanim)


end

-- 设置锁定
function C:RefreshLock()
    local my_seat_num = FishingMatchModel.GetPlayerSeat()

    if self.userdata and self.userdata.seat_num == my_seat_num then
        if self.userdata.lock_state == "inuse" then
            if not self.lock_obj then
                self.lock_obj = newObject("suoding_glow", self.FXNode)
                self.lock_obj.transform.localPosition = Vector3.New(0, 30, 0)
            end
        else
            self.panelSelf.LockHintImage.gameObject:SetActive(false)
            if self.lock_obj then
                GameObject.Destroy(self.lock_obj)
                self.lock_obj = nil
            end            
        end
    end
end

-- 刷新破产
function C:RefreshPC(change_type)
    if self.pc_seq then
        self.pc_seq:Kill()
    end
    local bullet_num = BulletManager.GetBulletNumber(self.userdata.seat_num)
    local cur_score = M.data.score
    local all_score = M.data.score + M.data.wait_add_score
    local min_gun_rate = FishingMatchModel.GetGunCfgByPlayer(self.userdata).gun_rate
    if FishingActivityManager.CheckHaveBullet(self.userdata.seat_num) or (all_score > 0 and all_score >= min_gun_rate) or bullet_num > 0 then
        self.userdata.isPC = false
        self.PCNode.gameObject:SetActive(false)
    else
        self.userdata.isPC = true
        self.PCNode.gameObject:SetActive(true)
        self.PCNode.transform.localScale = Vector3.New(1, 1, 1)
        self:ShowSubsidyPop(change_type)
    end
end

-- 加钱动画
function C:AddMoneyNumber(data)
    if self.userdata then
        local score = data.score
        if score > M.data.wait_add_score then
            print("<color=white>动画结束后增加的钱超过等待增加的钱的总量</color>")
            print("<color=white>等待增加的钱的总量" .. M.data.wait_add_score .. "</color>")
            print("<color=white>动画结束后增加的钱" .. score .. "</color>")
            return
        end
        self:AddGradesNumber(data)
        M.data.wait_add_score = M.data.wait_add_score - score

        M.data.score = M.data.score + score
        self:RefreshMoney()

        local beginPos = self.AddMoneyRect.transform.position
        FishingAnimManager.PlayGoldUpMove(self.AddMoneyRect.transform, beginPos, score)
    end
end
-- 加 累计赢金动画
function C:AddGradesNumber(data, isanim)
    if self.userdata and data.grades then
        local score = data.grades
        if score > M.data.wait_add_grades then
            print("<color=white>动画结束后增加的累计赢金超过等待增加的累计赢金的总量</color>")
            print("<color=white>等待增加的累计赢金的总量" .. M.data.wait_add_grades .. "</color>")
            print("<color=white>动画结束后增加的累计赢金" .. score .. "</color>")
            return
        end
        M.data.wait_add_grades = M.data.wait_add_grades - score
        M.data.grades = M.data.grades + score
        self:RefreshMoney()
        if isanim then
            local beginPos = self.AddMoneyRect.transform.position
            FishingAnimManager.PlayGradesUpMove(self.AddMoneyRect.transform, beginPos, score)
        end
    end
end

-- 破产
function C:SetPC()
    if not self.PCNode.gameObject.activeSelf then
        self.PCNode.gameObject:SetActive(true)
        self.PCNode.transform.localScale = Vector3.New(3, 3, 3)
        if self.pc_seq then
            self.pc_seq:Kill()
        end
        self.pc_seq = DoTweenSequence.Create()
        self.pc_seq:AppendInterval(0.5)
        self.pc_seq:Append(self.PCNode.transform:DOScale(Vector3.one, 0.2))
        self.pc_seq:OnKill(function ()
            self.pc_seq = nil
        end)
    end
    self:ShowSubsidyPop()
end

-- 是否是冰冻状态
function C:SetIce(isice)
    if isice then
        self.IceNode.gameObject:SetActive(true)
    else
        self.IceNode.gameObject:SetActive(false)
    end
end

-- 升级枪
function C:SetUpGunLevel()
    self.isChangeGunLevelFinish = true
end
-- 降级枪
function C:SetDownGunLevel()
    self.isChangeGunLevelFinish = true
end
-- 升级枪
function C:OnUpGunLevel()
    if not self.isChangeGunLevelFinish then
        return
    end
    local laser = self.userdata.use_laser_state
    if laser and laser == "inuse" then
        return
    end
    local my_seat_num = FishingMatchModel.GetPlayerSeat()
    local index = FishingMatchModel.GetChangeRate(self.userdata.gun_info.show_bullet_index, 1)
    if index then
        self.isChangeGunLevelFinish = false
        self.userdata.gun_info.show_bullet_index = index
        self:RefreshGun()
        self:SetUpGunLevel()
        self:RefreshJG(true)
        if self.userdata and my_seat_num == self.userdata.seat_num then
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jiabei.audio_name)
        end
    end
end
-- 降级枪
function C:OnDownGunLevel()
    if not self.isChangeGunLevelFinish then
        return
    end
    local laser = self.userdata.use_laser_state
    if laser and laser == "inuse" then
        return
    end
    local my_seat_num = FishingMatchModel.GetPlayerSeat()
    local index = FishingMatchModel.GetChangeRate(self.userdata.gun_info.show_bullet_index, -1)
    if index then
        self.isChangeGunLevelFinish = false
        self.userdata.gun_info.show_bullet_index = index
        self:RefreshGun()
        self:SetDownGunLevel()
        self:RefreshJG(true)
        if self.userdata and self.userdata.base and my_seat_num == self.userdata.base.seat_num then
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jianbei.audio_name)
        end
    end
end

function C:SetGunLevel(target_index)
    if not self.userdata or not self.userdata.gun_info then
        self.userdata = self:GetUser()
    end
    if not self.userdata or not self.userdata.gun_info or not self.userdata.gun_info.show_bullet_index then
        return
    end
    dump(self.userdata, "<color=yellow>self.userdata>>>>>>></color>")
    local offsect = target_index - self.userdata.gun_info.show_bullet_index
    local index = FishingMatchModel.GetChangeRate(self.userdata.gun_info.show_bullet_index, offsect)
    if index then
        self.userdata.gun_info.show_bullet_index = index
        self:RefreshGun()
        self:SetDownGunLevel()
        self:RefreshJG(true)
        if self.userdata and self.userdata.base and my_seat_num == self.userdata.base.seat_num then
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jianbei.audio_name)
        end
    end
end

-- 手动开枪
function C:ManualShoot(vec)
    if self.userdata and self.userdata.isPC then
        self:ShowSubsidyPop()
        Event.Brocast("model_fsmg_match_revive_msg")
    end

    if self.userdata and self.userdata.lock_state ~= "inuse" and self.userdata.use_laser_state == "nor" then
	   self.gun:ManualShoot(vec)
    end
end

-- 执行开枪
function C:RunShoot(data)
    if not FishingMatchModel.IsRecoverRet then
    	-- 首次开抢后移除提示效果
    end

    self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, data.angle)
    BulletManager.CreateBullet(data)

    self.shootAnim:Play("open_gun_anim", -1, 0)

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
    return self.IconImage.transform.position
end
-- 飞累计赢金的坐标点
function C:GetFlyGradesPos()
    return self.GradesIconImage.transform.position
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
    return self.MBImage.transform.position
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
    if b then
        self.AutoAnim.gameObject:SetActive(true)
    else
        self.AutoAnim.gameObject:SetActive(false)
    end
    self.gun:SetAuto(b)
end
-- 设置发射冷却系数
function C:SetAutoCoefficient(v)
    self.gun:SetAutoCoefficient(v)
end

function C:ShowSubsidyPop(change_type)
    --屏蔽抽奖破产弹窗
    if change_type and change_type == "fishing_task_chou_jiang" then
        return
    end
    if self.userdata and self.userdata.seat_num == M.data.seat_num then
        if self.userdata.isPC then
            if self.is_show_pc then
                self.is_show_pc = true
                HintPanel.Create(1, "破产提示!!!", function ()
                    self.is_show_pc = false
                end)
                self.userdata.is_auto = false
                Event.Brocast("ui_auto_change")
            end
        end
    end
end

