local basefunc = require "Game/Common/basefunc"

AwardBindingZFBPanel = basefunc.class()
local C = AwardBindingZFBPanel
C.name = "AwardBindingZFBPanel"

function C.Create(binding_callback)
	return C.New(binding_callback)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(binding_callback)

	ExtPanel.ExtMsg(self)

    self.binding_callback = binding_callback
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
    self.name_ipf = self.name_ipf.transform:GetComponent("InputField")
    self.user_ipf = self.user_ipf.transform:GetComponent("InputField")
    self.name_ipf.onValueChanged:AddListener(function (val)
    end)
    self.user_ipf.onValueChanged:AddListener(function (val)
    end)
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClick)
    EventTriggerListener.Get(self.binding_btn.gameObject).onClick = basefunc.handler(self, self.OnClickSureBinding)
    EventTriggerListener.Get(self.hint_btn.gameObject).onClick = basefunc.handler(self, self.OnOpenHintClick)
    
	self:MyRefresh()

    --self:OnOpenHintClick()
end

function C:MyRefresh()
    MainModel.GetBindZFB(function(  )
        if IsEquals(self.gameObject) then
            if MainModel.UserInfo.zfbData then
                self.name_ipf.text = MainModel.UserInfo.zfbData.name
                self.user_ipf.text = MainModel.UserInfo.zfbData.account
            end
        end
    end)
end

function C:OnCloseClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    self:CallCloseClick()
end
function C:CallCloseClick()
    self.binding_callback = nil
    GameObject.Destroy(self.gameObject)
end

--[[确认绑定]]
function C:OnClickSureBinding(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local zfb_name = self.name_ipf.text
    if not zfb_name or zfb_name == "" or type(tonumber(zfb_name)) == "number" then
        LittleTips.Create("请输入您的支付宝姓名,不能是纯数字")
        return
    end
    local account = self.user_ipf.text
    if not account or account == "" then
        LittleTips.Create("请输入您的支付宝账号,格式为邮箱或手机号码")
        return
    end
    local zfb_data = {name = zfb_name, account = account}
    Network.SendRequest("set_alipay_data",zfb_data , "发送请求" , function (data)
        if data.result == 0 then
            MainModel.SetBindZFB({name = data.name, account = data.account})
            LittleTips.Create(string.format( "支付宝账号：%s 绑定成功",account))
            if self.binding_callback then self.binding_callback() end
            Event.Brocast("update_query_bind_zfb")
            self:CallCloseClick()
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end

function C:OnOpenHintClick()
    BindingZFBHintPanel.Create(self.transform)
end
