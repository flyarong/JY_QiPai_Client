-- 创建时间:2019-03-06
-- Panel:FishingGamePanel
local basefunc = require "Game/Common/basefunc"

FishingGamePanel = basefunc.class()
local C = FishingGamePanel
C.name = "FishingGamePanel"

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

    self.lister["model_fsg_join_msg"] = basefunc.handler(self, self.on_fsg_join_msg)
    self.lister["model_fsg_leave_msg"] = basefunc.handler(self, self.on_fsg_leave_msg)
    self.lister["model_player_money_msg"] = basefunc.handler(self, self.on_model_player_money_msg)

    self.lister["model_ready_finish_msg"] = basefunc.handler(self, self.ReadyFinish)
    self.lister["model_fish_wave"] = basefunc.handler(self, self.FishWaveEvent)
    self.lister["model_box_fish"] = basefunc.handler(self, self.onBoxFishEvent)

    self.lister["model_ice_skill_deblocking_msg"] = basefunc.handler(self, self.on_model_ice_skill_deblocking_msg)

    self.lister["model_time_skill_change_msg"] = basefunc.handler(self, self.on_model_time_skill_change_msg)

    self.lister["model_fish_dead"] = basefunc.handler(self, self.on_model_fish_dead)
    self.lister["model_fish_dead_laser"] = basefunc.handler(self, self.on_model_fish_dead_laser)
    self.lister["model_fish_dead_missile"] = basefunc.handler(self, self.on_model_fish_dead_missile)

    self.lister["AssetChange"] = basefunc.handler(self, self.onAssetChange)

    self.lister["model_fish_laser_rate_change"] = basefunc.handler(self, self.on_model_fish_laser_rate_change)
    self.lister["model_fish_missile_rate_change"] = basefunc.handler(self, self.on_model_fish_missile_rate_change)

    self.lister["ai_fsg_join_msg"] = basefunc.handler(self, self.on_fsg_join_msg)
    self.lister["ai_manual_shoot"] = basefunc.handler(self, self.ManualShoot)
    self.lister["ai_freed_skill"] = basefunc.handler(self, self.FreeSkill)
    self.lister["ai_change_gun_level"] = basefunc.handler(self, self.ChangeGunLevel)
    self.lister["ai_set_gun_level"] = basefunc.handler(self, self.SetGunLevel)

    self.lister["activity_set_gun_level"] = basefunc.handler(self, self.SetGunLevel)

    self.lister["ui_gold_fly_finish_msg"] = basefunc.handler(self, self.on_ui_gold_fly_finish_msg)
    self.lister["ui_play_laser_finish_msg"] = basefunc.handler(self, self.on_ui_play_laser_finish_msg)
    self.lister["ui_play_missile_finish_msg"] = basefunc.handler(self, self.on_ui_play_missile_finish_msg)
    self.lister["ui_missile_fly_finish_msg"] = basefunc.handler(self, self.on_ui_missile_fly_finish_msg)
    self.lister["ui_timeskill_fly_finish_msg"] = basefunc.handler(self, self.on_ui_timeskill_fly_finish_msg)
    self.lister["ui_zongzi_fly_finish_msg"] = basefunc.handler(self, self.on_ui_zongzi_fly_finish_msg)
    self.lister["ui_zh_fly_finish_msg"] = basefunc.handler(self, self.on_ui_zh_fly_finish_msg)

    self.lister["ui_shake_screen_msg"] = basefunc.handler(self, self.on_ui_shake_screen_msg)

    self.lister["UpdateFishingBagRedHint"] = basefunc.handler(self, self.UpdateFishingBagRedHint)
    self.lister["model_refresh_money"] = basefunc.handler(self, self.model_refresh_money)

    self.lister["model_InitTSPath"] = basefunc.handler(self, self.InitTSPath)
    self.lister["ui_oper_manual_shoot_msg"] = basefunc.handler(self, self.on_ui_oper_manual_shoot)

    self.lister["model_event_summon_fish"] = basefunc.handler(self, self.on_event_summon_fish)
    self.lister["model_event_special_fish"] = basefunc.handler(self, self.on_event_special_fish)
    self.lister["model_event_small_boss"] = basefunc.handler(self, self.on_event_small_boss)
    self.lister["model_event_big_boss"] = basefunc.handler(self, self.on_event_big_boss)

    self.lister["ui_refresh_player_money"] = basefunc.handler(self, self.on_ui_refresh_player_money)
    self.lister["ui_bullet_scale_s2c"] = basefunc.handler(self, self.on_bullet_scale_s2c)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    if is_run_game_panel then
        DSM.PopAct()
        FishDeadManager.MyExit()
        FishingModel.StopUpdateFrame()
        is_run_game_panel = false
        self.update_time_log = "退出 开启"
        if self.game_btn_pre then
            self.game_btn_pre:MyExit()
            self.game_btn_pre = nil
        end
        if self.bag_pre then
            self.bag_pre:MyExit()
            self.bag_pre = nil
        end
        if self.update_time then
            self.update_time:Stop()
        end
        for i=1, FishingModel.maxPlayerNumber do
            self.PlayerClass[i]:MyExit()
        end

        self.update_time = nil
        FishManager.Exit()
        FishExtManager.Exit()
        VehicleManager.Exit()
        BulletManager.Exit()
        self.nor_skill_prefab:MyExit()
        self.oper_prefab:MyExit()
        self:RemoveListener()
        Event.Brocast("fishing_gameui_exit")
        -- GameObject.Destroy(self.transform.gameObject)
    end
