local basefunc = require "Game.Common.basefunc"

MjXlGamePanel = basefunc.class()

MjXlGamePanel.name = "MjXlGamePanel3D"
local lister
local listerRegisterName="mjXlFreeGameListerRegister"

local instance
function MjXlGamePanel.Create()
    instance = MjXlGamePanel.New()
    return createPanel(instance, MjXlGamePanel.name)
end
function MjXlGamePanel.Bind()
    local _in=instance
    instance=nil
    return _in
end

local timeStep = 1 -- update时间间隔
local updateDelayStep = 0.1
local touseziDelayTime = 1.3
function MjXlGamePanel:Awake()
    --- 动态创建场景
    --[[if not self.majiang_fj then
        self.majiang_fj = GameObject.Instantiate( GetPrefab( "majiang_fj" ) , self.transform.parent.parent.parent )
        self.majiang_fj.name = "majiang_fj"
    end
    if not self.lights then
        self.lights = GameObject.Instantiate( GetPrefab( "Lights" ) , self.transform.parent.parent.parent )
        self.lights.name = "Lights"
    end--]]
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
    self.zhishideng={}
    self.zhishideng[1]=self.TagDong
    self.zhishideng[2]=self.TagNan
    self.zhishideng[3]=self.TagXi
    self.zhishideng[4]=self.TagBei

    ------------------------------------------- add by wss
    self.BGImage = tran:Find("BGImage")
    self.LogoImage = tran:Find("LogoImage")
    self.hud = tran:Find("hud")
    self.hupai_hint = tran:Find("PlayerDownRect/hupai_hint")

    self.deskCenterMgr = MjDeskCenterManager3D.Create()
    
    ---- 信号强弱
    self.isNetWap = true
    self.netWapIcon = tran:Find("hud/TopLeftRect/Mj_net_wap_icon")
    self.netWapIconImage = self.netWapIcon:GetComponent("Image")
    self.netWapIcon.gameObject:SetActive(true)
    self.netWifiIcon = tran:Find("hud/TopLeftRect/Mj_net_wifi_icon")
    self.netWifiIconImage = self.netWifiIcon:GetComponent("Image")
    self.netWifiIcon.gameObject:SetActive(false)
    self.netClose = tran:Find("hud/TopLeftRect/Mj_net_close")
    self.netClose.gameObject:SetActive(false)
    --

    ------------------------
    --头像流光
    self.headLGNode={}
    self.headLGNode[1]= tran:Find("PlayerDownRect/HeadRect/HeadLiuGuangNode")
    self.headLGNode[2]= tran:Find("PlayerRightRect/HeadRect/HeadLiuGuangNode")
    self.headLGNode[3]= tran:Find("PlayerTopRect/HeadRect/HeadLiuGuangNode")
    self.headLGNode[4]= tran:Find("PlayerLeftRect/HeadRect/HeadLiuGuangNode")

    self.headBGLG={}
    self.headBGLG[1]= tran:Find("PlayerDownRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("Image")
    self.headBGLG[2]= tran:Find("PlayerRightRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("Image")
    self.headBGLG[3]= tran:Find("PlayerTopRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("Image")
    self.headBGLG[4]= tran:Find("PlayerLeftRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("Image")
    self.headBGLGTime = {}

    self.headBGLGCG={}
    self.headBGLGCG[1]= tran:Find("PlayerDownRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("CanvasGroup")
    self.headBGLGCG[2]= tran:Find("PlayerRightRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("CanvasGroup")
    self.headBGLGCG[3]= tran:Find("PlayerTopRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("CanvasGroup")
    self.headBGLGCG[4]= tran:Find("PlayerLeftRect/HeadRect/HeadLiuGuangNode/ParticleHeadLiuGuang"):GetComponent("CanvasGroup")
    self.headBGLGCGTime = {}


    --定缺 相关 ************
    self.DQRect=tran:Find("PlayerDownRect/DQRect")
    self.WanImage = tran:Find("PlayerDownRect/DQRect/WanImage"):GetComponent("Image")
    self.TongImage = tran:Find("PlayerDownRect/DQRect/TongImage"):GetComponent("Image")
    self.TiaoImage = tran:Find("PlayerDownRect/DQRect/TiaoImage"):GetComponent("Image")
    self.WanButton = tran:Find("PlayerDownRect/DQRect/WanImage"):GetComponent("Button")
    self.TongButton = tran:Find("PlayerDownRect/DQRect/TongImage"):GetComponent("Button")
    self.TiaoButton = tran:Find("PlayerDownRect/DQRect/TiaoImage"):GetComponent("Button")
    self.WanButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:SendDingque(3)
    end)
    self.TongButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:SendDingque(1)
    end)
    self.TiaoButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:SendDingque(2)
    end)

    self.ChatButton = tran:Find("hud/ChatButton"):GetComponent("Button")
    self.ChatButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if MjXlModel.data.model_status == MjXlModel.Model_Status.gaming then
            SysInteractiveChatManager.Show()
        end
    end)
    self.ChatButton.gameObject:SetActive(false)

    self.dingqueHint_d = tran:Find("PlayerDownRect/ItemDingQueHint")
    self.dingqueHint_r = tran:Find("PlayerRightRect/ItemDingQueHint")
    self.dingqueHint_t = tran:Find("PlayerTopRect/ItemDingQueHint")
    self.dingqueHint_l = tran:Find("PlayerLeftRect/ItemDingQueHint")
    self.dingqueHint = {}
    self.dingqueHint[1] = self.dingqueHint_d
    self.dingqueHint[2] = self.dingqueHint_r
    self.dingqueHint[3] = self.dingqueHint_t
    self.dingqueHint[4] = self.dingqueHint_l

    self.dingqueWaitHint_d = tran:Find("PlayerDownRect/ItemDingQueHintWait")
    self.dingqueWaitHint_r = tran:Find("PlayerRightRect/ItemDingQueHintWait")
    self.dingqueWaitHint_t = tran:Find("PlayerTopRect/ItemDingQueHintWait")
    self.dingqueWaitHint_l = tran:Find("PlayerLeftRect/ItemDingQueHintWait")
    self.dingqueWaitHint = {}
    self.dingqueWaitHint[1] = self.dingqueWaitHint_d
    self.dingqueWaitHint[2] = self.dingqueWaitHint_r
    self.dingqueWaitHint[3] = self.dingqueWaitHint_t
    self.dingqueWaitHint[4] = self.dingqueWaitHint_l

    ----------------------------- 打漂的ui ↓↓↓----------------------------------------
    self.DaPiaoRect=tran:Find("PlayerDownRect/DaPiaoRect")

    self.dapiaoHint_d = tran:Find("PlayerDownRect/ItemDaPiaoHint")
    self.dapiaoHint_r = tran:Find("PlayerRightRect/ItemDaPiaoHint")
    self.dapiaoHint_t = tran:Find("PlayerTopRect/ItemDaPiaoHint")
    self.dapiaoHint_l = tran:Find("PlayerLeftRect/ItemDaPiaoHint")
    self.dapiaoHint = {}
    self.dapiaoHint[1] = self.dapiaoHint_d
    self.dapiaoHint[2] = self.dapiaoHint_r
    self.dapiaoHint[3] = self.dapiaoHint_t
    self.dapiaoHint[4] = self.dapiaoHint_l

    self.dapiaoWaitHint_d = tran:Find("PlayerDownRect/ItemDaPiaoHintWait")
    self.dapiaoWaitHint_r = tran:Find("PlayerRightRect/ItemDaPiaoHintWait")
    self.dapiaoWaitHint_t = tran:Find("PlayerTopRect/ItemDaPiaoHintWait")
    self.dapiaoWaitHint_l = tran:Find("PlayerLeftRect/ItemDaPiaoHintWait")
    self.dapiaoWaitHint = {}
    self.dapiaoWaitHint[1] = self.dapiaoWaitHint_d
    self.dapiaoWaitHint[2] = self.dapiaoWaitHint_r
    self.dapiaoWaitHint[3] = self.dapiaoWaitHint_t
    self.dapiaoWaitHint[4] = self.dapiaoWaitHint_l

    self.dapiaoIcon_d = tran:Find("PlayerDownRect/HeadRect/piaoIcon"):GetComponent("Image")
    self.dapiaoIcon_r = tran:Find("PlayerRightRect/HeadRect/piaoIcon"):GetComponent("Image")
    self.dapiaoIcon_t = tran:Find("PlayerTopRect/HeadRect/piaoIcon"):GetComponent("Image")
    self.dapiaoIcon_l = tran:Find("PlayerLeftRect/HeadRect/piaoIcon"):GetComponent("Image")
    self.dapiaoIcon = {}
    self.dapiaoIcon[1]=self.dapiaoIcon_d
    self.dapiaoIcon[2]=self.dapiaoIcon_r
    self.dapiaoIcon[3]=self.dapiaoIcon_t
    self.dapiaoIcon[4]=self.dapiaoIcon_l

    self.DaPiaoButton1 = tran:Find("PlayerDownRect/DaPiaoRect/Panel/PiaoImage1"):GetComponent("Button")
    self.DaPiaoButton2 = tran:Find("PlayerDownRect/DaPiaoRect/Panel/PiaoImage2"):GetComponent("Button")
    self.DaPiaoButton3 = tran:Find("PlayerDownRect/DaPiaoRect/Panel/PiaoImage3"):GetComponent("Button")
    self.DaPiaoButton4 = tran:Find("PlayerDownRect/DaPiaoRect/Panel/PiaoImage4"):GetComponent("Button")

    self.buPiaoButton = tran:Find("PlayerDownRect/DaPiaoRect/selectPanel/buPiaoBtnBg"):GetComponent("Button")
    self.jiaPiaoButton = tran:Find("PlayerDownRect/DaPiaoRect/selectPanel/piaoBtnBg"):GetComponent("Button")

    self.DaPiaoButton1.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:SendDaPiao(0)
        self.DaPiaoRect.gameObject:SetActive(false)
    end)

    self.DaPiaoButton2.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:SendDaPiao(1)
        self.DaPiaoRect.gameObject:SetActive(false)
    end)

    self.DaPiaoButton3.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:SendDaPiao(3)
        self.DaPiaoRect.gameObject:SetActive(false)
    end)

    self.DaPiaoButton4.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:SendDaPiao(5)
        self.DaPiaoRect.gameObject:SetActive(false)
    end)

    self.buPiaoButton.onClick:AddListener(function ()
        --ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)

        self:SendDaPiao(0)
        self.DaPiaoRect.gameObject:SetActive(false)
    end)

    self.jiaPiaoButton.onClick:AddListener(function ()
        --ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)

        self:SendDaPiao(1)
        self.DaPiaoRect.gameObject:SetActive(false)
    end)

    ---- 打漂的上浮动画的位置
    self.dapiaoPosObjVec = {}
    self.dapiaoPosObjVec[1] = tran:Find("PlayerDownRect/HandImage")
    self.dapiaoPosObjVec[2] = tran:Find("PlayerRightRect/HandImage")
    self.dapiaoPosObjVec[3] = tran:Find("PlayerTopRect/HandImage")
    self.dapiaoPosObjVec[4] = tran:Find("PlayerLeftRect/HandImage")

    ----------------------------- 打漂的ui ↑↑↑----------------------------------------

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
            if MjXlModel.data.huanSanZhangVec then
                if not self:SendHuanSanZhang(MjXlModel.data.huanSanZhangVec) then
                    MJAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
                end
            end

            MjXlModel.data.huanSanZhangVec = {}
            MjXlModel.clearHuanSanZhangData()

            self.huanSanZhangRect[1].gameObject:SetActive(false)
        end
    )

    self.nowSelectSanZhangText = tran:Find("PlayerDownRect/huanSanZhangRect/nowSelectSanZhangText"):GetComponent("Text")
    self.huanPaiCd = tran:Find("PlayerDownRect/huanSanZhangRect/huanPaiBtn/huanPaiCd"):GetComponent("Text")
    ------------------------ 换三张的显示 ↑↑↑↑↑ --------------------------

    --定缺花色背景
    self.dingque_b_d = tran:Find("PlayerDownRect/HeadRect/DQIcon")
    self.dingque_b_r = tran:Find("PlayerRightRect/HeadRect/DQIcon")
    self.dingque_b_t = tran:Find("PlayerTopRect/HeadRect/DQIcon")
    self.dingque_b_l = tran:Find("PlayerLeftRect/HeadRect/DQIcon")
    self.dingque_b = {}
    self.dingque_b[1]=self.dingque_b_d
    self.dingque_b[2]=self.dingque_b_r
    self.dingque_b[3]=self.dingque_b_t
    self.dingque_b[4]=self.dingque_b_l
     --定缺花色
    self.dingque_c_d = tran:Find("PlayerDownRect/HeadRect/DQIcon/color"):GetComponent("Image")
    self.dingque_c_r = tran:Find("PlayerRightRect/HeadRect/DQIcon/color"):GetComponent("Image")
    self.dingque_c_t = tran:Find("PlayerTopRect/HeadRect/DQIcon/color"):GetComponent("Image")
    self.dingque_c_l = tran:Find("PlayerLeftRect/HeadRect/DQIcon/color"):GetComponent("Image")
    self.dingque_c = {}
    self.dingque_c[1]=self.dingque_c_d
    self.dingque_c[2]=self.dingque_c_r
    self.dingque_c[3]=self.dingque_c_t
    self.dingque_c[4]=self.dingque_c_l

   --定缺 相关 ************

   self.Changedesk = tran:Find("Changedesk")
   self.ChangedeskButton = tran:Find("Changedesk/ChangedeskButton"):GetComponent("Button")
   self.ChangedeskNo = tran:Find("Changedesk/ChangedeskNo")
   self.ChangedeskHintText = tran:Find("Changedesk/ChangedeskNo/ChangedeskHintText"):GetComponent("Text")
   self.ChangedeskButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        MjXlModel.HZCheck()
    end)


    self.PairdeskClass = MjXlPairdesk.Create(tran:Find("PairdeskRect"))

    self.OperTimeTextL = tran:Find("CenterRect/TimeRect/OperTimeTextL"):GetComponent("Text")
    self.OperTimeTextR = tran:Find("CenterRect/TimeRect/OperTimeTextR"):GetComponent("Text")
    self.OperTimeTextRRed = tran:Find("CenterRect/TimeRect/OperTimeTextRRed"):GetComponent("Text")
    self.OperTimeTextLRed = tran:Find("CenterRect/TimeRect/OperTimeTextLRed"):GetComponent("Text")
    self.DFText = tran:Find("CenterRect/DFText"):GetComponent("Text")

    self.CardNumText = tran:Find("hud/TopLeftRect/Mj_remain_bg/CardNumText"):GetComponent("Text")
    self.RateNumText = tran:Find("CenterRect/RateNumText"):GetComponent("Text")
    self.MenuButton = tran:Find("hud/MenuButton"):GetComponent("Button")
    self.MenuBG = tran:Find("hud/MenuButton/MenuBG")
    self.CloseButton = tran:Find("hud/MenuButton/MenuBG/CloseButton"):GetComponent("Button")
    self.SetButton = tran:Find("hud/MenuButton/MenuBG/SetButton"):GetComponent("Button")
    self.MenuButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        local b = not self.MenuBG.gameObject.activeSelf
        self.MenuBG.gameObject:SetActive(b)
        self.TopButtonImage.gameObject:SetActive(b)
    end)
    self.HelpButton = tran:Find("hud/MenuButton/MenuBG/HelpButton"):GetComponent("Button")
    self.HelpButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if MjXlModel.game_type == MjXlLogic.game_type.nor_mj_xzdd_er_7 or MjXlModel.game_type == MjXlLogic.game_type.nor_mj_xzdd_er_13 then
            MjHelpPanel.Create("ER")
        else
            MjHelpPanel.Create("XZ")
        end
    end)
    
    self.CloseButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        if not MjXlModel.data.hu_data_map[MjXlModel.data.seat_num] and MjXlModel.data.model_status == MjXlModel.Model_Status.gaming then
            if Network.SendRequest("fg_quit_game") then
            else
                MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
            end
        else
            local callback = function(  )
                if Network.SendRequest("fg_quit_game") then
                else
                    MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
                end
            end
            GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
        end
    end)
    self.SetButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
    end)
    --[[self.ChangeDeskButton = tran:Find("ChangeDeskButton"):GetComponent("Button")
    self.ChangeDeskButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if Network.SendRequest("fg_replay_game") then
            MjXlModel.ClearMatchData()
        else
            MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
        end
    end)--]]


    --玩家操作相关 **************
    self.OperRect = tran:Find("OperRect")
    self.PengButton = tran:Find("OperRect/PengImage"):GetComponent("Button")
    self.GangButton = tran:Find("OperRect/GangImage"):GetComponent("Button")
    self.HuButton = tran:Find("OperRect/HuImage"):GetComponent("Button")
    self.GuoButton = tran:Find("OperRect/GuoImage"):GetComponent("Button")

    self.PengButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendPengCB()
        end)
    self.GangButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendGangCB()
        end)
    self.HuButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendHuCB()
        end)
    self.GuoButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:SendGuoCB()
        end)

    --PFHG按钮位置
    self.PFHGpos={}
    self.PFHGpos[1]=self.GuoButton.transform.localPosition
    self.PFHGpos[2]=self.PengButton.transform.localPosition
    self.PFHGpos[3]=self.GangButton.transform.localPosition
    self.PFHGpos[4]=self.HuButton.transform.localPosition

    --*******************


    -- 下 右 上 左
    self.Player = {}
    self.Player[1] = tran:Find("PlayerDownRect")
    self.Player[2] = tran:Find("PlayerRightRect")
    self.Player[3] = tran:Find("PlayerTopRect")
    self.Player[4] = tran:Find("PlayerLeftRect")

    self.PlayerClass = {} 
    for i = 1, 4 do
        self.PlayerClass[i] = MjXlPlayerManger.Create(self.Player[i], i,self)
    end

    -- 出牌区域
    MjXlGamePanel.ChupaiMag = MjYiChuPaiManager3D.New(self.PlayerClass , MjXlModel)

    

    -- 碰杠区域
    MjXlGamePanel.PengGangMag = MjPgManager3D.New(self.PlayerClass , MjXlModel)
    
    self.countdown = nil
    self.updateTimer = Timer.New(basefunc.handler(self, self.UpdateCall), timeStep, -1, true)
    self.updateTimer:Start()

    self.updateDelay = Timer.New(basefunc.handler(self, self.UpdateDelayCall), updateDelayStep, -1, true)
    self.updateDelay:Start()

    self.TimeCallDict = {}

    self.SaiZiAnimNode = tran:Find("SaiZiAnimNode").gameObject

    --托管
    self.autoUI={}
    self.autoUI[1]=tran:Find("PlayerDownRect/AutoRect").gameObject
    self.autoUI[2]=tran:Find("PlayerRightRect/AutoRect").gameObject
    self.autoUI[3]=tran:Find("PlayerTopRect/AutoRect").gameObject
    self.autoUI[4]=tran:Find("PlayerLeftRect/AutoRect").gameObject
    self.autoBtn = tran:Find("PlayerDownRect/AutoRect/CloseAutoBtn"):GetComponent("Button")
    self.autoBtn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if Network.SendRequest("nor_mj_xzdd_auto", {operate=0}) then
            self.autoUI[1]:SetActive(false)
        else
            MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
        end
    end)
    self.TopButtonImage = tran:Find("TopButtonImage"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButtonImage.gameObject).onClick = basefunc.handler(self, self.SetHideMenu)
    self.TopButtonImage.gameObject:SetActive(false)
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

