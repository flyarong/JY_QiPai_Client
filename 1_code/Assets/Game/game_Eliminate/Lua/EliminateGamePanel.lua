local basefunc = require "Game.Common.basefunc"
EliminateGamePanel = basefunc.class()

local M = EliminateGamePanel
M.name = "EliminateGamePanel"
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
    ExtendSoundManager.PlaySceneBGM(audio_config.xxl.bgm_xxl_beijing.audio_name)
    local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:MyInit()
    -- self:MyRefresh()
    local bg = self.transform:Find("BG")
	MainModel.SetGameBGScale(bg)
end

function M:MyInit()
    self:MakeLister()
    EliminateLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onDown = basefunc.handler(self, self.OnClickLotteryDown)
    EventTriggerListener.Get(self.lottery_btn.gameObject).onUp = basefunc.handler(self, self.OnClickLotteryUp)
    EventTriggerListener.Get(self.skip_btn.gameObject).onUp = basefunc.handler(self, self.OnClickSkip)
    EventTriggerListener.Get(self.auto_btn.gameObject).onUp = basefunc.handler(self, self.OnClickAuto)
    EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBack)
    EventTriggerListener.Get(self.yxcard_btn.gameObject).onClick = basefunc.handler(self, self.OnClickYXCard)
    EliminateInfoPanel.Create()
    EliminateObjManager.InitEliminateBG(EliminateModel.cfg.size.max_x,EliminateModel.cfg.size.max_y)
    -- EliminateObjManager.CreateEliminateItem(EliminateModel.data.map)
    -- self:InitSpeedDropDown()
    self.skip_img = self.skip_btn.transform:GetComponent("Image")
    self.lottery_img = self.lottery_btn.transform:GetComponent("Image")
    self.auto_img = self.auto_btn.transform:GetComponent("Image")
    self.yxcard_img = self.yxcard_btn.transform:GetComponent("Image")

    local btn_map = {}
	btn_map["left_down"] = {self.left_down}
	btn_map["left_enter"] = {self.left_enter}
	btn_map["left_top"] = {self.left_top}
	btn_map["center"] = {self.center}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "xxl_game")
end

