--ganshuangfeng 比赛场界面
--2018-04-17
local basefunc = require "Game.Common.basefunc"
CityMatchHallPanel = basefunc.class()

CityMatchHallPanel.name = "CityMatchHallPanel"
local lister
local listerRegisterName = "CityMatchHallListerRegister"
local curSwitchMatch
local instance
local have_Jh
function CityMatchHallPanel.Create()
    instance = CityMatchHallPanel.New()
    return createPanel(instance, CityMatchHallPanel.name)
end
function CityMatchHallPanel.Bind()
    local _in = instance
    instance = nil
    return _in
end

function CityMatchHallPanel:Awake()
    ExtendSoundManager.PlaySceneBGM(audio_config.ddz.ddz_bgm_game_hall.audio_name)
    LuaHelper.GeneratingVar(self.transform, self)

    self.behaviour:AddClick(self.BackButton_btn.gameObject, CityMatchHallPanel.OnBackMatchClick, self)
    self.behaviour:AddClick(self.HelpButton_btn.gameObject, CityMatchHallPanel.OnHelpClick, self)
    self.behaviour:AddClick(self.RankButton_btn.gameObject, CityMatchHallPanel.OnRankClick, self)
    self.behaviour:AddClick(self.AwardButton_btn.gameObject, CityMatchHallPanel.OnAwardClick, self)
    self.behaviour:AddClick(self.ApplyButton_btn.gameObject, CityMatchHallPanel.OnApplyClick, self)
    self.behaviour:AddClick(self.GotoSiteButton_btn.gameObject, CityMatchHallPanel.OnGotoSiteClick, self)

    EventTriggerListener.Get(self.StageImage1_btn.gameObject).onDown = basefunc.handler(self, self.OnDown)
    EventTriggerListener.Get(self.StageImage1_btn.gameObject).onUp = basefunc.handler(self, self.OnUp)
    EventTriggerListener.Get(self.StageImage2_btn.gameObject).onDown = basefunc.handler(self, self.OnDown)
    EventTriggerListener.Get(self.StageImage2_btn.gameObject).onUp = basefunc.handler(self, self.OnUp)
    EventTriggerListener.Get(self.StageImage3_btn.gameObject).onDown = basefunc.handler(self, self.OnDown)
    EventTriggerListener.Get(self.StageImage3_btn.gameObject).onUp = basefunc.handler(self, self.OnUp)
end
function CityMatchHallPanel:OnDown(obj)
    local key = obj.name
    print("key = " .. key)
    if key == "@StageImage1_btn" then
        self.StageTipsNode.transform.localPosition = Vector3.New(-236, 72, 0)
        self.StageTips_txt.text = CityMatchModel.GetDdzMacthUIConfigTips()[1]
    elseif key == "@StageImage2_btn" then
        self.StageTipsNode.transform.localPosition = Vector3.New(0, 72, 0)
        self.StageTips_txt.text = CityMatchModel.GetDdzMacthUIConfigTips()[2]
    else
        self.StageTipsNode.transform.localPosition = Vector3.New(236, 72, 0)
        self.StageTips_txt.text = CityMatchModel.GetDdzMacthUIConfigTips()[3]
    end
    self.StageTipsNode.gameObject:SetActive(true)
end
function CityMatchHallPanel:OnUp()
    self.StageTipsNode.gameObject:SetActive(false)
end

function CityMatchHallPanel:Start()
    self:MakeLister()
    CityMatchLogic.setViewMsgRegister(lister, listerRegisterName)
    self:MyRefresh()
end

function CityMatchHallPanel:OnDestroy()
    if have_Jh then
        FullSceneJH.RemoveByTag(have_Jh)
        have_Jh = nil
    end
end

--[[刷新功能，供Logic和model调用，重复性操作]]
function CityMatchHallPanel:MyRefresh()
    self:RefreshState()
    self.DateText_txt.text = CityMatchModel.GetDdzMacthUIConfigTxt().time_txt
end

