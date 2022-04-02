local basefunc = require "Game.Common.basefunc"
EliminateFXGamePanel = basefunc.class()

local M = EliminateFXGamePanel
M.name = "EliminateFXGamePanel"
local lister
local listerRegisterName = "EliminateFXGameListerRegister"
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
    ExtendSoundManager.PlaySceneBGM(audio_config.fxgz.bgm_fxgz_bg_1.audio_name)
    local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MyInit()
end

function M:MyInit()
    self.dot_del_obj = true
	ExtPanel.ExtMsg(self)

    self:MakeLister()
    EliminateFXLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onDown = basefunc.handler(self, self.OnClickLotteryDown)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onUp = basefunc.handler(self, self.OnClickLotteryUp)
    EventTriggerListener.Get(self.skip_btn.gameObject).onUp = basefunc.handler(self, self.OnClickSkip)
    EventTriggerListener.Get(self.auto_btn.gameObject).onUp = basefunc.handler(self, self.OnClickAuto)
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBack)
    EventTriggerListener.Get(self.yxcard_btn.gameObject).onClick = basefunc.handler(self, self.OnClickYXCard)
    EventTriggerListener.Get(self.help_btn.gameObject).onClick = basefunc.handler(self, self.OnClickHelp)

    EliminateFXInfoPanel.Create()
    EliminateFXMoneyPanel.Create()
    EliminateFXClearPanel.Create()
    
    -- EliminateFXObjManager.InitEliminateBG(EliminateFXModel.size.max_x,EliminateFXModel.size.max_y)

    self.skip_img = self.skip_btn.transform:GetComponent("Image")
    self.lottery_img = self.lottery_btn.transform:GetComponent("Image")
    self.lottery_img2 = self.lottery_btn.transform:Find("Image").transform:GetComponent("Image")
    self.auto_img = self.auto_btn.transform:GetComponent("Image")
    self.yxcard_img = self.yxcard_btn.transform:GetComponent("Image")
    self.jcbg_1 = self.transform:Find("Root/JC/bg/jcbg_1").transform:GetComponent("Image")
    self.jcname_1 = self.transform:Find("Root/JC/bg/jcbg_1/jcname_1").transform:GetComponent("Image")
    self.jcbg_2 = self.transform:Find("Root/JC/bg/jcbg_2").transform:GetComponent("Image")
    self.jcname_2 = self.transform:Find("Root/JC/bg/jcbg_2/jcname_2").transform:GetComponent("Image")
    self.jcbg_3 = self.transform:Find("Root/JC/bg/jcbg_3").transform:GetComponent("Image")
    self.jcname_3 = self.transform:Find("Root/JC/bg/jcbg_3/jcname_3").transform:GetComponent("Image")
    self.jcbg_4 = self.transform:Find("Root/JC/bg/jcbg_4").transform:GetComponent("Image")
    self.jcname_4 = self.transform:Find("Root/JC/bg/jcbg_4/jcname_4").transform:GetComponent("Image")
    self:on_elimiante_fx_money_msg()
    self.nor_game_fx = self.transform:Find("Part/UI_yun")
    self.big_game_fx = self.transform:Find("Part/UI_xyx_beijing")
    self.animContent = self.transform:Find("Root/Viewport/AnimContent")

    -- 入口按钮
    local btn_map = {}
    btn_map["mrrw_node"] = {self.mrrw_node}
    btn_map["top_left_node"] = {self.tl_node}
    btn_map["top_right_node"] = {self.tr_node}
	-- btn_map["left_down"] = {self.left_down}
	-- btn_map["left_enter"] = {self.left_enter}
	-- btn_map["top"] = {self.left_top}
	-- btn_map["center"] = {self.center}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxlfx_game")

    -- HandleLoadChannelLua("EliminateFXGamePanel", self)

    self:ChangeBgView("nor")
    self:InitJc3()
    self:InitJc4()
    self:RefreshAllJC()
end

