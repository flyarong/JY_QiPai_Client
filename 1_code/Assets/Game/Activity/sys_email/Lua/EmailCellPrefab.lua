-- 创建时间:2018-05-30

local basefunc = require "Game.Common.basefunc"

EmailCellPrefab = basefunc.class()

EmailCellPrefab.name = "EmailCellPrefab"

local colorXZ = "<color=#FFFFFF>"
local colorZC = "<color=#B98109FF>"
local colorEnd = "</color>"
function EmailCellPrefab.Create(parent_transform, emailId, call, panelSelf)
	return EmailCellPrefab.New(parent_transform, emailId, call, panelSelf)
end

function EmailCellPrefab:ctor(parent_transform, emailId, call, panelSelf)
	self.emailId = emailId
	self.call = call
	self.panelSelf = panelSelf
	local obj = newObject("EmailCellPrefab", parent_transform)
	self.gameObject = obj
	
	self.OpenButton = obj.transform:Find("OpenButton"):GetComponent("Button")
	self.OpenImage = obj.transform:Find("OpenButton"):GetComponent("Image")
	self.SelectEmail = obj.transform:Find("SelectEmail"):GetComponent("Image")
	self.StateImage = obj.transform:Find("StateImage"):GetComponent("Image")
	self.TitleText = obj.transform:Find("TitleText"):GetComponent("Text")
	self.TimeText = obj.transform:Find("TimeText"):GetComponent("Text")
	self.RedImage = obj.transform:Find("RedImage").gameObject
	self.RedImage:SetActive(false)
	self.AwardHintImage = obj.transform:Find("AwardHintImage").gameObject
	self.AwardHintImage:SetActive(false)

	self.OpenButton.onClick:AddListener(function ()
		self:OnOpenEmail()
	end)

	self:UpdateEmailState()

	local ise = EmailModel.IsExistAward(self.emailId)
	self.AwardHintImage:SetActive(ise)

	local loseTime = EmailModel.GetLoseTime(self.emailId)
	if loseTime > 0 then
		self.timerUpdate = Timer.New(function ()
			self:UpdateEmailState()
		end, loseTime, 1, false)
    	self.timerUpdate:Start()
	end
end
-- 设置选中
function EmailCellPrefab:SetSelectEmail(b)
	self.SelectEmail.gameObject:SetActive(b)
	local data = EmailModel.Emails[self.emailId]
	if data == nil then return end
	local desc,title = EmailModel.GetEmailDesc(data)
	if b or EmailModel.IsReadState(self.emailId) then
		self.TitleText.text = colorXZ .. title .. colorEnd
		if #title>=24 then
			self.TitleText.text= "<size=32>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.TimeText.text = colorXZ .. EmailModel.GetConvertTime(data.create_time) .. colorEnd		
	else
		self.TitleText.text = colorZC .. title .. colorEnd
		if #title>=24 then
			self.TitleText.text= "<size=32>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.TimeText.text = colorZC .. EmailModel.GetConvertTime(data.create_time) .. colorEnd
	end
	self.OpenImage.gameObject:SetActive(not b)
end
function EmailCellPrefab:UpdateEmailState()
	if not IsEquals(self.gameObject) then return end
	self.EmailState,self.EmailStateName = EmailModel.GetState(self.emailId)
	local data = EmailModel.Emails[self.emailId]
	local desc,title = EmailModel.GetEmailDesc(data)
	
	if EmailModel.IsReadState(self.emailId) then
		self.StateImage.sprite = GetTexture("mail_icon_mail1")
		self.RedImage:SetActive(false)
		self.OpenImage.sprite = GetTexture("task_btn_unselect2")
		self.TitleText.text = colorXZ .. title .. colorEnd
		if #title>=24 then
			self.TitleText.text= "<size=32>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.TimeText.text = colorXZ .. EmailModel.GetConvertTime(data.create_time) .. colorEnd
	else
		self.StateImage.sprite = GetTexture("mail_icon_mail2")
		self.RedImage:SetActive(true)
		self.OpenImage.sprite = GetTexture("task_btn_unselect")
		self.TitleText.text = colorZC .. title .. colorEnd
		if #title>=24 then
			self.TitleText.text= "<size=32>"..colorXZ .. title .. colorEnd.."</size>"
		end
		self.TimeText.text = colorZC .. EmailModel.GetConvertTime(data.create_time) .. colorEnd
	end
end
function EmailCellPrefab:OnOpenEmail()
	self.call(self.panelSelf, self.emailId)
end
function EmailCellPrefab:OnDestroy()
	if self.timerUpdate then
		self.timerUpdate:Stop()
	end
	destroy(self.gameObject)
end


