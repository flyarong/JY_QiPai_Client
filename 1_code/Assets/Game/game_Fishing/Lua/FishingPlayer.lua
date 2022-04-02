-- 创建时间:2019-03-11
-- 玩家

local basefunc = require "Game.Common.basefunc"

FishingPlayer = basefunc.class()

local C = FishingPlayer

C.name = "FishingPlayer"

function C.Create(panelSelf, i, ui, ui_2D)
	return C.New(panelSelf, i, ui, ui_2D)
end
function C:FrameUpdate(time_elapsed)
    if self.userdata and self.userdata.base then
        -- 激光技能状态是使用中或者是准备使用
        if self.userdata.use_laser_state ~= "nor" then
            return
        end
        if self.userdata.is_lock_gun then
            return
        end
        -- 锁定
        local my_seat_num = FishingModel.GetPlayerSeat()
        if self.userdata.lock_state == "inuse" then
            if self.userdata.lock_fish_id <= 0 then
                local fish = FishManager.GetMaxScorePoolFish(self.userdata.base.seat_num)
                if fish then
                    self.userdata.lock_fish_id = fish.data.fish_id
                end
            end
            if my_seat_num == self.userdata.base.seat_num then
                if self.userdata.lock_fish_id > 0 then
                    local fish = FishManager.GetFishByID(self.userdata.lock_fish_id)
                    if fish then
                        local pos = FishingModel.Get2DToUIPoint(fish:GetLockPos())
                        self.panelSelf.LockHintImage.gameObject:SetActive(true)
                        self.panelSelf.LockHintAnim.transform.position = pos

                        local b_pos = FishingModel.Get2DToUIPoint(self.GunAnim.transform.position)
                        local e_pos = FishingModel.Get2DToUIPoint(fish:GetLockPos())
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
    self.lister["fishing_ready_finish"] = basefunc.handler(self, self.fishing_ready_finish)
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
    if self.lock_obj then
        GameObject.Destroy(self.lock_obj)
        self.lock_obj = nil
    end
    self:RemoveListener()
    GameManager.GotoUI({gotoui = "gift_fishing_subsidy",goto_scene_parm = "close_panel"})
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

    LuaHelper.GeneratingVar(self.transform, self)

    self.YesNode = self.transform:Find("YesNode")
    self.NoNode = self.transform:Find("NoNode")
    self.MBImage = self.transform:Find("YesNode/Image")
    self.IconImage = self.transform:Find("YesNode/Image2/IconImage")
    self.NameText = self.transform:Find("YesNode/NameText"):GetComponent("Text")
    self.YBText = self.transform:Find("YesNode/Image1/MoneyText"):GetComponent("Text")
    self.MoneyText = self.transform:Find("YesNode/Image2/MoneyText"):GetComponent("Text")
    self.GunBG = self.transform_2D:Find("GunF"):GetComponent("SpriteRenderer")
    self.Gun = self.transform_2D:Find("GunAnim/Gun"):GetComponent("SpriteRenderer")
    self.GunAnim = self.transform_2D:Find("GunAnim")
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
    if self.FSZT_btn then
        self.FSZT_btn.onClick:AddListener(function ()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnFSZTClick()
        end)
    end
    self.ZT = self.transform_2D:Find("GunAnim/Gun/GunOpen/ZT")
    self.ZT.gameObject:SetActive(false)
    self.AutoAnim.gameObject:SetActive(false)
    self.isChangeGunLevelFinish = true
    self.gun = FishingGun.Create(self, FishingModel.GetPosToSeatno(self.uipos), ui_2D)

    local pos1 = self.RateRect.transform.position
    local pos2d = FishingModel.GetUITo2DPoint(pos1)
    self.transform_2D.position = Vector3.New(pos2d.x, self.transform_2D.position.y, self.transform_2D.position.z)
    local pos = FishingModel.Get2DToUIPoint(self.GunAnim.transform.position)
    self.FXNode.transform.position = pos

    self:MyRefresh()
