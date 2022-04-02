-- 创建时间:2019-05-17
-- Panel:EliminateSGClearPanel
local basefunc = require "Game/Common/basefunc"
EliminateSGClearPanel = basefunc.class()
local C = EliminateSGClearPanel
C.name = "EliminateSGClearPanel"
local hide
local addmoney
local instance
local delay_time = {
    [1] = 0.4,
    [2] = 1,
    [3] = 1,
    [4] = 1.5
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
    self:RemoveListener()
    if self.hideAniTimer ~= nil then
        self.hideAniTimer:Stop()
    end
    self.hideAniTimer = nil
    if self.hide then
        self.hide:Stop()
    end
    if self.addmoney then
        self.addmoney:Stop()
    end
	for i = 1, 4 do
        self.childobjs[i] = nil
        self.childanis[i] = nil
    end
    self.childanis = {}
	self.childobjs = {}
    self.hide = nil
    self.addmoney = nil
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

    self.childobjsgoldtext = {}
    self.childobjsgoldtext[1] = self.childobjs[1].gameObject.transform:Find("xsxs/GoldText/Text"):GetComponent("Text")
    self.childobjsgoldtext[2] = self.childobjs[2].gameObject.transform:Find("djdl/GoldText/Text"):GetComponent("Text")
    self.childobjsgoldtext[3] = self.childobjs[3].gameObject.transform:Find("GoldText/Text"):GetComponent("Text")
    self.childobjsgoldtext[4] = self.childobjs[4].gameObject.transform:Find("fenzhi/GoldText/Text"):GetComponent("Text")

    self.zhe_dang = self.transform:Find("zhe_dang")
    self.zhe_dang.gameObject:SetActive(false)

    self.ClickTimes = 1
    self.CloseButton:GetComponent("Button").onClick:AddListener(
        function()
            if self.ClickTimes == 1 and self.data[1] > 2 and self.startmoney < self.data[2] then
                self.startmoney = self.data[2]
                self.ClickTimes = 2
                self.zhe_dang.gameObject:SetActive(false)
            else
                self.ClickTimes = 1
                if self.hide ~= nil then
                    self.hide:Stop()
                end
                if self.hideAniTimer ~= nil then
                    self.hideAniTimer:Stop()
                end
                self.hideAniTimer = nil
                if self.addmoney ~= nil then
                    self.addmoney:Stop()
                end
                Event.Brocast("eliminateSG_had_settel_msg")
                for i = 1, #self.childobjs do
                    self.childobjs[i].gameObject:SetActive(false)
                end
                if EliminateSGModel.GetAuto() then
                    Event.Brocast("auto_lottery", true)
                end
                self.CloseButton.gameObject:SetActive(false)
                if self.soundlv3 then
                    soundMgr:CloseLoopSound(self.soundlv3)
                    self.soundlv3 = nil
                end
                if self.soundlv4 then
                    soundMgr:CloseLoopSound(self.soundlv4)
                    self.soundlv4 = nil
                end
                self.zhe_dang.gameObject:SetActive(false)
            end
        end
    )
end

function C:ctor()

	ExtPanel.ExtMsg(self)

    local parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.hide = hide
    self.data = {}
    self.addmoney = addmoney
    self:MakeLister()
    self:AddMsgListener()
    self:InitUI()
end

function C:view_lottery_end(data)
    dump(data,"<color=blue><size=15>++++++++++结算界面++++++++++</size></color>")
    print(debug.traceback())
    local dangci = EliminateSGModel.GetAllResultLevel()
    local award = data.all_money
    self.zhe_dang.gameObject:SetActive(true)
    self:ShowClear({dangci, award})
end

--展示结算界面  data包含一个用int代表的结算类型，一个int代表的得分
function C:ShowClear(data)
    if data[1] == 1 then
        self.hidetime = 2
        if data[2] == 0 then
            self.hidetime = 1
        end
        -- self.soundlv1 =
        --     ExtendSoundManager.PlaySound(
        --     audio_config.sdbgj.bgm_sdbgj_jiangli1.audio_name,
        --     1,
        --     function()
        --         self.soundlv1 = nil
        --     end
        -- )
    end
    if data[1] == 2 then
        self.hidetime = 2
        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_jiangli2.audio_name)
    end
    if data[1] == 3 then
        self.hidetime = 8
        self.soundlv3 = nil
        self.soundlv3 =
            ExtendSoundManager.PlaySound(
            audio_config.cbzz.bgm_cbzz_jiangli3.audio_name,
            1,
            function()
                self.soundlv3 = nil
            end
        )
        -- ExtendSoundManager.PauseSceneBGM()
    end
    if data[1] == 4 then
        self.hidetime = 8
        self.soundlv4 = nil
        self.soundlv4 =
            ExtendSoundManager.PlaySound(
            audio_config.cbzz.bgm_cbzz_jiangli4.audio_name,
            1,
            function()
                self.soundlv4 = nil
            end
        )
        -- ExtendSoundManager.PauseSceneBGM()
    end
    self.data = data
    self.CloseButton.gameObject:SetActive(true)
    dump({data[1], data[2]}, "<color=red>-------------结算界面data-----------</color>")
    if data[1] == 0 then
        return
    end
    if data[2] == nil then
        data[2] = 0
    end
    --动画间隔时间
    local t = 0.05
    --动画开始时，显示多少金币
    local x = 1 / 4
    --动画开始时候的金币数量
    self.startmoney = data[2] * x
    --动画持续时间

    local animtime = 4.5
    if data[1] < 3 then
        self.startmoney = data[2]
        self.childobjsgoldtext[data[1]].text = string.format("%.0f", data[2])
    else
        -- self.Animator4.speed = 1
    end
    local index = 0
    if self.addmoney then
        self.addmoney:Stop()
    end
    self.addmoney = nil
    self.addmoney =
        Timer.New(
        function()
            index = index + 1
            if self.startmoney >= data[2] * 0.9 then
                self.childobjsgoldtext[data[1]].text = data[2]
                self.CloseButton.gameObject:SetActive(true)
                if self.addmoney then
                    self.addmoney:Stop()
                end
                if data[1] == 4 then
                    -- self.Animator4.speed = 0
                    -- self.Light:Stop()
                    -- self.JingBi4:Stop()
                end
                self.addmoney = nil
                return
            end
            self.startmoney = (1 - x) * data[2] / (animtime / t) + self.startmoney
            self.childobjsgoldtext[data[1]].text = string.format("%.0f", self.startmoney)
        end,
        t,
        -1
    )
    self.addmoney:Start()
    self.childobjs[data[1]].gameObject:SetActive(true)
    if self.hide ~= nil then
        self.hide:Stop()
    end
    self.hide = nil

    if self.hideAniTimer ~= nil then
        self.hideAniTimer:Stop()
    end
    self.hideAniTimer = nil
    local ani
    local ani2
    local len
    if data[1] == 1 then
        ani = "EliminateSGClearPanel_jiesuan1"
    elseif data[1] == 2 then
        ani = "xxl_sg_jyzg"
    elseif data[1] == 3 then
        ani = "EliminateSGClearPanel_lsrs"
        ani2 = "EliminateSGClearPanel_lsrs_xunhuan"
        len = 0.667
    elseif data[1] == 4 then
        ani = "EliminateSGClearPanel_sjms"
        ani2 = "EliminateSGClearPanel_sjms_xunhuan"
        len = 0.767
    end
    if ani then
        self.childanis[data[1]]:Play(ani,-1,0)
    end
    if self.timer_ani then
        self.timer_ani:Stop()
        self.timer_ani = nil
    end
    if len and ani2 then
        self.timer_ani = Timer.New(function ()
           self.childanis[data[1]]:Play(ani2,-1,0) 
        end,len,1,false)
        self.timer_ani:Start()
    end
    local is_auto = EliminateSGModel.GetAuto()
    dump(is_auto, "<color=white>自动模式</color>")
    if data[1] == 3 or data[1] == 4 then
        local hide_ani_t = 8
        if data[1] == 3 then
            hide_ani_t = 7.8
        else
            hide_ani_t = 7.4
        end
        if is_auto then
            self.hideAniTimer = Timer.New(function(  )
                if data[1] == 3 then
                    self.childanis[data[1]]:Play("xxl_xy_zycm_03",-1,0)
                elseif data[1] == 4 then
                    self.childanis[data[1]]:Play("xxl_xy_dzsf_3",-1,0)
                end
            end,hide_ani_t,1)
            self.hideAniTimer:Start()
        end
    end
    
    if is_auto or data[1] == 1 or data[1] == 2 then     
        local cd = 0
        self.hide =
            Timer.New(
            function()
                Event.Brocast("eliminateSG_had_settel_msg")
                for i = 1, #self.childobjs do
                    self.childobjs[i].gameObject:SetActive(false)
                end
                self.CloseButton.gameObject:SetActive(false)
                if  is_auto then
                    Event.Brocast("auto_lottery", true)
                end 
                if self.soundlv3 then
                    soundMgr:CloseLoopSound(self.soundlv3)
                    self.soundlv3 = nil
                end
                if self.soundlv4 then
                    soundMgr:CloseLoopSound(self.soundlv4)
                    self.soundlv4 = nil
                end
                self.ClickTimes = 1
                self.zhe_dang.gameObject:SetActive(false)
            end,
            self.hidetime,
            1
        ,false)
        self.hide:Start()       
    end
end
