local basefunc = require "Game.Common.basefunc"

MjXzFKGamePanel = basefunc.class()

MjXzFKGamePanel.name = "MjXzFKGamePanel3D"
local lister
local listerRegisterName = "MjXzFKFreeGameListerRegister"

local instance
function MjXzFKGamePanel.Create()
    instance = MjXzFKGamePanel.New()
    return createPanel(instance, MjXzFKGamePanel.name)
end
function MjXzFKGamePanel.Bind()
    local _in = instance
    instance = nil
    return _in
end

local timeStep = 1 -- update时间间隔
local updateDelayStep = 0.1
local touseziDelayTime = 1.3
function MjXzFKGamePanel:Awake()
    ------------------------------------------- add by wss
    --- 动态创建场景
    --[[if not self.majiang_fj then
        self.majiang_fj = GameObject.Instantiate( GetPrefab( "majiang_fj" ) , self.transform.parent.parent.parent )
        self.majiang_fj.name = "majiang_fj"
    end

    if not self.lights then
        self.lights = GameObject.Instantiate( GetPrefab( "Lights" ) , self.transform.parent.parent.parent )
        self.lights.name = "Lights"
    end--]]

    ---------------------------------------------
    self.scoreChangeDelayCount = 0.5

    ExtendSoundManager.PlaySceneBGM(audio_config.mj.majiang_bgm_game.audio_name)
    self.cardObj = GetPrefab("MjCard")
    local tran = self.transform
    self.CenterRect = tran:Find("CenterRect")
    self.ItemFXBG = tran:Find("CenterRect/ItemFXBG")

    self.PlayerDownRect = tran:Find("PlayerDownRect")
    self.PlayerRightRect = tran:Find("PlayerRightRect")
    self.PlayerTopRect = tran:Find("PlayerTopRect")
    self.PlayerLeftRect = tran:Find("PlayerLeftRect")
    self.CenterRect = tran:Find("CenterRect")

    --指示灯
    self.TagDong = tran:Find("CenterRect/ItemFXBG/TagDong")
    self.TagNan = tran:Find("CenterRect/ItemFXBG/TagNan")
    self.TagXi = tran:Find("CenterRect/ItemFXBG/TagXi")
    self.TagBei = tran:Find("CenterRect/ItemFXBG/TagBei")
    self.zhishideng = {}
    self.zhishideng[1] = self.TagDong
    self.zhishideng[2] = self.TagNan
    self.zhishideng[3] = self.TagXi
    self.zhishideng[4] = self.TagBei

    ------------------------------------------- add by wss
    self.BGImage = tran:Find("BGImage")
    self.LogoImage = tran:Find("LogoImage")

    self.deskCenterMgr = MjDeskCenterManager3D.Create()
    
    ---- 信号强弱
    self.isNetWap = true
    self.netWapIcon = tran:Find("TopLeftRect/Mj_net_wap_icon")
    self.netWapIconImage = self.netWapIcon:GetComponent("Image")
    self.netWapIcon.gameObject:SetActive(true)
    self.netWifiIcon = tran:Find("TopLeftRect/Mj_net_wifi_icon")
    self.netWifiIconImage = self.netWifiIcon:GetComponent("Image")
    self.netWifiIcon.gameObject:SetActive(false)
    self.netClose = tran:Find("TopLeftRect/Mj_net_close")
    self.netClose.gameObject:SetActive(false)
    --




    ------------------------

    --头像流光
    self.headLGNode = {}
    self.headLGNode[1] = tran:Find("PlayerDownRect/HeadRect/HeadLiuGuangNode")
    self.headLGNode[2] = tran:Find("PlayerRightRect/HeadRect/HeadLiuGuangNode")
    self.headLGNode[3] = tran:Find("PlayerTopRect/HeadRect/HeadLiuGuangNode")
    self.headLGNode[4] = tran:Find("PlayerLeftRect/HeadRect/HeadLiuGuangNode")

    self.headBGLG = {}
    self.headBGLG[1] = tran:Find("PlayerDownRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("Image")
    self.headBGLG[2] = tran:Find("PlayerRightRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("Image")
    self.headBGLG[3] = tran:Find("PlayerTopRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("Image")
    self.headBGLG[4] = tran:Find("PlayerLeftRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("Image")
    self.headBGLGTime = {}

    self.headBGLGCG = {}
    self.headBGLGCG[1] =
        tran:Find("PlayerDownRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("CanvasGroup")
    self.headBGLGCG[2] =
        tran:Find("PlayerRightRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("CanvasGroup")
    self.headBGLGCG[3] =
        tran:Find("PlayerTopRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("CanvasGroup")
    self.headBGLGCG[4] =
        tran:Find("PlayerLeftRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("CanvasGroup")
    self.headBGLGCGTime = {}

    --定缺 相关 ************
    self.DQRect = tran:Find("PlayerDownRect/DQRect")
    self.WanImage = tran:Find("PlayerDownRect/DQRect/WanImage"):GetComponent("Image")
    self.TongImage = tran:Find("PlayerDownRect/DQRect/TongImage"):GetComponent("Image")
    self.TiaoImage = tran:Find("PlayerDownRect/DQRect/TiaoImage"):GetComponent("Image")
    self.WanButton = tran:Find("PlayerDownRect/DQRect/WanImage"):GetComponent("Button")
    self.TongButton = tran:Find("PlayerDownRect/DQRect/TongImage"):GetComponent("Button")
    self.TiaoButton = tran:Find("PlayerDownRect/DQRect/TiaoImage"):GetComponent("Button")
    self.WanButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendDingque(3)
        end
    )
    self.TongButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendDingque(1)
        end
    )
    self.TiaoButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendDingque(2)
        end
    )
    
    self.ChatButton = tran:Find("ChatButton"):GetComponent("Button")
    self.ChatButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        SysInteractiveChatManager.Show()
    end)

    self.dingqueHint_d = tran:Find("PlayerDownRect/ItemDingQueHint")
    self.dingqueHint_r = tran:Find("PlayerRightRect/ItemDingQueHint")
    self.dingqueHint_t = tran:Find("PlayerTopRect/ItemDingQueHint")
    self.dingqueHint_l = tran:Find("PlayerLeftRect/ItemDingQueHint")
    self.dingqueHint = {}
    self.dingqueHint[1] = self.dingqueHint_d
    self.dingqueHint[2] = self.dingqueHint_r
    self.dingqueHint[3] = self.dingqueHint_t
    self.dingqueHint[4] = self.dingqueHint_l

    ------------------------- 换三张的显示 ↓↓↓↓↓ --------------------------
    self.huanSanZhangRect_d = tran:Find("PlayerDownRect/huanSanZhangRect")
    self.huanSanZhangRect_r = tran:Find("PlayerRightRect/huanSanZhangRect")
    self.huanSanZhangRect_t = tran:Find("PlayerTopRect/huanSanZhangRect")
    self.huanSanZhangRect_l = tran:Find("PlayerLeftRect/huanSanZhangRect")
    self.huanSanZhangRect = {}
    self.huanSanZhangRect[1] = self.huanSanZhangRect_d
    self.huanSanZhangRect[2] = self.huanSanZhangRect_r
    self.huanSanZhangRect[3] = self.huanSanZhangRect_t
    self.huanSanZhangRect[4] = self.huanSanZhangRect_l

    -- 换三张按钮
    self.huanSanZhangBtn = tran:Find("PlayerDownRect/huanSanZhangRect/huanPaiBtn"):GetComponent("Button")
    self.huanSanZhangBtn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if MjXzFKModel.data.huanSanZhangVec then
                if not self:SendHuanSanZhang(MjXzFKModel.data.huanSanZhangVec) then
                    MJAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
                end
            end

            MjXzFKModel.data.huanSanZhangVec = {}
            MjXzFKModel.clearHuanSanZhangData()

            self.huanSanZhangRect[1].gameObject:SetActive(false)
        end
    )

    self.nowSelectSanZhangText = tran:Find("PlayerDownRect/huanSanZhangRect/nowSelectSanZhangText"):GetComponent("Text")
    ------------------------ 换三张的显示 ↑↑↑↑↑ --------------------------

    self.dingqueWaitHint_d = tran:Find("PlayerDownRect/ItemDingQueHintWait")
    self.dingqueWaitHint_r = tran:Find("PlayerRightRect/ItemDingQueHintWait")
    self.dingqueWaitHint_t = tran:Find("PlayerTopRect/ItemDingQueHintWait")
    self.dingqueWaitHint_l = tran:Find("PlayerLeftRect/ItemDingQueHintWait")
    self.dingqueWaitHint = {}
    self.dingqueWaitHint[1] = self.dingqueWaitHint_d
    self.dingqueWaitHint[2] = self.dingqueWaitHint_r
    self.dingqueWaitHint[3] = self.dingqueWaitHint_t
    self.dingqueWaitHint[4] = self.dingqueWaitHint_l

    --定缺花色背景
    self.dingque_b_d = tran:Find("PlayerDownRect/HeadRect/DQIcon")
    self.dingque_b_r = tran:Find("PlayerRightRect/HeadRect/DQIcon")
    self.dingque_b_t = tran:Find("PlayerTopRect/HeadRect/DQIcon")
    self.dingque_b_l = tran:Find("PlayerLeftRect/HeadRect/DQIcon")
    self.dingque_b = {}
    self.dingque_b[1] = self.dingque_b_d
    self.dingque_b[2] = self.dingque_b_r
    self.dingque_b[3] = self.dingque_b_t
    self.dingque_b[4] = self.dingque_b_l
    --定缺花色
    self.dingque_c_d = tran:Find("PlayerDownRect/HeadRect/DQIcon/color"):GetComponent("Image")
    self.dingque_c_r = tran:Find("PlayerRightRect/HeadRect/DQIcon/color"):GetComponent("Image")
    self.dingque_c_t = tran:Find("PlayerTopRect/HeadRect/DQIcon/color"):GetComponent("Image")
    self.dingque_c_l = tran:Find("PlayerLeftRect/HeadRect/DQIcon/color"):GetComponent("Image")
    self.dingque_c = {}
    self.dingque_c[1] = self.dingque_c_d
    self.dingque_c[2] = self.dingque_c_r
    self.dingque_c[3] = self.dingque_c_t
    self.dingque_c[4] = self.dingque_c_l

    --定缺 相关 ************

    self.BeginButton = tran:Find("BeginButton")
    self.ShareButton = tran:Find("ShareButton")
    self.CopyButton = tran:Find("CopyButton")
    EventTriggerListener.Get(self.BeginButton.gameObject).onClick = basefunc.handler(self, self.OnBeginClick)
    EventTriggerListener.Get(self.ShareButton.gameObject).onClick = basefunc.handler(self, self.OnShareClick)
    EventTriggerListener.Get(self.CopyButton.gameObject).onClick = basefunc.handler(self, self.OnCopyClick)

    self.OperTimeTextL = tran:Find("CenterRect/TimeRect/OperTimeTextL"):GetComponent("Text")
    self.OperTimeTextR = tran:Find("CenterRect/TimeRect/OperTimeTextR"):GetComponent("Text")
    self.OperTimeTextRRed = tran:Find("CenterRect/TimeRect/OperTimeTextRRed"):GetComponent("Text")
    self.OperTimeTextLRed = tran:Find("CenterRect/TimeRect/OperTimeTextLRed"):GetComponent("Text")
    self.DFText = tran:Find("CenterRect/DFText"):GetComponent("Text")
    self.RoomIDText = tran:Find("CenterRect/RoomIDText"):GetComponent("Text")

    self.CardNumText = tran:Find("TopLeftRect/Mj_remain_bg/CardNumText"):GetComponent("Text")
    self.RateNumText = tran:Find("CenterRect/RateNumText"):GetComponent("Text")
    self.MenuButton = tran:Find("MenuButton"):GetComponent("Button")
    self.MenuBG = tran:Find("MenuButton/MenuBG")
    self.CloseImage = tran:Find("MenuButton/MenuBG/CloseButton"):GetComponent("Image")
    self.CloseButton = tran:Find("MenuButton/MenuBG/CloseButton"):GetComponent("Button")
    self.SetButton = tran:Find("MenuButton/MenuBG/SetButton"):GetComponent("Button")
    self.HelpButton = tran:Find("MenuButton/MenuBG/HelpButton"):GetComponent("Button")
    self.MenuButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            local b = not self.MenuBG.gameObject.activeSelf
            self.MenuBG.gameObject:SetActive(b)
            self.TopButtonImage.gameObject:SetActive(b)
        end
    )
    self.HelpButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            MjHelpPanel.Create("XZ")
        end
    )

    self.CloseButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
            if self:IsJSFun() then
                local m_data = MjXzFKModel.data
                -- 游戏中要发起投票
                if m_data and m_data.model_status == MjXzFKModel.Model_Status.gaming then
                    local hint =
                        HintPanel.Create(
                        2,
                        "是否要申请解散房间",
                        function()
                            --发起申请解散房间
                            Network.SendRequest("begin_vote_cancel_room")
                        end
                    )
                    hint:SetSmallHint("提示：游戏中途解散所有房卡不予退回")
                    hint:SetButtonText("否", "是")
                else
                    local hint =
                        HintPanel.Create(
                        2,
                        "是否要申请解散房间",
                        function()
                            --房主未开始解散游戏
                            self:OnExitClick()
                        end
                    )
                end
            else
                self:OnExitClick()
            end
        end
    )
    self.SetButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
        end
    )
    self.ChangeDeskButton = tran:Find("ChangeDeskButton"):GetComponent("Button")
    self.ChangeDeskButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if Network.SendRequest("nor_mj_xzdd_replay_game") then
                MjXzFKModel.ClearMatchData()
            else
                MJAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
            end
        end
    )
    self.RuleText = tran:Find("RuleRect/BG/RuleText"):GetComponent("Text")

    --玩家操作相关 **************
    self.OperRect = tran:Find("OperRect")
    self.PengButton = tran:Find("OperRect/PengImage"):GetComponent("Button")
    self.GangButton = tran:Find("OperRect/GangImage"):GetComponent("Button")
    self.HuButton = tran:Find("OperRect/HuImage"):GetComponent("Button")
    self.GuoButton = tran:Find("OperRect/GuoImage"):GetComponent("Button")

    self.PengButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendPengCB()
        end
    )
    self.GangButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendGangCB()
        end
    )
    self.HuButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendHuCB()
        end
    )
    self.GuoButton.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendGuoCB()
        end
    )

    --PFHG按钮位置
    self.PFHGpos = {}
    self.PFHGpos[1] = self.GuoButton.transform.localPosition
    self.PFHGpos[2] = self.PengButton.transform.localPosition
    self.PFHGpos[3] = self.GangButton.transform.localPosition
    self.PFHGpos[4] = self.HuButton.transform.localPosition

    --*******************

    -- 下 右 上 左
    self.Player = {}
    self.Player[1] = tran:Find("PlayerDownRect")
    self.Player[2] = tran:Find("PlayerRightRect")
    self.Player[3] = tran:Find("PlayerTopRect")
    self.Player[4] = tran:Find("PlayerLeftRect")

    self.PlayerClass = {}
    for i = 1, 4 do
        self.PlayerClass[i] = MjXzFKPlayerManger.Create(self.Player[i], i, self)
    end

    -- 出牌区域
    MjXzFKGamePanel.ChupaiMag = MjYiChuPaiManager3D.New(self.PlayerClass , MjXzFKModel)
    -- 碰杠区域
    MjXzFKGamePanel.PengGangMag = MjPgManager3D.New(self.PlayerClass , MjXzFKModel)

    self.countdown = nil
    self.updateTimer = Timer.New(basefunc.handler(self, self.UpdateCall), timeStep, -1, true)
    self.updateTimer:Start()

    self.updateDelay = Timer.New(basefunc.handler(self, self.UpdateDelayCall), updateDelayStep, -1, true)
    self.updateDelay:Start()

    self.TimeCallDict = {}

    self.SaiZiAnimNode = tran:Find("SaiZiAnimNode").gameObject

    --托管
    self.autoUI = {}
    self.autoUI[1] = tran:Find("PlayerDownRect/AutoRect").gameObject
    self.autoUI[2] = tran:Find("PlayerRightRect/AutoRect").gameObject
    self.autoUI[3] = tran:Find("PlayerTopRect/AutoRect").gameObject
    self.autoUI[4] = tran:Find("PlayerLeftRect/AutoRect").gameObject
    self.autoBtn = tran:Find("PlayerDownRect/AutoRect/CloseAutoBtn"):GetComponent("Button")
    self.autoBtn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if Network.SendRequest("nor_mj_xzdd_auto", {operate = 0}) then
                self.autoUI[1]:SetActive(false)
            else
                MJAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
            end
        end
    )
    self.TopButtonImage = tran:Find("TopButtonImage"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButtonImage.gameObject).onClick = basefunc.handler(self, self.SetHideMenu)
    self.TopButtonImage.gameObject:SetActive(false)

    -- 语音聊天按钮
    self.VoiceButton = tran:Find("VoiceButton")
    EventTriggerListener.Get(self.VoiceButton.gameObject).onDown = basefunc.handler(self, self.OnVoiceDown)
    EventTriggerListener.Get(self.VoiceButton.gameObject).onUp = basefunc.handler(self, self.OnVoiceUp)

    self.GPSButton = tran:Find("GPSButton"):GetComponent("Button")
    self.GPSHintImg = tran:Find("GPSButton/GPSHintImg"):GetComponent("Image")
    EventTriggerListener.Get(self.GPSButton.gameObject).onClick = basefunc.handler(self, self.OnClickGPSButton)
    self:MyInit()

    ----- add by wss
    -- 先隐藏掉一些背景图，把3D桌面漏出来
    self.BGImage.gameObject:SetActive(false)
    self.LogoImage.gameObject:SetActive(false)
    self.CenterRect.gameObject:SetActive(false)

    ------------------------- 主摄像机屏幕适配 -------------------------------- ↓↓
    self.mainCamera = GameObject.Find("MainCamera"):GetComponent("Camera")

    --[[local targetWidth = 1600
    local targetHeight = 900

    local nowHeight = 0
    if Screen.height / Screen.width > targetHeight / targetWidth then
        nowHeight = targetWidth / Screen.width * Screen.height
    else
        nowHeight = targetHeight
    end

    local scale = nowHeight / targetHeight

    self.mainCamera.fieldOfView = self.mainCamera.fieldOfView * scale--]]
    -------------------------------------------------------------------------------- ↑↑↑

    self:MyRefresh()
