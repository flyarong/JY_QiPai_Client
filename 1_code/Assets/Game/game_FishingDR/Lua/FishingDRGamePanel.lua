local basefunc = require "Game/Common/basefunc"
FishingDRGamePanel = basefunc.class()
-- 别名
FishingGamePanel = FishingDRGamePanel
local C = FishingDRGamePanel
C.name = "FishingDRGamePanel"

local camera2d = nil
local instance
function C.Create(pram)
    if not instance then
        DSM.PushAct({panel = C.name})
		instance = C.New(pram)
		instance = instance
	else
		instance:MyRefresh()
	end
	return instance
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
    self.lister["AssetChange"] = basefunc.handler(self, self.RefreshAssets)
    
    self.lister["model_fish_trigger_item"] = basefunc.handler(self, self.model_fish_trigger_item)
    self.lister["model_bullet_trigger_fish"] = basefunc.handler(self, self.model_bullet_trigger_fish)
    self.lister["model_shoot"] = basefunc.handler(self, self.model_shoot)
    self.lister["model_game_click"] = basefunc.handler(self, self.model_game_click)

    self.lister["model_fish_dead_msg"] = basefunc.handler(self, self.model_fish_dead_msg)
    self.lister["model_fish_flee_msg"] = basefunc.handler(self, self.model_fish_flee_msg)
    self.lister["model_event_trigger_msg"] = basefunc.handler(self, self.model_event_trigger_msg)
    self.lister["model_event_trigger_end_msg"] = basefunc.handler(self, self.model_event_trigger_end_msg)

    self.lister["model_fishing_dr_enter_room"] = basefunc.handler(self, self.on_fishing_dr_enter_room)
    self.lister["model_fishing_dr_game_begin"] = basefunc.handler(self, self.on_fishing_dr_game_begin)
    self.lister["model_fishing_dr_game_end"] = basefunc.handler(self, self.on_fishing_dr_game_end)
    self.lister["model_fishing_dr_game_new"] = basefunc.handler(self, self.on_fishing_dr_game_new)
    self.lister["model_add_history_log"] = basefunc.handler(self, self.on_add_history_log)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyClose()
    self:MyExit()
    destroy(self.gameObject)
    destroy(self.Fishing2DUI_Obj)
end
function C:MyExit()
    DSM.PopAct()
    FishingDRBetPanel.Close()
    FishingDRNoticePanel.Close()
    FishingDROverPanel.Close()
    self:RemoveListener()
    FishingDRPlayerManager.Exit()
    FishingDRGunManager.Exit()
    FishingDRItemManager.Exit()
    FishingDRFishManager.Exit()
    FishingDRBulletManager.Exit()
    FishingDRFishNetManager.Exit()
    if self.start_time then
        self.start_time:Stop()
        self.start_time = nil
    end
    if self.update_time then
        self.update_time:Stop()
        self.update_time = nil
    end    
    if self.flee_time then
        self.flee_time:Stop()
        self.flee_time = nil
    end
    if self.yb_timer then
        self.yb_timer:Stop()
        self.yb_timer = nil
    end
    if self.game_btn_pre then
		self.game_btn_pre:MyExit()
    end
    for k, v in pairs(self.record_list) do
    	destroy(v.gameObject)
    end
    self.record_list = {}
    self.record_list_node = nil
    self.record_tmpl = nil
end

function C:Update()
    if not self then return end
    C.check_click(self.camera2d)
end

