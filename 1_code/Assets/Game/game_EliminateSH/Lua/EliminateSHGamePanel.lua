local basefunc = require "Game.Common.basefunc"
EliminateSHGamePanel = basefunc.class()

local M = EliminateSHGamePanel
M.name = "EliminateSHGamePanel"
local lister
local listerRegisterName = "EliminateGameListerRegister"
local instance
--******************框架
function M.Create()
    DSM.PushAct({panel = M.name})
    instance = M.New()
    return instance
end

function M:ctor()
    ExtendSoundManager.PlaySceneBGM(audio_config.shxxl.bgm_shxxl_beijing.audio_name)
    local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MyInit()
    local bg = self.transform:Find("BG")
	MainModel.SetGameBGScale(bg)
end

function M:MyInit()
    self:MakeLister()
    EliminateSHLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onDown = basefunc.handler(self, self.OnClickLotteryDown)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onUp = basefunc.handler(self, self.OnClickLotteryUp)
    EventTriggerListener.Get(self.skip_btn.gameObject).onUp = basefunc.handler(self, self.OnClickSkip)
    EventTriggerListener.Get(self.auto_btn.gameObject).onUp = basefunc.handler(self, self.OnClickAuto)
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBack)
    EventTriggerListener.Get(self.yxcard_btn.gameObject).onClick = basefunc.handler(self, self.OnClickYXCard)

    
    EliminateSHInfoPanel.Create()
    EliminateSHMoneyPanel.Create()
    EliminateSHHeroManager.Create()
    EliminateSHClearPanel.Create()
    EliminateSHObjManager.InitEliminateBG(EliminateSHModel.size.max_x,EliminateSHModel.size.max_y)

    self.skip_img = self.skip_btn.transform:GetComponent("Image")
    self.lottery_img = self.lottery_btn.transform:GetComponent("Image")
    self.auto_img = self.auto_btn.transform:GetComponent("Image")
    self.yxcard_img = self.yxcard_btn.transform:GetComponent("Image")


    local btn_map = {}
	btn_map["left_down"] = {self.left_down}
	btn_map["left_enter"] = {self.left_enter}
	btn_map["left_top"] = {self.left_top}
	btn_map["center"] = {self.center}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxlsh_game")
    
    if EliminateSHModel.Manually then
        self.lottery_img.sprite = GetTexture("shxxl_btn_start")
    end

    HandleLoadChannelLua("EliminateSHGamePanel", self)
end

function M:MyRefresh()
    if not EliminateSHModel.data then return end
    local m_data = EliminateSHModel.data
    dump(m_data, "<color=yellow>刷新数据</color>")
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            EliminateSHObjManager.ClearEliminateItem()
            EliminateSHObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base)
        else
            EliminateSHObjManager.ClearEliminateItem()
            EliminateSHObjManager.CreateEliminateItem(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new)
            -- ExtendSoundManager.PauseSceneBGM()
            --model处理开奖结束的数据
            EliminateSHModel.SetDataLotteryEnd()
            local level = EliminateSHModel.GetAllResultLevel()
            local result_data = EliminateSHModel.GetAllResultData()
            local seq = DoTweenSequence.Create()
            seq:AppendInterval(EliminateSHModel.GetTime(EliminateSHModel.time["show_clear" .. level]))
            seq:OnKill(function ()
                --开奖结束
                self:RefreshLotteryBtns()
                Event.Brocast("view_lottery_end",result_data)
            end)

            return
        end        
    end

    --model处理开奖结束的数据
    EliminateSHModel.SetDataLotteryEnd()
    --开奖结束
    self:RefreshLotteryBtns()

    Event.Brocast("eliminate_refresh_end")
end

function M:MyExit()
    Event.Brocast("view_quit_game")
    EliminateSHLogic.clearViewMsgRegister(listerRegisterName)
    if M.auto_lotter_timer then 
        M.auto_lotter_timer:Stop()
        M.auto_lotter_timer = nil
    end
    if self.game_btn_pre then
		self.game_btn_pre:MyExit()
	end
end

function M:MyClose()
    DSM.PopAct()
    self:MyExit()
    closePanel(M.name)
end

