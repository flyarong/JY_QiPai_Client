-- 创建时间:2018-11-08

local basefunc = require "Game.Common.basefunc"

HallMoneyPanel = basefunc.class()

HallMoneyPanel.name = "HallMoneyPanel"


local instance
function HallMoneyPanel.Create(parent)
	instance = HallMoneyPanel.New(parent)
	return instance
end

function HallMoneyPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallMoneyPanel:MakeLister()
    self.lister = {}
    self.lister["AssetChange"] = basefunc.handler(self, self.RefreshMoney)
end

function HallMoneyPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function HallMoneyPanel:MyClose()
	self:MyExit()
end

function HallMoneyPanel:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)	 
end

function HallMoneyPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(HallMoneyPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.DrawMoneyButton = tran:Find("Rect/DrawMoneyButton"):GetComponent("Button")
	self.MoneyText = tran:Find("Rect/MoneyText"):GetComponent("Text")
    self.DrawMoneyButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnDrawMoneyClick()
    end)
    self:InitUI()
end
function HallMoneyPanel:InitUI()
	self:RefreshMoney()
end

function HallMoneyPanel:MyRefresh()
	self:RefreshMoney()
end
function HallMoneyPanel:RefreshMoney()
    self.MoneyText.text = StringHelper.ToRedNum(MainModel.UserInfo.cash / 100)
end

function HallMoneyPanel:OnDrawMoneyClick()
	MainLogic.Withdraw(self:RefreshMoney())
end