end

function MjXzFKGamePanel:OnPing(ping)
    local netIconImage = nil
    if LuaFramework.Util.NetAvailable then
        if LuaFramework.Util.IsWifi then
            if self.isNetWap then
                self.isNetWap = false
                self.netWapIcon.gameObject:SetActive(false)
                self.netWifiIcon.gameObject:SetActive(true)
            end
            netIconImage = self.netWifiIconImage
        else
            if not self.isNetWap then
                self.isNetWap = true

                self.netWapIcon.gameObject:SetActive(true)
                self.netWifiIcon.gameObject:SetActive(false)
            end
            netIconImage = self.netWapIconImage
        end

        self.netClose.gameObject:SetActive(false)
    else
        self.netClose.gameObject:SetActive(true)
    end
    
    local maxPing = 300
    local pingPercent = (maxPing - ping) < 0 and 0 or (maxPing - ping)
    pingPercent = pingPercent / maxPing

    if netIconImage then
        --print("<color=yellow> -------------- have netIconImage ".. pingPercent .. "-------------- </color>")

        if self.isNetWap then
            netIconImage.fillAmount = pingPercent
        else
   
        end

        if pingPercent > 0.75 then
            netIconImage.color = Color.New( 0,1,0,1 )
            if not self.isNetWap and self.wifiType ~= 4 then
                self.wifiType = 4
            end
        elseif pingPercent > 0.5 then
            netIconImage.color = Color.New( 1,1,0,1 )
            if not self.isNetWap and self.wifiType ~= 3 then
                self.wifiType = 3
            end
        elseif pingPercent > 0.25 then
            netIconImage.color = Color.New( 1,0.5,0,1 )
            if not self.isNetWap and self.wifiType ~= 2 then
                self.wifiType = 2
            end
        else
            netIconImage.color = Color.New( 1,0,0,1 )
            if not self.isNetWap and self.wifiType ~= 1 then
                self.wifiType = 1
            end
        end

        if not self.isNetWap then
            self.netWifiIconImage.sprite = GetTexture( string.format("ddz_wifi_icon%d",self.wifiType))
        end
    end