end

local isPointDownOnUI = false
local isSkillReady = false
function C:Update()
    if is_run_game_panel and not FishingModel.IsRecoverRet then
    	-- 检测是否放在UI上
        local worldpos_up
        local seatno = FishingModel.GetPlayerSeat()
        if gameRuntimePlatform == "WindowsEditor" or gameRuntimePlatform == "" then
            if UnityEngine.Input.GetMouseButtonDown(0) then
                if FishingModel.GetPlayerLaserState(seatno) == "ready" or
                FishingModel.GetPlayerMissileState(seatno) == "ready" then
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
                if FishingModel.GetPlayerLaserState(seatno) == "ready" or
                FishingModel.GetPlayerMissileState(seatno) == "ready" then
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

        if isSkillReady and FishingModel.GetPlayerLaserState(seatno) == "ready" and worldpos_up then
            isSkillReady = false
            worldpos_up = self.camera2d:ScreenToWorldPoint(worldpos_up)
            self:LaserShoot({vec=worldpos_up, seat_num=seatno})
        elseif isSkillReady and FishingModel.GetPlayerMissileState(seatno) == "ready" and worldpos_up then
            isSkillReady = false
            worldpos_up = self.camera2d:ScreenToWorldPoint(worldpos_up)
            self:MissileShoot({vec=worldpos_up, seat_num=seatno})
        else
            if worldpos then
                worldpos = self.camera2d:ScreenToWorldPoint(worldpos)

                local user = FishingModel.GetPlayerData()
                if user and user.base and user.lock_state == "inuse" and not user.is_lock_gun then

                    -- 射线检测鱼
                    local hit = UnityEngine.Physics2D.Raycast(Vector2(worldpos.x, worldpos.y), Vector2.zero, 1000)

                    if hit.collider ~= nil then
                        local fish = FishManager.GetFishByID(tonumber(hit.collider.gameObject.name))
                        if fish then
                            if not fish.data.seat_num or fish.data.seat_num == FishingModel.data.seat_num then
                                FishingModel.SetLockFishID(FishingModel.data.seat_num, fish.data.fish_id)
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
function C:on_ui_shake_screen_msg(t)
    t = t or 1
    local seq = DoTweenSequence.Create()
    seq:Append(self.by_bg.transform:DOShakePosition(t, Vector3.New(0.30, 0.30, 0), 20))
    seq:OnForceKill(function ()
        if IsEquals(self.by_bg) then
            self.by_bg.transform.localPosition = Vector3.zero
        end
    end)
end

