-- 创建时间:2019-05-17
-- Panel:EliminateFXClearPanel
local basefunc = require "Game/Common/basefunc"
EliminateFXClearPanel = basefunc.class()
local C = EliminateFXClearPanel
C.name = "EliminateFXClearPanel"
local hide
local addmoney
local instance
local delay_time = {
    [1] = 0.4,
    [2] = 1,
    [3] = 1,
    [4] = 1.5
}

local jc_bg = {
    [1] = "fxgz_bg_xj",
    [2] = "fxgz_bg_zj",
    [3] = "fxgz_bg_dj",
    [4] = "fxgz_bg_jj",
}

local jc_name = {
    [1] = "fxgz_imgf_xj",
    [2] = "fxgz_imgf_zj",
    [3] = "fxgz_imgf_dj",
    [4] = "fxgz_imgf_jj",
}

function C.Create()
    instance = C.New()
    return instance
end

function C:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["view_lottery_end"] = basefunc.handler(self, self.view_lottery_end)
end

function C:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
    self:ClearMyTimer()
    self:ClearMyTween()
	for i = 1, 4 do
        self.childobjs[i] = nil
        self.childanis[i] = nil
    end
    self.childanis = {}
	self.childobjs = {}
    self:RemoveListener()
    destroy(self.gameObject)
end

function C:InitUI()
    self.childanis = {}
    self.childobjs = {}
    for i = 1, 4 do
        self.childobjs[i] = self.transform:Find(i)
        self.childanis[i] = self.childobjs[i].transform:GetComponent("Animator")
    end
    for i = 1, #self.childobjs do
        self.childobjs[i].gameObject:SetActive(false)
    end

    self.CloseButton = self.gameObject.transform:Find("Button")
    self.CloseButton.gameObject:SetActive(false)

    self.bgBlack = self.transform:Find("bg_black")
    self.bgBlackImg = self.bgBlack:GetComponent("Image")
    self.bgBlack.gameObject:SetActive(false)

    self.childobjsgoldtext = {}
    self.childobjsgoldtext[1] = self.childobjs[1].gameObject.transform:Find("Text"):GetComponent("Text")
    self.childobjsgoldtext[2] = self.childobjs[2].gameObject.transform:Find("Text"):GetComponent("Text")
    self.childobjsgoldtext[3] = self.childobjs[3].gameObject.transform:Find("Text"):GetComponent("Text")
    self.childobjsgoldtext[4] = self.childobjs[4].gameObject.transform:Find("Text"):GetComponent("Text")

    --点击次数
    self.ClickTimes = 1
    self.clearLv = 1
    self.CloseButton:GetComponent("Button").onClick:AddListener(function()
        self:OnClickCloseBtn()
    end)
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.sound = {}
    self.clearLv = 1
    self.clearMoney = 0
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function C:view_lottery_end(data)
    dump(data,"<color=blue><size=15>++++++++++结算界面++++++++++</size></color>")
    print(debug.traceback())
    local dangci = EliminateFXModel.GetAllResultLevel()
    local award = data.all_money
    self.bgBlack.gameObject:SetActive(true)
    self:ShowClear({dangci, award})
end


function C:ClearMyTimer()
    if self.hideTimer then
        self.hideTimer:Stop()
        self.hideTimer = nil
    end

    if self.addmoney then
        self.addmoney:Stop()
        self.addmoney = nil
    end
end

function C:ClearMyTween()
    if self.seq then
        self.seq:Kill()
        self.seq = nil
    end
end