end


function MjXzFKGamePanel:OnClickGPSButton()
    MjXzFKModel.RefreshGPS(true)
end

function MjXzFKGamePanel:OnVoiceDown()
    self.begPos = UnityEngine.Input.mousePosition
    GameVoicePanel.RecordVoice()
end
function MjXzFKGamePanel:OnVoiceUp()
    local pos = UnityEngine.Input.mousePosition
    local x = pos.x - self.begPos.x
    local y = pos.y - self.begPos.y
    print("<color=red>语音 滑动距离 x = " .. x .. "  y = " .. y .. "</color>")
    if y < 20 then
        GameVoicePanel.FinishVoice()
    else
        GameVoicePanel.CancelVoice()
    end
end
function MjXzFKGamePanel:OnExitClick()
    Network.SendRequest(
        "friendgame_exit_room",
        nil,
        "请求退出",
        function(data)
            if data.result == 0 then
                --清除数据
                MjXzFKModel.ClearMatchData()
                MainLogic.ExitGame()
                MainLogic.GotoScene("game_Hall")
            else
                HintPanel.ErrorMsg(data.result)
            end
        end
    )
end
function MjXzFKGamePanel:OnBeginClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if MjXzFKModel.data.player_count == MjXzFKModel.GetCurrPlayerCount() then
        Network.SendRequest("friendgame_begin_game", nil, "请求开始游戏")
    else
        HintPanel.Create(1, "人数不足，不能开始游戏")
    end
end
function MjXzFKGamePanel:OnCopyClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    LittleTips.Create("已复制微信号请前往微信进行添加")
    UniClipboard.SetText(MjXzFKModel.data.friendgame_room_no)

    -- Network.SendRequest("query_gps_info",nil,"xx",function (data)
    --     dump(data,"xxx*****-------")
    -- end)
end
function MjXzFKGamePanel:OnShareClick()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local share_cfg = basefunc.deepcopy(share_link_config.url_mjfk)
    share_cfg.title = string.format(share_cfg.title, MjXzFKModel.data.friendgame_room_no)
    share_cfg.description = string.format(share_cfg.description, self.RuleText.text)
    share_cfg.url = string.format(share_cfg.title, MainLogic.GetPTDeeplinkKeyword(), MjXzFKModel.data.friendgame_room_no, MainModel.UserInfo.user_id)

    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "url",share_cfg = share_cfg})
end
function MjXzFKGamePanel:SetHideMenu()
    self.MenuBG.gameObject:SetActive(false)
    self.TopButtonImage.gameObject:SetActive(false)
end
function MjXzFKGamePanel:Start()
    -- self:MyRefresh()
end
-- 初始化
function MjXzFKGamePanel:MyInit()
    self:MakeLister()
    MjXzFKLogic.setViewMsgRegister(lister, listerRegisterName)
    math.randomseed(os.time() * 78415)
    -- Network.SendRequest("send_gps_info", {
    --     locations = "成都市",
    --     latitude = "10.12"..math.random(1,10),
    --     longitude = "11.11"..math.random(1,10),
    --     })
end

function MjXzFKGamePanel:showOrHideGameDesk(status)
    self.PlayerDownRect.gameObject:SetActive(status)
    self.PlayerRightRect.gameObject:SetActive(status)
    self.PlayerTopRect.gameObject:SetActive(status)
    self.PlayerLeftRect.gameObject:SetActive(status)
    --self.CenterRect.gameObject:SetActive(status)
end
function MjXzFKGamePanel:showOrHideZhishideng(pos, status)
    for i = 1, 4 do
        self.zhishideng[i].gameObject:SetActive(false)
        self.headLGNode[i].gameObject:SetActive(false)

        self.deskCenterMgr:showOrHideOneZhishideng(i , false)

        if self.headBGLGTime[i] then
            self.headBGLGTime[i]:Stop()
            self.headBGLGTime[i] = nil
        end
        if self.headBGLGCGTime[i] then
            self.headBGLGCGTime[i]:Kill()
            self.headBGLGCGTime[i] = nil
        end
    end
    if pos and pos > 0 and pos < 5 then
        self.zhishideng[pos].gameObject:SetActive(status)
        self.deskCenterMgr:showOrHideOneZhishideng(pos , true)

        self.headBGLGTime[pos],self.headBGLGCGTime[pos] = MjAnimation.HeadBG(self.headBGLG[pos], self.headBGLGCG[pos], self.countdown)
        self.headLGNode[pos].gameObject:SetActive(status)
    end
end
-- Update
function MjXzFKGamePanel:UpdateCall()
    local dt = timeStep
    if self.countdown and self.countdown > 0 then
        self.countdown = self.countdown - dt
    end
    for k, call in pairs(self.TimeCallDict) do
        call(self)
    end
end

function MjXzFKGamePanel:UpdateDelayCall()
    if self.scoreChangeDelay then
        self.scoreChangeDelay = self.scoreChangeDelay - updateDelayStep
        if self.scoreChangeDelay < 0 then
            self.scoreChangeDelay = 0
        end
    end


end


