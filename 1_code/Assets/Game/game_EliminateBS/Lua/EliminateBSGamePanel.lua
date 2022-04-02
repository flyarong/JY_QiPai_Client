local basefunc = require "Game.Common.basefunc"
EliminateBSGamePanel = basefunc.class()

local M = EliminateBSGamePanel
M.name = "EliminateBSGamePanel"
local lister
local listerRegisterName = "EliminateBSGameListerRegister"
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
    ExtendSoundManager.PlaySceneBGM(audio_config.bsmz.bgm_bsmz_bg_1.audio_name)
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
    self:AddMsgListener()
    --EliminateBSLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onDown = basefunc.handler(self, self.OnClickLotteryDown)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onUp = basefunc.handler(self, self.OnClickLotteryUp)
    EventTriggerListener.Get(self.skip_btn.gameObject).onUp = basefunc.handler(self, self.OnClickSkip)
    EventTriggerListener.Get(self.auto_btn.gameObject).onUp = basefunc.handler(self, self.OnClickAuto)
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBack)
    EventTriggerListener.Get(self.yxcard_btn.gameObject).onClick = basefunc.handler(self, self.OnClickYXCard)


    EliminateBSInfoPanel.Create()
    EliminateBSMoneyPanel.Create()
    EliminateBSClearPanel.Create()
    
    EliminateBSObjManager.InitEliminateBG(EliminateBSModel.size.max_x,EliminateBSModel.size.max_y)

    self.skip_img = self.skip_btn.transform:GetComponent("Image")
    self.lottery_img = self.lottery_btn.transform:GetComponent("Image")
    self.lottery_img_1 = self.lottery_btn.transform:Find("Image").transform:GetComponent("Image")
    self.lottery_img_2 = self.lottery_btn.transform:Find("Image (1)").transform:GetComponent("Image")
    self.auto_img = self.auto_btn.transform:GetComponent("Image")
    self.yxcard_img = self.yxcard_btn.transform:GetComponent("Image")

    self.slider = self.Slider.transform:GetComponent("Slider")
    local btn_map = {}
	btn_map["left_down"] = {self.left_down}
	btn_map["left_enter"] = {self.left_enter}
	btn_map["top"] = {self.left_top}
	btn_map["center"] = {self.center}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxlsg_game")

    --HandleLoadChannelLua("EliminateBSGamePanel", self)

    --local canvas = self.task_node.transform:GetComponent("Canvas")
    --canvas.sortingOrder = 3
    --change_renderer(self.task_node, 3, true)

    Event.Brocast("open_act_027_panel")
    Event.Brocast("open_sys_act_base")

    --EliminateBSHJGamePanel.Create()
end

