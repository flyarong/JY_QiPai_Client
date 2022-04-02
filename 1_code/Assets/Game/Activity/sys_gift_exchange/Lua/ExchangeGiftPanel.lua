-- 创建时间:2018-06-06
local basefunc = require "Game.Common.basefunc"

ExchangeGiftPanel = basefunc.class()
ExchangeGiftPanel.name = "ExchangeGiftPanel"

local instance
function ExchangeGiftPanel.Create(parent)
	if not instance then
		instance = ExchangeGiftPanel.New(parent)
	end
	return instance
end

function ExchangeGiftPanel:MyExit()
	self:RemoveListener()
	self:ResetCooldownTimer()
	destroy(self.gameObject)
end

function ExchangeGiftPanel.Close()
	if instance then
		instance:MyExit()
		instance = nil
	end
end

function ExchangeGiftPanel:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function ExchangeGiftPanel:MakeLister()
	self.lister = {}
	self.lister["use_redeem_code_response"] = basefunc.handler(self, self.use_redeem_code_response)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function ExchangeGiftPanel:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
end

function ExchangeGiftPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	self:MakeLister()
	self:AddMsgListener()
	local obj = newObject(ExchangeGiftPanel.name, parent)
	self.transform = obj.transform
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform,self)
	self:InitRect()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function ExchangeGiftPanel:InitRect()
	local transform = self.transform
	
	self.hintTxt = transform:Find("ImgCenter/Hint_txt"):GetComponent("Text")
	self.hintTxt.text = ""

	self.disableBtn = transform:Find("ImgCenter/DisableExchange_btn"):GetComponent("Button")
	self.disableBtn.gameObject:SetActive(true)
	self.enableBtn = transform:Find("ImgCenter/EnableExchange_btn"):GetComponent("Button")
	self.enableBtn.gameObject:SetActive(false)
	self.enableBtn.onClick:AddListener(function ()
		Network.SendRequest("use_redeem_code", {code=self.inputField.text}, "发送兑换请求")
	end)
	self.closeBtn = transform:Find("Close_btn"):GetComponent("Button")
	self.closeBtn.onClick:AddListener(function ()
		ExchangeGiftPanel.Close()
	end)

	local MIN_LENGTH = 6
	local MAX_LENGTH = 10
	self.inputField = transform:Find("ImgCenter/InputField"):GetComponent("InputField")
	--self.inputField.characterLimit = MAX_LENGTH
	self.inputField.onValueChanged:AddListener(function (val)
		if self:IsCooldownLocking() then
			self.inputField.text = ""
			return
		end
		local text = self.inputField.text
		if string.len(text) <= MAX_LENGTH and string.len(text) >= MIN_LENGTH then
			self.disableBtn.gameObject:SetActive(false)
			self.enableBtn.gameObject:SetActive(true)
		else
			self.disableBtn.gameObject:SetActive(true)
			self.enableBtn.gameObject:SetActive(false)
		end
	end)
	self.inputField.onEndEdit:AddListener(function ()
		if not IsEquals(self.gameObject) then return end
		local disable = true
		local text = self.inputField.text
		if text == "" then
			self.hintTxt.text = ""
		else
			if string.len(text) <= MAX_LENGTH and string.len(text) >= MIN_LENGTH then
				self.hintTxt.color = Color.New(237/255, 136/255, 19/255)
				self.hintTxt.text = "提示：兑换码格式正确"
				disable = false
			else
				self.hintTxt.color = Color.New(237/255, 40/255, 19/255)
				self.hintTxt.text = "提示：兑换码格式错误"
			end
		end
		self.disableBtn.gameObject:SetActive(disable)
		self.enableBtn.gameObject:SetActive(not disable)
	end)

	self:CheckCooldownTimer()
end

function ExchangeGiftPanel:use_redeem_code_response(_, result)
	local result_code = result.result
	local result_time = result.time or 0
	self.inputField.text = ""
	self.hintTxt.text = ""
	if result_code ~= 0 then
		HintPanel.ErrorMsg(result_code)
		if result_time > 0 then
			print("time: " .. result_time)
			self:CooldownLocking(result_time)
		end
	else
		print("exchange ok")
	end
end

function ExchangeGiftPanel:OnExitScene()
	ExchangeGiftPanel.Close()
end

function ExchangeGiftPanel:GetCooldownKey()
	local CooldownTime = "EGP_COOLDOWN_"
	local userInfo = MainModel.UserInfo or {}
	local user_id = userInfo.user_id or 0
	return CooldownTime .. user_id
end

function ExchangeGiftPanel:IsCooldownLocking()
	return self.cooldownTimer ~= nil
end

function ExchangeGiftPanel:CooldownLocking(second)
	local CooldownTime = self:GetCooldownKey()

	local current_time = os.time()
	local expired_time = current_time + second
	PlayerPrefs.SetInt(CooldownTime, expired_time)

	self:ResetCooldownTimer()
	self.cooldownSecond = second
	self.cooldownTimer = Timer.New(function ()
		self.cooldownSecond = self.cooldownSecond - 1
		if self.cooldownSecond <= 0 then
			self:ResetCooldownTimer()

			self.hintTxt.text = ""
			PlayerPrefs.DeleteKey(CooldownTime)
		else
			local stamp = os.date("!*t", self.cooldownSecond)
			self.hintTxt.color = Color.New(237/255, 40/255, 19/255)
			self.hintTxt.text = string.format("提示：连续输入错误次数已达上限，请稍后 ( %02d:%02d:%02d )", stamp.hour, stamp.min, stamp.sec)
		end
	end, 1, -1)
	self.cooldownTimer:Start()
end

function ExchangeGiftPanel:CheckCooldownTimer()
	local CooldownTime = self:GetCooldownKey()
	if not PlayerPrefs.HasKey(CooldownTime) then
		return
	end

	local expired_time = PlayerPrefs.GetInt(CooldownTime)
	local second = expired_time - os.time()
	if second > 1 then
		self:CooldownLocking(second)
	else
		self:ResetCooldownTimer()
		PlayerPrefs.DeleteKey(CooldownTime)
	end

end

function ExchangeGiftPanel:ResetCooldownTimer()
	if self.cooldownTimer then
		self.cooldownTimer:Stop()
		self.cooldownTimer = nil
	end
	self.cooldownSecond = 0
end