function C:ctor()
    local parent = GameObject.Find("Canvas/GUIRoot").transform
	self.gameObject = newObject(C.name, parent)
    self.transform = self.gameObject.transform
	self:MakeLister()
	self:AddMsgListener()
	-- 创建2DUI
    local ui2d = newObject("FishingDR2DUI")

    local cam = ui2d.transform:Find("CatchFish2DCamera"):GetComponent("Camera")
    cam.clearFlags = UnityEngine.CameraClearFlags.Skybox;

	self.Fishing2DUI_Obj = ui2d
    self.Fishing2DUI_Tran = ui2d.transform
    self.GunNodes={}
    self.camera2d = self.Fishing2DUI_Tran:Find("CatchFish2DCamera"):GetComponent("Camera")
    self.camera = GameObject.Find("Canvas/Camera"):GetComponent("Camera") 
    FishingDRModel.SetCamera(self.camera2d, self.camera)

    self.zdx = self.Fishing2DUI_Tran:Find("zdx")
    self.LineNode = self.Fishing2DUI_Tran:Find("LineNode")
    self.GunNode = self.Fishing2DUI_Tran:Find("GunNode")
    self.by_bg_Node_1 = self.Fishing2DUI_Tran:Find("by_bg_Node_1")
    self.by_bg_Node_2 = self.Fishing2DUI_Tran:Find("by_bg_Node_2")
    self.by_bg_Node_3 = self.Fishing2DUI_Tran:Find("by_bg_Node_3")
    self.by_bg_Node_1_times = self.Fishing2DUI_Tran:Find("by_bg_Node_1/times")


    self.ybh_list = {}
    self.gun_list = {}
    for i = 1, 7 do
        self.ybh_list[#self.ybh_list + 1] = self.transform:Find("UINode/Player" .. i.."/ybh")
        self.gun_list[#self.gun_list + 1] = self.Fishing2DUI_Tran:Find("GunNode/Node" .. i)
    end

    self.FishNodeTran = self.Fishing2DUI_Tran:Find("FishNodeTran")
    self.FishAniNodeTran = self.Fishing2DUI_Tran:Find("FishAniNodeTran")

    self.GoldText = self.transform:Find("UINode/RectTop/JBBG/GoldText"):GetComponent("Text")

    self.BackButton = self.transform:Find("UINode/RectTop/BackButton"):GetComponent("Button")
    self.BackButton.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBack()
    end)

    self.JBBG = self.transform:Find("UINode/RectTop/JBBG"):GetComponent("Button")
    self.JBBG.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnJBBG()
    end)

    self.FXNode = self.transform:Find("FXNode")
    --self.by_bg = self.Fishing2DUI_Tran:Find("by_bg_Node/by_bg"):GetComponent("SpriteRenderer")

    self.TallyNode = self.transform:Find("UINode/RectTop/TallyNode")
    self.record_list_node = self.transform:Find("UINode/RectTop/TallyNode/record_list_node")
    self.record_tmpl = self.transform:Find("UINode/RectTop/TallyNode/record_tmpl")
    self.record_list = {}

    FishingDROverPanel.Create()
    FishingDRNoticePanel.Create()
    
    FishingDRPlayerManager.Init()
    FishingDRGunManager.Init()
    FishingDRItemManager.Init()
    FishingDRFishManager.Init()
    FishingDRBulletManager.Init()
    FishingDRFishNetManager.Init()
    self:InitUI()
end

function C:InitUI()
    LuaHelper.GeneratingVar(self.transform, self)
    local btn_map = {}
    btn_map["top"] = {self.hall_btn_top}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "crazy_fish_game")
    

    self.ca = GameObject.Find("Canvas/Camera")

    self.energy_node = GameObject.Find("Canvas/GUIRoot/FishingDRGamePanel/UINode/EnergyNode")
    self.energy_txt = GameObject.Find("Canvas/GUIRoot/FishingDRGamePanel/UINode/EnergyNode/energy_count"):GetComponent("Text")

    self.gun_button_node = GameObject.Find("Canvas/GUIRoot/FishingDRGamePanel/UINode/GunButton")
    for i=1,7 do
        local btn = self.gun_button_node.Find("GunButton"..i):GetComponent("Button")
        btn.onClick:AddListener(function ()
            self:onGunClick(i)
        end)
    end

    if  #self.GunNodes ~= 7 then 
        for i = 1, 7 do
            local str="GunNode/Node"..i.."/GunAnim/Gun/GunOpen"
            local b=self.Fishing2DUI_Obj.transform:Find(str)
            self.GunNodes[#self.GunNodes+1]=b
        end
    end
end

function C:MyRefresh(is_ani)
    print("<color=white>刷新游戏</color>")
    self:RefreshAssets()
    local m_data = FishingDRModel.data
    if m_data and m_data.model_status then
        if m_data.model_status == FishingDRModel.Model_Status.bet then
            self:RefreshBet(is_ani)
            self:SceneReady(is_ani)
        elseif m_data.model_status == FishingDRModel.Model_Status.gaming then
            FishingDRBetPanel.Close()
            self:SceneStart(is_ani)
            self:RefreshGaming(is_ani)
        elseif m_data.model_status == FishingDRModel.Model_Status.gameover then
            ExtendSoundManager.PauseSceneBGM()
            FishingDRBetPanel.Close()
            self:RefreshGameover(is_ani)
        else
            dump(m_data, "<color=red>状态不存在</color>")
        end
    else
        print("ssssssssssssssss")
    end
end
function C:RefreshAssets()
   self.GoldText.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi) 
end

function C:RefreshBet(is_ani)
    if self.update_time then
        self.update_time:Stop()
        self.update_time = nil
    end
    if IsEquals(self.TallyNode) then
        self.TallyNode.gameObject:SetActive(false)
    end
    --self:SceneGunExit(is_ani)
    self:ClearFlyItem()
    FishingDROverPanel.MyHide()
    FishingDRPlayerManager.RefreshAll()
    FishingDRBetPanel.Create()
    ExtendSoundManager.PlaySceneBGM(audio_config.by_dr.bydr_bgm_bet.audio_name)
    C.ManagerRemoveAll()
end

