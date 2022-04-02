-- 创建时间:2019-03-06
-- Panel:FishingMatchGamePanel
local basefunc = require "Game/Common/basefunc"

FishingMatchGamePanel = basefunc.class()
-- 别名
FishingGamePanel = FishingMatchGamePanel
local C = FishingMatchGamePanel
C.name = "FishingMatchGamePanel"

local is_run_game_panel = false
local instance
local m_pram
function C.Create(pram)
    m_pram = pram
    if not instance then
        DSM.PushAct({panel = C.name})
		instance = C.New(pram)
		instance = createPanel(instance, C.name)
	else
		instance:MyRefresh()
	end
	return instance
end
function C.Bind()
    local _in = instance
    instance = nil
    return _in
end

function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_shoot"] = basefunc.handler(self, self.Shoot)
    self.lister["model_player_PC"] = basefunc.handler(self, self.on_model_player_PC)
    self.lister["model_bullet_boom"] = basefunc.handler(self, self.on_model_bullet_boom)

    self.lister["model_player_money_msg"] = basefunc.handler(self, self.on_model_player_money_msg)

    self.lister["model_ready_finish_msg"] = basefunc.handler(self, self.ReadyFinish)
    self.lister["model_fish_wave"] = basefunc.handler(self, self.FishWaveEvent)
    self.lister["model_box_fish"] = basefunc.handler(self, self.onBoxFishEvent)

    self.lister["model_fish_dead"] = basefunc.handler(self, self.on_model_fish_dead)
    self.lister["model_fish_dead_laser"] = basefunc.handler(self, self.on_model_fish_dead_laser)
    self.lister["model_fish_dead_missile"] = basefunc.handler(self, self.on_model_fish_dead_missile)
    self.lister["model_fsmg_get_one_event"] = basefunc.handler(self, self.on_model_fsmg_get_one_event)
    self.lister["model_fsmg_match_revive_msg"] = basefunc.handler(self, self.on_model_fsmg_match_revive_msg)
    self.lister["model_fsmg_match_finish_revive_msg"] = basefunc.handler(self, self.on_model_fsmg_match_finish_revive_msg)
    self.lister["model_fsmg_gameover_msg"] = basefunc.handler(self, self.on_model_fsmg_gameover_msg)

    self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)

    self.lister["model_fish_laser_rate_change"] = basefunc.handler(self, self.on_model_fish_laser_rate_change)
    self.lister["model_fish_missile_rate_change"] = basefunc.handler(self, self.on_model_fish_missile_rate_change)
    self.lister["model_barbette_info_change_msg"] = basefunc.handler(self, self.on_model_barbette_info_change_msg)

    self.lister["ai_manual_shoot"] = basefunc.handler(self, self.ManualShoot)
    self.lister["ai_freed_skill"] = basefunc.handler(self, self.FreeSkill)
    self.lister["ai_change_gun_level"] = basefunc.handler(self, self.ChangeGunLevel)

    self.lister["activity_set_gun_level"] = basefunc.handler(self, self.SetGunLevel)
    self.lister["activity_over_msg"] = basefunc.handler(self, self.on_activity_over_msg)

    self.lister["ui_gold_fly_finish_msg"] = basefunc.handler(self, self.on_ui_gold_fly_finish_msg)
    self.lister["ui_play_laser_finish_msg"] = basefunc.handler(self, self.on_ui_play_laser_finish_msg)
    self.lister["ui_play_missile_finish_msg"] = basefunc.handler(self, self.on_ui_play_missile_finish_msg)
    self.lister["ui_missile_fly_finish_msg"] = basefunc.handler(self, self.on_ui_missile_fly_finish_msg)
    self.lister["ui_lock_fly_finish_msg"] = basefunc.handler(self, self.on_ui_lock_fly_finish_msg)
    self.lister["ui_ice_fly_finish_msg"] = basefunc.handler(self, self.on_ui_ice_fly_finish_msg)
    self.lister["ui_zongzi_fly_finish_msg"] = basefunc.handler(self, self.on_ui_zongzi_fly_finish_msg)
    self.lister["ui_grades_fly_finish_msg"] = basefunc.handler(self, self.on_ui_grades_fly_finish_msg)

    self.lister["ui_shake_screen_msg"] = basefunc.handler(self, self.on_ui_shake_screen_msg)

    self.lister["UpdateFishingBagRedHint"] = basefunc.handler(self, self.UpdateFishingBagRedHint)

    self.lister["model_gunup_msg"] = basefunc.handler(self, self.on_model_gunup_msg)
    self.lister["ui_gunup_fx_finish"] = basefunc.handler(self, self.on_ui_gunup_fx_finish)
    self.lister["ui_refresh_player_money"] = basefunc.handler(self, self.on_ui_refresh_player_money)
    self.lister["ui_bullet_scale_s2c"] = basefunc.handler(self, self.on_bullet_scale_s2c)
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
    self:MyExit()
    PopUpFMRevive.Close()
    destroy(self.gameObject)
    destroy(self.Fishing2DUI_Obj)
    FishingActivityManager.Exit()
    Event.Brocast("exit_bullet_broadcast")