function C:UpdateFishingBagRedHint()
    local tt1 = PlayerPrefs.GetString(MainModel.RecentlyOpenBagTimeFishing, "0")
    local tt2 = PlayerPrefs.GetString(MainModel.RecentlyGetNewItemTimeFishing, "0")
    if tonumber(tt1) < tonumber(tt2) then
        --有新东西
        print("<color=green>捕鱼背包有新物品</color>")
    else
        print("<color=green>捕鱼背包没有新物品</color>")
    end
end

function C:model_refresh_money()
    local uipos = FishingModel.GetPlayerUIPos()
    self.PlayerClass[uipos]:RefreshMoney("fishing_model_msg")
end
function C:Awake()
	local tran = self.transform
	self.gameObject = self.transform.gameObject

	self:MakeLister()
	self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)

	-- 创建2DUI
	local ui2d = newObject("Fishing2DUI")
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
    FishingModel.SetCamera(self.camera2d, self.camera)

	self.isDown = false
    self.update_time_log = ""

    self.by_bg = self.Fishing2DUI_Tran:Find("by_bg"):GetComponent("SpriteRenderer")
    self.Bingdong = self.Fishing2DUI_Tran:Find("Bingdong"):GetComponent("SpriteRenderer")
    self.PlayerUI = {}
    self.PlayerUI2D = {}
    self.PlayerClass = {}
    for i=1, FishingModel.maxPlayerNumber do
    	self.PlayerUI[i] = tran:Find("UINode/Player"..i)
    	self.PlayerUI2D[i] = tran_2D:Find("Player"..i)
    end
    for i=1, FishingModel.maxPlayerNumber do
    	if FishingModel.IsRotationPlayer() then
	    	local i2d = FishingModel.maxPlayerNumber - i + 1
    		self.PlayerClass[i] = FishingPlayer.Create(self, i, self.PlayerUI[i], self.PlayerUI2D[i2d])
    	else
	    	self.PlayerClass[i] = FishingPlayer.Create(self, i, self.PlayerUI[i], self.PlayerUI2D[i])
    	end
	end

    self.DebugText = tran:Find("UINode/DebugText"):GetComponent("Text")
    self.DebugText.gameObject:SetActive(false)
    
    self.FXNode = tran:Find("FXNode")
    self.FishNetNode = tran:Find("UINode/FishNetNode")
    self.SkillNode = tran:Find("UINode/SkillNode")
    self.FlyGoldNode = tran:Find("UINode/FlyGoldNode")
    self.OperNode = tran:Find("UINode/OperNode")
    self.ActFXNode = tran:Find("UINode/ActFXNode")
    

    self.LockHintImage = tran:Find("FXNode/LockHintImage")
    self.DotLine = tran:Find("FXNode/LockHintImage/DotLine")
    self.DotLineLayout = tran:Find("FXNode/LockHintImage/DotLine/DotLine"):GetComponent("HorizontalLayoutGroup")
    self.LockHintAnim = tran:Find("FXNode/LockHintImage/suoding"):GetComponent("Animator")
    self.ZZAddMoneyNode = tran:Find("UINode/ZZAddMoneyNode")
    self.LayerLv2 = GameObject.Find("Canvas/LayerLv2").transform
    self.LayerLv3 = GameObject.Find("Canvas/LayerLv3").transform

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
    end, FishingModel.Defines.FrameTime, -1, nil, true)

    FishDeadManager.Init(self)
    FishingSkillManager.SetPanelSelf(self)
    self.nor_skill_prefab = FishingNorSKillPrefab.Create(self.SkillNode, self)
    self.oper_prefab = FishingOperPrefab.Create(self.OperNode, self)
    FishingLoadingPanel.Create(function(  )
        Event.Brocast("fishing_guide_step")
        Event.Brocast("fishing_activity_begin")
    end)
    self:InitUI()
    is_run_game_panel = true

    if FishingModel.Config.fish_debug_map and
        FishingModel.Config.fish_debug_map.is_bullet_node_onoff and
        FishingModel.Config.fish_debug_map.is_bullet_node_onoff == 1 then
        self.bullet_node_tran.gameObject:SetActive(false)
    end
    if FishingModel.Config.fish_debug_map and
        FishingModel.Config.fish_debug_map.is_fish_node_onoff and
        FishingModel.Config.fish_debug_map.is_fish_node_onoff == 1 then
        self.fish_node_tran.gameObject:SetActive(false)
    end
    self.isHintYB = true

    self.wild_obj = newObject("Crit_time_fire", self.transform)
    self.wild_obj.gameObject:SetActive(false)
    self.doubled_obj = newObject("activity_bjsk_jinbi", self.transform)
    self.doubled_obj.gameObject:SetActive(false)
        
    local btn_map = {}
    btn_map["top"] = {self.ACTTopNode}
    btn_map["left_top"] = {self.Left_Top}
    btn_map["down"] = {self.ACTNode2,self.ACTNode3}
    btn_map["down2"] = {self.ACTNode1, self.ACTNode1_2}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "fishing_game")

    self:UpdateFishingBagRedHint()