function M:MyRefresh()
    if not EliminateModel.data then return end
    local m_data = EliminateModel.data
    dump(m_data, "<color=yellow>m_data断线重连数据</color>")
    local all_del_list = {}
    if table_is_null(m_data.fix_xiaochu_map) then
        --加入删除的元素
        EliminateModel.ConvertAndAddFixDelList(all_del_list)
    end
    if m_data.eliminate_data then
        if m_data.eliminate_data.result then
            local last_result = m_data.eliminate_data.result[#m_data.eliminate_data.result]
            EliminateObjManager.ClearEliminateItem()
            EliminateObjManager.CreateEliminateItem(last_result.map)
            for x,_v in pairs(last_result.map) do
                for y,v in pairs(_v) do
                    if v == 0 then   
                        local eliminate_data = eliminate_algorithm.compute_eliminate_result(EliminateModel.cfg.kaijiang_maps,nil,EliminateModel.cfg)
                        if eliminate_data.map then
                            EliminateObjManager.ClearEliminateItem()
                            EliminateObjManager.CreateEliminateItem(eliminate_data.map)
                        end
                    end
                end
            end
            all_del_list = EliminateModel.ConvertAllDelList(m_data.eliminate_data)
        elseif m_data.eliminate_data.map then
            EliminateObjManager.ClearEliminateItem()
            EliminateObjManager.CreateEliminateItem(m_data.eliminate_data.map)
        end
        dump(all_del_list, "<color=white>删除元素list</color>")
        if next(all_del_list) then
            Event.Brocast("eliminate_lottery_award_all","eliminate_lottery_award_all",all_del_list)
        end
        eliminate_algorithm.get_lottery_award_data(m_data.award_rate,m_data.award_money,EliminateModel.GetBet(),all_del_list,EliminateModel.cfg.rate,EliminateModel.cfg.double_hit)
        if m_data.eliminate_data.result then
             ExtendSoundManager.PauseSceneBGM()
            if m_data.eliminate_data.bureau_type and m_data.eliminate_data.bureau_type == EliminateModel.lottery_type.lucky then
                Event.Brocast("view_lottery_end_lucky")
            else
                Event.Brocast("view_lottery_end")
            end
        end
    end

    --model处理开奖结束的数据
    EliminateModel.SetDataLotteryEnd()
    --开奖结束
    self:RefreshLotteryBtns()
    Event.Brocast("eliminate_refresh_end")
end

function M:MyExit()
    Event.Brocast("eliminate_quit_game")
    EliminateLogic.clearViewMsgRegister(listerRegisterName)
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
    lister["eliminate_can_aoto"] = basefunc.handler(self, self.eliminate_can_aoto)
    lister["stop_auto_lotttery"] = basefunc.handler(self,self.stop_auto_lotttery)

end

function M:eliminate_can_aoto()
    print("<color=yellow>托管开奖</color>")
    ExtendSoundManager.PlaySceneBGM(audio_config.xxl.bgm_xxl_beijing.audio_name)
    if not EliminateModel.data then return end
    if EliminateModel.GetAuto() then
        --托管自动开奖
        self:AutoLottery()
    else
        --model处理开奖结束的数据
        EliminateModel.SetDataLotteryEnd()
        --开奖结束
        self:RefreshLotteryBtns()
    end
end

function M:model_lottery_error()
    print("<color=yellow>开奖错误</color>")
    if not EliminateModel.data then return end
    EliminateObjManager.ClearEliminateItem()
    EliminateObjManager.CreateEliminateItem(EliminateModel.data.eliminate_data.map)
    self:RefreshLotteryBtns()
    Event.Brocast("view_lottery_error")
end

function M:model_lottery_success()
    print("<color=yellow>开奖成功</color>")
    if not EliminateModel.data then return end
    local m_data = EliminateModel.data
    if EliminateObjManager.bgm_xxl_kaishi then
        local key = EliminateObjManager.bgm_xxl_kaishi
        soundMgr:CloseLoopSound(key)
        EliminateObjManager.bgm_xxl_kaishi = nil
    end
    EliminateObjManager.bgm_xxl_kaishi = ExtendSoundManager.PlaySound(audio_config.xxl.bgm_xxl_kaishi.audio_name)
    self:RefreshLotteryBtns()
    if EliminateModel.GetSkip() then
        dump(m_data.eliminate_data, "<color=red>跳过动画，直接到最后的结果</color>")
        -- if not table_is_null(m_data.fix_xiaochu_map) then
        --     --固定消除
        --     local all_del_list = {}
        --     EliminateModel.ConvertAndAddFixDelList(all_del_list)
        --     --通知其他地方做出相应变化
        --     Event.Brocast("eliminate_lottery_award_one","eliminate_lottery_award_one",all_del_list[1])
        -- end
        self:lottery_end()
    else
        local lottery = function(  )
            local new_map = m_data.eliminate_data.map
            EliminateAnimManager.StopScrollLottery(new_map,function()
                self:HideSkipBtn()
                self:lottery_start(m_data)
            end)
        end
        dump(m_data.eliminate_data, "<color=red>正常开奖</color>")
        if not table_is_null(m_data.fix_xiaochu_map) and not table_is_null(m_data.fix_xiaochu_map.del_list) then
            --固定消除
            -- local all_del_list = {}
            -- EliminateModel.ConvertAndAddFixDelList(all_del_list)
            -- dump(all_del_list, "<color=yellow>固定消除all_del_list</color>")
            --  --通知其他地方做出相应变化
            -- Event.Brocast("eliminate_lottery_award_one","eliminate_lottery_award_one",all_del_list[1])
            EliminateObjManager.LotteryFix(lottery)
        else
            lottery()
        end
    end
end

function M:lottery_start(m_data)
    local eliminate_data_temp = basefunc.deepcopy( m_data.eliminate_data)
    EliminateObjManager.ClearEliminateItem()
    EliminateObjManager.CreateEliminateItem(m_data.eliminate_data.map)
    local lottery
    lottery = function ()
        if not eliminate_data_temp.result or not eliminate_data_temp.result[1] then
            --本局没有可以开奖的元素了，本局开奖结束
            self:lottery_end()
            return
        end
        dump(eliminate_data_temp, "<color=yellow>eliminate_data_temp</color>")
        --开奖 或 刷新lucky
        local cur_result = basefunc.deepcopy(eliminate_data_temp.result[1])
        table.remove(eliminate_data_temp.result,1)
        dump(cur_result, "<color=yellow>开始开奖</color>")
        if cur_result.have_lucky and cur_result.del_map_lucky then
            --先变lucky再开奖
            EliminateObjManager.change_lucky(cur_result, function(  )
                --lucky变换完成开奖
                EliminateObjManager.Lottery(cur_result,function()
                    --当前屏幕元素消除完,继续开奖
                    lottery()
                end)
            end)
        else
            --直接开奖
            EliminateObjManager.Lottery(cur_result,function()
                --当前屏幕元素消除完,继续开奖
                lottery()
            end)
        end
    end
    lottery()
end

function M:lottery_end()
    local m_data = EliminateModel.data
    if m_data.eliminate_data.result then
        local last_result = m_data.eliminate_data.result[#m_data.eliminate_data.result]
        EliminateObjManager.ClearEliminateItem()
        if last_result.win_lucky and last_result.win_lucky.over then
            EliminateObjManager.CreateEliminateItem(eliminate_algorithm.str_maps_conver_to_pos_maps(EliminateModel.cfg.kaijiang_maps,EliminateModel.cfg.size.max_x))
        else
            EliminateObjManager.CreateEliminateItem(last_result.map)
        end
    elseif m_data.eliminate_data.map then
        EliminateObjManager.ClearEliminateItem()
        EliminateObjManager.CreateEliminateItem(m_data.eliminate_data.map)
    end

    ExtendSoundManager.PauseSceneBGM()
    if m_data.eliminate_data.bureau_type and m_data.eliminate_data.bureau_type == EliminateModel.lottery_type.lucky then
        Event.Brocast("view_lottery_end_lucky")
    else
        Event.Brocast("view_lottery_end")
    end
    --model处理开奖结束的数据
    EliminateModel.SetDataLotteryEnd()
    --开奖结束
    self:RefreshLotteryBtns()
end
--********************refresh
function M:RefreshLotteryBtns()
    dump(EliminateModel.data.status_lottery, "<color=red>当前状态</color>")
    self:RefreshYXCard()
    if IsEquals(self.auto_img) then
        self.auto_img.raycastTarget = true
    end
    if IsEquals(self.skip_img) then
        self.skip_img.raycastTarget = true
    end
    if IsEquals(self.lottery_img) then
        self.lottery_img.raycastTarget = true
        self.lottery_img.color = Color.white
    end
    if not EliminateModel.data then return end
    local m_data = EliminateModel.data
    local auto = EliminateModel.GetAuto()
    if not auto then
        if m_data.status_lottery == EliminateModel.status_lottery.wait then
            self.lottery_btn.transform.gameObject:SetActive(true)
            self.skip_btn.transform.gameObject:SetActive(false)
        elseif m_data.status_lottery == EliminateModel.status_lottery.run then
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
    local open, yxcard, game_level, qp_image = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateModel.yxcard_type}, "GetCurGameCard")
    dump({
        yxcard = yxcard,
        status_lottery = EliminateModel.data.status_lottery,
        raycastTarget = self.lottery_img.raycastTarget ,
        auto = EliminateModel.GetAuto()
    }, "<color=red>【游戏卡状态刷新】</color>")
    if open then
        if not EliminateModel.GetAuto() 
        and EliminateModel.data.status_lottery == EliminateModel.status_lottery.wait 
        and yxcard 
        and self.lottery_img.raycastTarget 
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
        Network.SendRequest("xxl_quit_game")
    end
    if GameManager.GotoUI({gotoui = "xxl_xrhb",goto_scene_parm = "check_is_run",callback = callback}) then
        return
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
    end,EliminateModel.GetTime(EliminateModel.cfg.time.auto_lotter_d),1)
    M.auto_lotter_timer:Start()
