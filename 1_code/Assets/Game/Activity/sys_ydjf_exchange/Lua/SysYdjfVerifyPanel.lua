-- 创建时间:2021-04-30
-- Panel:SysYdjfVerifyPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

SysYdjfVerifyPanel = basefunc.class()
local C = SysYdjfVerifyPanel
local M = SysYdJfExchangeManager
C.name = "SysYdjfVerifyPanel"

local phone_num_len = 11		--手机号码限制长度
local vrf_num_len = 4			--验证码限制长度

exchange_errors = {
	[1008] = "重复提交",
	[1001] = "参数错误",
	[1004] = "请先获取验证码..",
	[2602] = "请稍后再试..",
	[1060] = "验证码错误..",
	[2001] = "没有可兑换的积分..",
}

sms_errors = {
	[1008] = "重复提交",
	[1009] = "参数错误",
	[1010] = "请稍后再试..",
}

function C.Create()
	return C.New()
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
	if self.timer_djs then
		self.timer_djs:Stop()
		self.timer_djs = nil
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

function C:ctor()
	ExtPanel.ExtMsg(self)
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
	self.phoneInput = self.phone_InputField:GetComponent("InputField")
	self.vrfInput = self.vrf_InputField:GetComponent("InputField")
	self.phoneInput.characterLimit = phone_num_len
	self.vrfInput.characterLimit = vrf_num_len
	self.back_btn.onClick:AddListener(function()
		self:MyExit()
	end)
	self.get_verify_btn.onClick:AddListener(function()
		self:OnClickGetVerifyBtn()
	end)
	self.comfirm_btn.onClick:AddListener(function()
		self:OnClickComfirmBtn()
	end)
	self:RefreshGetVerify()
	self:MyRefresh()
end

--获取验证码
function C:OnClickGetVerifyBtn()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local phone_number = self:CheckIphoneTxtFormat()
	if not phone_number then
		return
	end
	Network.SendRequest("chinamobile_send_sms_vcode",{phone_no = phone_number},"获取验证码..",function(data)
		if data.result == 0 then
			LittleTips.Create("验证码发送成功")
		else
			if sms_errors[data.result] then
				HintPanel.Create(1, sms_errors[data.result])
			else
				HintPanel.ErrorMsg(data.result)
			end
			M.ClearLastVerifyTime()
		end
	end)
	M.SetLastVerifyTime()
	self:RefreshGetVerify()
end

--确认并领取
function C:OnClickComfirmBtn()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local phone_number = self:CheckIphoneTxtFormat()
	local vrf_number = self:CheckVrfTxtFormat()
	if not phone_number or not vrf_number then
		return
	end
	Network.SendRequest("chinamobile_exchange",{phone_no = phone_number,sms_vcode = vrf_number},"兑换..",function(data)
		dump(data, "<color=white>chinamobile_exchange</color>")
		if data.result == 0 then
			LittleTips.Create("兑换成功")
			self:ClearInputTxt()
		else
			if exchange_errors[data.result] then
				HintPanel.Create(1,exchange_errors[data.result])
			else
				HintPanel.ErrorMsg(data.result)
			end
		end
	end)
end

function C:CheckIphoneTxtFormat()
    local phone_number = self.phone_txt.text
    if not phone_number or phone_number == "" then
        HintPanel.Create(1, "手机号码不能为空")
        return false
    end

    if string.utf8len(phone_number) ~= phone_num_len then
        HintPanel.Create(1, "输入的手机号码格式错误")
        return false
    end
	return tonumber(phone_number)
end

function C:CheckVrfTxtFormat()
	local vrf_number = self.vrf_txt.text
	if not vrf_number or vrf_number == "" then
		HintPanel.Create(1, "验证码不能为空")
        return false
	end
	if string.utf8len(vrf_number) ~= vrf_num_len then
        HintPanel.Create(1, "输入的验证码格式错误")
        return false
    end
	return tonumber(vrf_number)
end

function C:ClearInputTxt()
	self.phone_txt.text = ""
	self.vrf_txt.text = ""
end


function C:RefreshGetVerify()
	if M.IsInVerifyCd() then
		self:ViewDjs()
	else
		self:ViewVeriftGetBtn()
	end
end

--显示获取验证码的冷却倒计时
function C:ViewDjs()
	self.get_verify_btn.gameObject:SetActive(false)
	self.cd_txt.gameObject:SetActive(true)
	local refresh_djs_txt = function()
		self.cd_txt.text = 	"(" .. M.GetVerifyCdNum() .. "s)后可重新获取"	
	end
	self.timer_djs = Timer.New(function()
		if not M.IsInVerifyCd() then
			self:RefreshGetVerify()
		else
			refresh_djs_txt()
		end
	end,1,-1)
	refresh_djs_txt()
	self.timer_djs:Start()
end
--显示获取验证码的按钮
function C:ViewVeriftGetBtn()
	self.cd_txt.gameObject:SetActive(false)
	self.get_verify_btn.gameObject:SetActive(true)
	if self.timer_djs then
		self.timer_djs:Stop()
		self.timer_djs = nil
	end
end

function C:MyRefresh()

end