function MjXlGamePanel:OnPing(ping)
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


function MjXlGamePanel:SetHideMenu()
    self.MenuBG.gameObject:SetActive(false)
    self.TopButtonImage.gameObject:SetActive(false)
end
function MjXlGamePanel:Start()
    -- self:MyRefresh()

end
-- 初始化
function MjXlGamePanel:MyInit()
    self:MakeLister()
    MjXlLogic.setViewMsgRegister(lister,listerRegisterName)

    --任务
    GameTaskBtnPrefab.Create()
end

function MjXlGamePanel:showOrHideGameDesk(status )

    if MjXlModel.checkIsEr() then
        self.PlayerDownRect.gameObject:SetActive(status) 
        --self.PlayerRightRect.gameObject:SetActive(status)  
        self.PlayerTopRect.gameObject:SetActive(status) 
        --self.PlayerLeftRect.gameObject:SetActive(status) 
    else
        self.PlayerDownRect.gameObject:SetActive(status) 
        self.PlayerRightRect.gameObject:SetActive(status)  
        self.PlayerTopRect.gameObject:SetActive(status) 
        self.PlayerLeftRect.gameObject:SetActive(status) 
    end

    

    --self.CenterRect.gameObject:SetActive(status) 
end










--- 指示灯显示or隐藏
function MjXlGamePanel:showOrHideZhishideng(pos,status )
    for i=1,4 do
        self.zhishideng[i].gameObject:SetActive(false)

        self.deskCenterMgr:showOrHideOneZhishideng(i , false)
        

        self.headLGNode[i].gameObject:SetActive(false)
        if self.headBGLGTime[i] then
            self.headBGLGTime[i]:Stop()
            self.headBGLGTime[i] = nil
        end    
        if self.headBGLGCGTime[i] then
            self.headBGLGCGTime[i]:Kill()
            self.headBGLGCGTime[i] = nil
        end    
    end
    if pos and pos>0 and pos<5 then
        self.zhishideng[pos].gameObject:SetActive(status)
        self.deskCenterMgr:showOrHideOneZhishideng(pos , true)
        

        self.headBGLGTime[pos],self.headBGLGCGTime[pos] = MjAnimation.HeadBG(self.headBGLG[pos],self.headBGLGCG[pos],self.countdown)
        self.headLGNode[pos].gameObject:SetActive(status)
    end
