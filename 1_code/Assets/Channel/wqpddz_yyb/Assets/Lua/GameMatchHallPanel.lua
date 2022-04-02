-- 创建时间:2018-10-15
local basefunc = require "Game.Common.basefunc"
MatchHallPanel = basefunc.class()
MatchHallPanel.name = "MatchHallPanel"
local dotweenlayer = "MatchHallPanel"
local instance
local lister
local listerRegisterName = "MatchHallListerRegister"
function MatchHallPanel.Create(parm)
    if not instance then
        DSM.PushAct({panel = MatchHallPanel.name})
        instance = MatchHallPanel.New(parm)
    else
        instance:MyRefresh(parm)
    end
    return instance
end

function MatchHallPanel:ctor(parm)
    self.parm = parm
    local parent = GameObject.Find("Canvas/GUIRoot").transform
    local obj = newObject(MatchHallPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.duihuanshangcheng_anniu = self.transform:Find("@hall_ui/duihuanshangcheng_anniu")
    local btn_map = {}
	btn_map["left_top"] = {self.btnNode}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "match_hall")
    self:MyInit()
    self:MyRefresh()
end

function MatchHallPanel:MyInit()
    ExtendSoundManager.PlaySceneBGM(audio_config.match.bgm_bisai_bisaidengdai.audio_name)
    self:MakeLister()
    MatchHallLogic.setViewMsgRegister(lister, listerRegisterName)
    EventTriggerListener.Get(self.hall_back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickBackMatch)
    EventTriggerListener.Get(self.shop_btn.gameObject).onClick = basefunc.handler(self, self.OnClickShoping)
    EventTriggerListener.Get(self.duihuan_btn.gameObject).onClick = basefunc.handler(self, self.OnClickStore)
    self:InitContent()
    self:InitTge()
    self:GameGlobalOnOff()
end

function MatchHallPanel:MyRefresh()
    self:UpdateAssetInfo()
    self:OpenUIAnim()
end

function MatchHallPanel:MyExit()
    if instance then
        DOTweenManager.KillAllLayerTween(dotweenlayer)
        MatchHallLogic.clearViewMsgRegister(listerRegisterName)
        MatchHallContent.Close()
        instance = nil
        MatchHallDetailPanel.Close()
        if self.game_btn_pre then
            self.game_btn_pre:MyExit()
        end
    end
end

function MatchHallPanel:MyClose()
    self:MyExit()
    DSM.PopAct()
    closePanel(MatchHallPanel.name)
end

function MatchHallPanel:MakeLister()
    lister = {}
    lister["AssetChange"] = basefunc.handler(self, self.UpdateAssetInfo)
end

--************方法
-- 界面打开的动画
function MatchHallPanel:OpenUIAnim()
    local Ease = DG.Tweening.Ease.InOutQuart
    local tt = 0.2
    local tt2 = 0.15
    local tt3 = 0.15

    self.RectTop.transform.localPosition = Vector3.New(0, 150, 0)
    self.LeftNode.transform.localPosition = Vector3.New(-1200, -67.5, 0)

    local seq = DG.Tweening.DOTween.Sequence()
    local tweenKey = DOTweenManager.AddTweenToLayer(seq, dotweenlayer)
    seq:Append(self.RectTop.transform:DOLocalMoveY(-86, tt):SetEase(Ease))
    seq:Append(self.LeftNode.transform:DOLocalMoveX(-763, tt3):SetEase(Ease))

    seq:OnComplete(
        function()
            self:OpenUIAnimFinish()
        end
    )
    seq:OnKill(
        function()
            DOTweenManager.RemoveLayerTween(tweenKey, dotweenlayer)            
        end
    )
end

function MatchHallPanel:OpenUIAnimFinish()
    self.RectTop.transform.localPosition = Vector3.New(0, -86, 0)
    self.LeftNode.transform.localPosition = Vector3.New(-763, -67.5, 0)
    if GuideLogic then
        GuideLogic.CheckRunGuide("match_hall")
    end
