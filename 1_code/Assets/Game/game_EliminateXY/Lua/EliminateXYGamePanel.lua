local basefunc = require "Game.Common.basefunc"
EliminateXYGamePanel = basefunc.class()

local M = EliminateXYGamePanel
M.name = "EliminateXYGamePanel"
local lister
local listerRegisterName = "EliminateXYGameListerRegister"
local instance
local is_first
--******************框架
function M.Create()
    DSM.PushAct({panel = M.name})
    is_first = true
    instance = M.New()
    return instance
end

function M:ctor()
    ExtendSoundManager.PlaySceneBGM(audio_config.sdbgj.bgm_sdbgj_beijing.audio_name)
    local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MyInit()
end

function M:MyInit()
	ExtPanel.ExtMsg(self)
	self.dot_del_obj = true

    self:MakeLister()
    EliminateXYLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onDown = basefunc.handler(self, self.OnClickLotteryDown)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onUp = basefunc.handler(self, self.OnClickLotteryUp)
    EventTriggerListener.Get(self.skip_btn.gameObject).onUp = basefunc.handler(self, self.OnClickSkip)
    EventTriggerListener.Get(self.auto_btn.gameObject).onUp = basefunc.handler(self, self.OnClickAuto)
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBack)
    EventTriggerListener.Get(self.yxcard_btn.gameObject).onClick = basefunc.handler(self, self.OnClickYXCard)

    
    EliminateXYInfoPanel.Create()
    EliminateXYMoneyPanel.Create()
    EliminateXYClearPanel.Create()
    EliminateXYHeroManager.Create()
    EliminateXYObjManager.InitEliminateBG(EliminateXYModel.size.max_x,EliminateXYModel.size.max_y)

    self.skip_img = self.skip_btn.transform:GetComponent("Image")
    self.lottery_img = self.lottery_btn.transform:GetComponent("Image")
    self.auto_img = self.auto_btn.transform:GetComponent("Image")
    self.yxcard_img = self.yxcard_btn.transform:GetComponent("Image")


    local btn_map = {}
	btn_map["left_down"] = {self.left_down}
	btn_map["left_enter"] = {self.left_enter}
	btn_map["left_top"] = {self.left_top}
	btn_map["center"] = {self.center}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxlxy_game")

    HandleLoadChannelLua("EliminateXYGamePanel", self)
end