end
-- Update
function MjXlGamePanel:UpdateCall()
    local dt = timeStep
    if self.countdown and self.countdown > 0 then 
        self.countdown = self.countdown - dt
    end
    for k,call in pairs(self.TimeCallDict) do
        call(self)
    end
end

function MjXlGamePanel:UpdateDelayCall()
    if self.scoreChangeDelay then
        self.scoreChangeDelay = self.scoreChangeDelay - updateDelayStep
        if self.scoreChangeDelay < 0 then
            self.scoreChangeDelay = 0
        end
    end


end

-- UI关注的事件
function MjXlGamePanel:MakeLister()
    lister = {}
    
    ---------------------------------------------------------------- new
    lister["ping"] = basefunc.handler(self,self.OnPing) 

    ---- 模式
    lister["model_fg_enter_room_msg"] = basefunc.handler(self, self.fg_enter_room_msg)
    lister["model_fg_join_msg"] = basefunc.handler(self, self.fg_join_msg)
    lister["model_fg_leave_msg"] = basefunc.handler(self, self.fg_leave_msg)
    --lister["model_fg_all_info"] = basefunc.handler(self, self.model_fg_all_info)
    lister["model_nor_mg_score_change_msg"] = basefunc.handler(self, self.model_nor_mg_score_change_msg)
    lister["model_fg_ready_msg"] = basefunc.handler(self, self.model_fg_ready_msg)
    lister["model_nor_mj_xzdd_game_bankrupt_msg"] = basefunc.handler(self, self.model_nor_mj_xzdd_game_bankrupt_msg)
    
    lister["model_fg_huanzhuo_response"] = basefunc.handler(self, self.model_fg_huanzhuo_response)
    lister["model_fg_ready_response"] = basefunc.handler(self, self.model_fg_ready_response)
    
    ---- 玩法
    lister["model_nor_mj_xzdd_ready_msg"] = basefunc.handler(self, self.model_nor_mj_xzdd_ready_msg)
    lister["model_nor_mj_xzdd_begin_msg"] = basefunc.handler(self, self.model_nor_mj_xzdd_begin_msg)
    lister["model_nor_mj_xzdd_action_msg"] = basefunc.handler(self, self.nor_mj_xzdd_action_msg)
    lister["model_nor_mj_xzdd_tou_sezi_msg"] = basefunc.handler(self, self.nor_mj_xzdd_tou_sezi_msg)
    lister["model_nor_mj_xzdd_pai_msg"] = basefunc.handler(self, self.nor_mj_xzdd_pai_msg)
    lister["model_nor_mj_xzdd_permit_msg"] = basefunc.handler(self, self.nor_mj_xzdd_permit_msg)
    lister["model_nor_mj_xzdd_grades_change_msg"] = basefunc.handler(self, self.nor_mj_xzdd_grades_change_msg)
    lister["model_nor_mj_xzdd_dingque_result_msg"] = basefunc.handler(self, self.nor_mj_xzdd_dingque_result_msg)
    lister["model_nor_mj_xzdd_auto_msg"] = basefunc.handler(self, self.nor_mj_xzdd_auto_msg)
    lister["model_nor_mj_xzdd_settlement_msg"] = basefunc.handler(self, self.nor_mj_xzdd_settlement_msg)
    lister["model_nor_mj_xzdd_next_game_msg"] = basefunc.handler(self, self.nor_mj_xzdd_next_game_msg)

    lister["model_nor_mj_xzdd_da_piao_msg"] = basefunc.handler(self, self.nor_mj_xzdd_da_piao_msg)
    lister["model_nor_mj_xzdd_da_piao_finish_msg"] = basefunc.handler(self, self.nor_mj_xzdd_da_piao_finish_msg)

    lister["model_nor_mj_xzdd_huansanzhang_msg"]=basefunc.handler(self,self.model_nor_mj_xzdd_huansanzhang_msg)
    lister["model_nor_mj_xzdd_huan_pai_finish_msg"]=basefunc.handler(self,self.model_nor_mj_xzdd_huan_pai_finish_msg)
    
    lister["model_huanSanZhang_num_change_msg"]=basefunc.handler(self,self.model_huanSanZhang_num_change_msg)
    lister["model_zhuan_yu_msg"] = basefunc.handler(self, self.model_zhuan_yu_msg)

    --资产改变
    lister["model_AssetChange"] = basefunc.handler(self, self.AssetChange)
end

function MjXlGamePanel:set_erRen_about()
    -----
    if MjXlModel.game_type and MjXlModel.checkIsEr() and not self.isSetEr then
        self.isSetEr = true
        print("<color=yellow>-------------- 调整已出牌的位置<color>")
        --- 一行改成放8个
        MjXlGamePanel.ChupaiMag:setMaxLine(8) 

        MjXlGamePanel.ChupaiMag:addChuPaiPosOffsetX( -0.4 )
    end

    if MjXlModel.game_type and not self.isSetShouPai then
        self.isSetShouPai = true
        for i = 1, #self.PlayerClass do
            local playerInfo = MjXlModel.GetPosToPlayer(i)
            if playerInfo then
                self.PlayerClass[i]:adjustShouPaiPos()
            end
        end 
    end
end


function MjXlGamePanel:model_fg_huanzhuo_response()
    self:MyRefresh()

    self.deskCenterMgr:showOrHideAllReaminCard(false)
    self:ClearZhuanYu()
end

function MjXlGamePanel:model_fg_ready_response()
    self:MyRefresh()

    self:ClearShowCards()
    self.deskCenterMgr:showOrHideAllReaminCard(false)
    self:ClearZhuanYu()
end

function MjXlGamePanel:model_nor_mg_score_change_msg()
        
end

function MjXlGamePanel:model_fg_ready_msg(seatno)
    self:RefreshPlayer(seatno)
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
local function HuanPaiCountdown(self)
    if self.countdown and self.countdown > 0 then
        self.huanPaiCd.text = string.format("(%02d)" , math.ceil(self.countdown))
    end
end

local function ChangedeskCountdown(self)
    if self.countdown and self.countdown > 0 then
        self.ChangedeskHintText.text = "换  桌(" .. self.countdown .. "s)"
    else
        self:RefreshChangedesk()
    end
end