function CityMatchHallPanel:RefreshPlayerInfo(data)
    if data then
        URLImageManager.UpdateHeadImage(data[1].url, self.FirstHead_img)
        self.FirstName_txt.text = data[1].name or ""
        URLImageManager.UpdateHeadImage(data[2].url, self.SecondHead_img)
        self.SecondName_txt.text = data[2].name or ""
        URLImageManager.UpdateHeadImage(data[3].url, self.ThirdHead_img)
        self.ThirdName_txt.text = data[3].name or ""
    end
end

function CityMatchHallPanel:RefreshState()
    print("<color=ywllow>CityMatchHallPanel:RefreshState</color>")
    self.ApplyButton_btn.gameObject:SetActive(false)
    self.NoApplyButton.gameObject:SetActive(false)
    self.StageImageHi1.gameObject:SetActive(false)
    self.StageImageHi2.gameObject:SetActive(false)
    self.StageImageHi3.gameObject:SetActive(false)
    self.StageImageNo1.gameObject:SetActive(true)
    self.StageImageNo2.gameObject:SetActive(true)
    self.StageImageNo3.gameObject:SetActive(true)
    self.RankButton_btn.gameObject:SetActive(true)

    local func_get_state_data = function(state_data)
        if IsEquals(self.transform) then
            local stateData = state_data
            if stateData.state == MainModel.CityMatchState.CMS_Wait then
                self.NoApplyButton.gameObject:SetActive(true)
                self.NoApply_txt.text = "即将开赛"
                self.StageImageHi1.gameObject:SetActive(true)
                self.RankButton_btn.gameObject:SetActive(false)
            elseif stateData.state == MainModel.CityMatchState.CMS_MatchStage_One then
                self.ApplyButton_btn.gameObject:SetActive(true)
                self.StageImageHi1.gameObject:SetActive(true)
                self.StageImageNo1.gameObject:SetActive(false)
            elseif stateData.state == MainModel.CityMatchState.CMS_MatchStage_Wait1 then
                self.NoApplyButton.gameObject:SetActive(true)
                self.NoApply_txt.text = "即将开赛"
                self.StageImageHi2.gameObject:SetActive(true)
                self.StageImageNo2.gameObject:SetActive(false)
            elseif stateData.state == MainModel.CityMatchState.CMS_MatchStage_Two_Singup then
                self.ApplyButton_btn.gameObject:SetActive(true)
                self.StageImageHi2.gameObject:SetActive(true)
                self.StageImageNo2.gameObject:SetActive(false)
            elseif stateData.state == MainModel.CityMatchState.CMS_MatchStage_Two then
                self.NoApplyButton.gameObject:SetActive(true)
                self.NoApply_txt.text = "正在比赛"
                self.StageImageHi2.gameObject:SetActive(true)
                self.StageImageNo2.gameObject:SetActive(false)
            elseif stateData.state == MainModel.CityMatchState.CMS_MatchStage_Wait2 then
                self.ApplyButton_btn.gameObject:SetActive(true)
                self.StageImageHi3.gameObject:SetActive(true)
                self.StageImageNo3.gameObject:SetActive(false)
            elseif stateData.state == MainModel.CityMatchState.CMS_MatchStage_Three then
                self.ApplyButton_btn.gameObject:SetActive(true)
                self.StageImageHi3.gameObject:SetActive(true)
                self.StageImageNo3.gameObject:SetActive(false)
            elseif stateData.state == MainModel.CityMatchState.CMS_MatchStage_End then
                self.DownRectTournament.gameObject:SetActive(false)
                self.BGRectTournament.gameObject:SetActive(false)
                self.TimeImageTournament.gameObject:SetActive(false)

                self.DownRectMatch.gameObject:SetActive(true)
                self.BGRectMatch.gameObject:SetActive(true)

                local rank_data = CityMatchModel.GetDdzMacthUIConfigFinalsRank().rank_list
                self:RefreshPlayerInfo(rank_data)
            else --没有比赛 同结束状态一样显示
                self.RankButton_btn.gameObject:SetActive(false)
                self.DownRectTournament.gameObject:SetActive(false)
                self.BGRectTournament.gameObject:SetActive(false)
                self.TimeImageTournament.gameObject:SetActive(false)

                self.DownRectMatch.gameObject:SetActive(true)
                self.BGRectMatch.gameObject:SetActive(true)
                local rank_data = CityMatchModel.GetDdzMacthUIConfigFinalsRank().rank_list
                self:RefreshPlayerInfo(rank_data)
            end
            self.currState = stateData.state
            self.showTime = stateData.time
            self:RefreshTime()
        end
    end

    CityMatchModel.GetGameStateData(func_get_state_data)
