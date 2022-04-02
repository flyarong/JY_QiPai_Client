-- 创建时间:2018-11-09

local basefunc = require "Game.Common.basefunc"

HallDressBQPanel = basefunc.class()

HallDressBQPanel.name = "HallDressBQPanel"


local instance
function HallDressBQPanel.Create(parent)
	instance = HallDressBQPanel.New(parent)
	return instance
end

function HallDressBQPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function HallDressBQPanel:MakeLister()
    self.lister = {}
    self.lister["model_dress_data"] = basefunc.handler(self, self.model_dress_data)
end

function HallDressBQPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function HallDressBQPanel:MyClose()
	self:ClearCellList()
	if self.ShowAnimObj then
		GameObject.Destroy(self.ShowAnimObj.gameObject)
		self.ShowAnimObj = nil
	end

	self:MyExit()
end

function HallDressBQPanel:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function HallDressBQPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	local obj = newObject(HallDressBQPanel.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.Cell = tran:Find("Cell")
	self.Content = tran:Find("ScrollView/Viewport/Content")
	self.ShowRect = tran:Find("ShowRect")
	self.AnimNode = tran:Find("ShowRect/AnimNode")
	self.FrameName = tran:Find("ShowRect/FrameName"):GetComponent("Text")
	self.LockText1 = tran:Find("ShowRect/LockBG1/Text"):GetComponent("Text")
	self.LockText2 = tran:Find("ShowRect/LockBG2/Text"):GetComponent("Text")

	PersonalInfoManager.ReqDressData()
end

function HallDressBQPanel:model_dress_data()
	self.data = PersonalInfoManager.GetAnimChatData()
	self:InitUI()
end

function HallDressBQPanel:InitUI()
	self:UpdateUILeft()
	self:SetSelectHead(1)
end

function HallDressBQPanel:MyRefresh()
end

function HallDressBQPanel:UpdateUILeft()
	self:ClearCellList()
	for k,v in ipairs(self.data) do
		local obj = self:CreateItem(k)
		self.CellList[#self.CellList + 1] = obj
	end
end
-- 创建入口Item
function HallDressBQPanel:CreateItem(i)
	local data = self.data[i]
	local go = GameObject.Instantiate(self.Cell, self.Content)
	local tran = go.transform
	go.name = i
	go.gameObject:SetActive(true)

	local Icon = tran:Find("IconButton"):GetComponent("Image")
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

	return go
end
function HallDressBQPanel:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			GameObject.Destroy(v.gameObject)
		end
	end
	self.CellList = {}
end
function HallDressBQPanel:SetSelectHead(i)
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

function HallDressBQPanel:UpdateUIRight()
	dump(self.selectData, "<color=red>self.selectData</color>")
	if self.selectData then
		-- 不展示表情
		-- if self.ShowAnimObj then
		-- 	GameObject.Destroy(self.ShowAnimObj.gameObject)
		-- 	self.ShowAnimObj = nil
		-- end
		-- self.ShowAnimObj = GameObject.Instantiate(GetPrefab(self.selectData.effect), self.AnimNode)

		self.FrameName.text = self.selectData.desc

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

function HallDressBQPanel:OnClick(obj)
	local i = tonumber(obj.name)
	self:SetSelectHead(i)
end


