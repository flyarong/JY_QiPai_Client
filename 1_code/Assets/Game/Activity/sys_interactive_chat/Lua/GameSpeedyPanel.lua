-- 创建时间:2018-09-10
local basefunc = require "Game.Common.basefunc"
GameSpeedyPanel = basefunc.class()

GameSpeedyPanel.instance = nil
function GameSpeedyPanel.Create()
	GameSpeedyPanel.instance = GameSpeedyPanel.New()
	return GameSpeedyPanel.instance
end

function GameSpeedyPanel.Show()
	if not GameSpeedyPanel.instance then
		GameSpeedyPanel.Create()
	end
	GameSpeedyPanel.instance:ShowUI()
end
function GameSpeedyPanel.Hide()
	if GameSpeedyPanel.instance then
		GameSpeedyPanel.instance:HideUI()
		GameSpeedyPanel.instance:CloseSpeedyCell()
	end
	GameSpeedyModel.isCanPlay = true
end

function GameSpeedyPanel.Exit()
	if GameSpeedyPanel.instance then
		GameSpeedyPanel.instance:ExitUI()
	end
	GameSpeedyPanel.instance = nil
end

function GameSpeedyPanel:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GameSpeedyPanel:MakeLister()
	dump(debug.traceback(),"<color=green>狗阿米。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。</color>")
    self.lister = {}
    self.lister["model_dress_data"] = basefunc.handler(self, self.model_dress_data)
end

function GameSpeedyPanel:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function GameSpeedyPanel:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
    self.gameObject = newObject("GameSpeedyPanel", parent)
    self.transform = self.gameObject.transform
    local tran = self.transform

	self:MakeLister()
    self:AddMsgListener()

    self.OperRect = tran:Find("OperRect")
    self.OperRect.gameObject:SetActive(false)
    self.ScrollView = tran:Find("OperRect/ScrollView")
    self.Node = tran:Find("OperRect/ScrollView/Viewport/Content")
    self.Cell = tran:Find("OperRect/Cell")
    self.TopButton = tran:Find("OperRect/TopButton"):GetComponent("MyButton")
    EventTriggerListener.Get(self.TopButton.gameObject).onClick = basefunc.handler(self, self.HideUI)

    self.ChatNode = tran:Find("ChatNode")
	self.ChatCell = tran:Find("ChatNode/ChatCell")
	
	if MainModel.GetLocalType() == "mj" then
		self.gameType = "MJ3D"
		self.ScrollView.localPosition = Vector3.New(500, -57, 0)
	else
		self.gameType = "DDZ"
		self.ScrollView.localPosition = Vector3.New(587, -72, 0)
	end
    self:InitRect()
end