function M:MyRefresh(b)
    
    if EliminateFXModel.DataDamage() then return end
    local m_data = EliminateFXModel.data
    dump(m_data, "<color=yellow>刷新数据</color>")
    
    if is_first then
        is_first = false
    end
    -- self:RefreshAllJC()
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            dump(m_data.eliminate_data.result[1].map_base,"<color=yellow><size=15>++++++++++m_data.eliminate_data.result++++++++++</size></color>")
            EliminateFXObjManager.ClearEliminateItem()
            EliminateFXObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base)
        else
            local last_data = m_data.eliminate_data.result[#m_data.eliminate_data.result]
            dump(last_data,"<color=yellow><size=15>++++++++++last_data++++++++++</size></color>")
            if not table_is_null(last_data.map_new) then
                EliminateFXObjManager.ClearEliminateItem()
                EliminateFXObjManager.CreateEliminateItem(last_data.map_new,last_data.bgj_rate_map)
            end
            -- ExtendSoundManager.PauseSceneBGM()
            --model处理开奖结束的数据
            EliminateFXModel.SetDataLotteryEnd()
            local level = EliminateFXModel.GetAllResultLevel()
            local result_data = EliminateFXModel.GetAllResultData()
            local seq = DoTweenSequence.Create()
            -- if m_data.eliminate_data.has_little then
            --     local data = eliminate_fx_algorithm.GetCalculateRate(m_data.eliminate_data)
            --     EliminateFXAnimManager.DoAddMoneyToJc(seq, data, self.animContent)
            -- end
            seq:AppendInterval(EliminateFXModel.GetTime(EliminateFXModel.time["show_clear" .. level]))
            seq:OnKill(function ()
                --开奖结束
                if m_data.eliminate_data.has_little then
                    local fxjjRate = EliminateFXModel.GetLittleSpecRate()
                    if fxjjRate > 0 then
                        EliminateFXObjManager.ClearScoreObj()
                        EliminateFXObjManager.InitScore()
                        EliminateFXAnimManager.ShowFxjj(self.animContent, fxjjRate)
                    end
                end
                self:RefreshLotteryBtns()
                Event.Brocast("view_lottery_end",result_data,not b)
                ExtendSoundManager.CloseSound(self.sound_key)
                self:ChangeBgView("nor")
            end)
            return
        end        
    end
    EliminateFXModel.SetDataLotteryEnd()
    self:RefreshLotteryBtns()
    Event.Brocast("eliminate_refresh_end")
end

function M:MyExit()
    EliminateFXGamePanel.ExitTimer()
    self:ClearJc3Timer()
    self:ClearJc4Timer()
    Event.Brocast("view_quit_game")
    EliminateFXLogic.clearViewMsgRegister(listerRegisterName)
    if M.auto_lotter_timer then 
        M.auto_lotter_timer:Stop()
        M.auto_lotter_timer = nil
    end
    if self.game_btn_pre then
		self.game_btn_pre:MyExit()
    end
    EliminateFXObjManager.Exit()
    

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
    EliminateFXAnimManager.ExitTimer()
    EliminateFXObjManager.ExitTimer()
    EliminateFXPartManager.ExitTimer()
end

function M:MakeLister()
    lister = {}
    lister["model_lottery_success"] = basefunc.handler(self, self.model_lottery_success)
    lister["model_lottery_error"] = basefunc.handler(self, self.model_lottery_error)
    lister["auto_lottery"] = basefunc.handler(self, self.auto_lottery)
    lister["all_info_is_reconnection_msg"] = basefunc.handler(self, self.on_all_info_is_reconnection_msg)
    lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    lister["elimiante_fx_money_msg"] = basefunc.handler(self,self.on_elimiante_fx_money_msg)
    -- lister["eliminateFX_had_settel_msg"] = basefunc.handler(self,self.on_eliminateFX_had_settel_msg)
    lister["xxl_fuxing_award_pool_3_increase"] = basefunc.handler(self,self.on_xxl_fuxing_award_pool_3_increase)
    lister["xxl_fuxing_award_pool_4_increase"] = basefunc.handler(self,self.on_xxl_fuxing_award_pool_4_increase)
    lister["xxl_fuxing_award_pool_consume"] = basefunc.handler(self,self.on_xxl_fuxing_award_pool_consume)
    lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
end

function M:auto_lottery()
    print("<color=yellow>托管开奖</color>")
    if EliminateFXModel.DataDamage() then return end
    if EliminateFXModel.GetAuto() then
        --托管自动开奖
        self:AutoLottery()
    else
        --model处理开奖结束的数据
        EliminateFXModel.SetDataLotteryEnd()
        --开奖结束
        self:RefreshLotteryBtns()
    end
end

function M:model_lottery_error()
    print("<color=yellow>开奖错误</color>")
    if EliminateFXModel.DataDamage() then return end
    local m_data = EliminateFXModel.data
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            EliminateFXObjManager.ClearEliminateItem()
            EliminateFXObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base,m_data.eliminate_data.result[1].bgj_rate_map)
        else
            if not table_is_null(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new) then
                EliminateFXObjManager.ClearEliminateItem()
                EliminateFXObjManager.CreateEliminateItem(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new)
            end
        end
    end
    self:RefreshLotteryBtns()
    Event.Brocast("view_lottery_error")