end
function C:Start()
    print("-------------------------------start")
    self:InitTSPath()
end
function C:InitUI()
    self:TestAddJoinAI(  )
end
function C:InitTSPath()
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
            stelist[1].waitTime = 600

            -- 增加路径一条
            FishingModel.ts_steer_map[path_id] = steer
            path_id = path_id + 1
        end
    end
    dump(FishingModel.ts_steer_map)
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
    self:RefreshTimeSkill()
    self.nor_skill_prefab:MyRefresh()
    self.oper_prefab:MyRefresh()
end

function C:PrintDebug()
end

-- 断线重连完成
function C:ReadyFinish()
    self:MyRefresh()
    if m_pram then
        if m_pram.open_bag then
            FishingBagPanel.Create({game_type =FishingBagPanel.TYPE_ENUM.free})
        end
    end
    m_pram = nil
    self.update_time_log = "断线重连完成 开启"
    self.update_time:Start()
    if FishingModel.data.fish_map_id % 2 == 0 then
        ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_by_yuchaogame.audio_name)
        self.by_bg.sprite = GetTexture("by_bg1")
    else
        ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_by_game.audio_name)
        self.by_bg.sprite = GetTexture("3dby_bg_4_1")
    end

    local userdata = FishingModel.GetPlayerData()
    if self.isHintYB then
        if userdata and userdata.base and userdata.base.fish_coin > 0 then
            HintYBPrefab.Create(self)
            self.isHintYB = false
        end
    end
    if self.bag_pre then
        self.bag_pre:MyRefresh()
    else
        self.bag_pre = BYKJBagPanel.Create(self.bag_node, self)
    end

    Event.Brocast("fishing_activity_begin")
    Event.Brocast("fishing_ready_finish")
end
function C:on_background_msg()
    if self.update_time then
        self.update_time:Stop()
        -- self.update_time = nil
        self.update_time_log = "切入后台 关闭"
        -- self.back_time = os.time()
    end
end
function C:on_backgroundReturn_msg()
    -- local ct = os.time() - self.back_time
    -- while (true) do
    --     if ct >= FishingModel.Defines.FrameTime then
    --         self:FrameUpdate(FishingModel.Defines.FrameTime)
    --         ct = ct - FishingModel.Defines.FrameTime
    --     else
    --         self:FrameUpdate(ct)
    --         break
    --     end
    -- end
    self.update_time_log = "进入前台 开启"
    -- self.update_time = Timer.New(function ()
    --     self:FrameUpdate(FishingModel.Defines.FrameTime)
    -- end, FishingModel.Defines.FrameTime, -1,false,true)
    -- self.update_time:Start()
end
-- 刷新玩家
function C:RefreshPlayer()
    for i=1, FishingModel.maxPlayerNumber do
        self.PlayerClass[i]:MyRefresh()
    end
end
-- 刷新冰冻
function C:RefreshIce()
    local ice_state = FishingModel.GetSceneIceState()
    if ice_state == "inuse" then
        FishManager.SetIceState(true)
        self.Bingdong.gameObject:SetActive(true)
    else
        FishManager.SetIceState(false)
        self.Bingdong.gameObject:SetActive(false)
    end