function M:MyRefresh()
    if EliminateBSModel.DataDamage() then return end

    local m_data = EliminateBSModel.data
    dump(m_data, "<color=yellow>刷新数据</color>")
    
    if is_first then
        is_first = false
    end
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            dump(m_data.eliminate_data.result[1].map_base,"<color=yellow><size=15>++++++++++m_data.eliminate_data.result++++++++++</size></color>")
            EliminateBSObjManager.ClearEliminateItem()
            EliminateBSObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base)
            self:RefreshButtomTask(true)
        else
            local last_data = m_data.eliminate_data.result[#m_data.eliminate_data.result]
            dump(last_data,"<color=yellow><size=15>++++++++++last_data++++++++++</size></color>")
            if not table_is_null(last_data.map_new) then
                EliminateBSObjManager.ClearEliminateItem()
                EliminateBSObjManager.CreateEliminateItem(last_data.map_new,last_data.bgj_rate_map)
            end
            -- ExtendSoundManager.PauseSceneBGM()
            --model处理开奖结束的数据
            EliminateBSModel.SetDataLotteryEnd()
            local level = EliminateBSModel.GetAllResultLevel()
            local result_data = EliminateBSModel.GetAllResultData()
            local seq = DoTweenSequence.Create()
            seq:AppendInterval(EliminateBSModel.GetTime(EliminateBSModel.time["show_clear" .. level]))
            seq:OnKill(function ()
                --开奖结束
                EliminateBSPartManager.RemoveEliminateItem_SpecialTXAll()
                self:RefreshLotteryBtns()
                Event.Brocast("view_lottery_end",result_data,true)
                self:SetFxActive(false)
                ExtendSoundManager.CloseSound(self.sound_key)
            end)
            self:RefreshButtomTask(true)
            return
        end        
    end
    EliminateBSModel.SetDataLotteryEnd()
    self:RefreshLotteryBtns()
    Event.Brocast("eliminate_refresh_end")
end

function M:MyExit()
    EliminateBSGamePanel.ExitTimer()
    Event.Brocast("view_quit_game")
    self:RemoveListener()
    --EliminateBSLogic.clearViewMsgRegister(listerRegisterName)
    if M.auto_lotter_timer then 
        M.auto_lotter_timer:Stop()
        M.auto_lotter_timer = nil
    end
    if self.game_btn_pre then
		self.game_btn_pre:MyExit()
    end
    EliminateBSObjManager.Exit()
    

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
    EliminateBSAnimManager.ExitTimer()
    EliminateBSObjManager.ExitTimer()
    EliminateBSPartManager.ExitTimer()
end

function M:MakeLister()
    self.lister = {}
    self.lister["model_lottery_success"] = basefunc.handler(self, self.model_lottery_success)
    self.lister["model_lottery_error"] = basefunc.handler(self, self.model_lottery_error)
    self.lister["auto_lottery"] = basefunc.handler(self, self.auto_lottery)
    self.lister["refresh_gamepanel_btn_msg"] = basefunc.handler(self, self.on_refresh_gamepanel_btn_msg)
    self.lister["all_info_is_reconnection_msg"] = basefunc.handler(self, self.on_all_info_is_reconnection_msg)
    self.lister["gamepanel_fx_set_false_msg"] = basefunc.handler(self, self.on_gamepanel_fx_set_false_msg)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
    self.lister["eliminatebs_slider_change_msg"] = basefunc.handler(self, self.on_eliminatebs_slider_change_msg)
    self.lister["view_lottery_start"] = basefunc.handler(self, self.eliminate_lottery_start)
    self.lister["hf_had_fly_finish_msg"] = basefunc.handler(self, self.on_hf_had_fly_finish_msg)
    self.lister["view_bshj_all_lottery_end"] = basefunc.handler(self, self.on_view_bshj_all_lottery_end)
    self.lister["eliminateBS_had_settel_msg"] = basefunc.handler(self, self.on_eliminateBS_had_settel_msg)
end

function M:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:auto_lottery()
    print("<color=yellow>托管开奖</color>")
    ----ExtendSoundManager.PlaySceneBGM(audio_config.sdbgj.bgm_sdbgj_beijing.audio_name)
    if EliminateBSModel.DataDamage() then return end
    if EliminateBSModel.GetAuto() then
        --托管自动开奖
        self:AutoLottery()
    else
        --model处理开奖结束的数据
        EliminateBSModel.SetDataLotteryEnd()
        --开奖结束
        self:RefreshLotteryBtns()
    end
end

function M:model_lottery_error()
    print("<color=yellow>开奖错误</color>")
    if EliminateBSModel.DataDamage() then return end
    local m_data = EliminateBSModel.data
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            EliminateBSObjManager.ClearEliminateItem()
            EliminateBSObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base,m_data.eliminate_data.result[1].bgj_rate_map)
        else
            if not table_is_null(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new) then
                EliminateBSObjManager.ClearEliminateItem()
                EliminateBSObjManager.CreateEliminateItem(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new)
            end
        end
    end
    self:RefreshLotteryBtns()
    Event.Brocast("view_lottery_error")
end

function M:model_lottery_success()
    print("<color=yellow>开奖成功</color>")
    if EliminateBSModel.DataDamage() then return end
    if (EliminateBSModel.data.state ~= EliminateBSModel.xc_state.nor) and (EliminateBSModel.data.state ~= EliminateBSModel.xc_state.null) and (EliminateBSModel.data.state ~= EliminateBSModel.xc_state.select) then return end
    local m_data = EliminateBSModel.data
    self:RefreshLotteryBtns()
    if EliminateBSModel.GetSkip() then
        dump(m_data.eliminate_data, "<color=red>跳过动画，直接到最后的结果</color>")
        self:lottery_end()
    else
        local new_map = m_data.eliminate_data.result[1].map_base
        local bgj_rate_map = m_data.eliminate_data.result[1].bgj_rate_map
        local times = {
            ys_j_sgdjg = EliminateBSModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateBSModel.time.ys_ysgdsj,
            ys_ysgdsj_add = EliminateBSModel.time.ys_ysgdsj_add,
        }
        EliminateBSAnimManager.StopScrollLottery(new_map,function()
            self:HideSkipBtn()
            self:lottery_start(m_data)
        end,times,nil,bgj_rate_map)
        dump(m_data.eliminate_data, "<color=red>正常开奖</color>")
    end
    Event.Brocast("view_lottery_sucess")