end

function M:model_lottery_success()
    dump(debug.traceback())
    print("<color=yellow>开奖成功</color>")
    if EliminateFXModel.DataDamage() then return end
    -- if (EliminateFXModel.data.state ~= EliminateFXModel.xc_state.nor) and (EliminateFXModel.data.state ~= EliminateFXModel.xc_state.null) and (EliminateFXModel.data.state ~= EliminateFXModel.xc_state.select) then return end
    local m_data = EliminateFXModel.data
    if EliminateFXModel.data.state == "nor" then
        -- self.isLastHasLittle = false
        self:RefreshLotteryBtns()
    end
    if EliminateFXModel.GetSkip() then
        dump(m_data.eliminate_data, "<color=red>跳过动画，直接到最后的结果</color>")
        self:lottery_end()
    else
        local new_map = m_data.eliminate_data.result[1].map_base
        local bgj_rate_map = m_data.eliminate_data.result[1].bgj_rate_map
        local times = {
            ys_j_sgdjg = EliminateFXModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateFXModel.time.ys_ysgdsj,
            ys_ysgdsj_add = EliminateFXModel.time.ys_ysgdsj_add,
        }
        EliminateFXAnimManager.StopScrollLottery(new_map,function()
            self:HideSkipBtn()
            self:lottery_start(m_data)
        end,times,nil,bgj_rate_map)
        dump(m_data.eliminate_data, "<color=red>正常开奖</color>")
    end
    Event.Brocast("view_lottery_sucess")
end

function M:lottery_start(m_data)
    local data = m_data.eliminate_data
    EliminateFXObjManager.ExitTimer()
    local index = 0
    local lottery
    lottery = function (is_first)
        if EliminateFXModel.DataDamage() then return end
        if index == #data.result then
            --本局没有可以开奖的元素了，本局开奖结束
            if data.state ~= "big_game" and data.has_little then
                self:ChangeBgView("big_game")
                EliminateFXObjManager.InitScore()
                EliminateFXPartManager.ChangeAni(function ()
                    self:Lottery2()    
                end)
                -- self.isLastHasLittle = true
            else
                for i,v in ipairs(data.result) do
                    dump(v,"<color=red><size=15>+/"..i.."/++++++8888888++++++++</size></color>")
                end
                -- local tab = eliminate_fx_algorithm.GetCalculateRate(data)
                -- dump(tab,"<color=yellow><size=15>++++++++++tab++++++++++</size></color>")
                -- EliminateFXObjManager.ClearScore()
                self:lottery_end()
            end
            return
        elseif index > 0 and EliminateFXModel.IsFullGameRateMap() then
            self:lottery_end()
            return
        end
        index = index + 1
        local cur_data = data.result[index]
        dump(cur_data, "<color=red>WWWWWWWWWW cur_data</color>")
        
        EliminateFXObjManager.Lottery(index,lottery,is_first)
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
    if IsEquals(self.lottery_img) and IsEquals(self.lottery_img.color) and IsEquals(self.lottery_img2) and IsEquals(self.lottery_img2.color) then
        self.lottery_img.raycastTarget = true
        self.lottery_img.color = Color.white
        self.lottery_img2.raycastTarget = true
        self.lottery_img2.color = Color.white
    else
        if AppDefine.IsEDITOR() then
            HintPanel.Create(1, "问题：XXL color设置失败!")
            dump(self.lottery_img)
            dump(self.lottery_img.color)
        end
    end
    if EliminateFXModel.DataDamage() then return end
    local m_data = EliminateFXModel.data
    local auto = EliminateFXModel.GetAuto()
    print(debug.traceback())
    dump(auto,"<color=yellow><size=15>++++++++++auto++++++++++</size></color>")
    if not auto then
        if m_data.status_lottery == EliminateFXModel.status_lottery.wait then
            self.lottery_btn.transform.gameObject:SetActive(true)
            self.skip_btn.transform.gameObject:SetActive(false)
        elseif m_data.status_lottery == EliminateFXModel.status_lottery.run then
            self.lottery_btn.transform.gameObject:SetActive(false)
            self.skip_btn.transform.gameObject:SetActive(true)
        -- elseif m_data.status_lottery == EliminateFXModel.status_lottery.run_prog then
        --     self.lottery_btn.transform.gameObject:SetActive(false)
        --     self.skip_btn.transform.gameObject:SetActive(false)
        end
    else
        self.lottery_btn.transform.gameObject:SetActive(false)
        self.skip_btn.transform.gameObject:SetActive(false)
    end
    self.auto_btn.gameObject:SetActive(auto)