end

function C:RefreshTimeSkill(skill_type)
    local userdata = FishingModel.GetPlayerData()
    if not userdata or not userdata.base then
        return
    end

    if skill_type then
        if skill_type == "accelerate" then
            local uipos = FishingModel.GetSeatnoToPos(userdata.base.seat_num)
            if userdata.accelerate_state == "inuse" then
                self.PlayerClass[uipos]:SetAutoCoefficient(1.5)
            else
                self.PlayerClass[uipos]:SetAutoCoefficient(1)
            end
        end
        if skill_type == "wild" or skill_type == "doubled" then
            if userdata[skill_type .. "_state"] == "inuse" then
                self[skill_type .. "_obj"].gameObject:SetActive(true)
            else
                self[skill_type .. "_obj"].gameObject:SetActive(false)
            end
        end
    else
        local ll = {"accelerate", "wild", "doubled"}
        for k,v in ipairs(ll) do
            self:RefreshTimeSkill(v)
        end
    end
end

function C:FrameUpdate(time_elapsed)
    self:PrintDebug()
    -- 防止除0
    if time_elapsed < 0.000001 then
        time_elapsed = 0.000001
    end
    FishingModel.UpdateSkillCD(time_elapsed)

    local ice_state = FishingModel.GetSceneIceState()
    if ice_state == "inuse" then
        local a,b = FishingModel.GetSceneIceTime()
        if a and b then
            self.Bingdong.color = Color.New(1, 1, 1, a/b * 0.7 + 0.3)
        end
    else
        VehicleManager.FrameUpdate(time_elapsed)
    end

    FishManager.FrameUpdate(time_elapsed)
    BulletManager.FrameUpdate(time_elapsed)

    for i=1, FishingModel.maxPlayerNumber do
        self.PlayerClass[i]:FrameUpdate(time_elapsed)
    end
    self.nor_skill_prefab:FrameUpdate(time_elapsed)
    self.oper_prefab:FrameUpdate(time_elapsed)
end

function C:onBoxFishEvent()
    -- FishingAnimManager.PlayWaveHint(self.FXNode, false, "by_imgf_bxycll")
end

-- 鱼儿逃离 2秒逃离完成
function C:FishWaveEvent()
    -- FishingAnimManager.PlayWave(self.FXNode, false)
    if FishingModel.data.fish_map_id % 2 == 0 then
        FishingAnimManager.PlayWaveHint(self.FXNode, false, "by_imgf_ycll")
        FishingAnimManager.PlaySwitchoverMap(self.Fishing2DUI_Tran, "3dby_bg_4_1", "by_bg1", false, function ()
            self.by_bg.sprite = GetTexture("by_bg1")
            ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_by_yuchaogame.audio_name)
        end)
    else
        FishingAnimManager.PlayWaveHint(self.FXNode, false, "by_imgf_ycjs")
        FishingAnimManager.PlaySwitchoverMap(self.Fishing2DUI_Tran, "by_bg1", "3dby_bg_4_1", false, function ()
            self.by_bg.sprite = GetTexture("3dby_bg_4_1")
            ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_by_game.audio_name)
        end)
    end

    ExtendSoundManager.PlaySound(audio_config.by.bgm_by_yuchao.audio_name)

    VehicleManager.PlayFlee(FishingModel.data.clear_level)
    FishManager.PlayFlee(FishingModel.data.clear_level)
end

-- 发射子弹
function C:ManualShoot(data)
	local uipos = FishingModel.GetSeatnoToPos(data.seatno)
	self.PlayerClass[uipos]:ManualShoot(data.vec)
end

function C:on_ui_oper_manual_shoot(pram)
    local uipos = FishingModel.GetSeatnoToPos(pram.seat_num)
    self.PlayerClass[uipos]:ForceShoot(pram)
    if uipos == 1 then
        self.PlayerClass[uipos].FSZT_btn.gameObject:SetActive(false)
        self.PlayerClass[uipos].ZT.gameObject:SetActive(false)
        self.LockHintImage.gameObject:SetActive(false)
    end
