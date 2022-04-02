-- 创建时间:2019-03-11
local basefunc = require "Game.Common.basefunc"
FishingActivityZT = basefunc.class()

local M = FishingActivityZT
M.name = "FishingActivityZT"
local Manager = FishingActivityManager

local s_time = 3
local e_time = 3
local min_scale = 0.1

FishingActivityZT.FAZTState = 
{
    FAZTS_Nor = "常态",
    FAZTS_Zh = "最后10秒",
}

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
    self.lister["ui_oper_fashe_msg"] = basefunc.handler(self, self.on_ui_oper_manual_shoot_msg)
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function M:ctor(data,config)
	ExtPanel.ExtMsg(self)

    if not data.msg_type or not data.seat_num then return end
    --检查配置，可能没有，根据具体活动决定
    if not config then return end

    self:MakeLister()
    self:AddMsgListener()

    self.data = data
    self.config = config
    self.ui = {}
    self.ui.parent = GameObject.Find("Canvas/LayerLv5")
    self.ui.gameObject = newObject(M.name,self.ui.parent.transform)
    self.ui.transform = self.ui.gameObject.transform
    self.ui.player = self.ui.transform:Find("UINode/@player" .. self.data.seat_num)
    self.ui.activity_bg = self.ui.transform:Find("UINode/@activity_bg")
    self.ui.global_particle = self.ui.transform:Find("UINode/@global_particle")

	self.gameObject = self.ui.gameObject
    self.transform = self.ui.transform

    LuaHelper.GeneratingVar(self.ui.player.transform, self.ui)
    self.ui.player.gameObject:SetActive(true)
    self:SetParticleByType(self.data.msg_type)
    self.actbk_state = FishingActivityZT.FAZTState.FAZTS_Nor

    self.ui.activity_node.gameObject:SetActive(true)
    self.ui.time_node.gameObject:SetActive(false)

    local userdata = FishingModel.GetSeatnoToUser(self.data.seat_num)
    if userdata then
        userdata.is_lock_gun = true
    end

    local status = M.CheckActivityStatus(self.data)
    if status == FISHING_ACTIVITY_STATUS_ENUM.begin then
        self:InitUI()
    elseif status == FISHING_ACTIVITY_STATUS_ENUM.running then
        self:Refresh(data)
    end
end

function M:Exit(data)
    self.data = data or self.data
    if self.update then
        self.update:Stop()
        self.update = nil
    end
    if self.data then
        local userdata = FishingModel.GetSeatnoToUser(self.data.seat_num)
        if userdata then
            userdata.is_lock_gun = false
        end
    end
    self:RemoveListener()
    self.xh_audio = ExtendSoundManager.CloseSound(self.xh_audio)

    self:RecoverGame()
    self:SetAllGold()
    self.ui.global_particle.gameObject:SetActive(false)
    self.ui.activity_node.gameObject:SetActive(false)
    self:SetActivityBG(false)
    if self.timer_gun then 
        self.timer_gun:Stop() 
        self.timer_gun = nil
    end
    if not self.data then
        self:Back()
        destroy(self.gameObject)
        self.data = nil
        self.config = nil
        self = nil
        return 
    end
    self.timer = Timer.New(function()
        self:Back()
        destroy(self.gameObject)
        if self.timer then
            self.timer:Stop()
        end
        self.data = nil
        self.config = nil
        self = nil
    end,e_time,1)
    self.timer:Start()
end

function M:Back(  )
    if self.ui.act_bullet_obj_p then
        CachePrefabManager.Back(self.ui.act_bullet_obj_p)
    end
    if self.ui.act_all_gold_p then
        CachePrefabManager.Back(self.ui.act_all_gold_p)
    end
    if self.ui.act_ptc_obj_p then
        if not self.ui.act_ptc then 
            local tf = self.ui.activity_node.transform
            self.ui.act_ptc = tf:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
        end
        for i = 0, self.ui.act_ptc.Length - 1 do
            local ptc = self.ui.act_ptc[i]
            if IsEquals(ptc) then
                local l_scl = ptc.transform.localScale
                ptc.transform.localScale = Vector3.New(l_scl.x / min_scale, l_scl.y / min_scale, l_scl.z / min_scale)
            end
        end
        CachePrefabManager.Back(self.ui.act_ptc_obj_p)
    end
    if self.ui.gun_ptc_obj_p then
        CachePrefabManager.Back(self.ui.gun_ptc_obj_p)
    end
