-- 创建时间:2019-03-26
-- 玩家操作面板

local basefunc = require "Game.Common.basefunc"

FishingOperPrefab = basefunc.class()

local C = FishingOperPrefab

C.name = "FishingOperPrefab"

function C.Create(tran, panelSelf)
	return C.New(tran, panelSelf)
end
function C:FrameUpdate()
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ui_auto_change"] = basefunc.handler(self, self.on_ui_auto_change)
    self.lister["ui_laser_state_change"] = basefunc.handler(self, self.ui_laser_state_change)
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

    self.back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)
    self.set_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
    end)
    self.open_oper_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnOpenOperClick()
    end)
    self.help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnWikeClick()
    end)
    self.shop_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        PayPanel.Create(GOODS_TYPE.jing_bi)
    end)
    self.auto_no_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAutoClick(false)
    end)
    self.auto_yes_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnAutoClick(true)
    end)
    self.task_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        LittleTips.Create("任务")
    end)
    self.bag_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        FishingBagPanel.Create({game_type = FishingBagPanel.TYPE_ENUM.free_3d})
    end)
    self.jg_skill_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnJGClick()
    end)
    self.TopButtonImage = self.transform:Find("OperRight/@oper_rect/TopButtonImage"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButtonImage.gameObject).onClick = basefunc.handler(self, self.SetHideMenu)

    self:MyRefresh() 
end
function C:MyRefresh()
	self:SetOpenOper(false)
    self.auto_yes_btn.gameObject:SetActive(true)
    self.auto_no_btn.gameObject:SetActive(false)
    self:RefreshJG()
end

function C:MyExit()
	self:RemoveListener()
end
function C:SetHideMenu()
    self:SetOpenOper(false)
end
function C:SetOpenOper(b)
    self.oper_rect.gameObject:SetActive(b)
    self.open_oper_jt1.gameObject:SetActive(b)
    self.open_oper_jt2.gameObject:SetActive(not b)
end
function C:OnOpenOperClick()
    local b = not self.oper_rect.gameObject.activeSelf
    self:SetOpenOper(b)
end

function C:OnBackClick()
    if _G["FishingXRHBManager"] then
        local tash_data = FishingXRHBManager.GetTaskDataByGameID(FishingModel.data.game_id)
        local cfg = FishingXRHBManager.GetCfgByGameID(FishingModel.data.game_id)
        dump(tash_data, "<color=red>当前处于捕鱼新人福卡中，完成即可领取福卡</color>")
        if FishingXRHBManager.is_show(tash_data) then
            local desc = ""
            if tash_data.now_process >= tash_data.need_process then
                desc = "当前处于捕鱼新人福卡中，完成即可领取福卡\n确定要退出吗？"
            else
                local userdata = FishingModel.GetPlayerData()
                local gun_config = FishingModel.GetGunCfg(userdata.index)
                local g_num = math.ceil( (tash_data.need_process - tash_data.now_process) / gun_config.gun_rate )
                desc = "当前炮倍再发射<color=#F18611FF>" .. StringHelper.ToCash(g_num) .. "发</color>即可领取\n<color=#F18611FF>" .. cfg.red_val .. "福卡</color>\n确定要退出吗？"
            end
            local pre = HintPanel.Create(5, desc, function ()
                FishingLogic.quit_game()
            end)
            pre:SetButtonText("继续退出", "继续领福卡")
            return
        end
    end
    FishingLogic.quit_game()
end

function C:OnWikeClick()
    Fishing3DBKPanel.Create()
end

function C:OnAutoClick(is_auto)
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    if is_auto then
        userdata.is_auto = true
        userdata.auto_index = 1
    else
        userdata.is_auto = false
        userdata.auto_index = 1
    end
    self:on_ui_auto_change()
end
function C:OnAutoScaleClick()
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    userdata.auto_index = userdata.auto_index + 1
    if userdata.auto_index > #FishingModel.Defines.auto_bullet_speed then
        userdata.auto_index = 1
    end
    local v = FishingModel.Defines.auto_bullet_speed[userdata.auto_index]
    self.AutoScaleText.text = "x" .. v

    self:SetAutoCoefficient(v)
end

function C:SetAutoCoefficient(v)
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    self.panelSelf.PlayerClass[uipos]:SetAutoCoefficient(v)
end

function C:on_ui_auto_change()
    local userdata = FishingModel.GetPlayerData()
    local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
    if userdata.is_auto then
        self.auto_yes_btn.gameObject:SetActive(false)
        self.auto_no_btn.gameObject:SetActive(true)

        self.panelSelf.PlayerClass[uipos]:SetAuto(true)
    else
        self.auto_yes_btn.gameObject:SetActive(true)
        self.auto_no_btn.gameObject:SetActive(false)

        self.panelSelf.PlayerClass[uipos]:SetAuto(false)
    end
end

function C:GetSkillNode()
    if self.oper_rect.gameObject.activeSelf then
        return self.bag_btn.transform.position
    else
        return self.open_oper_btn.transform.position
    end
end

function C:close_jg_sound()
    if self.jg_xl_audio then
        soundMgr:CloseLoopSound(self.jg_xl_audio)
        self.jg_xl_audio = nil
    end
end
function C:SetLaserHide()
    self:close_jg_sound()
    self:CloseJGXL()
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
    local jgdata = self:GetJGData()
    if jgdata.num > 0 then
        if FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "nor" then
            FishingModel.SetPlayerLaserState(FishingModel.GetPlayerSeat(), "ready")
            self.jg_fx_yan.gameObject:SetActive(true)
            self:close_jg_sound()
            self.jg_xl_audio = ExtendSoundManager.PlaySound(audio_config.by3d.bgm_by_jiguang1.audio_name, -1)
            self:CloseJGXL()
            self:CreateJGXL()
        elseif FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "ready" then
            FishingModel.SetPlayerLaserState(FishingModel.GetPlayerSeat(), "nor")
            self.jg_fx_yan.gameObject:SetActive(false)
            self:close_jg_sound()
            self:CloseJGXL()
        end
    else
        LittleTips.Create("激光要蓄满才能使用哦！")
    end
end
function C:GetJGData()
    local userdata = FishingModel.GetPlayerData()
    if userdata then
        local bullet_cfg = FishingModel.GetGunCfg(userdata.index)
        local cur = userdata.laser_rate or 0
        local max = bullet_cfg.laser_max_rate
        local val = cur / max
        local nn = math.floor(val)
        if val > 1 then
            val = 1
        end
        return {jd=val, num=nn}
    end
    return {jd=0, num=0}
end
function C:RefreshJG()
    local jgdata = self:GetJGData()
    self.jg_num_txt.text = jgdata.num
    self.jg_rate_img.fillAmount = jgdata.jd

    self.jg_fx_yan.gameObject:SetActive(false)

    if jgdata.num > 0 and FishingModel.GetPlayerLaserState(FishingModel.GetPlayerSeat()) == "ready" then
        self.jg_fx_yan.gameObject:SetActive(true)
    end
end
function C:ui_laser_state_change(seat_num)
    if seat_num == FishingModel.GetPlayerSeat() then
        if FishingModel.GetPlayerLaserState(seat_num) == "inuse" then
            return
        end
        self:CloseJGXL()
        self:RefreshJG()
    end
end
