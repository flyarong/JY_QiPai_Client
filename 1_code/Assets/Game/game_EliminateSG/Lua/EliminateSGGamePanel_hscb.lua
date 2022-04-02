local basefunc = require "Game.Common.basefunc"
EliminateSGGamePanel_hscb = basefunc.class()

local M = EliminateSGGamePanel_hscb
M.name = "EliminateSGGamePanel_hscb"
local lister
local listerRegisterName = "EliminateSGGameListerRegister_hscb"
local instance
local is_first
--******************框架
function M.Create(data)
    if not instance then
        DSM.PushAct({panel = M.name})
        is_first = true
        instance = M.New(data)
    else
        if data then
            instance.data = data
            if data.status_data.status == EliminateSGModel.xc_state.hscb_1 then
                is_first = true
                Event.Brocast("xxl_sanguo_hscb_kaijiang_msg","xxl_sanguo_hscb_kaijiang_msg")
                if data.status_data.time_out - os.time() > 0 then
                    instance:Timer_to_selet(true,data.status_data.time_out - os.time())
                end
                if instance.pos then
                    EliminateSGObjManager.LitEliminateItem(instance.pos)
                end
            elseif data.status_data.status == EliminateSGModel.xc_state.hscb_2 then
                Event.Brocast("free_game_times_change_msg",0)
                Event.Brocast("refresh_boat_nums_change_mag",data.hscb_data.fire_ship_num)
                is_first = false
                instance:SetFireFx(true)
                instance:MyRefresh()
                instance.zhezhao.gameObject:SetActive(false)
            end
        else
            Event.Brocast("xxl_sanguo_hscb_kaijiang_msg","xxl_sanguo_hscb_kaijiang_msg")
            instance:Timer_to_selet(true,nil)
        end
    end
    return instance
end