function M:MyRefresh()
    if EliminateXYModel.DataDamage() then return end
    local m_data = EliminateXYModel.data
    dump(m_data, "<color=yellow>刷新数据</color>")
    EliminateXYHeroManager.Refresh()
    if is_first then
        ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_jinru.audio_name)
        EliminateXYHeroManager.SWKSpeak(5)
        is_first = false
    end
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            EliminateXYObjManager.ClearEliminateItem()
            EliminateXYObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base,m_data.eliminate_data.result[1].bgj_rate_map)
        else
            local last_data = m_data.eliminate_data.result[#m_data.eliminate_data.result]
            if not table_is_null(last_data.swk_map_new) then
                EliminateXYObjManager.ClearEliminateItem()
                EliminateXYObjManager.CreateEliminateItem(last_data.swk_map_new,last_data.bgj_rate_map)
            elseif not table_is_null(last_data.map_new) then
                EliminateXYObjManager.ClearEliminateItem()
                EliminateXYObjManager.CreateEliminateItem(last_data.map_new,last_data.bgj_rate_map)
            end
            -- ExtendSoundManager.PauseSceneBGM()
            --model处理开奖结束的数据
            EliminateXYModel.SetDataLotteryEnd()
            local level = EliminateXYModel.GetAllResultLevel()
            local result_data = EliminateXYModel.GetAllResultData()
            local seq = DoTweenSequence.Create()
            seq:AppendInterval(EliminateXYModel.GetTime(EliminateXYModel.time["show_clear" .. level]))
            seq:OnKill(function ()
                --开奖结束
                self:RefreshLotteryBtns()
                Event.Brocast("view_lottery_end",result_data)
                EliminateXYHeroManager.ViewFreeBG(false)
            end)
            return
        end        
    end
    EliminateXYModel.SetDataLotteryEnd()
    self:RefreshLotteryBtns()
    Event.Brocast("eliminate_refresh_end")
end

function M:MyExit()
    EliminateXYGamePanel.ExitTimer()
    Event.Brocast("view_quit_game")
    EliminateXYLogic.clearViewMsgRegister(listerRegisterName)
    if M.auto_lotter_timer then 
        M.auto_lotter_timer:Stop()
        M.auto_lotter_timer = nil
    end
    if self.game_btn_pre then
		self.game_btn_pre:MyExit()
    end
    EliminateXYObjManager.Exit()
    EliminateXYHeroManager.Exit()

	-- self.skip_img.sprite = nil
    -- self.auto_img.sprite = nil

	destroy(self.gameObject)
end

function M:MyClose()
    DSM.PopAct()
    self:MyExit()
    --closePanel(M.name)
end

function M.ExitTimer()
    if M.auto_lotter_timer then 
        M.auto_lotter_timer:Stop()
        M.auto_lotter_timer = nil
    end
    EliminateXYAnimManager.ExitTimer()
    EliminateXYObjManager.ExitTimer()
    EliminateXYPartManager.ExitTimer()
end

function M:MakeLister()
    lister = {}
    lister["model_lottery_success"] = basefunc.handler(self, self.model_lottery_success)
    lister["model_lottery_error"] = basefunc.handler(self, self.model_lottery_error)
    lister["auto_lottery"] = basefunc.handler(self, self.auto_lottery)
    lister["model_query_one_task_data_response_xyxxl"] = basefunc.handler(self, self.model_query_one_task_data_response_xyxxl)
    lister["stop_auto_lotttery"] = basefunc.handler(self,self.stop_auto_lotttery)

end

function M:model_query_one_task_data_response_xyxxl()
    print("<color=yellow>西游任务刷新</color>")
    EliminateXYHeroManager.RefreshTask()
end

function M:auto_lottery()
    print("<color=yellow>托管开奖</color>")
    ExtendSoundManager.PlaySceneBGM(audio_config.sdbgj.bgm_sdbgj_beijing.audio_name)
    if EliminateXYModel.DataDamage() then return end
    if EliminateXYModel.GetAuto() then
        --托管自动开奖
        self:AutoLottery()
    else
        --model处理开奖结束的数据
        EliminateXYModel.SetDataLotteryEnd()
        --开奖结束
        self:RefreshLotteryBtns()
    end
end

function M:model_lottery_error()
    print("<color=yellow>开奖错误</color>")
    if EliminateXYModel.DataDamage() then return end
    local m_data = EliminateXYModel.data
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            EliminateXYObjManager.ClearEliminateItem()
            EliminateXYObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base,m_data.eliminate_data.result[1].bgj_rate_map)
        else
            if not table_is_null(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new) then
                EliminateXYObjManager.ClearEliminateItem()
                EliminateXYObjManager.CreateEliminateItem(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new,m_data.eliminate_data.result[#m_data.eliminate_data.result].bgj_rate_map)
            end
        end
    end
    self:RefreshLotteryBtns()
    Event.Brocast("view_lottery_error")
end

function M:model_lottery_success()
    print("<color=yellow>开奖成功</color>")
    if EliminateXYModel.DataDamage() then return end
    local m_data = EliminateXYModel.data
    self:RefreshLotteryBtns()
    if EliminateXYModel.GetSkip() then
        dump(m_data.eliminate_data, "<color=red>跳过动画，直接到最后的结果</color>")
        self:lottery_end()
    else
        local new_map = m_data.eliminate_data.result[1].map_base
        local bgj_rate_map = m_data.eliminate_data.result[1].bgj_rate_map
        local times = {
            ys_j_sgdjg = EliminateXYModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateXYModel.time.ys_ysgdsj,
            ys_ysgdsj_add = EliminateXYModel.time.ys_ysgdsj_add,
        }
        EliminateXYAnimManager.StopScrollLottery(new_map,function()
            self:HideSkipBtn()
            self:lottery_start(m_data)
        end,times,nil,bgj_rate_map)
        dump(m_data.eliminate_data, "<color=red>正常开奖</color>")
    end
    Event.Brocast("view_lottery_sucess")
end

function M:lottery_start(m_data)
    local data = m_data.eliminate_data
    EliminateXYObjManager.ExitTimer()
    local index = 0
    local lottery
    lottery = function (is_first)
        if EliminateXYModel.DataDamage() then return end
        if index == #data.result then
            --本局没有可以开奖的元素了，本局开奖结束
            EliminateXYModel.data.state = nil
            if data.result[index].swk_skill_award then
                EliminateXYObjManager.LotteryBigGame(index,function()
                    self:lottery_end()
                end)
            else
                self:lottery_end()
            end
            return
        end
        index = index + 1
        local cur_data = data.result[index]
        EliminateXYModel.data.state = cur_data.state
        EliminateXYObjManager.Lottery(index,lottery,is_first)
    end
    lottery(true)
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
    if self.lottery_img.color then
    self.lottery_img.color = Color.white
    end
    if EliminateXYModel.DataDamage() then return end
    local m_data = EliminateXYModel.data
    local auto = EliminateXYModel.GetAuto()
    if not auto then
        if m_data.status_lottery == EliminateXYModel.status_lottery.wait then
            self.lottery_btn.transform.gameObject:SetActive(true)
            self.skip_btn.transform.gameObject:SetActive(false)
        elseif m_data.status_lottery == EliminateXYModel.status_lottery.run then
            self.lottery_btn.transform.gameObject:SetActive(false)
            self.skip_btn.transform.gameObject:SetActive(true)
        elseif m_data.status_lottery == EliminateXYModel.status_lottery.run_prog then
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
    local open, yxcard, game_level, qp_image = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateXYModel.yxcard_type}, "GetCurGameCard")
    dump({
        yxcard = yxcard,
        status_lottery = EliminateXYModel.data.status_lottery,
        raycastTarget = self.lottery_img.raycastTarget ,
        auto = EliminateXYModel.GetAuto()
    }, "<color=red>【游戏卡状态刷新】</color>")
    if open then
        if not EliminateXYModel.GetAuto() 
        and EliminateXYModel.data.status_lottery == EliminateXYModel.status_lottery.wait 
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
        Network.SendRequest("xxl_xiyou_quit_game")
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
    end,EliminateXYModel.GetTime(EliminateXYModel.time.xc_zdkj),1)
    M.auto_lotter_timer:Start()