-- 刷新UI
function MjXlGamePanel:MyRefresh()
    local m_data = MjXlModel.data
    if m_data then
        --- 桌面ui
        if not self.isSetMjDeskUi then
            self.isSetMjDeskUi = true
            if m_data.init_stake then
                self.deskCenterMgr:setBaseScore(m_data.init_stake)
            else
                self.isSetMjDeskUi = false
            end

            if MjXlModel.game_type then 
                if MjXlModel.checkIsEr() then
                    self.deskCenterMgr:setMjTypeDeskUi("mj_game_imgf_ermj")
                else
                    self.deskCenterMgr:setMjTypeDeskUi("mj_game_imgf_xz")
                end
            else
                self.isSetMjDeskUi = false
            end

        end

        local gameCfg = GameFreeModel.GetGameIDToConfig(MjXlModel.baseData.game_id)
        if gameCfg then
            self.deskCenterMgr:SetGameName(gameCfg.game_name)
        end

        self:set_erRen_about()

        self.last_action_msg=nil
        if not m_data.model_status then
            print("<color=red>房间状态为空</color>")
        else
            print("<color=yellow> MjXlGamePanel:MyRefresh </color>")
            self:RefreshChangedesk()
            self:RefreshPlayer()
            if m_data.init_stake then
                self.DFText.text = "底分：" .. m_data.init_stake
            end

            --[[self.Changedesk.gameObject:SetActive(false)
            if m_data.hu_data_map and m_data.hu_data_map[m_data.seat_num] then
                -- self.ChangeDeskButton.gameObject:SetActive(true)
                self.Changedesk.gameObject:SetActive(false)
            end--]]

            -- 这个一定要在  RefreshCenter 之前  ↓↓
            if MjXlModel.checkIsEr() then
                self.deskCenterMgr:refreshZhuangjiaZhishideng_erRen( MjXlModel )  
            else
                self.deskCenterMgr:refreshZhuangjiaZhishideng( MjXlModel )  
            end
            
            self:RefreshCenter()

            if m_data.model_status == MjXlModel.Model_Status.wait_begin or m_data.model_status == MjXlModel.Model_Status.wait_table then
                self.deskCenterMgr:showOrHideAllReaminCard(false)
            else
                if MjXlModel.checkIsEr() then
                    self.deskCenterMgr:refreshRemainCard_erRen(MjXlModel)
                else
                    self.deskCenterMgr:refreshRemainCard(MjXlModel)
                end
            end

            self:RefreshHuanSanZhang()

            self:RefreshZhuanYu()
            self:RefreshRoom()
            self:RefreshClearing()
            self:RefreshDingqueStatus()
            --刷新托管
            self:RefreshAutoStatus()
            self:RefreshPermit()

            self:RefreshDapiaoStatus()
            self:RefreshTouSezi()

            self:RefreshHuPai()
            self:RefreshHud()
            self:RefreshPoChan()
        end
        
    end
end

--- 刷新胡牌
function MjXlGamePanel:RefreshHuPai()
    local m_data = MjXlModel.data
    --- 如果胡牌了，那么要显示换桌和离开
    if m_data.hu_data_map[ m_data.seat_num ] and m_data.status ~= MjXlModel.Status.settlement and m_data.status ~= MjXlModel.Status.gameover and m_data.status ~= MjXlModel.Status.wait_table then
        --MjXlHuanZhuo3D.Create()
    else
        MjXlHuanZhuo3D.Close()
    end
end

function MjXlGamePanel:RefreshTouSezi()
    local m_data = MjXlModel.data
    if not m_data or not m_data.status or not m_data.countdown or m_data.status ~= MjXlModel.Status.tou_sezi then
        return

    end

    local passTime = self.deskCenterMgr.touseziAcTime - m_data.countdown

    if passTime < touseziDelayTime then
        MjAnimation.DelayTimeAction(function()
            self.deskCenterMgr:testShaiziAnimation(MjXlModel , 0 )
        end , passTime)
    else
        self.deskCenterMgr:testShaiziAnimation(MjXlModel , passTime - touseziDelayTime )
    end
    

end 

-- 刷新房间状态
function MjXlGamePanel:RefreshRoom()
    local m_data = MjXlModel.data
    if m_data and m_data.model_status then
        if m_data.model_status == MjXlModel.Model_Status.wait_table then
            self.PairdeskClass:Show(m_data.countdown)
        else
            self.PairdeskClass:Hide()
        end
        if m_data.model_status == MjXlModel.Model_Status.gaming then
            self.ChatButton.gameObject:SetActive(true)
        else
            self.ChatButton.gameObject:SetActive(false)
        end
    end
end

-- 刷新换桌状态
function MjXlGamePanel:RefreshChangedesk()
    local m_data = MjXlModel.data
    if m_data.model_status and m_data.model_status == MjXlModel.Model_Status.wait_begin then
        self.Changedesk.gameObject:SetActive(true)
        self.countdown = math.floor(m_data.countdown)
        if self.countdown > 0 then
            self.TimeCallDict["ChangedeskCountdown"] = ChangedeskCountdown
            ChangedeskCountdown(self)
            self.ChangedeskNo.gameObject:SetActive(true)
        else
            self.TimeCallDict["ChangedeskCountdown"] = nil
            self.ChangedeskNo.gameObject:SetActive(false)
        end
    else
        self.Changedesk.gameObject:SetActive(false)
    end
end

-- 刷新游戏结算界面
function MjXlGamePanel:RefreshClearing()
    if MjXlModel.data.model_status == MjXlModel.Model_Status.wait_begin then
        return
    end

    --[[if MjXlModel.data.status==MjXlModel.Status.settlement then
        MjXlClearing.Create(self.transform)
    elseif MjXlModel.data.status == MjXlModel.Status.gameover then
        MjXlClearing.Create(self.transform)
    else
        MjXlClearing.Close()
    end]]
    if MjXlModel.data.status==MjXlModel.Status.settlement or MjXlModel.data.status == MjXlModel.Status.gameover then
        self:ShowAllCards()
        self:CreateClearPanel()
    else
        self:ClearShowCards()
        if self.clearPanel then
            self.clearPanel:Close()
        end
    end

    self:RefreshHud()
end

function MjXlGamePanel:ShowAllCards()
    dump(MjXlModel.data.settlement_info, "<color=blue>------------------------------------------>>> settle info:</color>")
    log("<color=yellow>------------------------------------->>> my seat:</color>" .. MjXlModel.data.seat_num)

    local settleData = MjXlModel.data.settlement_info
    for _, data in ipairs(settleData) do
        local huPai = 0
        if data.settle_data and data.settle_data.hu_pai and data.settle_data.hu_type and data.settle_data.hu_type ~= "tian_hu" then
            huPai = data.settle_data.hu_pai
        end
        self.PlayerClass[MjXlModel.GetSeatnoToPos (data.seat_num)]:ShowCards(data.shou_pai, nil)
    end
end

function MjXlGamePanel:CreateClearPanel()
    if MjXlModel.data and MjXlModel.data.activity_data then
        local m_ad = {}
        for i,v in ipairs(MjXlModel.data.activity_data) do
            m_ad[v.key] = v.value
        end
        if m_ad.activity_id ~= ActivityType.TianJiangCaiShen then
            Event.Brocast("activity_fg_gameover_msg")
        end
    end
    self.clearPanel = MjXlClearing.Create(self.transform)
end

function MjXlGamePanel:RefreshHud()
    local isShow = true
    if MjXlModel.data.status==MjXlModel.Status.settlement or MjXlModel.data.status == MjXlModel.Status.gameover then
        isShow = false
        self.hupai_hint.gameObject:SetActive(false)
        self.countdown = 0
        OperTime(self)
        self.updateTimer:Stop()
        self:ShowOrHideOperRect(false)
        self:ClearCurrentCP()

        self.PlayerDownRect:Find("Rect/TPRoot").gameObject:SetActive(false)

        if self.autoUI and #self.autoUI > 0 then
            for i = 1, #self.autoUI do
                self.autoUI[i]:SetActive(false)
            end
        end

        for i = 1, #self.PlayerClass do
            if self.PlayerClass[i] and self.PlayerClass[i].ShouPai and self.PlayerClass[i].ShouPai.hpImg then
                self.PlayerClass[i].ShouPai.hpImg:SetActive(false)
            end
        end

        self:showOrHideZhishideng(-1, false)
    else
        self.updateTimer:Start()
        self.hupai_hint.gameObject:SetActive(true)
    end

    self.hud.gameObject:SetActive(isShow)
end

function MjXlGamePanel:ClearCurrentCP()
    for i = 1, #self.Player do
        if self.Player[i] then
            local cpNode = self.Player[i]:Find("CPNode")
            for j = 1, cpNode.childCount do
                local mj = cpNode:GetChild(j - 1)
                if mj and IsEquals(mj.gameObject) and mj.gameObject.activeInHierarchy then
                    GameObject.Destroy(mj.gameObject)
                end
            end
        end
    end
end

function MjXlGamePanel:ClearShowCards()
    for i = 1, #self.PlayerClass do
        self.PlayerClass[i]:ClearShowCards()
    end
end

-- 刷新中间区域(方位)
function MjXlGamePanel:RefreshCenter()

    self.OperTimeTextL.text = ""
    self.OperTimeTextR.text = ""
    self.OperTimeTextRRed.text = ""
    self.OperTimeTextLRed.text = ""
    self.CardNumText.text = ""
    self.RateNumText.text = ""

    local data = MjXlModel.data
    if data then
        if data.model_status == MjXlModel.Model_Status.wait_table or data.model_status == MjXlModel.Model_Status.wait_begin then
            self:showOrHideZhishideng(-1, false)
        else
            self.countdown = math.floor(MjXlModel.data.countdown)
            --self.CenterRect.gameObject:SetActive(true)
            if data.cur_p and data.cur_p > 0 then
                self:showOrHideZhishideng(MjXlModel.GetSeatnoToPos(data.cur_p), true)
            else
                --- 如果有庄家
                if data.zjSeatno and data.zjSeatno~=0 then
                    self:showOrHideZhishideng(MjXlModel.GetSeatnoToPos(data.zjSeatno), true)
                else
                    self:showOrHideZhishideng(-1, false)
                end
                self.CardNumText.text = ""
                self.RateNumText.text = ""
            end
            self.TimeCallDict["OperTime"] = OperTime
            OperTime(self)
            self:SetRemainCard()
            self:SetRate()

        end
    end