-- UI关注的事件
function MjXzFKGamePanel:MakeLister()
    lister = {}
    lister["model_nor_mj_xzdd_join_msg"] = basefunc.handler(self, self.nor_mj_xzdd_join_msg)
    lister["model_nor_mj_xzdd_exit_msg"] = basefunc.handler(self, self.nor_mj_xzdd_exit_msg)
    lister["model_nor_mj_xzdd_pai_msg"] = basefunc.handler(self, self.nor_mj_xzdd_pai_msg)
    lister["model_nor_mj_xzdd_tou_sezi_msg"] = basefunc.handler(self, self.nor_mj_xzdd_tou_sezi_msg)
    lister["model_nor_mj_xzdd_action_msg"] = basefunc.handler(self, self.nor_mj_xzdd_action_msg)
    lister["model_nor_mj_xzdd_permit_msg"] = basefunc.handler(self, self.nor_mj_xzdd_permit_msg)
    lister["model_nor_mj_xzdd_dingque_result_msg"] = basefunc.handler(self, self.nor_mj_xzdd_dingque_result_msg)
    lister["model_nor_mj_xzdd_auto_msg"] = basefunc.handler(self, self.nor_mj_xzdd_auto_msg)
    lister["model_nor_mj_xzdd_ready_msg"] = basefunc.handler(self, self.model_nor_mj_xzdd_ready_msg)
    lister["model_nor_mj_xzdd_begin_msg"] = basefunc.handler(self, self.model_nor_mj_xzdd_begin_msg)
    lister["model_friendgame_net_quality"] = basefunc.handler(self, self.model_friendgame_net_quality)
    lister["model_friendgame_gameover_msg_com"]=basefunc.handler(self,self.friendgame_gameover_msg_com)

    lister["model_nor_mj_xzdd_huansanzhang_msg"]=basefunc.handler(self,self.model_nor_mj_xzdd_huansanzhang_msg)
    lister["model_nor_mj_xzdd_huan_pai_finish_msg"]=basefunc.handler(self,self.model_nor_mj_xzdd_huan_pai_finish_msg)
    
    lister["model_huanSanZhang_num_change_msg"]=basefunc.handler(self,self.model_huanSanZhang_num_change_msg)
    

    lister["ping"] = basefunc.handler(self,self.OnPing) 

    lister["model_nor_mj_xzdd_settlement_msg"] = basefunc.handler(self, self.nor_mj_xzdd_settlement_msg)
    lister["model_friendgame_gameover_msg"] = basefunc.handler(self, self.friendgame_gameover_msg)

    lister["model_nor_mj_xzdd_grades_change_msg"] = basefunc.handler(self, self.nor_mj_xzdd_grades_change_msg)
    lister["model_nor_mj_xzdd_dingque_response"] = basefunc.handler(self, self.nor_mj_xzdd_dingque)

    lister["model_begin_vote_cancel_room_response"] = basefunc.handler(self, self.model_begin_vote_cancel_room_response)
    lister["model_player_vote_cancel_room_response"] =
        basefunc.handler(self, self.model_player_vote_cancel_room_response)
    lister["model_friendgame_begin_vote_cancel_room_msg"] =
        basefunc.handler(self, self.model_friendgame_begin_vote_cancel_room_msg)
    lister["model_friendgame_over_vote_cancel_room_msg"] =
        basefunc.handler(self, self.model_friendgame_over_vote_cancel_room_msg)

    --gps
    lister["model_query_gps_info_msg"] = basefunc.handler(self, self.model_query_gps_info_msg)
end

function MjXzFKGamePanel:set_erRen_about()
    -----
    if MjXzFKModel.game_type and MjXzFKModel.checkIsEr() and not self.isSetEr then
        self.isSetEr = true
        print("<color=yellow>-------------- 调整已出牌的位置<color>")
        --- 一行改成放8个
        MjXzFKGamePanel.ChupaiMag:setMaxLine(8) 

        MjXzFKGamePanel.ChupaiMag:addChuPaiPosOffsetX( -0.4 )

    end

    if MjXzFKModel.game_type and not self.isSetShouPai then
        self.isSetShouPai = true
        for i = 1, #self.PlayerClass do
            local playerInfo = MjXzFKModel.GetPosToPlayer(i)
            if playerInfo then
                self.PlayerClass[i]:adjustShouPaiPos()
            end
        end 
    end

end

-- 发起投票
function MjXzFKGamePanel:model_begin_vote_cancel_room_response()
    -- RoomCardDissolve.Create(parm)
end

-- 玩家投票返回
function MjXzFKGamePanel:model_player_vote_cancel_room_response()
end

-- 投票开始
function MjXzFKGamePanel:model_friendgame_begin_vote_cancel_room_msg()
    if MjXzFKModel.data and MjXzFKModel.data.vote_parm then
        RoomCardDissolve.Create(MjXzFKModel.data.cur_race, MjXzFKModel.data.room_rent, MjXzFKModel.data.vote_data.begin_player_id, MjXzFKModel.data.vote_parm)
    end
end

-- 投票结束
function MjXzFKGamePanel:model_friendgame_over_vote_cancel_room_msg()
    RoomCardDissolve.MyExit()
    local data = MjXzFKModel.data
    if data then
        if data.vote_result then
            if data.vote_result == 0 then
                HintPanel.Create(1, "该次投票已通过，房间已解散")
            elseif data.vate_data == 1 then
                HintPanel.Create(1, "该次投票未通过，无法解散房间")
            elseif data.vate_data == 2 then
                HintPanel.Create(1, "投票已取消")
            end
        end
    end
end

--gps
function MjXzFKGamePanel:model_query_gps_info_msg(isTrustDistance)
    self.GPSHintImg.gameObject:SetActive(isTrustDistance)
end

function MjXzFKGamePanel:RefreshVoteStatus()
    --根据状态显示和隐藏面板
    RoomCardDissolve.MyExit()
    if MjXzFKModel.data and MjXzFKModel.data.vote_data and MjXzFKModel.data.vote_parm then
        local parm = MjXzFKModel.data.vote_parm
        RoomCardDissolve.Create(MjXzFKModel.data.cur_race, MjXzFKModel.data.room_rent, MjXzFKModel.data.vote_data.begin_player_id, parm)
    end
end

--刷新房间是否退出
function MjXzFKGamePanel:RefreshRoomDissolveStatus()
    if MjXzFKModel.data and MjXzFKModel.data.room_dissolve and MjXzFKModel.data.room_dissolve ~= 0 then
        if not (MjXzFKModel.data.status == MjXzFKModel.Status.settlement and MjXzFKModel.data.settlement_info) then
            if not (MjXzFKModel.data.model_status == MjXzFKModel.Model_Status.gameover or
                MjXzFKModel.data.status == MjXzFKModel.Status.gameover) then
        HintPanel.Create(
            1,
            "房间已经解散",
            function()
                MjXzFKModel.ClearMatchData()
                MainLogic.ExitGame()
                MainLogic.GotoScene("game_Hall")
            end
        )
            end
        end
    end
end

-- 操作倒计时
local function OperTime(self)
    if self.countdown and self.countdown >= 0 then
        self.OperTimeTextR.gameObject:SetActive(self.countdown > 5)
        self.OperTimeTextRRed.gameObject:SetActive(self.countdown <= 5)
        self.OperTimeTextL.gameObject:SetActive(self.countdown > 5)
        self.OperTimeTextLRed.gameObject:SetActive(self.countdown <= 5)
        local t1 = math.floor(self.countdown / 10)
        local t2 = self.countdown % 10
        self.OperTimeTextL.text = "" .. t1
        self.OperTimeTextLRed.text = "" .. t1
        self.OperTimeTextR.text = "" .. t2
        self.OperTimeTextRRed.text = "" .. t2

        self.deskCenterMgr:set3DOperTimeTexOffset( math.ceil(self.countdown) )
    else
        self.TimeCallDict["OperTime"] = nil
    end
end

-- 刷新UI
function MjXzFKGamePanel:MyRefresh()
    local m_data = MjXzFKModel.data
    if m_data then
        --- 桌面ui
        if not self.isSetMjDeskUi then
            self.isSetMjDeskUi = true
            if m_data.init_stake then
                self.deskCenterMgr:setBaseScore(m_data.init_stake)
            else
                self.isSetMjDeskUi = false
            end

            --- 设置局数
            --[[if m_data.cur_race and m_data.race_count then
                self.deskCenterMgr:setRaceNum(m_data.cur_race , m_data.race_count)
            else
                self.isSetMjDeskUi = false
            end--]]

            if m_data.friendgame_room_no then
                self.deskCenterMgr:setRoomNum(m_data.friendgame_room_no)
            else
                self.isSetMjDeskUi = false
            end

            self.deskCenterMgr:setMjTypeDeskUi("mj_game_imgf_xz")
        end

        self:set_erRen_about()

        print("<color=yellow>---------------------------- fk majiang , m_data.model_status:</color>", (m_data.model_status or "nil"))
        if not m_data.model_status then

        elseif m_data.model_status == MjXzFKModel.Model_Status.wait_begin then
            self:RefreshMenu()
            self:RefreshPlayer()
            self:RefreshCenter()
            self:refreshReaceNum()
        else
            

            self.last_action_msg = nil
            self:showOrHideGameDesk(true)

            self:RefreshPlayer()
            self:RefreshMenu()
            -- 这个一定要在  RefreshCenter 之前  ↓↓
            self.deskCenterMgr:refreshZhuangjiaZhishideng( MjXzFKModel )  
            self:RefreshCenter()
            self.deskCenterMgr:refreshRemainCard( MjXzFKModel )
            
	        self:RefreshHuanSanZhang()
            if MjXzFKModel.data.status == MjXzFKModel.Status.ready then
                self.deskCenterMgr:showOrHideAllReaminCard(false)
            end
            
            self:RefreshClearing()
            self:refreshReaceNum()
            -- self:RefreshGameOver()
            self:RefreshDingqueStatus()
            self:RefreshAutoStatus()
            self:RefreshVoteStatus()
            self:RefreshRoomDissolveStatus()

            --- 这个放最后
            self:RefreshPermit()

            self:RefreshTouSezi()
        end
    end
