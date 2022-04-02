local basefunc = require "Game.Common.basefunc"
EliminateSGGamePanel = basefunc.class()

local M = EliminateSGGamePanel
M.name = "EliminateSGGamePanel"
local lister
local listerRegisterName = "EliminateSGGameListerRegister"
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
    ExtendSoundManager.PlaySceneBGM(audio_config.cbzz.bgm_cbzz_beijing.audio_name)
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
    EliminateSGLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onDown = basefunc.handler(self, self.OnClickLotteryDown)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onUp = basefunc.handler(self, self.OnClickLotteryUp)
    EventTriggerListener.Get(self.skip_btn.gameObject).onUp = basefunc.handler(self, self.OnClickSkip)
    EventTriggerListener.Get(self.auto_btn.gameObject).onUp = basefunc.handler(self, self.OnClickAuto)
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBack)
    EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)
    EventTriggerListener.Get(self.yxcard_btn.gameObject).onClick = basefunc.handler(self, self.OnClickYXCard)


    EliminateSGInfoPanel.Create()
    EliminateSGMoneyPanel.Create()
    EliminateSGClearPanel.Create()
    
    EliminateSGObjManager.InitEliminateBG(EliminateSGModel.size.max_x,EliminateSGModel.size.max_y)

    self.skip_img = self.skip_btn.transform:GetComponent("Image")
    self.lottery_img = self.lottery_btn.transform:GetComponent("Image")
    self.auto_img = self.auto_btn.transform:GetComponent("Image")
    self.yxcard_img = self.yxcard_btn.transform:GetComponent("Image")

    self.slider1 = self.Slider1.transform:GetComponent("Slider")
    self.slider2 = self.Slider2.transform:GetComponent("Slider")
    self.baoxiang_ani = self.task_node.transform:Find("baoxiang").gameObject:GetComponent("Animator")
    self:RefreshButtomTask()
    local btn_map = {}
	btn_map["left_down"] = {self.left_down}
	btn_map["left_enter"] = {self.left_enter}
	btn_map["top"] = {self.left_top}
	btn_map["center"] = {self.center}
    self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxlsg_game")

    HandleLoadChannelLua("EliminateSGGamePanel", self)

    local canvas = self.task_node.transform:GetComponent("Canvas")
    canvas.sortingOrder = 3
    change_renderer(self.task_node, 3, true)

    Event.Brocast("open_act_027_panel")
    Event.Brocast("open_sys_act_base")
end