end
function MjXlGamePanel:SetRemainCard()
    self.CardNumText.text = MjXlModel.GetRemainCard ()
    if MjXlModel.GetRemainCard() == 4 then
        MjAnimation.ShowLast4Pai(Vector3.New(0,-300,0),Vector3.New(0,0,0))
    end
end
function MjXlGamePanel:SetRate()
    if MjXlModel.data.cur_race and MjXlModel.data.sumRace then
        self.RateNumText.text = MjXlModel.data.cur_race .. "/".. MjXlModel.data.sumRace
    else
        self.RateNumText.text = "-/-"
    end
end
function MjXlGamePanel:MyExit()
    DOTweenManager.CloseAllSequence()
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()
    VfxCoinFly.ClearAll()
    self:ClearShowCards()

    if self.updateTimer then
        self.updateTimer:Stop()
        self.updateTimer=nil
    end

    if self.updateDelay then
        self.updateDelay:Stop()
        self.updateDelay=nil
    end

    for i=1,#self.PlayerClass do
        self.PlayerClass[i]:MyExit()
    end

    for i=1,4 do
        if self.headBGLGTime[i] then
            self.headBGLGTime[i]:Stop()
            self.headBGLGTime[i] = nil
        end    
        if self.headBGLGCGTime[i] then
            self.headBGLGCGTime[i]:Kill()
            self.headBGLGCGTime[i] = nil
        end   
    end
    self.cardObj = nil

    MjXlLogic.clearViewMsgRegister(listerRegisterName)
    
    if self.clearPanel then
        self.clearPanel:Close()
    end
    --MjXlClearing.Close()
--[[
    if self.majiang_fj then
        GameObject.Destroy( self.majiang_fj.gameObject )
        self.majiang_fj = nil
    end

    if self.lights then
        GameObject.Destroy( self.lights.gameObject )
        self.lights = nil
    end--]]

    self.deskCenterMgr:MyExit()
    MjXlGamePanel.ChupaiMag:MyExit()
    MjXlGamePanel.PengGangMag:MyExit()

    --closePanel(MjXlGamePanel.name)

    --任务取消
    Event.Brocast("close_task")
end
function MjXlGamePanel:MyClose()
    self:MyExit()
    closePanel(MjXlGamePanel.name)
end
--[[***********************
UI关注的消息
***********************--]]
-- 进入房间 玩家自己入座
function MjXlGamePanel:fg_enter_room_msg()
    self:MyRefresh()
end
-- 其它玩家入座
function MjXlGamePanel:fg_join_msg(seatno)
    local uiPos = MjXlModel.GetSeatnoToPos (seatno)
    self.PlayerClass[uiPos]:PlayerEnter()
end
-- 玩家离开
function MjXlGamePanel:fg_leave_msg(seatno)
    local uiPos = MjXlModel.GetSeatnoToPos (seatno)
    self.PlayerClass[uiPos]:PlayerExit()
end

--检测action msg是否已经执行
function MjXlGamePanel:check_action_isrun(data)
    if data.type~="cp" or  MjXlModel.GetSeatnoToPos(data.p)~=1 then
        return false
    end
    if data.from=="client" then
        self.last_action_msg=data
        return false
    end
    if not self.last_action_msg then
        return false
    end
    --检查是否操作是否相同
    if data.pai==self.last_action_msg.pai then
        self.last_action_msg=nil
        return true
    else
        --不合法   客户端回滚之前出的牌 以服务器为准  
        local seatno = MjXlModel.GetSeatnoToPos(data.p)
        self.PlayerClass[seatno]:BackChupai()
        self.last_action_msg=nil
        return false
    end


end

function  MjXlGamePanel:ShowOrHideOperRect(status)
    self.OperRect.gameObject:SetActive(status)
end

function MjXlGamePanel:Permit()
    if MjXlModel.data then
        local m_data = MjXlModel.data
        local my_s=m_data.seat_num
        local pgh_data=m_data.pgh_data
        self:ShowOrHideOperRect(false)

        if m_data.status == MjXlModel.Status.ding_que then
            --刷新定缺状态
            self:RefreshDingqueStatus()
        elseif m_data.status == MjXlModel.Status.da_piao then
            self:RefreshDapiaoStatus()
        elseif m_data.status == MjXlModel.Status.huan_san_zhang then
            -- 
            self:RefreshHuanSanZhang()
        else
            local seatno = MjXlModel.GetSeatnoToPos(m_data.cur_p)
            if m_data.status == MjXlModel.Status.mo_pai then
                self.PlayerClass[seatno]:MopaiPermit(m_data.cur_mopai)

                self.PlayerClass[1]:hideAllHint()
            end
            if m_data.status == MjXlModel.Status.chu_pai or m_data.status == MjXlModel.Status.start then
                self.PlayerClass[seatno]:ChupaiPermit()
            end

            --我自己
            if m_data.cur_p == m_data.seat_num then
                dump(pgh_data, "<color=yellow>--->>>pgh_data:</color>")
                if m_data.status == MjXlModel.Status.mo_pai and m_data.hu_data_map[m_data.seat_num] and (not pgh_data or not (pgh_data.gang or pgh_data.hu)) then
                --if m_data.status == MjXlModel.Status.mo_pai and (not pgh_data or not (pgh_data.gang or pgh_data.hu)) then
                    Timer.New(function()
                        self.PlayerClass[seatno]:SendChupai(m_data.cur_mopai)
                    end, 1, 1, false):Start()
                    self.PlayerClass[seatno].ShouPai:ShowTingPaiMask()
                end

                if pgh_data then
                    if m_data.hu_data_map[m_data.seat_num] and not pgh_data.gang and not pgh_data.hu then
                        if pgh_data.guo then
                            self:SendGuoCB()
                        end
                    else
                        self:ShowOrHideOperRect(true)
                    end
                    local pos=1
                    if pgh_data.guo and not m_data.hu_data_map[m_data.seat_num] then
                        self.GuoButton.gameObject:SetActive(true)
                        pos=pos+1
                    else
                        self.GuoButton.gameObject:SetActive(false)
                    end
                    if pgh_data.peng then
                        self.PengButton.gameObject:SetActive(true)
                        self.PengButton.transform.localPosition=self.PFHGpos[pos]
                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showPengHint( pgh_data.peng )
                        pos=pos+1
                    else
                        self.PengButton.gameObject:SetActive(false)
                    end
                    if pgh_data.gang then
                        self.GangButton.gameObject:SetActive(true)
                        self.GangButton.transform.localPosition=self.PFHGpos[pos]
                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showGangHint( pgh_data.gang )
                        pos=pos+1
                    else
                        self.GangButton.gameObject:SetActive(false)
                    end
                    if pgh_data.hu then
                        self.HuButton.gameObject:SetActive(true)
                        self.HuButton.transform.localPosition=self.PFHGpos[pos]
                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showAllHint( )
                    else
                        self.HuButton.gameObject:SetActive(false)
                    end
                end
            end
        
        end
    end
    self:RefreshCenter()

    if MjXlModel.checkIsEr() then
        self.deskCenterMgr:refreshRemainCard_erRen(MjXlModel)
    else
        self.deskCenterMgr:refreshRemainCard(MjXlModel)
    end

end

function MjXlGamePanel:RefreshPermit()
    if MjXlModel.data then
        local m_data = MjXlModel.data
        local my_s=m_data.seat_num
        local pgh_data=m_data.pgh_data
        self:ShowOrHideOperRect(false)

        if m_data.status == MjXlModel.Status.ding_que then
            --刷新定缺状态
            self:RefreshDingqueStatus()
        --elseif m_data.status == MjXlModel.Status.da_piao then
        --    self:RefreshDapiaoStatus()
        else
            local seatno = MjXlModel.GetSeatnoToPos(m_data.cur_p)
            if m_data.status == MjXlModel.Status.mo_pai then
                self.PlayerClass[seatno]:RefreshMopaiPermit(m_data.cur_mopai)

                self.PlayerClass[1]:hideAllHint()
            end
            if m_data.status == MjXlModel.Status.chu_pai or m_data.status == MjXlModel.Status.start then
                self.PlayerClass[seatno]:RefreshChupaiPermit()
            end

            --我自己
            if m_data.cur_p == m_data.seat_num then
                dump(pgh_data, "<color=yellow>RefreshPermit--->>>pgh_data:</color>")
                if m_data.status == MjXlModel.Status.mo_pai and m_data.hu_data_map[m_data.seat_num] and (not pgh_data or not (pgh_data.gang or pgh_data.hu)) then
                    Timer.New(function()
                        self.PlayerClass[seatno]:SendChupai(m_data.cur_mopai)
                    end, 1, 1, false):Start()
                    self.PlayerClass[seatno].ShouPai:ShowTingPaiMask()
                end

                if pgh_data then
                    if m_data.hu_data_map[m_data.seat_num] and not pgh_data.gang and not pgh_data.hu then
                        if pgh_data.guo then
                            self:SendGuoCB()
                        end
                    else
                        self:ShowOrHideOperRect(true)
                    end
                    local pos=1
                    if pgh_data.guo and not m_data.hu_data_map[m_data.seat_num] then
                        self.GuoButton.gameObject:SetActive(true)
                        pos=pos+1
                    else
                        self.GuoButton.gameObject:SetActive(false)
                    end
                    if pgh_data.peng then
                        self.PengButton.gameObject:SetActive(true)
                        self.PengButton.transform.localPosition=self.PFHGpos[pos]
                        pos=pos+1

                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showPengHint( pgh_data.peng )
                    else
                        self.PengButton.gameObject:SetActive(false)
                    end
                    if pgh_data.gang then
                        self.GangButton.gameObject:SetActive(true)
                        self.GangButton.transform.localPosition=self.PFHGpos[pos]
                        pos=pos+1

                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showGangHint( pgh_data.gang )
                    else
                        self.GangButton.gameObject:SetActive(false)
                    end
                    if pgh_data.hu then
                        self.HuButton.gameObject:SetActive(true)
                        self.HuButton.transform.localPosition=self.PFHGpos[pos]
                        self.PlayerClass[1]:hideAllHint()
                        self.PlayerClass[1]:showAllHint( )
                    else
                        self.HuButton.gameObject:SetActive(false)
                    end
                end
            end        
        end
    end