end

function M:InitUI()
    self:SetGunParticle()
    self:PlayActivityNode()
    self:ChangeGame()
end

function M:Refresh(data)
    self.data = data
    self:SetGunParticle()
    self:SetGlobalParticle()
    self:CreateActivityBObj()
    self:RefreshButtleTxt()
    self:CreateActivityObj()
    self:SetActivityNode()
    self:SetActivityBG(false)
    self:ChangeGame()

    if self.data.seat_num == FishingModel.GetPlayerSeat() and self.data.status == 1 and self.data.num > 0 then
        self.ui.time_node.gameObject:SetActive(true)
    else
        self.ui.time_node.gameObject:SetActive(false)
    end
    self:StartUpdate()

    if self.data.group_id and self.data.group_id > 0 then
        local bullet = BulletManager.GetIDToBullet(self.data.group_id)
        if bullet and bullet.bulletSpr.UpdateData then
            bullet.bulletSpr:UpdateData({rate = self.data.type, skill_id = self.data.index})
        end
    end
end

function M:SetParticleByType(act_type)
    destroyChildren(self.ui.global_particle)
    destroyChildren(self.ui.activity_bg)
    newObject("activity_mfsk_Zd",self.ui.global_particle)
    newObject("activity_by_bg_mc4",self.ui.activity_bg)
end

function M:StartUpdate()
    local b_time = tonumber(self.data.begin_time)
    local time = tonumber(self.data.time) - 2
    local s_time = tonumber(FishingModel.GetSystemTime())
    local sb_time = tonumber(FishingModel.GetFirstSystemTime())
    if s_time and sb_time and b_time and time then
        self.all_time = time
        self.cur_time = s_time - sb_time - b_time
    end

    self.cur_time = self.cur_time or 0
    self.all_time = self.all_time or 30
    if self.update then
        self.update:Stop()
        self.update = nil
    end
    self.update = Timer.New(function(  )
        self:Update()
    end,1,-1,false,false)
    self.update:Start()
    self:SetTimeText()
end

function M:SetTimeText()
    if self.cur_time < self.all_time then
        local tt = self.all_time - self.cur_time
        self.ui.fs_time_txt.text = tt .. "s"

        if tt <= 5 and self.actbk_state == FishingActivityZT.FAZTState.FAZTS_Nor then
            self.actbk_state = FishingActivityZT.FAZTState.FAZTS_Zh
            print("<color=red>最后5秒钟</color>")
        end
    end
end
function M:Update()
    self.cur_time = self.cur_time + 1
    self:SetTimeText()
    if self.cur_time >= self.all_time then
        -- 时间到 关闭
        if self.update then
            self.update:Stop()
            self.update = nil
        end
        if self.data.num and self.data.num > 0 then
            Event.Brocast("ui_oper_manual_shoot_msg", {seat_num = self.data.seat_num, type = 5})
        end
    end
end
function M:on_ui_oper_manual_shoot_msg(data)
    if data.seat_num == self.data.seat_num then
        Event.Brocast("ui_oper_manual_shoot_msg", {seat_num = data.seat_num, type = 5, vec=data.vec})
        if self.update then
            self.update:Stop()
            self.update = nil
        end
    end
end

function M:RefreshButtleTxt()
    -- self.ui.bullet_txt.text = string.format( "x%s", self.data.num)
    -- if self.data.num > 0 then
    --     self.ui.activity_b_node.gameObject:SetActive(true)
    -- else
    --     self.ui.activity_b_node.gameObject:SetActive(false)
    -- end
end