end

function MatchHallPanel.SetTgeByID(tge_id)
    dump(instance, "<color=yellow>SetTgeByID</color>")
    if instance then
        MatchHallTge.SetTgeIsOn(tge_id)
    end
end

--func1 需要更新回调   func2正常状态回调
function MatchHallPanel.HandleEnterGameClick(game_type, func1, func2)
    local sceneConfig = GameConfigToSceneCfg[game_type]
    if not sceneConfig then
        print("<color=red> is nil</color>",game_type)
        return
    end

    local sceneName = sceneConfig.SceneName
    local state = gameMgr:CheckUpdate(sceneName)
    -- state = "Update"
    if state == "Install" or state == "Update" then
        if func1 then
            func1()
        end
    elseif state == "Normal" then
        if func2 then
            func2()
        end
    else
        local msg = MainLogic.FormatGameStateError(state)
        if msg ~= nil then
            HintPanel.ErrorMsg(msg)
        end
    end
end

function MatchHallPanel:GameGlobalOnOff()
    if GameGlobalOnOff.Exchange then
        self.duihuan_btn.gameObject:SetActive(true)
    else
        self.duihuan_btn.gameObject:SetActive(false)
    end

    if GameGlobalOnOff.MatchUrgencyClose then
        HintPanel.Create(1, "比赛正在升级，请耐心等待，升级完毕后会通过邮件告知，请注意查看邮件", function ()
            MainLogic.GotoScene("game_Hall")
        end)
    end
end

-- 刷新钱
function MatchHallPanel:UpdateAssetInfo()
    self.ticker_num_txt.text = StringHelper.ToCash(MainModel.UserInfo.jing_bi)
    self.red_packet_txt.text = StringHelper.ToRedNum(MainModel.GetHBValue())
end

function MatchHallPanel.SetContentByCfg(game_tag)
    MatchHallContent.Refresh(game_tag)
end

function MatchHallPanel.UpdateRightUI(cfg)
    MatchHallPanel.SetContentByCfg(cfg.game_tag)
end

--Tge
function MatchHallPanel:InitTge()
    local config = MatchModel.GetHall()
    MatchHallTge.Create(self.LeftNode,config)
    --默认开启福卡赛
    local hall_type = MatchModel.GetCurHallType()
    MatchHallTge.SetTgeIsOn(hall_type)
    -- MatchHallPanel.SetTgeByID(hall_type)
end

--Content
function MatchHallPanel:InitContent()
    local config = MatchModel.GetConfigByType()
    MatchHallContent.Create(self.RightNode,config)
end