-- 刷新游戏进行中界面
function C:RefreshGaming(is_ani)
    if IsEquals(self.TallyNode) then
        self.TallyNode.gameObject:SetActive(true)
    end
    --self:SceneGunEnter(is_ani)
    C.ManagerRemoveAll()
    if not FishingDRModel.data then return end
    --枪
    if not table_is_null(FishingDRModel.data.gun) then
        for k,v in pairs(FishingDRModel.data.gun) do
            FishingDRGunManager.Add(v)
        end
    end

    --玩家
    if not table_is_null(FishingDRModel.data.player) then
        for k,v in pairs(FishingDRModel.data.player) do
            FishingDRPlayerManager.Add(v)
        end
    end

    --道具
    if not table_is_null(FishingDRModel.data.item) then
        for k,v in pairs(FishingDRModel.data.item) do
            v.pos = FishingDRItemManager.GetParentPos(v.track_id)
            v.pos = Vector3.New(v.pos.x + FishingDRModel.s2c_size(v.location),v.pos.y,v.pos.z)
            FishingDRItemManager.Add(v)
        end
    end

    --鱼
    if not table_is_null(FishingDRModel.data.fish) then
        for k,v in pairs(FishingDRModel.data.fish) do
            v.pos = FishingDRFishManager.GetParentPos(v.track_id)
            v.r = 0
            FishingDRFishManager.Add(v)
        end
    end

    FishingDRModel.FrameUpdateByTime(FishingDRModel.data.game_data.countdown_time)
    self:CreateFlyItem()
    --刷新鱼，道具，玩家
    --道具
    if not table_is_null(FishingDRModel.data.item) then
        for k,v in pairs(FishingDRModel.data.item) do
            if v.trigger == 1 then
                FishingDRItemManager.Remove(v.index)
            end
        end
    end

    --鱼
    if not table_is_null(FishingDRModel.data.fish) then
        for k,v in pairs(FishingDRModel.data.fish) do
            if v.is_dead == 1 then
                FishingDRFishManager.Remove(v.fish_id)
            end
        end
    end
    -- FishingDRFishManager.RefreshAll()
    -- FishingDRItemManager.RefreshAll()
    FishingDRPlayerManager.RefreshAll()
    if self.update_time then
        self.update_time:Stop()
        self.update_time = nil
    end
    self.update_time = Timer.New(function ()
        C.FrameUpdate(FishingDRModel.Defines.FrameTime)
    end, FishingDRModel.Defines.FrameTime, -1,false,false)
    if is_ani then
        if self.start_time then
            self.start_time:Stop()
            self.start_time = nil
        end
        self.start_time = Timer.New(function(  )
            self.update_time:Start()
        end,1.5,1)
        self.start_time:Start()
        ExtendSoundManager.PlaySound(audio_config.by_dr.bydr_bgm_begin.audio_name)
    else
        self.update_time:Start()
    end
    ExtendSoundManager.PlaySceneBGM(audio_config.by_dr.bydr_bgm_game.audio_name)

    self:RefreshEnergy()
end

function C:RefreshGameover(is_ani)
    if IsEquals(self.TallyNode) then
        self.TallyNode.gameObject:SetActive(false)
    end
    self:ClearFlyItem()
    --self:SceneGunExit(is_ani)
    if is_ani then
        ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_xxl_jiangli2_game_fishingdr.audio_name)
    end
    FishingDRPlayerManager.RefreshAll()
    C.ManagerRemoveAll()
    -- if self.update_time then
    --     self.update_time:Stop()
    --     self.update_time = nil
    -- end
    FishingDROverPanel.Show(FishingDRModel.data.settlement_data,nil,FishingDRModel.data.game_data.countdown_time)
end

function C.FrameUpdate(time_elapsed)
    -- 防止除0
    if time_elapsed < 0.000001 then
        time_elapsed = 0.000001
    end
    -- camera2d.transform.localPosition = camera2d.transform.localPosition + Vector3.New(-1,0,0) * time_elapsed * FishingDRModel.data.ave_sp
    if FishingDRModel.check_is_reset() then
        --重置中
    else
        --正常流程
        FishingDRModel.FrameUpdate(time_elapsed)
    end
    FishingDRFishManager.FrameUpdate(time_elapsed)
    FishingDRBulletManager.FrameUpdate(time_elapsed)
    FishingDRGunManager.FrameUpdate(time_elapsed)
    FishingDRPlayerManager.FrameUpdate(time_elapsed)

    if instance then
        instance:RefreshEnergy()
    end
end

function C:on_fishing_dr_enter_room()
    self:MyRefresh(true)
end
function C:on_fishing_dr_game_begin()
    --(type,data,backcall,timeout,isclickclose)
    FishingDRNoticePanel.Show(FishingDRNoticePanel.Types.KSBY,nil,nil,1.6,true)
    self:MyRefresh(true)
end
function C:on_fishing_dr_game_end()
    self:MyRefresh(true)
end
function C:on_fishing_dr_game_new()
    self:MyRefresh(true)
end
function C:on_add_history_log()
    self:MyRefresh(true)
end

function C:on_background_msg()
    if self.update_time then
        self.update_time:Stop()
    end
    self.ext_prefab:on_background_msg()
end
function C:on_backgroundReturn_msg()
    self.ext_prefab:on_backgroundReturn_msg()
end

-- *******************************
-- model的广播消息
-- *******************************
-- 点击
function C:model_game_click(data)
    -- dump(data, "<color=white>点击</color>")
    if table_is_null(data.players) then return end
    -- for k,v in pairs(data.players) do
    --     FishingDRGunManager.ManualShoot(v.gun_id,data.worldpos)
    -- end