end
function C:MyExit()
    if is_run_game_panel then
        DSM.PopAct()
        FishDeadManager.MyExit()
        FishingMatchModel.StopUpdateFrame()
        is_run_game_panel = false

        if self.update_time then
            self.update_time:Stop()
        end
        for i=1, FishingMatchModel.maxPlayerNumber do
            self.PlayerClass[i]:MyExit()
        end
        if self.quit_hint then
            self.quit_hint:Close()
            self.quit_hint = nil
        end
        self.update_time = nil
        FishManager.Exit()
        FishExtManager.Exit()
        VehicleManager.Exit()
        BulletManager.Exit()
        SettingPanel.Hide()
        FishingBKPanel.Close()
        
        FishingBagPanel.Close()
        PayPanel.Close()
        GameBroadcastBulletPanel.Close()

        self.nor_skill_prefab:MyExit()
        self.oper_prefab:MyExit()
        self.ext_prefab:MyExit()
        self:RemoveListener()
    end
end

local isPointDownOnUI = false
local isSkillReady = false
function C:Update()
    if is_run_game_panel and not FishingMatchModel.IsRecoverRet then
    	-- 检测是否放在UI上
        local worldpos_up
        local seatno = FishingMatchModel.GetPlayerSeat()
        if gameRuntimePlatform == "WindowsEditor" or gameRuntimePlatform == "" then
            if UnityEngine.Input.GetMouseButtonDown(0) then
                if FishingMatchModel.GetPlayerLaserState(seatno) == "ready" or
                FishingMatchModel.GetPlayerMissileState(seatno) == "ready" then
                    isSkillReady = true
                else
                    isSkillReady = false
                end
            end
            if EventSystem.current:IsPointerOverGameObject() and UnityEngine.Input.GetMouseButtonDown(0) then
                isPointDownOnUI = true
                return
            end
            if UnityEngine.Input.GetMouseButtonUp(0) then
                worldpos_up = UnityEngine.Input.mousePosition
                if isPointDownOnUI then
                    isSkillReady = false
                end
            end

            if isPointDownOnUI and UnityEngine.Input.GetMouseButtonUp(0) then
                isPointDownOnUI = false
            end
        else
            if UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Began then
                if FishingMatchModel.GetPlayerLaserState(seatno) == "ready" or
                FishingMatchModel.GetPlayerMissileState(seatno) == "ready" then
                    isSkillReady = true
                else
                    isSkillReady = false
                end
            end
            if UnityEngine.Input.touchCount > 0 and EventSystem.current:IsPointerOverGameObject(UnityEngine.Input.GetTouch(0).fingerId) and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Began then
                isPointDownOnUI = true
                return
            end

            if UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Ended then
                worldpos_up = Vector3.New(UnityEngine.Input.GetTouch(0).position.x, UnityEngine.Input.GetTouch(0).position.y, 0)
                if isPointDownOnUI then
                    isSkillReady = false
                end
            end
            if isPointDownOnUI and UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Ended then
                isPointDownOnUI = false
            end
        end

        if isPointDownOnUI then
            return
        end

        local worldpos
        if UnityEngine.Input.GetMouseButton(0) then
            worldpos = UnityEngine.Input.mousePosition
        end

        if UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Moved then
            worldpos = Vector3.New(UnityEngine.Input.GetTouch(0).position.x, UnityEngine.Input.GetTouch(0).position.y, 0)
        end

        if isSkillReady and FishingMatchModel.GetPlayerLaserState(seatno) == "ready" and worldpos_up then
            isSkillReady = false
            worldpos_up = self.camera2d:ScreenToWorldPoint(worldpos_up)
            self:LaserShoot({vec=worldpos_up, seatno=seatno})
        elseif isSkillReady and FishingMatchModel.GetPlayerMissileState(seatno) == "ready" and worldpos_up then
            isSkillReady = false
            worldpos_up = self.camera2d:ScreenToWorldPoint(worldpos_up)
            self:MissileShoot({vec=worldpos_up, seatno=seatno})
        else
            if worldpos then
                worldpos = self.camera2d:ScreenToWorldPoint(worldpos)

                local user = FishingMatchModel.GetPlayerData()
                if user and user.base and user.lock_state == "inuse" then

                    -- 射线检测鱼
                    local hit = UnityEngine.Physics2D.Raycast(Vector2(worldpos.x, worldpos.y), Vector2.zero, 1000)

                    if hit.collider ~= nil then
                        local fish = FishManager.GetFishByID(tonumber(hit.collider.gameObject.name))
                        if fish then
                            if not fish.data.seat_num or fish.data.seat_num == FishingMatchModel.data.seat_num then
                                FishingMatchModel.SetLockFishID(FishingMatchModel.data.seat_num, fish.data.fish_id)
                            else
                                LittleTips.Create("这条鱼不属于你@_@")
                            end
                        end
                    end
                else
                    self:ManualShoot({vec=worldpos, seatno=seatno})
                end
            end        
        end
    end