end

-- 事件
-- 召唤
function C:on_event_summon_fish(data)
    local cfg = FishingModel.Config.steer_map[data.path]
    local pos = {x=cfg.posX, y=cfg.posY, z=0}
    FishingAnimManager.PlaySummonFishFX(self.fish_node_tran, pos)
end
-- 特殊鱼
function C:on_event_special_fish(data)
    FishingAnimManager.PlaySpecialFishFX(self.FlyGoldNode, data)
end
-- 小boss鱼
function C:on_event_small_boss(data)
    dump(data, "<color=red>小boss鱼</color>")
    FishingAnimManager.PlaySmallBossFX(self.FlyGoldNode, data)
end
-- 大boss鱼
function C:on_event_big_boss(data)
    dump(data, "<color=red>大boss鱼</color>")
    FishingAnimManager.PlayBigBossFX(self.FlyGoldNode)
end

-- 使用炮台(枪)技能
function C:GunSkillShoot(data)
    dump(data, "<color=red><size=20>EEEE  使用炮台(枪)技能 </size></color>")
    data.msg_type = "gun_skill"
    Event.Brocast("model_use_skill_msg", data)
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
    if data.msg_type == "gun_skill" then
        self:LaserShoot(data)
        return
    end

    if data.msg_type == "drill" then
        Event.Brocast("ui_oper_fashe_msg", data)
        return
    end

	FishingModel.SendSkill(data)
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
    if data and data.seat_num and data.bullet_index and self.PlayerClass[data.seat_num] then
        self.PlayerClass[data.seat_num]:SetGunLevel(data.bullet_index)
    end
end
function C:on_ui_refresh_player_money(seat_num)
    seat_num = seat_num or 1
    self.PlayerClass[seat_num]:RefreshMoney()
end
function C:on_bullet_scale_s2c(seat_num, cha)
    local user = FishingModel.GetSeatnoToUser(seat_num)
    if user and user.base then
        user.base.score = user.base.score + cha
        self:on_ui_refresh_player_money(seat_num)
    end
end
function C:Shoot(data)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)

    local pos = self.PlayerClass[uipos]:GetBulletPos()
    local dirVec = {x = data.x, y = data.y}
    local r = Vec2DAngle(dirVec)
    local rr = r - 90
    data.angle = rr
    data.pos = pos

    local userdata = FishingModel.GetSeatnoToUser(data.seat_num)
    local gun_config = FishingModel.GetGunCfg(userdata.index)
    if not FishingActivityManager.CheckHaveBullet(data.seat_num) then
        
        local gun_rate = gun_config.gun_rate
        local bullet_rate_coefficient = 1 -- 倍率系数
        if data.type == FishingModel.BulletType.skill_power_bullet
            or data.type == FishingModel.BulletType.skill_crit_bullet then
                bullet_rate_coefficient = 2
        end
        gun_rate = gun_rate * bullet_rate_coefficient

        FishingModel.AddMoneyLog(data.seat_num, "开抢=(" .. gun_rate .. ")")
        if userdata.base.fish_coin >= gun_rate then
            userdata.base.fish_coin = userdata.base.fish_coin - gun_rate
        else
            userdata.base.score = userdata.base.score - gun_rate + userdata.base.fish_coin
            userdata.wait_dec_score = userdata.wait_dec_score + gun_rate - userdata.base.fish_coin
            userdata.base.fish_coin = 0
        end
    end
    self.PlayerClass[uipos]:RunShoot(data)
    self.PlayerClass[uipos]:RefreshMoney()
end

function C:GetTimeSkillPos(skill_type)
    return self.nor_skill_prefab[skill_type .. "_btn"].transform.position
end
function C:GetLockPos()
    return self.nor_skill_prefab.lock_btn.transform.position
end
function C:GetIcePos()
    return self.nor_skill_prefab.ice_btn.transform.position
end
function C:GetZHPos()
    return self.nor_skill_prefab.zh_btn.transform.position