function M.ExitTimer()
    if M.auto_lotter_timer then 
        M.auto_lotter_timer:Stop()
        M.auto_lotter_timer = nil
    end
end

function M:MakeLister()
    lister = {}
    lister["model_lottery_success"] = basefunc.handler(self, self.model_lottery_success)
    lister["model_lottery_error"] = basefunc.handler(self, self.model_lottery_error)
    lister["auto_lottery"] = basefunc.handler(self, self.auto_lottery)
    lister["stop_auto_lotttery"] = basefunc.handler(self,self.stop_auto_lotttery)

end

function M:auto_lottery()
    print("<color=yellow>托管开奖</color>")
    ExtendSoundManager.PlaySceneBGM(audio_config.shxxl.bgm_shxxl_beijing.audio_name)
    if not EliminateSHModel.data then return end
    if EliminateSHModel.GetAuto() then
        --托管自动开奖
        self:AutoLottery()
    else
        --model处理开奖结束的数据
        EliminateSHModel.SetDataLotteryEnd()
        --开奖结束
        self:RefreshLotteryBtns()
    end
end

function M:model_lottery_error()
    print("<color=yellow>开奖错误</color>")
    if not EliminateSHModel.data then return end
    local m_data = EliminateSHModel.data
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            EliminateSHObjManager.ClearEliminateItem()
            EliminateSHObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base)
        else
            EliminateSHObjManager.ClearEliminateItem()
            EliminateSHObjManager.CreateEliminateItem(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new)
        end
    end
    self:RefreshLotteryBtns()
    Event.Brocast("view_lottery_error")
end

function M:model_lottery_success()
    print("<color=yellow>开奖成功</color>")
    if not EliminateSHModel.data then return end
    local m_data = EliminateSHModel.data
    if EliminateSHObjManager.bgm_shxxl_kaishi then
        local key = EliminateSHObjManager.bgm_shxxl_kaishi
        soundMgr:CloseLoopSound(key)
        EliminateSHObjManager.bgm_shxxl_kaishi = nil
    end
    EliminateSHObjManager.bgm_shxxl_kaishi = ExtendSoundManager.PlaySound(audio_config.shxxl.bgm_shxxl_kaishi.audio_name)
    self:RefreshLotteryBtns()
    if EliminateSHModel.GetSkip() then
        dump(m_data.eliminate_data, "<color=red>跳过动画，直接到最后的结果</color>")
        self:lottery_end()
    else
        local new_map = m_data.eliminate_data.result[1].map_base
        local times = {
            ys_j_sgdjg = EliminateSHModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateSHModel.time.ys_ysgdsj,
        }
        EliminateSHAnimManager.StopScrollLottery(new_map,function()
            self:HideSkipBtn()
            self:lottery_start(m_data)
        end,times)
        dump(m_data.eliminate_data, "<color=red>正常开奖</color>")
    end
    Event.Brocast("view_lottery_sucess")
end

function M:lottery_start(m_data)
    if not m_data then return end
    local data = basefunc.deepcopy(m_data.eliminate_data)
    EliminateSHObjManager.ExitTimer()
    local lottery
    lottery = function ()
        if not EliminateSHModel.data or table_is_null(data.result) then
            --本局没有可以开奖的元素了，本局开奖结束
            self:lottery_end()
            return
        end
        local cur_result = basefunc.deepcopy(data.result[1])
        table.remove(data.result,1)
        local next_result = basefunc.deepcopy(data.result[1])
        EliminateSHObjManager.ClearEliminateItem()
        EliminateSHObjManager.CreateEliminateItem(cur_result.map_base)
        --直接开奖
        if EliminateSHModel.Manually then
            --手动消除
            EliminateSHObjManager.LotteryManually(cur_result,next_result,function()
                --当前屏幕元素消除完,继续开奖
                lottery()
            end)
        else
            EliminateSHObjManager.Lottery(cur_result,next_result,function()
                --当前屏幕元素消除完,继续开奖
                lottery()
            end)
        end
       
       
    end
    lottery()
end

function M:lottery_end()
    self:MyRefresh()
    if EliminateSHModel.Manually then
        EliminateSHObjManager.LotteryManuallyEnd() 
    end
