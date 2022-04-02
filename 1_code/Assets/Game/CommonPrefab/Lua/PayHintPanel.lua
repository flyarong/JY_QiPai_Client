-- 创建时间:2018-11-09

local basefunc = require "Game.Common.basefunc"

PayHintPanel = basefunc.class()
PayHintPanel.name = "PayHintPanel"

function PayHintPanel.Create(parent, config_pay, config_change, call)
    return PayHintPanel.New(parent, config_pay, config_change, call)
end

function PayHintPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function PayHintPanel:MakeLister()
    self.lister = {}
end

function PayHintPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function PayHintPanel:ctor(parent, config_pay, config_change, call)

	ExtPanel.ExtMsg(self)

	local obj = newObject(PayHintPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.config_pay = config_pay
	self.config_change = config_change
	self.call = call

	self:MakeLister()
	self:AddMsgListener()

    LuaHelper.GeneratingVar(self.transform, self)

    self.confirm_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:OnConfirmClick()
        end
    )
    self.close_btn.onClick:AddListener(
        function()
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            self:Close()
        end
    )

    local a = self.config_pay.buy_asset_count[1]
    local b = self.config_change.jing_bi
    local c = a - self.config_change.use_count

    if c > 0 then
        self.hint_info_txt.text = "剩余钻石不足，即将购买" .. a .. "钻石，并兑换为" .. b .. "鲸币，剩余" .. c .. "钻石将进入账户"
    else
        self.hint_info_txt.text = "剩余钻石不足，即将购买" .. a .. "钻石，并兑换为" .. b .. "鲸币"
    end
	self.pay_txt.text = "" .. a
end

function PayHintPanel:MyExit()
    destroy(self.gameObject)
    self:RemoveListener()
end
function PayHintPanel:Close()
    self:MyExit()
end

function PayHintPanel:OnConfirmClick()
	if self.call then
		self.call()
	end
	self:Close()
end