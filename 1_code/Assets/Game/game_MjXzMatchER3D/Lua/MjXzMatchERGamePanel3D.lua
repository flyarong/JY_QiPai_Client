local basefunc = require "Game.Common.basefunc"

MjXzGamePanel = basefunc.class()

MjXzGamePanel.name = "MjXzMatchERGamePanel3D"
local lister
local listerRegisterName="mjXzFreeGameListerRegister"

local instance
function MjXzGamePanel.Create()
    DSM.PushAct({panel = MjXzGamePanel.name})
    instance = MjXzGamePanel.New()
    return createPanel(instance, MjXzGamePanel.name)
end
function MjXzGamePanel.Bind()
    local _in=instance
    instance=nil
    return _in
end

local is_bsks
local timeStep = 1 -- update时间间隔
local updateDelayStep = 0.1
local touseziDelayTime = 1.3
function MjXzGamePanel:Awake()
    LuaHelper.GeneratingVar(self.transform, self)
    print("<color=yellow>----------------- MjXzGamePanel.Awake --------------- </color>")
    ------------------------------------------------ add by wss
    --- 动态创建场景
    --[[if not self.majiang_fj then
        self.majiang_fj = GameObject.Instantiate( GetPrefab( "majiang_fj" ) , self.transform.parent.parent.parent )
        self.majiang_fj.name = "majiang_fj"
    end
    if not self.lights then
        self.lights = GameObject.Instantiate( GetPrefab( "Lights" ) , self.transform.parent.parent.parent )
        self.lights.name = "Lights"
    end--]]
    --self.majiang_fj = GameObject.Find("majiang_fj")
    self.scoreChangeDelayCount = 0.5

    self.cur_match_txt = GameObject.Find("majiang_fj/mjz_01/tableCanvas/cur_match_txt"):GetComponent("Text")
    self.cur_match_txt.gameObject:SetActive(true)
    self.cur_multiple_txt = GameObject.Find("majiang_fj/mjz_01/tableCanvas/cur_multiple_txt"):GetComponent("Text")
    self.cur_base_score_txt = GameObject.Find("majiang_fj/mjz_01/tableCanvas/cur_base_score_txt"):GetComponent("Text")
    self.cur_pai_race_txt = GameObject.Find("majiang_fj/mjz_01/tableCanvas/cur_pai_race_txt"):GetComponent("Text")
    self.cur_pai_race_txt.gameObject:SetActive(true)

    ---------------------------------------------

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

    self.dizhu_card_son = {}
    LuaHelper.GeneratingVar(self.mj_match_dizhu_card_ui.transform, self.dizhu_card_son)
    self.mj_match_dizhu_card_ui.transform.gameObject:SetActive(false)

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
            if MjXzModel.data.huanSanZhangVec then
                if not self:SendHuanSanZhang(MjXzModel.data.huanSanZhangVec) then
                    MJAnimation.Hint(2, Vector3.New(0, -350, 0), Vector3.New(0, 0, 0))
                end
            end

            MjXzModel.data.huanSanZhangVec = {}
            MjXzModel.clearHuanSanZhangData()

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



    self.PairdeskClass = MjXzPairdesk.Create(tran:Find("PairdeskRect"))

    self.OperTimeTextL = tran:Find("CenterRect/TimeRect/OperTimeTextL"):GetComponent("Text")
    self.OperTimeTextR = tran:Find("CenterRect/TimeRect/OperTimeTextR"):GetComponent("Text")
    self.OperTimeTextRRed = tran:Find("CenterRect/TimeRect/OperTimeTextRRed"):GetComponent("Text")
    self.OperTimeTextLRed = tran:Find("CenterRect/TimeRect/OperTimeTextLRed"):GetComponent("Text")
    self.DFText = tran:Find("CenterRect/DFText"):GetComponent("Text")

    self.CardNumText = tran:Find("TopLeftRect/Mj_remain_bg/CardNumText"):GetComponent("Text")
    self.RateNumText = tran:Find("CenterRect/RateNumText"):GetComponent("Text")
    self.MenuButton = tran:Find("MenuButton"):GetComponent("Button")
    self.MenuBG = tran:Find("MenuButton/MenuBG")
    self.CloseButton = tran:Find("MenuButton/MenuBG/CloseButton"):GetComponent("Button")
    self.SetButton = tran:Find("MenuButton/MenuBG/SetButton"):GetComponent("Button")
    self.MenuButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        local b = not self.MenuBG.gameObject.activeSelf
        self.MenuBG.gameObject:SetActive(b)
        self.TopButtonImage.gameObject:SetActive(b)
    end)
    self.HelpButton = tran:Find("MenuButton/MenuBG/HelpButton"):GetComponent("Button")
    self.HelpButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        MjHelpPanel.Create("XZ")
    end)
    
    self.CloseButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        if Network.SendRequest("nor_mg_quit_game") then
        else
            MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
        end
    end)
    self.SetButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        GameManager.GotoUI({gotoui = "sys_setting",goto_scene_parm = "panel"})
    end)
    self.ChangeDeskButton = tran:Find("ChangeDeskButton"):GetComponent("Button")
    self.ChangeDeskButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        if Network.SendRequest("nor_mg_replay_game") then
            MjXzModel.ClearMatchData()
        else
            MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
        end
    end)


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
    for i = 1, 4 do  -- MjXzModel.maxPlayerNumber
        self.PlayerClass[i] = MjXzPlayerManger.Create(self.Player[i], i,self)
    end

    -- 出牌区域
    MjXzGamePanel.ChupaiMag = MjYiChuPaiManager3D.New(self.PlayerClass , MjXzModel)

    --- 一行改成放8个
    --MjXzGamePanel.ChupaiMag:setMaxLine(8) 

    --MjXzGamePanel.ChupaiMag:addChuPaiPosOffsetX( -0.4 )

    -- 碰杠区域
    MjXzGamePanel.PengGangMag = MjPgManager3D.New(self.PlayerClass , MjXzModel)
    
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
    --dump(MjXzModel.data, "<color=yellow>------------------------------------->>>> MjXzModel.data:</color>")


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

function MjXzGamePanel:OnPing(ping)
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


function MjXzGamePanel:SetHideMenu()
    self.MenuBG.gameObject:SetActive(false)
    self.TopButtonImage.gameObject:SetActive(false)
end
function MjXzGamePanel:Start()
    -- self:MyRefresh()

end
-- 初始化
function MjXzGamePanel:MyInit()
    self:MakeLister()
    MjXzLogic.setViewMsgRegister(lister,listerRegisterName)
end

function MjXzGamePanel:showOrHideGameDesk(status )

    if MjXzModel.checkIsEr() then
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

end