end

--********************refresh
function M:RefreshLotteryBtns()
    dump(self,"<color=white>刷新按钮</color>")
    self:RefreshYXCard()
    self.auto_img.raycastTarget = true
    self.skip_img.raycastTarget = true
    self.lottery_img.raycastTarget = true
    if self.lottery_img.color then
    self.lottery_img.color = Color.white
    end
    if not EliminateSHModel.data then return end
    local m_data = EliminateSHModel.data
    local auto = EliminateSHModel.GetAuto()
    if not auto then
        if m_data.status_lottery == EliminateSHModel.status_lottery.wait then
            self.lottery_btn.transform.gameObject:SetActive(true)
            self.skip_btn.transform.gameObject:SetActive(false)
        elseif m_data.status_lottery == EliminateSHModel.status_lottery.run then
            self.lottery_btn.transform.gameObject:SetActive(false)
            self.skip_btn.transform.gameObject:SetActive(true)
        end
    else
        self.lottery_btn.transform.gameObject:SetActive(false)
        self.skip_btn.transform.gameObject:SetActive(false)
    end
    self.auto_btn.gameObject:SetActive(auto)
end

function M:RefreshYXCard()
    local open, yxcard, game_level, qp_image = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateSHModel.yxcard_type}, "GetCurGameCard")
    dump({
        yxcard = yxcard,
        status_lottery = EliminateSHModel.data.status_lottery,
        raycastTarget = self.lottery_img.raycastTarget ,
        auto = EliminateSHModel.GetAuto()
    }, "<color=red>【游戏卡状态刷新】</color>")
    if open then
        if not EliminateSHModel.GetAuto() 
        and EliminateSHModel.data.status_lottery == EliminateSHModel.status_lottery.wait 
        and yxcard 
        --and self.lottery_img.raycastTarget 
        then
            self.yxcard_btn.gameObject:SetActive(true)
            self.yxcard_img.sprite = GetTexture(qp_image)
        else
            self.yxcard_btn.gameObject:SetActive(false)
        end
    end
end

--********************方法
function M:OnClickBack()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

    local callback = function(  )
        Network.SendRequest("xxl_shuihu_quit_game")
    end

    local a,b = GameButtonManager.RunFun({gotoui="cpl_ljyjcfk",callback = callback}, "CheckMiniGame")
    if a and b then
        return
    end

    callback()
end

function M:AutoLottery()
    if M.auto_lotter_timer then M.auto_lotter_timer:Stop() end
    M.auto_lotter_timer = Timer.New(function ()
        print("<color=red>托管开奖开始</color>")
        self:Lottery()
    end,EliminateSHModel.GetTime(EliminateSHModel.time.xc_zdkj),1)
    M.auto_lotter_timer:Start()
end

function M:Lottery(_card_type)
    dump(EliminateSHModel.data.bet, "<color=red>消消乐开奖</color>")
    -- ExtendSoundManager.PauseSceneBGM()
    local item_map = EliminateSHObjManager.GetAllEliminateItem()
    local times = {
        ys_jsgdsj = EliminateSHModel.time.ys_jsgdsj,
        ys_ysgdjg = EliminateSHModel.time.ys_ysgdjg,
        ys_j_sgdsj = EliminateSHModel.time.ys_j_sgdsj,
        ys_jsgdjg = EliminateSHModel.time.ys_jsgdjg
    }
    EliminateSHAnimManager.ScrollLottery(item_map,times)

    --测试数据
    if EliminateSHLogic.is_test then
        M.Test()
        return
    end

    Event.Brocast("view_lottery_start")
    --dump(EliminateSHModel.data.bet, "---------------------------------------")
    if _card_type then
        Network.SendRequest("xxl_shuihu_kaijiang",{bets = EliminateSHModel.data.bet, card_type = _card_type},"连接中") 
    else
        Network.SendRequest("xxl_shuihu_kaijiang",{bets = EliminateSHModel.data.bet},"连接中") 
    end
end