end 

-- 代表全部隐藏
function MjXlGamePanel:RefreshDingqueHint(pos,status)
    print("RefreshDingqueHint == " .. pos .. "  " .. status)
    --我自己
    if pos==1 then 
        if status==0 then
            self.DQRect.gameObject:SetActive(false)
            self:HideDQParticle()
            self.dingqueHint[pos].gameObject:SetActive(false)
            self.dingqueWaitHint[pos].gameObject:SetActive(true)
            -- self.dingqueHint[pos].transform:Find("dingqueHintTxt"):GetComponent("Text").text = "等待其他玩家定缺"
            
        elseif status==-1 then
            self.dingqueHint[pos].gameObject:SetActive(false)
            self.dingqueWaitHint[pos].gameObject:SetActive(false)
            self.DQRect.gameObject:SetActive(true)
            local playerData = MjXlModel.GetPosToPlayer(1)
            local tong,tiao,wan = normal_majiang.ding_que(playerData.spList)
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
            self:RefreshDingqueColor(pos,status)
        end

    else
        if status==-1 then
            self.dingqueHint[pos].gameObject:SetActive(true)
            self.dingqueWaitHint[pos].gameObject:SetActive(false)
            -- self.dingqueHint[pos].transform:Find("dingqueHintTxt"):GetComponent("Text").text = "定缺中"
        elseif status==0 then
            self.dingqueHint[pos].gameObject:SetActive(false)
            self.dingqueWaitHint[pos].gameObject:SetActive(true)
            -- self.dingqueHint[pos].transform:Find("dingqueHintTxt"):GetComponent("Text").text = "等待其他玩家定缺"
        else
            self.dingqueHint[pos].gameObject:SetActive(false)
            self.dingqueWaitHint[pos].gameObject:SetActive(false)
            self:RefreshDingqueColor(pos,status)
        end
    end
end
local huase_image={"mj_game_imgf_tong","mj_game_imgf_tiao","mj_game_imgf_wan"}
function MjXlGamePanel:RefreshDingqueColor(pos,status)
    if status and status>0 and status<4 then
        self.dingque_b[pos].gameObject:SetActive(true)
        --   切换定缺 color
        self.dingque_c[pos].sprite=GetTexture(huase_image[status])
    else
        self.dingque_b[pos].gameObject:SetActive(false)
    end
end

function MjXlGamePanel:RefreshDingqueStatus()
    local status=MjXlModel.data.status 
    local playerInfo=MjXlModel.data.playerInfo

    --- 二人麻将直接不刷新定缺
    if MjXlModel.checkIsEr() then
        return
    end

    if status and playerInfo then
        for i=1,4 do
            local pos=MjXlModel.GetSeatnoToPos(i)
            self:RefreshDingqueHint(pos, playerInfo[i].lackColor)
        end
        
    else
        --全部隐藏
        for i=1,4 do
            self:RefreshDingqueHint(i, -2)
        end
    end
end


function MjXlGamePanel:RefreshDapiaoStatus()
    dump( MjXlModel.data.playerInfo , "<color=yellow>------------- MjXlGamePanel:RefreshDapiaoStatus ------------- </color>" )
    
    ---- 打漂图标
    local daPiaoPlayerNum = 0
    local playerInfo=MjXlModel.data.playerInfo
    for i=1 , MjXlModel.maxPlayerNumber do
        if playerInfo[i] then
            local uiPos = MjXlModel.GetSeatnoToPos(i)
            local piaoNum = playerInfo[i].piaoNum
            --- 是自己
            if uiPos == 1 then
                if piaoNum then
                    if piaoNum == -1 then
                        self.dapiaoIcon[uiPos].gameObject:SetActive(false)
                    else
                        if piaoNum ~= 0 then
                            daPiaoPlayerNum = daPiaoPlayerNum + 1
                        end
                        if piaoNum > 0 then
                            self.dapiaoIcon[uiPos].gameObject:SetActive(true)
                            self.dapiaoIcon[uiPos].sprite = GetTexture(MjXlModel.piaoIconVec[piaoNum])
                        end
                    end
                else
                    self.dapiaoIcon[uiPos].gameObject:SetActive(false)
                end
            else
                --- 其他人
                if piaoNum then
                    if piaoNum == -1 then
                        self.dapiaoIcon[uiPos].gameObject:SetActive(false)
                    else
                        if piaoNum ~= 0 then
                            daPiaoPlayerNum = daPiaoPlayerNum + 1
                        end
                        if piaoNum > 0 then
                            self.dapiaoIcon[uiPos].gameObject:SetActive(true)
                            self.dapiaoIcon[uiPos].sprite = GetTexture(MjXlModel.piaoIconVec[piaoNum])
                        end 
                    end
                else
                    self.dapiaoIcon[uiPos].gameObject:SetActive(false)
                end
            end
        end
    end

    if daPiaoPlayerNum == 1 then
        self.deskCenterMgr:setBaseScore( string.format("%dx2",MjXlModel.data.init_stake) )
    elseif daPiaoPlayerNum >= 2 then
        self.deskCenterMgr:setBaseScore( string.format("%dx4",MjXlModel.data.init_stake) )
    elseif daPiaoPlayerNum == 0 then
        self.deskCenterMgr:setBaseScore( string.format("%d",MjXlModel.data.init_stake) )
    end
    -----------------------
    local status=MjXlModel.data.status 
    if status ~= MjXlModel.Status.da_piao then
        self.DaPiaoRect.gameObject:SetActive(false)
        for k,v in pairs(self.dapiaoHint) do
            v.gameObject:SetActive(false)
        end
        for k,v in pairs(self.dapiaoWaitHint) do
            v.gameObject:SetActive(false)
        end

        return 
    end

    ---- 
    local dapiaoPlayerNum = 0
    local playerInfo=MjXlModel.data.playerInfo
    for i=1 , MjXlModel.maxPlayerNumber do
        if playerInfo[i] then
            local uiPos = MjXlModel.GetSeatnoToPos(i)

            local piaoNum = playerInfo[i].piaoNum

            --- 是自己
            if uiPos == 1 then
                if piaoNum then
                    if piaoNum == -1 then
                        self.DaPiaoRect.gameObject:SetActive(true)
                        self.dapiaoWaitHint[uiPos].gameObject:SetActive(false)
                    else
                        dapiaoPlayerNum = dapiaoPlayerNum + 1
                        self.DaPiaoRect.gameObject:SetActive(false)
                        self.dapiaoWaitHint[uiPos].gameObject:SetActive(true)
                    end
                else
                    self.DaPiaoRect.gameObject:SetActive(false)
                    self.dapiaoWaitHint[uiPos].gameObject:SetActive(false)
                end
            else
                --- 其他人
                if piaoNum then
                    if piaoNum == -1 then
                        self.dapiaoHint[uiPos].gameObject:SetActive(true)
                    else
                        dapiaoPlayerNum = dapiaoPlayerNum + 1
                        self.dapiaoHint[uiPos].gameObject:SetActive(false)
                    end
                else
                    self.dapiaoHint[uiPos].gameObject:SetActive(false)
                end
            end
        end
    end

    if dapiaoPlayerNum == MjXlModel.maxPlayerNumber then
        self.dapiaoWaitHint[1].gameObject:SetActive(false)
    end

end