--- 指示灯显示or隐藏
function MjXzGamePanel:showOrHideZhishideng(pos,status )
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
function MjXzGamePanel:UpdateCall()
    local dt = timeStep
    if self.countdown and self.countdown > 0 then 
        self.countdown = self.countdown - dt
    end
    for k,call in pairs(self.TimeCallDict) do
        call(self)
    end
end

function MjXzGamePanel:UpdateDelayCall()
    if self.scoreChangeDelay then
        self.scoreChangeDelay = self.scoreChangeDelay - updateDelayStep
        if self.scoreChangeDelay < 0 then
            self.scoreChangeDelay = 0
        end
    end


end

-- UI关注的事件
function MjXzGamePanel:MakeLister()
    lister = {}
    
    lister["ping"] = basefunc.handler(self,self.OnPing) 

    ---------------------------------- new
    --模式
    lister["model_nor_mg_enter_room_msg"] = basefunc.handler(self, self.nor_mg_enter_room_msg)
    lister["model_nor_mg_join_msg"] = basefunc.handler(self, self.nor_mg_join_msg)
    lister["model_nor_mg_score_change_msg"] = basefunc.handler(self, self.nor_mg_score_change_msg)
    lister["model_nor_mg_rank_msg"] = basefunc.handler(self, self.nor_mg_rank_msg)
    lister["model_nor_mg_wait_result_msg"] = basefunc.handler(self, self.nor_mg_wait_result_msg)
    lister["model_nor_mg_promoted_msg"] = basefunc.handler(self, self.nor_mg_promoted_msg)
    lister["model_nor_mg_gameover_msg"] = basefunc.handler(self, self.nor_mg_gameover_msg)
    lister["model_nor_mg_req_cur_player_num_response"] = basefunc.handler(self, self.on_nor_mg_req_cur_player_num__response)

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

    lister["model_nor_mg_wait_revive_msg"] = basefunc.handler(self, self.nor_mg_wait_revive_msg)
    lister["model_nor_mg_free_revive_msg"] = basefunc.handler(self, self.nor_mg_free_revive_msg)
    lister["model_nor_mg_revive_response"] = basefunc.handler(self,self.nor_mg_revive_response)
end

function MjXzGamePanel:set_erRen_about()
    -----
    if MjXzModel.game_type and MjXzModel.checkIsEr() and not self.isSetEr then
        self.isSetEr = true
        print("<color=yellow>-------------- 调整已出牌的位置<color>")
        --- 一行改成放8个
        MjXzGamePanel.ChupaiMag:setMaxLine(8) 

        MjXzGamePanel.ChupaiMag:addChuPaiPosOffsetX( -0.4 )

    end

    if MjXzModel.game_type and not self.isSetShouPai then
        self.isSetShouPai = true
        for i = 1, #self.PlayerClass do
            local playerInfo = MjXzModel.GetPosToPlayer(i)
            if playerInfo then
                self.PlayerClass[i]:adjustShouPaiPos()
            end
        end 
    end
end

local function HuanPaiCountdown(self)
    if self.countdown and self.countdown > 0 then
        self.huanPaiCd.text = string.format("(%02d)" , math.ceil(self.countdown))
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
function MjXzGamePanel:MyRefresh()
    local m_data = MjXzModel.data
    if m_data then
        MjXzGamePanel.RefreshBGM()
        --- 桌面ui
        print("<color=yellow>--------------------- MjXzGamePanel:MyRefresh , m_data.init_stake: </color>",m_data.init_stake)

        if not self.stakeUpdater then
            self.stakeUpdater = Timer.New( function() 
                if not self.isSetMjDeskUi then
                    self.isSetMjDeskUi = true
                    if m_data.init_stake then
                        self.deskCenterMgr:setBaseScore(m_data.init_stake)
                        --print("<color=yellow>---------- stakeUpdater update </color>")
                    else
                        --print("<color=yellow>---------- self.isSetMjDeskUi false </color>")
                        self.isSetMjDeskUi = false
                    end
                    if not self.isSetMjDeskTitleUi then
                        self.isSetMjDeskTitleUi = true
                        if MjXzModel.checkIsEr() then
                            self.deskCenterMgr:setMjTypeDeskUi("mj_game_imgf_ermj")
                        else
                            self.deskCenterMgr:setMjTypeDeskUi("mj_game_imgf_xz")
                        end
                    end
                else
                    return
                end
            end , 1, -1, true)
            self.stakeUpdater:Start()

        end
        
        self:set_erRen_about()

        local m_data = MjXzModel.data
        self.countdown = math.floor(m_data.countdown)
        dump(m_data.model_status, "<color=red>m_data.model_status</color>")
        if m_data.model_status then
            if not self.refreshInTablePlayerNum then
                self.refreshInTablePlayerNum = Timer.New(basefunc.handler(self, self.RefreshGamingPlayerNum), 2, -1, false)
                self.refreshInTablePlayerNum:Start()
            end
        end

        self:HideWaitPanel()
        self:HideRevivePanel()
        if not m_data.model_status then
            print("<color=red>状态为空，等待AllInfo消息</color>")
            if MatchModel.CheckStartTypeIsRMJK() then
                ComMatchWaitStartPanel.Create({model = MjXzModel,logic = MjXzLogic,ani = MjAnimation})
            else
                ComMatchWaitRematchPanel.Create()
            end
            ComMatchRankPanel.Close()
        elseif m_data.model_status == MjXzModel.Model_Status.gameover then
            --MjXzMatchERClearing3D.Create()
            self:CreateRankPanel()
        elseif m_data.model_status == MjXzModel.Model_Status.wait_begin then
            --MjXzMatchERClearing3D.Close()
            --等待开始界面
            if MatchModel.CheckStartTypeIsRMJK() then
                ComMatchWaitStartPanel.Create({model = MjXzModel,logic = MjXzLogic,ani = MjAnimation})
            else
                ComMatchWaitRematchPanel.Create()
            end
            
            ComMatchRankPanel.Close()
        elseif m_data.model_status == MjXzModel.Model_Status.wait_table then
            if MatchModel.CheckStartTypeIsRMJK() then
                ComMatchWaitStartPanel.CloseUI()
            else
                ComMatchWaitRematchPanel.CloseUI()
            end
            ComMatchRankPanel.Close()
            --self.mj_match_pairdesk_ui.gameObject:SetActive(true)
            --self:ShowOrHideDdzView(false)
            --self:ShowOrHideWarningView(false)
            --self.cardsRemainUI[2].gameObject:SetActive(false)
            --self.cardsRemainUI[3].gameObject:SetActive(false)

            --SpineManager.RemoveAllDDZPlayerSpine()

            self.PairdeskClass:Show(m_data.countdown)
            self:showOrHideGameDesk(false)
            self:showOrHideZhishideng( -1 , false)

            self:ClearAllCards()
        elseif m_data.model_status == MjXzModel.Model_Status.reviveing or m_data.model_status == MjXzModel.Model_Status.give_up_reviveing then
            print("复活中和放弃复活中暂不处理")
        else
            ComMatchRankPanel.Close()
            if MatchModel.CheckStartTypeIsRMJK() then
                ComMatchWaitStartPanel.CloseUI()
            else
                ComMatchWaitRematchPanel.CloseUI()
            end
            self.mj_match_pairdesk_ui.gameObject:SetActive(false)

            if m_data.init_stake then
                self.DFText.text = "底分：" .. m_data.init_stake
            end
            self.PairdeskClass:Hide()
            self:showOrHideGameDesk(true)
            
            self:RefreshPlayer()
            
            self.ChangeDeskButton.gameObject:SetActive(false)
            if m_data.hu_data_map and m_data.hu_data_map[m_data.seat_num] then
                -- self.ChangeDeskButton.gameObject:SetActive(true)
                self.ChangeDeskButton.gameObject:SetActive(false)
            end

            -- 这个一定要在  RefreshCenter 之前  ↓↓
            if MjXzModel.checkIsEr() then
                self.deskCenterMgr:refreshZhuangjiaZhishideng_erRen( MjXzModel )  
            else
                self.deskCenterMgr:refreshZhuangjiaZhishideng( MjXzModel )  
            end
            self:RefreshCenter()

            if MjXzModel.checkIsEr() then
                self.deskCenterMgr:refreshRemainCard_erRen(MjXzModel)
            else
                self.deskCenterMgr:refreshRemainCard(MjXzModel)
            end
            

            print("<color=yellow> MjXzGamePanel:MyRefresh </color>")

            self:RefreshHuanSanZhang()

            --self:RefreshClearing()
            self:RefreshDingqueStatus()
            --刷新托管
            self:RefreshAutoStatus()

            self:RefreshPermit()
            --刷新轮数
            self:RefreshRound()
            ---- 刷新排名
            self:RefreshRank()

            --等待
            self:RefreshWait()

            --晋级
            self:RefreshPromoted()

            self:RefreshDapiaoStatus()
            self:RefreshTouSezi()
            self:RefreshRevive()
        end

    end
