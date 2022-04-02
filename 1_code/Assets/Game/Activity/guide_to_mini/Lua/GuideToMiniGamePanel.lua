local basefunc = require "Game.Common.basefunc"
GuideToMiniGamePanel = basefunc.class()

function GuideToMiniGamePanel.Create()
    return GuideToMiniGamePanel.New()
end

function GuideToMiniGamePanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GuideToMiniGamePanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["fg_close_clearing"] = basefunc.handler(self, self.Close)

end

function GuideToMiniGamePanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function GuideToMiniGamePanel:ctor()

	ExtPanel.ExtMsg(self)

    self:MakeLister()
    self:AddMsgListener()
    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject("GuideToMiniGamePanel", self.parent.transform)
    LuaHelper.GeneratingVar(self.gameObject.transform, self)

    self.close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnCloseClick()
    end)
    self.confirm_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        local callback = basefunc.handler(self, self.OnConfirmClick)
        GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
    end)

    self.goto_mini_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        local callback = basefunc.handler(self, self.OnConfirmClick)
        GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
    end)

    Network.SendRequest("query_consume_exceed",  {money = 100},"请求数据",function(data)
        dump(data, "<color=white>充值数据</color>")
        if data.result == 0 then
            self.cz_num = data.status == 0
		else
            HintPanel.ErrorMsg(data.result)
            self.cz_num = false
        end
        if IsEquals(self.button_node) then
            self.button_node.gameObject:SetActive(self.cz_num)
        end
	end)

    self.free_lose_num = PlayerPrefs.GetInt("grand_total_free_lose_num" .. MainModel.UserInfo.user_id, 0)
    self.window_node.gameObject:SetActive(self.free_lose_num >= 3 and MainModel.UserInfo.jing_bi >= 30000)
end

function GuideToMiniGamePanel:OnConfirmClick()
    dump(MainModel.myLocation)
    local is_fg_quit_game
    if MainModel.myLocation == "game_DdzFree"
        or MainModel.myLocation == "game_Mj3D"
        or MainModel.myLocation == "game_Gobang"
        or MainModel.myLocation == "game_DdzPDK" then
        is_fg_quit_game = true
        MainLogic.ExitGame()
    end
    GameManager.GotoUI({gotoui="game_MiniGame", enter_scene_call=function ()
        -- GameObject.Destroy(self.gameObject)
        -- self:RemoveListener()
        if is_fg_quit_game then
            -- 先发消息会去到匹配场大厅，改成这样
            Network.SendRequest("fg_quit_game")
        end
    end})
end

function GuideToMiniGamePanel:OnExitScene()
    self:Close()
end

function GuideToMiniGamePanel:OnCloseClick()
    self.window_node.gameObject:SetActive(false)
    if self.free_lose_num >= 3 then
        PlayerPrefs.SetInt("grand_total_free_lose_num" .. MainModel.UserInfo.user_id, 0)
    end
end

function GuideToMiniGamePanel:MyExit()
    destroy(self.gameObject)
    self:RemoveListener()
    if self.free_lose_num >= 3 then
        if MainModel.UserInfo then
            PlayerPrefs.SetInt("grand_total_free_lose_num" .. MainModel.UserInfo.user_id, 0)
        end
    end
end

function GuideToMiniGamePanel:Close()
    self:MyExit()
end