end

function M:RefreshYXCard()
    local open, yxcard, game_level, qp_image = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateFXModel.yxcard_type}, "GetCurGameCard")
    dump({
        yxcard = yxcard,
        status_lottery = EliminateFXModel.data.status_lottery,
        raycastTarget = self.lottery_img.raycastTarget ,
        auto = EliminateFXModel.GetAuto()
    }, "<color=red>【游戏卡状态刷新】</color>")
    if open then
        if not EliminateFXModel.GetAuto() 
        and EliminateFXModel.data.status_lottery == EliminateFXModel.status_lottery.wait 
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
    EliminateFXLogic.quit_game()
end

function M:AutoLottery()
    if M.auto_lotter_timer then M.auto_lotter_timer:Stop() end
    M.auto_lotter_timer = Timer.New(function ()
        print("<color=red>托管开奖开始</color>")
        self:Lottery()
    end,EliminateFXModel.GetTime(EliminateFXModel.time.xc_zdkj),1)
    M.auto_lotter_timer:Start()
end

function M:Lottery(_card_type)
    dump(EliminateFXModel.data.bet, "<color=red>消消乐开奖</color>")
    EliminateFXModel.data.state = "nor"
    --Event.Brocast("open_sys_act_base")
    ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_ksxc.audio_name)
    EliminateFXObjManager.ClearScoreObj()
    EliminateFXObjManager.ClearAnimObj()
    local item_map = EliminateFXObjManager.GetAllEliminateItem()
    local times = {
        ys_jsgdsj = EliminateFXModel.time.ys_jsgdsj,
        ys_ysgdjg = EliminateFXModel.time.ys_ysgdjg,
        ys_j_sgdsj = EliminateFXModel.time.ys_j_sgdsj,
        ys_jsgdjg = EliminateFXModel.time.ys_jsgdjg
    }
    EliminateFXAnimManager.ScrollLottery(item_map,times)

    --测试数据
    if EliminateFXLogic.is_test then
        M.Test()
        return
    end
    Event.Brocast("view_lottery_start")
    if _card_type then
        Network.SendRequest("xxl_fuxing_main_kaijiang",{bets = EliminateFXModel.data.bet, card_type = _card_type},"连接中") 
    else
        Network.SendRequest("xxl_fuxing_main_kaijiang",{bets = EliminateFXModel.data.bet},"连接中") 
    end
end