end
function C:on_ui_shake_screen_msg()
    local t = 1
    local o_pos = self.by_bg.transform.localPosition
    local seq = DoTweenSequence.Create()
    seq:Append(self.by_bg.transform:DOShakePosition(t, Vector3.New(0.30, 0.30, 0), 20))
    seq:OnForceKill(function ()
        if IsEquals(self.by_bg) then
            self.by_bg.transform.localPosition = o_pos
        end
    end)
end

function C:UpdateFishingBagRedHint()
    local tt1 = PlayerPrefs.GetString(MainModel.RecentlyOpenBagTimeFishing, "0")
    local tt2 = PlayerPrefs.GetString(MainModel.RecentlyGetNewItemTimeFishing, "0")
    if tonumber(tt1) < tonumber(tt2) then
        --有新东西
        print("<color=green>捕鱼背包有新物品</color>")
        self.bag_btn_ani.enabled = true
    else
        print("<color=green>捕鱼背包没有新物品</color>")
        self.bag_btn_ani.enabled = false
    end
end

function C:Awake()
	local tran = self.transform
	self.gameObject = self.transform.gameObject

	self:MakeLister()
	self:AddMsgListener()
	-- 创建2DUI
	local ui2d = newObject("FishingMatch2DUI")
	self.Fishing2DUI_Obj = ui2d
	self.Fishing2DUI_Tran = ui2d.transform
	local tran_2D = ui2d.transform
	self.fish_node_tran = self.Fishing2DUI_Tran:Find("FishNodeTran").transform
    self.fish_group_node_tran = self.Fishing2DUI_Tran:Find("FishGroupNodeTran").transform
    self.bullet_node_tran = self.Fishing2DUI_Tran:Find("BulletNodeTran").transform
	self.bullet_node_list = {}
    for i = 1, 4 do
        self.bullet_node_list[#self.bullet_node_list + 1] = self.Fishing2DUI_Tran:Find("BulletNodeTran/Node" .. i).transform
    end

	FishManager.Init(self.fish_node_tran, self.fish_group_node_tran)
    FishExtManager.Init()
	BulletManager.Init(self.bullet_node_list)
	self.camera2d = self.Fishing2DUI_Tran:Find("CatchFish2DCamera"):GetComponent("Camera")
    
    self.FXNode_GJ = GameObject.Find("Canvas/LayerLv2").transform

	self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera")
    FishingMatchModel.SetCamera(self.camera2d, self.camera)

    self.LayerLv2 = GameObject.Find("Canvas/LayerLv2").transform

	self.isDown = false

    self.by_bg = self.Fishing2DUI_Tran:Find("by_bg"):GetComponent("SpriteRenderer")
    self.Bingdong = self.Fishing2DUI_Tran:Find("Bingdong"):GetComponent("SpriteRenderer")
    self.PlayerUI = {}
    self.PlayerUI2D = {}
    self.PlayerClass = {}
    for i=1, FishingMatchModel.maxPlayerNumber do
    	self.PlayerUI[i] = tran:Find("UINode/Player"..i)
    	self.PlayerUI2D[i] = tran_2D:Find("Player"..i)
    end

    self.DebugText = tran:Find("UINode/DebugText"):GetComponent("Text")
    self.DebugText.gameObject:SetActive(false)
    
    self.FXNode = tran:Find("FXNode")
    self.FishNetNode = tran:Find("UINode/FishNetNode")
    self.SkillNode = tran:Find("UINode/SkillNode")
    self.FlyGoldNode = tran:Find("UINode/FlyGoldNode")
    self.OperNode = tran:Find("UINode/OperNode")
    self.ActFXNode = tran:Find("UINode/ActFXNode")
    self.ExtRect = tran:Find("UINode/ExtRect")

    self.LockHintImage = tran:Find("FXNode/LockHintImage")
    self.DotLine = tran:Find("FXNode/LockHintImage/DotLine")
    self.DotLineLayout = tran:Find("FXNode/LockHintImage/DotLine/DotLine"):GetComponent("HorizontalLayoutGroup")
    self.LockHintAnim = tran:Find("FXNode/LockHintImage/suoding"):GetComponent("Animator")

    -- 集粽子得礼
    self.ZZNode = tran:Find("UINode/ZZNode")
    self.ZZButton = tran:Find("UINode/ZZNode/ZZButton"):GetComponent("Button")
    self.ZZHint = tran:Find("UINode/ZZNode/ZZButton/ZZHint")
    self.ZZAddMoneyNode = tran:Find("UINode/ZZNode/ZZAddMoneyNode")
    self.ZZButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnZZClick()
    end)
    self.ZZNode.gameObject:SetActive(false)
    
    for i=1, FishingMatchModel.maxPlayerNumber do
        if i == 1 then
            self.PlayerClass[i] = FishingPlayer.Create(self, i, self.PlayerUI[i], self.PlayerUI2D[i])
        else
            self.PlayerClass[i] = FishingPlayerAss.Create(self, i, self.PlayerUI[i], self.PlayerUI2D[i])
        end
    end

    local width = Screen.width
    local height = Screen.height
    if width / height < 1 then
        width,height = height,width
    end
    local matchWidthOrHeight = MainModel.GetScene_MatchWidthOrHeight(width, height)
    if matchWidthOrHeight == 0 then
        self.by_bg.transform.localScale = Vector3.New(1, 1, 1)
    else
        self.by_bg.transform.localScale = Vector3.New(1.25, 1.25, 1)
    end

    self.update_time = Timer.New(function (_, time_elapsed)
        self:FrameUpdate(time_elapsed)
    end, FishingMatchModel.Defines.FrameTime, -1,false,true)

    FishDeadManager.Init(self)
    FishingSkillManager.SetPanelSelf(self)
    FishingMatchBuffManager.SetPanelSelf(self)
    self.nor_skill_prefab = FishingNorSKillPrefab.Create(self.SkillNode, self)
    self.oper_prefab = FishingOperPrefab.Create(self.OperNode, self)
    self.ext_prefab = FishingMatchExtPrefab.Create(self.ExtRect, self)

    FishingLoadingPanel.Create(function( )
        Event.Brocast("fishing_guide_step")
        Event.Brocast("fishing_activity_begin")
    end)
    self:InitUI()
    is_run_game_panel = true

    if FishingMatchModel.Config.fish_debug_map and
        FishingMatchModel.Config.fish_debug_map.is_bullet_node_onoff and
        FishingMatchModel.Config.fish_debug_map.is_bullet_node_onoff == 1 then
        self.bullet_node_tran.gameObject:SetActive(false)
    end
    if FishingMatchModel.Config.fish_debug_map and
        FishingMatchModel.Config.fish_debug_map.is_fish_node_onoff and
        FishingMatchModel.Config.fish_debug_map.is_fish_node_onoff == 1 then
        self.fish_node_tran.gameObject:SetActive(false)
    end
    self.isHintYB = true

    self.bag_btn = tran:Find("UINode/OperNode/@bag_btn"):GetComponent("Button")
    self.bag_btn_ani = self.bag_btn.transform:Find("beibao"):GetComponent("Animator")
    self.bag_btn.onClick:AddListener(function(  )
        FishingBagPanel.Create({game_type = FishingBagPanel.TYPE_ENUM.match})
    end)
    self:UpdateFishingBagRedHint()