end

function M:Lottery(_card_type)
    dump(EliminateXYModel.data.bet, "<color=red>消消乐开奖</color>")
    ExtendSoundManager.PlaySound(audio_config.sdbgj.bgm_sdbgj_kaishi.audio_name)
    local item_map = EliminateXYObjManager.GetAllEliminateItem()
    local times = {
        ys_jsgdsj = EliminateXYModel.time.ys_jsgdsj,
        ys_ysgdjg = EliminateXYModel.time.ys_ysgdjg,
        ys_j_sgdsj = EliminateXYModel.time.ys_j_sgdsj,
        ys_jsgdjg = EliminateXYModel.time.ys_jsgdjg
    }
    EliminateXYAnimManager.ScrollLottery(item_map,times,1)

    --测试数据
    if EliminateXYLogic.is_test then
        M.Test()
        return
    end
    Event.Brocast("view_lottery_start")
    if _card_type then
        Network.SendRequest("xxl_xiyou_kaijiang",{bets = EliminateXYModel.data.bet, card_type = _card_type},"连接中") 
    else
        Network.SendRequest("xxl_xiyou_kaijiang",{bets = EliminateXYModel.data.bet},"连接中") 
    end
end

local is_up = false
function M:OnClickLotteryDown()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if EliminateXYModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateXYModel.data.bet) do
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
    seq:AppendInterval(EliminateXYModel.time.xc_zdkj_jg)
    seq:AppendCallback(function ()
        self.auto_img.raycastTarget = false
        if not is_up then
            self.auto_btn.gameObject:SetActive(true)
        end
    end)
end

function M:OnClickLotteryUp(  )
    if EliminateXYModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateXYModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        self.lottery_img.raycastTarget = true
        return
    end
    is_up = true

    if self.lottery_down_time and os.time() - self.lottery_down_time >= EliminateXYModel.time.xc_zdkj_jg then
        --自动消除
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=white>自动消除</color>")
        EliminateXYModel.SetAuto(true)
        -- self:RefreshLotteryBtns()
    end
    self:Lottery()
    self.lottery_img.raycastTarget = false
end

function M:OnClickSkip()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:HideSkipBtn()
    EliminateXYGamePanel.ExitTimer()
    if GameGlobalOnOff.XXLSkipAllAni then
        --直接出结果
        self:MyRefresh()
    else
        --开始开奖
        self:lottery_start(EliminateXYModel.data)
        EliminateXYObjManager.EliminateItemMoneyAni(EliminateXYModel.data.eliminate_data.result[1].map_base)
        EliminateXYPartManager.ClearAll()
    end
end

function M:OnClickAuto()
    --取消托管
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.auto_img.raycastTarget = false
    EliminateXYModel.SetAuto( not EliminateXYModel.GetAuto())
    self:RefreshLotteryBtns()
    if not EliminateXYModel.data.ScrollLottery or EliminateXYModel.data.state then
        self:HideSkipBtn()
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
    local open, yxcard, game_level  = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateXYModel.yxcard_type}, "GetCurGameCard")
    if open and self.lottery_img.raycastTarget then
        dump({yxcard = yxcard, game_level = game_level}, "<color=white>【使用游戏卡】</color>")
        --EliminateXYModel.SetBet({game_level/5, game_level/5, game_level/5, game_level/5, game_level/5})
        self:Lottery(yxcard)
        Event.Brocast("view_lottery_start_yxcard", game_level)
    end
end

--停止自动游戏
function M:stop_auto_lotttery()
    if EliminateXYModel.GetAuto() then
        self.auto_img.raycastTarget = false
        EliminateXYModel.SetAuto(false)
        self:RefreshLotteryBtns()
        if not EliminateXYModel.data.ScrollLottery or EliminateXYModel.data.state then
            self:HideSkipBtn()
        end
    end
end

--测试代码
function M.Test()
    Event.Brocast("view_lottery_start")
    local data = EliminateXYLogic.GetTestData()
    Event.Brocast("xxl_xiyou_kaijiang_response","xxl_xiyou_kaijiang_response",data)
end