end

function CityMatchHallPanel:RefreshTime()
    if self.update then
        self.update:Stop()
    end
    if self.showTime and self.showTime > 0 then
        self.TimeText_txt.gameObject:SetActive(true)
        local call = function()
            self:UpdateUI()
        end
        self.update = Timer.New(call, 1, self.showTime, true)
        self.update:Start()
        self:UpdateTime()
    else
        self.TimeText_txt.gameObject:SetActive(false)
    end
end
function CityMatchHallPanel:UpdateUI()
    self.showTime = self.showTime - 1
    if self.showTime > 0 then
        self:UpdateTime()
    end
end
function CityMatchHallPanel:UpdateTime()
    local day = math.floor(self.showTime / 86400)
    local h = math.floor((self.showTime % 86400) / 3600)
    local m = math.floor((self.showTime % 3600) / 60)
    local s = math.floor(self.showTime % 60)
    if IsEquals(self.TimeText_txt) then
        self.TimeText_txt.text = "倒计时：" .. day .. "天" .. h .. "时" .. m .. "分" .. s .. "秒"
    end
end

--[[退出功能，供logic和model调用，只做一次]]
function CityMatchHallPanel:MyExit()
    CityMatchLogic.clearViewMsgRegister(listerRegisterName)
    lister = nil
    if self.update then
        self.update:Stop()
    end
    self.update = nil
end
function CityMatchHallPanel:MyClose()
    self:MyExit()
    closePanel(CityMatchHallPanel.name)
end

function CityMatchHallPanel:MakeLister()
    lister = {}
    lister["city_match_refersh_state"] = basefunc.handler(self, self.city_match_refersh_state)
end

function CityMatchHallPanel:city_match_refersh_state()
    self:MyRefresh()
end

--退出比赛场
function CityMatchHallPanel:OnBackMatchClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    -- Network.SendRequest("citymg_cancel_signup",{},"取消报名",function (data)
    -- 	if data.result == 0 then
    -- 		Event.Brocast("citymg_cancel_signup_response","citymg_cancel_signup_response",data)
    -- 	else
    -- 		HintPanel.ErrorMsg(data.result)
    -- 	end
    -- end)
    local hall_type = MatchModel.GetCurHallType()
    if hall_type then
        local scene_name = GameConfigToSceneCfg.game_MatchHall.SceneName
        local parm = {hall_type = hall_type}
        MainLogic.GotoScene(scene_name,parm)
    else
        MainLogic.GotoScene("game_Hall")
    end
end
--帮助
function CityMatchHallPanel:OnHelpClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local obj = newObject("CityRulePanel", GameObject.Find("Canvas/LayerLv3").transform)
    local obj_table = {}
    LuaHelper.GeneratingVar(obj.transform, obj_table)
    obj_table.rule_bg_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            destroy(obj)
            obj = nil
            obj_table = nil
        end
    )

    obj_table.rule_back_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            destroy(obj)
            obj = nil
            obj_table = nil
        end
    )
end
--排行榜
function CityMatchHallPanel:OnRankClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    CityRankPanel.Create(
        function()
            print("排行榜退出回调")
        end
    )
end

--排行榜
function CityMatchHallPanel:OnAwardClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    CityAwardPanel.Create(
        function()
            print("排行榜退出回调")
        end
    )
end