end

function MjXzFKGamePanel:RefreshTouSezi()
    local m_data = MjXzFKModel.data
    if not m_data or not m_data.status or not m_data.countdown or m_data.status ~= MjXzFKModel.Status.tou_sezi then
        return

    end

    local passTime = self.deskCenterMgr.touseziAcTime - m_data.countdown

    if passTime < touseziDelayTime then
        MjAnimation.DelayTimeAction(function()
            self.deskCenterMgr:testShaiziAnimation(MjXzFKModel , 0 )
        end , passTime)
    else
        self.deskCenterMgr:testShaiziAnimation(MjXzFKModel , passTime - touseziDelayTime )
    end
    

end 


function MjXzFKGamePanel:refreshReaceNum()
    if MjXzFKModel.data.cur_race and MjXzFKModel.data.race_count then
        self.deskCenterMgr:setRaceNum(MjXzFKModel.data.cur_race , MjXzFKModel.data.race_count)
    end
end

-- 是否是房主或者游戏中
function MjXzFKGamePanel:IsJSFun()
    local m_data = MjXzFKModel.data
    if m_data and m_data.playerInfo and m_data.playerInfo[m_data.seat_num] and
            (MjXzFKModel.IsFZ(m_data.seat_num) or m_data.model_status == MjXzFKModel.Model_Status.gaming)
     then
        return true
    end
end
-- 刷新游戏左上角UI 包括顶部规则说明
function MjXzFKGamePanel:RefreshMenu()
    if self:IsJSFun() then
        self.CloseImage.sprite = GetTexture("com_btn_back3")
    else
        self.CloseImage.sprite = GetTexture("com_btn_back")
    end
    local m_data = MjXzFKModel.data
    if m_data and m_data.ori_game_cfg then
        local list = {}
        for k, v in ipairs(m_data.ori_game_cfg) do
            local d = {}
            d.key = v.option
            d.sort = RoomCardModel.UIConfig.ruleNameMap[v.option].sort
            list[#list + 1] = d
        end
        list = MathExtend.SortList(list, "sort", true)
        local ss = ""
        for k, v in ipairs(list) do
            ss = ss .. " " .. RoomCardModel.UIConfig.ruleNameMap[v.key].name
        end
        self.RuleText.text = ss
    else
        self.RuleText.text = "游戏规则显示"
    end
end

-- 刷新游戏玩家
function MjXzFKGamePanel:RefreshPlayer(seatno)
    local m_data = MjXzFKModel.data
    if seatno then
        local uiPos = MjXzFKModel.GetSeatnoToPos(seatno)
        self.PlayerClass[uiPos]:Refresh()
    else
        for i = 1, #self.PlayerClass do
            if m_data.playerInfo and i <= #m_data.playerInfo and m_data.playerInfo[i] then
                local uiPos = MjXzFKModel.GetSeatnoToPos(i)
                self.PlayerClass[uiPos]:Refresh()
            end
        end
    end
end

-- 刷新游戏结算界面
function MjXzFKGamePanel:RefreshClearing()
    if MjXzFKModel.data.status == MjXzFKModel.Status.settlement and MjXzFKModel.data.settlement_info then
        MjXzFKClearing.Create(self.transform)
    else
        MjXzFKClearing.Close()
    end
    self:RefreshGameOver()
end

-- 刷新游戏总结算界面
function MjXzFKGamePanel:RefreshGameOver()
    if MjXzFKModel.data.model_status == MjXzFKModel.Model_Status.gameover or
            MjXzFKModel.data.status == MjXzFKModel.Status.gameover then
        RoomCardGameOver.Create(
            self.transform,
            MjXzFKModel.data.gameover_info,
            MjXzFKModel.data.playerInfo,
            "MJ",
            MjXzFKModel.data.room_owner,
            function()
                MjXzFKModel.ClearMatchData()
            end
        )
    else
        RoomCardGameOver.Close()
    end
end

-- 刷新中间区域(方位)
function MjXzFKGamePanel:RefreshCenter()
    self.OperTimeTextL.text = ""
    self.OperTimeTextR.text = ""
    self.OperTimeTextRRed.text = ""
    self.OperTimeTextLRed.text = ""
    self.CardNumText.text = ""
    self.RateNumText.text = ""

    local data = MjXzFKModel.data
    if data then
        ----- 只有第一局的时候会设置按钮的显示
        if data.cur_race == 1 then
            if data.model_status == MjXzFKModel.Model_Status.wait_begin then
                if GameGlobalOnOff.InviteFriends then
                    self.ShareButton.gameObject:SetActive(true)
                    if not MjXzFKModel.IsFZ(data.seat_num) then
                        self.ShareButton.transform.localPosition = Vector3.New(0,self.ShareButton.transform.localPosition.y, 0)
                    end
                else
                    self.ShareButton.gameObject:SetActive(false)
                end
            else
                self.ShareButton.gameObject:SetActive(false)
            end
            if data.model_status == MjXzFKModel.Model_Status.wait_begin and MjXzFKModel.IsFZ(data.seat_num) then
                print("<color=yellow>------------------ self.BeginButton true: </color>", data.seat_num ,  data.room_owner)
                self.BeginButton.gameObject:SetActive(true)
                self.CopyButton.gameObject:SetActive(true)
                if not GameGlobalOnOff.InviteFriends then
                    self.CopyButton.transform.localPosition = Vector3.New(0,self.CopyButton.transform.localPosition.y, 0)
                end
            else
                self.BeginButton.gameObject:SetActive(false)
                self.CopyButton.gameObject:SetActive(false)
            end
        else
            self.ShareButton.gameObject:SetActive(false)
            self.BeginButton.gameObject:SetActive(false)
            self.CopyButton.gameObject:SetActive(false)
        end



        if data.init_stake then
            self.DFText.text = "底分：" .. data.init_stake
        else
            self.DFText.text = "底分：--"
        end
        if data.friendgame_room_no then
            self.RoomIDText.text = "房号：" .. data.friendgame_room_no
        end
        if MjXzFKModel.data.countdown then
            self.countdown = math.floor(MjXzFKModel.data.countdown)
        else
            self.countdown = 0
        end
        --self.CenterRect.gameObject:SetActive(true)
        if data.cur_p and data.cur_p > 0 then
            self:showOrHideZhishideng(MjXzFKModel.GetSeatnoToPos(data.cur_p), true)
        else
            if data.zjSeatno and data.zjSeatno ~= 0 then
                self:showOrHideZhishideng(MjXzFKModel.GetSeatnoToPos(data.zjSeatno),true)
            else
                self:showOrHideZhishideng(-1,false)
            end

            --[[for i = 1, 4 do
                self.zhishideng[i].gameObject:SetActive(false)
                self.headLGNode[i].gameObject:SetActive(false)
                if self.headBGLGTime[i] then
                    self.headBGLGTime[i]:Stop()
                    self.headBGLGTime[i] = nil
                end
                if self.headBGLGCGTime[i] then
                    self.headBGLGCGTime[i]:Kill()
                    self.headBGLGCGTime[i] = nil
                end
            end--]]

            self.CardNumText.text = ""
            self.RateNumText.text = ""
        end
        self.TimeCallDict["OperTime"] = OperTime
        OperTime(self)

        self:SetRemainCard()
        self:SetRate()
    end
end
function MjXzFKGamePanel:SetRemainCard()
    self.CardNumText.text = MjXzFKModel.GetRemainCard()
    if MjXzFKModel.GetRemainCard() == 4 then
        MjAnimation.ShowLast4Pai(Vector3.New(0, -300, 0), Vector3.New(0, 0, 0))
    end
end
function MjXzFKGamePanel:SetRate()
    if MjXzFKModel.data.cur_race and MjXzFKModel.data.race_count then
        self.RateNumText.text = MjXzFKModel.data.cur_race .. "/" .. MjXzFKModel.data.race_count
    else
        dump(MjXzFKModel.data.cur_race)
        dump(MjXzFKModel.data.race_count)
        self.RateNumText.text = "-/-"
    end
end
function MjXzFKGamePanel:MyExit()
    DOTweenManager.CloseAllSequence()
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()

    if self.updateTimer then
        self.updateTimer:Stop()
        self.updateTimer = nil
    end
    if self.updateDelay then
        self.updateDelay:Stop()
        self.updateDelay=nil
    end
    self.cardObj = nil

    for i = 1, 4 do
        self.PlayerClass[i]:MyExit()

        if self.headBGLGTime[i] then
            self.headBGLGTime[i]:Stop()
            self.headBGLGTime[i] = nil
        end
        if self.headBGLGCGTime[i] then
            self.headBGLGCGTime[i]:Kill()
            self.headBGLGCGTime[i] = nil
        end
    end
    MjXzFKLogic.clearViewMsgRegister(listerRegisterName)

    MjXzFKClearing.Close()
    RoomCardGameOver.Close()
    GPSPanel.Close()

    --[[if self.majiang_fj then
        GameObject.Destroy( self.majiang_fj.gameObject )
        self.majiang_fj = nil
    end

    if self.lights then
        GameObject.Destroy( self.lights.gameObject )
        self.lights = nil
    end--]]

    self.deskCenterMgr:MyExit()
    MjXzFKGamePanel.ChupaiMag:MyExit()
    MjXzFKGamePanel.PengGangMag:MyExit()

    --closePanel(MjXzFKGamePanel.name)
end
function MjXzFKGamePanel:MyClose()
    self:MyExit()
    closePanel(MjXzFKGamePanel.name)
end
--[[***********************
UI关注的消息
***********************--]]
-- 玩家进入
function MjXzFKGamePanel:nor_mj_xzdd_join_msg(seatno)
    local uiPos = MjXzFKModel.GetSeatnoToPos(seatno)
    self.PlayerClass[uiPos]:PlayerEnter()
end
-- 玩家退出
function MjXzFKGamePanel:nor_mj_xzdd_exit_msg(seatno)
    local uiPos = MjXzFKModel.GetSeatnoToPos(seatno)
    self.PlayerClass[uiPos]:PlayerExit()
end

-- 发牌（开始游戏）
function MjXzFKGamePanel:nor_mj_xzdd_pai_msg()
    -- 自己的UI位置
    for i = 1, #self.PlayerClass do
        self.PlayerClass[i]:PlayerFapai()
    end
    self:RefreshMenu()
    self:RefreshCenter()

    self.deskCenterMgr:refreshRemainCard( MjXzFKModel , true )
end
-- 选庄 todo nmg
function MjXzFKGamePanel:nor_mj_xzdd_tou_sezi_msg()
    local function tsz()
        -- 动画
        --self:PlaySaiZi(MjXzFKModel.data.sezi_value1, MjXzFKModel.data.sezi_value2)
        self:SetRemainCard()
        self:SetRate()
    end
    --显示开局动画
    MJParticleManager.MJKaiJu(tsz)

    ----
    self.deskCenterMgr:refreshZhuangjiaZhishideng(MjXzFKModel)
    
    local uiPos = MjXzFKModel.GetSeatnoToPos (MjXzFKModel.data.zjSeatno)
    self.PlayerClass[uiPos]:SetZJ(true)


    --- 投色子的时候做麻将出牌口的降低&升起
    --- 延迟做动作...
    MjAnimation.DelayTimeAction(function() 
        self.deskCenterMgr:cardDoorAnimation(MjXzFKModel)
        --print("<color=yellow> !!!!! do  cardDoorAnimation </color>")
    end , 0.2)

    ----- 投骰子
    MjAnimation.DelayTimeAction(function() 
        self.deskCenterMgr:testShaiziAnimation(MjXzFKModel)
        ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_castdice.audio_name)
    end , touseziDelayTime )

    --- 显示庄家位置
    self:showOrHideZhishideng(MjXzFKModel.GetSeatnoToPos( MjXzFKModel.data.zjSeatno ),true)