end

function M:Lottery(_card_type)
    dump(EliminateModel.data.bet, "<color=red>消消乐开奖</color>")
    local item_map = EliminateObjManager.GetAllEliminateItem()
    EliminateAnimManager.ScrollLottery(item_map)
    if _card_type then
        Network.SendRequest("xxl_kaijiang",{bets = EliminateModel.data.bet, card_type = _card_type},"连接中")
    else
        Network.SendRequest("xxl_kaijiang",{bets = EliminateModel.data.bet},"连接中")
    end
    Event.Brocast("view_lottery_start")
    --测试
    -- M.Test()
end

local is_up = false

function M:OnClickLotteryDown()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not EliminateModel.data then return end
    local all_bet = 0
    for k,v in pairs(EliminateModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        Event.Brocast("show_gift_panel")
        self.lottery_img.raycastTarget = true
        return
    end
    is_up = false
    self.lottery_down_time = os.time()
    self.click_lottery_down_time = Timer.New(function(  )
        self.auto_img.raycastTarget = false
        if not is_up then
            self.auto_btn.gameObject:SetActive(true)
        end
    end,1,1)
    self.click_lottery_down_time:Start()
end

function M:OnClickLotteryUp(  )
    -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    if not EliminateModel.data then return end
    local all_bet = 0
    for k,v in pairs(EliminateModel.data.bet) do
        all_bet = all_bet + v
    end
    if all_bet > MainModel.UserInfo.jing_bi then
        self.lottery_img.raycastTarget = true
        return
    end
    is_up = true
    if self.lottery_down_time and os.time() - self.lottery_down_time >= 2 then
        --自动消除
        EliminateModel.SetAuto(true)
        -- self:RefreshLotteryBtns()
    end
    self:Lottery()
    self.lottery_img.raycastTarget = false
end

function M:OnClickSkip()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:HideSkipBtn()
    EliminateGamePanel.ExitTimer()
    EliminateAnimManager.ExitTimer()
    EliminateObjManager.ExitTimer()
    if GameGlobalOnOff.XXLSkipAllAni then
        --直接出结果
        self:MyRefresh()
    else
        -- if not table_is_null(EliminateModel.data.fix_xiaochu_map) then
        --     --固定消除
        --     local all_del_list = {}
        --     EliminateModel.ConvertAndAddFixDelList(all_del_list)
        --     --通知其他地方做出相应变化
        --     Event.Brocast("eliminate_lottery_award_one","eliminate_lottery_award_one",all_del_list[1])
        -- end

        --开始开奖
        self:lottery_start(EliminateModel.data)
    end
end

function M:OnClickAuto()
    --取消托管
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self.auto_img.raycastTarget = false
    EliminateModel.SetAuto( not EliminateModel.GetAuto())
    self:RefreshLotteryBtns()
    if not EliminateModel.data.ScrollLottery then
        self:HideSkipBtn()
    end
end

function M:InitSpeedDropDown()
    self.speed_dd = self.transform:Find("SpeedDropdown"):GetComponent("Dropdown")
    local list = EliminateModel.cfg.speed
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
            EliminateModel.SetSpeed(val + 1)
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
    if EliminateModel.GetAuto() then
        self.auto_img.raycastTarget = false
        EliminateModel.SetAuto(false)
        self:RefreshLotteryBtns()
        if not EliminateModel.data.ScrollLottery then
            self:HideSkipBtn()
        end
    end
end

--点击游戏卡
function M:OnClickYXCard()
    local open, yxcard, game_level  = GameButtonManager.RunFun({gotoui = "act_060_yxcard",card_type = EliminateModel.yxcard_type}, "GetCurGameCard")
    if open and self.lottery_img.raycastTarget then
        dump({yxcard = yxcard, game_level = game_level}, "<color=white>【使用游戏卡】</color>")
        --EliminateModel.SetBet({game_level/5, game_level/5, game_level/5, game_level/5, game_level/5})
        self:Lottery(yxcard)
        Event.Brocast("view_lottery_start_yxcard", game_level)
    end
end

function M.Test()
    --测试代码
    local data = {}
    data.result = 0
    data.award_money = 3800
    data.award_rate = 380
    --测试没有lucky
    -- data.kaijiang_maps = "3225443324355511232141515434323123225551515514434244342213114244004142330001440500003003000020030000100000004000"

    --测试没有lucky 4连击
    -- data.kaijiang_maps = "111143324355511232141515434323123225551515514434244342213114244004142330001440500003003000020030000100000004000"

    --测试没有lucky 5连击
    -- data.kaijiang_maps = "1111143324355511232141515434323123225551515514434244342213114244004142330001440500003003000020030000100000004000"
  
    --测试没有lucky 6连击
    -- data.kaijiang_maps = "1111113324355511232141515434323123225551515514434244342213114244004142330001440500003003000020030000100000004000"
  
    --测试lucky摇奖不中
    -- data.kaijiang_maps = "3225443324355566232646565434323123225556565514434244342213114244004642330001440500003003000020030000600000004000"
    -- data.lucky_maps = "111111111"

    --测试lucky摇奖3连
    -- data.kaijiang_maps = "6665443324355566232646565434323123225556565514434244342213114244004642330001440500003003000020030000600000004000"
    -- data.lucky_maps = "111111111"
    
    --测试lucky摇奖中4连
    data.kaijiang_maps = "66664433114355561132646565434323123225556565514434244342213114244004642330001440500003003000020030000600000004000"
    data.lucky_maps = "1111111111111"
    --测试lucky摇奖中5连
    -- data.kaijiang_maps = "66666443324355566232646565434323123225556565514434244342213114244004642330001440500003003000020030000600000004000"
    -- data.lucky_maps = "55555511111111"

    --测试lucky摇奖中6连
    -- data.kaijiang_maps = "666666443324355566232646565434323123225556565514434244342213114244004642330001440500003003000020030000600000004000"
    -- data.lucky_maps = "111111111111111"

    -- data.kaijiang_maps = "44544453545553534111445315114443131333333266333422244554222225333354453333344552215364423244314234443552054335550543630300136203005362050001400000033000000030000000500000005000"
    -- data.lucky_maps = "333334"

    Event.Brocast("xxl_kaijiang_response","xxl_kaijiang_response",data)
    Event.Brocast("view_lottery_start")
end