--点击关闭
function C:OnClickCloseBtn()
    dump(self.ClickTimes, "<color=white>self.ClickTimes</color>")
    if self.ClickTimes == 1 and self.clearLv > 2 and self.startmoney < self.clearMoney then
        self.startmoney = self.clearMoney
        self.ClickTimes = 2
    elseif self.ClickTimes == 2 and EliminateFXModel.GetTakePoolAward() > 0 then
        self.childobjs[self.clearLv].gameObject:SetActive(false)
        self:BgTransparent(true)
        self:ShowFxjjAnim()
        self.ClickTimes = 3
    else
        if self.fxjjJb and IsEquals(self.fxjjJb.gameObject) then
            destroy(self.fxjjJb.gameObject)
            self.fxjjJb = nil
        end
        if self.jcObj and IsEquals(self.jcObj.gameObject) then
            destroy(self.jcObj.gameObject)
            self.jcObj = nil
        end
        self.ClickTimes = 1
        self:ClearMyTween()
        self:ClearMyTimer()
        self:Hide()
    end
end

--隐藏
function C:Hide()
    Event.Brocast("eliminateFX_had_settel_msg")
    self.childobjs[self.clearLv].gameObject:SetActive(false)
    self:BgTransparent(false)
    self.CloseButton.gameObject:SetActive(false)
    self.bgBlack.gameObject:SetActive(false)
    self:StopPlaySound()
    if EliminateFXModel.GetAuto() then
        Event.Brocast("auto_lottery", true)
    end
end

--展示结算界面  data包含一个用int代表的结算类型，一个int代表的得分
function C:ShowClear(data)
    dump({data[1], data[2]}, "<color=red>-------------结算界面data-----------</color>")
    self.clearLv = data[1]
    self.clearMoney = data[2]

    -- self.clearLv = 2
    -- self.clearMoney = 1000000
    local serveRate = EliminateFXModel.GetLittleSpecRate()
    local localRate = EliminateFXModel.GetAllBigGameRate(false)
    dump("<color=white>服务器计算倍率为" .. serveRate .. " 客户端计算倍率为" .. localRate .. "</color>")
    if localRate ~= serveRate then
        -- HintPanel.Create(1, "服务器计算倍率为" .. serveRate .. "\n" .. "客户端计算倍率为" .. localRate)
        local base_msg = ""
        base_msg = base_msg .. "Version:" .. gameMgr:GetVersionNumber() .. "\n"
        base_msg = base_msg .. "Device:" .. gameRuntimePlatform .. "\n"
        base_msg = base_msg .. "Platform:" .. (gameMgr:getMarketPlatform() or "nil") .. "\n"
        base_msg = base_msg .. "Channel:" .. (gameMgr:getMarketChannel() or "nil") .. "\n"

        local errorInfo = "fuxing rate diff form c and s ..." .. "client : " .. localRate .. " server : " .. serveRate
        local stack = "fuxing clear"
        local error = base_msg .. errorInfo .. "  " .. stack
        Network.SendRequest("client_breakdown_info",{error=error})
    end

    self.data = data
    self.CloseButton.gameObject:SetActive(true)
    
    --加钱动画间隔时间
    local t = 0.05
    --加钱动画开始时，显示多少金币
    local x = 1 / 4
    --加钱动画开始时候的金币数量
    self.startmoney = self.clearMoney * x
    --加钱动画持续时间
    local animtime = 4.5


    local delay_time = 0

    if self.clearLv == 4 then
        --需要延时
        delay_time = 1
    end

    if self.clearLv < 3 then
        self.startmoney = self.clearMoney
        self.childobjsgoldtext[self.clearLv].text = string.format("%.0f", data[2])
    end
    local index = 0
    local delayIndex = 0
    if self.addmoney then
        self.addmoney:Stop()
    end
    self.addmoney = nil
    self.addmoney = Timer.New(function()
            delayIndex = delayIndex + 1
            if delayIndex * t < delay_time then
                return
            end
            index = index + 1
            if self.startmoney >= self.clearMoney * 0.9 then
                self.childobjsgoldtext[self.clearLv].text = self.clearMoney
                self.CloseButton.gameObject:SetActive(true)
                if self.addmoney then
                    self.addmoney:Stop()
                end
                self.addmoney = nil
                return
            end
            self.startmoney = (1 - x) * self.clearMoney / (animtime / t) + self.startmoney
            self.childobjsgoldtext[self.clearLv].text = string.format("%.0f", self.startmoney)
        end, t, -1)
    self.addmoney:Start()
    self.childobjs[self.clearLv].gameObject:SetActive(true)
    self.childobjsgoldtext[self.clearLv].text = ""
    self:PlayAnim()
    self:PlaySound()
    self:AutoHideMyClear()
