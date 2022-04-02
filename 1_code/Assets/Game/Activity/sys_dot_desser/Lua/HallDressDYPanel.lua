-- 创建时间:2018-11-09

local basefunc = require "Game.Common.basefunc"

HallDressDYPanel = basefunc.class()

HallDressDYPanel.name = "HallDressDYPanel"


local instance
function HallDressDYPanel.Create(parent)
	instance = HallDressDYPanel.New(parent)
	return instance
end

function HallDressDYPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallDressDYPanel:MakeLister()
    self.lister = {}
    self.lister["model_dress_data"] = basefunc.handler(self, self.model_dress_data)
end

function HallDressDYPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function HallDressDYPanel:MyClose()
	self:ClearCellList()
	if self.curSoundKey then
		soundMgr:CloseLoopSound(self.curSoundKey)
		self.curSoundKey = nil
	end
	self:MyExit()
end

function HallDressDYPanel:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)	 
end

function HallDressDYPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(HallDressDYPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.Cell = tran:Find("Cell")
	self.Content = tran:Find("ScrollView/Viewport/Content")
	self.ShowRect = tran:Find("ShowRect")
	self.LockText1 = tran:Find("ShowRect/LockBG1/Text"):GetComponent("Text")
	self.LockText2 = tran:Find("ShowRect/LockBG2/Text"):GetComponent("Text")
	self.DressButton = tran:Find("ShowRect/DressButton"):GetComponent("Button")
	self.NoDress = tran:Find("ShowRect/NoDress")
	self.DressButton.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        self:OnDressClick()
    end)

	PersonalInfoManager.ReqDressData()
end

function HallDressDYPanel:model_dress_data()
	self.data = PersonalInfoManager.GetSpeedyData()
	self:InitUI()
end

function HallDressDYPanel:InitUI()
	self:UpdateUILeft()
	self:SetSelectHead(1)
end

function HallDressDYPanel:MyRefresh()
end

function HallDressDYPanel:UpdateUILeft()
	self:ClearCellList()
	for k,v in ipairs(self.data) do
		local obj = self:CreateItem(k)
		self.CellList[#self.CellList + 1] = obj
	end
end
-- 创建入口Item
function HallDressDYPanel:CreateItem(i)
	local data = self.data[i]
	local go = GameObject.Instantiate(self.Cell, self.Content)
	local tran = go.transform
	go.name = i
	go.gameObject:SetActive(true)

	local DescText = tran:Find("DescText"):GetComponent("Text")
	local Lock = tran:Find("Lock")
	local HiImage = tran:Find("HiImage")
	HiImage.gameObject:SetActive(false)

	local IconButton = tran:Find("Button"):GetComponent("Button")
	IconButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnClick(go)
	end)

	if data.isCanUser then
		Lock.gameObject:SetActive(false)
	else
		Lock.gameObject:SetActive(true)
	end
	DescText.text = data.desc

	return go
end
function HallDressDYPanel:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			GameObject.Destroy(v.gameObject)
		end
	end
	self.CellList = {}
end
function HallDressDYPanel:SetSelectHead(i)
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

function HallDressDYPanel:UpdateUIRight()
	if self.selectData then
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
	else
	end
end

function HallDressDYPanel:OnClick(obj)
	local i = tonumber(obj.name)
	self:SetSelectHead(i)
end
function HallDressDYPanel:OnDressClick()
	print("确认使用")
	if self.selectData then
		if self.curSoundKey then
			soundMgr:CloseLoopSound(self.curSoundKey)
			self.curSoundKey = nil
		end
		self.curSoundKey = ExtendSoundManager.PlaySound(audio_config.player[self.selectData.voice].audio_name, 1, function ()
			self.curSoundKey = nil
		end)
	end
end