end
function C:GetPlayerPos(seat_num)
    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    local pos = self.PlayerClass[uipos]:GetPlayerFXPos()
    return pos
end

-- *******************************
-- model的广播消息
-- *******************************
-- 冰冻解封
function C:on_model_ice_skill_deblocking_msg()
    FishManager.SetIceDeblocking()
end

function C:on_model_time_skill_change_msg(seat_num, skill_type, is_lose)
    local userdata = FishingModel.GetSeatnoToUser(seat_num)
    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    
    if not is_lose then
        if skill_type == "lock" then
            self.PlayerClass[uipos]:RefreshLock()
            if userdata.lock_state ~= "inuse" then
                FishingModel.RemoveLockFishID(seat_num)
            end
        end
        if skill_type == "frozen" then
            if FishingModel.data.scene_frozen_state == "inuse" then
                ExtendSoundManager.PlaySound(audio_config.by.bgm_by_bingfeng.audio_name)
                FishManager.SetIceState(true)
                self.Bingdong.gameObject:SetActive(true)
                FishingAnimManager.PlayFrozen(self.FXNode)
                self.PlayerClass[uipos]:SetIce(true)
            else
                FishManager.SetIceState(false)
                self.Bingdong.gameObject:SetActive(false)
                self.PlayerClass[uipos]:SetIce(false)
            end
        end
        if skill_type == "accelerate" then
            if userdata[skill_type .. "_state"] == "inuse" then
                GameComAnimTool.PlayShowAndHideAndCall(self.transform, "activity_zdjs", Vector3.zero, 2.16)
            end
            self.PlayerClass[uipos]:RefreshTimeSkill(skill_type)
            self:RefreshTimeSkill(skill_type)
        end
        if skill_type == "wild" and seat_num == my_seat_num then
            if userdata[skill_type .. "_state"] == "inuse" then
                GameComAnimTool.PlayShowAndHideAndCall(self.transform, "activity_wlsk", Vector3.zero, 1.8)
            end
            self:RefreshTimeSkill(skill_type)
        end
        if skill_type == "doubled" and seat_num == my_seat_num then
            if userdata[skill_type .. "_state"] == "inuse" then
                GameComAnimTool.PlayShowAndHideAndCall(self.transform, "activity_bjsk", Vector3.zero, 1.8)
            end
            self:RefreshTimeSkill(skill_type)
        end
    end
end

function C:on_model_player_PC(seat_num)
    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    self.PlayerClass[uipos]:SetPC()
end

-- 子弹碰撞
function C:on_model_bullet_boom(data)
    local bullet =  BulletManager.GetIDToBullet(data.id)
    if bullet then
        FishingAnimManager.PlayFishNet(self.FishNetNode.transform, data)
        -- 只有自己的子弹碰到鱼才播受击
        if bullet.seat_num == FishingModel.data.seat_num then
            FishManager.PlayFishSuffer(data.fish_list)
        end
    end
end
-- 玩家加入
function C:on_fsg_join_msg(seatno)
    local uipos = FishingModel.GetSeatnoToPos(seatno)
    self.PlayerClass[uipos]:SetPlayerEnter()
    FishingPlayerAIManager.AddPlayer(seatno,self.PlayerClass[uipos])
end
-- 玩家离开
function C:on_fsg_leave_msg(seatno)
    local uipos = FishingModel.GetSeatnoToPos(seatno)
    self.PlayerClass[uipos]:SetPlayerExit()    
    FishingPlayerAIManager.RemovePlayer(seatno)
end
function C:on_model_player_money_msg(data)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)
    if uipos then
    	self.PlayerClass[uipos]:RefreshMoney(data.change_type)
    	self.nor_skill_prefab:RefreshAssets()
    end
end
-- 金币飞行完成
function C:on_ui_gold_fly_finish_msg(data)
    local uipos = FishingModel.GetSeatnoToPos(data.seat_num)
    self.PlayerClass[uipos]:AddMoneyNumber(data.score)