--[[
    @desc: 改变游戏，退出的时候一定要恢复
    author:{author}
    time:2019-03-29 17:23:30
    @return:
]]
function M:ChangeGame()
    dump(self.data, "<color=red>ChangeGame</color>")
    if not self.data then return end
    local pan = FishingLogic.GetPanel()
    local uipos = FishingModel.GetSeatnoToPos(self.data.seat_num)
    local p_pre = pan.PlayerClass[uipos]
    if self.data.seat_num == FishingModel.GetPlayerSeat() then
        if IsEquals(p_pre.AddButtonImage) then
            p_pre.AddButtonImage.gameObject:SetActive(false)
        end
        if IsEquals(p_pre.SubButtonImage) then
            p_pre.SubButtonImage.gameObject:SetActive(false)
        end
        if self.data.num and self.data.num > 0 then
            if IsEquals(p_pre.FSZT_btn) then
                p_pre.FSZT_btn.gameObject:SetActive(true)
            end
        else
            if IsEquals(p_pre.FSZT_btn) then
                p_pre.FSZT_btn.gameObject:SetActive(false)
            end
        end
    end
    
    if self.data.num and self.data.num > 0 and self.data.status == 1 then
        self.xh_audio = ExtendSoundManager.CloseSound(self.xh_audio)
        if IsEquals(p_pre.FSZT_btn) and self.data.seat_num == FishingModel.GetPlayerSeat() then
            p_pre.FSZT_btn.gameObject:SetActive(true)
        end
        self.xh_audio = ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zuantoudan2.audio_name, -1)
        if IsEquals(p_pre.ZT) then
            p_pre.ZT.gameObject:SetActive(true)
        end
        Event.Brocast("ui_player_change_zt", {seat_num = self.data.seat_num, is_cj_or_sc = true})
    else
        self.xh_audio = ExtendSoundManager.CloseSound(self.xh_audio)
        if IsEquals(p_pre.FSZT_btn) then
            p_pre.FSZT_btn.gameObject:SetActive(false)
        end
        if IsEquals(p_pre.ZT) then
            p_pre.ZT.gameObject:SetActive(false)
        end
        Event.Brocast("ui_player_change_zt", {seat_num = self.data.seat_num, is_cj_or_sc = false})
    end
end
--[[
    @desc: 还原游戏
    author:{author}
    time:2019-03-29 17:45:14
    @return:
]]
function M:RecoverGame()
    if self.data and self.data.seat_num == FishingModel.GetPlayerSeat() then
        local pan = FishingLogic.GetPanel()
        local uipos = FishingModel.GetSeatnoToPos(self.data.seat_num)
        local p_pre = pan.PlayerClass[uipos]

        if IsEquals(p_pre.AddButtonImage) then
            p_pre.AddButtonImage.gameObject:SetActive(true)
        end
        if IsEquals(p_pre.SubButtonImage) then
            p_pre.SubButtonImage.gameObject:SetActive(true)
        end
        if IsEquals(p_pre.FSZT_btn) then
            p_pre.FSZT_btn.gameObject:SetActive(false)
        end
        
        if IsEquals(p_pre.ZT) then
            p_pre.ZT.gameObject:SetActive(false)
        end
        Event.Brocast("ui_player_change_zt", {seat_num = self.data.seat_num, is_cj_or_sc = false})
    end
end

function M:CreateActivityBObj()
    if not self.ui.act_bullet_obj and not IsEquals(self.ui.act_bullet_obj) then
        -- local bullet_img_name = ""
        -- local rate = ""
        -- self.ui.act_bullet_obj_p = CachePrefabManager.Take("activity_bullet3")
        -- bullet_img_name = "bygame_icon_dan_bs08"
        
        -- self.ui.act_bullet_obj_p.prefab:SetParent(self.ui.activity_b_node)
        -- self.ui.act_bullet_obj = self.ui.act_bullet_obj_p.prefab.prefabObj
        -- if IsEquals(self.ui.act_bullet_obj) then
        --     self.ui.act_bullet_obj.transform.localPosition = Vector3.zero
        --     self.ui.act_bullet_obj.transform.localScale = Vector3.one
        -- end
        -- LuaHelper.GeneratingVar(self.ui.activity_b_node.transform,self.ui)
        -- self.ui.bullet_txt.text = self.data.num or 0
        -- self.ui.bullet_img.sprite = GetTexture(bullet_img_name .. rate)
        -- if self.data.seat_num == 3 or self.data.seat_num == 4 then
        --     self.ui.bullet_img.transform.localRotation =Quaternion.Euler(0, 0, 180)
        -- else
        --     self.ui.bullet_img.transform.localRotation =Quaternion.Euler(0, 0, 0)
        -- end
        -- self.ui.activity_b_node.gameObject:SetActive(true)
    end
end