end

function M:lottery_start(m_data)
    local data = m_data.eliminate_data
    EliminateBSObjManager.ExitTimer()
    local index = 0
    local lottery
    lottery = function (is_first)
        if EliminateBSModel.DataDamage() then return end
        if index == #data.result then
            --本局没有可以开奖的元素了，本局开奖结束
            EliminateBSModel.data.state = "nor"
            --dump(data,"<color=yellow><size=15>++++++++++本局没有可以开奖的元素了，本局开奖结束++++++++++</size></color>")
            if data.is_free_game then
                self:SetFxActive(false)
                self:CreateBSHJ()
            else
                self:lottery_end()
            end
            return
        end
        index = index + 1
        local cur_data = data.result[index]
        --dump(cur_data, "<color=red>WWWWWWWWWW cur_data</color>")
        
        EliminateBSObjManager.Lottery(index,lottery,is_first)
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
    if IsEquals(self.lottery_img) and IsEquals(self.lottery_img.color) and IsEquals(self.lottery_img_1) and IsEquals(self.lottery_img_1.color) and IsEquals(self.lottery_img_2) and IsEquals(self.lottery_img_2.color) then
        self.lottery_img.raycastTarget = true
        self.lottery_img.color = Color.New(255/255,255/255,255/255,1/255)
        self.lottery_img_1.color = Color.New(255/255,255/255,255/255,255/255)
        self.lottery_img_2.color = Color.New(255/255,255/255,255/255,255/255)
    else
        if AppDefine.IsEDITOR() then
            HintPanel.Create(1, "问题：XXL color设置失败!")
            dump(self.lottery_img)
            dump(self.lottery_img.color)
        end
    end
    if EliminateBSModel.DataDamage() then return end
    local m_data = EliminateBSModel.data
    local auto = EliminateBSModel.GetAuto()
    if not auto then
        if m_data.status_lottery == EliminateBSModel.status_lottery.wait then
            self.lottery_btn.transform.gameObject:SetActive(true)
            self.skip_btn.transform.gameObject:SetActive(false)
        elseif m_data.status_lottery == EliminateBSModel.status_lottery.run then
            self.lottery_btn.transform.gameObject:SetActive(false)
            self.skip_btn.transform.gameObject:SetActive(true)
        elseif m_data.status_lottery == EliminateBSModel.status_lottery.run_prog then
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
    local open, yxcard, game_level, qp_image = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateBSModel.yxcard_type}, "GetCurGameCard")
    dump({
        yxcard = yxcard,
        status_lottery = EliminateBSModel.data.status_lottery,
        raycastTarget = self.lottery_img.raycastTarget ,
        auto = EliminateBSModel.GetAuto()
    }, "<color=red>【游戏卡状态刷新】</color>")
    if open then
        if not EliminateBSModel.GetAuto() 
        and EliminateBSModel.data.status_lottery == EliminateBSModel.status_lottery.wait 
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
    EliminateBSLogic.quit_game()
end

function M:AutoLottery()
    if M.auto_lotter_timer then M.auto_lotter_timer:Stop() end
    M.auto_lotter_timer = Timer.New(function ()
        print("<color=red>托管开奖开始</color>")
        self:Lottery()
    end,EliminateBSModel.GetTime(EliminateBSModel.time.xc_zdkj),1)
    M.auto_lotter_timer:Start()
end

