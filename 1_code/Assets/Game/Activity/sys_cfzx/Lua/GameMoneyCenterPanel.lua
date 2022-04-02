-- 创建时间:2018-10-15

local basefunc = require "Game.Common.basefunc"

GameMoneyCenterPanel = basefunc.class()
local C = GameMoneyCenterPanel

C.name = "GameMoneyCenterPanel"

local panelNameMap = {
    wyhb = "wyhb",
    tgjj = "tgjj",
    wdhy = "wdhy",
    tgewm = "tgewm",
    tglb = "tglb",
    tgphb="tgphb",
}

local phb_begintime = 1606779000
local phb_endtime = 1607356799

local instance
function C.Create(parm)
    if instance then
        return instance
    end
    instance = C.New(parm)
    return instance
end
function C.Exit()
    if instance then
        instance:MyExit()
    end
end


function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end
function C.ReturnIsPopTips()
    return instance.isPopTips
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["model_get_player_sczd_base_info_response"] = basefunc.handler(self, self.model_get_player_sczd_base_info_response)
    self.lister["model_tglb_profit_activate"] = basefunc.handler(self, self.model_tglb_profit_activate)
    self.lister["model_task_change_msg"] = basefunc.handler(self, self.model_task_change_msg)
    self.lister["close_game_money_center_panel"] = basefunc.handler(self, self.OnBackClick)
    self.lister["open_money_center_tgewm"] = basefunc.handler(self, self.OnTGEWMClick)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor(parm)

	ExtPanel.ExtMsg(self)
    self.parm = parm
    local parent = GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(C.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.isPopTips=true
    self:MakeLister()
    self:AddMsgListener()
    LuaHelper.GeneratingVar(self.transform, self)
    self.mc_back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnBackClick()
    end)
    self.mc_help_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnHelpClick()
    end)

    self.WYHB_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnWYHBClick()
    end)
    self.TGJJ_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnTGJJClick()
    end)
    self.WDHY_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnWDHYClick()
    end)
    self.TGEWM_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnTGEWMClick()
    end)
    self.TGLB_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnTGLBClick()
    end)
    self.HelpClose_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnCloseHelp()
    end)
    self.TGPHB_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnTGPHBClick()
    end)
    self.achievement_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        AchievementTGCenterPanel.Create()
        GameObject.Destroy(self.gameObject)
        self:MyExit()
    end)
    self.mc_help_btn.gameObject:SetActive(false)

    self:InitUI()
    -- if  GameTaskModel.check_reward_state(70,1) then
    --     WelComeToTGCJPanel.Create()
    -- end
    -- self.achievement_red.gameObject:SetActive(GameTaskModel.check_reward_state(70,1) or GameTaskModel.check_reward_state(69,#AchievementTGManager.InitCfg().level)
    -- or GameTaskModel.check_reward_state(71,1) or GameTaskModel.check_reward_state(72,1) or  GameTaskModel.check_reward_state(73,1))
end

--初始化UI
function C:InitUI()
    GameMoneyCenterModel.GetSCZDBaseInfo()
    self:HideWDHB()
    self:HidePHB()
    self:HideTGLB()

    --[[if not GameMoneyCenterModel.CheckIsNewPlayerSys() then
        local is_hit = PlayerPrefs.GetInt("bing_zfg" .. MainModel.UserInfo.user_id, 0)
        if is_hit == 0 then
            HintPanel.Create(1,"因系统升级，现将收益提现到微信修改为提现到支付宝，请在“我的收益”界面绑定支付宝进行提现噢！")
            PlayerPrefs.SetInt("bing_zfg" .. MainModel.UserInfo.user_id, 1)
        end
    end--]]
end

function C:HidePHB()
    local tgphb= self.transform:Find("LeftRect/LeftRectContent/@TGPHB")
    if phb_begintime < os.time() and os.time() < phb_endtime then 
        tgphb.gameObject:SetActive(true)
    else
        tgphb.gameObject:SetActive(false)
    end
end

function C:HideWDHB()
    local wyhb = self.transform:Find("LeftRect/LeftRectContent/@WYHB")
    local tgjj = self.transform:Find("LeftRect/LeftRectContent/@TGJJ")
    local wdhy = self.transform:Find("LeftRect/LeftRectContent/@WDHY")
    local tgewm = self.transform:Find("LeftRect/LeftRectContent/@TGEWM")
    local tglb = self.transform:Find("LeftRect/LeftRectContent/@TGLB")

    tglb.gameObject:SetActive(GameGlobalOnOff.LIBAO)
    wyhb.gameObject:SetActive(false)
    -- tgewm.localPosition = wdhy.localPosition
    tglb.localPosition = wdhy.localPosition
    wdhy.localPosition = tgjj.localPosition
    tgjj.localPosition = wyhb.localPosition

    if not GameGlobalOnOff.LIBAO then
	tgewm.localPosition = tglb.localPosition
    end
    self.hideWYHB = true
end

function C:HideTGLB()
    local is_show = C.is_show_tglb()
    local tglb = self.transform:Find("LeftRect/LeftRectContent/@TGLB")
    tglb.gameObject:SetActive(is_show)
end

function C:model_get_player_sczd_base_info_response()
    if self.parm then
        self:ChangePanel(self.parm)
        self.parm = nil
        return
    end

    if not self.hideWYHB then
        self:OnWYHBClick()
    else
        -------------------------------------------------------
        --self:OnTGJJClick()  2020年7月21日运营需求修改
        if os.time() >= phb_begintime and os.time() <= phb_endtime then
            self:OnTGPHBClick()
        else
            self:OnTGJJClick()
        end
        -------------------------------------------------------
    end
end

-- 推广礼包激活
function C:model_tglb_profit_activate()
    self:MyRefresh()
end

function C:MyExit()
    if self.cur_panel then
        self.cur_panel.instance:MyClose()
        self.cur_panel = nil
    end
    self.parm = nil
    self:RemoveListener()
    instance = nil

	 
end

function C:ChangePanel(panelName)
    if self.cur_panel then
        if self.cur_panel.name == panelName then
            if  self.cur_panel.instance.MyRefresh then
                self.cur_panel.instance:MyRefresh()
            end 
        else
            self.cur_panel.instance:MyClose()
            self.cur_panel = nil
        end
    end
    if not self.cur_panel then
        self.WYHB_hi.gameObject:SetActive(false)
        self.TGLB_hi.gameObject:SetActive(false)
        self.TGJJ_hi.gameObject:SetActive(false)
        self.WDHY_hi.gameObject:SetActive(false)
        self.TGEWM_hi.gameObject:SetActive(false)
        self.TGPHB_hi.gameObject:SetActive(false)

        self.wyhb_bg_rect.gameObject:SetActive(false)
        self.tglb_bg_rect.gameObject:SetActive(false)
        self.tgjj_bg_rect.gameObject:SetActive(false)
        self.wdhy_bg_rect.gameObject:SetActive(false)
        self.tgewm_bg_rect.gameObject:SetActive(false)
        self.tgphb_bg_rect.gameObject:SetActive(false)
        self.achievement_btn.gameObject:SetActive(false)
        if panelName == panelNameMap.wyhb then
            self.WYHB_hi.gameObject:SetActive(true)
            self.wyhb_bg_rect.gameObject:SetActive(true)
            self.cur_panel = {name = panelName, instance = GameMoneyCenterWYHBPanel.Create(self.RightRect)}
            self.isPopTips=false
        elseif panelName == panelNameMap.tgjj then
            self.TGJJ_hi.gameObject:SetActive(true)
            self.tgjj_bg_rect.gameObject:SetActive(true)
            -- self.cur_panel = {name = panelName, instance = GameMoneyCenterRHZQPanel.Create(self.RightRect)}
            self.cur_panel = {name = panelName, instance = GameMoneyCenterRHZQ1Panel.Create(self.RightRect)}
            -- self.cur_panel = {name = panelName, instance = GameManager.GotoUI({gotoui = "sys_cfzx_qflb",goto_scene_parm = "panel" ,parent = self.RightRect})}
        elseif panelName == panelNameMap.wdhy then
            self.WDHY_hi.gameObject:SetActive(true)
            self.wdhy_bg_rect.gameObject:SetActive(true)
            self.cur_panel = {name = panelName, instance = GameMoneyCenterWDHYPanel.Create(self.RightRect)}
            self.isPopTips=false
            self.achievement_btn.gameObject:SetActive(false)
        elseif panelName == panelNameMap.tgewm then
            self.TGEWM_hi.gameObject:SetActive(true)
            self.tgewm_bg_rect.gameObject:SetActive(true)
            --self.cur_panel = {name = panelName, instance = GameMoneyCenterTGEWMPanel.Create(self.RightRect)}
	        self.cur_panel = {name = panelName, instance = GameMoneyCenterSharePanel.Create(self.RightRect)}
            self.isPopTips=false
        elseif panelName == panelNameMap.tglb then
            self.TGLB_hi.gameObject:SetActive(true)
            self.tglb_bg_rect.gameObject:SetActive(true)
            self.cur_panel = {name = panelName, instance = GameMoneyCenterTGLBPanel.Create(self.RightRect)}
            self.isPopTips=false
        elseif panelName == panelNameMap.tgphb then
            self.TGPHB_hi.gameObject:SetActive(true)
            self.tgphb_bg_rect.gameObject:SetActive(true)
            self.cur_panel = {name = panelName, instance = GameMoneyCenterTGPHBPanel.Create(self.RightRect)}
            self.isPopTips=false
        else
            dump(panelName, "<color=red>没有这个Panel</color>")
        end
        self:UpdateFriendCount()
    end
end

function C:UpdateFriendCount()
    if self.cur_panel then
        if MainModel.UserInfo.cash then
            self.myfriend_num_txt.text = "<color=#FFFFCBFF>" .. StringHelper.ToRedNum(MainModel.UserInfo.cash/100) .. "元</color>"
        else
            self.myfriend_num_txt.text = "<color=#FFFFCBFF>0元</color>"
        end
        -- if self.cur_panel.name == panelNameMap.wdhy then
        --     if GameMoneyCenterModel.data.my_all_son_count then
        --         -- self.myfriend_num_txt.text = "<color=#FFFFCBFF>" .. GameMoneyCenterModel.data.my_all_son_count .. "人</color>"
        --         self.myfriend_num_txt.text = "<color=#FFFFCBFF>" .. StringHelper.ToCash(GameMoneyCenterModel.data.my_get_award / 100) .. "元</color>"
        --     else
        --         -- self.myfriend_num_txt.text = "<color=#FFFFCBFF>0人</color>"
        --         self.myfriend_num_txt.text = "<color=#FFFFCBFF>0元</color>"
        --     end
        -- else
        --     if GameMoneyCenterModel.data.my_all_son_count then
        --         -- self.myfriend_num_txt.text = "<color=#914113FF>" .. GameMoneyCenterModel.data.my_all_son_count .. "人</color>"
        --         self.myfriend_num_txt.text = "<color=#914113FF>" .. StringHelper.ToCash(GameMoneyCenterModel.data.my_get_award / 100) .. "元</color>"
        --     else
        --         -- self.myfriend_num_txt.text = "<color=#FFFFCBFF>0人</color>"
        --         self.myfriend_num_txt.text = "<color=#FFFFCBFF>0元</color>"
        --     end
        -- end
    end
end

-- 场景退出
function C:OnExitScene()
    self:MyExit()
end

-- 刷新
function C:MyRefresh()
    if self.cur_panel and self.cur_panel then
        self.cur_panel.instance:MyRefresh()
    end
end

-- 返回
function C:OnBackClick(go)
    GameObject.Destroy(self.gameObject)
    self:MyExit()
end

-- 帮助
function C:OnHelpClick(go)
    self["HelpInfo"].gameObject:SetActive(true)
end

function C:OnCloseHelp()
    self["HelpInfo"].gameObject:SetActive(false)
end

-- 我要福卡
function C:OnWYHBClick(go)
    self:ChangePanel(panelNameMap.wyhb)
end

-- 推广奖金
function C:OnTGJJClick(go)
    self:ChangePanel(panelNameMap.tgjj)
end

-- 我的好友
function C:OnWDHYClick(go)
    self:ChangePanel(panelNameMap.wdhy)
end

-- 我的好友
function C:OnTGEWMClick(go)
    self:ChangePanel(panelNameMap.tgewm)
end

-- 我要福卡
function C:OnTGLBClick(go)
    self:ChangePanel(panelNameMap.tglb)
end


--推广排行榜
function C:OnTGPHBClick(go)
    self:ChangePanel(panelNameMap.tgphb)
end

 
function GameMoneyCenterPanel.GotoPanel(panel)
    if instance and panel then 
        instance:ChangePanel(panel)
    end 
end 

function C:model_task_change_msg()
    -- if IsEquals(self.gameObject)  then
    --     self.achievement_red.gameObject:SetActive(GameTaskModel.check_reward_state(70,1) or GameTaskModel.check_reward_state(69,#AchievementTGManager.InitCfg().level)
    -- or GameTaskModel.check_reward_state(71,1) or GameTaskModel.check_reward_state(72,1) or  GameTaskModel.check_reward_state(73,1))
    -- end

    self:HideTGLB()
end

function C.is_show_tglb()
    local data = GameMoneyCenterModel.GetTglbData()
    local function CheckGiftTypeByGiftID(id)
        if id then
            if id == 12 or id == 30 or id == 31 or id == 32 or id == 33 then
                return "pig"
            elseif  id == 43 then
                return "vip"
            end
        end
    end
    local list = {}
    if data then
        for k, v in pairs(data) do
            list[#list + 1] = v
        end
    end
    table.sort(
        list,
        function(a, b)
            return a.order < b.order
        end
    )
	for k,v in ipairs(list) do
		if v.on_off and v.on_off == 1 then
			local is_buy = false
            local is_show = false
            if CheckGiftTypeByGiftID(v.good_id) == "vip" then
                is_buy = VIPGiftModel.CheckIsBuy()
                is_show = is_buy
                if not is_buy then
                    is_show = v.not_buy_show and v.not_buy_show == 1
                end
                local is_running, status = VIPGiftModel.GetVIPStatusByTaskID(v.task_id)
                if is_show then
                    is_show = is_running
                end
            elseif CheckGiftTypeByGiftID(v.good_id) == "pig"  then
                -- is_show, is_buy = GoldenPigModel.CheckGiftIsShow(v.good_id)
                -- if is_show then
                --     is_show = GoldenPigModel.CheckTaskIsShow(v.task_id)
                -- end
            end
            --买了礼包且礼包任务没有做完
            if is_buy and is_show then
                return true
            end
		end
    end
end