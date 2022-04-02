-- 创建时间:2018-05-30

local basefunc = require "Game.Common.basefunc"

EmailPanel = basefunc.class()
local C = EmailPanel
EmailPanel.name = "EmailPanel"

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["model_set_email_state_change"] = basefunc.handler(self, self.UpdateEmailState)
    self.lister["model_add_email_data"] = basefunc.handler(self, self.AddEmail)
    self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function EmailPanel.Create()
	return EmailPanel.New()
end
function EmailPanel:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(EmailPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self:MakeLister()
	self:AddMsgListener()

	self.BackButton = self.transform:Find("BackButton"):GetComponent("Button")
	self.GetAllButton = self.transform:Find("LeftBG/GetAllButton"):GetComponent("Button")
	self.GetAllNo = self.transform:Find("LeftBG/GetAllNo").gameObject
	self.LeftRoot = self.transform:Find("LeftBG/ScrollView/Viewport/Content")


	self.RightRoot = self.transform:Find("RightBG/Email/BG/ScrollView/Viewport/Content")
	self.EmailNode = self.transform:Find("RightBG/Email").gameObject
	self.EmailNullNode = self.transform:Find("RightBG/EmailNull").gameObject
	self.GetButton = self.transform:Find("RightBG/Email/GetButton"):GetComponent("Button")
	self.GetNo = self.transform:Find("RightBG/Email/GetNo").gameObject
	self.DeleteButton = self.transform:Find("RightBG/Email/DeleteButton"):GetComponent("Button")
	self.DeleteNo = self.transform:Find("RightBG/Email/DeleteNo").gameObject
	self.TitleText = self.transform:Find("RightBG/Email/TitleText"):GetComponent("Text")
	self.SenderText = self.transform:Find("RightBG/Email/SenderText"):GetComponent("Text")
	self.DescScrollView = self.transform:Find("RightBG/Email/BG/ScrollView"):GetComponent("ScrollRect")
	self.DescText = self.transform:Find("RightBG/Email/BG/ScrollView/Viewport/Content/DescText"):GetComponent("Text")
	-- self.AwardPrefab = self.transform:Find("RightBG/Email/BG/ScrollView/Viewport/Content/BG2/AwardPrefab")
	self.AwardPrefab = self.transform:Find("RightBG/Email/BG/ScrollView/Viewport/Content/ScrollView2/Viewport2/Content2/AwardPrefab")
	self.AwardNode = self.AwardPrefab.parent
	
	self.BackButton.onClick:AddListener(function ()
		self:OnBackClick()
	end)
	self.GetAllButton.onClick:AddListener(function ()
		self:OnGetAllClick()
	end)
	self.GetButton.onClick:AddListener(function ()
		self:OnGetClick()
	end)
	self.DeleteButton.onClick:AddListener(function ()
		self:OnDeleteClick()
	end)

	self.CellList = {}
	self.AwardCellList = {}
	self.currEmailId = nil
	self.EmailShowList = {}
	self:SortEmailList()

	self:UpdateUI()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function EmailPanel:SortEmailList()
	self.EmailShowList = {}
	local eList = {}
	local aList = {}
	local bList = {}

	for i,v in ipairs(EmailModel.EmailIDs) do
		local data = EmailModel.Emails[v]
		local buf = {}
		buf.id = v
		buf.ctime = data.create_time
		eList[#eList + 1] = buf
	end
	for i = 1, #eList - 1 do
		local k = i
		for j = i + 1, #eList do
			if eList[k].ctime and eList[j].ctime and eList[k].ctime < eList[j].ctime then
				k = j
			end
		end
		if k ~= i then
			eList[i],eList[k] = eList[k],eList[i]
		end
	end

	for i,v in ipairs(eList) do
		local state,_ = EmailModel.GetState(v.id)
		if state == EmailModel.EmailState.UnRead then
			aList[#aList + 1] = v.id
		else
			bList[#bList + 1] = v.id
		end
	end
	for i,v in ipairs(aList) do
		self.EmailShowList[#self.EmailShowList + 1] = v
	end
	for i,v in ipairs(bList) do
		self.EmailShowList[#self.EmailShowList + 1] = v
	end
end

function EmailPanel:Exit()
	self:CloseCell()
	self:CloseAwardCell()
	self:RemoveListener()
	Event.Brocast("sys_023_exxsyd_panel_close")
	destroy(self.gameObject)
end
function EmailPanel:MyExit()
	self:Exit()
end
-- 刷新UI
function EmailPanel:UpdateUI()
	print("<color=red>邮件数量N = " .. #self.EmailShowList .. "</color>")
	if #self.EmailShowList > 0 then
		self:UpdateUILeft()
	else
		self:CloseCell()
	end
	self:EmailChangeUpdate()
end

-- 刷新UI左边
function EmailPanel:UpdateUILeft()
	self:CloseCell()
	for _,v in ipairs(self.EmailShowList) do
		local cell = EmailCellPrefab.Create(self.LeftRoot, v, EmailPanel.OnOpenEmail, self)
		self.CellList[v] = cell
	end
	if #self.EmailShowList > 0 then
		self.CellList[self.EmailShowList[1]]:OnOpenEmail()
	end
end

-- 刷新UI右边
function EmailPanel:UpdateUIRight()
	if not IsEquals(self.gameObject) then return end
	local EmailState, EmailStateName = EmailModel.GetState(self.currEmailId)
	local emailData = EmailModel.Emails[self.currEmailId]

	self:CloseAwardCell()
	if EmailModel.IsExistAward(self.currEmailId) then
		local awardTab = AwardManager.GetAwardTable(emailData.data)
		for i,v in ipairs(awardTab) do
			self:CreateAwardCell(v)
		end
	end

	if EmailState == EmailModel.EmailState.UnRead then
		self.DeleteButton.gameObject:SetActive(false)
		self.DeleteNo.gameObject:SetActive(false)
		self.GetButton.gameObject:SetActive(true)
		self.GetNo.gameObject:SetActive(false)
	else
		self.DeleteButton.gameObject:SetActive(true)
		self.DeleteNo.gameObject:SetActive(false)
		self.GetButton.gameObject:SetActive(false)
		self.GetNo.gameObject:SetActive(false)
	end

	local desc,title = EmailModel.GetEmailDesc(emailData)
	self.TitleText.text = title
	self.DescText.text = desc
	self.SenderText.text = emailData.sender

	self.RightRoot.localPosition = Vector3.zero
	-- self.DescText.preferredHeight

	self.DescScrollView.onValueChanged:AddListener(function (v)end)
end

-- 邮件内容有改变
function EmailPanel:EmailChangeUpdate()
	if not IsEquals(self.gameObject) then return end
	if #self.EmailShowList <= 0 then
		self.EmailNode:SetActive(false)
		self.EmailNullNode:SetActive(true)
		self.GetAllNo:SetActive(true)
	else
		self.EmailNode:SetActive(true)
		self.EmailNullNode:SetActive(false)
	end

	if EmailModel.IsEmailsGet() then
		self.GetAllNo:SetActive(false)
		self.GetAllButton.gameObject:SetActive(true)
	else
		self.GetAllNo:SetActive(true)
		self.GetAllButton.gameObject:SetActive(false)
	end
end

-- 创建奖励Cell
function EmailPanel:CreateAwardCell(data)
	if not IsEquals(self.AwardPrefab) and IsEquals(self.transform) then
		self.AwardPrefab = self.transform:Find("RightBG/Email/BG/ScrollView/Viewport/Content/ScrollView2/Viewport2/Content2/AwardPrefab")
	end
	if not IsEquals(self.AwardPrefab) then return end
	local obj = GameObject.Instantiate(self.AwardPrefab)
	obj.transform:SetParent(self.AwardNode)
	obj.transform.localPosition = Vector3.New(-356 + #self.AwardCellList * 180, 0, 0)
	obj.transform.localScale = Vector3.one
	self.AwardCellList[#self.AwardCellList + 1] = obj.gameObject
	obj.transform:Find("NumberText"):GetComponent("Text").text = "X" .. StringHelper.ToCash(data.number)
	local img = obj.transform:Find("ImageBG/AwardIcon"):GetComponent("Image")
	GetTextureExtend(img, data.image, data.is_local_icon)
	--img:SetNativeSize()
	obj.gameObject:SetActive(true)
end

-- 新增邮件
function EmailPanel:AddEmail(emailId)
	if self.CellList[emailId] then
		self:UpdateUI()
		return
	end
	local upIndex
	if #self.EmailShowList > 0 then
		if IsEquals(self.CellList[self.EmailShowList[1]]) then
			upIndex = self.CellList[self.EmailShowList[1]].gameObject.transform:GetSiblingIndex()
		end
	end
	local cell = EmailCellPrefab.Create(self.LeftRoot, emailId, EmailPanel.OnOpenEmail, self)
	self.CellList[emailId] = cell

	local bufList = {}
	bufList[#bufList + 1] = emailId
	for i,v in ipairs(self.EmailShowList) do
		bufList[#bufList + 1] = v
	end
	self.EmailShowList = bufList

	self:EmailChangeUpdate()
	if upIndex then
		cell.gameObject.transform:SetSiblingIndex(upIndex)
	else
		self:OnOpenEmail(emailId)
	end
end

-- 打开邮件
function EmailPanel:OnOpenEmail(emailId)
	print("打开emailId = " .. emailId)
	local EmailState,EmailStateName = EmailModel.GetState(emailId)
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if EmailState == EmailModel.EmailState.UnRead and not EmailModel.IsExistAward(emailId) then
		EmailModel.SendReadEmail(emailId, function ()
			self:CallOpenEmail(emailId)
		end)
	else
		self:CallOpenEmail(emailId)
	end
end
-- 
function EmailPanel:CallOpenEmail(emailId)
	-- if self.currEmailId and self.currEmailId == emailId then
	-- 	return
	-- end
	if self.currEmailId then
		self.CellList[self.currEmailId]:SetSelectEmail(false)
	end
	self.currEmailId = emailId
	self.CellList[self.currEmailId]:SetSelectEmail(true)

	self:UpdateUIRight()
end

-- 刷新邮件状态
function EmailPanel:UpdateEmailState(emailId)
	if emailId == self.currEmailId then
		self:UpdateUIRight()
	end
	self.CellList[emailId]:UpdateEmailState()	
end
function EmailPanel:CloseAwardCell()
	for i,v in ipairs(self.AwardCellList) do
		destroy(v)
	end
	self.AwardCellList = {}
end
function EmailPanel:CloseCell()
	for _,v in pairs(self.CellList) do
		v:OnDestroy()
	end
	self.CellList = {}
end

function EmailPanel:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    EmailLogic.ClosePanel()
    self:Exit()
end
function EmailPanel:OnGetAllClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	print("<color=red>一键领取 ****** </color>")
	EmailModel.SendGetAllEmail(function ()
		if not IsEquals(self.gameObject) then return end
		self.GetAllNo:SetActive(true)
		self.GetAllButton.gameObject:SetActive(false)

		self:UpdateUI()
	end)
end
function EmailPanel:OnGetClick()
	if not self.currEmailId then
		return
	end
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	if EmailModel.IsExistAward(self.currEmailId) then
		EmailModel.SendGetEmail(self.currEmailId, function ()
			self:EmailChangeUpdate()
		end)
	end
end
function EmailPanel:OnDeleteClick()
	if not self.currEmailId then
		print("<color=red>OnDeleteClick ****** </color>")
		return
	end
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	EmailModel.SendDeleteEmail(self.currEmailId, function ()
		self:DeleteEmail()
	end)
end
function EmailPanel:DeleteEmail()
	if self.CellList then
		if self.CellList[self.currEmailId] then
			self.CellList[self.currEmailId]:OnDestroy()
		end
		self.CellList[self.currEmailId] = nil
	end
	
	local delI = 1
    local bufList = {}
    for i,v in ipairs(self.EmailShowList) do
        if v ~= self.currEmailId then
            bufList[#bufList + 1] = v
        else
			delI = i
        end
    end
    self.EmailShowList = bufList
	self.currEmailId = nil
	if #self.EmailShowList <= 0 then
		self:UpdateUI()
	else
		local emailId
		-- 删除后看上一个邮件，没有就看下一个
		if (delI - 1) >= 1 then
			emailId = self.EmailShowList[delI - 1]
		else
			emailId = self.EmailShowList[delI]
		end
		self:OnOpenEmail(emailId)
	end
end