end
function C:Start()
    -- 初始化一些特殊路径
    -- 贝壳路径
    print("<color=red>初始化一些特殊路径</color>")
    FishingModel.ts_steer_map = {}
    local path_id = 10001
    for i = 1, FishingModel.maxPlayerNumber do
        for j = 1, 4 do
            local steer = {}
            local pathnode = self.PlayerClass[i].transform_2D:Find("TSPath/TSPath" .. j)
            steer.posX = pathnode.position.x
            steer.posY = pathnode.position.y
            steer.headX = 0
            steer.headY = 1
            steer.id = path_id
            steer.steer = {}
            local stelist = {}
            steer.steer[#steer.steer + 1] = stelist
            stelist[1] = {}
            stelist[1].id = 3
            stelist[1].line = 3
            stelist[1].type = 3
            stelist[1].waitTime = 300

            -- 增加路径一条
            FishingModel.ts_steer_map[path_id] = steer
            path_id = path_id + 1
        end
    end
end
function C:InitUI()
    self:TestAddJoinAI(  )
end

-- 重置
function C:ResetUI()
    if self.update_time then
        self.update_time:Stop()
    end
    if self.flee_time then
        self.flee_time:Stop()
    end
end
function C:MyRefresh()
    self:RefreshIce()
    self:RefreshPlayer()
    self:RefreshZZ()
    self.nor_skill_prefab:MyRefresh()
    self.oper_prefab:MyRefresh()
    self.ext_prefab:MyRefresh()
end

function C:PrintDebug()
end

-- 断线重连完成
function C:ReadyFinish()
    self:MyRefresh()
    if m_pram then
        if m_pram.open_bag then
            FishingBagPanel.Create({game_type =FishingBagPanel.TYPE_ENUM.match})
        end
    end
    if self.quit_hint then
        self.quit_hint:Close()
        self.quit_hint = nil
    end
    m_pram = nil
    self.update_time:Start()

    Event.Brocast("fishing_activity_begin")
    if FishingMatchModel.data.is_begin_game then
        FishingMatchModel.data.is_begin_game = false
        FishingAnimManager.PlayMatchBeginGame(self.FlyGoldNode)
    end
    self:on_model_fsmg_match_revive_msg()
end

function C:on_background_msg()
    if self.update_time then
        self.update_time:Stop()
    end
    self.ext_prefab:on_background_msg()
    PopUpFMRevive.Close()
end
function C:on_backgroundReturn_msg()
    self.ext_prefab:on_backgroundReturn_msg()
end
-- 刷新玩家
function C:RefreshPlayer()
    for i=1, FishingMatchModel.maxPlayerNumber do
        self.PlayerClass[i]:MyRefresh()
    end
end
-- 刷新冰冻
function C:RefreshIce()
    local ice_state = FishingMatchModel.GetSceneIceState()
    if ice_state == "inuse" then
        FishManager.SetIceState(true)
        self.Bingdong.gameObject:SetActive(true)
    else
        FishManager.SetIceState(false)
        self.Bingdong.gameObject:SetActive(false)
    end
end

function C:FrameUpdate(time_elapsed)
    self:PrintDebug()
    -- 防止除0
    if time_elapsed < 0.000001 then
        time_elapsed = 0.000001
    end
    FishingMatchModel.UpdateSkillCD(time_elapsed)

    local ice_state = FishingMatchModel.GetSceneIceState()
    if ice_state == "inuse" then
        local a,b = FishingMatchModel.GetSceneIceTime()
        if a and b then
            self.Bingdong.color = Color.New(1, 1, 1, a/b * 0.7 + 0.3)
        end
    else
        VehicleManager.FrameUpdate(time_elapsed)
    end

    FishManager.FrameUpdate(time_elapsed)
    BulletManager.FrameUpdate(time_elapsed)

    for i=1, FishingMatchModel.maxPlayerNumber do
        self.PlayerClass[i]:FrameUpdate(time_elapsed)
    end
    self.nor_skill_prefab:FrameUpdate(time_elapsed)
    self.oper_prefab:FrameUpdate(time_elapsed)
end
-- 宝箱鱼潮
function C:onBoxFishEvent()
    -- FishingAnimManager.PlayWaveHint(self.FXNode, false, "by_imgf_bxycll")
end

-- 鱼儿逃离 2秒逃离完成
function C:FishWaveEvent()
    if FishingMatchModel.data.fish_map_type == 2 then
        FishingAnimManager.PlayShowAndHideFX(self.FXNode, "luckFishTide_prefab", Vector3.zero, 3)
        FishingAnimManager.PlayShowAndHideFX(self.fish_group_node_tran, "by_hailiang_b", Vector3.zero, 2, true)
    else
        FishingAnimManager.PlayWaveHint(self.FXNode, false, "by_imgf_ycjs")
        FishingAnimManager.PlayShowAndHideFX(self.fish_group_node_tran, "by_hailiang_b", Vector3.zero, 2, true)
    end

    ExtendSoundManager.PlaySound(audio_config.by.bgm_by_yuchao.audio_name)

    VehicleManager.PlayFlee(FishingMatchModel.data.clear_level or 0)
    FishManager.PlayFlee(FishingMatchModel.data.clear_level or 0)
end

-- 发射子弹
function C:ManualShoot(data)
    local m_data = FishingMatchModel.data
    for i = 1, FishingMatchModel.maxPlayerNumber do
        local uipos = FishingMatchModel.GetSeatnoToPos(i)
        self.PlayerClass[uipos]:ManualShoot(data.vec)
    end
end

-- 使用激光技能
function C:LaserShoot(data)
    data.msg_type = "laser"
    Event.Brocast("model_use_skill_msg", data)
end
-- 使用核弹技能
function C:MissileShoot(data)
    data.msg_type = "missile"
    Event.Brocast("model_use_skill_msg", data)
end

function C:FreeSkill(data)
    if data.msg_type == "laser" then
        data.seatno = data.seat_num
        self:LaserShoot(data)
        return
    end
	FishingMatchModel.SendSkill(data)
end

function C:ChangeGunLevel(data)
    if data then
        if data.is_up then
            self.PlayerClass[data.seat_num]:OnUpGunLevel()
        else
            self.PlayerClass[data.seat_num]:OnDownGunLevel()
        end
    end
end

function C:SetGunLevel(data)
    dump(data, "<color=yellow>活动的数据。>>>>>></color>")
    if not data then
        return
    end
    if data.msg_type == FISHING_ACTIVITY_ENUM.quick_shoot then
        if data.seat_num and self.PlayerClass[data.seat_num] then
            local pp = {}
            pp.rate = 2
            pp.num = data.num
            self.PlayerClass[data.seat_num]:SetQuickShoot(pp)
        end
    else
        if data.seat_num and data.bullet_index and self.PlayerClass[data.seat_num] then
            local userdata = FishingMatchModel.GetSeatnoToUser(data.seat_num)
            userdata.gun_info.act_bullet_index = data.bullet_index
            self.PlayerClass[data.seat_num]:SetGunLevel(data.bullet_index)
        end
    end
end
function C:on_activity_over_msg(data)
    dump(data, "<color=yellow>活动结束的数据。>>>>>></color>")
    if not data then
        return
    end
    if data.msg_type == FISHING_ACTIVITY_ENUM.quick_shoot then
        if data.seat_num and self.PlayerClass[data.seat_num] then
            local pp = {}
            pp.rate = 1
            pp.num = 0
            self.PlayerClass[data.seat_num]:SetQuickShoot(pp)
        end
    else
        if data.seat_num and data.bullet_index and self.PlayerClass[data.seat_num] then
            local userdata = FishingMatchModel.GetSeatnoToUser(data.seat_num)
            userdata.gun_info.act_bullet_index = nil
            self.PlayerClass[data.seat_num]:SetGunLevel(userdata.gun_info.bullet_index)
        end
    end    
end


function C:Shoot(data)
    local uipos = FishingMatchModel.GetSeatnoToPos(data.seat_num)

    local pos = self.PlayerClass[uipos]:GetBulletPos()
    local dirVec = {x = data.x, y = data.y}
    local r = Vec2DAngle(dirVec)
    local rr = r - 90
    data.angle = rr
    data.pos = pos

    local userdata = FishingMatchModel.GetSeatnoToUser(data.seat_num)
    if userdata.is_ass then
        self.PlayerClass[uipos]:RunShoot(data)
    else
        local gun_config = FishingMatchModel.GetGunCfg(userdata.gun_info.show_bullet_index, userdata.seat_num)
        -- 只有自己扣分数
        if data.seat_num == FishingMatchModel.data.seat_num and not FishingActivityManager.CheckHaveBullet(data.seat_num) then
            FishingMatchModel.AddMoneyLog(data.seat_num, "开抢=(" .. gun_config.gun_rate .. ")")
            FishingMatchModel.data.score = FishingMatchModel.data.score - gun_config.gun_rate
            FishingMatchModel.data.wait_dec_score = FishingMatchModel.data.wait_dec_score + gun_config.gun_rate
        end
        self.PlayerClass[uipos]:RunShoot(data)
        self.PlayerClass[uipos]:RefreshMoney()
    end
end

-- *******************************
-- model的广播消息
-- *******************************

function C:on_model_player_PC(seat_num)
    local m_data = FishingMatchModel.data
    if m_data.cache_score and m_data.cache_grades and m_data.cache_score ~= m_data.score then
        print("<color=red>222EEE on_model_player_PC   cache_score = " .. m_data.cache_score .. ",m_data.score = " .. m_data.score .. "</color>")
        m_data.score = m_data.cache_score
        local userdata = FishingMatchModel.GetPlayerData()
        if userdata.isPC then
            userdata.isPC = false
        end
        Event.Brocast("ui_refresh_player_money")
    else
        print("<color=red>111EEE on_model_player_PC   cache_score = " .. m_data.cache_score .. ",m_data.score = " .. m_data.score .. "</color>")
        dump(m_data.cache_score, "<color=red>EEE m_data.cache_score </color>")
        dump(m_data.cache_grades, "<color=red>EEE m_data.cache_grades </color>")
        local uipos = FishingMatchModel.GetSeatnoToPos(seat_num)
        self.PlayerClass[uipos]:SetPC()
    end
end

-- 子弹碰撞
function C:on_model_bullet_boom(data)
    local bullet =  BulletManager.GetIDToBullet(data.id)
    if bullet then
        FishingAnimManager.PlayFishNet(self.FishNetNode.transform, data)
        -- 只有自己的子弹碰到鱼才播受击
        if bullet.seat_num == FishingMatchModel.data.seat_num then
            FishManager.PlayFishSuffer(data.fish_list)
        end
    end
end

function C:on_model_player_money_msg(data)
    local uipos = FishingMatchModel.GetSeatnoToPos(data.seat_num)
    if uipos then
    	self.PlayerClass[uipos]:RefreshMoney(data.change_type)
    end
end
-- 金币飞行完成
function C:on_ui_gold_fly_finish_msg(data)
    self.PlayerClass[1]:AddMoneyNumber(data)
end
-- 累计赢金飞行完成
function C:on_ui_grades_fly_finish_msg(data)
    self.PlayerClass[1]:AddGradesNumber(data, true)
end

-- 粽子飞行完成
function C:on_ui_zongzi_fly_finish_msg(seat_num, score)
    local my_seat_num = FishingMatchModel.GetPlayerSeat()
    if my_seat_num == seat_num then
        print("<color=red>获得粽子score = " .. score .. "</color>")
        self:RefreshZZ()
        FishingAnimManager.PlayAddZongzi(seat_num, score, self.ZZAddMoneyNode, Vector3.zero)
    end
end

-- 激光播放完成
function C:on_ui_play_laser_finish_msg(seat_num)
    FishingMatchModel.SetPlayerLaserState(seat_num, "nor")
    Event.Brocast("ui_laser_state_change", seat_num)
end
-- 核弹播放完成
function C:on_ui_play_missile_finish_msg(seat_num)
    FishingMatchModel.SetPlayerMissileState(seat_num, "nor")
end
-- 核弹碎片飞行完成
function C:on_ui_missile_fly_finish_msg(seat_num, v)
    local my_seat_num = FishingMatchModel.GetPlayerSeat()
    local userdata = FishingMatchModel.GetSeatnoToUser(seat_num)
    if userdata and userdata.base then
        userdata.missile_index = userdata.missile_index + 1
        userdata.missile_list[userdata.missile_index] = v
    end
    if my_seat_num == seat_num then
        self.nor_skill_prefab:UpdateMissileState()
    end
end
-- 锁定道具飞行完成
function C:on_ui_lock_fly_finish_msg(seat_num, v)
    local my_seat_num = FishingMatchModel.GetPlayerSeat()
    local userdata = FishingMatchModel.GetSeatnoToUser(seat_num)
    if userdata and userdata.base then
        userdata.prop_fish_lock = userdata.prop_fish_lock + v
    end
    if my_seat_num == seat_num then
        self.nor_skill_prefab:RefreshLock()
    end
end
-- 冰冻道具飞行完成
function C:on_ui_ice_fly_finish_msg(seat_num, v)
    local my_seat_num = FishingMatchModel.GetPlayerSeat()
    local userdata = FishingMatchModel.GetSeatnoToUser(seat_num)
    if userdata and userdata.base then
        userdata.prop_fish_frozen = userdata.prop_fish_frozen + v
    end
    if my_seat_num == seat_num then
        self.nor_skill_prefab:RefreshIce()
    end
end

-- 子弹弄死的鱼
function C:on_model_fish_dead(data)
    FishDeadManager.on_model_fish_dead(data)
end
-- 激光弄死的鱼
function C:on_model_fish_dead_laser(data)
    FishDeadManager.on_model_fish_dead_laser(data)
end
-- 核弹弄死的鱼
function C:on_model_fish_dead_missile(data)
    FishDeadManager.on_model_fish_dead_missile(data)
end

-- 获得一个事件
function C:on_model_fsmg_get_one_event(data)
    local parm = {}
    if data.event_type == "create_fish" then
        local fish_id = data.event_data[1]
        if fish_id == 22 or fish_id == 23 or fish_id == 24 then
            parm[#parm + 1] = {isImg=0, value = "<color=#A5EDFFFF>高倍赢金鱼即将出现</color>"}
        elseif fish_id == 26 then
            parm[#parm + 1] = {isImg=0, value = "<color=#7F8944FF>小章鱼即将出现</color>"}
        elseif fish_id == 27 then
            parm[#parm + 1] = {isImg=0, value = "<color=#7F8944FF>幸运宝箱即将出现</color>"}
        else
            local f = FishingMatchModel.Config.fish_map[fish_id]
            if f and f.name then
                parm[#parm + 1] = {isImg=0, value = "<color=#7F8944FF>" .. f.name .. "即将出现</color>"}
            else
                dump(data, "<color=red>获得了一个什么鬼事件</color>")
            end
        end
    elseif data.event_type == "create_skill" then
        if data.trigger_name then
            local desc = string.format("<color=#A5EDFFFF>玩家<color=#FEFE2FFF>%s</color>触发的奖励时刻即将出现</color>", data.trigger_name)
            parm[#parm + 1] = {isImg=0, value = desc}
        else
            dump(data, "<color=red>创建技能没有创建者?</color>")
        end
    elseif data.event_type == "stop_gun" then
        if data.trigger_name then
            local desc = string.format("<color=#A5EDFFFF>玩家<color=#FEFE2FFF>%s</color>将禁止你的副炮捕鱼</color>", data.trigger_name)
            parm[#parm + 1] = {isImg=0, value = desc}
            FishingAnimManager.ProhibitShoot(self.FlyGoldNode)
        else
            dump(data, "<color=red>封禁没有创建者?</color>")
        end
    else
        dump(data, "<color=red>事件没有类型?</color>")
    end

    ExtendSoundManager.PlaySound(audio_config.by.bgm_bymatch_shijian.audio_name)
    
    if next(parm) then
        LittleTips.CreateJoker(parm)
    end
end
-- 激光进度改变
function C:on_model_fish_laser_rate_change(seat_num)
    local uipos = FishingMatchModel.GetSeatnoToPos(seat_num)
    self.PlayerClass[uipos]:RefreshJG(true)
end

-- 核弹进度改变
function C:on_model_fish_missile_rate_change(seat_num)
    local my_seat_num = FishingMatchModel.GetPlayerSeat()
    if my_seat_num == seat_num then
        self.nor_skill_prefab:UpdateMissileState()
    end
end
-- 主炮台升级
function C:on_model_gunup_msg(data, main_index)
    local m_data = FishingMatchModel.data
    local beginPos = self.ext_prefab:GetLockRectPos()
    local endPos = FishingMatchModel.Get2DToUIPoint( self.PlayerClass[1]:GetGunPos() )
    FishingAnimManager.PlayGunUpFX1(self.FlyGoldNode, beginPos, endPos, data, main_index)
end

-- 复活
function C:on_model_fsmg_match_revive_msg()
    local m_data = FishingMatchModel.data
    if m_data.revive_data then
        if m_data.revive_data.count == 0 then
            if self.quit_hint then
                self.quit_hint:Close()
                self.quit_hint = nil
            end
            self.quit_hint = HintFMPanel.Create(1, "复活次数已用完!\n您现在可退出比赛等待排名结果了\n比赛结束后您的排名奖励将通过邮件发送" ,function ()
                self.quit_hint = nil
                FishingMatchLogic.quit_game()
            end, function ()
                self.quit_hint = nil
            end)
            return
        end
        local parm = {}
        if (m_data.revive_data.time - os.time()) > 0 then
            parm.time = m_data.revive_data.time - os.time()
        else
            parm.time = 0
        end
        if (m_data.revive_data.quit_time - os.time()) > 0 then
            parm.quit_time = m_data.revive_data.quit_time - os.time()
        else
            parm.quit_time = 0
        end

        parm.quit_time_table = m_data.revive_data.quit_time
        parm.assets = m_data.revive_data.assets
        parm.num = m_data.revive_data.count
        parm.game_id = m_data.game_id
        parm.score = m_data.revive_data.rank or 0
        PopUpFMRevive.Create(parm)

        local userdata = FishingMatchModel.GetPlayerData()
        userdata.is_auto = false
        userdata.auto_index = 1
        Event.Brocast("ui_auto_change")
    end
end
-- 复活成功
function C:on_model_fsmg_match_finish_revive_msg(data)
    FishingMatchModel.data.revive_data = nil
    FishingMatchModel.data.score = FishingMatchModel.data.score + data.score
    self.PlayerClass[1]:MyRefresh()

    if data.luck == 1 then
        FishingAnimManager.PlayShowAndHideFX(self.FXNode, "luck_prefab", Vector3.zero, 3)
    end
end

function C:on_model_fsmg_gameover_msg(data)
    FishingMatchModel.StopUpdateFrame()
    FishingMatchModel.data.clear_level = 10
    VehicleManager.PlayFlee(FishingMatchModel.data.clear_level or 0)
    FishManager.PlayFlee(FishingMatchModel.data.clear_level or 0)
    self.flee_time = Timer.New(function ()
        VehicleManager.RemoveAllFlee()
        FishManager.RemoveAllFlee()
        if self.update_time then
            self.update_time:Stop()
            self.update_time = nil
        end
    end, 2, 1)
    self.flee_time:Start()
end
function C:on_ui_refresh_player_money()
    self.PlayerClass[1]:RefreshMoney()
end
function C:on_bullet_scale_s2c(seat_num, cha)
    if seat_num == 1 then
        FishingMatchModel.data.score = FishingMatchModel.data.score + cha
        self:on_ui_refresh_player_money()
    end
end
function C:on_ui_gunup_fx_finish(data)
    local beginPos = self.PlayerClass[1]:GetPlayerFXPos()
    Event.Brocast("ui_shake_screen_msg")
    for k,v in ipairs(data) do
        local pos = FishingMatchModel.Get2DToUIPoint( self.PlayerClass[v]:GetGunPos() )
        FishingAnimManager.PlayGunChangeFX(self.FlyGoldNode, pos)
    end

    local m_data = FishingMatchModel.data
    if m_data.buf_barbette_info then
        for k,v in ipairs(m_data.buf_barbette_info) do
            v.lock_time = v.lock_time or 0
            for k1,v1 in pairs(v) do
                m_data.players_info[k].gun_info[k1] = v1
            end
        end
        m_data.buf_barbette_info = nil
        FishingMatchModel.update_barbette_info()
        Event.Brocast("model_barbette_info_change_msg")
    end
    if m_data.buf_gunup_give_money and m_data.buf_gunup_give_money > 0 then
        local pos1 = self.PlayerClass[1]:GetFlyGoldPos()
        FishingAnimManager.PlayGiveMoney(self.FlyGoldNode, beginPos, pos1, m_data.buf_gunup_give_money)
        m_data.buf_gunup_give_money = 0
    else
        print("<color=red>OOO 没有钱>>>>>>>>>>> </color>")
    end
end

-- 枪状态改变
function C:on_model_barbette_info_change_msg(type)
    for i = 1, FishingMatchModel.maxPlayerNumber do
        local uipos = FishingMatchModel.GetSeatnoToPos(i)
        self.PlayerClass[uipos]:MyRefresh(type)
    end
end

--加入机器人
local add_ai_num = 1
function C:TestAddJoinAI(  )
    self.add_ai_btn = self.transform:Find("UINode/@add_ai_btn"):GetComponent("Button")
    self.add_ai_btn.gameObject:SetActive(false)
    self.add_ai_btn.onClick:AddListener(function ()
        -- local v = {}
        -- v.type = 10
        -- v.types = {10,2,2,2,2}
        -- v.time = FishingMatchModel.data.system_time - FishingMatchModel.data.begin_time
        -- v.path = 7
        -- v.rate = 100
        -- v.fish_id = 8883
        -- FishManager.AddFishTeam(v)

        local v = {}
        v.types = {1,1,1,1,1}
        v.ids = {8883,8884,8885,8886,8887}
        v.time = FishingMatchModel.data.system_time - FishingMatchModel.data.begin_time
        v.time = v.time * 10
        v.path = 6
        v.rate = 100
        v.group_id = 1000
        FishManager.AddFishGroup(v)
    end)
end

local ai_running = false
function C:TestStopAI()
    ai_running = not ai_running
end
function C:onAssetChange()
    self:RefreshZZ()
end
-- 刷新粽子入口
function C:RefreshZZ()
end
function C:OnZZClick()
end

function C.GetPlayerInstance(seatno)
    if instance then
        if not seatno then
            seatno = FishingMatchModel.GetPlayerSeat()
        end
        local uipos = FishingMatchModel.GetSeatnoToPos(seatno)
        return instance.PlayerClass[uipos]
    end
end

function C:GetSkillNode()
    return self.nor_skill_prefab.kjbag_pre:GetSkillNode()
end

function C:GetPlayerPos()
    return Vector3.New(0,0,0)
end