end
--检测action msg是否已经执行
function MjXzFKGamePanel:check_action_isrun(data)
    if data.type ~= "cp" or MjXzFKModel.GetSeatnoToPos(data.p) ~= 1 then
        return false
    end
    if data.from == "client" then
        self.last_action_msg = data
        return false
    end
    if not self.last_action_msg then
        return false
    end
    --检查是否操作是否相同
    if data.pai == self.last_action_msg.pai then
        self.last_action_msg = nil
        return true
    else
        --不合法   客户端回滚之前出的牌 以服务器为准
        local seatno = MjXzFKModel.GetSeatnoToPos(data.p)
        self.PlayerClass[seatno]:BackChupai()
        self.last_action_msg = nil
        return false
    end
end
-- 操作
function MjXzFKGamePanel:nor_mj_xzdd_action_msg(data)
    if self:check_action_isrun(data) then
        return
    end

    self:ShowOrHideOperRect(false)
    
    MjXzFKGangsRect.Close()
    local uiPos = MjXzFKModel.GetSeatnoToPos(data.p)
    self.PlayerClass[uiPos]:Action(data)
end

function MjXzFKGamePanel:ShowOrHideOperRect(status)
    self.OperRect.gameObject:SetActive(status)
end

function MjXzFKGamePanel:Permit()
    if MjXzFKModel.data then
        local my_s = MjXzFKModel.data.seat_num
        local pgh_data = MjXzFKModel.data.pgh_data
        self:ShowOrHideOperRect(false)

        if MjXzFKModel.data.status == MjXzFKModel.Status.ding_que then
            --刷新定缺状态
            self:RefreshDingqueStatus()
        elseif MjXzFKModel.data.status == MjXzFKModel.Status.huan_san_zhang then
            -- 
            self:RefreshHuanSanZhang()
        else
            if MjXzFKModel.data.status == MjXzFKModel.Status.mo_pai then
                local seatno = MjXzFKModel.GetSeatnoToPos(MjXzFKModel.data.cur_p)
                self.PlayerClass[seatno]:MopaiPermit(MjXzFKModel.data.cur_mopai)

                self.PlayerClass[1]:hideAllHint()
            end
            if
                MjXzFKModel.data.status == MjXzFKModel.Status.chu_pai or
                    MjXzFKModel.data.status == MjXzFKModel.Status.start
             then
                local seatno = MjXzFKModel.GetSeatnoToPos(MjXzFKModel.data.cur_p)
                self.PlayerClass[seatno]:ChupaiPermit()
            end

            --我自己
            if MjXzFKModel.data.cur_p == MjXzFKModel.data.seat_num then
                if pgh_data then
                    self:ShowOrHideOperRect(true)
                    local pos = 1
                    if pgh_data.guo then
                        self.GuoButton.gameObject:SetActive(true)
                        pos = pos + 1
                    else
                        self.GuoButton.gameObject:SetActive(false)
                    end
                    if pgh_data.peng then
                        self.PengButton.gameObject:SetActive(true)
                        self.PengButton.transform.localPosition = self.PFHGpos[pos]
                        pos = pos + 1

                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showPengHint( pgh_data.peng )
                    else
                        self.PengButton.gameObject:SetActive(false)
                    end
                    if pgh_data.gang then
                        self.GangButton.gameObject:SetActive(true)
                        self.GangButton.transform.localPosition = self.PFHGpos[pos]
                        pos = pos + 1

                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showGangHint( pgh_data.gang )
                    else
                        self.GangButton.gameObject:SetActive(false)
                    end
                    if pgh_data.hu then
                        self.HuButton.gameObject:SetActive(true)
                        self.HuButton.transform.localPosition = self.PFHGpos[pos]

                        self.PlayerClass[1]:showAllHint( )
                    else
                        self.HuButton.gameObject:SetActive(false)
                    end
                end
            end
        end
    end
    self:RefreshCenter()
    print("<color=yellow>------------------------------ Permit refreshRemainCard ------------------ </color>")
    self.deskCenterMgr:refreshRemainCard(MjXzFKModel)
end