end


--播放动画
function C:PlayAnim()

end

--播放声音
function C:PlaySound()
    self.sound.isLoop = false
    self.sound.obj = nil
    if self.clearLv == 1 then
        self.sound.obj =
            ExtendSoundManager.PlaySound(
            audio_config.fxgz.bgm_fxgz_jiesuan1.audio_name,
            1,
            function()
                self.sound.obj = nil
            end)
    elseif self.clearLv == 2 then
        ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_jiesuan2.audio_name)
    elseif self.clearLv == 3 then
        self.sound.obj =
            ExtendSoundManager.PlaySound(
            audio_config.fxgz.bgm_fxgz_jiesuan3.audio_name,
            1,
            function()
                self.sound.obj = nil
            end)
    elseif self.clearLv == 4 then
        self.sound.isLoop = true
        self.sound.obj =
            ExtendSoundManager.PlaySound(
            audio_config.fxgz.bgm_fxgz_jiesuan4.audio_name,
            1,
            function()
                self.sound.obj = nil
            end)
    end
end

--停止声音
function C:StopPlaySound()
    if self.sound.isLoop and self.sound.obj then
        soundMgr:CloseLoopSound(self.sound.obj)
        self.sound.obj = nil
        self.sound.isLoop = false
    end
end

function C:AutoHideMyClear()
    self.hidetime = 10
    if self.clearLv == 1 then
        if self.clearMoney == 0 then
            self.hidetime = 1
        else
            self.hidetime = 2
        end
    elseif self.clearLv == 2 then
        self.hidetime = 2
    elseif self.clearLv == 3 then
        self.hidetime = 6
    elseif self.clearLv == 4 then
        self.hidetime = 8
    end

    local isAuto = EliminateFXModel.GetAuto()
    
    if isAuto or self.clearLv == 1 or self.clearLv == 2 then
        self.hideTimer = Timer.New(function()
            self:Hide()
        end, self.hidetime, 1, false)
        self.hideTimer:Start()
    end
end

function C:BgTransparent(isTransparent)
    if isTransparent then
        self.bgBlackImg.color = Color.New(0,0,0,0)
    else
        self.bgBlackImg.color = Color.New(0,0,0,0.8)
    end
end

--进入小游戏时，结算要显示金币从奖池喷出的动画
function C:ShowFxjjAnim()
    self.fxjjJb = newObject("UI_jc_jb", self.transform)
    local level = EliminateFXModel.data.take_pool_id
    local bgImg = jc_bg[level]
    local nameImg = jc_name[level]

    self.jcObj = newObject("EliminateFXClearJC", self.transform)
    local jcObjNameImg = self.jcObj.transform:Find("root/jcname"):GetComponent("Image")
    local jcObjBgImg = self.jcObj.transform:Find("root/jcbg"):GetComponent("Image")
    local jcObjTxt = self.jcObj.transform:Find("root/jc_num_txt"):GetComponent("Text")
    jcObjNameImg.sprite = GetTexture(nameImg) 
    jcObjBgImg.sprite = GetTexture(bgImg)
    jcObjTxt.text = EliminateFXModel.GetTakePoolAward()
    self.fxjjJb.transform.localPosition = Vector3.New(0, 210, 0)
    self.seq = DoTweenSequence.Create()
    self.seq:AppendInterval(3)
    self.seq:AppendCallback(function()
        if self.fxjjJb and IsEquals(self.fxjjJb.gameObject) then
            destroy(self.fxjjJb.gameObject)
            self.fxjjJb = nil
        end
        
        if self.jcObj and IsEquals(self.jcObj.gameObject) then
            destroy(self.jcObj.gameObject)
            self.jcObj = nil
        end
        self:ClearMyTween()
        self:ClearMyTimer()
        self:Hide()
    end)
end