--报名按钮
function CityMatchHallPanel:OnApplyClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)

    local func_get_state_data =
        function(state_data)
        local stateData = state_data
        --复赛结束后决赛未开始/决赛中：给出报名地点提示
        if
            stateData.state == MainModel.CityMatchState.CMS_MatchStage_Wait2 or
                stateData.state == MainModel.CityMatchState.CMS_MatchStage_Three
         then
            local msg = CityMatchModel.GetDdzMacthUIConfigTips().finals_gaming_tips
            LittleTips.Create(msg, {x = 0, y = -200})
            return
        end

        local func_bing =
            function()
            local func_signup_id =
                function(signup_id)
                print("<color=yellow>signup_id</color>", signup_id)
                local func_signup =
                    function()
                    if signup_id == 0 then
                        HintPanel.Create(1, "当前不在可报名状态")
                    elseif signup_id == 3 then
                        HintPanel.Create(1, CityMatchModel.GetDdzMacthUIConfigTips().finals_gaming_tips)
                    else
                        Network.SendRequest(
                            "citymg_signup",
                            {id = signup_id},
                            "城市杯报名",
                            function(data)
                                if data.result == 0 then
                                    if data.match_type == 1 then
                                        print("<color=yellow>城市杯海选赛报名成功：</color>", data.result)
                                        Event.Brocast("citymg_signup_response", "citymg_signup_response", data)
                                    elseif data.match_type == 2 then
                                        print("<color=yellow>城市杯复赛报名成功：</color>", data.result)
                                        Event.Brocast(
                                            "citymg_signup_rematch_response",
                                            "citymg_signup_rematch_response",
                                            data
                                        )
                                    end
                                elseif data.result == 1027 or data.result == 1028 then
                                    if data.match_type == 1 then
                                        --海选赛分享拿门票
                                        CityMatchSharePanel.Create(
                                            "city_match",
                                            "share",
                                            function()
                                                print("<color=yellow>分享以获取入场券</color>")
                                            end
                                        )
                                    elseif data.match_type == 2 then
                                        local txt = CityMatchModel.GetDdzMacthUIConfigTxt().rematch_not_tireck_hint
                                        HintPanel.Create(
                                            2,
                                            txt,
                                            function()
                                                MainLogic.GotoScene("game_MatchHall")
                                            end
                                        )
                                    end
                                elseif data.result == 3301 then
                                    LittleTips.Create(
                                        CityMatchModel.GetDdzMacthUIConfigTips().rematch_tips,
                                        {x = 0, y = 100}
                                    )
                                else
                                    HintPanel.ErrorMsg(data.result)
                                end
                            end
                        )
                    end
                end

                if signup_id == 2 then
                    --复赛检查手机
                    if GameGlobalOnOff.BindingPhone and not MainModel.UserInfo.phoneData.phone_no then
                        local parent = GameObject.Find("Canvas/LayerLv4").transform
                        local tips = CityMatchModel.GetDdzMacthUIConfigTxt().binding_phone
                        GameManager.GotoUI({gotoui = "sys_binding_phone",goto_scene_parm = "panel",parent = parent,tips = tips,func_signup = func_signup})
                        return
                    end
                end
                --报名
                func_signup()
            end
            CityMatchHallPanel.GetSingupId(func_signup_id)
        end
        MainModel.GetBindPhone(func_bing)
    end
    CityMatchModel.GetGameStateData(func_get_state_data)
end

--跳转到比赛场按钮
function CityMatchHallPanel:OnGotoSiteClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainLogic.GotoScene("game_MatchHall")
end

function CityMatchHallPanel.GetSingupId(call)
    local func_get_state_data = function(state_data)
        local cur_state = state_data.state
        if cur_state == MainModel.CityMatchState.CMS_MatchStage_One then
            call(1)
            return
        elseif cur_state == MainModel.CityMatchState.CMS_MatchStage_Two_Singup then
            call(2)
            return
        elseif cur_state == MainModel.CityMatchState.CMS_MatchStage_Three then
            call(3)
            return
        end
        call(0)
        return 0
    end
    CityMatchModel.GetGameStateData(func_get_state_data)
end