function GameSpeedyPanel:model_dress_data()
	self:CloseSpeedyCell()
	local data = GameSpeedyModel.GetSpeedyData()
	self.data_map = {}
	for k,v in ipairs(data) do
		self.data_map[v.item_id] = v
	end
	local ii = 0
	if self.CellList and next(self.CellList) then
		for k,v in ipairs(data) do
			local obj = self.CellList[k]
			local tran = obj.transform
			tran:Find("Text"):GetComponent("Text").text = v.desc
			local lock_icon = tran:Find("Lock")
			local lock = not v.isCanUser
			lock_icon.gameObject:SetActive(lock)
		end
	else
		self.CellList = {}
		for k,v in ipairs(data) do
			local obj = GameObject.Instantiate(self.Cell, self.Node)
			obj.gameObject:SetActive(true)
			obj.gameObject.name = v.item_id
			self.CellList[#self.CellList + 1] = obj
			local tran = obj.transform
			local BGImage = tran:Find("BGImage")
			if ii%2 == 0 then
				BGImage.gameObject:SetActive(false)
			end
			ii = ii + 1
			tran:Find("Text"):GetComponent("Text").text = v.desc
			local btn = tran:GetComponent("Button")

			local lock_icon = tran:Find("Lock")
			local lock = not v.isCanUser
			lock_icon.gameObject:SetActive(lock)

			btn.onClick:AddListener(function ()
				self:OnSpeedyClick(obj,v.ct_id)
			end)

			local condition_config = ConditionManager.GetConditionToID(v.ct_id)
			if condition_config then
				if condition_config.ct_type == "honor" then
					if GameGlobalOnOff.Honor == false then
						obj.gameObject:SetActive(false)
					end
				elseif condition_config.ct_type == "vip" then
					if GameGlobalOnOff.Vip == false then
						obj.gameObject:SetActive(false)
					end
				end
			end	
		end
	end
end

function GameSpeedyPanel:InitRect()
	PersonalInfoManager.ReqDressData()
end
function GameSpeedyPanel:CloseSpeedyCell()
	if self.SpeedyCellList then
		print(#self.SpeedyCellList)
		for k,v in pairs(self.SpeedyCellList) do
			v:Destroy()
		end
	end
	self.SpeedyCellList = {}
	self.SpeedyCellIndex = 1
end
function GameSpeedyPanel:PlayFinish(key)
	if self.SpeedyCellList[key] then
		self.SpeedyCellList[key]:Destroy()
		self.SpeedyCellList[key] = nil
	end
end
function GameSpeedyPanel:OnSpeedyClick(obj,ct_id)
    local key = obj.name
	if not self.data_map[tonumber(key)].isCanUser then
		ConditionManager.CheckCondition(ct_id, 1)
		return
	end

	if GameSpeedyModel.isCanPlay then
	    GameSpeedyModel.isCanPlay = false
	    Network.SendRequest("send_player_easy_chat", {parm=key})
	    self:HideUI()
	else
		LittleTips.Create("聊天发送太快")
	end
end

function GameSpeedyPanel:ShowUI()
	self.OperRect.gameObject:SetActive(true)
end
function GameSpeedyPanel:HideUI()
	self.OperRect.gameObject:SetActive(false)
end

function GameSpeedyPanel:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end
function GameSpeedyPanel:ExitUI()
	self:MyExit()
end

local MJ3DAnimChatShowPos =
{
    [1] = {pos = {x=-750, y=-200, z=0}, rota= {x=0, y=0, z=0}},
    [2] = {pos = {x=745, y=268, z=0}, rota= {x=0, y=180, z=0}},
    [3] = {pos = {x=286, y=474, z=0}, rota= {x=0, y=180, z=0}},
    [4] = {pos = {x=-745, y=268, z=0}, rota= {x=0, y=0, z=0}},
}

local DDZHeroAnimChatShowPos =
{
    [1] = {pos = {x=-600, y=-100, z=0}, rota= {x=0, y=0, z=0}},
    [2] = {pos = {x=600, y=270, z=0}, rota= {x=0, y=180, z=0}},
    [3] = {pos = {x=-600, y=370, z=0}, rota= {x=0, y=0, z=0}},
}
function GameSpeedyPanel:GetShowPos (uipos, isdz)
	if self.gameType == "MJ3D" then
		return MJ3DAnimChatShowPos[uipos]
	else
		return DDZHeroAnimChatShowPos[uipos]
	end
end

function GameSpeedyPanel:PlayVoice(data)
	local isSelf = false
	if data.player_id == MainModel.UserInfo.user_id then
		isSelf = true
	end
	local key = tonumber(data.parm)
	local speedyData = GameSpeedyModel.SpeedyConfig.mapconfig[key]
	
    if speedyData and soundMgr:GetIsSoundOn(MainModel.sound_pattern) then
	    local uiPos = self:GetShowPos(GameSpeedyLogic.gameModel.GetAnimChatShowPos(data.player_id))
	    local key = "SpeedyCellKey" .. self.SpeedyCellIndex .. "id=" .. data.player_id
	    local obj = GameSpeedyPrefab.Create(speedyData, uiPos, self.ChatNode, isSelf, key)
	    self.SpeedyCellList[key] = obj
	else
		if isSelf then
			GameSpeedyModel.isCanPlay = true
		end
    end
end