function M:Lottery2()
    dump(EliminateFXModel.data.bet, "<color=red>消消乐开奖2</color>")
    EliminateFXModel.data.state = "big_game"
    Event.Brocast("free_game_times_change_msg",7)
    --Event.Brocast("open_sys_act_base")
    ExtendSoundManager.PlaySound(audio_config.fxgz.bgm_fxgz_ksxc.audio_name)
    local item_map = EliminateFXObjManager.GetAllEliminateItem()
    local need_show_map = {}
    for x,v in pairs(item_map) do
        need_show_map[x] = need_show_map[x] or {}
        for y,vv in pairs(v) do
            need_show_map[x][y] = vv:ClearScore()
        end
    end
    dump(need_show_map,"<color=yellow><size=15>++++++++++need_show_map++++++++++</size></color>")
    local times = {
        ys_jsgdsj = EliminateFXModel.time.ys_jsgdsj,
        ys_ysgdjg = EliminateFXModel.time.ys_ysgdjg,
        ys_j_sgdsj = EliminateFXModel.time.ys_j_sgdsj,
        ys_jsgdjg = EliminateFXModel.time.ys_jsgdjg
    }
    EliminateFXAnimManager.ScrollLottery(item_map,times,true)
    Event.Brocast("view_lottery_start",true)
    EliminateFXModel.BigGame_Kaijiang()
    local data = EliminateFXModel.data.eliminate_data.result[1]
    EliminateFXModel.UpdateFirstSendRateMap(need_show_map)
    EliminateFXObjManager.RefreshAllScore(EliminateFXModel.GetBigGameRateMap(), data.map_new)
end

local is_up = false
function M:OnClickLotteryDown()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if EliminateFXModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateFXModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        Event.Brocast("show_gift_panel")
        self.lottery_img.raycastTarget = true
        self.lottery_img2.raycastTarget = true
        return
    end
    is_up = false

    self.lottery_down_time = os.time()
    local seq = DoTweenSequence.Create()
    seq:AppendInterval(EliminateFXModel.time.xc_zdkj_jg)
    seq:AppendCallback(function ()
        self.auto_img.raycastTarget = false
        if not is_up then
            self.auto_btn.gameObject:SetActive(true)
        end
    end)
end

function M:OnClickLotteryUp(  )
    if EliminateFXModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateFXModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        self.lottery_img.raycastTarget = true
        self.lottery_img2.raycastTarget = true
        return
    end
    is_up = true

    if self.lottery_down_time and os.time() - self.lottery_down_time >= EliminateFXModel.time.xc_zdkj_jg then
        --自动消除
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=white>自动消除</color>")
        EliminateFXModel.SetAuto(true)
        -- self:RefreshLotteryBtns()
    end
    self:Lottery()
    self.lottery_img.raycastTarget = false
    self.lottery_img2.raycastTarget = false
end

function M:OnClickSkip()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:HideSkipBtn()
    EliminateFXGamePanel.ExitTimer()
    if GameGlobalOnOff.XXLSkipAllAni then
        --直接出结果
        self:MyRefresh()
    else
        --开始开奖
        self:lottery_start(EliminateFXModel.data)
        EliminateFXObjManager.EliminateItemMoneyAni(EliminateFXModel.data.eliminate_data.result[1].map_base)
        -- EliminateFXPartManager.ClearAll()
    end
end

function M:OnClickAuto()
    --取消托管
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.auto_img.raycastTarget = false
    EliminateFXModel.SetAuto( not EliminateFXModel.GetAuto())
    self:RefreshLotteryBtns()
    if not EliminateFXModel.data.ScrollLottery or EliminateFXModel.data.state then
        self:HideSkipBtn()
    end
end

function M:HideSkipBtn()
    self.skip_img.raycastTarget = false
    self.skip_btn.gameObject:SetActive(false)
    self.lottery_img.color = Color.gray
    self.lottery_img.raycastTarget = false
    self.lottery_img2.color = Color.gray
    self.lottery_img2.raycastTarget = false
    self.lottery_btn.gameObject:SetActive(true)
end

--点击游戏卡
function M:OnClickYXCard()
    local open, yxcard, game_level  = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateFXModel.yxcard_type}, "GetCurGameCard")
    if open and self.lottery_img.raycastTarget and self.lottery_img2.raycastTarget then
        dump({yxcard = yxcard, game_level = game_level}, "<color=white>【使用游戏卡】</color>")
        --EliminateFXModel.SetBet({game_level/5, game_level/5, game_level/5, game_level/5, game_level/5})
        self:Lottery(yxcard)
        Event.Brocast("view_lottery_start_yxcard", game_level)
    end
end

--测试代码
function M.Test()
    Event.Brocast("view_lottery_start")
    local data = EliminateFXLogic.GetTestData("nor")
    Event.Brocast("xxl_fuxing_main_kaijiang_response", "xxl_fuxing_main_kaijiang_response",data)
end