function M:Lottery(_card_type)
    dump(EliminateBSModel.data.bet, "<color=red>消消乐开奖</color>")
    --//--ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_bsmz_ksxc.audio_name)
    local item_map = EliminateBSObjManager.GetAllEliminateItem()
    local times = {
        ys_jsgdsj = EliminateBSModel.time.ys_jsgdsj,
        ys_ysgdjg = EliminateBSModel.time.ys_ysgdjg,
        ys_j_sgdsj = EliminateBSModel.time.ys_j_sgdsj,
        ys_jsgdjg = EliminateBSModel.time.ys_jsgdjg
    }
    EliminateBSAnimManager.ScrollLottery(item_map,times)

    --测试数据
    if EliminateBSLogic.is_test then
        M.Test()
        return
    end
    Event.Brocast("view_lottery_start")
    local extend_bet = 0
    if EliminateBSModel.is_ew_bet then
        extend_bet = 1
    end
    if _card_type then
        Network.SendRequest("xxl_baoshi_main_kaijiang",{bets = EliminateBSModel.data.bet,extend_bet = extend_bet, card_type = _card_type},"连接中") 
    else
        Network.SendRequest("xxl_baoshi_main_kaijiang",{bets = EliminateBSModel.data.bet,extend_bet = extend_bet},"连接中") 
    end
end

local is_up = false
function M:OnClickLotteryDown()
    --ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if EliminateBSModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateBSModel.data.bet) do
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
    seq:AppendInterval(EliminateBSModel.time.xc_zdkj_jg)
    seq:AppendCallback(function ()
        self.auto_img.raycastTarget = false
        if not is_up then
            self.auto_btn.gameObject:SetActive(true)
        end
    end)
end

function M:OnClickLotteryUp(  )
    if EliminateBSModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateBSModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        self.lottery_img.raycastTarget = true
        return
    end
    is_up = true

    if self.lottery_down_time and os.time() - self.lottery_down_time >= EliminateBSModel.time.xc_zdkj_jg then
        --自动消除
        --ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=white>自动消除</color>")
        EliminateBSModel.SetAuto(true)
        -- self:RefreshLotteryBtns()
    end
    self:Lottery()
    self.lottery_img.raycastTarget = false
end

function M:OnClickSkip()
    --ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:HideSkipBtn()
    EliminateBSGamePanel.ExitTimer()
    if GameGlobalOnOff.XXLSkipAllAni then
        --直接出结果
        self:MyRefresh()
    else
        --开始开奖
        self:lottery_start(EliminateBSModel.data)
        EliminateBSObjManager.EliminateItemMoneyAni(EliminateBSModel.data.eliminate_data.result[1].map_base)
        EliminateBSPartManager.ClearAll()
    end
end

function M:OnClickAuto()
    --取消托管
    --ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.auto_img.raycastTarget = false
    EliminateBSModel.SetAuto( not EliminateBSModel.GetAuto())
    self:RefreshLotteryBtns()
    if not EliminateBSModel.data.ScrollLottery or EliminateBSModel.data.state then
        self:HideSkipBtn()
    end
end

function M:HideSkipBtn()
    self.skip_img.raycastTarget = false
    self.skip_btn.gameObject:SetActive(false)
    self.lottery_img.color = Color.New(128/255,128/255,128/255,1/255)
    self.lottery_img_1.color = Color.New(128/255,128/255,128/255,255/255)
    self.lottery_img_2.color = Color.New(128/255,128/255,128/255,255/255)
    self.lottery_img.raycastTarget = false
    self.lottery_btn.gameObject:SetActive(not EliminateBSModel.GetAuto())
end

--点击游戏卡
function M:OnClickYXCard()
    local open, yxcard, game_level  = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateBSModel.yxcard_type}, "GetCurGameCard")
    if open and self.lottery_img.raycastTarget then
        dump({yxcard = yxcard, game_level = game_level}, "<color=white>【使用游戏卡】</color>")
        EliminateBSModel.SetBet({game_level/5, game_level/5, game_level/5, game_level/5, game_level/5})
        self:Lottery(yxcard)
        Event.Brocast("view_lottery_start_yxcard")
    end
end

--测试代码
function M.Test()
    Event.Brocast("view_lottery_start")
    local data = EliminateBSLogic.GetTestData("nor")
    Event.Brocast("xxl_baoshi_main_kaijiang_response","xxl_baoshi_main_kaijiang_response",data)
end

