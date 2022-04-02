-- 创建时间:2018-08-06

local basefunc = require "Game.Common.basefunc"

RoomCardCreate = basefunc.class()

RoomCardCreate.name = "RoomCardCreate"

local instance
function RoomCardCreate.Create(parent)
	instance = RoomCardCreate.New(parent)
	return instance
end
function RoomCardCreate.MyExit()
	if instance then
		instance:CloseUI()
		instance = nil
	end
end
function RoomCardCreate:CloseUI()
	GameObject.Destroy(self.gameObject)
end

function RoomCardCreate:ctor(parent)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(RoomCardCreate.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self.LeftNode = tran:Find("LeftBG/ScrollView/Viewport/Content")
	self.RightNode = tran:Find("RightBG/ScrollView/Viewport/Content")
	self.CellLeft = tran:Find("CellLeft")
	self.CellRight = tran:Find("CellRight")
	self.CellLine = tran:Find("CellLine")
	self.CellDesc = tran:Find("CellDesc")
	self.OneLayout = self.CellRight:Find("Layout/OneLayout")
	self.TwoLayout = self.CellRight:Find("Layout/TwoLayout")

	self.BackButton = tran:Find("BackButton")
	self.CreateButton = tran:Find("RightBG/CreateButton")
	EventTriggerListener.Get(self.BackButton.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	EventTriggerListener.Get(self.CreateButton.gameObject).onClick = basefunc.handler(self, self.OnCreateClick)

	self.mapAreaID = MainModel.GetAreaID()
	self.gamelist = RoomCardModel.UIConfig.areagame[self.mapAreaID].gamelist

	self:InitUI()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end
function RoomCardCreate:InitUI()
	self:ClearCellList()
	for k,v in ipairs(self.gamelist) do
		local obj = self:CreateItem(k)
		self.CellList[#self.CellList + 1] = obj
		if k == 1 then
			self:CallToggleClick(k)
		end
	end
end
function RoomCardCreate:ClearCellList()
	if self.CellList then
		for k,v in ipairs(self.CellList) do
			GameObject.Destroy(v.gameObject)
		end
	end
	self.CellList = {}
end
-- 创建入口Item
function RoomCardCreate:CreateItem(i)
	local data = RoomCardModel.UIConfig.config[self.gamelist[i]]
	local go = GameObject.Instantiate(self.CellLeft, self.LeftNode)
	local tran = go.transform
	go.name = i
	go.gameObject:SetActive(true)
	local toggle = tran:Find("SelectButton"):GetComponent("Button")
	toggle.onClick:AddListener(function ()
		self:OnToggleClick(toggle)
	end)

	tran:Find("SelectButton/Text"):GetComponent("Text").text = data.name
	tran:Find("HiImage/Text"):GetComponent("Text").text = data.name
	tran:Find("SelectButton").gameObject:SetActive(true)
	tran:Find("HiImage").gameObject:SetActive(false)

	local state = gameMgr:CheckUpdate(data.sceneName)
	if state == "Install" or state == "Update" then
		tran:Find("HintText"):GetComponent("Text").text = "(需下载)"
	else
		tran:Find("HintText"):GetComponent("Text").text = ""
	end

	return go
end
function RoomCardCreate:OnToggleClick(obj)
	local i = tonumber(obj.transform.parent.name)
	local data = RoomCardModel.UIConfig.config[self.gamelist[i]]
	local state = gameMgr:CheckUpdate(data.sceneName)
	if state == "Install" or state == "Update" then
		RoomCardDown.Create(data.sceneName, function ()
			for i = 1, #self.gamelist do
				local HintText = self.CellList[i].transform:Find("HintText"):GetComponent("Text")
				local data = RoomCardModel.UIConfig.config[self.gamelist[i]]
				local state = gameMgr:CheckUpdate(data.sceneName)
				if state == "Install" or state == "Update" then
					HintText.text = "(需下载)"
				else
					HintText.text = ""
				end
			end
			self:CallToggleClick(i)
		end)
		return
	end

    self:CallToggleClick(i)
end
function RoomCardCreate:CallToggleClick(i)
	local id = RoomCardModel.UIConfig.config[self.gamelist[i]].ruleId
	local gameID = RoomCardModel.UIConfig.config[self.gamelist[i]].gameID
	if self.selectIndex and self.selectIndex == i then
		return
	end
	if self.selectIndex then
		self.CellList[self.selectIndex].transform:Find("SelectButton").gameObject:SetActive(true)
		self.CellList[self.selectIndex].transform:Find("HiImage").gameObject:SetActive(false)
	end

	self.selectIndex = i
	self.CellList[self.selectIndex].transform:Find("SelectButton").gameObject:SetActive(false)
	self.CellList[self.selectIndex].transform:Find("HiImage").gameObject:SetActive(true)

	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local options = PlayerPrefs.GetString(MainModel.CreateRoomCardParm .. "gameidE" .. gameID, "")
	self.bufoptions = nil
	if options ~= "" then
		local list = StringHelper.Split(options, ',')
		self.bufoptions = {}
		for k,v in ipairs(list) do
			self.bufoptions[v] = 1
		end
	end
	self:UpdateRule(RoomCardModel.UIConfig.rule[id])
end

function RoomCardCreate:UpdateRule(data)
	self:ClearRuleCell()
	local nn = #data
	for k,v in ipairs(data) do
		local obj = self:CreateRuleItem(v)
		self.RuleCellList[#self.RuleCellList + 1] = obj

		-- 新加描述
		if v.desc then
			local obj1 = GameObject.Instantiate(self.CellDesc, self.RightNode)
			obj1.gameObject:SetActive(true)
			local FunDescText = obj1.transform:Find("FunDescText"):GetComponent("Text")
			FunDescText.text = v.desc
			self.RuleCellList[#self.RuleCellList + 1] = obj1			
		end

		if k ~= nn then
			local obj1 = GameObject.Instantiate(self.CellLine, self.RightNode)
			obj1.gameObject:SetActive(true)
			self.RuleCellList[#self.RuleCellList + 1] = obj1
		end
	end

	self.RightNode.localPosition = Vector3.zero
end
function RoomCardCreate:CreateRuleItem(data)
	local obj = GameObject.Instantiate(self.CellRight, self.RightNode)
	local tran = obj.transform
	obj.gameObject:SetActive(true)
	tran:Find("TitleNode/TitleText"):GetComponent("Text").text = data.title
	local Layout = tran:Find("Layout")

	for k,v in ipairs(data.data) do
		local cell
		if v.type == "one" then
			cell = self.OneLayout
		else
			cell = self.TwoLayout			
		end
		local obj1 = GameObject.Instantiate(cell, Layout)
		local tran1 = obj1.transform
		obj1.name = "" .. k
		obj1.gameObject:SetActive(true)

		local cell2 = tran1:Find("Cell")
		for k1,v1 in ipairs(v.names) do
			local obj2 = GameObject.Instantiate(cell2, tran1)
			obj2.gameObject:SetActive(true)
			local tran2 = obj2.transform
			obj2.name = "" .. v.serV[k1]
			tran2:Find("Button/Text"):GetComponent("Text").text = v1
			if (self.bufoptions and self.bufoptions[ v.serV[k1] ]) or (not self.bufoptions and v.firstsel[k1] == 1) then
				local toggle = tran2:Find("Button"):GetComponent("Toggle")
				toggle.isOn = true
			end
			self.ToggleList[#self.ToggleList + 1] = obj2
		end
	end

	return obj
end
function RoomCardCreate:ClearRuleCell()
	if self.RuleCellList then
		for k,v in ipairs(self.RuleCellList) do
			GameObject.Destroy(v.gameObject)
		end
	end
	self.RuleCellList = {}
	self.ToggleList = {}
end

-- 关闭
function RoomCardCreate:OnBackClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    self:CloseUI()
end
-- 创建
function RoomCardCreate:OnCreateClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local data = RoomCardModel.UIConfig.config[self.gamelist[self.selectIndex]]
	local call = function ()
	local list = {}
	local options = ""
	for k,v in ipairs(self.ToggleList) do
		if v.transform:Find("Button"):GetComponent("Toggle").isOn then
			list[v.gameObject.name] = 1
			options = options .. "," .. v.gameObject.name
		end
	end
	PlayerPrefs.SetString(MainModel.CreateRoomCardParm .. "gameidE" .. data.gameID, options)

	RoomCardModel.data.game_type = RoomCardModel.RoomCardGameTypeTable[data.sceneName]
	RoomCardModel.data.room_cfg = {}
	for k,v in pairs(list) do
		table.insert(RoomCardModel.data.room_cfg,{option=k,value=v})
	end
	dump(RoomCardModel.data.room_cfg, "<color=red>创建房间的参数</color>")
	print(RoomCardModel.data.game_type)
	Network.SendRequest("friendgame_create_room", {game_type=RoomCardModel.data.game_type, game_cfg=RoomCardModel.data.room_cfg}, "请求创建房间", function(data)
		if data.result == 0 then
			RoomCardLogic.JoinRoomCardByData()
		elseif data.result == 1026 then
            HintPanel.Create(3, "你的房卡不足，是否购买", function()
                    PayPanel.Create(GOODS_TYPE.item)
                end
            )
		else
			HintPanel.ErrorMsg(data.result)
		end
	end)
end
	ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
	local state = gameMgr:CheckUpdate(data.sceneName)
	if state == "Install" or state == "Update" then
		RoomCardDown.Create(data.sceneName, function ()
			call()
		end)
	else
		call()
	end
end