function MjXlGamePanel:RefreshHuanSanZhang()
    self.PlayerClass[1]:hideAllHint()
    self.PlayerClass[1].ShouPai:showAllMask()
    print("<color=yellow>--------------- MjXlGamePanel , RefreshHuanSanZhang </color>")
    local m_data = MjXlModel.data
    local status = m_data.status
    if status ~= MjXlModel.Status.huan_san_zhang then
        for k,v in ipairs(self.huanSanZhangRect) do
            v.gameObject:SetActive(false)
        end
        self.PlayerClass[1]:setShouPaiActionModel( "normal" )
        self.TimeCallDict["HuanPaiCountdown"] = nil 
        return
    end

    self.TimeCallDict["HuanPaiCountdown"] = HuanPaiCountdown 

    --- 界面显示
    for k,v in ipairs(self.huanSanZhangRect) do
        v.gameObject:SetActive(true)
    end

    if MjXlModel.data.isHuanPai then
        self.huanSanZhangRect[1].gameObject:SetActive(false)
        self.TimeCallDict["HuanPaiCountdown"] = nil 
    else
         --- 
        self.PlayerClass[1]:setShouPaiActionModel( "huanSanZhang" )

        if m_data.huanSanZhangVec then
            self.PlayerClass[1]:refreshHuanSanZhangPai(m_data.huanSanZhangVec)
            self.nowSelectSanZhangText.text = string.format( "%d" , 3 - #MjXlModel.data.huanSanZhangVec ) 
        end
    end

   

end

function MjXlGamePanel:HideDQParticle()
    MjAnimation.TJColorOnKill(self.tongTJTween,self.TongImage.transform)
    MjAnimation.TJColorOnKill(self.tiaoTJTween,self.TiaoImage.transform)
    MjAnimation.TJColorOnKill(self.wanTJTween,self.WanImage.transform)

    self.tongTJTween = nil
    self.tiaoTJTween = nil
    self.wanTJTween = nil
end

function MjXlGamePanel:ClearTJ()
    MjAnimation.TJColorOnKill(self.tongTJTween,self.TongImage.transform)
    MjAnimation.TJColorOnKill(self.tiaoTJTween,self.TiaoImage.transform)
    MjAnimation.TJColorOnKill(self.wanTJTween,self.WanImage.transform)

    self.tongTJTween = nil
    self.tiaoTJTween = nil
    self.wanTJTween = nil
end

function MjXlGamePanel:model_nor_mj_xzdd_huansanzhang_msg( is_time_out )
    if not is_time_out then
        if MjXlModel.data and MjXlModel.data.huanSanZhangNewVec then
            self.PlayerClass[1].ShouPai:huanPai( MjXlModel.data.huanSanZhangNewVec , MjXlModel.data.playerInfo[MjXlModel.data.seat_num].spList )
        end
    end

end

function MjXlGamePanel:model_nor_mj_xzdd_huan_pai_finish_msg()
    self:RefreshHuanSanZhang()
    MjXlModel.clearHuanSanZhangData()
end

function MjXlGamePanel:model_huanSanZhang_num_change_msg()
    self.nowSelectSanZhangText.text = string.format( "%d" , 3-#MjXlModel.data.huanSanZhangVec ) 
end


function MjXlGamePanel:RefreshAutoStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if MjXlModel.data then
        --刷新全部 
        if not pSeatNum then
            dump(MjXlModel.data.playerInfo, "<color=red>MjXlModel.data.playerInfo</color>")
            if MjXlModel.data.playerInfo then
                for i=1,MjXlModel.maxPlayerNumber do
                    local auto=MjXlModel.data.playerInfo[i].auto
                    local uiPos = MjXlModel.GetSeatnoToPos(i)
                    if auto then
                        if  auto==1 then
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
        --刷新单个人
        else
            if MjXlModel.data.playerInfo then
                local auto=MjXlModel.data.playerInfo[pSeatNum].auto
                local uiPos = MjXlModel.GetSeatnoToPos(pSeatNum)
                if auto then
                    if auto ==1 then
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


-- 刷新当前的牌
function MjXlGamePanel:S2CMoPai()
    if MjXlModel.data and MjXlModel.data.currCard and MjXlModel.data.cur_p then
        local paiData = MjXlModel.data.currCard
        local seatData = MjXlModel.data.cur_p
        if paiData then
            local uiPos = MjXlModel.GetSeatnoToPos (seatData)
            self.PlayerClass[uiPos]:AddZPPai(paiData)
        else

        end
    end
end

--发送数据***********************
function MjXlGamePanel:SendAction(data)
    table.print("<color=blue>sendAction:</color>",data)
    if Network.SendRequest("nor_mj_xzdd_operator", data) then
        return true
    else
        MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
        return false
    end
    
end
function MjXlGamePanel:SendDingque(val)
    self:HideDQParticle()
    if self:SendAction({type="dq", pai = val}) then
        --刷新我的定缺状态 （将 定缺按钮隐藏 状态改变为 等待其他玩家定缺）
        self:RefreshDingqueHint(1,0)
    end
end

function MjXlGamePanel:SendDaPiao(val)
    if Network.SendRequest("nor_mj_xzdd_dapiao", { piaoNum = val }) then
        
        return true
    else
        MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
        return false
    end
end

function MjXlGamePanel:SendHuanSanZhang(paiVec)
    print("<color=yellow>-----------------  MjXlGamePanel:SendHuanSanZhang </color>")
    local data = { paiVec = paiVec }

    if Network.SendRequest("nor_mj_xzdd_huansanzhang", data) then
        MjXlModel.data.isCanOpPai = false
        return true
    else
        return false
    end
end

function MjXlGamePanel:SendPengCB()
    local pgh_data=MjXlModel.data.pgh_data
    local peng
    if pgh_data then
        peng=pgh_data.peng
    end
    if not peng then
        --没有出牌权限
    end
    local act={type="peng", pai = peng.pai}
    if self:SendAction(act) then
        --按钮隐藏
        self:ShowOrHideOperRect(false)

    end
end
function MjXlGamePanel:SendGangCB(act)
    local pgh_data=MjXlModel.data.pgh_data
    local gang
    if pgh_data then
        gang=pgh_data.gang
    end
    if not gang then
        --没有出牌权限        
    end
    if #gang > 1 then
        --展示提示
        MjXlGangsRect.Create(self.gameObject, gang, function (act)
            self:SendGang(act)
        end)
    else
        local act={type="gang", pai=gang[1].pai}
        self:SendGang(act)
    end
end
function MjXlGamePanel:SendGang(act)
    if self:SendAction(act) then
        if act.type == "gang" then
            self.PlayerClass[1]:SetSendCP()
        end
        --按钮隐藏
        self:ShowOrHideOperRect(false)
    end
end


function MjXlGamePanel:SendHuCB(val)
    local pgh_data=MjXlModel.data.pgh_data
    local hu
    if pgh_data then
        hu=pgh_data.hu
    end
    if not hu then
        --没有胡牌权限
    else
        if self:SendAction({type="hu"}) then
            --按钮隐藏
            self:ShowOrHideOperRect(false)
        end
    end
end
function MjXlGamePanel:SendGuoCB()
    if self:SendAction({type="guo"}) then
        --按钮隐藏
        self:ShowOrHideOperRect(false)

        ----- 提示的牌取消提示
        local pgh_data = MjXlModel.data.pgh_data

        self.PlayerClass[1]:hideAllHint()
        

    end
end
--发送数据***********************

-- 播放骰子动画
function MjXlGamePanel:PlaySaiZi(val1, val2)
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
    seq:AppendCallback(function ()
        SZNode.gameObject:SetActive(false)
        Node.gameObject:SetActive(true)
    end)
    seq:AppendInterval(2)
    seq:OnKill(function ()
        DOTweenManager.RemoveStopTween(tweenKey)
        self:StopSaiZi()
        -- 设置庄家
        local uiPos = MjXlModel.GetSeatnoToPos (MjXlModel.data.zjSeatno)
        self.PlayerClass[uiPos]:SetZJ(true)
    end)
end
-- 暂停骰子动画
function MjXlGamePanel:StopSaiZi()
    self.SaiZiAnimNode:SetActive(false)
end






-- 刷新游戏玩家
function MjXlGamePanel:RefreshPlayer(seatno)
    local m_data = MjXlModel.data
    if m_data then
        if m_data.model_status == MjXlModel.Model_Status.wait_table or m_data.model_status == MjXlModel.Model_Status.wait_begin then
            for i = 1, #self.PlayerClass do
                local playerInfo = MjXlModel.GetPosToPlayer(i)
                if playerInfo then
                    self.PlayerClass[i]:Refresh()
                end
            end
        else
            if seatno then
                if seatno ~= MjXlModel.data.seat_num and m_data.model_status == MjXlModel.Status.gameover then
                else
                    local uiPos = MjXlModel.GetSeatnoToPos(seatno)
                    self.PlayerClass[uiPos]:Refresh()
                end
            else
                
                for i = 1, #self.PlayerClass do
                    -- if playerInfo and i <= #playerInfo and playerInfo[i] then
                    --local uiPos = MjXlModel.GetSeatnoToPos(i)

                    local playerInfo = MjXlModel.GetPosToPlayer(i)
                    if playerInfo then
                        print("<color=yellow>--------------------- MjXlGamePanel:RefreshPlayer: </color>",i)
                        dump(playerInfo , "<color=yellow>--------------------- MjXlGamePanel:RefreshPlayer: dump </color>")
                        self.PlayerClass[i]:Refresh()
                    end
                end
            end
        end
    end
end

------------------------------------- 玩法
--准备
function MjXlGamePanel:model_nor_mj_xzdd_ready_msg(pSeatNum)
    self:RefreshCenter()
    self:RefreshPlayer(pSeatNum)
end

--开始游戏
function MjXlGamePanel:model_nor_mj_xzdd_begin_msg()
    self:RefreshCenter()
    self:RefreshPlayer()
end

-- 操作
function MjXlGamePanel:nor_mj_xzdd_action_msg(data)
    if self:check_action_isrun(data) then
        return
    end

    if data.type == "hu" and data.p == MjXlModel.data.seat_num then
        self:RefreshHuPai()
    end

    self:ShowOrHideOperRect(false)
    
    MjXlGangsRect.Close()
    local uiPos = MjXlModel.GetSeatnoToPos( data.p )
    self.PlayerClass[uiPos]:Action(data)

    self:TestCoinFly(data)
end

-- 选庄 todo nmg
function MjXlGamePanel:nor_mj_xzdd_tou_sezi_msg()
    local function tsz()
        -- 动画
        --self:PlaySaiZi(MjXlModel.data.sezi_value1, MjXlModel.data.sezi_value2)
        self:SetRemainCard()
        self:SetRate()
    end
    --显示开局动画
    if MjXlModel.data.race == 1 then
        print("<color=yellow>----------------- MJKaiJu </color>")
        MJParticleManager.MJKaiJu(tsz)
    end

    ----
    if MjXlModel.checkIsEr() then
        self.deskCenterMgr:refreshZhuangjiaZhishideng_erRen(MjXlModel)
    else
        self.deskCenterMgr:refreshZhuangjiaZhishideng(MjXlModel)
    end
    
    local uiPos = MjXlModel.GetSeatnoToPos (MjXlModel.data.zjSeatno)
    self.PlayerClass[uiPos]:SetZJ(true)


    --- 投色子的时候做麻将出牌口的降低&升起
    --- 延迟做动作...
    MjAnimation.DelayTimeAction(function() 
        if MjXlModel.checkIsEr() then
            self.deskCenterMgr:cardDoorAnimation_erRen(MjXlModel)
        else
            self.deskCenterMgr:cardDoorAnimation(MjXlModel)
        end
        print("<color=yellow> !!!!! do  cardDoorAnimation </color>")
    end , 0.2)

    ----- 投骰子
    MjAnimation.DelayTimeAction(function() 
        self.deskCenterMgr:testShaiziAnimation(MjXlModel , 0)
        ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_castdice.audio_name)
    end , touseziDelayTime)

    --- 显示庄家位置
    self:showOrHideZhishideng(MjXlModel.GetSeatnoToPos( MjXlModel.data.zjSeatno ),true)

end

-- 发牌（开始游戏）
function MjXlGamePanel:nor_mj_xzdd_pai_msg()
    -- 自己的UI位置
    
    for i = 1, #self.PlayerClass do
        --local pos = MjXlModel.GetSeatnoToPos(i)
        local playerInfo = MjXlModel.GetPosToPlayer(i)
        if playerInfo then
            --print("<color=yellow>--------------- nor_mj_xzdd_pai_msg ,".. i .. ",".. pos .." </color>")
            self.PlayerClass[i]:PlayerFapai()
        end
    end
    --self:RefreshMenu()
    self:RefreshCenter()

    if MjXlModel.checkIsEr() then
        self.deskCenterMgr:refreshRemainCard_erRen(MjXlModel , true)
    else
        self.deskCenterMgr:refreshRemainCard(MjXlModel , true)
    end

    --self.deskCenterMgr:refreshRemainCard( MjXlModel , true )
end

-- 权限
function MjXlGamePanel:nor_mj_xzdd_permit_msg()
    if MjXlModel.data.cur_p == 0 then
        print("<color=red>权限拥有者是0</color>")
    end
    self:Permit()
end

-- 分数改变
function MjXlGamePanel:nor_mj_xzdd_grades_change_msg(data)
    dump(data, "<color=red>--------------------------------->>>> 钱变化 nor_mj_xzdd_grades_change_msg</color>")
    
    if MjXlModel.data and MjXlModel.data.moneyChange then
        self.scoreChangeDelay = self.scoreChangeDelay or 0

        for i, v in ipairs(MjXlModel.data.moneyChange) do
            local uipos = v.cur_p
            local score = v.score
            MjAnimation.DelayTimeAction(function()     
                local seatno = MjXlModel.GetSeatnoToPos(uipos)
                self.PlayerClass[seatno]:ChangeMoney(score)
            end , self.scoreChangeDelay)
        end

        self.scoreChangeDelay = self.scoreChangeDelay + self.scoreChangeDelayCount
    end

end

function MjXlGamePanel:nor_mj_xzdd_dingque_result_msg()
    self:RefreshDingqueStatus()
    --定缺动画 将花色飞过去
    for i = 1, 4 do
        MjAnimation.DQIcon(self.dingque_b[i])
    end
    --清除定缺特效
    self:ClearTJ()
    
    for i = 1, 4 do
        --local pos = MjXlModel.GetSeatnoToPos(i)
        local playerInfo = MjXlModel.GetPosToPlayer(i)
        if playerInfo then
            self.PlayerClass[i]:Dingque({pai = playerInfo.lackColor})
        end
    end
end

--托管
function MjXlGamePanel:nor_mj_xzdd_auto_msg(pSeatNum)
    self:RefreshAutoStatus(pSeatNum)
end

-- 结算
function MjXlGamePanel:nor_mj_xzdd_settlement_msg(pSeatNum)
    --- 移除掉手牌的回调函数
    self.PlayerClass[1].ShouPai:removeShouPaiCallBack()

    --- 指针位置还原
    MjXlGamePanel.ChupaiMag:restoreMjHint()

    self:RefreshHuPai()

    MjAnimation.DelayTimeAction( function() 
        self:RefreshClearing()
    end , 1 )
end

-- 结算
function MjXlGamePanel:nor_mj_xzdd_next_game_msg()
    self:MyRefresh()
    --新的局数
    if MjXlModel.data then
        local curRace = MjXlModel.data.race
        if curRace then
            MjAnimation.CurRace(curRace, self.start_again_cards_pos)
        end
    end
end

--- 打漂
function MjXlGamePanel:nor_mj_xzdd_da_piao_msg(seat_num)
    if MjXlModel.data.playerInfo[seat_num] and MjXlModel.data.playerInfo[seat_num].piaoNum then
        local uiPos = MjXlModel.GetSeatnoToPos (seat_num)

        -- 播声音
        local playerInfo = MjXlModel.data.playerInfo[seat_num]
        if playerInfo and playerInfo.base then
            local sound = MjXlModel.data.playerInfo[seat_num].piaoNum == 0 and "action_nopiao" or "action_piao"
            sound = sound .. (playerInfo.base.sex == 0 and "_0" or "_1")
            dump(sound, "<color=yellow>sound</color>")
            ExtendSoundManager.PlaySound(audio_config.mj[sound].audio_name)
        end

        ---- 创建一个 上浮的 打漂的动画
        MjAnimation.DapiaoAnimation( MjXlModel.piaoIconVec[ MjXlModel.data.playerInfo[seat_num].piaoNum ] , self.dapiaoPosObjVec[uiPos] )
        ---- 翻牌
        self.PlayerClass[uiPos]:daPiaoFinish()

    end
    self:RefreshDapiaoStatus()
end

--- 打漂操作完了
function MjXlGamePanel:nor_mj_xzdd_da_piao_finish_msg()
    --[[local playerInfo = MjXlModel.data.playerInfo
    for i=1,4 do
        if playerInfo[i] then
            local uiPos = MjXlModel.GetSeatnoToPos (i)

        end
    end--]]

end

function MjXlGamePanel:RefreshPoChan()
    if MjXlModel.data.game_bankrupt and MjXlModel.data.model_status == MjXlModel.Model_Status.gaming then
        for i, d in ipairs(MjXlModel.data.game_bankrupt) do
            local uiPos = MjXlModel.GetSeatnoToPos(i)
            if d == 1 and self.PlayerClass[uiPos] and self.PlayerClass[uiPos].ShouPai then
                self.PlayerClass[uiPos].ShouPai:ShowPoChan()
                if i == MjXlModel.data.seat_num then
                    MjXlHuanZhuo3D.Create()
                end
            end
        end
    end
end

function MjXlGamePanel:model_nor_mj_xzdd_game_bankrupt_msg()
    self:RefreshPoChan()
end

function MjXlGamePanel:AssetChange()
    if MjXlModel.data then
        local seatno = MjXlModel.GetPlayerUIPos()
        if self.PlayerClass[seatno] then
            self.PlayerClass[seatno]:RefreshMoney()
        end
    end
end

function MjXlGamePanel:RefreshZhuanYu()
    if MjXlModel.data.zhuan_yu_data then
        self:model_zhuan_yu_msg(MjXlModel.data.zhuan_yu_data, true)
    end
end

function MjXlGamePanel:ClearZhuanYu()
    MjXlGamePanel.PengGangMag:ClearZhuanYuArrows()
    MjXlModel.data.zhuan_yu_data = nil
end

function MjXlGamePanel:model_zhuan_yu_msg(data, NoVfx)
    dump(data, "<color=yellow>MjXlGamePanel:model_zhuan_yu_msg</color>")
    for i, d in ipairs(data) do
        local gSeat = tonumber(d.other)
        local hPlayer = MjXlModel.data.playerInfo[d.p]
        local gPlayer = MjXlModel.data.playerInfo[gSeat]
        local gp = d.pai
        local hPos = MjXlModel.GetSeatnoToPos(d.p)
        local gPos = MjXlModel.GetSeatnoToPos(gSeat)
        MjXlGamePanel.PengGangMag:AddZhuanYuPai(hPos, gPos, gp)
        MjXlGamePanel.PengGangMag:Refresh(gPos, gPlayer.pgList)

        if self.headLGNode and not NoVfx then
            local startPos = self.headLGNode[gPos].position
            local tarPos = self.headLGNode[hPos].position
            VfxCoinFly.Create(GameObject.Find("Canvas/GUIRoot/MjXlGamePanel3D").transform, startPos, tarPos)
        end
    end
end

function MjXlGamePanel:TestCoinFly(data)
    if false and data.type == "peng" then
        local seat1 = MjXlModel.data.cur_chupai.p
        local seat2 = data.p
        local hPos = MjXlModel.GetSeatnoToPos(seat2)
        local gPos = MjXlModel.GetSeatnoToPos(seat1)
        
        log("<color=green>MjXlGamePanel:TestCoinFly, Seat1:" .. seat1 .. ", Seat2:" .. seat2 .. ", uiPos1:" .. gPos .. ", uiPos2:" .. hPos .. "</color>")
        if self.headLGNode then
            local startPos = self.headLGNode[gPos].position
            local tarPos = self.headLGNode[hPos].position
            VfxCoinFly.Create(GameObject.Find("Canvas/GUIRoot/MjXlGamePanel3D").transform, startPos, tarPos)
        end
    end
end