end
function C:MyRefresh()
    self.userdata = self:GetUser()
    self:SetAuto(false)
    self.AutoAnim.gameObject:SetActive(false)
	
    if self.userdata and self.userdata.base then
        local pos1 = self.RateRect.transform.position
        local pos2d = FishingModel.GetUITo2DPoint(pos1)
        self.transform_2D.position = Vector3.New(pos2d.x, self.transform_2D.position.y, self.transform_2D.position.z)
        local pos = FishingModel.Get2DToUIPoint(self.GunAnim.transform.position)
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

        if self.userdata.base.seat_num == FishingModel.GetPlayerSeat() then
            self.SubButtonImage.gameObject:SetActive(true)
            self.AddButtonImage.gameObject:SetActive(true)
            self.CaiHongPrefab.gameObject:SetActive(true)
        else
            self.SubButtonImage.gameObject:SetActive(false)
            self.AddButtonImage.gameObject:SetActive(false)
            self.CaiHongPrefab.gameObject:SetActive(false)
        end
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
        self.NoNode.gameObject:SetActive(true)
        self.gameObject_2D:SetActive(false)
	end
end
-- 玩家数据
function C:GetUser()
    local i = FishingModel.GetPosToSeatno(self.uipos)
    return FishingModel.GetSeatnoToUser(i)
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
    self.YBText.text = StringHelper.ToCashAndBit(self.userdata.base.fish_coin, 2)
    self.MoneyText.text = StringHelper.ToCashAndBit(self.userdata.base.score, 2)
    self:RefreshPC(change_type)
end

function C:set_gun_rate(seat_num)
    if self.userdata and self.userdata.base and self.userdata.base.seat_num == seat_num then
        self:RefreshGun()
        self:RefreshJG(true)
    end
end
-- 刷新枪
function C:RefreshGun()
    local my_seat_num = FishingModel.GetPlayerSeat()
    if self.userdata and self.userdata.base and self.userdata.base.seat_num == my_seat_num then
        FishingModel.my_gun_cur_index = self.userdata.index
        FishingModel.SetPlayerLaserState(FishingModel.GetPlayerSeat(), "nor")
    end
    local gun_config = FishingModel.GetGunCfg(self.userdata.index)
    self.Gun.sprite = GetTexture(gun_config.gun_icon)
    self.RateText.text = gun_config.gun_rate
    if self.userdata and self.userdata.base then
        Event.Brocast("refresh_gun",{seat_num = self.userdata.base.seat_num, gun_rate = gun_config.gun_rate})
    end
end

-- 刷新激光进度
function C:RefreshJG(isanim)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if self.userdata and self.userdata.base and my_seat_num == self.userdata.base.seat_num then
        local bullet_cfg = FishingModel.GetGunCfg(self.userdata.index)
        local cur = self.userdata.laser_rate or 0
        local max = bullet_cfg.laser_max_rate
        local val = cur / max
        if val > 1 then
            val = 1
        end
        self.JDNode.transform.rotation = Quaternion.Euler(0, 0, -90 * val)

        if cur >= max then
            self.CaiHongHI.gameObject:SetActive(true)
            self.CaiHongAnim:Play("JG_yes", -1, 0)
        else
            self.CaiHongAnim:Play("JG_nor", -1, 0)
            self.CaiHongHI.gameObject:SetActive(false)
        end

        if isanim then
            Event.Brocast("ui_laser_state_change", self.userdata.base.seat_num)
        end
    end
end

-- 设置锁定
function C:RefreshLock()
    local my_seat_num = FishingModel.GetPlayerSeat()

    if self.userdata and self.userdata.base and self.userdata.base.seat_num == my_seat_num then
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

function C:RefreshTimeSkill(tool_type)
    
end