function M:on_all_info_is_reconnection_msg(data)
    if data then
        dump(data,"<color=yellow><size=15>++++++111++++on_all_info_is_reconnection_msg++++++++++</size></color>")
        data.status_data.status = EliminateFXModel.xc_state.nor
        local m_data = eliminate_fx_algorithm.compute_eliminate_result(EliminateFXModel.ToDealWithData("nor",data))
        dump(m_data,"<color=yellow><size=15>+++++222+++++on_all_info_is_reconnection_msg++++++++++</size></color>")
        if not table_is_null(m_data.result[#m_data.result].map_new) then
            EliminateFXObjManager.ClearEliminateItem()
            EliminateFXObjManager.CreateEliminateItem(m_data.result[#m_data.result].map_new)
        end
    end
end

function M:ChangeBgView(state)
    if state == "big_game" then
        self.bg_img.sprite = GetTexture("fxgz_bg_bjt_xyx")
        self.big_game_fx.gameObject:SetActive(true)
        self.nor_game_fx.gameObject:SetActive(false)
        ExtendSoundManager.PlaySceneBGM(audio_config.fxgz.bgm_fxgz_bg_2.audio_name)
    elseif state == "nor" then
        self.bg_img.sprite = GetTexture("fxgz_bg_bjt")
        self.big_game_fx.gameObject:SetActive(false)
        self.nor_game_fx.gameObject:SetActive(true)
        ExtendSoundManager.PlaySceneBGM(audio_config.fxgz.bgm_fxgz_bg_1.audio_name)
    end
end

function M:on_elimiante_fx_money_msg(num)
    local num = num or EliminateFXModel.data.bet[1] * 5
    for i=1,4 do
        self["jcbg_" .. i].color = Color.gray
        self["jcname_" .. i].color = Color.gray
        self["jc_num_" .. i .. "_txt"].color = Color.gray
    end
    if num >= 2000 then
        self.jcbg_4.color = Color.New(1,1,1,1)
        self.jcname_4.color = Color.New(1,1,1,1)
        self.jc_num_4_txt.color = Color.New(235/255,234/255,142/255,1)
    end
    if num >= 8000 then
        self.jcbg_3.color = Color.New(1,1,1,1)
        self.jcname_3.color = Color.New(1,1,1,1)
        self.jc_num_3_txt.color = Color.New(235/255,234/255,142/255,1)
    end
    if num >= 60000 then
        self.jcbg_2.color = Color.New(1,1,1,1)
        self.jcname_2.color = Color.New(1,1,1,1)
        self.jc_num_2_txt.color = Color.New(235/255,234/255,142/255,1)
    end
    if num >= 480000 then
        self.jcbg_1.color = Color.New(1,1,1,1)
        self.jcname_1.color = Color.New(1,1,1,1)
        self.jc_num_1_txt.color = Color.New(235/255,234/255,142/255,1)
    end
    self:RefreshJcFromYazhuChange()
end

function M:OnClickHelp()
    EliminateFXHelpPanel.Create()
end

-- function M:on_eliminateFX_had_settel_msg()
--     if self.isLastHasLittle then
--         EliminateFXAnimManager.ResetJC(self.animContent)
--     end
-- end

function M:ClearJc3Timer()
    if self.jc3Timer then
        self.jc3Timer:Stop()
        self.jc3Timer = nil
    end
end
function M:ClearJc4Timer()
    if self.jc4Timer then
        self.jc4Timer:Stop()
        self.jc4Timer = nil
    end
end

--大奖
function M:InitJc3()
    self:ClearJc3Timer()
    self.curJc3 = 0
    --单位时间增长量
    self.dJc3Increase = 0
    --增长计数
    self.curJc3IncreaseTime = 0
    --增长计数长度
    self.jc3TimeIncrease = 0
    self.jc3Timer = Timer.New(function()
        if self.curJc3IncreaseTime < self.jc3TimeIncrease then
            self.curJc3 = self.curJc3 + self.dJc3Increase
            self.curJc3IncreaseTime = self.curJc3IncreaseTime + 1
        end
        self:RefreshJc3(self.curJc3)
    end, 1, -1)
    self.jc3Timer:Start()
end

--奖池增长，num 增长的数量 time 达到增长数量需要的时间
function M:Jc3Increase(num, time)
    --奖池增长的时间
    self.curJc3IncreaseTime = 0
    self.jc3TimeIncrease = time
    self.dJc3Increase = num / time
end

function M:Jc3Consume(consumeNum)
    if self.curJc3 - consumeNum > 0 then
        self.curJc3 = self.curJc3 - consumeNum
    end
end

--巨奖
function M:InitJc4()
    self:ClearJc4Timer()
    self.curJc4 = 0
    self.dJc4Increase = 0
    self.curJc4IncreaseTime = 0
    self.jc4TimeIncrease = 0
    self.jc4Timer = Timer.New(function()
        if self.curJc4IncreaseTime < self.jc4TimeIncrease then
            self.curJc4 = self.curJc4 + self.dJc4Increase
            self.curJc4IncreaseTime = self.curJc4IncreaseTime + 1
        end
        self:RefreshJc4(self.curJc4)
    end, 1, -1)
    self.jc4Timer:Start()
end

--奖池增长，num 增长的数量 time 达到增长数量需要的时间
function M:Jc4Increase(num, time)
    self.curJc4IncreaseTime = 0
    self.jc4TimeIncrease = time
    self.dJc4Increase = num / time
end

function M:Jc4Consume(consumeNum)
    if self.curJc4 - consumeNum > 0 then
        self.curJc4 = self.curJc4 - consumeNum
    end
end

function M:on_xxl_fuxing_award_pool_3_increase(data)
    dump(data, "<color=white>on_xxl_fuxing_award_pool_3_increase</color>")
    local targetNum = EliminateFXModel.GetAwardPool3()
    if data.isNewPool then
        self:InitJc3()
        local advanceNum = math.random(100, 200)
        self.curJc3 = targetNum - advanceNum
        self:Jc3Increase(advanceNum, 60)
        dump(self.curJc3, "<color=white>初始化大奖奖池为</color>")
    else
        local increaseNum = targetNum - self.curJc3
        if increaseNum > 0 then
            self:Jc3Increase(increaseNum, 60)
        end
    end
end

function M:on_xxl_fuxing_award_pool_4_increase(data)
    dump(data, "<color=white>on_xxl_fuxing_award_pool_4_increase</color>")
    local targetNum = EliminateFXModel.GetAwardPool4()
    if data.isNewPool then
        self:InitJc4()
        local advanceNum = math.random(180, 300)
        self.curJc4 = targetNum - advanceNum
        self:Jc4Increase(advanceNum, 60)
        dump(self.curJc4, "<color=white>初始化巨奖奖池为</color>")
    else
        local increaseNum = targetNum - self.curJc4
        if increaseNum > 0 then
            self:Jc4Increase(increaseNum, 60)
        end
    end
end

--奖池消耗，只有大奖和巨奖会消耗奖池内的数量
function M:on_xxl_fuxing_award_pool_consume(data)
    dump(data, "<color=white>on_xxl_fuxing_award_pool_consume</color>")
    if data.take_pool_id == 3 then
        self:Jc3Consume(data.take_pool_award)
    elseif data.take_pool_id == 4 then
        self:Jc4Consume(data.take_pool_award)
    end
end

function M:onEnterBackGround()
    self:ClearJc4Timer()
    self:ClearJc3Timer()
end

--刷新所有奖池
function M:RefreshAllJC()
    self:RefreshJc1()
    self:RefreshJc2()
    self:RefreshJc3()
    self:RefreshJc4()
end

--押注改变时，刷新小奖和中奖
function M:RefreshJcFromYazhuChange()
    self:RefreshJc1()
    self:RefreshJc2()
end

function M:RefreshJc1()
    self.jc_num_4_txt.text = EliminateFXModel.GetAwardPool1()
end

function M:RefreshJc2()
    self.jc_num_3_txt.text = EliminateFXModel.GetAwardPool2()
end

function M:RefreshJc3(value)
    if value then
        self.jc_num_2_txt.text = math.floor(value) 
    else
        self.jc_num_2_txt.text = EliminateFXModel.GetAwardPool3()
    end
end

function M:RefreshJc4(value)
    if value then
        self.jc_num_1_txt.text =  math.floor(value)
    else
        self.jc_num_1_txt.text = EliminateFXModel.GetAwardPool4()
    end
end