local is_up = false
function M:OnClickLotteryDown()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not EliminateSHModel.data then return end
    local all_bet = 0
    for k,v in pairs(EliminateSHModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        Event.Brocast("show_gift_panel")
        self.lottery_img.raycastTarget = true
        return
    end
    is_up = false

    if EliminateSHModel.Manually then
        return
    end

    self.lottery_down_time = os.time()
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(EliminateSHModel.time.xc_zdkj_jg)
    seq:AppendCallback(function ()
        self.auto_img.raycastTarget = false
        if not is_up then
            self.auto_btn.gameObject:SetActive(true)
        end
    end)
end

function M:OnClickLotteryUp(  )
    if not EliminateSHModel.data then return end
    local all_bet = 0
    for k,v in pairs(EliminateSHModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        self.lottery_img.raycastTarget = true
        return
    end
    is_up = true

    if EliminateSHModel.Manually then
        self:Lottery()
        self.lottery_img.raycastTarget = false
        return
    end

    if self.lottery_down_time and os.time() - self.lottery_down_time >= EliminateSHModel.time.xc_zdkj_jg then
        --自动消除
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=white>自动消除</color>")
        EliminateSHModel.SetAuto(true)
        -- self:RefreshLotteryBtns()
    end
    self:Lottery()
    self.lottery_img.raycastTarget = false
end

function M:OnClickSkip()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:HideSkipBtn()
    EliminateSHGamePanel.ExitTimer()
    EliminateSHAnimManager.ExitTimer()
    EliminateSHObjManager.ExitTimer()
    if GameGlobalOnOff.XXLSkipAllAni then
        --直接出结果
        self:MyRefresh()
    else
        --开始开奖
        self:lottery_start(EliminateSHModel.data)
    end
end

function M:OnClickAuto()
    --取消托管
    if not EliminateSHModel.data then return end
    dump({EliminateSHModel.data.ScrollLottery,EliminateSHModel.GetAuto()},"<color=red>取消托管</color>")
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.auto_img.raycastTarget = false
    EliminateSHModel.SetAuto( not EliminateSHModel.GetAuto())
    self:RefreshLotteryBtns()
    if not EliminateSHModel.data.ScrollLottery then
        self:HideSkipBtn()
    end
end

function M:InitSpeedDropDown()
    self.speed_dd = self.transform:Find("SpeedDropdown"):GetComponent("Dropdown")
    local list = EliminateSHModel.cfg.speed
	self.speed_dd:ClearOptions()
	if not list or not next(list) then return end
    for k, v in ipairs(list) do
        local d = OptionData.New()
        d.text = k
        self.speed_dd:AddOptionData(d)
    end
    self.speed_dd.transform:Find("Label"):GetComponent("Text").text = list[1]
	self.speed_dd.onValueChanged:AddListener(
        function(val)
            EliminateSHModel.SetSpeed(val + 1)
        end
    )
end

function M:HideSkipBtn()
    self.skip_img.raycastTarget = false
    self.skip_btn.gameObject:SetActive(false)
    self.lottery_img.color = Color.gray
    self.lottery_img.raycastTarget = false
    self.lottery_btn.gameObject:SetActive(true)
end

--停止自动游戏
function M:stop_auto_lotttery()
    if EliminateSHModel.GetAuto() then
        self.auto_img.raycastTarget = false
        EliminateSHModel.SetAuto(false)
        self:RefreshLotteryBtns()
        if not EliminateSHModel.data.ScrollLottery then
            self:HideSkipBtn()
        end
    end
end

--点击游戏卡
function M:OnClickYXCard()
    local open, yxcard, game_level  = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateSHModel.yxcard_type}, "GetCurGameCard")
    if open and self.lottery_img.raycastTarget then
        dump({yxcard = yxcard, game_level = game_level}, "<color=white>【使用游戏卡】</color>")
        --EliminateSHModel.SetBet({game_level/5, game_level/5, game_level/5, game_level/5, game_level/5})
        self:Lottery(yxcard)
        Event.Brocast("view_lottery_start_yxcard", game_level)
    end
end

--测试代码
function M.Test()
    local data = EliminateSHLogic.GetTestData()
    Event.Brocast("xxl_shuihu_kaijiang_response","xxl_shuihu_kaijiang_response",data)
    Event.Brocast("view_lottery_start")
end