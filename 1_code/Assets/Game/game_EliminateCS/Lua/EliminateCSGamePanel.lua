local basefunc = require "Game.Common.basefunc"
EliminateCSGamePanel = basefunc.class()

local M = EliminateCSGamePanel
M.name = "EliminateCSGamePanel"
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
    ExtendSoundManager.PlaySceneBGM(audio_config.csxxl.bgm_csxxl_beijing.audio_name)
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
    EliminateCSLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onDown = basefunc.handler(self, self.OnClickLotteryDown)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onUp = basefunc.handler(self, self.OnClickLotteryUp)
    EventTriggerListener.Get(self.skip_btn.gameObject).onUp = basefunc.handler(self, self.OnClickSkip)
    EventTriggerListener.Get(self.auto_btn.gameObject).onUp = basefunc.handler(self, self.OnClickAuto)
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBack)
    EventTriggerListener.Get(self.yxcard_btn.gameObject).onClick = basefunc.handler(self, self.OnClickYXCard)

    
    EliminateCSInfoPanel.Create()
    EliminateCSMoneyPanel.Create()
    EliminateCSClearPanel.Create()
    EliminateCSProgPanel.Create()
    EliminateCSZiPanel.Create()
    EliminateCSObjManager.InitEliminateBG(EliminateCSModel.size.max_x,EliminateCSModel.size.max_y)

    self.skip_img = self.skip_btn.transform:GetComponent("Image")
    self.lottery_img = self.lottery_btn.transform:GetComponent("Image")
    self.auto_img = self.auto_btn.transform:GetComponent("Image")
    self.yxcard_img = self.yxcard_btn.transform:GetComponent("Image")

    local btn_map = {}
	btn_map["left_down"] = {self.left_down}
	btn_map["left_enter"] = {self.left_enter}
	btn_map["left_top"] = {self.left_top}
	btn_map["center"] = {self.center}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxlcs_game")

    HandleLoadChannelLua("EliminateCSGamePanel", self)
end

function M:MyRefresh()
    if EliminateCSModel.DataDamage() then return end
    local m_data = EliminateCSModel.data
    dump(m_data, "<color=yellow>刷新数据</color>")
    local function show_end()
        if not table_is_null(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new) then
            EliminateCSObjManager.ClearEliminateItem()
            EliminateCSObjManager.CreateEliminateItem(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new)
        end
        -- ExtendSoundManager.PauseSceneBGM()
        --model处理开奖结束的数据
        EliminateCSModel.SetDataLotteryEnd()
        local level = EliminateCSModel.GetAllResultLevel()
        local result_data = EliminateCSModel.GetAllResultData()
        local seq = DoTweenSequence.Create()
        seq:AppendInterval(EliminateCSModel.GetTime(EliminateCSModel.time["show_clear" .. level]))
        seq:OnKill(function ()
            --开奖结束
            self:RefreshLotteryBtns()
            Event.Brocast("view_lottery_end",result_data)
        end)
    end

    local function show_zd()
        --财神砸蛋
        EliminateCSObjManager.ClearEliminateItem()
        local nor_last_result = EliminateCSModel.GetNorXCLastResult()
        EliminateCSObjManager.CreateEliminateItem(nor_last_result.map_new)
        local result_data = EliminateCSModel.GetAllResultData()
        Event.Brocast("view_lottery_end_nor",result_data)
        local m_data = EliminateCSModel.GetResultInZD()
        EliminateCSModel.SetDataLotteryStart()
        self:RefreshLotteryBtns()
        self:HideSkipBtn()
        self:lottery_start(m_data)
    end

    local function show_zp()
       --幸运转盘
       EliminateCSObjManager.ClearEliminateItem()
       local map_new = eliminate_cs_algorithm.str_maps_conver_to_pos_maps(EliminateCSModel.kaijiang_maps,EliminateCSModel.size.max_x)
       EliminateCSObjManager.CreateEliminateItem(map_new)
       local m_data = EliminateCSModel.GetResultInZP()
        EliminateCSModel.SetDataLotteryStartProg()
       self:RefreshLotteryBtns()
       self:HideSkipBtn()
       self:lottery_start(m_data)
    end

    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            EliminateCSObjManager.ClearEliminateItem()
            EliminateCSObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base)
            local result_data = EliminateCSModel.GetAllResultData()
            EliminateCSProgPanel.SetProInstant(result_data)
            Event.Brocast("view_lottery_refresh",result_data)
            ExtendSoundManager.PlaySceneBGM(audio_config.csxxl.bgm_csxxl_beijing.audio_name)
        else
            if EliminateCSLogic.is_test_state then
                EliminateCSModel.data.state = EliminateCSLogic.xc_state
                EliminateCSLogic.is_test_state = false
            else
                --由于鲸币同步问题，断线重连直接回到结算界面
                EliminateCSModel.data.state = nil
            end
            
            dump(EliminateCSModel.data.state, "<color=white>当前状态</color>")
            if not EliminateCSModel.data.state then
                show_end()
                return
            end

            if EliminateCSModel.data.state == EliminateCSModel.xc_state.nor then
                if EliminateCSModel.IsZD() then
                    show_zd()
                    return
                end
                show_end()
                return
            elseif EliminateCSModel.data.state == EliminateCSModel.xc_state.zd then
                show_zd()
                return
            elseif EliminateCSModel.data.state == EliminateCSModel.xc_state.zd_tnsh then
                show_end()
                return
            elseif EliminateCSModel.data.state == EliminateCSModel.xc_state.zp then
                show_zp()
                return
            elseif EliminateCSModel.data.state == EliminateCSModel.xc_state.zp_tnsh then
                show_end()
                return
            end
        end        
    end
    EliminateCSModel.SetDataLotteryEnd()
    self:RefreshLotteryBtns()

    Event.Brocast("eliminate_refresh_end")