end

local ITEM_IMAGE = {
	"bydr_game_icon_y15", "bydr_game_icon_y16", "bydr_game_icon_y17", "bydr_game_icon_y18", "bydr_game_icon_y19", "bydr_game_icon_y20", "bydr_game_icon_y21"
}
function C:FlyItem(idx, callback, is_fj, not_fly,pos)
    if not table_is_null(self.record_list) then
        for i,v in ipairs(self.record_list) do
            if is_fj ~= nil then
                if tonumber(v.gameObject.name) == 8 then return end 
            else
                if tonumber(v.gameObject.name) == tonumber(idx) then return end 
            end
        end
    end
	local fish = FishingDRFishManager.Get(idx)
    if not fish then return end

	local period = 1
	local point = pos or FishingDRModel.Get2DToUIPoint(fish.transform.position)
	local item = GameObject.Instantiate(self.record_tmpl, self.record_list_node)
    self.record_list[#self.record_list + 1] = item
    item.gameObject:SetActive(true)
    item.gameObject.name = idx
	point = item.transform:InverseTransformPoint(point)

    local icon = item.transform:Find("icon_img")
    local icon_img = icon:GetComponent("Image")
    icon_img.sprite = GetTexture(ITEM_IMAGE[idx])
    if is_fj ~= nil then
        --返金
        item.gameObject.name = 8
        icon_img.sprite = GetTexture("bydr_game_icon_jyb_1")
    else
        local num_img = item.transform:Find("icon_img/num_img"):GetComponent("Image")
        if FishingDRModel.data and not table_is_null(FishingDRModel.data.event_data) then
            for i,v in ipairs(FishingDRModel.data.event_data) do
                if v.track_id == idx and v.id ~= 4 then
                    num_img.sprite = GetTexture("bydr_game_imgf_bs" .. (v.id + 1))
                    num_img.gameObject:SetActive(true)
                end
            end
        end
    end
    
    if not_fly then return end
	FishingDRAnimManager.FlyItem(icon, point, period, callback, 0, true)
end

function C:ClearFlyItem()
    if table_is_null(self.record_list) then
        return
    end
    for _, v in ipairs(self.record_list) do
        destroy(v.gameObject)
    end
    self.record_list = {}
end

function C:CreateFlyItem()
    for k, v in pairs(self.record_list) do
    	destroy(v.gameObject)
    end
    self.record_list = {}
    local m_data = FishingDRModel.data
    dump(m_data.fish, "<color=yellow>我的捕鱼</color>")
    if m_data and m_data.fish then
        for k,v in pairs(m_data.fish) do
            if v.is_dead == 1 then
                self:FlyItem(k, nil, nil, true)
                if v.is_fj ~= nil then
                    self:FlyItem(k, nil, v.is_fj, true)
                end
            end
        end
    end
end

-- 开枪
function C:model_shoot(data)
    -- dump(data, "<color=white>开枪</color>")
    FishingDRBulletManager.Add(data.bullet)
end
-- 子弹碰撞
function C:model_bullet_trigger_fish(data)
    -- dump(data, "<color=yellow>子弹数据</color>")
    if data.bullet.is_destroy then
        FishingDRBulletManager.Remove(data.bullet.id)
    end
    if data.gun.id == 8 then
        FishingDRFishNetManager.Add(data.net)
    end
    --鱼死处理
    if data.fish.is_dead then
        dump(data, "<color=white>鱼被打死</color>")
        self:PlayFishDead(data)
    else
        FishingDRFishManager.FishSuffer(data.fish.id,data.fish.reply_level)
        FishingDRModel.set_fish_sp(data.fish.fish_id)
        -- FishingDRGunManager.Remove(data.fish.id)
        -- FishingDRBulletManager.RemoveByGunID(data.fish.id)
        FishingDRPlayerManager.Refresh(data.fish.id)
    end
end

--播放激光
function C:playjg(trigger)
    for i = 1, #trigger do
        FishingDRAnimManager.PlayDRLaser(self.GunNodes[trigger[i]].parent.parent,trigger[i],FishingDRModel.Get2DToUIPoint(self.GunNodes[trigger[i]].transform.position))
    end
end

--播放闪电
function C:playsd(fishid,trigger)
    -- body
    local pos={}
    for i = 1, #trigger do
        if FishingDRFishManager.Get(trigger[i]) and IsEquals(FishingDRFishManager.Get(trigger[i]).transform) then
            pos[#pos+1]= FishingDRModel.Get2DToUIPoint( FishingDRFishManager.Get(trigger[i]).transform.position)
        end
    end
    dump(pos, "######################################")
    if FishingDRFishManager.Get(fishid) and IsEquals(FishingDRFishManager.Get(fishid).transform) then
        dump("闪电", "<color=yellow>闪电》》》》》》》》》》》》》</color>")
        FishingDRAnimManager.PlayLinesFX_FS(self.FXNode.transform,FishingDRModel.Get2DToUIPoint(FishingDRFishManager.Get(fishid).transform.position),pos,0.2,1)
    end
end

function C:model_fish_trigger_item(data)
    dump(data, "<color=white>触发道具</color>")
    if data.id == 1 or data.id == 2 or data.id == 3 then
        --道具加倍
        print("<color=yellow>道具加倍</color>")
        --待完成 加倍表现
        if FishingDRModel.check_is_reset() then
            --重置中
            FishingDRItemManager.Remove(data.index)
            local fish = FishingDRFishManager.Get(data.fish_id)
            if fish then fish:CreateBing() end
        else
            --正常流程
            FishingDRItemManager.Remove(data.index)
            local fish = FishingDRFishManager.Get(data.fish_id)
            if fish then fish:CreateJB(data.id + 1) end
        end
    elseif data.id == 4 then
        --道具减速
        print("<color=yellow>道具减速</color>")
        --待完成 减速表现
        if FishingDRModel.check_is_reset() then
            --重置中
            FishingDRItemManager.Remove(data.index)
            local fish = FishingDRFishManager.Get(data.fish_id)
            if fish then fish:CreateBing() end
        else
            --正常流程
            FishingDRItemManager.Remove(data.index)
            local fish = FishingDRFishManager.Get(data.fish_id)
            if fish then fish:CreateBing() end
            local pos = FishingDRModel.Get2DToUIPoint(fish.transform.position)
            FishingDRAnimManager.PlayShowAndHideFX(self.FXNode,"by_bs_jiansu_bing",pos,2)
        end
    end
end

-- 鱼死亡
function C:model_fish_dead_msg(data)
    dump(data, "<color=white>鱼死亡</color>")
    --待完成 游戏界面刷新 清除子弹，停止射击，炮台刷新，捕获提示
    if FishingDRModel.check_is_reset() then
        --重置中不弹捕获提示
        FishingDRFishManager.FishDead(data.fish.fish_id)
        -- FishingDRGunManager.Remove(data.fish.fish_id)
        -- FishingDRBulletManager.RemoveByGunID(data.fish.fish_id)
        FishingDRPlayerManager.Refresh(data.fish.fish_id)
        --不要动画
        -- self:FlyItem(data.fish.fish_id)
    else
        --正常流程弹捕获提示
        data.fish.id = data.fish.fish_id
        data.fish.trigger,data.fish.trigger_type = FishingDRModel.get_fish_trigger(data.fish.id)
        self:PlayFishDead(data)
    end
end

function C:PlayFishDead(data)
    if table_is_null(data.fish.trigger) then
        local fishobj = FishingDRFishManager.Get(data.fish.id)
        fishobj:SetFishState(FishingDRFishPrefab.FishState.FS_FeignDead)
        local pos = fishobj.transform.position -- FishingDRModel.Get2DToUIPoint(fishobj.transform.position)
        ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_dapiaojinbi.audio_name)
        FishingDRAnimManager.PlayDRFishDeadFX(self.FXNode, pos, fishobj, function ()
            -- FishingDRGunManager.Remove(data.fish.id)
            -- FishingDRBulletManager.RemoveByGunID(data.fish.id)
            FishingDRPlayerManager.Refresh(data.fish.id)
            local fish = {}
            fish[#fish + 1] = data.fish.id

            if data.fish.is_fj ~= nil then
                ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_by_jiangli6_game_fishingdr.audio_name)
                -- self:FlyItem(data.fish.id, function (  )
                --     self.yb_timer = Timer.New(function(  )
                --         self:FlyItem(data.fish.id,function(  )
                --             FishingDRNoticePanel.Show(FishingDRNoticePanel.Types.JYB, data.fish.is_fj, nil, 1, true)
                --         end,data.fish.is_fj)
                --     end,0.5,1)
                --     self.yb_timer:Start()
                -- end)
                local seq = DoTweenSequence.Create()
                local prefab
                seq:AppendInterval(0.02)
                seq:AppendCallback(function(  )
                    self:FlyItem(data.fish.id)
                end)
                seq:AppendInterval(0.5)
                seq:AppendCallback(function(  )
                    prefab = CachePrefabManager.Take("by_yuanbao")
                    prefab.prefab:SetParent(self.FXNode.transform)
                    prefab.prefab.prefabObj.transform.localPosition = pos
                    prefab.prefab.prefabObj.transform.localRotation = Quaternion.Euler(0, 0, 0)
                end)
                seq:AppendInterval(2)
                seq:AppendCallback(function(  )
                    self:FlyItem(data.fish.id,function(  )
                    end,data.fish.is_fj,nil,pos)
                end)
                -- seq:AppendInterval(0.5)
                -- seq:AppendCallback(function(  )
                --     FishingDRNoticePanel.Show(FishingDRNoticePanel.Types.JYB, data.fish.is_fj, nil, 1, true)
                -- end)
                seq:OnForceKill(function()
                    if prefab then
                        CachePrefabManager.Back(prefab)
                    end
                end)
            else
                self:FlyItem(data.fish.id)
            end
            -- 自己死亡
            FishingDRFishManager.FishDead(data.fish.id,data.fish.reply_level)
        end)
    else
        --待完成
        if data.fish.trigger_type == 1 then
            -- 自己死亡
        elseif data.fish.trigger_type == 2 then
            dump(data.fish, "data.fish.idttttttttttttttttttttttttttt")

            local fishobj = FishingDRFishManager.Get(data.fish.id)
            fishobj:SetFishState(FishingDRFishPrefab.FishState.FS_FeignDead)
            for k,v in ipairs(data.fish.trigger) do
                local fobj = FishingDRFishManager.Get(v)
                fobj:SetFishState(FishingDRFishPrefab.FishState.FS_FeignDead)
            end
            local pos = FishingDRModel.Get2DToUIPoint(fishobj.transform.position)
            ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_dapiaojinbi.audio_name)
            ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_by_shandianyu_game_fishingdr.audio_name)
            --闪电
            self:playsd(data.fish.id, data.fish.trigger)
            FishingDRAnimManager.PlayDRFishDeadFX(self.FXNode, pos, fishobj, function ()
                local fish = {}
                fish[#fish + 1] = data.fish.id
                for k,v in ipairs(data.fish.trigger) do
                    if not FishingDRModel.check_fish_is_dead(v) then
                        fish[#fish + 1] = v
                    end
                end
                for k,v in ipairs(fish) do
                    self:FlyItem(v)
                    FishingDRModel.set_fish_dead(v)
                    FishingDRFishManager.FishDead(v, 1)
                    -- FishingDRGunManager.Remove(v)
                    -- FishingDRBulletManager.RemoveByGunID(v)
                    FishingDRPlayerManager.Refresh(v)
                end
            end)
        elseif data.fish.trigger_type == 3 then
            dump(data.fish, "data.fish.idttttttttttttttttttttttttttt")
            local fishobj = FishingDRFishManager.Get(data.fish.id)
            fishobj:SetFishState(FishingDRFishPrefab.FishState.FS_FeignDead)
            local pos = FishingDRModel.Get2DToUIPoint(fishobj.transform.position)
            ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_dapiaojinbi.audio_name)
            ExtendSoundManager.PlaySound(audio_config.by_dr.bgm_by_jiguang2.audio_name)

            local cc = function (id)
                if FishingDRModel.check_fish_is_dead(id) then return end
                self:playjg({id})
                local seq = DoTweenSequence.Create()
                seq:AppendInterval(1)
                seq:AppendCallback(function()
                    if FishingDRModel.check_fish_is_dead(id) then return end
                    local fish = {id}
                    for k,v in ipairs(fish) do
                        dump(fish, "<color=white>激光射死的鱼</color>")
                        local fobj = FishingDRFishManager.Get(v)
                        if IsEquals(fobj) then
                            fobj:SetFishState(FishingDRFishPrefab.FishState.FS_FeignDead)
                        end
                        self:FlyItem(v)
                        FishingDRModel.set_fish_dead(v)
                        FishingDRFishManager.FishDead(v, 1)
                        -- FishingDRGunManager.Remove(v)
                        -- FishingDRBulletManager.RemoveByGunID(v)
                        FishingDRPlayerManager.Refresh(v)
                    end
                end)
                seq:OnForceKill(function()
                end)
            end
            FishingDRAnimManager.PlayDRFishDeadFX(self.FXNode, pos, fishobj, function ()
                for k,v in ipairs(data.fish.trigger) do
                    local fobj = FishingDRFishManager.Get(v)
                    -- local pos = FishingDRModel.Get2DToUIPoint(fobj.transform.position)
                    local endPos = FishingDRModel.Get2DToUIPoint(self.GunNodes[v].transform.position)
                    if not FishingDRModel.check_fish_is_dead(v) then 
                        FishingDRAnimManager.PlayToolSP(self.FXNode, nil, pos, endPos, nil, 1, function ()
                            cc(v)
                        end, "bydr_btn_xl",0.4,0.6)
                    end
                end                
            end)            
        end
        FishingDRFishManager.FishDead(data.fish.id,data.fish.reply_level)
        FishingDRPlayerManager.Refresh(data.fish.id)
        self:FlyItem(data.fish.id)
    end
end

-- 鱼逃离
function C:model_fish_flee_msg(data)
    -- dump(data, "<color=white>鱼逃离</color>")
    --待完成 游戏界面刷新，终点刷新，清除子弹，停止射击，炮台刷新
    if FishingDRModel.check_is_reset() then
        FishingDRFishManager.FishFlee(data.fish.fish_id)
        -- FishingDRGunManager.Remove(data.fish.fish_id)
        -- FishingDRBulletManager.RemoveByGunID(data.fish.fish_id)
        FishingDRModel.set_fish_sp(data.fish.fish_id)
        FishingDRPlayerManager.Refresh(data.fish.fish_id)
    else
        --正常流程
        FishingDRFishManager.FishFlee(data.fish.fish_id)
        -- FishingDRGunManager.Remove(data.fish.fish_id)
        -- FishingDRBulletManager.RemoveByGunID(data.fish.fish_id)
        FishingDRModel.set_fish_sp(data.fish.fish_id)
        FishingDRPlayerManager.Refresh(data.fish.fish_id)
        -- print("<color=yellow>鱼逃离</color>",data.fish.fish_id)
    end
end

-- 事件触发
function C:model_event_trigger_msg(data)
    dump(data, "<color=white>事件触发</color>")
    if data.id == 1 or data.id == 2 or data.id == 3 then
        print("<color=yellow>道具加倍</color>")
        FishingDRItemManager.Remove(data.index)
        local fish = FishingDRFishManager.Get(data.track_id)
        if fish then fish:CreateJB(data.id + 1) end
    elseif data.id == 4 then
        print("<color=yellow>道具减速</color>")
        FishingDRItemManager.Remove(data.index)
        local fish = FishingDRFishManager.Get(data.track_id)
        if fish then fish:CreateBing() end
        if FishingDRModel.check_is_reset() then
            
        else
            if fish and IsEquals(fish.transform) then
                 --正常流程 特效
                local pos = FishingDRModel.Get2DToUIPoint(fish.transform.position)
                FishingDRAnimManager.PlayShowAndHideFX(self.FXNode,"by_bs_jiansu_bing",pos,2)
            end
        end
    end
end

-- 事件触发失效
function C:model_event_trigger_end_msg(data)
    dump(data, "<color=white>事件触发结束</color>")
    if data.id == 1 or data.id == 2 or data.id == 3 then
        local fish = FishingDRFishManager.Get(data.track_id)
        if fish then fish:BackJB() end
    elseif data.id == 4 then
        print("<color=yellow>道具减速</color>")
        local fish = FishingDRFishManager.Get(data.track_id)
        if fish then fish:BackBing() end
    end
end
---------------------------------------------------------方法
function C.check_click(camera2d)
    -- 检测是否放在UI上
    local isPointDownOnUI
    local worldpos_up
    if gameRuntimePlatform == "WindowsEditor" or gameRuntimePlatform == "" then
        if UnityEngine.Input.GetMouseButtonDown(0) then

        end
        if EventSystem.current:IsPointerOverGameObject() and UnityEngine.Input.GetMouseButtonDown(0) then
            isPointDownOnUI = true
            return
        end
        if UnityEngine.Input.GetMouseButtonUp(0) then
            worldpos_up = UnityEngine.Input.mousePosition
            if isPointDownOnUI then
            end
        end

        if isPointDownOnUI and UnityEngine.Input.GetMouseButtonUp(0) then
            isPointDownOnUI = false
        end
    else
        if UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Began then

        end
        if UnityEngine.Input.touchCount > 0 and EventSystem.current:IsPointerOverGameObject(UnityEngine.Input.GetTouch(0).fingerId) and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Began then
            isPointDownOnUI = true
            return
        end

        if UnityEngine.Input.touchCount > 0 and UnityEngine.Input.GetTouch(0).phase == UnityEngine.TouchPhase.Ended then
            worldpos_up = Vector3.New(UnityEngine.Input.GetTouch(0).position.x, UnityEngine.Input.GetTouch(0).position.y, 0)
            if isPointDownOnUI then
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
    if worldpos then
        worldpos = camera2d:ScreenToWorldPoint(worldpos)
        local data = {}
        data.worldpos = worldpos
        Event.Brocast("game_click","game_click",data)
    end 
end

-- 场景准备
function C:SceneReady(is_anim)
    local py = FishingDRModel.Defines.WorldDimensionUnit.xMax - 9.6
    local pp = Vector3.New(-1 * py + 5.8, 0, 0)
    local pp2 = Vector3.New(-1 * py, 0, 0)
    if not is_anim then
        self.GunNode.transform.localPosition = pp

        self.FishAniNodeTran.gameObject:SetActive(true)
        self.FishAniNodeTran.transform.localPosition = pp

        self.LineNode.transform.localPosition = pp
        self.by_bg_Node_1.transform.localPosition = pp
        self.by_bg_Node_2.transform.localPosition = pp
        self.by_bg_Node_3.transform.localPosition = pp
    else
        FishingDRAnimManager.PlayComMove(self.GunNode, pp2, pp)

        self.FishAniNodeTran.gameObject:SetActive(true)
        FishingDRAnimManager.PlayComMove(self.FishAniNodeTran, pp2, pp)
        
        FishingDRAnimManager.PlayComMove(self.LineNode, pp2, pp)
        FishingDRAnimManager.PlayComMove(self.by_bg_Node_1, pp2, pp)
        FishingDRAnimManager.PlayComMove(self.by_bg_Node_2, pp2, pp)
        FishingDRAnimManager.PlayComMove(self.by_bg_Node_3, pp2, pp)
    end

    self.energy_node.gameObject:SetActive(false)
    self.gun_button_node.gameObject:SetActive(false)
    self.by_bg_Node_1_times.gameObject:SetActive(true)
end

-- 场景开始
function C:SceneStart(is_anim)
    local py = FishingDRModel.Defines.WorldDimensionUnit.xMax - 9.6
    local pp = Vector3.New(-1 * py + 5.8, 0, 0)
    local pp2 = Vector3.New(-1 * py, 0, 0)
    if not is_anim then
        self.GunNode.transform.localPosition = pp2

        self.FishAniNodeTran.gameObject:SetActive(false)
        self.FishAniNodeTran.transform.localPosition = pp2

        self.LineNode.transform.localPosition = pp2
        self.by_bg_Node_1.transform.localPosition = pp2
        self.by_bg_Node_2.transform.localPosition = pp2
        self.by_bg_Node_3.transform.localPosition = pp2
    else
        FishingDRAnimManager.PlayComMove(self.GunNode, pp, pp2)

        self.FishAniNodeTran.gameObject:SetActive(false)
        FishingDRAnimManager.PlayComMove(self.FishAniNodeTran, pp, pp2)
        
        FishingDRAnimManager.PlayComMove(self.LineNode, pp, pp2)
        FishingDRAnimManager.PlayComMove(self.by_bg_Node_1, pp, pp2)
        FishingDRAnimManager.PlayComMove(self.by_bg_Node_2, pp, pp2)
        FishingDRAnimManager.PlayComMove(self.by_bg_Node_3, pp, pp2)
    end

    self.energy_node.gameObject:SetActive(true)
    self.gun_button_node.gameObject:SetActive(true)
    self.by_bg_Node_1_times.gameObject:SetActive(false)
end

-- 场景炮台进入
function C:SceneGunEnter(is_anim)
    local py = FishingDRModel.Defines.WorldDimensionUnit.xMax - 9.6
    local pp = Vector3.New(-1 * py, 0, 0)
    local pp2 = Vector3.New(-7-1 * py, 0, 0)
    if not is_anim then
        self.zdx.transform.localPosition = Vector3.New(8, 0, 0)
        -- self.LineNode.gameObject:SetActive(true)
        self.GunNode.transform.localPosition = pp
        self.FishAniNodeTran.gameObject:SetActive(false)
        self.FishAniNodeTran.transform.localPosition = pp
    else
        -- self.LineNode.gameObject:SetActive(true)
        FishingDRAnimManager.PlayComMove(self.zdx, Vector3.New(12, 0, 0), Vector3.New(8, 0, 0))
        FishingDRAnimManager.PlayComMove(self.GunNode, pp2, pp)
        self.FishAniNodeTran.gameObject:SetActive(false)
        FishingDRAnimManager.PlayComMove(self.FishAniNodeTran, pp2, pp)
    end
end
-- 场景炮台退出
function C:SceneGunExit(is_anim)
    local py = FishingDRModel.Defines.WorldDimensionUnit.xMax - 9.6
    local pp = Vector3.New(-1 * py, 0, 0)
    local pp2 = Vector3.New(-7-1 * py, 0, 0)
    if not is_anim then
        if IsEquals(self.zdx) then
            self.zdx.transform.localPosition = Vector3.New(12, 0, 0)
        end
        -- self.LineNode.gameObject:SetActive(false)
        self.GunNode.transform.localPosition = pp2
        self.FishAniNodeTran.gameObject:SetActive(true)
        self.FishAniNodeTran.transform.localPosition = Vector3.New(-7-1 * py + 4.8, 0, 0) 
    else
        -- self.LineNode.gameObject:SetActive(false)
        FishingDRAnimManager.PlayComMove(self.zdx, Vector3.New(8, 0, 0), Vector3.New(12, 0, 0))
        FishingDRAnimManager.PlayComMove(self.GunNode, pp, pp2)
        self.FishAniNodeTran.gameObject:SetActive(true)
        FishingDRAnimManager.PlayComMove(self.FishAniNodeTran, pp, Vector3.New(-7-1 * py + 4.8, 0, 0))
    end
end

function C:OnJBBG()
    PayPanel.Create(GOODS_TYPE.jing_bi)
end

function C:OnBack()
    local callback = function(  )
        --Network.SendRequest("fishing_dr_quit_room", nil, "")
        GameManager.GotoUI({gotoui = "game_MiniGame"})
    end

    local a,b = GameButtonManager.RunFun({gotoui="cpl_ljyjcfk",callback = callback}, "CheckMiniGame")
    if a and b then
        return
    end

    callback()
end

function C.ManagerRemoveAll()
    FishingDRPlayerManager.RemoveAll()
    FishingDRGunManager.RemoveAll()
    FishingDRItemManager.RemoveAll()
    FishingDRFishManager.RemoveAll()
    FishingDRBulletManager.RemoveAll()
    FishingDRFishNetManager.RemoveAll()
end

function C:onGunClick(i)
    if FishingModel.data.energy_waiting then return end
    
    print("onGunClick"..i)
    if FishingModel.data.energy > 0 then
        if FishingDRModel.data.gun[i] and FishingDRModel.data.gun[i].is_energy == false then
            Network.SendRequest("fishing_dr_use_energy", {track_id = i}, "")
            FishingModel.data.energy_waiting = true
        end
    end
end

function C:RefreshEnergy()
    self.energy_txt.text = string.format("%d", FishingModel.data.energy)
end