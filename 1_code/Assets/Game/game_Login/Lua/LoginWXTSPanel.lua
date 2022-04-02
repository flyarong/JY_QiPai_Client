-- 创建时间:2021-01-05
-- Panel:LoginWXTSPanel
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

LoginWXTSPanel = basefunc.class()
local C = LoginWXTSPanel
C.name = "LoginWXTSPanel"

function C.Create(data, binding_callback)
	return C.New(data, binding_callback)
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
    if self.updateTimer then
        self.updateTimer:Stop()
    end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(data, binding_callback)
	self.binding_callback = binding_callback
	self.data = data
	
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
	self.close_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:MyExit()
	end)
	self.yes_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnYesClick()
	end)
	self.close_btn.gameObject:SetActive(false)

	-- 添加手动绑定功能
    self.phone_ipf = self.phone_ipf.transform:GetComponent("InputField")
    self.code_ipf = self.code_ipf.transform:GetComponent("InputField")
	self.get_verification_code_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnClickGetVerificationCode()
	end)

	self:MyRefresh()
end

function C:MyRefresh()
	table.sort( self.data, function (v1, v2)
		if v1.vip_level <= v2.vip_level then
			return false
		else
			return true
		end
	end )

	self.CellList = {}
	for k,v in ipairs(self.data) do
		local pre = LoginWXTSPrefab.Create(self.Content, v, self.OnSelectClick, self, k)
		self.CellList[#self.CellList + 1] = pre
	end
	
	self.select_index = 1
	self:RefreshSelect()
end

function C:RefreshSelect()
	for k,v in ipairs(self.CellList) do
		if k == self.select_index then
			v:SetSelect(true)
		else
			v:SetSelect(false)
		end
	end
	if self.select_index and self.data[self.select_index] then
		self.phone_ipf.text = self.data[self.select_index].login_id
	end
end

function C:OnSelectClick(index)
	self.select_index = index
	self:RefreshSelect()
end

function C:OnYesClick()
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

	local desc = "确定要绑定手机号: "..phong_number.." 吗？"
	HintPanel.Create(2, desc, function ()
		self.binding_callback({channel_type="phone", login_id=phong_number, code=self.code_ipf.text})		
	end)
end

----------------------------------
-- 手动绑定手机号
----------------------------------
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
        self.wait_btn.gameObject:SetActive(true)
        self:SetDJS()
    else
        if IsEquals(self.wait_btn) then
            self.wait_btn.gameObject:SetActive(false)
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

--[[获取验证码]]
function C:OnClickGetVerificationCode(go)
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
    Network.SendRequest("send_sms_vcode", {phone_number=phong_number, platform=gameMgr:getMarketPlatform()}, "获取验证码" , function (data)
        if data.result == 0 then
            self.wait_time = 60
            self:SetWaitTime()
        elseif data.result == 2406 then
            HintPanel.Create(2,"手机号码错误")
        else
            HintPanel.ErrorMsg(data.result)
        end
    end)
end