function M:CreateActivityObj()
    -- if not self.ui.act_ptc_obj and not IsEquals(self.ui.act_ptc_obj) then
    --     self.ui.act_ptc_obj_p = CachePrefabManager.Take("Superbullet_mfsk")

    --     self.ui.act_ptc_obj_p.prefab:SetParent(self.ui.activity_node)
    --     self.ui.act_ptc_obj = self.ui.act_ptc_obj_p.prefab.prefabObj
    --     if IsEquals(self.ui.act_ptc_obj) then
    --         self.ui.act_ptc_obj.transform.localPosition = Vector3.zero
    --         self.ui.act_ptc_obj.transform.localScale = Vector3.one    
    --     end
    --     LuaHelper.GeneratingVar(self.ui.activity_node,self.ui)
    -- end
end

function M:ShowOrHiedActivityNode(is_show)
    self.ui.activity_node.gameObject:SetActive(is_show)
end

function M:PlayActivityNode()
    self:SetActivityBG(true)
    self:CreateActivityObj()
    self:ShowOrHiedActivityNode(false)
    local tf = self.ui.activity_node.transform
    self.ui.act_ptc = tf:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
    local o_pos = tf.position
    local ani_kill_callback = function ()
        if not self.data then return end
        -- self.data.status = 1
        local sd = basefunc.deepcopy(self.data)
        sd.status = 1
        FishingModel.SendActivity(sd)
        tf.position = o_pos
        tf.localScale = Vector3.one * min_scale
        self:CreateActivityBObj()
        self:RefreshButtleTxt()
        self:ShowOrHiedActivityNode(false)
        self:SetActivityBG(false)
        self:SetActivityNode()
        self:SetGlobalParticle()
    end

    if not self.data.speed then
        ani_kill_callback()
    else
        local beginPos
        local fish = FishManager.GetFishByID(self.data.speed)
        if fish then
            beginPos = FishingModel.Get2DToUIPoint(fish:GetPos())
        else
            beginPos = Vector3.zero
        end
        local endPos = self.ui.activity_node.position
        local type = FishingSkillManager.FishDeadAppendType.ZT_bullet
        local num = 1

        FishingAnimManager.PlayToolSP(self.ui.transform, self.data.seat_num, beginPos, endPos, type, num, function (v)
            ExtendSoundManager.PlaySound(audio_config.by.bgm_by_zuantoudan1.audio_name)
            ani_kill_callback()
        end)
    end
end

function M:SetActivityNode()
    local tf = self.ui.activity_node.transform
    tf.localScale = Vector3.one * min_scale
    if not self.ui.act_ptc then
        self.ui.act_ptc = tf:GetComponentsInChildren(typeof(UnityEngine.ParticleSystem), true)
    end
    for i = 0, self.ui.act_ptc.Length - 1 do
        local ptc = self.ui.act_ptc[i]
        local l_scl = ptc.transform.localScale
        ptc.transform.localScale = Vector3.New(l_scl.x,l_scl.y,l_scl.z) * min_scale
    end
    self:ShowOrHiedActivityNode(false)
end

function M:SetGlobalParticle()
    if FishingModel.GetPlayerSeat() == self.data.seat_num then
        self.ui.global_particle.gameObject:SetActive(false)
    end
end

function M:SetGunParticle()
    local pp = FishingLogic.GetPanel()
    local gun_pos = pp.PlayerClass[self.data.seat_num]:GetLaserFXPos()
    local pos = FishingModel.Get2DToUIPoint(gun_pos)
    self.ui.gun_node.transform.position = pos
    local offset = 20
    local offset1 = 150
    if self.data.seat_num == 3 or self.data.seat_num == 4 then
        offset = -20
        offset1 = -150
    end
    self.ui.activity_b_node.transform.position = Vector3.New(pos.x,pos.y + offset,pos.z)
    self.ui.activity_node.transform.position = Vector3.New(pos.x,pos.y + offset,pos.z)
    self.ui.time_node.transform.position = Vector3.New(pos.x,pos.y + offset1,pos.z)

    self.ui.gun_node.gameObject:SetActive(true)
end