function M:MyRefresh()
    if EliminateSGModel.DataDamage() then return end
    local m_data = EliminateSGModel.data
    dump(m_data, "<color=yellow>刷新数据</color>")
    
    if is_first then
        is_first = false
    end
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            dump(m_data.eliminate_data.result[1].map_base,"<color=yellow><size=15>++++++++++m_data.eliminate_data.result++++++++++</size></color>")
            EliminateSGObjManager.ClearEliminateItem()
            EliminateSGObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base)
        else
            local last_data = m_data.eliminate_data.result[#m_data.eliminate_data.result]
            dump(last_data,"<color=yellow><size=15>++++++++++last_data++++++++++</size></color>")
            if not table_is_null(last_data.map_new) then
                EliminateSGObjManager.ClearEliminateItem()
                EliminateSGObjManager.CreateEliminateItem(last_data.map_new,last_data.bgj_rate_map)
            end
            -- ExtendSoundManager.PauseSceneBGM()
            --model处理开奖结束的数据
            EliminateSGModel.SetDataLotteryEnd()
            local level = EliminateSGModel.GetAllResultLevel()
            local result_data = EliminateSGModel.GetAllResultData()
            local seq = DoTweenSequence.Create()
            seq:AppendInterval(EliminateSGModel.GetTime(EliminateSGModel.time["show_clear" .. level]))
            seq:OnKill(function ()
                --开奖结束
                self:RefreshLotteryBtns()
                if EliminateSGModel.data.state == EliminateSGModel.xc_state.nor then
                    Event.Brocast("view_lottery_end",result_data)
                    self:SetFxActive(false)
                    ExtendSoundManager.CloseSound(self.sound_key)
                end
            end)
            return
        end        
    end
    EliminateSGModel.SetDataLotteryEnd()
    self:RefreshLotteryBtns()
    Event.Brocast("eliminate_refresh_end")
end

function M:MyExit()
    EliminateSGGamePanel.ExitTimer()
    Event.Brocast("view_quit_game")
    EliminateSGLogic.clearViewMsgRegister(listerRegisterName)
    if M.auto_lotter_timer then 
        M.auto_lotter_timer:Stop()
        M.auto_lotter_timer = nil
    end
    if self.game_btn_pre then
		self.game_btn_pre:MyExit()
    end
    EliminateSGObjManager.Exit()
    

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
    EliminateSGAnimManager.ExitTimer()
    EliminateSGObjManager.ExitTimer()
    EliminateSGPartManager.ExitTimer()
end

function M:MakeLister()
    lister = {}
    lister["model_lottery_success"] = basefunc.handler(self, self.model_lottery_success)
    lister["model_lottery_error"] = basefunc.handler(self, self.model_lottery_error)
    lister["auto_lottery"] = basefunc.handler(self, self.auto_lottery)
    lister["refresh_gamepanel_btn_msg"] = basefunc.handler(self, self.on_refresh_gamepanel_btn_msg)
    lister["all_info_is_reconnection_msg"] = basefunc.handler(self, self.on_all_info_is_reconnection_msg)
    lister["hf_had_fly_finish_msg"] = basefunc.handler(self, self.on_hf_had_fly_finish_msg)
    lister["model_get_task_award_response"] = basefunc.handler(self, self.on_model_get_task_award_response)
    lister["model_task_change_msg"] = basefunc.handler(self, self.on_model_task_change_msg)
    lister["gamepanel_fx_set_false_msg"] = basefunc.handler(self, self.on_gamepanel_fx_set_false_msg)
    lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function M:auto_lottery()
    print("<color=yellow>托管开奖</color>")
    --ExtendSoundManager.PlaySceneBGM(audio_config.sdbgj.bgm_sdbgj_beijing.audio_name)
    if EliminateSGModel.DataDamage() then return end
    if EliminateSGModel.GetAuto() then
        --托管自动开奖
        self:AutoLottery()
    else
        --model处理开奖结束的数据
        EliminateSGModel.SetDataLotteryEnd()
        --开奖结束
        self:RefreshLotteryBtns()
    end
end

function M:model_lottery_error()
    print("<color=yellow>开奖错误</color>")
    if EliminateSGModel.DataDamage() then return end
    local m_data = EliminateSGModel.data
    if m_data.eliminate_data and m_data.eliminate_data.result then
        if m_data.is_new then
            EliminateSGObjManager.ClearEliminateItem()
            EliminateSGObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base,m_data.eliminate_data.result[1].bgj_rate_map)
        else
            if not table_is_null(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new) then
                EliminateSGObjManager.ClearEliminateItem()
                EliminateSGObjManager.CreateEliminateItem(m_data.eliminate_data.result[#m_data.eliminate_data.result].map_new)
            end
        end
    end
    self:RefreshLotteryBtns()
    Event.Brocast("view_lottery_error")
end

function M:model_lottery_success()
    print("<color=yellow>开奖成功</color>")
    if EliminateSGModel.DataDamage() then return end
    if (EliminateSGModel.data.state ~= EliminateSGModel.xc_state.nor) and (EliminateSGModel.data.state ~= EliminateSGModel.xc_state.null) and (EliminateSGModel.data.state ~= EliminateSGModel.xc_state.select) then return end
    local m_data = EliminateSGModel.data
    self:RefreshLotteryBtns()
    if EliminateSGModel.GetSkip() then
        dump(m_data.eliminate_data, "<color=red>跳过动画，直接到最后的结果</color>")
        self:lottery_end()
    else
        local new_map = m_data.eliminate_data.result[1].map_base
        local bgj_rate_map = m_data.eliminate_data.result[1].bgj_rate_map
        local times = {
            ys_j_sgdjg = EliminateSGModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateSGModel.time.ys_ysgdsj,
            ys_ysgdsj_add = EliminateSGModel.time.ys_ysgdsj_add,
        }
        EliminateSGAnimManager.StopScrollLottery(new_map,function()
            self:HideSkipBtn()
            self:lottery_start(m_data)
        end,times,nil,bgj_rate_map)
        dump(m_data.eliminate_data, "<color=red>正常开奖</color>")
    end
    Event.Brocast("view_lottery_sucess")
end

function M:lottery_start(m_data)
    local data = m_data.eliminate_data
    EliminateSGObjManager.ExitTimer()
    local index = 0
    local lottery
    lottery = function (is_first)
        if EliminateSGModel.DataDamage() then return end
        if index == #data.result then
            --本局没有可以开奖的元素了，本局开奖结束
            EliminateSGModel.data.state = "nor"
            if data.hf_skill_trigger then
                --LittleTips.Create("此刻进入2选1界面~")
                EliminateSGFreeChoosePanel.Create()
            else
                self:lottery_end()
            end
            return
        end
        index = index + 1
        local cur_data = data.result[index]
        dump(cur_data, "<color=red>WWWWWWWWWW cur_data</color>")
        
        EliminateSGObjManager.Lottery(index,lottery,is_first)
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
    if IsEquals(self.lottery_img) and IsEquals(self.lottery_img.color) then
        self.lottery_img.raycastTarget = true
        self.lottery_img.color = Color.white
    else
        if AppDefine.IsEDITOR() then
            HintPanel.Create(1, "问题：XXL color设置失败!")
            dump(self.lottery_img)
            dump(self.lottery_img.color)
        end
    end
    if EliminateSGModel.DataDamage() then return end
    local m_data = EliminateSGModel.data
    local auto = EliminateSGModel.GetAuto()
    print(debug.traceback())
    dump(auto,"<color=yellow><size=15>++++++++++auto++++++++++</size></color>")
    if not auto then
        if m_data.status_lottery == EliminateSGModel.status_lottery.wait then
            self.lottery_btn.transform.gameObject:SetActive(true)
            self.skip_btn.transform.gameObject:SetActive(false)
        elseif m_data.status_lottery == EliminateSGModel.status_lottery.run then
            self.lottery_btn.transform.gameObject:SetActive(false)
            self.skip_btn.transform.gameObject:SetActive(true)
        elseif m_data.status_lottery == EliminateSGModel.status_lottery.run_prog then
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
    local open, yxcard, game_level, qp_image = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateSGModel.yxcard_type}, "GetCurGameCard")
    dump({
        yxcard = yxcard,
        status_lottery = EliminateSGModel.data.status_lottery,
        raycastTarget = self.lottery_img.raycastTarget ,
        auto = EliminateSGModel.GetAuto()
    }, "<color=red>【游戏卡状态刷新】</color>")
    if open then
        if not EliminateSGModel.GetAuto() 
        and EliminateSGModel.data.status_lottery == EliminateSGModel.status_lottery.wait 
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
    EliminateSGLogic.quit_game()