function MjXzFKGamePanel:RefreshPermit()
    if MjXzFKModel.data then
        local my_s = MjXzFKModel.data.seat_num
        local pgh_data = MjXzFKModel.data.pgh_data
        self:ShowOrHideOperRect(false)

        if MjXzFKModel.data.status == MjXzFKModel.Status.ding_que then
            --刷新定缺状态
            self:RefreshDingqueStatus()
        else
            if MjXzFKModel.data.status == MjXzFKModel.Status.mo_pai then
                local seatno = MjXzFKModel.GetSeatnoToPos(MjXzFKModel.data.cur_p)
                self.PlayerClass[seatno]:RefreshMopaiPermit(MjXzFKModel.data.cur_mopai)
            end
            if
                MjXzFKModel.data.status == MjXzFKModel.Status.chu_pai or
                    MjXzFKModel.data.status == MjXzFKModel.Status.start
             then
                local seatno = MjXzFKModel.GetSeatnoToPos(MjXzFKModel.data.cur_p)
                self.PlayerClass[seatno]:RefreshChupaiPermit()
            end

            --我自己
            if MjXzFKModel.data.cur_p == MjXzFKModel.data.seat_num then
                if pgh_data then
                    self:ShowOrHideOperRect(true)
                    local pos = 1
                    if pgh_data.guo then
                        self.GuoButton.gameObject:SetActive(true)
                        pos = pos + 1
                    else
                        self.GuoButton.gameObject:SetActive(false)
                    end
                    if pgh_data.peng then
                        self.PengButton.gameObject:SetActive(true)
                        self.PengButton.transform.localPosition = self.PFHGpos[pos]
                        pos = pos + 1

                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showPengHint( pgh_data.peng )
                    else
                        self.PengButton.gameObject:SetActive(false)
                    end
                    if pgh_data.gang then
                        self.GangButton.gameObject:SetActive(true)
                        self.GangButton.transform.localPosition = self.PFHGpos[pos]
                        pos = pos + 1

                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showGangHint( pgh_data.gang )
                    else
                        self.GangButton.gameObject:SetActive(false)
                    end
                    if pgh_data.hu then
                        self.HuButton.gameObject:SetActive(true)
                        self.HuButton.transform.localPosition = self.PFHGpos[pos]

                        self.PlayerClass[1]:showAllHint( )
                    else
                        self.HuButton.gameObject:SetActive(false)
                    end
                end
            end
        end
    end
end
-- 权限
function MjXzFKGamePanel:nor_mj_xzdd_permit_msg()
    if MjXzFKModel.data.cur_p == 0 then
        print("<color=red>权限拥有者是0</color>")
    end
    self:Permit()
end
-- 代表全部隐藏
function MjXzFKGamePanel:RefreshDingqueHint(pos, status)
    -- print("RefreshDingqueHint == " .. pos .. "  " .. status)
    --我自己
    if pos == 1 then
        if status == 0 then
            -- self.dingqueHint[pos].transform:Find("dingqueHintTxt"):GetComponent("Text").text = "等待其他玩家定缺"
            self.DQRect.gameObject:SetActive(false)
            self:HideDQParticle()
            self.dingqueHint[pos].gameObject:SetActive(false)
            self.dingqueWaitHint[pos].gameObject:SetActive(true)
        elseif status == -1 then
            self.dingqueHint[pos].gameObject:SetActive(false)
            self.dingqueWaitHint[pos].gameObject:SetActive(false)
            self.DQRect.gameObject:SetActive(true)
            local playerData = MjXzFKModel.GetPosToPlayer(1)
            local tong, tiao, wan = normal_majiang.ding_que(playerData.spList)
            if tong then
                self.tongTJTween = MjAnimation.TJColor(self.TongImage.transform)
            end

            if tiao then
                self.tiaoTJTween = MjAnimation.TJColor(self.TiaoImage.transform)
            end

            if wan then
                self.wanTJTween = MjAnimation.TJColor(self.WanImage.transform)
            end
        else
            self.DQRect.gameObject:SetActive(false)
            self:HideDQParticle()
            self.dingqueHint[pos].gameObject:SetActive(false)
            self.dingqueWaitHint[pos].gameObject:SetActive(false)
            self:RefreshDingqueColor(pos, status)
        end
    else
        if status == -1 then
            -- self.dingqueHint[pos].transform:Find("dingqueHintTxt"):GetComponent("Text").text = "定缺中"
            self.dingqueHint[pos].gameObject:SetActive(true)
            self.dingqueWaitHint[pos].gameObject:SetActive(false)
        elseif status == 0 then
            -- self.dingqueHint[pos].transform:Find("dingqueHintTxt"):GetComponent("Text").text = "等待其他玩家定缺"
            self.dingqueHint[pos].gameObject:SetActive(false)
            self.dingqueWaitHint[pos].gameObject:SetActive(true)
        else
            self.dingqueHint[pos].gameObject:SetActive(false)
            self.dingqueWaitHint[pos].gameObject:SetActive(false)
            self:RefreshDingqueColor(pos, status)
        end
    end
end
local huase_image = {"mj_game_imgf_tong", "mj_game_imgf_tiao", "mj_game_imgf_wan"}
function MjXzFKGamePanel:RefreshDingqueColor(pos, status)
    if status and status > 0 and status < 4 then
        self.dingque_b[pos].gameObject:SetActive(true)
        --   切换定缺 color
        self.dingque_c[pos].sprite = GetTexture(huase_image[status])
    else
        self.dingque_b[pos].gameObject:SetActive(false)
    end
end

function MjXzFKGamePanel:RefreshDingqueStatus()
    local status = MjXzFKModel.data.status
    local playerInfo = MjXzFKModel.data.playerInfo
    if status and playerInfo then
        for i = 1, 4 do
            local pos = MjXzFKModel.GetSeatnoToPos(i)
            self:RefreshDingqueHint(pos, playerInfo[i].lackColor)
        end
    else
        --全部隐藏
        for i = 1, 4 do
            self:RefreshDingqueHint(i, -2)
        end
    end
end