--OnClick**********************************
function MatchHallPanel:OnClickBackMatch(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainLogic.GotoScene("game_Hall")
end

function MatchHallPanel:OnClickShoping(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    DSM.PushAct({button = "pay_btn"})
    PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
end

function MatchHallPanel:OnClickStore(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    -- MainModel.OpenDH()
    PayPanel.Create(GOODS_TYPE.item)
end

function MatchHallPanel.ShowMatch(cfg)
    if table_is_null(cfg) then return end
    if cfg.game_type == MatchModel.GameType.game_DdzMatch or cfg.game_type == MatchModel.GameType.game_DdzPDKMatch or cfg.game_type == MatchModel.GameType.game_MjXzMatch3D then
        --福卡赛模式
        MatchHallPanel.ShowMatchHBS(cfg)
    elseif cfg.game_type == MatchModel.GameType.game_DdzMatchNaming or cfg.game_type == MatchModel.GameType.game_MjMatchNaming then
        --千元赛模式
        MatchHallPanel.ShowMatchQYS(cfg)
    elseif cfg.game_type == MatchModel.GameType.game_CityMatch then
        MatchHallPanel.ShowMatchJYB(cfg)
    elseif cfg.game_type == MatchModel.GameType.game_DdzMillion then
        MatchHallPanel.ShowMatchBWS(cfg)
    end
end

function MatchHallPanel.SignupMatch(cfg)
    if table_is_null(cfg) then return end
    if cfg.game_type == MatchModel.GameType.game_DdzMatch or cfg.game_type == MatchModel.GameType.game_DdzPDKMatch or cfg.game_type == MatchModel.GameType.game_MjXzMatch3D then
        --福卡赛模式
        MatchHallPanel.SignupMatchHBS(cfg)
    elseif cfg.game_type == MatchModel.GameType.game_DdzMatchNaming or cfg.game_type == MatchModel.GameType.game_MjMatchNaming then
        --千元赛模式
        MatchHallPanel.SignupMatchQYS(cfg)
    elseif cfg.game_type == MatchModel.GameType.game_CityMatch then
    elseif cfg.game_type == MatchModel.GameType.game_DdzMillion then
    end
end

function MatchHallPanel.ShowMatchHBS(cfg)
    if tonumber(cfg.game_id) == 1 then
        --新手引导
        MatchHallPanel.SignupMatch(cfg)
        return
    end
    MatchHallDetailPanel.Create(cfg.game_id)
end

--福卡赛模式报名
function MatchHallPanel.SignupMatchHBS(cfg)
    if tonumber(cfg.game_id) == 1 then
        --新手引导
        if instance then
            instance:MyExit()
        end
        GameManager.GotoSceneID(1,true,nil,function()
            if not Network.SendRequest("nor_mg_xsyd_signup", nil, "正在报名") then
                HintPanel.Create(1,"网络异常",function()
                    GameManager.GotoSceneName("game_MatchHall")
                end)
            end
        end)
        return
    end

    if tonumber(cfg.game_id) == 10 then
        --一元赛
        MatchHallPanel.ShowMatch(cfg)
        return
    end

    if cfg.game_tag == MatchModel.MatchType.fps then
        LittleTips.Create("扶贫赛即将开始")
        return
    end

    local signup = function ()
        local request = {id = tonumber(cfg.game_id)}
        MatchModel.SetCurrGameID(cfg.game_id)
        local scene_id = MatchModel.GetGameIDToScene(cfg.game_id)
        GameManager.GotoSceneID(scene_id , true , nil , function() 
            if not Network.SendRequest("nor_mg_signup", request, "正在报名") then
                HintPanel.Create(1, "网络异常", function()
                    GameManager.GotoSceneName("game_MatchHall")
                end)
            end
        end)
    end
    local config = MatchModel.GetGameCfg(cfg.game_id)
    -- dump(config, "<color=white>比赛配置》》》》</color>")
    local itemkey, item_count = MatchModel.GetMatchCanUseTool(config.enter_condi_itemkey, config.enter_condi_item_count)
    if itemkey then
        signup()
    else
        if config.enter_condi_count <= MainModel.UserInfo.jing_bi then
            signup()
        else
            PayFastPanel.Create(config, signup)
        end 
    end
end

function MatchHallPanel.ShowMatchQYS(cfg)
    local game_over_countdown = tonumber(cfg.over_time) - os.time()
    local game_start_countdown = tonumber(cfg.start_time) - os.time()

    local qurey_rank = function()
        -- 排行榜分步请求
        local cur_index = 1
        local rank_list = {}
        local call
        call = function ()
            Network.SendRequest("nor_mg_query_all_rank",{id = cfg.game_id, index = cur_index},"正在请求排名",
                function(data)
                    cur_index = cur_index + 1
                    dump(data, "<color=yellow>nor_mg_query_all_rank_response</color>")
                    if data.result == 0 then
                        for k,v in ipairs(data.rank_list) do  
                            rank_list[#rank_list + 1] = v
                        end
                        if #data.rank_list < 100 then
                            -- 排行榜请求完成
                            MatchHallRankPanel.Create(cfg, rank_list)
                        else
                            call()
                        end
                    elseif data.result == 1004 then
                        MatchHallRankPanel.Create(cfg)
                    else
                        HintPanel.ErrorMsg(data.result)
                    end
            end)
        end
        call()
    end
    --比赛结束排行榜处理
    if game_over_countdown <= 0 then
        qurey_rank()
        return
    end

    MatchHallDetailPanel.Create(cfg.game_id)
end

--千元赛模式报名
function MatchHallPanel.SignupMatchQYS(cfg)
    dump(cfg, "<color=white>cfg????????千元赛模式报名</color>")
    local game_over_countdown = tonumber(cfg.over_time) - os.time()
    local game_start_countdown = tonumber(cfg.start_time) - os.time()
    --测试数据
    -- game_over_countdown = -1

    --各种情况不能报名
    if game_over_countdown <= 0 or 
        (cfg.iswy and cfg.iswy == 1) or
        game_start_countdown > 0 or
        not MatchModel.CheckIsCanSignup(cfg) then
            MatchHallPanel.ShowMatchQYS(cfg)
        return
    end

    if MatchModel.CheckIsCanSignup(cfg) and not MatchModel.CheckIsCanSignupByTicket(cfg) then
        --鲸币满足道具不满足，排除不能用金币报名的比赛
        if cfg.game_tag == MatchModel.MatchType.gms then
            if not cfg.iswy or cfg.iswy ~= 1 then
                MatchHallDetailPanel.Create(cfg.game_id)
                return
            end
        end
    end

    Network.SendRequest("nor_mg_signup", {id = cfg.game_id}, "正在报名",
        function(data)
            dump(data, "<color=yellow>千元赛模式报名结果</color>")
            if data.result == 0 then
                MatchModel.SetCurrGameID(cfg.game_id)
                local scene_id = MatchModel.GetGameIDToScene(cfg.game_id)
                GameManager.GotoSceneID(scene_id, false, nil)
                if instance then
                    instance:MyExit()
                end
            elseif data.result == 3601 then
                HintPanel.Create(2,"您已经参加过该比赛了，更多福卡赛等你来，是否立刻前往福卡赛？",function()
                    MatchHallDetailPanel.Close()
                    MatchHallPanel.SetTgeByID(1)
                end)
            else
                HintPanel.ErrorMsg(data.result)
            end
        end
    )
end

--百万大奖赛模式
function MatchHallPanel.ShowMatchBWS(cfg)
    local sceneName = GameConfigToSceneCfg["game_DdzMillion"].SceneName
    local function GoToMillion()
        Network.SendRequest("dbwg_req_game_list",nil,"正在请求数据",function(data)
            if data.result == 0 then
                MainLogic.GotoScene(sceneName)
            else
                HintPanel.Create(1, "今日没有比赛")
            end
        end)
    end

    MatchHallPanel.HandleEnterGameClick(
        sceneName,
        function()
            package.loaded["Game.game_Hall.Lua.RoomCardDown"] = nil
            require "Game.game_Hall.Lua.RoomCardDown"
            RoomCardDown.Create(
                sceneName,
                function()
                    GoToMillion()
                end
            )
        end,
        function()
            GoToMillion()
        end
    )
end

--鲸鱼杯模式
function MatchHallPanel.ShowMatchJYB(cfg)
    MainModel.RequestCityMatchStateData(
        function(data)
            local sceneName = GameConfigToSceneCfg["game_CityMatch"].SceneName
            MatchHallPanel.HandleEnterGameClick(
                sceneName,
                function()
                    package.loaded["Game.game_Hall.Lua.RoomCardDown"] = nil
                    require "Game.game_Hall.Lua.RoomCardDown"
                    RoomCardDown.Create(
                        sceneName,
                        function()
                            MainLogic.GotoScene(sceneName, data)
                        end
                    )
                end,
                function()
                    MainLogic.GotoScene(sceneName, data)
                end
            )
        end
    )
end