end

function M:MyExit()
    EliminateCSGamePanel.ExitTimer()
    Event.Brocast("view_quit_game")
    EliminateCSLogic.clearViewMsgRegister(listerRegisterName)
    if M.auto_lotter_timer then 
        M.auto_lotter_timer:Stop()
        M.auto_lotter_timer = nil
    end
    if self.game_btn_pre then
		self.game_btn_pre:MyExit()
    end
    EliminateCSObjManager.Exit()
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
    EliminateCSAnimManager.ExitTimer()
    EliminateCSObjManager.ExitTimer()
    EliminateCSPartManager.ExitTimer()
    EliminateCSZDGamePanel.Close()
    EliminateCSZPGamePanel.Close()
end

function M:MakeLister()
    lister = {}
    lister["model_lottery_success"] = basefunc.handler(self, self.model_lottery_success)
    lister["model_lottery_error"] = basefunc.handler(self, self.model_lottery_error)
    lister["auto_lottery"] = basefunc.handler(self, self.auto_lottery)
    lister["model_lottery_success_zp"] = basefunc.handler(self, self.model_lottery_success_zp)
    lister["model_lottery_error_zp"] = basefunc.handler(self, self.model_lottery_error_zp)
    lister["stop_auto_lotttery"] = basefunc.handler(self,self.stop_auto_lotttery)
end

function M:auto_lottery()
    print("<color=yellow>托管开奖</color>")
    ExtendSoundManager.PlaySceneBGM(audio_config.csxxl.bgm_csxxl_beijing.audio_name)
    if EliminateCSModel.DataDamage() then return end
    if EliminateCSModel.GetAuto() then
        --托管自动开奖
        self:AutoLottery()
    else
        --model处理开奖结束的数据
        EliminateCSModel.SetDataLotteryEnd()
        --开奖结束
        self:RefreshLotteryBtns()
    end
end

function M:model_lottery_error()
    print("<color=yellow>开奖错误</color>")
    if EliminateCSModel.DataDamage() then return end
    local m_data = EliminateCSModel.data
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            EliminateCSObjManager.ClearEliminateItem()
            EliminateCSObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base)
        else
            if not table_is_null(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new) then
                EliminateCSObjManager.ClearEliminateItem()
                EliminateCSObjManager.CreateEliminateItem(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new)
            end
        end
    end
    self:RefreshLotteryBtns()
    Event.Brocast("view_lottery_error")
end

function M:model_lottery_success()
    print("<color=yellow>开奖成功</color>")
    if EliminateCSModel.DataDamage() then return end
    local m_data = EliminateCSModel.data
    self:RefreshLotteryBtns()
    if EliminateCSModel.GetSkip() then
        dump(m_data.eliminate_data, "<color=red>跳过动画，直接到最后的结果</color>")
        self:lottery_end()
    else
        local new_map = m_data.eliminate_data.result[1].map_base
        local times = {
            ys_j_sgdjg = EliminateCSModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateCSModel.time.ys_ysgdsj,
        }
        EliminateCSAnimManager.StopScrollLottery(new_map,function()
            self:HideSkipBtn()
            self:lottery_start(m_data)
        end,times)
        dump(m_data.eliminate_data, "<color=red>正常开奖</color>")
    end
    Event.Brocast("view_lottery_sucess")
end