end

function M:AutoLottery()
    if M.auto_lotter_timer then M.auto_lotter_timer:Stop() end
    M.auto_lotter_timer = Timer.New(function ()
        print("<color=red>托管开奖开始</color>")
        self:Lottery()
    end,EliminateSGModel.GetTime(EliminateSGModel.time.xc_zdkj),1)
    M.auto_lotter_timer:Start()
end

function M:Lottery(_card_type)
    dump(EliminateSGModel.data.bet, "<color=red>消消乐开奖</color>")
    ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_kaishi.audio_name)
    local item_map = EliminateSGObjManager.GetAllEliminateItem()
    local times = {
        ys_jsgdsj = EliminateSGModel.time.ys_jsgdsj,
        ys_ysgdjg = EliminateSGModel.time.ys_ysgdjg,
        ys_j_sgdsj = EliminateSGModel.time.ys_j_sgdsj,
        ys_jsgdjg = EliminateSGModel.time.ys_jsgdjg
    }
    EliminateSGAnimManager.ScrollLottery(item_map,times)

    --测试数据
    if EliminateSGLogic.is_test then
        M.Test()
        return
    end
    Event.Brocast("view_lottery_start")
    if _card_type then
        Network.SendRequest("xxl_sanguo_base_kaijiang",{bets = EliminateSGModel.data.bet, card_type = _card_type},"连接中") 
    else
        Network.SendRequest("xxl_sanguo_base_kaijiang",{bets = EliminateSGModel.data.bet},"连接中") 
    end
end

local is_up = false
function M:OnClickLotteryDown()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if EliminateSGModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateSGModel.data.bet) do
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
    seq:AppendInterval(EliminateSGModel.time.xc_zdkj_jg)
    seq:AppendCallback(function ()
        self.auto_img.raycastTarget = false
        if not is_up then
            self.auto_btn.gameObject:SetActive(true)
        end
    end)
end