end
-- 粽子飞行完成
function C:on_ui_zongzi_fly_finish_msg(seat_num, score)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if my_seat_num == seat_num then
        dump(self.ZZAddMoneyNode,"?????????????????????????????????????")
        FishingAnimManager.PlayAddZongzi(seat_num, score, self.ZZAddMoneyNode, Vector3.zero)
    end
end

-- 激光播放完成
function C:on_ui_play_laser_finish_msg(seat_num)
    FishingModel.SetPlayerLaserState(seat_num, "nor")
    Event.Brocast("ui_laser_state_change", seat_num)
end
-- 核弹播放完成
function C:on_ui_play_missile_finish_msg(seat_num)
    FishingModel.SetPlayerMissileState(seat_num, "nor")
end
-- 核弹碎片飞行完成
function C:on_ui_missile_fly_finish_msg(seat_num, v)
    local my_seat_num = FishingModel.GetPlayerSeat()
    local userdata = FishingModel.GetSeatnoToUser(seat_num)
    if userdata and userdata.base then
        userdata.missile_index = userdata.missile_index + 1
        userdata.missile_list[userdata.missile_index] = v
    end
    if my_seat_num == seat_num then
        self.nor_skill_prefab:UpdateMissileState()
    end
end

-- 时间道具飞行完成
function C:on_ui_timeskill_fly_finish_msg(seat_num, v, skill_type)
    local my_seat_num = FishingModel.GetPlayerSeat()
    local userdata = FishingModel.GetSeatnoToUser(seat_num)
    if userdata and userdata.base then
        userdata["prop_fish_" .. skill_type] = userdata["prop_fish_" .. skill_type] + v
    end
    if my_seat_num == seat_num then
        self.nor_skill_prefab:RefreshTimeSkill(skill_type)
    end
end

-- 召唤道具飞行完成
function C:on_ui_zh_fly_finish_msg(seat_num, v)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if my_seat_num == seat_num then
        self.nor_skill_prefab:RefreshMF()
    end
end

-- 子弹弄死的鱼
function C:on_model_fish_dead(data)
    FishDeadManager.on_model_fish_dead(data, self.FXNode)
end
-- 激光弄死的鱼
function C:on_model_fish_dead_laser(data)
    FishDeadManager.on_model_fish_dead_laser(data, self.FXNode)
end
-- 核弹弄死的鱼
function C:on_model_fish_dead_missile(data)
    FishDeadManager.on_model_fish_dead_missile(data, self.FXNode)
end
-- 激光进度改变
function C:on_model_fish_laser_rate_change(seat_num)
    local uipos = FishingModel.GetSeatnoToPos(seat_num)
    self.PlayerClass[uipos]:RefreshJG(true)
end

-- 核弹进度改变
function C:on_model_fish_missile_rate_change(seat_num)
    local my_seat_num = FishingModel.GetPlayerSeat()
    if my_seat_num == seat_num then
        self.nor_skill_prefab:UpdateMissileState()
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
        -- v.time = FishingModel.data.system_time - FishingModel.data.begin_time
        -- v.path = 7
        -- v.rate = 100
        -- v.fish_id = 8883
        -- FishManager.AddFishTeam(v)

        local v = {}
        v.types = {1,1,1,1,1}
        v.ids = {8883,8884,8885,8886,8887}
        v.time = FishingModel.data.system_time - FishingModel.data.begin_time
        v.time = v.time * 10
        v.path = 6
        v.rate = 100
        v.group_id = 1000
        FishManager.AddFishGroup(v)
    end)
end

local ai_running = false
function C:TestStopAI()
    for i=1,4 do
        FishingPlayerAIManager.SetUpdateRunning(i, ai_running)
    end
    ai_running = not ai_running
end
function C:onAssetChange()
end

function C.GetPlayerInstance(seatno)
    if instance then
        if not seatno then
            seatno = FishingModel.GetPlayerSeat()
        end
        local uipos = FishingModel.GetSeatnoToPos(seatno)
        return instance.PlayerClass[uipos]
    end
end

function C:GetSkillNode()
    if self.bag_pre then
        return self.bag_pre:GetSkillNode()
    else
        return Vector3.zero
    end
end