function MjXzFKGamePanel:RefreshHuanSanZhang()
    self.PlayerClass[1]:hideAllHint()
    self.PlayerClass[1].ShouPai:showAllMask()
    print("<color=yellow>--------------- MjXzFKGamePanel , RefreshHuanSanZhang </color>")
    local m_data = MjXzFKModel.data
    local status = m_data.status
    if status ~= MjXzFKModel.Status.huan_san_zhang then
        for k,v in ipairs(self.huanSanZhangRect) do
            v.gameObject:SetActive(false)
        end
        self.PlayerClass[1]:setShouPaiActionModel( "normal" )
        return
    end

    --- 界面显示
    for k,v in ipairs(self.huanSanZhangRect) do
        v.gameObject:SetActive(true)
    end

    if MjXzFKModel.data.isHuanPai then
        self.huanSanZhangRect[1].gameObject:SetActive(false)
    else
         --- 
        self.PlayerClass[1]:setShouPaiActionModel( "huanSanZhang" )

        if m_data.huanSanZhangVec then
            self.PlayerClass[1]:refreshHuanSanZhangPai(m_data.huanSanZhangVec)
            self.nowSelectSanZhangText.text = string.format( "%d" ,3 - #MjXzFKModel.data.huanSanZhangVec ) 
        end
    end

   

end

function MjXzFKGamePanel:HideDQParticle()
    MjAnimation.TJColorOnKill(self.tongTJTween, self.TongImage.transform)
    MjAnimation.TJColorOnKill(self.tiaoTJTween, self.TiaoImage.transform)
    MjAnimation.TJColorOnKill(self.wanTJTween, self.WanImage.transform)

    self.tongTJTween = nil
    self.tiaoTJTween = nil
    self.wanTJTween = nil
end

function MjXzFKGamePanel:ClearTJ()
    MjAnimation.TJColorOnKill(self.tongTJTween, self.TongImage.transform)
    MjAnimation.TJColorOnKill(self.tiaoTJTween, self.TiaoImage.transform)
    MjAnimation.TJColorOnKill(self.wanTJTween, self.WanImage.transform)

    self.tongTJTween = nil
    self.tiaoTJTween = nil
    self.wanTJTween = nil
end

-- 定缺返回
function MjXzFKGamePanel:nor_mj_xzdd_dingque()
    print("定缺返回")
end

function MjXzFKGamePanel:nor_mj_xzdd_dingque_result_msg()
    self:RefreshDingqueStatus()
    --定缺动画 将花色飞过去
    for i = 1, 4 do
        MjAnimation.DQIcon(self.dingque_b[i])
    end
    --清除定缺特效
    self:ClearTJ()
    local playerInfo = MjXzFKModel.data.playerInfo
    for i = 1, 4 do
        local pos = MjXzFKModel.GetSeatnoToPos(i)
        self.PlayerClass[pos]:Dingque({pai = playerInfo[i].lackColor})
    end
end

--托管
function MjXzFKGamePanel:nor_mj_xzdd_auto_msg(pSeatNum)
    self:RefreshAutoStatus(pSeatNum)
end

--准备
function MjXzFKGamePanel:model_nor_mj_xzdd_ready_msg(pSeatNum)
    self:RefreshCenter()
    self:RefreshPlayer(pSeatNum)
    --self.deskCenterMgr:refreshRemainCard( MjXzFKModel )

    self:refreshReaceNum()

    self.deskCenterMgr:showOrHideAllReaminCard(false)
end

-- 离线状态变化
function MjXzFKGamePanel:model_friendgame_net_quality(pSeatNum)
    local uiPos = MjXzFKModel.GetSeatnoToPos(pSeatNum)
    self.PlayerClass[uiPos]:SetDX()
end

--开始游戏
function MjXzFKGamePanel:model_nor_mj_xzdd_begin_msg()
    self:RefreshCenter()
    self:RefreshPlayer()
    --self.deskCenterMgr:refreshRemainCard( MjXzFKModel )

    self:refreshReaceNum()

    self.deskCenterMgr:showOrHideAllReaminCard(false)
end

-- 结算
function MjXzFKGamePanel:nor_mj_xzdd_settlement_msg(pSeatNum)
    --- 移除掉手牌的回调函数
    self.PlayerClass[1].ShouPai:removeShouPaiCallBack()

    --- 指针位置还原
    MjXzFKGamePanel.ChupaiMag:restoreMjHint()

    self:RefreshClearing()
end

-- 总结算
function MjXzFKGamePanel:friendgame_gameover_msg(pSeatNum)
    self:RefreshGameOver()
end

function MjXzFKGamePanel:friendgame_gameover_msg_com()
    MjXzFKClearing.SetGameOver()
end

function MjXzFKGamePanel:model_nor_mj_xzdd_huansanzhang_msg()
    if MjXzFKModel.data and MjXzFKModel.data.huanSanZhangNewVec then
        self.PlayerClass[1].ShouPai:huanPai( MjXzFKModel.data.huanSanZhangNewVec , MjXzFKModel.data.playerInfo[MjXzFKModel.data.seat_num].spList )
    end

end

function MjXzFKGamePanel:model_nor_mj_xzdd_huan_pai_finish_msg()
    self:RefreshHuanSanZhang()
    MjXzFKModel.clearHuanSanZhangData()
end

function MjXzFKGamePanel:model_huanSanZhang_num_change_msg()
    self.nowSelectSanZhangText.text = string.format( "%d" , 3-#MjXzFKModel.data.huanSanZhangVec ) 
end

function MjXzFKGamePanel:RefreshAutoStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if MjXzFKModel.data then
        --刷新全部
        if not pSeatNum then
            --刷新单个人
            if MjXzFKModel.data.playerInfo then
                for i = 1, 4 do
                    local auto = MjXzFKModel.data.playerInfo[i].auto
                    local uiPos = MjXzFKModel.GetSeatnoToPos(i)
                    if auto then
                        if auto == 1 then
                            --显示
                            self.autoUI[uiPos].gameObject:SetActive(true)
                            self.PlayerClass[1]:hideAllHint()
                        else
                            --隐藏
                            self.autoUI[uiPos].gameObject:SetActive(false)
                        end
                    else
                        --隐藏
                        self.autoUI[uiPos].gameObject:SetActive(false)
                    end
                end
            end
        else
            if MjXzFKModel.data.playerInfo then
                local auto = MjXzFKModel.data.playerInfo[pSeatNum].auto
                local uiPos = MjXzFKModel.GetSeatnoToPos(pSeatNum)
                if auto then
                    if auto == 1 then
                        --显示
                        self.autoUI[uiPos].gameObject:SetActive(true)
                        self.PlayerClass[1]:hideAllHint()
                    else
                        --隐藏
                        self.autoUI[uiPos].gameObject:SetActive(false)
                    end
                else
                    --隐藏
                    self.autoUI[uiPos].gameObject:SetActive(false)
                end
            end
        end
    end
end

-- 分数改变
function MjXzFKGamePanel:nor_mj_xzdd_grades_change_msg(data)
    print("<color=red>钱变化 nor_mj_xzdd_grades_change_msg</color>")
    if MjXzFKModel.data and MjXzFKModel.data.moneyChange then
        self.scoreChangeDelay = self.scoreChangeDelay or 0
        for i, v in ipairs(MjXzFKModel.data.moneyChange) do
            --local seatno = MjXzFKModel.GetSeatnoToPos(v.cur_p)
            --self.PlayerClass[seatno]:ChangeMoney(v.score)
            local uipos = v.cur_p
            local score = v.score
            MjAnimation.DelayTimeAction(function() 
                local seatno = MjXzFKModel.GetSeatnoToPos(uipos)
                self.PlayerClass[seatno]:ChangeMoney(score)
            end , self.scoreChangeDelay)
        end
        self.scoreChangeDelay = self.scoreChangeDelay + self.scoreChangeDelayCount
    end
end

-- 刷新当前的牌
function MjXzFKGamePanel:S2CMoPai()
    if MjXzFKModel.data and MjXzFKModel.data.currCard and MjXzFKModel.data.cur_p then
        local paiData = MjXzFKModel.data.currCard
        local seatData = MjXzFKModel.data.cur_p
        if paiData then
            local uiPos = MjXzFKModel.GetSeatnoToPos(seatData)
            self.PlayerClass[uiPos]:AddZPPai(paiData)
        else
        end
    end
end

--发送数据***********************
function MjXzFKGamePanel:SendAction(data)
    table.print("<color=blue>sendAction:</color>", data)
    if Network.SendRequest("nor_mj_xzdd_operator", data) then
        return true
    else
        MJAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
        return false
    end
end
function MjXzFKGamePanel:SendDingque(val)
    self:HideDQParticle()
    if self:SendAction({type = "dq", pai = val}) then
        --刷新我的定缺状态 （将 定缺按钮隐藏 状态改变为 等待其他玩家定缺）
        self:RefreshDingqueHint(1, 0)
    end
end

function MjXzFKGamePanel:SendPengCB()
    local pgh_data = MjXzFKModel.data.pgh_data
    local peng
    if pgh_data then
        peng = pgh_data.peng
    end
    if not peng then
    --没有出牌权限
    end
    local act = {type = "peng", pai = peng.pai}
    if self:SendAction(act) then
        --按钮隐藏
        self:ShowOrHideOperRect(false)
    end
end
function MjXzFKGamePanel:SendGangCB(act)
    local pgh_data = MjXzFKModel.data.pgh_data
    local gang
    if pgh_data then
        gang = pgh_data.gang
    end
    if not gang then
    --没有出牌权限
        return
    end
    if #gang > 1 then
        --展示提示
        MjXzFKGangsRect.Create(
            self.gameObject,
            gang,
            function(act)
                self:SendGang(act)
            end
        )
    else
        local act = {type = "gang", pai = gang[1].pai}
        self:SendGang(act)
    end
end
function MjXzFKGamePanel:SendGang(act)
    if self:SendAction(act) then
        if act.type == "gang" then
            self.PlayerClass[1]:SetSendCP()
        end
        --按钮隐藏
        self:ShowOrHideOperRect(false)
    end
end

function MjXzFKGamePanel:SendHuCB(val)
    local pgh_data = MjXzFKModel.data.pgh_data
    local hu
    if pgh_data then
        hu = pgh_data.hu
    end
    if not hu then
        --没有胡牌权限
    else
        if self:SendAction({type = "hu"}) then
            --按钮隐藏
            self:ShowOrHideOperRect(false)
        end
    end
end
function MjXzFKGamePanel:SendGuoCB()
    if self:SendAction({type = "guo"}) then
        --按钮隐藏
        self:ShowOrHideOperRect(false)

        self.PlayerClass[1]:hideAllHint()
    end
end

function MjXzFKGamePanel:SendHuanSanZhang(paiVec)
    local data = { paiVec = paiVec }
    


    if Network.SendRequest("nor_mj_xzdd_huansanzhang", data) then
        MjXzFKModel.data.isCanOpPai = false
        return true
    else
        return false
    end
end

--发送数据***********************

-- 播放骰子动画
function MjXzFKGamePanel:PlaySaiZi(val1, val2)
    if not val1 or not val2 then
        print("<color=red>骰子点数为空</color>")
        return
    end
    ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_castdice.audio_name)
    self.SaiZiAnimNode:SetActive(true)
    local SZNode = self.SaiZiAnimNode.transform:Find("SZNode")
    local Node = self.SaiZiAnimNode.transform:Find("Node")
    local SaiZi1 = self.SaiZiAnimNode.transform:Find("Node/SaiZi1"):GetComponent("Image")
    local SaiZi2 = self.SaiZiAnimNode.transform:Find("Node/SaiZi2"):GetComponent("Image")
    SZNode.gameObject:SetActive(true)
    Node.gameObject:SetActive(false)

    SaiZi1.sprite = GetTexture("shaizi" .. val1)
    SaiZi2.sprite = GetTexture("shaizi" .. val2)

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToStop(seq)
    seq:AppendInterval(1)
    seq:AppendCallback(
        function()
            SZNode.gameObject:SetActive(false)
            Node.gameObject:SetActive(true)
        end
    )
    seq:AppendInterval(2)
    seq:OnKill(
        function()
            DOTweenManager.RemoveStopTween(tweenKey)
            self:StopSaiZi()
            -- 设置庄家
            local uiPos = MjXzFKModel.GetSeatnoToPos(MjXzFKModel.data.zjSeatno)
            self.PlayerClass[uiPos]:SetZJ(true)
        end
    )
end
-- 暂停骰子动画
function MjXzFKGamePanel:StopSaiZi()
    self.SaiZiAnimNode:SetActive(false)
end