function M:OnClickLotteryUp(  )
    if EliminateSGModel.DataDamage() then return end
    local all_bet = 0
    for k,v in pairs(EliminateSGModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        self.lottery_img.raycastTarget = true
        return
    end
    is_up = true

    if self.lottery_down_time and os.time() - self.lottery_down_time >= EliminateSGModel.time.xc_zdkj_jg then
        --自动消除
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        print("<color=white>自动消除</color>")
        EliminateSGModel.SetAuto(true)
        -- self:RefreshLotteryBtns()
    end
    self:Lottery()
    self.lottery_img.raycastTarget = false
end

function M:OnClickSkip()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:HideSkipBtn()
    EliminateSGGamePanel.ExitTimer()
    if GameGlobalOnOff.XXLSkipAllAni then
        --直接出结果
        self:MyRefresh()
    else
        --开始开奖
        self:lottery_start(EliminateSGModel.data)
        EliminateSGObjManager.EliminateItemMoneyAni(EliminateSGModel.data.eliminate_data.result[1].map_base)
        EliminateSGPartManager.ClearAll()
    end
end

function M:OnClickAuto()
    --取消托管
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.auto_img.raycastTarget = false
    EliminateSGModel.SetAuto( not EliminateSGModel.GetAuto())
    self:RefreshLotteryBtns()
    if not EliminateSGModel.data.ScrollLottery or EliminateSGModel.data.state then
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
    local open, yxcard, game_level  = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateSGModel.yxcard_type}, "GetCurGameCard")
    if open and self.lottery_img.raycastTarget then
        dump({yxcard = yxcard, game_level = game_level}, "<color=white>【使用游戏卡】</color>")
        --EliminateSGModel.SetBet({game_level/5, game_level/5, game_level/5, game_level/5, game_level/5})
        self:Lottery(yxcard)
        Event.Brocast("view_lottery_start_yxcard", game_level)
    end
end

--测试代码
function M.Test()
    Event.Brocast("view_lottery_start")
    local data = EliminateSGLogic.GetTestData("nor")
    Event.Brocast("xxl_sanguo_base_kaijiang_response","xxl_sanguo_base_kaijiang_response",data)
end

--刷新下方任务
function M:RefreshButtomTask()
    local ids_tab = EliminateSGModel.GamePanelButtomTaskIds
    local is_can = false
    for i=1,#ids_tab do
        local data = GameTaskModel.GetTaskDataByID(ids_tab[i])
        if data then
            self["slider"..i].value = data.now_process / data.need_process
            self["process"..i.."_txt"].text = data.now_process .. "/" .. data.need_process
            if data.award_status == 1 then
                is_can = true
            end
        end
    end
    if is_can then
        self.baoxiang_ani:Play("EliminateSG_baoxiang",-1,0)
        self.glow_01.gameObject:SetActive(true)
    else
        self.baoxiang_ani:Play("null",-1,0)
        self.glow_01.gameObject:SetActive(false)
    end
end

--领取下方任务奖励
function M:OnGetClick()
    local ids_tab = EliminateSGModel.GamePanelButtomTaskIds
    for i=1,#ids_tab do
        local data = GameTaskModel.GetTaskDataByID(ids_tab[i])
        if data and data.award_status == 1 then
            Network.SendRequest("get_task_award", {id = ids_tab[i]})
            return
        end
    end
    LittleTips.Create("任务还未完成~")
end

function M:on_model_get_task_award_response(data)
    local ids_tab = EliminateSGModel.GamePanelButtomTaskIds
    for k,v in pairs(ids_tab) do
        if v == data.id then
            self:RefreshButtomTask()
        end
    end
end

function M:on_model_task_change_msg(data)
    local ids_tab = EliminateSGModel.GamePanelButtomTaskIds
    for k,v in pairs(ids_tab) do
        if v == data.id then
            self:RefreshButtomTask()
        end
    end
end

function M:on_refresh_gamepanel_btn_msg()
    self:RefreshLotteryBtns()
end

function M:on_all_info_is_reconnection_msg(data)
    if data then
        dump(data,"<color=yellow><size=15>++++++111++++on_all_info_is_reconnection_msg++++++++++</size></color>")
        data.status_data.status = EliminateSGModel.xc_state.nor
        local m_data = eliminate_sg_algorithm.compute_eliminate_result(EliminateSGModel.ToDealWithData("nor",data))
        dump(m_data,"<color=yellow><size=15>+++++222+++++on_all_info_is_reconnection_msg++++++++++</size></color>")
        if not table_is_null(m_data.result[#m_data.result].map_new) then
            EliminateSGObjManager.ClearEliminateItem()
            EliminateSGObjManager.CreateEliminateItem(m_data.result[#m_data.result].map_new)
        end
    end
end

function M:on_hf_had_fly_finish_msg()
    self:SetFxActive(true)
end

function M:SetFxActive(b)
    if b then
        self.sound_key = ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_ranshao.audio_name,100,function ()
            self.sound_key = nil
        end)
    else
        ExtendSoundManager.CloseSound(self.sound_key)
        self.sound_key = nil
    end
    self.hou_04.gameObject:SetActive(b)
    self.hou_05.gameObject:SetActive(b)
    self.hou_06.gameObject:SetActive(b)
    self.kuang.gameObject:SetActive(b)
end

function M:on_gamepanel_fx_set_false_msg()
    self:SetFxActive(false)
end
