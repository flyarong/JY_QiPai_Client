--ganshuangfeng 绑定手机Panel
--2018-05-09
local basefunc = require "Game.Common.basefunc"

BindingPhonePanel = basefunc.class()

BindingPhonePanel.name = "BindingPhonePanel"

local instance
function BindingPhonePanel.Create(parent,tips,binding_callback)
    -- 换成有奖绑定，以前的UI没有改，新加的
    if true then
        instance = GameManager.GotoUI({gotoui = "sys_binding_phone_award",goto_scene_parm = "panel",parent = parent,tips = tips,binding_callback = binding_callback})
        return instance
    end

    instance = BindingPhonePanel.New(parent,tips,binding_callback)
    return instance
end
function BindingPhonePanel:ctor(parent,tips,binding_callback)

	ExtPanel.ExtMsg(self)

    self.binding_callback = binding_callback
    parent = GameObject.Find("Canvas/LayerLv5").transform
    local obj = newObject(BindingPhonePanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    self.tips_txt.text = tips or ""

    self.phone_ipf = self.phone_ipf.transform:GetComponent("InputField")
    self.code_ipf = self.code_ipf.transform:GetComponent("InputField")
    self.phone_ipf.onValueChanged:AddListener(function (val)
    end)
    self.code_ipf.onValueChanged:AddListener(function (val)
    end)
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClick)
    EventTriggerListener.Get(self.get_verification_code_btn.gameObject).onClick = basefunc.handler(self, self.OnClickGetVerificationCode)
    EventTriggerListener.Get(self.sure_binding_btn.gameObject).onClick = basefunc.handler(self, self.OnClickSureBinding)

    Network.SendRequest("query_bind_phone", nil, "请求绑定手机", function (data)
        dump(data, "<color=green>query_bind_phone</color>")
        if data.result == 0 then
            self.Phone = data.phone_no
            self.wait_time = data.cd
            self:InitUI()
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end

function BindingPhonePanel:InitUI()
    self:SetWaitTime()
end
function BindingPhonePanel:Update()
    if self.wait_time then
        self.wait_time = self.wait_time - 1
        if self.wait_time <= 0 then
            self.wait_time = nil
        end
        self:SetDJS()
    end
end
function BindingPhonePanel:SetWaitTime()
    if self.updateTimer then
        self.updateTimer:Stop()
    end
    if self.wait_time and self.wait_time > 0 then
        self.updateTimer = Timer.New(basefunc.handler(self,self.Update), 1, -1, true)
        self.updateTimer:Start()
        self.wait_verification.gameObject:SetActive(true)
        self:SetDJS()
    else
        if IsEquals(self.wait_verification) then
            self.wait_verification.gameObject:SetActive(false)
        end
    end
end
function BindingPhonePanel:SetDJS()
    if self.wait_time then
        self.ImgGetCode_txt.text = self.wait_time .. "(s)"
    else
        self:SetWaitTime()
    end
end

--[[退出玩家中心，返回到大厅 ]]
function BindingPhonePanel:OnCloseClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    self:CallCloseClick()
end

function BindingPhonePanel:MyExit()
    if self.updateTimer then
        self.updateTimer:Stop()
    end
    self.wait_time = nil
    self.binding_callback = nil
    destroy(self.gameObject)
end
function BindingPhonePanel:CallCloseClick()
    self:MyExit()
end

--[[获取验证码]]
function BindingPhonePanel:OnClickGetVerificationCode(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local phong_number = self.phone_ipf.text
    if not phong_number or phong_number == "" then
        HintPanel.Create(1, "手机号码不能为空")
        return
    end
    local cnt = string.utf8len(phong_number)
    print("<color=red>cnt == " .. cnt .. "</color>")
    if cnt ~= 11 then
        HintPanel.Create(1, "输入的手机号码格式错误")
        return
    end
    Network.SendRequest("send_bind_phone_verify_code", {phone_no=phong_number}, "获取验证码" , function (data)
        if data.result == 0 then
            self.wait_time = data.cd
            self:SetWaitTime()
        elseif data.result == 2406 then
            HintPanel.Create(2,"手机号码错误")
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end

--[[确认绑定]]
function BindingPhonePanel:OnClickSureBinding(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    local phong_number = self.phone_ipf.text
    if not phong_number or phong_number == "" then
        HintPanel.Create(1, "手机号码不能为空")
        return
    end
    local cnt = string.utf8len(phong_number)
    print("<color=red>cnt == " .. cnt .. "</color>")
    if cnt ~= 11 then
        HintPanel.Create(1, "输入的手机号码格式错误")
        return
    end

    if not self.code_ipf.text or self.code_ipf.text == "" then
        HintPanel.Create(1, "输入的验证码格式错误")
        return
    end

    Network.SendRequest("verify_bind_phone_code", {code=self.code_ipf.text}, "发送请求" , function (data)
        if data.result == 0 then
            MainModel.SetBindPhone(phong_number)
            Event.Brocast("update_query_bind_phone")
            if self.binding_callback then self.binding_callback() end
            --提现次数不足
            LittleTips.Create(string.format( "已绑定手机：%s",phong_number ))
            self:CallCloseClick()
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end

