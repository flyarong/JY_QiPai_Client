-- 创建时间:2018-11-09

local basefunc = require "Game.Common.basefunc"

HallDressTXPanel = basefunc.class()

HallDressTXPanel.name = "HallDressTXPanel"


local instance
function HallDressTXPanel.Create(parent)
	instance = HallDressTXPanel.New(parent)
	return instance
end

function HallDressTXPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallDressTXPanel:MakeLister()
    self.lister = {}
    self.lister["model_dress_data"] = basefunc.handler(self, self.model_dress_data)
    self.lister["dressed_head_frame_response"] = basefunc.handler(self, self.dressed_head_frame_response)
end

function HallDressTXPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function HallDressTXPanel:MyClose()
	self:ClearCellList()
	self:MyExit()
end

function HallDressTXPanel:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)	 
end

function HallDressTXPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(HallDressTXPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.Cell = tran:Find("Cell")
	self.Content = tran:Find("ScrollView/Viewport/Content")
	self.ShowRect = tran:Find("ShowRect")
	self.HeadIcon = tran:Find("ShowRect/HeadIcon"):GetComponent("Image")
	self.HeadFrame = tran:Find("ShowRect/HeadFrame"):GetComponent("Image")
	self.FrameName = tran:Find("ShowRect/FrameName"):GetComponent("Text")
	self.LockText1 = tran:Find("ShowRect/LockBG1/Text"):GetComponent("Text")
	self.LockText2 = tran:Find("ShowRect/LockBG2/Text"):GetComponent("Text")
	self.DressButton = tran:Find("ShowRect/DressButton"):GetComponent("Button")
	self.NoDress = tran:Find("ShowRect/NoDress")
	self.NoDressText = tran:Find("ShowRect/NoDress/Text"):GetComponent("Text")
	self.DressButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnDressClick()
    end)

	PersonalInfoManager.ReqDressData()
end

function HallDressTXPanel:model_dress_data()
	self.data = PersonalInfoManager.GetHeadData()
	self:InitUI()
end

function HallDressTXPanel:InitUI()
	URLImageManager.UpdateHeadImage(MainModel.UserInfo.head_image, self.HeadIcon)
	self:UpdateUILeft()
	for k,v in ipairs(self.data) do
		if v.item_id == PersonalInfoManager.GetSelfHeadID() then
			self:SetSelectHead(k)
			break
		end
	end
end

function HallDressTXPanel:MyRefresh()
end

function HallDressTXPanel:UpdateUILeft()
	self:ClearCellList()
	for k,v in ipairs(self.data) do
		local obj = self:CreateItem(k)
		self.CellList[#self.CellList + 1] = obj
	end
end
-- 创建入口Item
function HallDressTXPanel:CreateItem(i)
	local data = self.data[i]
	local go = GameObject.Instantiate(self.Cell, self.Content)
	local tran = go.transform
	go.name = i
	go.gameObject:SetActive(true)

	local Icon = tran:Find("IconButton"):GetComponent("Image")
	local HintText = tran:Find("HintText"):GetComponent("Text")
	local Lock = tran:Find("Lock")
	local HiImage = tran:Find("HiImage")
	HiImage.gameObject:SetActive(false)
	Icon.sprite = GetTexture(data.icon)

	local IconButton = tran:Find("IconButton"):GetComponent("Button")
	IconButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnClick(go)
	end)

	if data.isCanUser then
		Lock.gameObject:SetActive(false)
	else
		Lock.gameObject:SetActive(true)
	end
	if data.item_id == PersonalInfoManager.GetSelfHeadID() then
		HintText.text = "使用中"
	else
		HintText.text = ""
	end

	return go
end
function HallDressTXPanel:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			GameObject.Destroy(v.gameObject)
		end
	end
	self.CellList = {}
end
function HallDressTXPanel:SetSelectHead(i)
	if not self.selectIndex then
		self.selectIndex = i
	else
		if self.selectIndex == i then
			return
		else
			self.CellList[self.selectIndex].transform:Find("HiImage").gameObject:SetActive(false)
		end
	end
	self.selectIndex = i
	self.CellList[self.selectIndex].transform:Find("HiImage").gameObject:SetActive(true)
	self.selectData = self.data[self.selectIndex]
	self:UpdateUIRight()
end

function HallDressTXPanel:UpdateUIRight()
	self.HeadFrame.sprite = GetTexture(self.selectData.icon)
	self.FrameName.text = self.selectData.desc

	local headid = PersonalInfoManager.GetSelfHeadID()
	if self.selectData.item_id == headid then
		self.DressButton.gameObject:SetActive(false)
		self.NoDress.gameObject:SetActive(true)
		self.NoDressText.text = "已佩戴"
	else
		self.NoDressText.text = "确认佩戴"
		local ct = ConditionManager.GetConditionToID(self.selectData.ct_id)
		if ct then
			local islock = self.selectData.isCanUser
			if islock then
				self.DressButton.gameObject:SetActive(true)
				self.NoDress.gameObject:SetActive(false)
			else
				self.DressButton.gameObject:SetActive(false)
				self.NoDress.gameObject:SetActive(true)
			end
		else
			self.DressButton.gameObject:SetActive(true)
			self.NoDress.gameObject:SetActive(false)
		end
	end
	local ct = ConditionManager.GetConditionToID(self.selectData.ct_id)
	if ct then
		self.LockText1.text = "解锁:" .. ct.hint_desc
		local islock = self.selectData.isCanUser
		if islock then
			self.LockText2.text = "期限:无限制"
		else
			self.LockText2.text = "期限:未解锁"
		end
	else
		self.LockText1.text = "解锁:无"
		self.LockText2.text = "期限:无限制"
	end
end

function HallDressTXPanel:OnClick(obj)
	local i = tonumber(obj.name)
	self:SetSelectHead(i)
end
function HallDressTXPanel:OnDressClick()
	local headid = PersonalInfoManager.GetSelfHeadID()
	if self.selectData.item_id ~= headid then
		print("确认使用")
		Network.SendRequest("dressed_head_frame", {id=self.selectData.item_id}, "确认使用")
	end
end

function HallDressTXPanel:dressed_head_frame_response(_,data)
	if data.result == 0 then
		local headid = PersonalInfoManager.GetSelfHeadID()
		for k,v in ipairs(self.data) do
			if v.item_id == headid then
				self.CellList[k].transform:Find("HintText"):GetComponent("Text").text = ""
				break
			end
		end
		self.CellList[self.selectIndex].transform:Find("HintText"):GetComponent("Text").text = "使用中"
		PersonalInfoManager.SetSelfHeadID(self.selectData.item_id)
		self:UpdateUIRight()
	else
		HintPanel.ErrorMsg(data.result)
	end
end