--刷新下方进度
function M:RefreshButtomTask(is_sever)
    if is_sever then
        local data = EliminateBSModel.data.eliminate_data
        if data and data.little_prog then
            if data.little_prog >= 100 then
                self.slider_realy = 1
            else
                self.slider_realy = data.little_prog / 100
            end
        else
            self.slider_realy = 0
        end
        self.slider_img.gameObject:SetActive(self.slider_realy >= 1)
    else
        self.slider_img.gameObject:SetActive(self.slider_realy >= 1)
    end
    self.tou.gameObject:SetActive((self.slider_realy ~= 0) and (self.slider_realy ~= 1))
    self:refreshSlider()
    if self.slider_realy >= 1 then
        self:SetFxActive(true)
    else
        self:SetFxActive(false)
    end
end

function M:refreshSlider()
    --[[if (self.slider_realy <= 0.99) and (self.slider_realy >= 0.95) then
        self.slider.value = 0.95
    else
        self.slider.value = self.slider_realy
    end--]]
    self.slider.value = self.slider_realy
end

function M:on_refresh_gamepanel_btn_msg()
    self:RefreshLotteryBtns()
end

function M:on_view_bshj_all_lottery_end()
    self:RefreshLotteryBtns()
end

function M:on_all_info_is_reconnection_msg(data)
    if data then
        dump(data,"<color=yellow><size=15>++++++111++++on_all_info_is_reconnection_msg++++++++++</size></color>")
        local m_data = eliminate_bs_algorithm.compute_eliminate_result(EliminateBSModel.ToDealWithData("nor",data))
        dump(m_data,"<color=yellow><size=15>+++++222+++++on_all_info_is_reconnection_msg++++++++++</size></color>")
        if not table_is_null(m_data.result[#m_data.result].map_new) then
            EliminateBSObjManager.ClearEliminateItem()
            EliminateBSObjManager.CreateEliminateItem(m_data.result[#m_data.result].map_new)
        end
    end
end


function M:SetFxActive(b)
    if IsEquals(self.bsmz_eff_jdtman) then
        self.bsmz_eff_jdtman.gameObject:SetActive(b)
    end
    if IsEquals(self.bsmz_eff_jdtbs) then
        self.bsmz_eff_jdtbs.gameObject:SetActive(b)
    end
    -- if b then
    --     self.sound_key = ExtendSoundManager.PlaySound(audio_config.bsmz.bgm_cbzz_ranshao.audio_name,100,function ()
    --         self.sound_key = nil
    --     end)
    -- else
    --     ExtendSoundManager.CloseSound(self.sound_key)
    --     self.sound_key = nil
    -- end
    --[[self.hou_04.gameObject:SetActive(b)
    self.hou_05.gameObject:SetActive(b)
    self.hou_06.gameObject:SetActive(b)
    self.kuang.gameObject:SetActive(b)--]]
end

function M:on_gamepanel_fx_set_false_msg()
    self:SetFxActive(false)
end

function M:on_hf_had_fly_finish_msg()
    --self:SetFxActive(false)
end

function M:on_eliminatebs_slider_change_msg(value)
    --[[self.count = self.count or 0
    self.count = self.count + value
    dump(self.count,"<color=yellow><size=15>+++++++++//self.count++++++++++</size></color>")--]]
    self.slider_realy = self.slider_realy or 0
    self.slider_realy = self.slider_realy + value / 100
    self:RefreshButtomTask(false)
end

function M:eliminate_lottery_start()
    EliminateBSModel.slider_ani = false
    EliminateBSModel.slider_value = 0
    self.slider_realy = 0
    self:RefreshButtomTask(false)
end

function M:CreateBSHJ()
    local seq = DoTweenSequence.Create()
    seq:AppendCallback(function ()
        self.bsmz_eff_zhuanchang.gameObject:SetActive(true)
    end)
    seq:AppendInterval(2)
    seq:AppendCallback(function ()
        self.slider_node.gameObject:SetActive(false)
        self.bsmz_eff_zhuanchang.gameObject:SetActive(false)
        EliminateBSHJGamePanel.Create()
    end)
    seq:OnForceKill(function ()
        self.slider_node.gameObject:SetActive(false)
        self.bsmz_eff_zhuanchang.gameObject:SetActive(false)
    end)
end

function M:on_eliminateBS_had_settel_msg()
    self.slider_node.gameObject:SetActive(true)
    EliminateBSModel.slider_ani = false
    EliminateBSModel.slider_value = 0
    self.slider_realy = 0
    self:RefreshButtomTask(false)
end