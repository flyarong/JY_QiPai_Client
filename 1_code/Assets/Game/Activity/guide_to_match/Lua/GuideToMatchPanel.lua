local basefunc = require "Game.Common.basefunc"
GuideToMatchPanel = basefunc.class()

function GuideToMatchPanel.Create(call)
    -- 鲸币数不足以进入新手场时，屏蔽引导玩家前往免费福卡赛的弹窗
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="drt_block_free_match_game_dialog", is_on_hint = true}, "CheckCondition")
    if a and b then
        if call then
            call()
        end
        return
    end
    return GuideToMatchPanel.New()
end

function GuideToMatchPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GuideToMatchPanel:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
    self.lister["query_everyday_shared_award_response"] = basefunc.handler(self, self.query_everyday_shared_award_response)
end

function GuideToMatchPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function GuideToMatchPanel:ctor()

	ExtPanel.ExtMsg(self)

    self:MakeLister()
    self:AddMsgListener()
    self.parent = GameObject.Find("Canvas/LayerLv5")
    self.gameObject = newObject("GuideToMatchPanel", self.parent.transform)
    LuaHelper.GeneratingVar(self.gameObject.transform, self)

    self.close_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:Close()
    end)
    self.confirm_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnConfirmClick()
    end)
    self.gameObject:SetActive(false)
    Network.SendRequest("query_everyday_shared_award", {type="one_yuan_match"})
end

function GuideToMatchPanel:OnConfirmClick()
    dump(MainModel.myLocation)
    local is_fg_quit_game
    if MainModel.myLocation == "game_DdzFree"
        or MainModel.myLocation == "game_Mj3D"
        or MainModel.myLocation == "game_Gobang"
        or MainModel.myLocation == "game_FishingHall"
        or MainModel.myLocation == "game_DdzPDK" then
        is_fg_quit_game = true
        MainLogic.ExitGame()
    end
	GameManager.GotoUI({gotoui="match_hall", enter_scene_call=function ()
        if is_fg_quit_game then
            -- 先发消息会去到匹配场大厅，改成这样
            Network.SendRequest("fg_quit_game")
        end
    end})
end

function GuideToMatchPanel:OnExitScene()
    self:Close()
end

function GuideToMatchPanel:MyExit()
    destroy(self.gameObject)
    self:RemoveListener()
end

function GuideToMatchPanel:Close()
    self:MyExit()
end

function GuideToMatchPanel:query_everyday_shared_award_response(_,data)
    if data and data.result == 0 then 
        local  can_share_num = data.status or 0
        if  can_share_num <= 0 then 
            self:OnExitScene() 
        else
            if IsEquals(self.gameObject) then 
                self.gameObject:SetActive(true)
            end 
        end 
    else
        self:OnExitScene() 
    end 
end 