-- 刷新破产
function C:RefreshPC(change_type)
    if self.pc_seq then
        self.pc_seq:Kill()
    end
    local bullet_num = BulletManager.GetBulletNumber(self.userdata.base.seat_num)
    local cur_score = self.userdata.base.score + self.userdata.base.fish_coin
    local all_score = self.userdata.base.score + self.userdata.base.fish_coin + self.userdata.wait_add_score
    local min_gun_rate = FishingModel.GetMinGunCfg().gun_rate
    if FishingActivityManager.CheckHaveBullet(self.userdata.base.seat_num) or (all_score > 0 and all_score >= min_gun_rate) or bullet_num > 0 then
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
function C:AddMoneyNumber(score)
    if self.userdata and self.userdata.base then
        if score > self.userdata.wait_add_score then
            print("<color=white>动画结束后增加的钱超过等待增加的钱的总量</color>")
            print("<color=white>等待增加的钱的总量" .. self.userdata.wait_add_score .. "</color>")
            print("<color=white>动画结束后增加的钱" .. score .. "</color>")
            return
        end
        self.userdata.wait_add_score = self.userdata.wait_add_score - score
        self.userdata.base.score = self.userdata.base.score + score

        self:RefreshMoney()
        local beginPos = self.AddMoneyRect.transform.position
        FishingAnimManager.PlayGoldUpMove(self.AddMoneyRect.transform, beginPos, score)
    end
end
-- 减钱动画
function C:DecMoneyNumber(num)
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
    local my_seat_num = FishingModel.GetPlayerSeat()
    local index = FishingModel.GetChangeRate(self.userdata.index, 1)
    if index then
        if self.userdata and self.userdata.base and FishingModel.GetPlayerSeat() == self.userdata.base.seat_num then
            local _ii = (index - 1) % 10 + 1
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing_".. FishingModel.data.game_id .. "_" .. _ii}, "CheckCondition")
            if a and not b then
                return
            end
        end

        self.isChangeGunLevelFinish = false
        self.userdata.index = index
        self:RefreshGun()
        self:SetUpGunLevel()
        self:RefreshJG(true)
        if self.userdata and self.userdata.base and my_seat_num == self.userdata.base.seat_num then
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
    local my_seat_num = FishingModel.GetPlayerSeat()
    local index = FishingModel.GetChangeRate(self.userdata.index, -1)
    if index then
        if self.userdata and self.userdata.base and FishingModel.GetPlayerSeat() == self.userdata.base.seat_num then
            local _ii = (index - 1) % 10 + 1
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing_".. FishingModel.data.game_id .. "_" .. _ii}, "CheckCondition")
            if a and not b then
                return
            end
        end

        self.isChangeGunLevelFinish = false
        self.userdata.index = index
        self:RefreshGun()
        self:SetDownGunLevel()
        self:RefreshJG(true)
        if self.userdata and self.userdata.base and my_seat_num == self.userdata.base.seat_num then
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jianbei.audio_name)
        end
    end
end

function C:SetGunLevel(target_index)
    if not self.userdata or not self.userdata.index then
        self.userdata = self:GetUser()
    end
    if not self.userdata or not self.userdata.index or not self.userdata.base then
        return
    end
    dump(self.userdata, "<color=yellow>self.userdata>>>>>>></color>")
    local offsect = target_index - self.userdata.index
    local index = FishingModel.GetChangeRate(self.userdata.index, offsect)

    if index then
        self.userdata.index = index
        self:RefreshGun()
        self:SetDownGunLevel()
        self:RefreshJG(true)
        if self.userdata and self.userdata.base and my_seat_num == self.userdata.base.seat_num then
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_jianbei.audio_name)
        end
    end
end

function C:OnFSZTClick()
    Event.Brocast("ui_oper_fashe_msg", {seat_num = 1})
end

-- 手动开枪
function C:ManualShoot(vec)
    if self.userdata.is_lock_gun then
        self.gun:RotateToPos(vec)
        return
    end
    if self.PCNode.gameObject.activeSelf then
        self:ShowSubsidyPop()
    end

    if self.userdata and self.userdata.base and self.userdata.lock_state ~= "inuse" and self.userdata.use_laser_state == "nor" then
	   self.gun:ManualShoot(vec)
    end
end

-- 强制开枪
function C:ForceShoot(parm)
    if self.userdata and self.userdata.base then
       self.gun:ForceShoot(parm)
    end
