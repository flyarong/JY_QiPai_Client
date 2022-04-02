local basefunc = require "Game.Common.basefunc"

WithdrawPanel = basefunc.class()

WithdrawPanel.name = "WithdrawPanel"

local instance
function WithdrawPanel.Create()
    instance = WithdrawPanel.New()
    return instance
end
function WithdrawPanel.Exit()
    if instance then
        instance:MyExit()
    end
    instance = nil
end
function WithdrawPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

    parent = GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(WithdrawPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)

    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClick)
    EventTriggerListener.Get(self.withdraw_btn.gameObject).onClick = basefunc.handler(self, self.OnClickWithdraw)

    self.AssetChange = function ()
        self:RefreshMoney()
    end
    Event.AddListener("AssetChange", self.AssetChange)

    self:InitUI()

    DOTweenManager.OpenPopupUIAnim(self.transform)
end

--初始化UI
function WithdrawPanel:InitUI()
    self:RefreshMoney()
end

function WithdrawPanel:RefreshMoney()
    self.money_txt.text = StringHelper.ToRedNum(MainModel.UserInfo.cash / 100)
end

function WithdrawPanel:OnCloseClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    self:MyExit()
end

function WithdrawPanel:OnClickWithdraw(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    MainLogic.Withdraw(self:RefreshMoney())
end

function WithdrawPanel:MyExit()
    Event.RemoveListener("AssetChange", self.AssetChange)
    destroy(self.gameObject)
end