function M:ctor(data)
    self.data = data
    ExtendSoundManager.PlaySceneBGM(audio_config.cbzz.bgm_cbzz_hscb_beijing.audio_name)
    local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(M.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self:SetBaseGamePanelActive(false)
    self:MyInit()
end

function M:MyInit()
	ExtPanel.ExtMsg(self)
    Event.Brocast("gamepanel_fx_set_false_msg")
    for i=1,4 do
        self["selet"..i.."_btn"].gameObject:SetActive(true)
    end
    self.selet1_btn.onClick:AddListener(function ()
        self:OnSeletClick(1)
    end)
    self.selet2_btn.onClick:AddListener(function ()
        self:OnSeletClick(2)
    end)
    self.selet3_btn.onClick:AddListener(function ()
        self:OnSeletClick(3)
    end)
    self.selet4_btn.onClick:AddListener(function ()
        self:OnSeletClick(4)
    end)

    self:MakeLister()
    EliminateSGLogic.setViewMsgRegister(lister, listerRegisterName)

    self.info_pre = EliminateSGInfoPanel_hscb.Create()
    self.money_pre = EliminateSGMoneyPanel_hscb.Create()
    
    EliminateSGObjManager.InitEliminateBG(EliminateSGModel.size.max_x,EliminateSGModel.size.max_y)

    HandleLoadChannelLua("EliminateSGGamePanel_hscb", self)
    if self.data then
        if self.data.status_data.status == EliminateSGModel.xc_state.hscb_1 then
            Event.Brocast("xxl_sanguo_hscb_kaijiang_msg","xxl_sanguo_hscb_kaijiang_msg")
            if self.data.status_data.time_out - os.time() > 0 then
                self:Timer_to_selet(true,self.data.status_data.time_out - os.time())
            end
        elseif self.data.status_data.status == EliminateSGModel.xc_state.hscb_2 then
            is_first = false
            self:SetFireFx(true)
            self:MyRefresh()
            self.zhezhao.gameObject:SetActive(false)
            Event.Brocast("refresh_boat_nums_change_mag",self.data.hscb_data.fire_ship_num)
        end
    else
        Event.Brocast("xxl_sanguo_hscb_kaijiang_msg","xxl_sanguo_hscb_kaijiang_msg")
        self:Timer_to_selet(true,nil)
    end
end

function M:MyRefresh()
    if EliminateSGModel.DataDamage() then return end
    local m_data = EliminateSGModel.data
    dump(m_data, "<color=yellow>刷新数据</color>")
    if is_first then
        --初始化一个默认元素摆放
        EliminateSGObjManager.ClearEliminateItem()
        EliminateSGObjManager.CreateEliminateItem(m_data.eliminate_data.result[1].map_base)
        is_first = false
    else
        if m_data.eliminate_data and m_data.eliminate_data.result then  
            local last_data = m_data.eliminate_data.result[#m_data.eliminate_data.result]
            if not table_is_null(last_data.map_new) then
                EliminateSGObjManager.ClearEliminateItem()
                EliminateSGObjManager.CreateEliminateItem(last_data.map_new)
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
                Event.Brocast("view_lottery_end",result_data)
                Event.Brocast("refresh_gamepanel_btn_msg")
            end)
            return     
        end
    end 
    EliminateSGModel.SetDataLotteryEnd()
    Event.Brocast("eliminate_refresh_end")
end

function M:MyExit()
    self:StopTimer()
    self:SetBaseGamePanelActive(true)

    if self.info_pre then
        self.info_pre:MyExit()
    end
    if self.money_pre then
        self.money_pre:MyExit()
    end
    EliminateSGObjManager.Exit_hscb()
    EliminateSGGamePanel_hscb.ExitTimer()
    EliminateSGModel.data.state = "nor"
    EliminateSGModel.ChangeXY("nor")
    Event.Brocast("all_info_is_reconnection_msg",self.data)
    EliminateSGLogic.clearViewMsgRegister(listerRegisterName)
	destroy(self.gameObject)
    instance = nil
end

function M:MyClose()
    DSM.PopAct()
    self:MyExit()
end

function M.ExitTimer()
    EliminateSGAnimManager.ExitTimer()
    EliminateSGObjManager.ExitTimer()
    EliminateSGPartManager.ExitTimer()
end

function M:MakeLister()
    lister = {}
    lister["model_lottery_success"] = basefunc.handler(self, self.model_lottery_success)
    lister["eliminateSG_had_settel_msg"] = basefunc.handler(self, self.on_eliminateSG_had_settel_msg)
    lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function M:model_lottery_success()
    print("<color=yellow>开奖成功</color>")
    if EliminateSGModel.DataDamage() then return end
    if EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_1 then
        self.zhezhao.gameObject:SetActive(true)
        self:MyRefresh()
    elseif EliminateSGModel.data.state == EliminateSGModel.xc_state.hscb_2 then
        self.zhezhao.gameObject:SetActive(false)
        self:SetActiveTimeTxt(false)
        local m_data = EliminateSGModel.data
        local new_map = m_data.eliminate_data.result[1].map_base
        if not self.is_scroll then
            self:StartScroll()
        end
        if not self.is_kaijiang then
            local pos_tab = eliminate_sg_algorithm.get_hscb_pos_by_index(m_data.eliminate_data.start_fire_index)
            for k,v in pairs(pos_tab) do
                ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_hscb_ranshao.audio_name)
                EliminateSGObjManager.LitEliminateItem(v)--点燃选中的船
            end
            Event.Brocast("refresh_boat_nums_change_mag",2) 
        end
        local times = {
            ys_j_sgdjg = EliminateSGModel.time.ys_j_sgdjg,
            ys_ysgdsj = EliminateSGModel.time.ys_ysgdsj,
            ys_ysgdsj_add = EliminateSGModel.time.ys_ysgdsj_add,
        }
        EliminateSGAnimManager.StopScrollLottery(new_map,function()
            self:lottery_start(m_data)
        end,times,nil,bgj_rate_map)
        dump(m_data.eliminate_data, "<color=red>正常开奖</color>")
        Event.Brocast("view_lottery_sucess")
    end
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
            self:lottery_end()
            return
        end
        index = index + 1
        EliminateSGModel.debug_index = index
        local cur_data = data.result[index]
        dump(cur_data, "<color=red>WWWWWWWWWW cur_data</color>")
        
        EliminateSGObjManager.Lottery(index,lottery,is_first)
    end
    lottery(true)
end

function M:lottery_end()
    self:MyRefresh()
end

function M:StartScroll()
    Event.Brocast("free_game_times_change_msg",5)
    local item_map = EliminateSGObjManager.GetAllEliminateItem()
    local times = {
        ys_jsgdsj = EliminateSGModel.time.ys_jsgdsj,
        ys_ysgdjg = EliminateSGModel.time.ys_ysgdjg,
        ys_j_sgdsj = EliminateSGModel.time.ys_j_sgdsj,
        ys_jsgdjg = EliminateSGModel.time.ys_jsgdjg
    }
    EliminateSGAnimManager.ScrollLottery(item_map,times)
    self.is_scroll = true
    Event.Brocast("view_lottery_start")
end