end

-- 执行开枪
function C:RunShoot(data)
    if not FishingModel.IsRecoverRet then
    	-- 首次开抢后移除提示效果
    end

    self.GunAnim.transform.rotation = Quaternion.Euler(0, 0, data.angle)
    Event.Brocast("activity_fish_gun_rotation",{angle = data.angle,seat_num = self.seat_num})
    BulletManager.CreateBullet(data)

    self.shootAnim:Play("open_gun_anim", -1, 0)

    local my_seat_num = FishingModel.GetPlayerSeat()
    if self.userdata and self.userdata.base and my_seat_num == self.userdata.base.seat_num then
        local isAct = FishingActivityManager.CheckIsActivityTime(self.userdata.base.seat_num)
        if isAct then
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zidan2.audio_name)
        else
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zidan.audio_name)
        end
    end

    if data.type and data.type == 5 then
        ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zuantoudan3.audio_name)
    end

    local pos = FishingModel.Get2DToUIPoint(self.GunOpen.transform.position)
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

function C:RotateTo(r)
    self.gun:RotateTo(r)
end

function C:GetCurGunLevel()
    return self.userdata.index
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
    if change_type and (change_type == "fishing_task_chou_jiang" or change_type == "fishing_model_msg") then
        return
    end
    if self.userdata and self.userdata.base and self.userdata.base.seat_num == FishingModel.data.seat_num then
        local gameCfg = GameFreeModel.GetFishGameConfig(FishingModel.data.game_id)
        --gameCfg.index = 2
        
        --dump(gameCfg, "<color=yellow>--->>>ShowSubsidyPop:</color>")
        if gameCfg.index == 4 then
            if self.userdata.isPC then
                local pc_num =  UnityEngine.PlayerPrefs.GetString(MainModel.UserInfo.user_id .. "_pc_num",0)
                if tonumber(pc_num) <= 1 then
                    --每日首次破产
                    OneYuanGift.ChekcBroke()
                else
                    OneYuanGift.Create(nil, function()
                        PayPanel.Create(GOODS_TYPE.jing_bi)
                    end)
                end
            end
        else
            Event.Brocast("ui_game_pc_msg", {tag="by", idx=gameCfg.index, is_pc = self.userdata.isPC})
        end
        self.userdata.is_auto = false
        Event.Brocast("ui_auto_change")
    end
end
function C:GetGunZ()
    local z = self.GunAnim.transform.localEulerAngles.z + 90
    return z
end
function C:GetGunTran()
    return self.GunAnim.transform
end

--获取推荐倍数
--满足VIP的条件下，以当前金币为准，如果 金币/1000 <= 100，则 推荐100倍, 如果计算结果≥200且＜300 ,则推荐200炮倍
function C:GetBestRate()
    local vip_limit_max_rate = 10
    local index = 1
    if self.userdata and self.userdata.base and self.userdata.base.seat_num == FishingModel.data.seat_num and FishingModel.data.game_id <=3 then
        for i = 10,1,-1 do
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="fishing_".. FishingModel.data.game_id .. "_" .. i,is_on_hint = true}, "CheckCondition")
            if a and not b then
                
            else
                vip_limit_max_rate = i
                break
            end
        end
        for i = vip_limit_max_rate,1,-1 do
            local gun_config = FishingModel.GetGunCfg(i + (FishingModel.data.game_id) * 10)
            if MainModel.UserInfo.jing_bi/1000 >= gun_config.gun_rate then
                index = i
                break
            end
        end
        self.isChangeGunLevelFinish = false
        -- 在 fish_gun_config 中，1-10是体延场，11-20-低场，21-30 -中场，31-40高场
        self.userdata.index = index + (FishingModel.data.game_id) * 10
        --dump(self.userdata.index,"<color=red>PPPPPPPPPPPPPPPPPPPPPPPPPPP</color>")
        self:RefreshGun()
        self:SetUpGunLevel()
        self:RefreshJG(true)
    end
end

function C:fishing_ready_finish()
    self:GetBestRate()
end