function M:SetAllGold()
    if M.CheckActivityStatus(self.data) ~= FISHING_ACTIVITY_STATUS_ENUM.over then
        return
    end
    if not self.data.score or self.data.score == 0 then
        return
    end
    if self.data.msg_type == FISHING_ACTIVITY_ENUM.quick_shoot then
        print("忽略...")
        return
    end
    if FishingModel.is3D then
        local pp = FishingLogic.GetPanel()
        local uipos = FishingModel.GetSeatnoToPos(self.data.seat_num)
        local playerPos = pp.PlayerClass[uipos]:GetPlayerFXPos()
        local cfg = FishingModel.Config.fish_map[26]
        local parm = {dead_guang = CFG.dead_guang, reward_image = cfg.reward_image, icon = cfg.icon}
        FishingAnimManager.PlayBY3D_HDY_FX(pp.LayerLv3, playerPos, playerPos, self.data.score, nil, self.data.seat_num, nil, parm)
    else
        if not self.ui.act_all_gold_p and not self.ui.activity_all_gold then
            self.ui.act_all_gold_p = CachePrefabManager.Take("activity_all_gold")
            self.ui.act_all_gold_p.prefab:SetParent(self.ui.all_gold_node.transform)
            self.ui.activity_all_gold = self.ui.act_all_gold_p.prefab.prefabObj
            self.ui.activity_all_gold.transform.localPosition = Vector3.zero
            self.ui.activity_all_gold.transform.localScale = Vector3.one
            LuaHelper.GeneratingVar(self.ui.activity_all_gold.transform,self.ui)
        end
        if self.data.score then
            self.ui.all_gold_txt.text = string.format( "%s",self.data.score)
        end
        self.ui.all_gold_node.gameObject:SetActive(true)
    end
end

function M:SetActivityBG(view)
    if FishingModel.GetPlayerSeat() == self.data.seat_num then
        self.ui.activity_bg.gameObject:SetActive(view)
    else
        self.ui.activity_bg.gameObject:SetActive(false)
    end
end

------------------------------------------外部使用数据
function M:GetDropAwardRate()
    if not self.data then return nil end
    if not self:CheckIsRunning() then return nil end
    return self.data.rate    
end

function M:CheckIsGanChangeGun(  )
    if not self.config then return nil end
    if not self:CheckIsRunning() then return nil end
    return self.config.change_gun
end

function M:GetBulletType(  )
    if not self.config or not self.data then return nil end
    if not self:CheckIsRunning() then return nil end
    if self.data.num <= 0 then return nil end
    return self.config.bullet_type
end

function M:GetFishNetType(  )
    if not self.config or not self.data then return nil end
    if not self:CheckIsRunning() then return nil end
    if self.data.num <= 0 then return nil end
    return self.config.net_type
end

function M:activity_get_gold(data)
    -- dump(data, "<color=green>activity_get_gold</color>")
    if true then return nil end
    if not self:CheckIsRunning() then return nil end
    if data and data.seat_num == self.data.seat_num and data.score then
        self.data.all_score = self.data.all_score or 0
        self.data.all_score = self.data.all_score + data.score
    end
end

function M:activity_kill_fish(data)
    if not self:CheckIsRunning() then return nil end
    -- dump(data, "<color=green>activity_kill_fish</color>")
end

function M:activity_shoot(data)
    if not self:CheckIsRunning() then return nil end
    -- dump(data, "<color=green>activity_shoot</color>")
    if self.data and self.data.num and self.data.num > 0 then
        self.data.num = self.data.num - 1
        self:RefreshButtleTxt()
    end
end

function M:activity_fish_gun_rotation(data)
    -- dump(data, "<color=green>activity_fish_gun_rotation</color>")
    if data.angle and self.ui and self.ui.gun_node then
        self.ui.gun_node.transform.rotation = Quaternion.Euler(0, 0, data.angle)
    end
end

function M.CheckIsActivityTime(data)
    if not data then return false end
    if data and data.num then
        return data.num > 0
    end
    return false
end

function M.CheckActivityStatus(data)
    if not data then return false end
    local function check_time(_data)
        if _data.status == 0 then
            return FISHING_ACTIVITY_STATUS_ENUM.begin
        elseif _data.status == 1 then
            return FISHING_ACTIVITY_STATUS_ENUM.running
        end
        return FISHING_ACTIVITY_STATUS_ENUM.over
    end
    if data and data.status then
        return check_time(data)
    end
    return FISHING_ACTIVITY_STATUS_ENUM.over
end

function M:CheckHaveBullet()
    if self.data then
        if self.data.status == 1 then
            if self.data.num then
                return self.data.num > 0
            end
        end
    end
    return false
end

function M:CheckIsRunning()
    if self.data and self.data.status and self.data.status == 1 then
        return true
    end
    return false
end