function M:lottery_start(m_data)
    local data = basefunc.deepcopy(m_data.eliminate_data)
    EliminateCSObjManager.ExitTimer()
    local lottery
    lottery = function ()
        if EliminateCSModel.DataDamage() then return end
        if table_is_null(data.result) then
            --本局没有可以开奖的元素了，本局开奖结束
            EliminateCSModel.data.state = nil
            PlayerPrefs.SetString(EliminateCSModel.csxxl_state_key,"")
            EliminateCSPartManager.DestroyTNSH()
            EliminateCSPartManager.DestroyTNSHZXH()
            self:lottery_end()
            return
        end
        local cur_result = basefunc.deepcopy(data.result[1])
        table.remove(data.result,1)
        local next_result = basefunc.deepcopy(data.result[1])
        if not table_is_null(cur_result.map_base) then
            EliminateCSObjManager.ClearEliminateItem()
            EliminateCSObjManager.CreateEliminateItem(cur_result.map_base)
        end
        EliminateCSModel.data.state = cur_result.state
        PlayerPrefs.SetString(EliminateCSModel.csxxl_state_key,EliminateCSModel.data.state)
        EliminateCSObjManager.Lottery(cur_result,function()
            --当前屏幕元素消除完,继续开奖
            lottery()
        end,next_result)
    end
    lottery()
end

function M:lottery_end()
    self:MyRefresh()
end

--********************refresh
function M:RefreshLotteryBtns()
    if not IsEquals(self.transform) then return end
    self:RefreshYXCard()
    self.auto_img.raycastTarget = true
    self.skip_img.raycastTarget = true
    self.lottery_img.raycastTarget = true
    if IsEquals(self.lottery_img) and self.lottery_img.color then
        self.lottery_img.color = Color.white
    end
    if EliminateCSModel.DataDamage() then return end
    local m_data = EliminateCSModel.data
    local auto = EliminateCSModel.GetAuto()
    if not auto then
        if m_data.status_lottery == EliminateCSModel.status_lottery.wait then
            self.lottery_btn.transform.gameObject:SetActive(true)
            self.skip_btn.transform.gameObject:SetActive(false)
        elseif m_data.status_lottery == EliminateCSModel.status_lottery.run then
            self.lottery_btn.transform.gameObject:SetActive(false)
            self.skip_btn.transform.gameObject:SetActive(true)
        elseif m_data.status_lottery == EliminateCSModel.status_lottery.run_prog then
            self.lottery_btn.transform.gameObject:SetActive(false)
            self.skip_btn.transform.gameObject:SetActive(false)
        end
    else
        self.lottery_btn.transform.gameObject:SetActive(false)
        self.skip_btn.transform.gameObject:SetActive(false)
    end
    self.auto_btn.gameObject:SetActive(auto)
end

function M:RefreshYXCard()
    local open, yxcard, game_level, qp_image = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateCSModel.yxcard_type}, "GetCurGameCard")
    dump({
        yxcard = yxcard,
        status_lottery = EliminateCSModel.data.status_lottery,
        raycastTarget = self.lottery_img.raycastTarget ,
        auto = EliminateCSModel.GetAuto()
    }, "<color=red>【游戏卡状态刷新】</color>")
    if open then
        if not EliminateCSModel.GetAuto() 
        and EliminateCSModel.data.status_lottery == EliminateCSModel.status_lottery.wait 
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
        Network.SendRequest("xxl_caishen_quit_game")
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
    end,EliminateCSModel.GetTime(EliminateCSModel.time.xc_zdkj),1)
    M.auto_lotter_timer:Start()
end

function M:Lottery(_card_type)
    dump(EliminateCSModel.data.bet, "<color=red>消消乐开奖</color>")
    ExtendSoundManager.PlaySound(audio_config.csxxl.bgm_csxxl_kaishi.audio_name)
    local item_map = EliminateCSObjManager.GetAllEliminateItem()
    local times = {
        ys_jsgdsj = EliminateCSModel.time.ys_jsgdsj,
        ys_ysgdjg = EliminateCSModel.time.ys_ysgdjg,
        ys_j_sgdsj = EliminateCSModel.time.ys_j_sgdsj,
        ys_jsgdjg = EliminateCSModel.time.ys_jsgdjg
    }
    EliminateCSAnimManager.ScrollLottery(item_map,times)

    --测试数据
    if EliminateCSLogic.is_test then
        M.Test()
        return
    end
    Event.Brocast("view_lottery_start")
    if _card_type then
        Network.SendRequest("xxl_caishen_kaijiang",{bets = EliminateCSModel.data.bet, card_type = _card_type},"连接中") 
    else
        Network.SendRequest("xxl_caishen_kaijiang",{bets = EliminateCSModel.data.bet},"连接中") 
    end
end

