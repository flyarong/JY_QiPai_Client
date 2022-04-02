-- 创建时间:2019-07-25
-- Panel:AwardC
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

AwardBindingPhonePanel = basefunc.class()
local C = AwardBindingPhonePanel
C.name = "AwardBindingPhonePanel"

function C.Create(parent,tips,binding_callback)
	return C.New(parent,tips,binding_callback)
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

function C:ctor(parent,tips,binding_callback)

	ExtPanel.ExtMsg(self)

    self.tips = tips
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
    self.tips_txt.text = self.tips or "*绑定后可大幅提高帐号安全"

    self.phone_ipf = self.phone_ipf.transform:GetComponent("InputField")
    self.code_ipf = self.code_ipf.transform:GetComponent("InputField")
    self.phone_ipf.onValueChanged:AddListener(function (val)
    end)
    self.code_ipf.onValueChanged:AddListener(function (val)
    end)
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnCloseClick)
    EventTriggerListener.Get(self.get_verification_code_btn.gameObject).onClick = basefunc.handler(self, self.OnClickGetVerificationCode)
    EventTriggerListener.Get(self.sure_binding_btn.gameObject).onClick = basefunc.handler(self, self.OnClickSureBinding)

    self.PhoneAward = {}
    self.PhoneAward[#self.PhoneAward + 1] = {obj=self.PhoneAward1}
    self.PhoneAward[#self.PhoneAward + 1] = {obj=self.PhoneAward2}
    self.PhoneAward[#self.PhoneAward + 1] = {obj=self.PhoneAward3}
    for i=1, #self.PhoneAward do
        local icon = self.PhoneAward[i].obj:Find("AwardImage"):GetComponent("Image")
        local txt = self.PhoneAward[i].obj:Find("AwardText"):GetComponent("Text")
        self.PhoneAward[i].icon = icon
        self.PhoneAward[i].txt = txt
    end
    self.award_cfg = SysBindingPhoneAwardManager.config
	self:MyRefresh()

    -- 隐藏鱼币
    self.PhoneAward[2].obj.gameObject:SetActive(false)
    self.PhoneAward[3].obj.localPosition = Vector3.New(146, 4.66, 0)
end

function C:MyRefresh()
	self:SetWaitTime()
    self:RefreshAward()
end

function C:Update()
    if self.wait_time then
        self.wait_time = self.wait_time - 1
        if self.wait_time <= 0 then
            self.wait_time = nil
        end
        self:SetDJS()
    end
end
function C:SetWaitTime()
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
function C:SetDJS()
    if self.wait_time then
        self.ImgGetCode_txt.text = self.wait_time .. "(s)"
    else
        self:SetWaitTime()
    end
end

--[[退出玩家中心，返回到大厅 ]]
function C:OnCloseClick(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    self:CallCloseClick()
end
function C:CallCloseClick()
    if self.updateTimer then
        self.updateTimer:Stop()
    end
    self.wait_time = nil
    self.binding_callback = nil
    GameObject.Destroy(self.gameObject)
end

--[[获取验证码]]
function C:OnClickGetVerificationCode(go)
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
function C:OnClickSureBinding(go)
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
            RedHintManager.UpdateRedHint(RedHintManager.RedHintKey.RHK_PhoneAward)
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end

function C:RefreshAward()
    for i = 1, 3 do
        if i <= #self.award_cfg then
            self.PhoneAward[i].obj.gameObject:SetActive(true)
            self.PhoneAward[i].icon.sprite = GetTexture(self.award_cfg[i].icon)
            self.PhoneAward[i].txt.text = self.award_cfg[i].desc
        else
            self.PhoneAward[i].obj.gameObject:SetActive(false)
        end
    end
end