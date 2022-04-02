ComMatchReservationPanel = basefunc.class()
local M = ComMatchReservationPanel
M.name = "ComMatchReservationPanel"

local instance

function M:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function M:MakeLister()
    self.lister = {}
end

function M:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function M:MyExit()
    self:RemoveListener()
    destroy(self.gameObject)
    instance = nil	 
end

function M.Create(cfg)
    if not instance then
        instance = M.New(cfg)
    end
    return instance
end

function M.Close()
    if instance then
        instance:MyExit()
    end
    instance = nil
end

function M:ctor(cfg)

	ExtPanel.ExtMsg(self)

    self.cfg = cfg
    self.config = MatchModel.GetGameCfg(self.cfg.game_id)
    self.parent = GameObject.Find("Canvas/LayerLv3").transform
    local obj = newObject(M.name, self.parent)

    self:MakeLister()
    self:AddMsgListener()
    
    self.match_type = self.config.match_type
    self.transform = obj.transform
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    self:InitUI()
end

function M:MyRefresh()
end

function M:InitUI()
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickClose)
    EventTriggerListener.Get(self.signup_btn.gameObject).onClick = basefunc.handler(self, self.OnClickSignup)
    self.name_txt = self.config.ui_match_name
end

function M:OnClickClose()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:MyExit()
end

function M:OnClickSignup()
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MatchLogic.SignupMatch(self.config)
    Network.SendRequest("nor_mg_reserve",{game_id = self.config.game_id,time = os.time()},"",function(data)
        if data.result ~= 0 then
            HintPanel.ErrorMsg(data.result)
        else
            LittleTips.Create("预约成功")
            self:MyExit()
        end
    end)
end

--京东卡争夺战决赛预约报名
function M.ShowJDKZDSJS(cfg,data)
    if cfg.match_type ~= MatchModel.MatchType.jddzds then
        return
    end
    if not data.fianlResult or not data.fianlResult.reward then
        return
    end
    local js_cfg = MatchModel.GetGameCfg(cfg.game_id + 1)
    if not js_cfg then
        return
    end
    local is_js = false
    for k,v in pairs(data.fianlResult.reward) do
        if v.assets_type == "jdkzdsjs_prop" then
            is_js = true
            break
        end
    end
    if not is_js then return end
    local now_match_game_id = MatchModel.GetNowMatchGameID(js_cfg.game_id)
    if now_match_game_id == js_cfg.game_id then
        return
    end
    M.Create(js_cfg)
end