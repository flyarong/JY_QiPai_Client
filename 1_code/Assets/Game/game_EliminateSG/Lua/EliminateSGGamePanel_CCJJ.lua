local basefunc = require "Game/Common/basefunc"

EliminateSGGamePanel_ccjj = basefunc.class()
local C = EliminateSGGamePanel_ccjj
C.name = "EliminateSGGamePanel_ccjj"
local lister
local listerRegisterName = "EliminateSGGameListerRegister_ccjj"
local instance
local is_first

function C.Create(data)
    if not instance then
        DSM.PushAct({panel = C.name})
        is_first = true
        instance = C.New(data)
    else
        if data then
            instance.data = data
            if data.status_data.status == EliminateSGModel.xc_state.ccjj_2 then
                Event.Brocast("refresh_collect_arrows_nums_change_mag",data.ccjj_data.tot_arrow_num,true)
                is_first = false
                instance:MyRefresh()
            end
        else
            Event.Brocast("xxl_sanguo_ccjj_kaijiang_msg","xxl_sanguo_ccjj_kaijiang_msg")
        end
    end
    return instance
end

function C:ctor(data)
    self.free_number=0
    self.data = data
    ExtendSoundManager.PlaySceneBGM(audio_config.cbzz.bgm_cbzz_ccjj_beijing.audio_name)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:SetBaseGamePanelActive(false)
	self:InitUI()
end


function C:MakeLister()
	lister={}
	lister["model_lottery_success"] = basefunc.handler(self, self.model_lottery_success)
    lister["eliminateSG_had_settel_msg"] = basefunc.handler(self, self.on_eliminateSG_had_settel_msg)
    lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:MyExit()
    self:SetBaseGamePanelActive(true)
    if self.hero_pre then
        self.hero_pre:MyExit()
    end
    if self.money_pre then
        self.money_pre:MyExit()
    end
    if self.info_pre then
        self.info_pre:MyExit()
    end
    EliminateSGObjManager.Exit_ccjj()
	EliminateSGGamePanel_ccjj.ExitTimer()
    EliminateSGModel.data.state = "nor"
    EliminateSGModel.ChangeXY("nor")
    Event.Brocast("all_info_is_reconnection_msg",self.data)
    EliminateSGLogic.clearViewMsgRegister(listerRegisterName)
	destroy(self.gameObject)
    instance = nil
end

function C.ExitTimer()
    EliminateSGAnimManager.ExitTimer()
    EliminateSGObjManager.ExitTimer()
    EliminateSGPartManager.ExitTimer()
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	DSM.PopAct()
    self:MyExit()
end

function C:InitUI()
	ExtPanel.ExtMsg(self)
    Event.Brocast("gamepanel_fx_set_false_msg")
	self:MakeLister()
    HandleLoadChannelLua("EliminateSGGamePanel_ccjj", self)
	EliminateSGLogic.setViewMsgRegister(lister, listerRegisterName)
    EliminateSGObjManager.InitEliminateBG(EliminateSGModel.size.max_x,EliminateSGModel.size.max_y)

    self.money_pre = EliminateSGMoneyPanel_ccjj.Create()
    self.hero_pre = EliminateSGHeroPanel_ccjj.Create()
    self.info_pre = EliminateSGInfoPanel_ccjj.Create()
    if self.data then
        if self.data.status_data.status == EliminateSGModel.xc_state.ccjj_2 then
            Event.Brocast("refresh_collect_arrows_nums_change_mag",self.data.ccjj_data.tot_arrow_num,true)
            is_first = false
            self:MyRefresh()
        end
    else
        Event.Brocast("xxl_sanguo_ccjj_kaijiang_msg","xxl_sanguo_ccjj_kaijiang_msg")
    end
end

function C:MyRefresh()
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
            local index = 0
            self.free_number=0
            for i=1,#m_data.eliminate_data.result do
                if self:CheckIsEnd(m_data.eliminate_data.result[i]) then
                    index = i - 1
                    break
                end
                if m_data.eliminate_data.result[i].arrow_fly_list then
                    self.free_number= self.free_number+1
                end
            end
            -- dump(m_data.eliminate_data.result,"<color=yellow><size=15>++++++++++m_data.eliminate_data.result++++++++++</size></color>")
            -- for i=1,#m_data.eliminate_data.result do
            --     dump(m_data.eliminate_data.result[i],"<color=red><size=15>++++++++++"..i.."++++++++++</size></color>")
            -- end
            -- dump(index,"<color=yellow><size=15>++++++++++index++++++++++</size></color>")
            local last_data = m_data.eliminate_data.result[index ~= 0 and index or 1]
            --local last_data = m_data.eliminate_data.result[#m_data.eliminate_data.result]

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
		        Event.Brocast("add_free_game_times_msg", self.free_number)
                if EliminateSGModel.is_all_info then
                    Event.Brocast("view_lottery_end",result_data,self.data.ccjj_data.tot_arrow_num)
                else
                    Event.Brocast("view_lottery_end",result_data)
                end
                Event.Brocast("refresh_gamepanel_btn_msg")
            end)
            return     
        end
    end 
    EliminateSGModel.SetDataLotteryEnd()
    Event.Brocast("eliminate_refresh_end")
end

--设置基础消界面的显隐
function C:SetBaseGamePanelActive(b)
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

 function C:model_lottery_success()
    print("<color=yellow>开奖成功</color>")
    if EliminateSGModel.DataDamage() then return end
    if EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_cs then
        self:MyRefresh()
    elseif EliminateSGModel.data.state == EliminateSGModel.xc_state.ccjj_2 then
        self:Lottery()
        local m_data = EliminateSGModel.data
        local new_map = m_data.eliminate_data.result[1].map_base
        local bgj_rate_map = m_data.eliminate_data.result[1].bgj_rate_map
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




function C:lottery_start(m_data)
    local data = m_data.eliminate_data
    EliminateSGObjManager.ExitTimer()
    local index = 0
    local lottery
    lottery = function (is_first)
        if EliminateSGModel.DataDamage() then return end
        if self:CheckIsEnd(data.result[index + 1]) or (index == #data.result) then
            --本局没有可以开奖的元素了，本局开奖结束
            self:lottery_end()
            return
        end
        index = index + 1
        local cur_data = data.result[index]
        dump(cur_data, "<color=red>WWWWWWWWWW cur_data</color>")
        
        EliminateSGObjManager.Lottery(index,lottery,is_first)
    end
    lottery(true)
end

function C:lottery_end()
    self:MyRefresh()
end

function C:Lottery()
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
    Event.Brocast("view_lottery_start")
end

function C:CheckIsEnd(data)
    for k,v in pairs(data.map_new) do
        for kk,vv in pairs(v) do
            if vv == 0 then
                return true
            end
        end
    end
end

function C:on_eliminateSG_had_settel_msg()
    self:MyExit()
end