end

function MjXzGamePanel:RefreshTouSezi()
    local m_data = MjXzModel.data
    if not m_data or not m_data.status or not m_data.countdown or m_data.status ~= MjXzModel.Status.tou_sezi then
        return

    end

    local passTime = self.deskCenterMgr.touseziAcTime - m_data.countdown

    if passTime < touseziDelayTime then
        MjAnimation.DelayTimeAction(function()
            self.deskCenterMgr:testShaiziAnimation(MjXzModel , 0 )
        end , passTime)
    else
        self.deskCenterMgr:testShaiziAnimation(MjXzModel , passTime - touseziDelayTime )
    end
    

end 

-- 刷新游戏结算界面
function MjXzGamePanel:RefreshClearing()
    if MjXzModel.data.status==MjXzModel.Status.settlement then
        MjXzMatchERClearing3D.Create(self.transform)
    else
        MjXzMatchERClearing3D.Close()
    end
end
-- 刷新中间区域(方位)
function MjXzGamePanel:RefreshCenter()

    self.OperTimeTextL.text = ""
    self.OperTimeTextR.text = ""
    self.OperTimeTextRRed.text = ""
    self.OperTimeTextLRed.text = ""
    self.CardNumText.text = ""
    self.RateNumText.text = ""

    local data = MjXzModel.data
    if data then

        self.countdown = math.floor(MjXzModel.data.countdown)
        --self.CenterRect.gameObject:SetActive(true)
        if data.cur_p and data.cur_p > 0 then
            self:showOrHideZhishideng(MjXzModel.GetSeatnoToPos(data.cur_p),true)
        else
            --- 如果有庄家
            if data.zjSeatno and data.zjSeatno~=0 then
                self:showOrHideZhishideng(MjXzModel.GetSeatnoToPos(data.zjSeatno),true)
            else
                self:showOrHideZhishideng(-1,false)
            end

            

            --[[for i=1,4 do
                self.zhishideng[i].gameObject:SetActive(false)
                self:showOrHideOneZhishideng(i , false)

                self.headLGNode[i].gameObject:SetActive(false)
                if self.headBGLGTime[i] then
                    self.headBGLGTime[i]:Stop()
                end    
                if self.headBGLGCGTime[i] then
                    self.headBGLGCGTime[i]:Kill()
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
function MjXzGamePanel:SetRemainCard()
    self.CardNumText.text = MjXzModel.GetRemainCard ()
    if MjXzModel.GetRemainCard() == 4 then
        MjAnimation.ShowLast4Pai(Vector3.New(0,-300,0),Vector3.New(0,0,0))
    end
end
function MjXzGamePanel:SetRate()
    if MjXzModel.data.cur_race and MjXzModel.data.sumRace then
        self.RateNumText.text = MjXzModel.data.cur_race .. "/".. MjXzModel.data.sumRace
    else
        self.RateNumText.text = "-/-"
    end
end
function MjXzGamePanel:MyExit()
    DOTweenManager.CloseAllSequence()
    SysInteractivePlayerManager.Close()
    SysInteractiveChatManager.Hide()
    self:HideWaitPanel()
    self:HideRevivePanel()

    if self.stakeUpdater then
        self.stakeUpdater:Stop()
        self.stakeUpdater=nil
    end    
    if self.updateTimer then
        self.updateTimer:Stop()
        self.updateTimer=nil
    end
    if self.updateDelay then
        self.updateDelay:Stop()
        self.updateDelay=nil
    end
    self.cardObj = nil

    for i=1,#self.PlayerClass do
        self.PlayerClass[i]:MyExit()
    end

    for i=1, 4 do
        if self.headBGLGTime[i] then
            self.headBGLGTime[i]:Stop()
            self.headBGLGTime[i] = nil
        end    
        if self.headBGLGCGTime[i] then
            self.headBGLGCGTime[i]:Kill()
            self.headBGLGCGTime[i] = nil
        end   
    end

    if self.refreshInTablePlayerNum then
        self.refreshInTablePlayerNum:Stop()
        self.refreshInTablePlayerNum = nil
    end

    if self.delayShowRank then
        self.delayShowRank:Stop()
        self.delayShowRank = nil
    end

    --[[if self.majiang_fj then
        GameObject.Destroy( self.majiang_fj.gameObject )
        self.majiang_fj = nil
    end

    if self.lights then
        GameObject.Destroy( self.lights.gameObject )
        self.lights = nil
    end--]]


    MjXzLogic.clearViewMsgRegister(listerRegisterName)
    
    ComMatchRankPanel.Close()

    self.deskCenterMgr:MyExit()
    MjXzGamePanel.ChupaiMag:MyExit()
    MjXzGamePanel.PengGangMag:MyExit()

    is_bsks = nil
    --closePanel(MjXzGamePanel.name)
end
function MjXzGamePanel:MyClose()
    DSM.PopAct()
    self:MyExit()
    closePanel(MjXzGamePanel.name)
end
--[[***********************
UI关注的消息
***********************--]]

--检测action msg是否已经执行
function MjXzGamePanel:check_action_isrun(data)
    if data.type~="cp" or  MjXzModel.GetSeatnoToPos(data.p)~=1 then
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
        local seatno = MjXzModel.GetSeatnoToPos(data.p)
        self.PlayerClass[seatno]:BackChupai()
        self.last_action_msg=nil
        return false
    end


end


function  MjXzGamePanel:ShowOrHideOperRect(status)
    self.OperRect.gameObject:SetActive(status)
end

function MjXzGamePanel:Permit()
    if MjXzModel.data then

        local my_s=MjXzModel.data.seat_num
        local pgh_data=MjXzModel.data.pgh_data
        self:ShowOrHideOperRect(false)

        if MjXzModel.data.status == MjXzModel.Status.ding_que then
            --刷新定缺状态
            self:RefreshDingqueStatus()
        elseif MjXzModel.data.status == MjXzModel.Status.da_piao then
            self:RefreshDapiaoStatus()
        elseif MjXzModel.data.status == MjXzModel.Status.huan_san_zhang then
            -- 
            self:RefreshHuanSanZhang()
        else
            if MjXzModel.data.status == MjXzModel.Status.mo_pai then
                local uipos = MjXzModel.GetSeatnoToPos(MjXzModel.data.cur_p)
                self.PlayerClass[uipos]:MopaiPermit(MjXzModel.data.cur_mopai)

                self.PlayerClass[1]:hideAllHint()
            end
            if MjXzModel.data.status == MjXzModel.Status.chu_pai or MjXzModel.data.status == MjXzModel.Status.start then
                local uipos = MjXzModel.GetSeatnoToPos(MjXzModel.data.cur_p)
                self.PlayerClass[uipos]:ChupaiPermit()
            end

            --我自己
            print("<color=yellow>----------------- Permit 1</color>",MjXzModel.data.cur_p , MjXzModel.data.seat_num)
            if MjXzModel.data.cur_p == MjXzModel.data.seat_num then
                print("<color=yellow>----------------- Permit 2</color>")
                if pgh_data then
                    print("<color=yellow>----------------- Permit 3</color>")
                    self:ShowOrHideOperRect(true)
                    local pos=1
                    if pgh_data.guo then
                        self.GuoButton.gameObject:SetActive(true)
                        pos=pos+1
                    else
                        self.GuoButton.gameObject:SetActive(false)
                    end
                    if pgh_data.peng then
                        print("<color=yellow>----------------- Permit 4</color>")
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
                        self.PlayerClass[1]:showAllHint( )
                    else
                        self.HuButton.gameObject:SetActive(false)
                    end
                end
            end
        
        end
    end
    self:RefreshCenter()

    if MjXzModel.checkIsEr() then
        self.deskCenterMgr:refreshRemainCard_erRen(MjXzModel)
    else
        self.deskCenterMgr:refreshRemainCard(MjXzModel)
    end
end

function MjXzGamePanel:RefreshPermit()
    if MjXzModel.data then

        local my_s=MjXzModel.data.seat_num
        local pgh_data=MjXzModel.data.pgh_data
        self:ShowOrHideOperRect(false)

        if MjXzModel.data.status == MjXzModel.Status.ding_que then
            --刷新定缺状态
            self:RefreshDingqueStatus()
        else
            if MjXzModel.data.status == MjXzModel.Status.mo_pai then
                local seatno = MjXzModel.GetSeatnoToPos(MjXzModel.data.cur_p)
                self.PlayerClass[seatno]:RefreshMopaiPermit(MjXzModel.data.cur_mopai)
            end
            if MjXzModel.data.status == MjXzModel.Status.chu_pai or MjXzModel.data.status == MjXzModel.Status.start then
                local seatno = MjXzModel.GetSeatnoToPos(MjXzModel.data.cur_p)
                self.PlayerClass[seatno]:RefreshChupaiPermit()
            end

            --我自己
            if MjXzModel.data.cur_p == MjXzModel.data.seat_num then
                if pgh_data then
                    self:ShowOrHideOperRect(true)
                    local pos=1
                    if pgh_data.guo then
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
function MjXzGamePanel:RefreshDingqueHint(pos,status)
    print("RefreshDingqueHint == " .. pos .. "  " .. (status or "nil"))
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
            local playerData = MjXzModel.GetPosToPlayer(1)
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
function MjXzGamePanel:RefreshDingqueColor(pos,status)
    if status and status>0 and status<4 then
        self.dingque_b[pos].gameObject:SetActive(true)
        --   切换定缺 color
        self.dingque_c[pos].sprite=GetTexture(huase_image[status])
    else
        self.dingque_b[pos].gameObject:SetActive(false)
    end
end

function MjXzGamePanel:RefreshDingqueStatus()


    --- 二人麻将直接不刷新定缺
    if MjXzModel.checkIsEr() then
        return
    end
    
    local status=MjXzModel.data.status 
    local playerInfo=MjXzModel.data.playerInfo

    if status and playerInfo then
        for i=1,4 do
            local pos=MjXzModel.GetSeatnoToPos(i)
            self:RefreshDingqueHint(pos, playerInfo[i].lackColor)
        end
        
    else
        --全部隐藏
        for i=1,4 do
            self:RefreshDingqueHint(i, -2)
        end
    end
end

function MjXzGamePanel:HideDQParticle()
    MjAnimation.TJColorOnKill(self.tongTJTween,self.TongImage.transform)
    MjAnimation.TJColorOnKill(self.tiaoTJTween,self.TiaoImage.transform)
    MjAnimation.TJColorOnKill(self.wanTJTween,self.WanImage.transform)

    self.tongTJTween = nil
    self.tiaoTJTween = nil
    self.wanTJTween = nil
end

function MjXzGamePanel:ClearTJ()
    MjAnimation.TJColorOnKill(self.tongTJTween,self.TongImage.transform)
    MjAnimation.TJColorOnKill(self.tiaoTJTween,self.TiaoImage.transform)
    MjAnimation.TJColorOnKill(self.wanTJTween,self.WanImage.transform)

    self.tongTJTween = nil
    self.tiaoTJTween = nil
    self.wanTJTween = nil
end

function MjXzGamePanel:model_nor_mj_xzdd_huansanzhang_msg( is_time_out )
    if not is_time_out then
        if MjXzModel.data and MjXzModel.data.huanSanZhangNewVec then
            self.PlayerClass[1].ShouPai:huanPai( MjXzModel.data.huanSanZhangNewVec , MjXzModel.data.playerInfo[MjXzModel.data.seat_num].spList )
        end
    end

end

function MjXzGamePanel:model_nor_mj_xzdd_huan_pai_finish_msg()
    self:RefreshHuanSanZhang()
    MjXzModel.clearHuanSanZhangData()
end

function MjXzGamePanel:model_huanSanZhang_num_change_msg()
    self.nowSelectSanZhangText.text = string.format( "%d" , 3-#MjXzModel.data.huanSanZhangVec ) 
end


function MjXzGamePanel:RefreshAutoStatus(pSeatNum)
    --根据状态显示和隐藏面板
    if MjXzModel.data then
        --刷新全部 
        if not pSeatNum then
            if MjXzModel.data.playerInfo then
                for i=1,MjXzModel.maxPlayerNumber do
                    repeat

                    local auto= MjXzModel.data.playerInfo[i].auto
                    local uiPos = MjXzModel.GetSeatnoToPos(i)
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

                    until true
                end
            end
        --刷新单个人
        else

            if MjXzModel.data.playerInfo then
                local auto= MjXzModel.data.playerInfo[pSeatNum].auto
                local uiPos = MjXzModel.GetSeatnoToPos(pSeatNum)
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

function MjXzGamePanel:RefreshDapiaoStatus()
    dump( MjXzModel.data.playerInfo , "<color=yellow>------------- MjXzGamePanel:RefreshDapiaoStatus ------------- </color>" )
    
    ---- 打漂图标
    local daPiaoPlayerNum = 0
    local playerInfo=MjXzModel.data.playerInfo
    for i=1 , MjXzModel.maxPlayerNumber do
        if playerInfo[i] then
            local uiPos = MjXzModel.GetSeatnoToPos(i)
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
                            self.dapiaoIcon[uiPos].sprite = GetTexture(MjXzModel.piaoIconVec[piaoNum])
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
                            self.dapiaoIcon[uiPos].sprite = GetTexture(MjXzModel.piaoIconVec[piaoNum])
                        end 
                    end
                else
                    self.dapiaoIcon[uiPos].gameObject:SetActive(false)
                end
            end
        end
    end

    if daPiaoPlayerNum == 1 then
        self.deskCenterMgr:setBaseScore( string.format("%dx2",MjXzModel.data.init_stake) )
    elseif daPiaoPlayerNum >= 2 then
        self.deskCenterMgr:setBaseScore( string.format("%dx4",MjXzModel.data.init_stake) )
    elseif daPiaoPlayerNum == 0 then
        self.deskCenterMgr:setBaseScore( string.format("%d",MjXzModel.data.init_stake) )
    end
    -----------------------
    local status=MjXzModel.data.status 
    if status ~= MjXzModel.Status.da_piao then
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
    local playerInfo=MjXzModel.data.playerInfo
    for i=1 , MjXzModel.maxPlayerNumber do
        if playerInfo[i] then
            local uiPos = MjXzModel.GetSeatnoToPos(i)

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

    if dapiaoPlayerNum == MjXzModel.maxPlayerNumber then
        self.dapiaoWaitHint[1].gameObject:SetActive(false)
    end

end

function MjXzGamePanel:RefreshHuanSanZhang()
    self.PlayerClass[1]:hideAllHint()
    self.PlayerClass[1].ShouPai:showAllMask()
    print("<color=yellow>--------------- MjXzGamePanel , RefreshHuanSanZhang </color>")
    local m_data = MjXzModel.data
    local status = m_data.status
    if status ~= MjXzModel.Status.huan_san_zhang then
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

    if MjXzModel.data.isHuanPai then
        self.huanSanZhangRect[1].gameObject:SetActive(false)
        self.TimeCallDict["HuanPaiCountdown"] = nil 
    else
         --- 
        self.PlayerClass[1]:setShouPaiActionModel( "huanSanZhang" )

        if m_data.huanSanZhangVec then
            self.PlayerClass[1]:refreshHuanSanZhangPai(m_data.huanSanZhangVec)
            self.nowSelectSanZhangText.text = string.format( "%d" , 3-#MjXzModel.data.huanSanZhangVec ) 
        end
    end

   

end

-- 刷新当前的牌
function MjXzGamePanel:S2CMoPai()
    if MjXzModel.data and MjXzModel.data.currCard and MjXzModel.data.cur_p then
        local paiData = MjXzModel.data.currCard
        local seatData = MjXzModel.data.cur_p
        if paiData then
            local uiPos = MjXzModel.GetSeatnoToPos (seatData)
            self.PlayerClass[uiPos]:AddZPPai(paiData)
        else

        end
    end
end

--发送数据***********************
function MjXzGamePanel:SendAction(data)
    table.print("<color=blue>sendAction:</color>",data)
    if Network.SendRequest("nor_mj_xzdd_operator", data) then
        return true
    else
        MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
        return false
    end
    
end
function MjXzGamePanel:SendDingque(val)
    self:HideDQParticle()
    if self:SendAction({type="dq", pai = val}) then
        --刷新我的定缺状态 （将 定缺按钮隐藏 状态改变为 等待其他玩家定缺）
        self:RefreshDingqueHint(1,0)
    end
end

function MjXzGamePanel:SendDaPiao(val)
    if Network.SendRequest("nor_mj_xzdd_dapiao", { piaoNum = val }) then
        
        return true
    else
        MJAnimation.Hint(2,Vector3.New(0,-350,0),Vector3.New(0,0,0))
        return false
    end
end

function MjXzGamePanel:SendHuanSanZhang(paiVec)
    print("<color=yellow>-----------------  MjXzGamePanel:SendHuanSanZhang </color>")
    local data = { paiVec = paiVec }


    if Network.SendRequest("nor_mj_xzdd_huansanzhang", data) then
        MjXzModel.data.isCanOpPai = false
        return true
    else
        return false
    end
end

function MjXzGamePanel:SendPengCB()
    local pgh_data=MjXzModel.data.pgh_data
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
function MjXzGamePanel:SendGangCB(act)
    local pgh_data=MjXzModel.data.pgh_data
    local gang
    if pgh_data then
        gang=pgh_data.gang
    end
    if not gang then
        --没有出牌权限        
    end
    if #gang > 1 then
        --展示提示
        MjXzGangsRect.Create(self.gameObject, gang, function (act)
            self:SendGang(act)
        end)
    else
        local act={type="gang", pai=gang[1].pai}
        self:SendGang(act)
    end
end
function MjXzGamePanel:SendGang(act)
    if self:SendAction(act) then
        if act.type == "gang" then
            self.PlayerClass[1]:SetSendCP()
        end
        --按钮隐藏
        self:ShowOrHideOperRect(false)
    end
end


function MjXzGamePanel:SendHuCB(val)
    local pgh_data=MjXzModel.data.pgh_data
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
function MjXzGamePanel:SendGuoCB()
    if self:SendAction({type="guo"}) then
        --按钮隐藏
        self:ShowOrHideOperRect(false)

        ----- 提示的牌取消提示
        local pgh_data = MjXzModel.data.pgh_data

        self.PlayerClass[1]:hideAllHint()
        

    end
end
--发送数据***********************

-- 播放骰子动画
function MjXzGamePanel:PlaySaiZi(val1, val2)
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
        local uiPos = MjXzModel.GetSeatnoToPos (MjXzModel.data.zjSeatno)
        self.PlayerClass[uiPos]:SetZJ(true)
    end)
end
-- 暂停骰子动画
function MjXzGamePanel:StopSaiZi()
    self.SaiZiAnimNode:SetActive(false)
end

function MjXzGamePanel:RefreshScore(p_seat)
    if MjXzModel.data then
        if p_seat then
            local player = self.PlayerClass[p_seat]
            local score
            if
                MjXzModel.data.players_info and MjXzModel.data.seatNum and
                    MjXzModel.data.players_info[MjXzModel.data.seatNum[p_seat]]
             then
                score = MjXzModel.data.players_info[MjXzModel.data.seatNum[p_seat]].score
                if score then
                    player:ChangeScore( score )
                end
            end
        else
            for p_seat = 1, MjXzModel.maxPlayerNumber do
                local player = self.PlayerClass[p_seat]
                local score
                if p_seat == 1 then
                    score = MjXzModel.data.score
                else
                    score = MjXzModel.data.players_info[MjXzModel.data.seatNum[p_seat]].score
                end
                if score then
                    player:ChangeScore( score )
                end
            end
        end
    end
end

function MjXzGamePanel:RefreshRank()
    if MjXzModel.data then
        local player = self.PlayerClass[1]
        if MjXzModel.data.rank and MjXzModel.data.total_players then
            if MjXzModel.data.match_player_num and MjXzModel.data.rank <= MjXzModel.data.match_player_num then
                player:SetRank(MjXzModel.data.rank .. "/" .. MjXzModel.data.match_player_num)
            else
                player:SetRank(MjXzModel.data.rank .. "/" .. MjXzModel.data.total_players)
            end
        elseif MjXzModel.data.total_players then
            player:SetRank(MjXzModel.data.total_players .. "/" .. MjXzModel.data.total_players)
        end
    end
end

--刷新等待
function MjXzGamePanel:RefreshWait()
    if MjXzModel.data then
        --玩家在配桌界面直接进入游戏需要隐藏
        self.mj_match_pairdesk_ui.gameObject:SetActive(false)
        local myData = MjXzModel.data
        if myData.model_status == MjXzModel.Model_Status.wait_result then
            SysInteractivePlayerManager.Close()
            SysInteractiveChatManager.Hide()
            self:ShowWaitPanel()
        end
    end
end

--刷新晋级
function MjXzGamePanel:RefreshPromoted(is_ani)
    if MjXzModel.data then
        --玩家在配桌界面直接进入游戏需要隐藏
        self.mj_match_pairdesk_ui.gameObject:SetActive(false)
        self:RefreshWait()
        local myData = MjXzModel.data
        if myData.model_status == MjXzModel.Model_Status.promoted then
            if myData.promoted_type then
                --0表示普通晋级 1表示晋级决赛
                local isMatch = myData.promoted_type == 1
                ExtendSoundManager.PlaySound(audio_config.match.bgm_bisai_jinji.audio_name)
                SysInteractivePlayerManager.Close()
                SysInteractiveChatManager.Hide()
                self:ShowWaitPanel(is_ani)
            end
        end
    end
end

-- 刷新游戏玩家
function MjXzGamePanel:RefreshPlayer(seatno)
    local m_data = MjXzModel.data
    if m_data then
        if m_data.model_status == MjXzModel.Model_Status.wait_table or m_data.model_status == MjXzModel.Model_Status.wait_begin then
            for i = 1, #self.PlayerClass do
                local playerInfo = MjXzModel.GetPosToPlayer(i)
                if playerInfo then
                    self.PlayerClass[i]:Refresh()
                end
            end
        else
            if seatno then
                local uiPos = MjXzModel.GetSeatnoToPos(seatno)
                self.PlayerClass[uiPos]:Refresh()
            else
                
                for i = 1, #self.PlayerClass do
                    -- if playerInfo and i <= #playerInfo and playerInfo[i] then
                    --local uiPos = MjXzModel.GetSeatnoToPos(i)

                    local playerInfo = MjXzModel.GetPosToPlayer(i)
                    if playerInfo then
                        print("<color=yellow>--------------------- MjXzGamePanel:RefreshPlayer: </color>",i)
                        dump(playerInfo , "<color=yellow>--------------------- MjXzGamePanel:RefreshPlayer: dump </color>")
                        self.PlayerClass[i]:Refresh()
                    end
                end
            end
        end
    end
end

function MjXzGamePanel:RefreshRound()
    if MjXzModel.data then
        local round_info = MjXzModel.data.round_info
        local race = MjXzModel.data.race
        self.cur_match_txt.gameObject:SetActive(false)
        self.cur_base_score_txt.gameObject:SetActive(false)
        self.jcs_info.gameObject:SetActive(false)
        --self.dizhu_card_son.cur_multiple_txt.gameObject:SetActive(false)
        if round_info then
             --此轮晋级人数 此轮的局数
             if round_info.round_type == 0 then
                --初赛
                self.cur_match_txt.text = "预赛 第" .. round_info.round .. "局（低于" .. round_info.rise_score .. "分将被淘汰）"
                self.jcs_info.gameObject:SetActive(false)
            elseif round_info.round_type == 1 then
                --决赛
                self.cur_match_txt.text = "晋级赛 第" .. round_info.round .. "局 " .. round_info.rise_num .. "人晋级"
                --self.cur_match_txt.gameObject:SetActive(true)
                self.jcs_round_txt.text = round_info.round
                self.jcs_total_txt.text = round_info.rise_num
            end

            if race and round_info.race_count then
                self.cur_pai_race_txt.text = "第" .. race .. "副（共" .. round_info.race_count .. "副）"
            end
            self.jcs_info.gameObject:SetActive(true)
            --此轮的底分
            if round_info.init_stake then
                if round_info.round_type == 0 then
                    --初赛
                    self.cur_base_score_txt.text = "预赛 底分" .. round_info.init_stake
                elseif round_info.round_type == 1 then
                    --决赛
                    self.cur_base_score_txt.text = "晋级赛 底分" .. round_info.init_stake
                end
                --self.cur_base_score_txt.gameObject:SetActive(true)
            end
            --此轮的初始倍率
            --[[if round_info.init_rate and MjXzModel.data.my_rate then
                self.dizhu_card_son.cur_multiple_txt.text = MjXzModel.data.my_rate .. "倍"
                self.dizhu_card_son.cur_multiple_txt.gameObject:SetActive(true)
            end--]]
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------- new
function MjXzGamePanel:nor_mg_enter_room_msg()
    MjXzGamePanel.PlayBSKS()
    self:MyRefresh()
end

function MjXzGamePanel:nor_mg_join_msg(seat_num)
    --self:RefreshPlayerInfo(MjXzModel.data.s2cSeatNum[seat_num])

    --local uiPos = MjXzModel.GetSeatnoToPos (seatno)
    --local uiPos = MjXzModel.data.s2cSeatNum[seat_num]

    local uiPos = MjXzModel.GetSeatnoToPos (seat_num)
    self.PlayerClass[uiPos]:PlayerEnter()
end

function MjXzGamePanel:nor_mg_score_change_msg()
    self:RefreshScore(1)
end

function MjXzGamePanel:nor_mg_rank_msg()
    self:RefreshRank()
end

function MjXzGamePanel:nor_mg_wait_result_msg()
    self:RefreshWait()
end

function MjXzGamePanel:nor_mg_promoted_msg()
    self:RefreshPromoted(true)
end

function MjXzGamePanel:nor_mg_gameover_msg()
    --self:RefreshWait()
    local gameCfg = MatchModel.GetGameCfg(MatchModel.data.game_id)
    if MjXzModel.data.model_status == MjXzModel.Model_Status.gameover then
        if gameCfg.round and #gameCfg.round > 0 and MjXzModel.GetCurRoundId() < #gameCfg.round then
            self:ShowWaitPanel()
            self:DelayShowRank()
        else
            self:CreateRankPanel()
        end
    end
end

function MjXzGamePanel:nor_mg_wait_revive_msg(data)
    if not MjXzModel.data then return end
    self:RefreshRevive()
end

function MjXzGamePanel:nor_mg_free_revive_msg()
    self:HideRevivePanel()
end

function MjXzGamePanel:nor_mg_revive_response(data)
    if data.result == 0 then
        self:HideRevivePanel()
    end
end

function MjXzGamePanel:DelayShowRank()
    if self.delayShowRank then
        self.delayShowRank:Stop()
        self.delayShowRank = nil
    end

    self.delayShowRank = Timer.New(function()
        self:CreateRankPanel()
    end, 4, 1, false)
    self.delayShowRank:Start()
end

function MjXzGamePanel:CreateRankPanel()
    local parm = {}
    parm.game_name = MjXzModel.data.name
    parm.game_id = MjXzModel.data.game_id
    parm.fianlResult = MjXzModel.data.nor_mg_final_result
    parm.detailRanknum = MjXzModel.data.detail_rank_num
    ComMatchRankPanel.Create(parm)
    self:HideWaitPanel()
    self:HideRevivePanel()
end

------------------------------------- 玩法
--准备
function MjXzGamePanel:model_nor_mj_xzdd_ready_msg(pSeatNum)
    self:RefreshCenter()
    self:RefreshPlayer(pSeatNum)
end

--开始游戏
function MjXzGamePanel:model_nor_mj_xzdd_begin_msg()
    self:RefreshCenter()
    self:RefreshPlayer()
end

-- 操作
function MjXzGamePanel:nor_mj_xzdd_action_msg(data)
    if self:check_action_isrun(data) then
        return
    end

    self:ShowOrHideOperRect(false)

    MjXzGangsRect.Close()
    local uiPos = MjXzModel.GetSeatnoToPos( data.p )
    self.PlayerClass[uiPos]:Action(data)
end

-- 选庄 todo nmg
function MjXzGamePanel:nor_mj_xzdd_tou_sezi_msg()
    local function tsz()
        -- 动画
        --self:PlaySaiZi(MjXzModel.data.sezi_value1, MjXzModel.data.sezi_value2)
        self:SetRemainCard()
        self:SetRate()
    end
    --显示开局动画
    if MjXzModel.data.race == 1 then
        MJParticleManager.MJKaiJu(tsz)
    end

    ----
    if MjXzModel.checkIsEr() then
        self.deskCenterMgr:refreshZhuangjiaZhishideng_erRen(MjXzModel)
    else
        self.deskCenterMgr:refreshZhuangjiaZhishideng(MjXzModel)
    end
    
    local uiPos = MjXzModel.GetSeatnoToPos (MjXzModel.data.zjSeatno)
    self.PlayerClass[uiPos]:SetZJ(true)


    --- 投色子的时候做麻将出牌口的降低&升起
    --- 延迟做动作...
    MjAnimation.DelayTimeAction(function()
        if MjXzModel.checkIsEr() then
            self.deskCenterMgr:cardDoorAnimation_erRen(MjXzModel)
        else
            self.deskCenterMgr:cardDoorAnimation(MjXzModel)
        end
        --print("<color=yellow> !!!!! do  cardDoorAnimation </color>")
    end , 0.2)

    ----- 投骰子
    MjAnimation.DelayTimeAction(function() 
        self.deskCenterMgr:testShaiziAnimation(MjXzModel,0)
        ExtendSoundManager.PlaySound(audio_config.mj.sod_majiang_castdice.audio_name)
    end , touseziDelayTime)

    --- 显示庄家位置
    self:showOrHideZhishideng(MjXzModel.GetSeatnoToPos( MjXzModel.data.zjSeatno ),true)

end

-- 发牌（开始游戏）
function MjXzGamePanel:nor_mj_xzdd_pai_msg()
    -- 自己的UI位置
    for i = 1, #self.PlayerClass do
        local playerInfo = MjXzModel.GetPosToPlayer(i)
        if playerInfo then
            
            self.PlayerClass[i]:PlayerFapai()
        end
    end
    --self:RefreshMenu()
    self:RefreshCenter()

    if MjXzModel.checkIsEr() then
        self.deskCenterMgr:refreshRemainCard_erRen(MjXzModel , true)
    else
        self.deskCenterMgr:refreshRemainCard(MjXzModel , true)
    end
    ComMatchWaitPanel.ShowPromotionInfo(MatchModel.data.game_id,MjXzModel.data.round_info)
end

-- 权限
function MjXzGamePanel:nor_mj_xzdd_permit_msg()
    if MjXzModel.data.cur_p == 0 then
        print("<color=red>权限拥有者是0</color>")
    end
    self:Permit()
end

-- 分数改变
function MjXzGamePanel:nor_mj_xzdd_grades_change_msg(data)
    print("<color=red>钱变化 nor_mj_xzdd_grades_change_msg</color>")
    if MjXzModel.data and MjXzModel.data.moneyChange then
        self.scoreChangeDelay = self.scoreChangeDelay or 0
        for i, v in ipairs(MjXzModel.data.moneyChange) do
            --local seatno = MjXzModel.GetSeatnoToPos(v.cur_p)
            --self.PlayerClass[seatno]:ChangeMoney(v.score)
            local uipos = v.cur_p
            local score = v.score
            MjAnimation.DelayTimeAction(function() 
                local seatno = MjXzModel.GetSeatnoToPos(uipos)
                self.PlayerClass[seatno]:ChangeMoney(score)
            end , self.scoreChangeDelay)
        end

        self.scoreChangeDelay = self.scoreChangeDelay + self.scoreChangeDelayCount
    end
end

function MjXzGamePanel:nor_mj_xzdd_dingque_result_msg()
    self:RefreshDingqueStatus()
    --定缺动画 将花色飞过去
    for i = 1, 4 do
        MjAnimation.DQIcon(self.dingque_b[i])
    end
    --清除定缺特效
    self:ClearTJ()

    for i = 1, 4 do
        local playerInfo = MjXzModel.GetPosToPlayer(i)
        if playerInfo then
            self.PlayerClass[i]:Dingque({pai = playerInfo.lackColor})
        end
    end
end

--托管
function MjXzGamePanel:nor_mj_xzdd_auto_msg(pSeatNum)
    self:RefreshAutoStatus(pSeatNum)
end

-- 结算
function MjXzGamePanel:nor_mj_xzdd_settlement_msg(pSeatNum)
    --- 移除掉手牌的回调函数
    self.PlayerClass[1].ShouPai:removeShouPaiCallBack()
    --- 指针位置还原
    MjXzGamePanel.ChupaiMag:restoreMjHint()

    --self:RefreshClearing()
end

-- 结算
function MjXzGamePanel:nor_mj_xzdd_next_game_msg()
    self:MyRefresh()
    --新的局数
    if MjXzModel.data then
        local curRace = MjXzModel.data.race
        if curRace then
            MjAnimation.CurRace(curRace, self.start_again_cards_pos)
        end
    end
end

--- 打漂
function MjXzGamePanel:nor_mj_xzdd_da_piao_msg(seat_num)
    if MjXzModel.data.playerInfo[seat_num] and MjXzModel.data.playerInfo[seat_num].piaoNum then
        local uiPos = MjXzModel.GetSeatnoToPos (seat_num)

        -- 播声音
        local playerInfo = MjXzModel.data.playerInfo[seat_num]
        if playerInfo and playerInfo.base then
            local sound = MjXzModel.data.playerInfo[seat_num].piaoNum == 0 and "action_nopiao" or "action_piao"
            sound = sound .. (playerInfo.base.sex == 0 and "_0" or "_1")
            ExtendSoundManager.PlaySound(audio_config.mj[sound].audio_name)
        end

        ---- 创建一个 上浮的 打漂的动画
        MjAnimation.DapiaoAnimation( MjXzModel.piaoIconVec[ MjXzModel.data.playerInfo[seat_num].piaoNum ] , self.dapiaoPosObjVec[uiPos] )
        ---- 翻牌
        self.PlayerClass[uiPos]:daPiaoFinish()

    end
    self:RefreshDapiaoStatus()
end

--- 打漂操作完了
function MjXzGamePanel:nor_mj_xzdd_da_piao_finish_msg()
    --[[local playerInfo = MjXzModel.data.playerInfo
    for i=1,4 do
        if playerInfo[i] then
            local uiPos = MjXzModel.GetSeatnoToPos (i)

        end
    end--]]

end

function MjXzGamePanel:RefreshGamingPlayerNum()
    if MjXzModel.data.model_status ~= MjXzModel.Model_Status.wait_begin then
        Network.SendRequest("nor_mg_req_cur_player_num")
    end
end

function MjXzGamePanel:on_nor_mg_req_cur_player_num__response()    
    if MjXzModel.data.model_status == MjXzModel.Model_Status.gameover then
        return
    end
    self:RefreshRank()
end


function MjXzGamePanel:ClearAllCards()
    log("<color=green>----------------------->>> clear card.</color>")
    if self.deskCenterMgr then
        self.deskCenterMgr:showOrHideAllReaminCard(false)
    end

    if MjXzGamePanel.ChupaiMag then
        MjXzGamePanel.ChupaiMag:ClearCards()
    end

    if MjXzGamePanel.PengGangMag then
        MjXzGamePanel.PengGangMag:ClearCards()
    end
    
    if self.PlayerClass then
        for i=1, #self.PlayerClass do
            if self.PlayerClass[i] and self.PlayerClass[i].ShouPai then
                self.PlayerClass[i].ShouPai:ClearCards()
            end
        end
    end
end

--刷新背景音
function MjXzGamePanel.RefreshBGM(isCoerce)
    local data = MjXzModel.data
    if data and data.total_round and data.round_info and data.round_info.round then
        if data.total_round == data.round_info.round then
            --决赛背景音
            ExtendSoundManager.PlaySceneBGM(audio_config.match.bgm_bisai_juesai.audio_name,isCoerce)
        else
            ExtendSoundManager.PlaySceneBGM(audio_config.match.bgm_bisai_bisaizhong.audio_name,isCoerce)
        end
    end
end

function MjXzGamePanel.PlayBSKS()
    local data = MjXzModel.data
    if not is_bsks and data and data.round_info and data.round_info.round and data.round_info.round == 1 then
		is_bsks = ExtendSoundManager.PlaySound(audio_config.match.bgm_bisai_kaishi.audio_name)
    end
end


function MjXzGamePanel:ShowWaitPanel(is_ani)
    local _data = MjXzModel.data
    local data = {}
    data.state = _data.model_status
	data.game_cfg = MatchModel.GetGameCfg(_data.game_id)
	data.award_cfg = data.game_cfg.award
	data.my_rank = _data.rank
	data.match_player_num = _data.match_player_num
	data.in_table_player_num = _data.in_table_player_num
    data.one_table_player_num = MjXzModel.maxPlayerNumber
    
    data.is_pro = is_ani
    data.round_info = _data.round_info
    data.total_players = _data.total_players

    ComMatchWaitPanel.Create(data)
end

function MjXzGamePanel:HideWaitPanel()
    ComMatchWaitPanel.Close()
end

function MjXzGamePanel:RefreshRevive()
    if not MjXzModel.data then return end
    local m_data = MjXzModel.data
    if m_data.model_status == MjXzModel.Model_Status.wait_revive then
        SysInteractivePlayerManager.Close()
        SysInteractiveChatManager.Hide()
        self:ShowRevivePanel()
    end
end

function MjXzGamePanel:ShowRevivePanel()
    local _data = MjXzModel.data
    if not _data.revive_num or _data.revive_num <= 0 or not _data.revive_time or _data.revive_time <= 0 then 
        self:HideRevivePanel()
        return 
    end
    local data = {}
    data.revive_num = _data.revive_num
    data.revive_time = _data.revive_time
    data.revive_assets = _data.revive_assets
    data.revive_round = _data.revive_round
    local game_cfg = MatchModel.GetGameCfg(_data.game_id)
    ComMatchRevivePanel.Create(data,game_cfg)
end

function MjXzGamePanel:HideRevivePanel()
    ComMatchRevivePanel.Close()
end