local is_up = false
function M:OnClickLotteryDown()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if EliminateCSModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateCSModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        Event.Brocast("show_gift_panel")
        self.lottery_img.raycastTarget = true
        return
    end
    is_up = false

    self.lottery_down_time = os.time()
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(EliminateCSModel.time.xc_zdkj_jg)
    seq:AppendCallback(function ()
        self.auto_img.raycastTarget = false
        if not is_up then
            self.auto_btn.gameObject:SetActive(true)
        end
    end)
end

function M:OnClickLotteryUp(  )
    if EliminateCSModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateCSModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        self.lottery_img.raycastTarget = true
        return
    end
    is_up = true

    if self.lottery_down_time and os.time() - self.lottery_down_time >= EliminateCSModel.time.xc_zdkj_jg then
        --自动消除
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=white>自动消除</color>")
        EliminateCSModel.SetAuto(true)
        -- self:RefreshLotteryBtns()
    end
    self:Lottery()
    self.lottery_img.raycastTarget = false
end

function M:OnClickSkip()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not EliminateCSModel.data then return end
    self:HideSkipBtn()
    EliminateCSGamePanel.ExitTimer()
    if GameGlobalOnOff.XXLSkipAllAni then
        --直接出结果
        self:MyRefresh()
    else
        if not EliminateCSModel.data.state then
            --开始开奖
            self:lottery_start(EliminateCSModel.data)
        end
    end
end

function M:OnClickAuto()
    --取消托管
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.auto_img.raycastTarget = false
    EliminateCSModel.SetAuto( not EliminateCSModel.GetAuto())
    self:RefreshLotteryBtns()
    if not EliminateCSModel.data.ScrollLottery or EliminateCSModel.data.state then
        self:HideSkipBtn()
    end
end

function M:InitSpeedDropDown()
    self.speed_dd = self.transform:Find("SpeedDropdown"):GetComponent("Dropdown")
    local list = EliminateCSModel.cfg.speed
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
            EliminateCSModel.SetSpeed(val + 1)
        end
    )
end

--停止自动游戏
function M:stop_auto_lotttery()
    if EliminateCSModel.GetAuto() then
        self.auto_img.raycastTarget = false
        EliminateCSModel.SetAuto(false)
        self:RefreshLotteryBtns()
        if not EliminateCSModel.data.ScrollLottery or EliminateCSModel.data.state then
            self:HideSkipBtn()
        end
    end
end

function M:HideSkipBtn()
    self.skip_img.raycastTarget = false
    self.skip_btn.gameObject:SetActive(false)
    self.lottery_img.color = Color.gray
    self.lottery_img.raycastTarget = false
    self.lottery_btn.gameObject:SetActive(true)
end

--点击游戏卡
function M:OnClickYXCard()
    local open, yxcard, game_level  = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateCSModel.yxcard_type}, "GetCurGameCard")
    if open and self.lottery_img.raycastTarget then
        dump({yxcard = yxcard, game_level = game_level}, "<color=white>【使用游戏卡】</color>")
        --EliminateCSModel.SetBet({game_level/5, game_level/5, game_level/5, game_level/5, game_level/5})
        self:Lottery(yxcard)
        Event.Brocast("view_lottery_start_yxcard", game_level)
    end
end

function M.LotteryZP()
    dump(EliminateCSModel.data, "<color=red>消消乐转盘开奖</color>")
    --测试数据
    if EliminateCSLogic.is_test then
        M.TestZP()
        return
    end
    local total_bet_money = 0
    for k,v in pairs(EliminateCSModel.data.bet) do
        total_bet_money = total_bet_money + v
    end
    Event.Brocast("view_lottery_start")
    Network.SendRequest("xxl_caishen_progress_data_kaijiang",{total_bet_money = total_bet_money},"连接中") 
end

function M:model_lottery_success_zp()
    print("<color=yellow>转盘开奖成功</color>")
    if EliminateCSModel.DataDamage() then return end
    local m_data = EliminateCSModel.data
    self:RefreshLotteryBtns()
    self:lottery_start(m_data)
    Event.Brocast("view_lottery_sucess")
end

function M:model_lottery_error_zp()
    print("<color=yellow>转盘开奖错误</color>")
    if EliminateCSModel.DataDamage() then return end
    self:RefreshLotteryBtns()
    Event.Brocast("view_lottery_error")
end

--测试代码
function M.Test()
    Event.Brocast("view_lottery_start")
    local data = EliminateCSLogic.GetTestDataNor()
    Event.Brocast("xxl_caishen_kaijiang_response","xxl_caishen_kaijiang_response",data)
end

--测试代码
function M.TestZP()
    local data = EliminateCSLogic.GetTestDataZP()
    Event.Brocast("view_lottery_start")
    Event.Brocast("xxl_caishen_progress_data_kaijiang_response","xxl_caishen_progress_data_kaijiang_response",data)
end