function M:Lottery()
    dump(EliminateSGModel.data.bet, "<color=red>消消乐开奖</color>")
    ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_kaishi.audio_name)
    Event.Brocast("refresh_boat_nums_change_mag",#self.indexs) 
    self:StartScroll()
    self:hscb_kaijiang()
end


--设置基础消界面的显隐
function M:SetBaseGamePanelActive(b)
    local pre = GameObject.Find("Canvas/GUIRoot/EliminateSGGamePanel")
    if IsEquals(pre) then
        pre.gameObject:SetActive(b)
    end
    local pre = GameObject.Find("Canvas/LayerLv1/EliminateSGInfoPanel")
    if IsEquals(pre) then
        pre.gameObject:SetActive(b)
    end
    local pre = GameObject.Find("Canvas/LayerLv1/EliminateSGMoneyPanel")
    if IsEquals(pre) then
        pre.gameObject:SetActive(b)
    end
    if b then
        ExtendSoundManager.PlaySceneBGM(audio_config.cbzz.bgm_cbzz_beijing.audio_name)
    end
end

--点火之后向服务器发开奖消息
function M:hscb_kaijiang()
    self.is_kaijiang = true
    Network.SendRequest("xxl_sanguo_hscb_kaijiang",{start_fire_index = self:GetC2SIndexByIndexs()})
end


function M:OnSeletClick(index)
    if (EliminateSGModel.data.state ~= EliminateSGModel.xc_state.hscb_1) then return end
    --LittleTips.Create("当前选中的index是"..index)
    self["selet"..index.."_btn"].gameObject:SetActive(false)
    self.indexs = self.indexs or {}
    self.indexs[#self.indexs + 1] = index
    local tab = {{1,1},{5,1},{1,4},{5,4}}
    local pos = tab[index]
    self:SetFireFx(true)
    ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_hscb_ranshao.audio_name)
    if self.pos then
        self.pos = nil
    else
        self.pos = pos
    end
    EliminateSGObjManager.LitEliminateItem(pos)--点燃选中的船
    Event.Brocast("refresh_boat_nums_change_mag",#self.indexs) 
    if #self.indexs == 2 then
        self:Lottery()
    end
end

function M:GetC2SIndexByIndexs()
    local tab = {}
    tab[1] = math.min(self.indexs[1],self.indexs[2])
    tab[2] = math.max(self.indexs[1],self.indexs[2])
    if tab[1] == 1 and tab[2] == 2 then
        return 0
    elseif tab[1] == 1 and tab[2] == 3 then
        return 1
    elseif tab[1] == 1 and tab[2] == 4 then
        return 2
    elseif tab[1] == 2 and tab[2] == 3 then
        return 3
    elseif tab[1] == 2 and tab[2] == 4 then
        return 4
    elseif tab[1] == 3 and tab[2] == 4 then
        return 5
    end
end

function M:Timer_to_selet(b,time_out)
    dump(time_out,"<color=yellow><size=15>++++++++++Timer_to_selet++++++++++</size></color>")
    self:StopTimer()
    if b then
        if time_out then
            self.time_num = time_out - 2
        else
            self.time_num = 15
        end
        self:RefreshTimeTxt()
        self:SetActiveTimeTxt(true)
        self.cut_down_timer = Timer.New(function ()
            self.time_num = self.time_num - 1
            if self.time_num < 12 then
                --self:SetFireFx(true)
            end
            self:RefreshTimeTxt()
            if self.time_num <= 0 then
                self:SetFireFx(true)
                self:SetActiveTimeTxt(false)
                self:StopTimer()
                self:AutoSeletIndex()
            end
        end,1,-1,false)
        self.cut_down_timer:Start()
    end
end

function M:StopTimer()
    if self.cut_down_timer then
        self.cut_down_timer:Stop()
        self.cut_down_timer = nil
    end
end

function M:SetFireFx(b)
    if not self.ParticleSystem.gameObject.activeSelf then
        self.ParticleSystem.gameObject:SetActive(b)
    end
end

function M:SetActiveTimeTxt(b)
    self.time_txt.gameObject:SetActive(b)
end

function M:RefreshTimeTxt()
    self.time_txt.text = self.time_num
end

function M:AutoSeletIndex()
    if (EliminateSGModel.data.state ~= EliminateSGModel.xc_state.hscb_1) then return end
    self.indexs = self.indexs or {}
    local index = math.random(1,4)
    if not self:CheckHaveThisIndex(index) then
        local tab = {{1,1},{5,1},{1,4},{5,4}}
        local pos = tab[index]
        ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_hscb_ranshao.audio_name)
        EliminateSGObjManager.LitEliminateItem(pos)--点燃选中的船
        self.indexs[#self.indexs + 1] = index
        if #self.indexs == 2 then
            self:Lottery()
        else
            self:AutoSeletIndex()
        end
    else
        self:AutoSeletIndex()
    end
end

function M:CheckHaveThisIndex(index)
    if not table_is_null(self.indexs) and index then
        for i=1,#self.indexs do
            if self.indexs[i] == index then
                return true
            end
        end
    end
    return false
end

function M:on_eliminateSG_had_settel_msg()
    self:MyExit()
end